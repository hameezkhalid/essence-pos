import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:flutter/foundation.dart';

import '../core/db/database.dart';
import '../core/models/order_models.dart';
import '../core/models/settings_models.dart';
import '../core/services/pos_context.dart';
import '../core/services/reports.dart';
import '../core/sync/remote_codec.dart';

const dashboardStoreId = 'essence';

/// One low-stock line from `/stores/essence/live/stock`.
class LowStockLine {
  const LowStockLine({required this.name, required this.display, required this.state});
  final String name;
  final String display;

  /// 'low' | 'critical' | 'out'
  final String state;
}

class StockSnapshot {
  const StockSnapshot({required this.updatedAt, required this.stockValue, required this.items, required this.low, this.device});
  final int updatedAt;

  /// Paisa.
  final int stockValue;
  final int items;
  final List<LowStockLine> low;
  final String? device;

  static StockSnapshot fromMap(Map<String, dynamic> d) => StockSnapshot(
        updatedAt: (d['updatedAt'] as num?)?.toInt() ?? 0,
        stockValue: (d['stockValue'] as num?)?.toInt() ?? 0,
        items: (d['items'] as num?)?.toInt() ?? 0,
        device: d['device'] as String?,
        low: [
          for (final e in (d['low'] as List? ?? const []).whereType<Map>())
            LowStockLine(
              name: '${e['name'] ?? 'Item'}',
              display: '${e['display'] ?? ''}',
              state: '${e['state'] ?? 'low'}',
            ),
        ],
      );
}

/// Live view of the store straight from Firestore snapshots (no local database).
/// Listeners stay open while the dashboard is shown, so every figure updates by itself.
class LiveStore extends ChangeNotifier {
  LiveStore(this.fs);

  final FirebaseFirestore fs;
  DocumentReference<Map<String, dynamic>> get _store => fs.collection('stores').doc(dashboardStoreId);
  CollectionReference<Map<String, dynamic>> _col(String c) => _store.collection(c);

  StoreSettings settings = const StoreSettings();
  bool settingsLoaded = false;

  List<Order> _orders = const [];
  List<Refund> _refunds = const [];
  bool ordersLoaded = false;
  bool refundsLoaded = false;
  Map<String, String> categoryNames = const {};
  List<Terminal> terminals = const [];
  bool terminalsLoaded = false;
  StockSnapshot? stock;
  bool stockLoaded = false;

  /// True while the orders listener is serving cached data (connecting / offline).
  bool fromCache = true;
  Object? error;

  String today = '';
  String yesterday = '';

  // Derived figures, recomputed on every change.
  SalesReport todayReport = SalesReport(const [], const []);
  SalesReport yesterdaySoFar = SalesReport(const [], const []);
  SalesReport yesterdayFull = SalesReport(const [], const []);

  /// Latest sales and voids across both days, newest first.
  List<Order> recent = const [];

  final _subs = <StreamSubscription<dynamic>>[];
  StreamSubscription<dynamic>? _ordersSub;
  StreamSubscription<dynamic>? _refundsSub;
  Timer? _tick;
  bool _disposed = false;

  void start() {
    _computeDates();
    _subs.add(_col('settings').doc(SettingKeys.store).snapshots().listen((d) {
      settings = StoreSettings.fromJson(d.exists ? settingValueFromRemote(d.data() ?? const {}) : const {});
      settingsLoaded = true;
      if (_computeDates()) _listenSales();
      _changed();
    }, onError: _onError));
    _subs.add(_col('categories').snapshots().listen((s) {
      final names = <String, String>{};
      for (final d in s.docs) {
        try {
          final c = categoryFromRemote(d.id, d.data());
          if (!c.deleted) names[c.id] = c.name;
        } catch (_) {}
      }
      categoryNames = names;
      _changed();
    }, onError: _onError));
    _subs.add(_col('devices').snapshots().listen((s) {
      final list = <Terminal>[];
      for (final d in s.docs) {
        try {
          final t = terminalFromRemote(d.id, d.data());
          if (!t.deleted) list.add(t);
        } catch (_) {}
      }
      list.sort((a, b) => a.code.compareTo(b.code));
      terminals = list;
      terminalsLoaded = true;
      _changed();
    }, onError: _onError));
    _subs.add(_col('live').doc('stock').snapshots().listen((d) {
      stock = d.exists && d.data() != null ? StockSnapshot.fromMap(d.data()!) : null;
      stockLoaded = true;
      _changed();
    }, onError: (Object e) {
      stockLoaded = true;
      _changed();
    }));
    _listenSales();
    // Business day roll-over, "same time yesterday" cut-off and terminal online state.
    _tick = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_computeDates()) _listenSales();
      _changed();
    });
  }

  /// Returns true when today's business date changed.
  bool _computeDates() {
    final now = DateTime.now();
    final t = businessDateFor(now, settings.dayStartHour);
    if (t == today) return false;
    today = t;
    yesterday = businessDateFor(now.subtract(const Duration(days: 1)), settings.dayStartHour);
    return true;
  }

  void _listenSales() {
    _ordersSub?.cancel();
    _refundsSub?.cancel();
    ordersLoaded = false;
    refundsLoaded = false;
    final days = [today, yesterday];
    _ordersSub = _col('orders').where('businessDate', whereIn: days).snapshots(includeMetadataChanges: true).listen((s) {
      fromCache = s.metadata.isFromCache;
      final list = <Order>[];
      for (final d in s.docs) {
        try {
          final o = orderFromRemote(d.id, d.data());
          if (!o.deleted && o.status != OrderStatus.held) list.add(o);
        } catch (_) {}
      }
      _orders = list;
      ordersLoaded = true;
      error = null;
      _changed();
    }, onError: _onError);
    _refundsSub = _col('refunds').where('businessDate', whereIn: days).snapshots().listen((s) {
      final list = <Refund>[];
      for (final d in s.docs) {
        try {
          final r = refundFromRemote(d.id, d.data());
          if (!r.deleted) list.add(r);
        } catch (_) {}
      }
      _refunds = list;
      refundsLoaded = true;
      _changed();
    }, onError: _onError);
  }

  void _onError(Object e) {
    error = e;
    _changed();
  }

  void _changed() {
    if (_disposed) return;
    _recompute();
    notifyListeners();
  }

  void _recompute() {
    final cutoff = DateTime.now().subtract(const Duration(days: 1)).millisecondsSinceEpoch;
    final t = _orders.where((o) => o.businessDate == today).toList();
    final y = _orders.where((o) => o.businessDate == yesterday).toList();
    final tr = _refunds.where((r) => r.businessDate == today).toList();
    final yr = _refunds.where((r) => r.businessDate == yesterday).toList();
    todayReport = SalesReport(t, tr, categoryNames: categoryNames);
    yesterdayFull = SalesReport(y, yr, categoryNames: categoryNames);
    yesterdaySoFar = SalesReport(
      y.where((o) => o.createdAt <= cutoff).toList(),
      yr.where((r) => r.createdAt <= cutoff).toList(),
      categoryNames: categoryNames,
    );
    recent = ([..._orders]..sort((a, b) => b.createdAt.compareTo(a.createdAt))).take(15).toList();
  }

  bool get salesLoaded => ordersLoaded && refundsLoaded;

  @override
  void dispose() {
    _disposed = true;
    _tick?.cancel();
    _ordersSub?.cancel();
    _refundsSub?.cancel();
    for (final s in _subs) {
      s.cancel();
    }
    super.dispose();
  }
}
