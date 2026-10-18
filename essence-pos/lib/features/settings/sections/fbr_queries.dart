import 'package:drift/drift.dart';

import '../../../core/db/database.dart';

/// Invoices for [businessDate] grouped by fiscal status ('none' | 'pending' | 'reported' | 'failed').
/// Held orders (no invoice number yet) are not counted.
Stream<Map<String, int>> watchFiscalCounts(AppDatabase db, String businessDate) {
  final count = db.orders.id.count();
  final q = db.selectOnly(db.orders)
    ..addColumns([db.orders.fiscalStatus, count])
    ..where(db.orders.businessDate.equals(businessDate) & db.orders.deleted.equals(false) & db.orders.number.isNotNull())
    ..groupBy([db.orders.fiscalStatus]);
  return q.watch().map((rows) => {for (final r in rows) r.read(db.orders.fiscalStatus) ?? 'none': r.read(count) ?? 0});
}
