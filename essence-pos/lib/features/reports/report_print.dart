import 'package:intl/intl.dart';

import '../../core/models/order_models.dart';
import '../../core/models/settings_models.dart';
import '../../core/money.dart';
import '../../core/printing/receipt_doc.dart';
import '../../core/services/reports.dart';

/// Printable sales summary for a date range (thermal report printer).
ReceiptDoc buildSalesSummary(SalesReport r, AppSettings s, {required String rangeLabel}) {
  final dt = DateFormat('d MMM yyyy  h:mm a');
  final failed = r.orders.where((o) => o.fiscalStatus == 'failed').length;
  return ReceiptDoc([
    RText(s.store.name.toUpperCase(), align: RAlign.center, bold: true, big: true),
    const RText('SALES SUMMARY', align: RAlign.center, bold: true),
    RText(rangeLabel, align: RAlign.center),
    const RDivider('='),
    RRow('Printed', dt.format(DateTime.now())),
    const RDivider(),
    const RText('SALES', bold: true),
    RRow('Orders', '${r.orderCount}'),
    RRow('Items sold', '${r.itemsSold}'),
    RRow('Gross sales', num0(r.gross)),
    RRow('Discounts', '-${num0(r.discounts)}'),
    if (r.charges > 0) RRow('Charges', num0(r.charges)),
    RRow('Tax collected', num0(r.tax)),
    if (r.fees > 0) RRow('FBR POS fees', num0(r.fees)),
    RRow('Total collected', num0(r.collected), bold: true),
    RRow('Refunds (${r.refunds.length})', '-${num0(r.refundTotal)}'),
    RRow('NET SALES', rs(r.netSales), bold: true, tall: true),
    RRow('Average ticket', num0(r.avgTicket)),
    RRow('Voids (${r.voids.length})', num0(r.voidTotal)),
    const RDivider(),
    const RText('TAX BY RATE', bold: true),
    if (r.taxByRate.isEmpty) const RText('No tax collected'),
    for (final e in r.taxByRate.entries) RRow(e.key, num0(e.value)),
    const RDivider(),
    const RText('PAYMENTS', bold: true),
    for (final e in (r.byMethod.entries.toList()..sort((a, b) => b.value.compareTo(a.value)))) RRow(e.key, num0(e.value)),
    const RDivider(),
    const RText('ORDER TYPES', bold: true),
    for (final t in OrderType.values)
      if ((r.byType[t] ?? 0) > 0) RRow('${t.label} (${r.orders.where((o) => o.type == t).length})', num0(r.byType[t]!)),
    const RDivider(),
    const RText('TOP ITEMS', bold: true),
    for (final i in r.topItems(10)) RRow('${i.qty} x ${i.name}', num0(i.amount)),
    const RDivider(),
    const RText('FBR', bold: true),
    RRow('Reported', '${r.fiscalReported}'),
    RRow('Pending', '${r.fiscalPending}'),
    if (failed > 0) RRow('Failed', '$failed'),
    const RDivider(),
    const RFeed(1),
  ], title: 'Sales summary');
}
