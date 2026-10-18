import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';

import '../db/database.dart';
import '../models/cart.dart';
import '../money.dart';
import '../models/order_models.dart';
import '../models/settings_models.dart';
import '../printing/printer_config.dart';
import '../printing/printer_service.dart';
import '../printing/receipt_doc.dart';
import '../printing/templates.dart';
import '../tax/tax_engine.dart';
import 'inventory_service.dart';
import 'pos_context.dart';
import 'repos.dart';

class PrintNotice {
  const PrintNotice(this.message, {this.error = false});
  final String message;
  final bool error;
}

/// Selling: checkout, hold, send to bar, void, refund, reprint.
class PosService {
  PosService(this.db, this.ctx, this.inventory, this.printer) : audit = AuditRepo(db);

  final AppDatabase db;
  final PosContext ctx;
  final InventoryService inventory;
  final PrinterService printer;
  final AuditRepo audit;

  final _notices = StreamController<PrintNotice>.broadcast();

  /// Printing problems and confirmations for the UI.
  Stream<PrintNotice> get notices => _notices.stream;

  AppSettings get settings => ctx.settings;

  // ───────────── Bill ─────────────

  List<ChargeRule> chargesFor(OrderType t) => settings.charges.rulesFor(t);

  BillResult bill(CartState cart, List<PaymentPortionInput> portions) => computeBill(
        lines: cart.billLines,
        orderDiscount: cart.orderDiscount,
        charges: chargesFor(cart.type),
        config: ctx.billConfig,
        portions: portions,
      );

  Paisa previewTotal(CartState cart, RateGroup g) => totalIfPaidWith(
        lines: cart.billLines,
        orderDiscount: cart.orderDiscount,
        charges: chargesFor(cart.type),
        config: ctx.billConfig,
        group: g,
      );

  // ───────────── Numbering ─────────────

  Future<String> _nextInvoiceNumber() async {
    final seq = await db.nextCounter('seq.invoice');
    return '${settings.store.invoicePrefix}-${ctx.device.code}-${seq.toString().padLeft(6, '0')}';
  }

  Future<int> _nextToken(String businessDate) => db.nextCounter('seq.token.$businessDate');

  // ───────────── Checkout ─────────────

  /// Completes a sale. [payments] carry what each method paid (from [BillResult.portions])
  /// plus cash tendered/change. Printing happens in the background.
  Future<Order> checkout({
    required CartState cart,
    required List<PaymentPortionInput> portions,
    required Map<int, int> tenderedByPortion,
    required StaffMember staff,
    required Shift? shift,
  }) async {
    final b = bill(cart, portions);
    if (b.isEmpty) throw StateError('Cart is empty');
    final now = DateTime.now();
    final businessDate = ctx.businessDate(now);
    final number = await _nextInvoiceNumber();
    final token = cart.token ?? await _nextToken(businessDate);

    final payments = <PaymentRecord>[
      for (var i = 0; i < b.portions.length; i++)
        PaymentRecord(
          methodId: b.portions[i].methodId,
          methodName: b.portions[i].methodName,
          group: b.portions[i].group,
          amount: b.portions[i].amount,
          tendered: tenderedByPortion[i],
          change: (tenderedByPortion[i] ?? b.portions[i].amount) - b.portions[i].amount > 0
              ? (tenderedByPortion[i]! - b.portions[i].amount)
              : 0,
          taxes: b.portions[i].taxes,
        ),
    ];

    final lines = [
      for (var i = 0; i < cart.lines.length; i++) cart.lines[i].copyWith(net: b.lines[i].net),
    ];
    final unsent = [
      for (final l in lines)
        if (l.qty > l.sentQty) l.copyWith(qty: l.qty - l.sentQty),
    ];
    final fbrOn = settings.fbr.enabled;
    final id = cart.heldOrderId ?? newId();
    final createdAt = cart.heldOrderId != null
        ? (await (db.select(db.orders)..where((o) => o.id.equals(id))).getSingleOrNull())?.createdAt ?? now.millisecondsSinceEpoch
        : now.millisecondsSinceEpoch;

    final order = Order(
      id: id,
      updatedAt: nowMs(),
      deleted: false,
      number: number,
      token: token,
      businessDate: businessDate,
      orderType: cart.type.key,
      status: OrderStatus.paid,
      tableId: cart.tableId,
      tableLabel: cart.tableLabel,
      guests: cart.guests,
      customerId: cart.customerId,
      customerName: cart.customerName,
      customerPhone: cart.customerPhone,
      deliveryAddress: cart.deliveryAddress,
      linesJson: jsonEncode([for (final l in lines) l.copyWith(sentQty: l.qty).toJson()]),
      orderDiscountJson: cart.orderDiscount == null ? null : jsonEncode(cart.orderDiscount!.toJson()),
      chargesJson: jsonEncode([
        for (final c in b.charges) ChargeRecord(type: c.type.name, label: c.label, amount: c.amount, taxable: c.taxable).toJson(),
      ]),
      taxLinesJson: jsonEncode([for (final t in b.taxLines) t.toJson()]),
      paymentsJson: jsonEncode([for (final p in payments) p.toJson()]),
      pricesIncludeTax: b.pricesIncludeTax,
      itemsGross: b.itemsGross,
      discountTotal: b.discountTotal,
      chargesTotal: b.chargesTotal,
      taxTotal: b.taxTotal,
      fbrFee: b.fbrFee,
      rounding: b.rounding,
      total: b.total,
      netExTax: b.netExTax,
      refundedTotal: 0,
      note: cart.note,
      staffId: staff.id,
      staffName: staff.name,
      shiftId: shift?.id,
      deviceId: ctx.device.id,
      deviceCode: ctx.device.code,
      kotSent: true,
      fiscalStatus: fbrOn ? 'pending' : 'none',
      createdAt: createdAt,
      paidAt: now.millisecondsSinceEpoch,
    );
    await db.saveSynced(db.orders, order);
    await inventory.applyLines(lines, refId: order.id, type: 'sale', restore: false, staff: staff, deviceId: ctx.device.id);

    if (cart.hasDiscount) {
      await audit.log('discount', staff: staff, deviceId: ctx.device.id, details: {
        'order': number,
        'amount': b.discountTotal,
        if (cart.orderDiscount != null) 'orderDiscount': cart.orderDiscount!.toJson(),
        if (cart.discountApprovedBy != null) 'approvedBy': cart.discountApprovedBy,
      });
    }

    final opensDrawer = payments.any((p) => ctx.methods.where((m) => m.id == p.methodId).any((m) => m.opensDrawer));
    unawaited(_printSale(order, unsent, opensDrawer));
    return order;
  }

  Future<void> _printSale(Order order, List<OrderLine> unsentKot, bool drawer) async {
    final r = settings.receipt;
    try {
      if (r.printKotOnPay && unsentKot.isNotEmpty) {
        _report(await printer.print(buildKot(order, unsentKot), PrintRole.kot, copies: r.kotCopies), 'Bar ticket');
      }
      if (r.autoPrintReceipt) {
        final fresh = await _fresh(order.id) ?? order;
        _report(await printer.print(buildReceipt(fresh, settings).withDrawer(drawer), PrintRole.receipt, copies: r.receiptCopies), 'Receipt');
      } else if (drawer) {
        _report(await printer.openDrawer(), 'Cash drawer');
      }
    } catch (e) {
      _notices.add(PrintNotice('Printing failed: $e', error: true));
    }
  }

  void _report(PrintResult res, String what) {
    for (final e in res.errors) {
      _notices.add(PrintNotice('$what not printed — $e', error: true));
    }
  }

  Future<Order?> _fresh(String id) => (db.select(db.orders)..where((o) => o.id.equals(id))).getSingleOrNull();

  // ───────────── Hold / send to bar ─────────────

  /// Parks the cart as a held order (visible on every terminal). Returns the saved order.
  Future<Order> hold(CartState cart, {required StaffMember staff, Shift? shift, bool sendToBar = false}) async {
    final now = DateTime.now();
    final businessDate = ctx.businessDate(now);
    final token = cart.token ?? await _nextToken(businessDate);
    final b = bill(cart, [const PaymentPortionInput(methodId: 'cash', methodName: 'Cash', group: RateGroup.cash)]);
    final unsent = [
      for (final l in cart.lines)
        if (l.qty > l.sentQty) l.copyWith(qty: l.qty - l.sentQty),
    ];
    final lines = sendToBar ? [for (final l in cart.lines) l.copyWith(sentQty: l.qty)] : cart.lines;
    final existing = cart.heldOrderId == null ? null : await _fresh(cart.heldOrderId!);
    final order = Order(
      id: cart.heldOrderId ?? newId(),
      updatedAt: nowMs(),
      deleted: false,
      number: null,
      token: token,
      businessDate: businessDate,
      orderType: cart.type.key,
      status: OrderStatus.held,
      tableId: cart.tableId,
      tableLabel: cart.tableLabel,
      guests: cart.guests,
      customerId: cart.customerId,
      customerName: cart.customerName,
      customerPhone: cart.customerPhone,
      deliveryAddress: cart.deliveryAddress,
      linesJson: jsonEncode([for (final l in lines) l.toJson()]),
      orderDiscountJson: cart.orderDiscount == null ? null : jsonEncode(cart.orderDiscount!.toJson()),
      chargesJson: '[]',
      taxLinesJson: '[]',
      paymentsJson: '[]',
      pricesIncludeTax: b.pricesIncludeTax,
      itemsGross: b.itemsGross,
      discountTotal: b.discountTotal,
      chargesTotal: b.chargesTotal,
      taxTotal: b.taxTotal,
      fbrFee: b.fbrFee,
      rounding: b.rounding,
      total: b.total,
      netExTax: b.netExTax,
      refundedTotal: 0,
      note: cart.note,
      staffId: staff.id,
      staffName: staff.name,
      shiftId: shift?.id,
      deviceId: ctx.device.id,
      deviceCode: ctx.device.code,
      kotSent: sendToBar || (existing?.kotSent ?? false),
      fiscalStatus: 'none',
      createdAt: existing?.createdAt ?? now.millisecondsSinceEpoch,
    );
    await db.saveSynced(db.orders, order);
    if (sendToBar && unsent.isNotEmpty) {
      final res = await printer.print(buildKot(order, unsent, addition: existing?.kotSent ?? false), PrintRole.kot,
          copies: settings.receipt.kotCopies);
      _report(res, 'Bar ticket');
    }
    return order;
  }

  /// Discards a held order (e.g. customer left).
  Future<void> discardHeld(String orderId, StaffMember staff) async {
    final o = await _fresh(orderId);
    if (o == null || o.status != OrderStatus.held) return;
    await db.saveSynced(db.orders, o.copyWith(deleted: true, updatedAt: nowMs()));
    await audit.log('discardHeld', staff: staff, deviceId: ctx.device.id, details: {'token': o.token, 'total': o.total});
  }

  Stream<List<Order>> watchHeld() => (db.select(db.orders)
        ..where((o) => o.status.equals(OrderStatus.held) & o.deleted.equals(false))
        ..orderBy([(o) => OrderingTerm.asc(o.createdAt)]))
      .watch();

  // ───────────── Orders ─────────────

  Stream<List<Order>> watchOrders({required String fromDate, required String toDate, int limit = 500}) => (db.select(db.orders)
        ..where((o) => o.deleted.equals(false) & o.status.isNotValue(OrderStatus.held) & o.businessDate.isBetweenValues(fromDate, toDate))
        ..orderBy([(o) => OrderingTerm.desc(o.createdAt)])
        ..limit(limit))
      .watch();

  Stream<Order?> watchOrder(String id) => (db.select(db.orders)..where((o) => o.id.equals(id))).watchSingleOrNull();

  Stream<List<Refund>> watchRefunds(String orderId) =>
      (db.select(db.refunds)..where((r) => r.orderId.equals(orderId) & r.deleted.equals(false))).watch();

  Future<void> reprint(Order o) async {
    final res = await printer.print(buildReceipt(o, settings, reprint: true), PrintRole.receipt);
    _report(res, 'Receipt');
    if (res.nothingConfigured) _notices.add(const PrintNotice('No receipt printer set up — see Settings › Printers', error: true));
  }

  Future<void> reprintKot(Order o) async {
    final res = await printer.print(buildKot(o, o.lines), PrintRole.kot);
    _report(res, 'Bar ticket');
  }

  // ───────────── Void & refund ─────────────

  Future<void> voidOrder(Order o, {required String reason, required StaffMember staff, StaffMember? approvedBy}) async {
    if (o.status != OrderStatus.paid || o.refundedTotal > 0) throw StateError('Only unrefunded paid orders can be voided');
    await db.saveSynced(
      db.orders,
      o.copyWith(status: OrderStatus.voided, voidReason: Value(reason), voidedBy: Value(approvedBy?.name ?? staff.name), updatedAt: nowMs()),
    );
    await inventory.applyLines(o.lines, refId: o.id, type: 'void', restore: true, staff: staff, deviceId: ctx.device.id);
    await audit.log('void', staff: staff, approvedBy: approvedBy, deviceId: ctx.device.id, details: {'order': o.number, 'total': o.total, 'reason': reason});
  }

  /// Refund amount and tax for returning [qtyByKey] of [o]'s lines.
  static ({int amount, int tax}) refundValue(Order o, Map<String, int> qtyByKey) {
    final lines = o.lines;
    final linesNet = lines.fold<int>(0, (a, l) => a + l.net);
    if (linesNet <= 0) return (amount: 0, tax: 0);
    var refundNet = 0.0;
    for (final l in lines) {
      final q = qtyByKey[l.key] ?? 0;
      if (q > 0 && l.qty > 0) refundNet += l.net * q / l.qty;
    }
    final phi = refundNet / linesNet;
    final refundable = o.total - o.fbrFee - o.rounding;
    var amount = (refundable * phi / 100).round() * 100;
    if (amount > o.netSales) amount = o.netSales;
    final tax = (o.taxTotal * phi / 100).round() * 100;
    return (amount: amount, tax: tax);
  }

  Future<Refund> refund(
    Order o, {
    required Map<String, int> qtyByKey,
    required PaymentMethod method,
    required String reason,
    required bool restock,
    required StaffMember staff,
    StaffMember? approvedBy,
    Shift? shift,
  }) async {
    final v = refundValue(o, qtyByKey);
    if (v.amount <= 0) throw StateError('Nothing to refund');
    final now = DateTime.now();
    final lines = o.lines;
    final refundLines = [
      for (final l in lines)
        if ((qtyByKey[l.key] ?? 0) > 0)
          {'key': l.key, 'name': l.title, 'qty': qtyByKey[l.key], 'amount': (l.net * qtyByKey[l.key]! / l.qty).round()},
    ];
    final r = Refund(
      id: newId(),
      updatedAt: nowMs(),
      deleted: false,
      orderId: o.id,
      orderNumber: o.displayNumber,
      linesJson: jsonEncode(refundLines),
      amount: v.amount,
      taxAmount: v.tax,
      methodId: method.id,
      methodName: method.name,
      rateGroup: method.rateGroup,
      reason: reason,
      restock: restock,
      staffId: staff.id,
      staffName: staff.name,
      approvedBy: approvedBy?.name,
      shiftId: shift?.id,
      deviceId: ctx.device.id,
      businessDate: ctx.businessDate(now),
      createdAt: now.millisecondsSinceEpoch,
    );
    final newLines = [for (final l in lines) l.copyWith(refundedQty: l.refundedQty + (qtyByKey[l.key] ?? 0))];
    final allBack = newLines.every((l) => l.refundedQty >= l.qty);
    await db.transaction(() async {
      await db.saveSynced(db.refunds, r);
      await db.saveSynced(
        db.orders,
        o.copyWith(
          linesJson: jsonEncode([for (final l in newLines) l.toJson()]),
          refundedTotal: o.refundedTotal + v.amount,
          status: allBack ? OrderStatus.refunded : OrderStatus.partiallyRefunded,
          updatedAt: nowMs(),
        ),
      );
    });
    if (restock) {
      await inventory.applyLines(lines,
          refId: r.id, type: 'refund', restore: true, qtyOf: (l) => qtyByKey[l.key] ?? 0, staff: staff, deviceId: ctx.device.id);
    }
    await audit.log('refund', staff: staff, approvedBy: approvedBy, deviceId: ctx.device.id, details: {
      'order': o.number,
      'amount': v.amount,
      'method': method.name,
      'reason': reason,
    });
    unawaited(() async {
      final res = await printer.print(
        buildRefundSlip(r, o, settings).withDrawer(method.opensDrawer),
        PrintRole.receipt,
      );
      _report(res, 'Refund slip');
    }());
    return r;
  }

  Future<PrintResult> noSaleDrawer(StaffMember staff, {StaffMember? approvedBy}) async {
    await audit.log('drawerOpen', staff: staff, approvedBy: approvedBy, deviceId: ctx.device.id);
    final r = await printer.openDrawer();
    _report(r, 'Cash drawer');
    return r;
  }

  ReceiptDoc receiptFor(Order o, {bool reprint = false}) => buildReceipt(o, settings, reprint: reprint);

  void dispose() => _notices.close();
}
