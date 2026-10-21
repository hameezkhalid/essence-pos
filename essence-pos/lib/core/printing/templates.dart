import 'dart:convert';

import 'package:intl/intl.dart';

import '../db/database.dart';
import '../money.dart';
import '../models/order_models.dart';
import '../models/settings_models.dart';
import '../tax/tax_engine.dart';
import 'receipt_doc.dart';

final _dt = DateFormat('d MMM yyyy  h:mm a');
final _time = DateFormat('h:mm a');

String _typeLine(Order o) {
  switch (o.type) {
    case OrderType.dineIn:
      final t = o.tableLabel == null ? 'Dine-in' : 'Dine-in · Table ${o.tableLabel}';
      return o.guests == null ? t : '$t · ${o.guests} guests';
    case OrderType.takeaway:
      return 'Takeaway';
    case OrderType.delivery:
      return 'Delivery';
  }
}

List<RLine> _storeHeader(AppSettings s) {
  final st = s.store;
  return [
    if (s.receipt.showLogo) const RLogo(),
    if (!s.receipt.showLogo) RText(st.name.toUpperCase(), align: RAlign.center, big: true, bold: true),
    if (st.tagline.isNotEmpty && !s.receipt.showLogo) RText(st.tagline, align: RAlign.center),
    if (st.address.isNotEmpty) RText(st.address, align: RAlign.center),
    if (st.phone.isNotEmpty) RText('Tel: ${st.phone}', align: RAlign.center),
    if (st.ntn.isNotEmpty || st.strn.isNotEmpty)
      RText([if (st.ntn.isNotEmpty) 'NTN: ${st.ntn}', if (st.strn.isNotEmpty) 'STRN: ${st.strn}'].join('   '), align: RAlign.center),
    if (s.receipt.header.trim().isNotEmpty) RText(s.receipt.header.trim(), align: RAlign.center),
  ];
}

/// Customer receipt / sales tax invoice.
ReceiptDoc buildReceipt(Order o, AppSettings s, {bool reprint = false}) {
  final lines = o.lines;
  final payments = o.payments;
  final taxLines = o.taxLines;
  final fbrOn = s.fbr.enabled && o.fiscalStatus != 'none';
  final out = <RLine>[
    ..._storeHeader(s),
    const RDivider('='),
    RText(fbrOn ? 'SALES TAX INVOICE' : 'SALES RECEIPT', align: RAlign.center, bold: true),
    if (reprint) const RText('*** DUPLICATE COPY ***', align: RAlign.center),
    if (o.status == OrderStatus.voided) const RText('*** VOIDED ***', align: RAlign.center, bold: true),
    RRow('Invoice: ${o.displayNumber}', s.receipt.showToken && o.token != null ? 'Token ${o.tokenLabel}' : ''),
    RRow(_dt.format(o.created), 'POS ${o.deviceCode}'),
    RRow(_typeLine(o), s.receipt.showCashier ? 'Cashier: ${o.staffName}' : ''),
    if (o.customerName != null && o.customerName!.isNotEmpty)
      RText('Customer: ${o.customerName}${o.customerPhone?.isNotEmpty == true ? ' · ${o.customerPhone}' : ''}'),
    if (o.deliveryAddress != null && o.deliveryAddress!.isNotEmpty) RText('Deliver to: ${o.deliveryAddress}'),
    const RDivider(),
  ];

  for (final l in lines) {
    out.add(RRow('${l.qty} x ${l.title}', num0(l.gross)));
    if (l.qty > 1) out.add(RText('    @ ${num0(l.unitPrice)} each'));
    if (l.modifiers.isNotEmpty) out.add(RText('    ${l.optionsText}'));
    if (l.note != null && l.note!.isNotEmpty) out.add(RText('    Note: ${l.note}'));
    if (l.discount != null) {
      final d = l.discount!.apply(l.gross);
      if (d > 0) out.add(RRow('Discount ${l.discount!.display}', '-${num0(d)}', indent: 4));
    }
  }
  out.add(const RDivider());

  final lineDisc = lines.fold<int>(0, (a, l) => a + (l.discount?.apply(l.gross) ?? 0));
  final orderDisc = o.discountTotal - lineDisc;
  out.add(RRow('Subtotal (${o.itemCount} items)', num0(o.itemsGross)));
  if (o.discountTotal > 0) {
    final od = o.orderDiscount;
    out.add(RRow(od != null && orderDisc > 0 ? 'Discount ${od.label ?? od.display}' : 'Discounts', '-${num0(o.discountTotal)}'));
  }
  for (final c in o.charges) {
    out.add(RRow(c.label, num0(c.amount)));
  }
  if (!o.pricesIncludeTax) {
    for (final t in taxLines) {
      out.add(RRow('${t.name} ${pct(t.rateBp)} (${t.group.label})', num0(t.amount)));
    }
  }
  if (o.fbrFee > 0) out.add(RRow('FBR POS fee', num0(o.fbrFee)));
  if (o.rounding != 0) out.add(RRow('Rounding', num0(o.rounding)));
  out.add(RRow('TOTAL', rs(o.total), bold: true, tall: true));
  if (o.pricesIncludeTax && s.receipt.showTaxBreakdown) {
    for (final t in taxLines) {
      out.add(RRow('Incl. ${t.name} ${pct(t.rateBp)} (${t.group.label})', num0(t.amount)));
    }
    out.add(RRow('Value excl. tax', num0(o.netExTax)));
  } else if (!o.pricesIncludeTax && s.receipt.showTaxBreakdown && o.taxTotal > 0) {
    out.add(RRow('Value excl. tax', num0(o.netExTax)));
  }
  out.add(const RDivider());

  for (final p in payments) {
    out.add(RRow('Paid · ${p.methodName}', num0(p.tendered ?? p.amount)));
    if (p.change > 0) out.add(RRow('Change', num0(p.change), bold: true));
  }
  if (o.refundedTotal > 0) out.add(RRow('Refunded', '-${num0(o.refundedTotal)}'));

  if (fbrOn) {
    out.add(const RDivider());
    if (o.fiscalStatus == 'reported' && o.fiscalInvoiceNo != null) {
      out.addAll([
        const RText('FBR Invoice Number', align: RAlign.center, bold: true),
        RText(o.fiscalInvoiceNo!, align: RAlign.center, bold: true),
        RQr(o.fiscalInvoiceNo!),
        const RText('Verify this invoice through the FBR', align: RAlign.center),
        const RText('Tax Asaan app or SMS at 9966', align: RAlign.center),
      ]);
    } else {
      out.addAll(const [
        RText('FBR invoice pending', align: RAlign.center, bold: true),
        RText('Will be reported automatically when the', align: RAlign.center),
        RText('connection is back. Ask for a reprint.', align: RAlign.center),
      ]);
    }
  }

  out.add(const RDivider());
  if (s.receipt.footer.trim().isNotEmpty) out.add(RText(s.receipt.footer.trim(), align: RAlign.center));
  out.add(const RText('Powered by NIBNOX', align: RAlign.center));
  return ReceiptDoc(out, title: 'Receipt ${o.displayNumber}');
}

/// Bar / kitchen order ticket. Prints only lines (or the quantity) not sent before.
ReceiptDoc buildKot(Order o, List<OrderLine> lines, {bool addition = false}) {
  final out = <RLine>[
    RText(addition ? 'KOT - ADDITION' : 'KOT', align: RAlign.center, big: true, bold: true),
    if (o.token != null) RText('Token ${o.tokenLabel}', align: RAlign.center, big: true),
    RText(_typeLine(o), align: RAlign.center, bold: true),
    RText('${_time.format(DateTime.now())} · ${o.staffName} · POS ${o.deviceCode}', align: RAlign.center),
    if (o.customerName?.isNotEmpty == true) RText('For: ${o.customerName}', align: RAlign.center),
    const RDivider('='),
  ];
  for (final l in lines) {
    out.add(RText('${l.qty} x ${l.title}', tall: true, bold: true));
    if (l.modifiers.isNotEmpty) out.add(RText('   + ${l.optionsText}'));
    if (l.note?.isNotEmpty == true) out.add(RText('   ! ${l.note}', bold: true));
  }
  out.add(const RDivider('='));
  if (o.note?.isNotEmpty == true) out.add(RText('Note: ${o.note}', bold: true));
  out.add(RText(o.number ?? 'Open order', align: RAlign.center));
  return ReceiptDoc(out, title: 'KOT');
}

ReceiptDoc buildRefundSlip(Refund r, Order o, AppSettings s) {
  final lines = decodeRefundLines(r.linesJson);
  return ReceiptDoc([
    ..._storeHeader(s),
    const RDivider('='),
    const RText('REFUND', align: RAlign.center, big: true, bold: true),
    RRow('Original: ${o.displayNumber}', ''),
    RRow(_dt.format(DateTime.fromMillisecondsSinceEpoch(r.createdAt)), 'POS ${o.deviceCode}'),
    RText('By: ${r.staffName}${r.approvedBy != null ? ' · Approved: ${r.approvedBy}' : ''}'),
    const RDivider(),
    for (final l in lines) RRow('${l['qty']} x ${l['name']}', num0((l['amount'] as num).toInt())),
    const RDivider(),
    if (r.taxAmount > 0) RRow('Tax refunded', num0(r.taxAmount)),
    RRow('REFUND · ${r.methodName}', rs(r.amount), bold: true, tall: true),
    RText('Reason: ${r.reason}'),
    const RFeed(2),
    const RText('Customer signature: ____________________'),
  ], title: 'Refund');
}

List<Map<String, dynamic>> decodeRefundLines(String json) {
  try {
    return [for (final e in jsonDecode(json) as List) Map<String, dynamic>.from(e as Map)];
  } catch (_) {
    return const [];
  }
}

/// Figures for an X (mid-shift) or Z (closing) report.
class ShiftSummary {
  ShiftSummary({
    required this.shift,
    required this.orders,
    required this.refunds,
    required this.cashIn,
    required this.cashOut,
  });

  final Shift shift;
  final List<Order> orders;
  final List<Refund> refunds;
  final int cashIn;
  final int cashOut;

  List<Order> get sales => orders.where((o) => o.isSale).toList();
  List<Order> get voids => orders.where((o) => o.status == OrderStatus.voided).toList();
  int get grossSales => sales.fold(0, (a, o) => a + o.itemsGross);
  int get discounts => sales.fold(0, (a, o) => a + o.discountTotal);
  int get charges => sales.fold(0, (a, o) => a + o.chargesTotal);
  int get tax => sales.fold(0, (a, o) => a + o.taxTotal);
  int get fees => sales.fold(0, (a, o) => a + o.fbrFee);
  int get roundingTotal => sales.fold(0, (a, o) => a + o.rounding);
  int get totalCollected => sales.fold(0, (a, o) => a + o.total);
  int get refundTotal => refunds.fold(0, (a, r) => a + r.amount);
  int get netSales => totalCollected - refundTotal;

  Map<String, int> get byMethod {
    final m = <String, int>{};
    for (final o in sales) {
      for (final p in o.payments) {
        m[p.methodName] = (m[p.methodName] ?? 0) + p.amount;
      }
    }
    return m;
  }

  Map<String, int> get taxByRate {
    final m = <String, int>{};
    for (final o in sales) {
      for (final t in o.taxLines) {
        final k = '${t.name} ${pct(t.rateBp)} (${t.group.label})';
        m[k] = (m[k] ?? 0) + t.amount;
      }
    }
    return m;
  }

  int get cashSales {
    var c = 0;
    for (final o in sales) {
      for (final p in o.payments) {
        if (p.group == RateGroup.cash) c += p.amount;
      }
    }
    return c;
  }

  int get cashRefunds => refunds.where((r) => r.rateGroup == 'cash').fold(0, (a, r) => a + r.amount);
  int get expectedCash => shift.openingFloat + cashSales + cashIn - cashOut - cashRefunds;

  Map<String, dynamic> toJson() => {
        'orders': sales.length,
        'voids': voids.length,
        'grossSales': grossSales,
        'discounts': discounts,
        'charges': charges,
        'tax': tax,
        'fees': fees,
        'rounding': roundingTotal,
        'totalCollected': totalCollected,
        'refunds': refundTotal,
        'netSales': netSales,
        'byMethod': byMethod,
        'taxByRate': taxByRate,
        'cashSales': cashSales,
        'cashIn': cashIn,
        'cashOut': cashOut,
        'cashRefunds': cashRefunds,
        'expectedCash': expectedCash,
      };
}

ReceiptDoc buildShiftReport(ShiftSummary sm, AppSettings s, {required bool closing}) {
  final sh = sm.shift;
  final counted = sh.countedCash;
  return ReceiptDoc([
    RText(s.store.name.toUpperCase(), align: RAlign.center, bold: true, big: true),
    RText(closing ? 'Z-REPORT (SHIFT CLOSE)' : 'X-REPORT (MID-SHIFT)', align: RAlign.center, bold: true),
    const RDivider('='),
    RRow('Terminal', sh.deviceCode),
    RRow('Opened', '${_dt.format(DateTime.fromMillisecondsSinceEpoch(sh.openedAt))} · ${sh.openedByName}'),
    if (sh.closedAt != null) RRow('Closed', '${_dt.format(DateTime.fromMillisecondsSinceEpoch(sh.closedAt!))} · ${sh.closedByName}'),
    RRow('Printed', _dt.format(DateTime.now())),
    const RDivider(),
    const RText('SALES', bold: true),
    RRow('Orders', '${sm.sales.length}'),
    RRow('Gross sales', num0(sm.grossSales)),
    RRow('Discounts', '-${num0(sm.discounts)}'),
    if (sm.charges > 0) RRow('Charges', num0(sm.charges)),
    for (final e in sm.taxByRate.entries) RRow(e.key, num0(e.value)),
    RRow('FBR POS fees', num0(sm.fees)),
    if (sm.roundingTotal != 0) RRow('Rounding', num0(sm.roundingTotal)),
    RRow('Total collected', num0(sm.totalCollected), bold: true),
    RRow('Refunds (${sm.refunds.length})', '-${num0(sm.refundTotal)}'),
    RRow('Voids (${sm.voids.length})', num0(sm.voids.fold(0, (a, o) => a + o.total))),
    RRow('NET SALES', rs(sm.netSales), bold: true, tall: true),
    const RDivider(),
    const RText('PAYMENTS', bold: true),
    for (final e in sm.byMethod.entries) RRow(e.key, num0(e.value)),
    const RDivider(),
    const RText('CASH DRAWER', bold: true),
    RRow('Opening float', num0(sh.openingFloat)),
    RRow('Cash sales', num0(sm.cashSales)),
    RRow('Cash in', num0(sm.cashIn)),
    RRow('Cash out', '-${num0(sm.cashOut)}'),
    RRow('Cash refunds', '-${num0(sm.cashRefunds)}'),
    RRow('Expected in drawer', num0(sm.expectedCash), bold: true),
    if (counted != null) ...[
      RRow('Counted', num0(counted), bold: true),
      RRow(counted - sm.expectedCash >= 0 ? 'Over' : 'Short', num0((counted - sm.expectedCash).abs()), bold: true),
    ],
    const RDivider(),
    const RFeed(1),
    const RText('Manager signature: ____________________'),
  ], title: closing ? 'Z-Report' : 'X-Report');
}

ReceiptDoc buildTestPage(String printerName, int paperMm, AppSettings s) => ReceiptDoc([
      const RLogo(),
      const RText('TEST PRINT', align: RAlign.center, big: true, bold: true),
      RText(printerName, align: RAlign.center),
      RText('${paperMm}mm paper · ${DateFormat('d MMM yyyy h:mm a').format(DateTime.now())}', align: RAlign.center),
      const RDivider(),
      const RRow('Left text', 'Right'),
      const RText('Bold text', bold: true),
      const RText('Tall text', tall: true),
      const RText('Big', big: true),
      const RDivider('='),
      const RText('QR code below', align: RAlign.center),
      const RQr('ESSENCE-POS-TEST'),
      RText('If you can read this, ${s.store.name} POS can print.', align: RAlign.center),
    ], title: 'Test print');
