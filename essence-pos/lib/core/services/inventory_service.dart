import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';

import '../db/database.dart';
import '../models/menu_models.dart';
import '../models/order_models.dart';
import 'repos.dart';

enum StockState { ok, low, critical, out }

class StockView {
  const StockView(this.item, this.qty);
  final StockItem item;
  final double qty;

  StockState get state {
    if (qty <= 0) return StockState.out;
    if (qty <= item.reorderLevel * 0.5) return StockState.critical;
    if (qty <= item.reorderLevel) return StockState.low;
    return StockState.ok;
  }

  bool get needsReorder => state != StockState.ok;
  double get value => item.costOf(qty < 0 ? 0 : qty);

  /// Suggested purchase to get back to par.
  double get suggestedOrder => (item.parLevel - qty).clamp(0, double.infinity);

  /// 0..1 fill against par level for level bars.
  double get fill => item.parLevel <= 0 ? 1 : (qty / item.parLevel).clamp(0, 1);
}

class LowStockAlert {
  const LowStockAlert(this.item, this.qty, this.state);
  final StockItem item;
  final double qty;
  final StockState state;
}

/// Size scale used when a product has one recipe for all sizes.
double sizeFactor(String? code) => switch (code) { 'S' => 0.8, 'L' => 1.3, _ => 1.0 };

class InventoryService {
  InventoryService(this.db);
  final AppDatabase db;

  final _alerts = StreamController<LowStockAlert>.broadcast();

  /// Fires when a sale takes an item to or below its reorder level.
  Stream<LowStockAlert> get alerts => _alerts.stream;

  Stream<List<StockItem>> watchItems({bool activeOnly = false}) => (db.select(db.stockItems)
        ..where((t) => t.deleted.equals(false) & (activeOnly ? t.active.equals(true) : const Constant(true)))
        ..orderBy([(t) => OrderingTerm.asc(t.groupName), (t) => OrderingTerm.asc(t.name)]))
      .watch();

  Stream<List<StockView>> watchStock() {
    late StreamController<List<StockView>> ctrl;
    List<StockItem>? items;
    Map<String, double>? levels;
    final subs = <StreamSubscription<dynamic>>[];
    void emit() {
      if (items == null || levels == null) return;
      ctrl.add([for (final i in items!) StockView(i, levels![i.id] ?? 0)]);
    }

    ctrl = StreamController<List<StockView>>(
      onListen: () {
        subs.add(watchItems().listen((v) {
          items = v;
          emit();
        }, onError: ctrl.addError));
        subs.add(db.watchStockLevels().listen((v) {
          levels = v;
          emit();
        }, onError: ctrl.addError));
      },
      onCancel: () async {
        for (final s in subs) {
          await s.cancel();
        }
      },
    );
    return ctrl.stream;
  }

  Stream<List<Recipe>> watchRecipes() => (db.select(db.recipes)..where((t) => t.deleted.equals(false))).watch();

  Stream<List<StockMovement>> watchMovements({String? stockItemId, int limit = 300}) => (db.select(db.stockMovements)
        ..where((t) => t.deleted.equals(false) & (stockItemId == null ? const Constant(true) : t.stockItemId.equals(stockItemId)))
        ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
        ..limit(limit))
      .watch();

  Future<void> saveItem(StockItem i) => db.saveSynced(db.stockItems, i.copyWith(updatedAt: nowMs()));
  Future<void> deleteItem(StockItem i) => db.saveSynced(db.stockItems, i.copyWith(deleted: true, updatedAt: nowMs()));

  static String recipeId(String productId, String sizeCode) => sizeCode.isEmpty ? productId : '${productId}_$sizeCode';

  Future<void> saveRecipe(String productId, String sizeCode, List<RecipeItem> items) => db.saveSynced(
        db.recipes,
        Recipe(
          id: recipeId(productId, sizeCode),
          updatedAt: nowMs(),
          deleted: false,
          productId: productId,
          sizeCode: sizeCode,
          itemsJson: jsonEncode(items.map((e) => e.toJson()).toList()),
        ),
      );

  /// Ingredients (base units) used by [qty] of a line, after size scaling and modifiers.
  static Map<String, double> usageForLine(OrderLine line, Map<String, Recipe> recipesById, int qty) {
    final sizeCode = line.size?.code ?? '';
    final exact = recipesById[recipeId(line.productId, sizeCode)];
    final base = recipesById[recipeId(line.productId, '')];
    final recipe = exact ?? base;
    final factor = exact != null ? 1.0 : sizeFactor(line.size?.code);
    final use = <String, double>{};
    if (recipe != null) {
      for (final it in recipe.items) {
        use[it.stockItemId] = (use[it.stockItemId] ?? 0) + it.qty * factor * qty;
      }
    }
    for (final m in line.modifiers) {
      final o = m.option;
      if (o.stockItemId == null) continue;
      if (o.replacesStockItemId != null && use.containsKey(o.replacesStockItemId)) {
        final replaced = use.remove(o.replacesStockItemId)!;
        final q = o.qty > 0 ? o.qty * qty : replaced;
        use[o.stockItemId!] = (use[o.stockItemId!] ?? 0) + q;
      } else if (o.qty > 0) {
        use[o.stockItemId!] = (use[o.stockItemId!] ?? 0) + o.qty * qty;
      }
    }
    return use;
  }

  Future<Map<String, Recipe>> _recipes() async =>
      {for (final r in await (db.select(db.recipes)..where((t) => t.deleted.equals(false))).get()) r.id: r};

  /// Deducts (or with [restore], returns) the ingredients of [lines] (qty per line from [qtyOf]).
  Future<void> applyLines(
    List<OrderLine> lines, {
    required String refId,
    required String type,
    required bool restore,
    int Function(OrderLine l)? qtyOf,
    StaffMember? staff,
    String? deviceId,
  }) async {
    final recipes = await _recipes();
    final totals = <String, double>{};
    for (final l in lines) {
      final q = qtyOf?.call(l) ?? l.qty;
      if (q <= 0) continue;
      usageForLine(l, recipes, q).forEach((k, v) => totals[k] = (totals[k] ?? 0) + v);
    }
    if (totals.isEmpty) return;
    final before = restore ? const <String, double>{} : await db.stockLevels();
    final now = nowMs();
    await db.saveAllSynced(db.stockMovements, [
      for (final e in totals.entries)
        StockMovement(
          id: newId(),
          updatedAt: now,
          deleted: false,
          stockItemId: e.key,
          qty: restore ? e.value : -e.value,
          type: type,
          refId: refId,
          staffId: staff?.id,
          staffName: staff?.name,
          deviceId: deviceId,
          createdAt: now,
        ),
    ]);
    if (restore) return;
    final items = {for (final i in await db.select(db.stockItems).get()) i.id: i};
    for (final e in totals.entries) {
      final item = items[e.key];
      if (item == null) continue;
      final was = StockView(item, before[e.key] ?? 0).state;
      final now = StockView(item, (before[e.key] ?? 0) - e.value);
      if (now.state != StockState.ok && now.state.index > was.index) {
        _alerts.add(LowStockAlert(item, now.qty, now.state));
      }
    }
  }

  Future<void> _move(StockItem item, double qty, String type, {String? note, int? unitCost, StaffMember? staff, String? deviceId}) {
    final now = nowMs();
    return db.saveSynced(
      db.stockMovements,
      StockMovement(
        id: newId(),
        updatedAt: now,
        deleted: false,
        stockItemId: item.id,
        qty: qty,
        type: type,
        note: note,
        unitCost: unitCost,
        staffId: staff?.id,
        staffName: staff?.name,
        deviceId: deviceId,
        createdAt: now,
      ),
    );
  }

  /// Receive a delivery. [qty] is in base units; [unitCost] is paisa per kg/L/pc (updates the item cost).
  Future<void> stockIn(StockItem item, double qty, {int? unitCost, String? note, StaffMember? staff, String? deviceId}) async {
    await _move(item, qty, 'stockIn', note: note, unitCost: unitCost, staff: staff, deviceId: deviceId);
    if (unitCost != null && unitCost > 0 && unitCost != item.costPerUnit) {
      await saveItem(item.copyWith(costPerUnit: unitCost));
    }
  }

  Future<void> wastage(StockItem item, double qty, {String? note, StaffMember? staff, String? deviceId}) =>
      _move(item, -qty.abs(), 'wastage', note: note, staff: staff, deviceId: deviceId);

  /// Stock count: records the difference so the level becomes [counted].
  Future<void> count(StockItem item, double counted, {StaffMember? staff, String? deviceId}) async {
    final cur = (await db.stockLevels())[item.id] ?? 0;
    final diff = counted - cur;
    if (diff.abs() < 0.0001) return;
    await _move(item, diff, 'count', note: 'Counted ${item.fmt(counted)} (was ${item.fmt(cur)})', staff: staff, deviceId: deviceId);
  }

  /// Ingredient cost of one unit of a product (paisa), or null without a recipe.
  static double? recipeCost(Product p, String sizeCode, Map<String, Recipe> recipes, Map<String, StockItem> items) {
    final exact = recipes[recipeId(p.id, sizeCode)];
    final base = recipes[recipeId(p.id, '')];
    final r = exact ?? base;
    if (r == null) return null;
    final f = exact != null ? 1.0 : sizeFactor(sizeCode.isEmpty ? null : sizeCode);
    var cost = 0.0;
    for (final it in r.items) {
      final si = items[it.stockItemId];
      if (si != null) cost += si.costOf(it.qty * f);
    }
    return cost;
  }

  void dispose() => _alerts.close();
}
