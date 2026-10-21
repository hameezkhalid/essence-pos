import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/db/database.dart';
import '../core/models/settings_models.dart';
import '../core/services/real_menu.dart';
import '../core/services/pos_context.dart';
import '../core/services/repos.dart';
import '../core/sync/firestore_remote.dart';
import '../features/setup/setup_screens.dart';
import '../firebase_options.dart';
import 'boot_actions.dart';
import 'pos_app.dart';
import 'providers.dart';
import 'services.dart';
import 'theme/theme.dart';

const storeId = 'essence';

enum BootPhase { loading, signIn, setup, ready, error }

/// Starts Firebase and the local database, then walks a new terminal through sign-in and
/// setup before handing over to [PosApp].
class BootApp extends StatefulWidget {
  const BootApp({super.key});
  @override
  State<BootApp> createState() => BootAppState();
}

class BootAppState extends State<BootApp> implements BootActions {
  BootPhase phase = BootPhase.loading;
  String? error;
  AppDatabase? db;
  AppServices? services;
  ThemeMode themeMode = ThemeMode.system;
  int _generation = 0;

  FirebaseFirestore get firestore => FirebaseFirestore.instance;
  FirestoreRemote get remote => FirestoreRemote(firestore, storeId);

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      db ??= AppDatabase();
      themeMode = themeModeFrom(await db!.getMeta('ui.theme'));
      final user = await FirebaseAuth.instance.authStateChanges().first.timeout(const Duration(seconds: 8), onTimeout: () => FirebaseAuth.instance.currentUser);
      if (user == null) return _go(BootPhase.signIn);
      if (await db!.getMeta('store.ready') == 'true') {
        await _launch();
        return;
      }
      _go(BootPhase.setup);
    } catch (e) {
      error = '$e';
      _go(BootPhase.error);
    }
  }

  void _go(BootPhase p) {
    if (mounted) setState(() => phase = p);
  }

  Future<DeviceInfo?> _device() async {
    final id = await db!.getMeta('device.id');
    if (id == null) return null;
    return DeviceInfo(id: id, code: await db!.getMeta('device.code') ?? 'T1', name: await db!.getMeta('device.name') ?? 'Counter 1');
  }

  Future<void> _launch() async {
    final device = await _device();
    if (device == null) return _go(BootPhase.setup);
    final s = await AppServices.create(db!, firestore, device, storeId: storeId);
    await s.start();
    services = s;
    _generation++;
    _go(BootPhase.ready);
  }

  // ───────────── Called by the setup screens ─────────────

  Future<void> onSignedIn() async {
    if (await db!.getMeta('store.ready') == 'true') return _launch();
    _go(BootPhase.setup);
  }

  /// Finishes setup for a brand-new store (claimed by this account).
  Future<void> setupNewStore({
    required String terminalName,
    required String terminalCode,
    String? ownerName,
    String? ownerPin,
    required void Function(String) onStep,
  }) async {
    await _saveDevice(terminalName, terminalCode);
    onStep('Store settings and menu');
    await seedEssentials(db!, ownerName: ownerName ?? 'Owner', ownerPin: ownerPin ?? '1111');
    await db!.setMeta('store.ready', 'true');
    onStep('Starting the till');
    await _launch();
  }

  /// Finishes setup for a terminal joining an existing store: downloads its data first.
  Future<void> setupJoin({required String terminalName, required String terminalCode, required void Function(String) onStep}) async {
    final device = await _saveDevice(terminalName, terminalCode);
    final s = await AppServices.create(db!, firestore, device, storeId: storeId);
    await s.start();
    onStep('Downloading menu, staff and settings…');
    final until = DateTime.now().add(const Duration(seconds: 90));
    while (DateTime.now().isBefore(until)) {
      final staff = await db!.select(db!.staff).get();
      final products = await db!.select(db!.products).get();
      final orders = await db!.select(db!.orders).get();
      onStep('Downloaded ${products.length} products, ${staff.length} staff, ${orders.length} orders…');
      if (staff.isNotEmpty && products.isNotEmpty) {
        await Future<void>.delayed(const Duration(seconds: 3));
        break;
      }
      await Future<void>.delayed(const Duration(seconds: 1));
    }
    if ((await db!.select(db!.staff).get()).isEmpty) {
      onStep('No staff found yet — adding store defaults');
      await seedEssentials(db!, ownerName: 'Owner', ownerPin: '1111');
    }
    await s.alignCounters();
    await s.dispose();
    await db!.setMeta('store.ready', 'true');
    await _launch();
  }

  Future<DeviceInfo> _saveDevice(String name, String code) async {
    final id = await db!.getMeta('device.id') ?? newId();
    await db!.setMeta('device.id', id);
    await db!.setMeta('device.name', name.trim().isEmpty ? 'Counter 1' : name.trim());
    await db!.setMeta('device.code', code.trim().isEmpty ? 'T1' : code.trim().toUpperCase());
    return (await _device())!;
  }

  // ───────────── BootActions ─────────────

  @override
  String? get accountEmail => FirebaseAuth.instance.currentUser?.email;

  @override
  Future<String?> signOut() async {
    final s = services;
    if (s != null && s.sync.status.pending > 0) {
      return '${s.sync.status.pending} changes are still waiting to upload. Connect to the internet and wait until everything is synced.';
    }
    await s?.dispose();
    services = null;
    await db!.wipeAll();
    await db!.delete(db!.localMeta).go();
    await FirebaseAuth.instance.signOut();
    _go(BootPhase.signIn);
    return null;
  }

  @override
  Future<String?> clearSalesHistory(void Function(String step) onStep) async {
    final s = services;
    if (s == null) return 'Not ready';
    if (!s.sync.status.online) return 'Connect to the internet to clear sales history.';
    final levels = await db!.stockLevels();
    await s.dispose();
    services = null;
    _go(BootPhase.loading);
    try {
      const collections = ['orders', 'refunds', 'shifts', 'cashMovements', 'auditLogs', 'stockMovements'];
      for (final c in collections) {
        onStep('Clearing $c…');
        await remote.deleteAll(c);
      }
      await db!.transaction(() async {
        await db!.delete(db!.orders).go();
        await db!.delete(db!.refunds).go();
        await db!.delete(db!.shifts).go();
        await db!.delete(db!.cashMovements).go();
        await db!.delete(db!.auditLogs).go();
        await db!.delete(db!.stockMovements).go();
        await db!.delete(db!.outbox).go();
      });
      onStep('Carrying stock levels forward…');
      final now = nowMs();
      await db!.saveAllSynced(db!.stockMovements, [
        for (final e in levels.entries)
          StockMovement(
            id: newId(),
            updatedAt: now,
            deleted: false,
            stockItemId: e.key,
            qty: e.value,
            type: 'opening',
            note: 'Carried forward',
            createdAt: now,
          ),
      ]);
      // Re-pull settings/menu etc. but keep pull cursors for cleared collections at zero.
      for (final c in collections) {
        await db!.setMeta('pull.$c', '0');
      }
      await _launch();
      return null;
    } catch (e) {
      await _launch();
      return 'Clearing failed: $e';
    }
  }

  @override
  Future<void> renameTerminal(String name, String code) async {
    await db!.setMeta('device.name', name.trim());
    await db!.setMeta('device.code', code.trim().toUpperCase());
    final s = services;
    if (s == null) return;
    await s.dispose();
    services = null;
    await _launch();
    await services?.beat();
  }

  @override
  Widget build(BuildContext context) {
    if (phase == BootPhase.ready && services != null) {
      return ProviderScope(
        key: ValueKey(_generation),
        overrides: [
          servicesProvider.overrideWithValue(services!),
          bootActionsProvider.overrideWithValue(this),
        ],
        child: const PosApp(),
      );
    }
    return MaterialApp(
      title: 'Essence POS',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      themeMode: themeMode,
      home: switch (phase) {
        BootPhase.loading || BootPhase.ready => const SplashScreen(),
        BootPhase.signIn => SignInScreen(boot: this),
        BootPhase.setup => SetupScreen(boot: this),
        BootPhase.error => ErrorScreen(message: error ?? 'Unknown error', onRetry: () {
            _go(BootPhase.loading);
            _start();
          }),
      },
    );
  }
}

/// A new store: settings, GST, payment methods, the owner and the Essence dessert menu.
Future<void> seedEssentials(AppDatabase db, {required String ownerName, required String ownerPin}) async {
  final now = nowMs();
  await SettingsRepo(db).saveAll(const AppSettings());
  await db.saveAllSynced(db.taxes, [
    TaxRow(id: 'gst', updatedAt: now, deleted: false, name: 'GST', enabled: true, cashBp: 1500, cardOnlineBp: 500, builtIn: true, sortOrder: 0),
  ]);
  PaymentMethod pm(String id, String name, String group, String icon, int sort, {bool drawer = false, bool builtIn = false}) => PaymentMethod(
        id: id,
        updatedAt: now,
        deleted: false,
        name: name,
        rateGroup: group,
        icon: icon,
        opensDrawer: drawer,
        active: true,
        builtIn: builtIn,
        sortOrder: sort,
      );
  await db.saveAllSynced(db.paymentMethods, [
    pm('cash', 'Cash', 'cash', 'cash', 0, drawer: true, builtIn: true),
    pm('card', 'Card', 'cardOnline', 'card', 1),
    pm('jazzcash', 'JazzCash', 'cardOnline', 'wallet', 2),
    pm('easypaisa', 'Easypaisa', 'cardOnline', 'wallet', 3),
    pm('bank', 'Bank transfer', 'cardOnline', 'bank', 4),
  ]);
  await db.saveAllSynced(db.staff, [StaffRepo.build(id: 'owner', name: ownerName, role: Role.owner, pin: ownerPin)]);
  await RealMenu.seed(db);
  await db.saveAllSynced(db.areas, [Area(id: 'ground', updatedAt: now, deleted: false, name: 'Ground floor', sortOrder: 0)]);
}
