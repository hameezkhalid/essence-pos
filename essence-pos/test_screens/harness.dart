import 'dart:async';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:essence_pos/app/boot_actions.dart';
import 'package:essence_pos/app/pos_app.dart';
import 'package:essence_pos/app/providers.dart';
import 'package:essence_pos/app/services.dart';
import 'package:essence_pos/core/db/database.dart';
import 'package:essence_pos/core/services/demo_data.dart';
import 'package:essence_pos/core/services/pos_context.dart';
import 'package:essence_pos/core/sync/remote_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:essence_pos/features/shell/app_shell.dart';

/// Renders the real app with demo data for visual review. Not part of `flutter test`.
/// Run: flutter test test_screens --update-goldens  → PNGs in test_screens/out/

class NullRemote implements RemoteStore {
  @override
  String get storeId => 'test';
  @override
  Future<void> writeBatch(List<RemoteWrite> writes) async {}
  @override
  Stream<List<RemoteChange>> watch(String collection, {required int sinceMs}) => const Stream.empty();
  @override
  Future<void> writeDerived(String collection, String docId, Map<String, dynamic> data) async {}
  @override
  Future<int> deleteAll(String collection) async => 0;
  @override
  Future<void> setNetworkEnabled(bool enabled) async {}
}

class FakeBoot implements BootActions {
  @override
  String? get accountEmail => 'store@essence.pk';
  @override
  Future<String?> clearSalesHistory(void Function(String step) onStep) async => null;
  @override
  Future<void> renameTerminal(String name, String code) async {}
  @override
  Future<String?> resetDemoData(void Function(String step) onStep) async => null;
  @override
  Future<String?> signOut() async => null;
}

bool _fontsLoaded = false;

Future<void> loadFonts() async {
  if (_fontsLoaded) return;
  _fontsLoaded = true;
  Future<void> load(String family, List<String> paths) async {
    final l = FontLoader(family);
    for (final p in paths) {
      l.addFont(File(p).readAsBytes().then((b) => ByteData.view(b.buffer)));
    }
    await l.load();
  }

  const f = 'assets/fonts';
  await load('Inter', ['$f/Inter-400.ttf', '$f/Inter-500.ttf', '$f/Inter-600.ttf', '$f/Inter-700.ttf', '$f/Inter-800.ttf']);
  await load('Playfair', ['$f/PlayfairDisplay-500.ttf', '$f/PlayfairDisplay-600.ttf', '$f/PlayfairDisplay-700.ttf']);
  await load('JetBrainsMono', ['$f/JetBrainsMono-400.ttf', '$f/JetBrainsMono-600.ttf']);
  final flutterRoot = Platform.environment['FLUTTER_ROOT'] ?? '/Users/hameez/Documents/dev/flutter';
  await load('MaterialIcons', ['$flutterRoot/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf']);
}

class Shot {
  Shot(this.tester, this.container, this.services);
  final WidgetTester tester;
  final ProviderContainer container;
  final AppServices services;

  Future<void> settle([int ms = 600]) async {
    for (var i = 0; i < 6; i++) {
      await tester.pump(Duration(milliseconds: ms ~/ 6));
    }
  }

  Future<void> go(String path) async {
    final ctx = tester.element(find.byType(AppShell).first);
    GoRouter.of(ctx).go(path);
    await settle(1200);
  }

  Future<void> snap(String name) async {
    await settle(400);
    await expectLater(find.byType(MaterialApp).first, matchesGoldenFile('out/$name.png'));
  }
}

Future<Shot> bootApp(WidgetTester tester, {required Size size, String theme = 'light', String role = 'owner'}) async {
  await tester.runAsync(loadFonts);
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  late AppServices svc;
  late StaffMember staff;
  await tester.runAsync(() async {
    final db = AppDatabase(NativeDatabase.memory());
    const device = DeviceInfo(id: 'dev-1', code: 'T1', name: 'Counter 1');
    await DemoData(db, device).seed();
    await db.setMeta('demo.seeded', 'true');
    await db.setMeta('ui.theme', theme);
    await db.delete(db.outbox).go();
    svc = await AppServices.withRemote(db, NullRemote(), device);
    if (await svc.shifts.openShift() == null) {
      final owner = await (db.select(db.staff)..where((s) => s.id.equals('owner'))).getSingle();
      await svc.shifts.open(openingFloat: 1000000, staff: owner);
    }
    staff = await (db.select(db.staff)..where((s) => s.id.equals(role))).getSingle();
  });
  final container = ProviderContainer(overrides: [
    servicesProvider.overrideWithValue(svc),
    bootActionsProvider.overrideWithValue(FakeBoot()),
  ]);
  container.read(sessionProvider.notifier).signIn(staff);
  await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const PosApp()));
  final shot = Shot(tester, container, svc);
  await shot.settle(1500);
  return shot;
}

Future<void> teardown(WidgetTester tester, Shot s) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 3));
  s.container.dispose();
  await tester.pump(const Duration(seconds: 1));
  tester.view.resetPhysicalSize();
  tester.view.resetDevicePixelRatio();
}
