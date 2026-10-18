import 'dart:async';
import 'dart:convert';

import 'package:drift/native.dart';
import 'package:essence_pos/core/db/database.dart';
import 'package:essence_pos/core/models/cart.dart';
import 'package:essence_pos/core/models/menu_models.dart';
import 'package:essence_pos/core/models/order_models.dart';
import 'package:essence_pos/core/printing/printer_service.dart';
import 'package:essence_pos/core/services/demo_data.dart';
import 'package:essence_pos/core/services/inventory_service.dart';
import 'package:essence_pos/core/services/pos_context.dart';
import 'package:essence_pos/core/services/pos_service.dart';
import 'package:essence_pos/core/services/reports.dart';
import 'package:essence_pos/core/services/shift_service.dart';
import 'package:essence_pos/core/sync/remote_store.dart';
import 'package:essence_pos/core/sync/sync_engine.dart';
import 'package:essence_pos/core/tax/tax_engine.dart';
import 'package:flutter_test/flutter_test.dart';

/// In-memory cloud used to test sync between two "terminals".
class FakeRemote implements RemoteStore {
  final docs = <String, Map<String, Map<String, dynamic>>>{};
  final _changes = StreamController<(String, String)>.broadcast();
  int _clock = 1000;

  @override
  String get storeId => 'test';

  @override
  Future<void> writeBatch(List<RemoteWrite> writes) async {
    for (final w in writes) {
      final col = docs.putIfAbsent(w.collection, () => {});
      col[w.docId] = {...?col[w.docId], ...jsonDecode(jsonEncode(w.data)) as Map<String, dynamic>, 'syncedAt': ++_clock};
      _changes.add((w.collection, w.docId));
    }
  }

  @override
  Stream<List<RemoteChange>> watch(String collection, {required int sinceMs}) async* {
    final initial = [
      for (final e in (docs[collection] ?? {}).entries)
        if ((e.value['syncedAt'] as int) >= sinceMs) RemoteChange(RemoteChangeType.upsert, e.key, e.value, e.value['syncedAt'] as int),
    ];
    yield initial;
    await for (final c in _changes.stream.where((c) => c.$1 == collection)) {
      final d = docs[collection]![c.$2]!;
      yield [RemoteChange(RemoteChangeType.upsert, c.$2, d, d['syncedAt'] as int)];
    }
  }

  @override
  Future<void> writeDerived(String collection, String docId, Map<String, dynamic> data) async {}

  @override
  Future<int> deleteAll(String collection) async => (docs.remove(collection) ?? {}).length;

  @override
  Future<void> setNetworkEnabled(bool enabled) async {}
}

Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 400));

void main() {
  late AppDatabase db;
  late PosContext ctx;
  late InventoryService inventory;
  late PosService pos;
  const device = DeviceInfo(id: 'dev-1', code: 'T1', name: 'Counter 1');

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await DemoData(db, device).seed();
    ctx = PosContext(db, device);
    await ctx.start();
    inventory = InventoryService(db);
    pos = PosService(db, ctx, inventory, PrinterService(db));
  });

  tearDown(() async {
    ctx.dispose();
    await db.close();
  });

  Future<StaffMember> cashier() => (db.select(db.staff)..where((s) => s.id.equals('cashier'))).getSingle();

  OrderLine lineFor(Product p, {String? size, int qty = 1, List<SelectedModifier> mods = const []}) => OrderLine(
        key: 'k-${p.id}-$size',
        productId: p.id,
        categoryId: p.categoryId,
        name: p.name,
        basePrice: p.price,
        size: size == null ? null : p.sizes.firstWhere((s) => s.code == size),
        modifiers: mods,
        qty: qty,
      );

  test('demo seed creates menu, history and outbox', () async {
    expect(await db.select(db.products).get(), hasLength(greaterThan(40)));
    final orders = await db.select(db.orders).get();
    expect(orders.length, greaterThan(800));
    expect(await db.watchOutboxCount().first, greaterThan(orders.length));
    expect(ctx.settings.store.name, 'Essence');
    expect(ctx.billConfig.taxes.single.cashBp, 1500);
    expect(ctx.billConfig.taxes.single.cardOnlineBp, 500);
  });

  test('checkout saves the order, numbers it and deducts stock with modifiers', () async {
    final products = {for (final p in await db.select(db.products).get()) p.id: p};
    final milkGroup = (await (db.select(db.modifierGroups)..where((g) => g.id.equals('milk'))).getSingle());
    final oat = milkGroup.options.firstWhere((o) => o.id == 'oat');
    final before = await db.stockLevels();

    final cart = CartState(lines: [
      lineFor(products['latte']!, size: 'L', mods: [SelectedModifier(groupId: 'milk', groupName: 'Milk', option: oat)]),
      lineFor(products['croissant']!, qty: 2),
    ]);
    final order = await pos.checkout(
      cart: cart,
      portions: const [PaymentPortionInput(methodId: 'cash', methodName: 'Cash', group: RateGroup.cash)],
      tenderedByPortion: const {0: 300000},
      staff: await cashier(),
      shift: null,
    );
    expect(order.status, OrderStatus.paid);
    expect(order.number, startsWith('ESS-T1-'));
    expect(order.fiscalStatus, 'pending');
    // Large latte 650+150 + oat 150 = 950; 2 croissants 1100 → 2050 + 15% GST 307.5→308 + Re 1 fee
    expect(order.itemsGross, 205000);
    expect(order.taxTotal, 30800);
    expect(order.total, 205000 + 30800 + 100);
    expect(order.payments.single.change, 300000 - order.total);

    final after = await db.stockLevels();
    // Latte recipe has 18 g beans scaled ×1.3 for Large; oat milk replaces fresh milk (220 ml × 1.3).
    expect(before['beans']! - after['beans']!, closeTo(18 * 1.3, 0.001));
    expect(before['oat']! - after['oat']!, closeTo(220 * 1.3, 0.001));
    expect(after['milk'], before['milk']);
    expect(before['dough']! - after['dough']!, 2);
  });

  test('refund returns stock and marks the order; void restores everything', () async {
    final products = {for (final p in await db.select(db.products).get()) p.id: p};
    final staff = await cashier();
    final order = await pos.checkout(
      cart: CartState(lines: [lineFor(products['croissant']!, qty: 2), lineFor(products['americano']!, size: 'M')]),
      portions: const [PaymentPortionInput(methodId: 'card', methodName: 'Card', group: RateGroup.cardOnline)],
      tenderedByPortion: const {},
      staff: staff,
      shift: null,
    );
    final dough = (await db.stockLevels())['dough']!;
    final card = await (db.select(db.paymentMethods)..where((m) => m.id.equals('card'))).getSingle();
    final croissantKey = order.lines.first.key;
    final r = await pos.refund(order,
        qtyByKey: {croissantKey: 1}, method: card, reason: 'Test', restock: true, staff: staff);
    expect(r.amount, greaterThan(0));
    final refunded = await (db.select(db.orders)..where((o) => o.id.equals(order.id))).getSingle();
    expect(refunded.status, OrderStatus.partiallyRefunded);
    expect(refunded.refundedTotal, r.amount);
    expect((await db.stockLevels())['dough'], dough + 1);

    final second = await pos.checkout(
      cart: CartState(lines: [lineFor(products['croissant']!)]),
      portions: const [PaymentPortionInput(methodId: 'cash', methodName: 'Cash', group: RateGroup.cash)],
      tenderedByPortion: const {},
      staff: staff,
      shift: null,
    );
    final d2 = (await db.stockLevels())['dough']!;
    await pos.voidOrder(second, reason: 'Mistake', staff: staff);
    expect((await db.stockLevels())['dough'], d2 + 1);
  });

  test('hold, recall and pay keeps one order', () async {
    final products = {for (final p in await db.select(db.products).get()) p.id: p};
    final staff = await cashier();
    final held = await pos.hold(CartState(lines: [lineFor(products['karak']!)], type: OrderType.dineIn, tableId: 't3', tableLabel: '3'), staff: staff);
    expect(held.number, isNull);
    expect(await pos.watchHeld().first, hasLength(1));
    final cart = CartState.fromOrder(held);
    final paid = await pos.checkout(
      cart: cart,
      portions: const [PaymentPortionInput(methodId: 'cash', methodName: 'Cash', group: RateGroup.cash)],
      tenderedByPortion: const {},
      staff: staff,
      shift: null,
    );
    expect(paid.id, held.id);
    expect(paid.token, held.token);
    expect(await pos.watchHeld().first, isEmpty);
  });

  test('shift summary: expected cash includes float, cash sales and paid-outs', () async {
    final staff = await cashier();
    // Close the seeded open shift first.
    final shiftService = ShiftService(db, ctx, PrinterService(db));
    final open = await shiftService.openShift();
    if (open != null) await shiftService.close(open, countedCash: 0, staff: staff);
    final shift = await shiftService.open(openingFloat: 500000, staff: staff);
    final products = {for (final p in await db.select(db.products).get()) p.id: p};
    final o = await pos.checkout(
      cart: CartState(lines: [lineFor(products['karak']!)]),
      portions: const [PaymentPortionInput(methodId: 'cash', methodName: 'Cash', group: RateGroup.cash)],
      tenderedByPortion: const {},
      staff: staff,
      shift: shift,
    );
    await shiftService.cashMove(shift, isIn: false, amount: 20000, reason: 'Ice', staff: staff);
    final sm = await shiftService.summary(shift);
    expect(sm.expectedCash, 500000 + o.total - 20000);
    final closed = await shiftService.close(shift, countedCash: sm.expectedCash, staff: staff);
    expect(closed.status, 'closed');
  });

  test('reports aggregate history', () async {
    final orders = await db.select(db.orders).get();
    final refunds = await db.select(db.refunds).get();
    final r = SalesReport(orders, refunds);
    expect(r.orderCount, greaterThan(800));
    expect(r.collected, greaterThan(0));
    expect(r.byMethod.keys, contains('Cash'));
    expect(r.topItems(5), hasLength(5));
    expect(r.toCsv().split('\n').length, greaterThan(800));
  });

  test('sync: terminal 1 pushes, terminal 2 pulls; no duplicates on retry', timeout: const Timeout(Duration(minutes: 3)), () async {
    final remote = FakeRemote();
    final net = StreamController<bool>.broadcast();
    final engine1 = SyncEngine(db, remote, networkStream: net.stream);
    await engine1.start();
    net.add(true);
    for (var i = 0; i < 40 && (await db.watchOutboxCount().first) > 0; i++) {
      await engine1.pump();
      await settle();
    }
    expect(await db.watchOutboxCount().first, 0);
    final localOrders = await db.select(db.orders).get();
    expect(remote.docs['orders']!.length, localOrders.length);
    // Firestore form: JSON columns become real lists without the suffix.
    final anyOrder = remote.docs['orders']!.values.first;
    expect(anyOrder['lines'], isA<List<dynamic>>());
    expect(anyOrder.containsKey('linesJson'), isFalse);

    final db2 = AppDatabase(NativeDatabase.memory());
    final net2 = StreamController<bool>.broadcast();
    final engine2 = SyncEngine(db2, remote, networkStream: net2.stream);
    await engine2.start();
    net2.add(true);
    await settle();
    await settle();
    expect((await db2.select(db2.orders).get()).length, localOrders.length);
    expect((await db2.select(db2.products).get()).length, (await db.select(db.products).get()).length);
    expect(await db2.watchOutboxCount().first, 0, reason: 'pulled rows must not be re-queued');

    // A sale on terminal 1 reaches terminal 2 live.
    final products = {for (final p in await db.select(db.products).get()) p.id: p};
    final o = await pos.checkout(
      cart: CartState(lines: [lineFor(products['espresso']!, size: 'M')]),
      portions: const [PaymentPortionInput(methodId: 'cash', methodName: 'Cash', group: RateGroup.cash)],
      tenderedByPortion: const {},
      staff: await cashier(),
      shift: null,
    );
    await settle();
    await engine1.pump();
    await settle();
    final mirrored = await (db2.select(db2.orders)..where((x) => x.id.equals(o.id))).getSingleOrNull();
    expect(mirrored, isNotNull);
    expect(mirrored!.total, o.total);
    expect(mirrored.lines.single.name, 'Espresso');
    expect((await db2.stockLevels())['beans'], closeTo((await db.stockLevels())['beans']!, 0.001));

    // Re-sending the same writes doesn't duplicate.
    final count = remote.docs['orders']!.length;
    await remote.writeBatch([RemoteWrite('orders', o.id, {'id': o.id, 'updatedAt': o.updatedAt})]);
    expect(remote.docs['orders']!.length, count);

    await engine1.dispose();
    await engine2.dispose();
    await db2.close();
  });
}
