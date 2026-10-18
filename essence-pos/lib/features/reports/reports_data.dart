import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/providers.dart';
import '../../core/db/database.dart';
import '../../core/models/order_models.dart';
import '../../core/services/reports.dart';

/// Inclusive range of business dates (yyyy-MM-dd).
typedef DateSpan = ({String from, String to});

final _key = DateFormat('yyyy-MM-dd');

DateTime spanDay(String d) {
  final t = DateTime.parse(d);
  return DateTime.utc(t.year, t.month, t.day);
}

String spanKey(DateTime d) => _key.format(d);

int spanDays(DateSpan s) => spanDay(s.to).difference(spanDay(s.from)).inDays + 1;

/// The equal-length period just before [s].
DateSpan previousSpan(DateSpan s) {
  final n = spanDays(s);
  final from = spanDay(s.from);
  return (from: spanKey(from.subtract(Duration(days: n))), to: spanKey(from.subtract(const Duration(days: 1))));
}

enum RangePreset {
  today('Today'),
  yesterday('Yesterday'),
  last7('Last 7 days'),
  last30('Last 30 days'),
  thisMonth('This month'),
  custom('Custom');

  const RangePreset(this.label);
  final String label;

  DateSpan span(String today) {
    final t = spanDay(today);
    String k(int daysBack) => spanKey(t.subtract(Duration(days: daysBack)));
    return switch (this) {
      RangePreset.today || RangePreset.custom => (from: today, to: today),
      RangePreset.yesterday => (from: k(1), to: k(1)),
      RangePreset.last7 => (from: k(6), to: today),
      RangePreset.last30 => (from: k(29), to: today),
      RangePreset.thisMonth => (from: spanKey(DateTime.utc(t.year, t.month, 1)), to: today),
    };
  }
}

/// Sales and voided orders (never held or deleted) in a business-date range, live.
final reportOrdersProvider = StreamProvider.autoDispose.family<List<Order>, DateSpan>((ref, s) {
  final db = ref.watch(dbProvider);
  return (db.select(db.orders)
        ..where((o) => o.deleted.equals(false) & o.status.equals(OrderStatus.held).not() & o.businessDate.isBetweenValues(s.from, s.to)))
      .watch();
});

final reportRefundsProvider = StreamProvider.autoDispose.family<List<Refund>, DateSpan>((ref, s) {
  final db = ref.watch(dbProvider);
  return (db.select(db.refunds)..where((r) => r.deleted.equals(false) & r.businessDate.isBetweenValues(s.from, s.to))).watch();
});

/// SalesReport for a range, recomputed whenever orders, refunds or category names change.
final salesReportProvider = Provider.autoDispose.family<AsyncValue<SalesReport>, DateSpan>((ref, s) {
  final orders = ref.watch(reportOrdersProvider(s));
  final refunds = ref.watch(reportRefundsProvider(s));
  final cats = ref.watch(categoriesProvider).value ?? const [];
  if (orders.hasError) return AsyncValue.error(orders.error!, orders.stackTrace ?? StackTrace.current);
  if (refunds.hasError) return AsyncValue.error(refunds.error!, refunds.stackTrace ?? StackTrace.current);
  final o = orders.value, r = refunds.value;
  if (o == null || r == null) return const AsyncValue.loading();
  return AsyncValue.data(SalesReport(o, r, categoryNames: {for (final c in cats) c.id: c.name}));
});
