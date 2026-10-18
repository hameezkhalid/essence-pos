import 'dart:async';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:intl/intl.dart';

import '../db/database.dart';
import '../models/settings_models.dart';
import '../sync/sync_engine.dart';

class FiscalResult {
  const FiscalResult.reported(this.invoiceNo) : error = null;
  const FiscalResult.failed(this.error) : invoiceNo = null;
  final String? invoiceNo;
  final String? error;
  bool get ok => invoiceNo != null;
}

/// Reports a sale to the tax authority and returns its fiscal invoice number.
/// The receipt prints that number and a QR code of it.
abstract class FiscalAdapter {
  Future<FiscalResult> submit(Order order, FbrSettings settings, StoreSettings store);
}

/// Demo adapter: behaves like FBR (short delay, realistic invoice numbers) without a network call.
class MockFbrAdapter implements FiscalAdapter {
  final _rnd = Random();

  @override
  Future<FiscalResult> submit(Order order, FbrSettings settings, StoreSettings store) async {
    await Future<void>.delayed(Duration(milliseconds: 250 + _rnd.nextInt(450)));
    final pos = settings.posId.trim().isEmpty ? '137284' : settings.posId.trim();
    final t = DateTime.fromMillisecondsSinceEpoch(order.createdAt);
    final no = '$pos-${DateFormat('MMdd').format(t)}-${DateFormat('HHmm').format(t)}-${(order.token ?? _rnd.nextInt(99)).toString().padLeft(2, '0')}${_rnd.nextInt(10)}';
    return FiscalResult.reported(no);
  }
}

/// Real FBR POS integration. Added after the demo, once the café's POS ID and token are issued.
class FbrImsAdapter implements FiscalAdapter {
  @override
  Future<FiscalResult> submit(Order order, FbrSettings settings, StoreSettings store) async =>
      const FiscalResult.failed('Live FBR integration is not configured yet');
}

/// Watches orders waiting for a fiscal number and reports them whenever the device is online.
class FiscalQueue {
  FiscalQueue(this.db, this.sync, this.settings, {Map<FbrMode, FiscalAdapter>? adapters})
      : adapters = adapters ?? {FbrMode.mock: MockFbrAdapter(), FbrMode.sandbox: FbrImsAdapter(), FbrMode.live: FbrImsAdapter()};

  final AppDatabase db;
  final SyncEngine sync;
  final AppSettings Function() settings;
  final Map<FbrMode, FiscalAdapter> adapters;

  StreamSubscription<dynamic>? _ordersSub;
  StreamSubscription<dynamic>? _statusSub;
  Timer? _timer;
  bool _running = false;
  String _deviceId = '';

  void start(String deviceId) {
    _deviceId = deviceId;
    // Only this terminal reports its own invoices (avoids double reporting across terminals).
    final q = db.select(db.orders)
      ..where((o) => o.fiscalStatus.equals('pending') & o.deviceId.equals(deviceId) & o.deleted.equals(false));
    _ordersSub = q.watch().listen((_) => run());
    _statusSub = sync.statusStream.listen((s) {
      if (s.online) run();
    });
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => run());
  }

  Future<void> run() async {
    if (_running || !sync.status.online) return;
    _running = true;
    try {
      final s = settings();
      final pending = await (db.select(db.orders)
            ..where((o) => o.fiscalStatus.equals('pending') & o.deviceId.equals(_deviceId) & o.deleted.equals(false))
            ..orderBy([(o) => OrderingTerm.asc(o.createdAt)])
            ..limit(50))
          .get();
      for (final o in pending) {
        if (!sync.status.online) break;
        final adapter = adapters[s.fbr.mode]!;
        FiscalResult r;
        try {
          r = await adapter.submit(o, s.fbr, s.store).timeout(const Duration(seconds: 20));
        } catch (e) {
          r = FiscalResult.failed('$e');
        }
        final fresh = await (db.select(db.orders)..where((x) => x.id.equals(o.id))).getSingle();
        await db.saveSynced(
          db.orders,
          fresh.copyWith(
            fiscalStatus: r.ok ? 'reported' : 'pending',
            fiscalInvoiceNo: Value(r.invoiceNo ?? fresh.fiscalInvoiceNo),
            fiscalError: Value(r.error),
            fiscalAt: Value(r.ok ? nowMs() : fresh.fiscalAt),
            updatedAt: nowMs(),
          ),
        );
        if (!r.ok) break;
      }
    } finally {
      _running = false;
    }
  }

  void stop() {
    _ordersSub?.cancel();
    _statusSub?.cancel();
    _timer?.cancel();
  }
}
