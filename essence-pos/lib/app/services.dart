import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart';

import '../core/db/database.dart';
import '../core/fiscal/fiscal.dart';
import '../core/models/menu_models.dart';
import '../core/printing/printer_service.dart';
import '../core/services/inventory_service.dart';
import '../core/services/pos_context.dart';
import '../core/services/pos_service.dart';
import '../core/services/repos.dart';
import '../core/services/shift_service.dart';
import '../core/sync/account_admin.dart';
import '../core/sync/firestore_remote.dart';
import '../core/sync/remote_store.dart';
import '../core/sync/sync_engine.dart';
import '../firebase_options.dart';

const appVersion = '1.0.0';

/// Everything a configured terminal runs. Created once the device is signed in and set up.
class AppServices {
  AppServices._(this.db, this.remote, this.device)
      : ctx = PosContext(db, device),
        printer = PrinterService(db),
        settingsRepo = SettingsRepo(db),
        menu = MenuRepo(db),
        staff = StaffRepo(db),
        customers = CustomerRepo(db),
        audit = AuditRepo(db),
        inventory = InventoryService(db) {
    sync = SyncEngine(db, remote);
    pos = PosService(db, ctx, inventory, printer);
    shifts = ShiftService(db, ctx, printer);
    fiscal = FiscalQueue(db, sync, () => ctx.settings);
  }

  final AppDatabase db;
  final RemoteStore remote;

  /// Firestore-specific features (store logins); null when running against a test remote.
  FirestoreRemote? get firestore => remote is FirestoreRemote ? remote as FirestoreRemote : null;

  /// Creates logins for other tills / the owner (admins only).
  AccountAdmin get accounts => AccountAdmin(DefaultFirebaseOptions.currentPlatform.apiKey);
  final DeviceInfo device;
  final PosContext ctx;
  final PrinterService printer;
  final SettingsRepo settingsRepo;
  final MenuRepo menu;
  final StaffRepo staff;
  final CustomerRepo customers;
  final AuditRepo audit;
  final InventoryService inventory;
  late final SyncEngine sync;
  late final PosService pos;
  late final ShiftService shifts;
  late final FiscalQueue fiscal;

  final _subs = <StreamSubscription<dynamic>>[];
  Timer? _heartbeat;
  Timer? _stockDebounce;

  static Future<AppServices> create(AppDatabase db, FirebaseFirestore firestore, DeviceInfo device, {String storeId = 'essence'}) =>
      withRemote(db, FirestoreRemote(firestore, storeId), device);

  /// Any cloud implementation (tests use an in-memory one).
  static Future<AppServices> withRemote(AppDatabase db, RemoteStore remote, DeviceInfo device) async {
    final s = AppServices._(db, remote, device);
    await s.ctx.start();
    return s;
  }

  Future<void> start() async {
    await sync.start();
    fiscal.start(device.id);
    _heartbeat = Timer.periodic(const Duration(minutes: 5), (_) => beat());
    unawaited(beat());
    // Publish a live stock summary for the owner dashboard (debounced, best effort).
    _subs.add(inventory.watchStock().listen((_) {
      _stockDebounce?.cancel();
      _stockDebounce = Timer(const Duration(seconds: 20), _publishStock);
    }));
  }

  /// Marks this terminal as seen (shown on the dashboard's terminal list).
  Future<void> beat() async {
    if (!sync.status.online) return;
    final t = await (db.select(db.terminals)..where((t) => t.id.equals(device.id))).getSingleOrNull();
    await db.saveSynced(
      db.terminals,
      Terminal(
        id: device.id,
        updatedAt: nowMs(),
        deleted: false,
        name: t?.name ?? device.name,
        code: device.code,
        lastSeenAt: nowMs(),
        appVersion: appVersion,
      ),
    );
  }

  Future<void> _publishStock() async {
    if (!sync.status.online) return;
    try {
      final stock = await inventory.watchStock().first;
      final low = stock.where((s) => s.item.active && s.needsReorder).toList()..sort((a, b) => b.state.index.compareTo(a.state.index));
      await remote.writeDerived('live', 'stock', {
        'updatedAt': nowMs(),
        'device': device.code,
        'stockValue': stock.fold<double>(0, (a, s) => a + s.value).round(),
        'items': stock.length,
        'low': [
          for (final s in low.take(30))
            {'id': s.item.id, 'name': s.item.name, 'qty': s.qty, 'unit': s.item.unit, 'reorder': s.item.reorderLevel, 'state': s.state.name, 'display': s.item.fmt(s.qty)},
        ],
      });
    } catch (_) {}
  }

  /// After joining an existing store, continue invoice numbers from this terminal code's last invoice.
  Future<void> alignCounters() async {
    final prefix = '${ctx.settings.store.invoicePrefix}-${device.code}-';
    final last = await (db.select(db.orders)
          ..where((o) => o.number.like('$prefix%'))
          ..orderBy([(o) => OrderingTerm.desc(o.number)])
          ..limit(1))
        .getSingleOrNull();
    final n = int.tryParse(last?.number?.substring(prefix.length) ?? '') ?? 0;
    final cur = int.tryParse(await db.getMeta('seq.invoice') ?? '') ?? 0;
    if (n > cur) await db.setMeta('seq.invoice', '$n');
  }

  Future<void> dispose() async {
    _heartbeat?.cancel();
    _stockDebounce?.cancel();
    for (final s in _subs) {
      unawaited(s.cancel());
    }
    fiscal.stop();
    await sync.dispose();
    ctx.dispose();
    pos.dispose();
    inventory.dispose();
  }
}
