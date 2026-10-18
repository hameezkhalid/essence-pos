import '../db/database.dart';
import '../models/order_models.dart';
import '../money.dart';

class ItemStat {
  ItemStat(this.name);
  final String name;
  int qty = 0;
  int amount = 0;
}

/// Sales figures for a set of orders and refunds. Pure, so both the POS (SQLite) and the
/// owner dashboard (Firestore) compute identical numbers.
class SalesReport {
  SalesReport(List<Order> allOrders, this.refunds, {Map<String, String> categoryNames = const {}})
      : orders = allOrders.where((o) => o.isSale).toList(),
        voids = allOrders.where((o) => o.status == OrderStatus.voided).toList() {
    for (final o in orders) {
      gross += o.itemsGross;
      discounts += o.discountTotal;
      charges += o.chargesTotal;
      tax += o.taxTotal;
      fees += o.fbrFee;
      collected += o.total;
      netExTax += o.netExTax;
      final h = o.created.hour;
      byHour[h] = (byHour[h] ?? 0) + o.total;
      byDay[o.businessDate] = (byDay[o.businessDate] ?? 0) + o.total;
      ordersByDay[o.businessDate] = (ordersByDay[o.businessDate] ?? 0) + 1;
      byType[o.type] = (byType[o.type] ?? 0) + o.total;
      for (final p in o.payments) {
        byMethod[p.methodName] = (byMethod[p.methodName] ?? 0) + p.amount;
      }
      for (final t in o.taxLines) {
        final k = '${t.name} ${pct(t.rateBp)} · ${t.group.label}';
        taxByRate[k] = (taxByRate[k] ?? 0) + t.amount;
      }
      for (final l in o.lines) {
        itemsSold += l.qty;
        (items[l.name] ??= ItemStat(l.name))
          ..qty += l.qty
          ..amount += l.net;
        final cat = categoryNames[l.categoryId] ?? 'Other';
        byCategory[cat] = (byCategory[cat] ?? 0) + l.net;
      }
      switch (o.fiscalStatus) {
        case 'reported':
          fiscalReported++;
        case 'pending':
          fiscalPending++;
      }
    }
    for (final r in refunds) {
      refundTotal += r.amount;
    }
  }

  final List<Order> orders;
  final List<Order> voids;
  final List<Refund> refunds;

  int gross = 0, discounts = 0, charges = 0, tax = 0, fees = 0, collected = 0, netExTax = 0, refundTotal = 0, itemsSold = 0;
  int fiscalReported = 0, fiscalPending = 0;
  final Map<int, int> byHour = {};
  final Map<String, int> byDay = {};
  final Map<String, int> ordersByDay = {};
  final Map<OrderType, int> byType = {};
  final Map<String, int> byMethod = {};
  final Map<String, int> taxByRate = {};
  final Map<String, int> byCategory = {};
  final Map<String, ItemStat> items = {};

  int get orderCount => orders.length;
  int get netSales => collected - refundTotal;
  int get avgTicket => orderCount == 0 ? 0 : (collected / orderCount / 100).round() * 100;
  int get voidTotal => voids.fold(0, (a, o) => a + o.total);

  List<ItemStat> topItems([int n = 10]) => (items.values.toList()..sort((a, b) => b.qty.compareTo(a.qty))).take(n).toList();

  String toCsv() {
    final b = StringBuffer('Invoice,Date,Time,Type,Status,Items,Gross,Discount,Charges,Tax,FBR fee,Total,Refunded,Payment,Cashier,Terminal,FBR invoice\n');
    String esc(String s) => s.contains(',') || s.contains('"') ? '"${s.replaceAll('"', '""')}"' : s;
    String r(int p) => (p / 100).toStringAsFixed(2);
    for (final o in [...orders, ...voids]..sort((a, b) => a.createdAt.compareTo(b.createdAt))) {
      final t = o.created;
      b.writeln([
        o.displayNumber,
        o.businessDate,
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}',
        o.type.label,
        OrderStatus.label(o.status),
        '${o.itemCount}',
        r(o.itemsGross),
        r(o.discountTotal),
        r(o.chargesTotal),
        r(o.taxTotal),
        r(o.fbrFee),
        r(o.total),
        r(o.refundedTotal),
        o.payments.map((p) => '${p.methodName} ${r(p.amount)}').join(' + '),
        o.staffName,
        o.deviceCode,
        o.fiscalInvoiceNo ?? '',
      ].map(esc).join(','));
    }
    return b.toString();
  }
}
