import 'dart:convert';

import '../db/database.dart';

List<Map<String, dynamic>> decodeList(String? s) {
  if (s == null || s.isEmpty) return const [];
  final v = jsonDecode(s);
  return v is List ? v.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList() : const [];
}

Map<String, dynamic> decodeMap(String? s) {
  if (s == null || s.isEmpty) return {};
  final v = jsonDecode(s);
  return v is Map ? Map<String, dynamic>.from(v) : {};
}

int _int(Object? v, [int d = 0]) => (v as num?)?.toInt() ?? d;
double _dbl(Object? v, [double d = 0]) => (v as num?)?.toDouble() ?? d;

class ProductSize {
  const ProductSize({required this.code, required this.label, this.delta = 0});
  final String code;
  final String label;

  /// Price difference from the product's base price (paisa).
  final int delta;

  Map<String, dynamic> toJson() => {'code': code, 'label': label, 'delta': delta};
  static ProductSize fromJson(Map j) => ProductSize(code: j['code'] as String, label: j['label'] as String? ?? j['code'] as String, delta: _int(j['delta']));
}

class ModifierOption {
  const ModifierOption({
    required this.id,
    required this.name,
    this.delta = 0,
    this.stockItemId,
    this.qty = 0,
    this.replacesStockItemId,
  });
  final String id;
  final String name;
  final int delta;

  /// Inventory: this option uses [qty] of [stockItemId] (base units)…
  final String? stockItemId;
  final double qty;

  /// …instead of the recipe's [replacesStockItemId] (e.g. oat milk replaces milk).
  final String? replacesStockItemId;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'delta': delta,
        if (stockItemId != null) 'stockItemId': stockItemId,
        if (qty != 0) 'qty': qty,
        if (replacesStockItemId != null) 'replacesStockItemId': replacesStockItemId,
      };
  static ModifierOption fromJson(Map j) => ModifierOption(
        id: j['id'] as String,
        name: j['name'] as String,
        delta: _int(j['delta']),
        stockItemId: j['stockItemId'] as String?,
        qty: _dbl(j['qty']),
        replacesStockItemId: j['replacesStockItemId'] as String?,
      );
}

class RecipeItem {
  const RecipeItem({required this.stockItemId, required this.qty});
  final String stockItemId;
  final double qty;
  Map<String, dynamic> toJson() => {'stockItemId': stockItemId, 'qty': qty};
  static RecipeItem fromJson(Map j) => RecipeItem(stockItemId: j['stockItemId'] as String, qty: _dbl(j['qty']));
}

extension ProductX on Product {
  List<ProductSize> get sizes => decodeList(sizesJson).map(ProductSize.fromJson).toList();
  List<String> get modifierGroupIds => (jsonDecode(modifierGroupIdsJson) as List).cast<String>();
  bool get hasOptions => sizes.length > 1 || modifierGroupIds.isNotEmpty;
}

extension ModifierGroupX on ModifierGroup {
  List<ModifierOption> get options => decodeList(optionsJson).map(ModifierOption.fromJson).toList();
}

extension RecipeX on Recipe {
  List<RecipeItem> get items => decodeList(itemsJson).map(RecipeItem.fromJson).toList();
}

extension StockItemX on StockItem {
  /// Purchase/display unit for the base unit.
  String get bigUnit => switch (unit) { 'g' => 'kg', 'ml' => 'L', _ => 'pcs' };
  double get perBig => unit == 'pcs' ? 1 : 1000;

  /// Cost in paisa of [qty] base units.
  double costOf(double qty) => qty / perBig * costPerUnit;

  String fmt(double qty) => formatQty(qty, unit);
}

/// 18 → "18 g", 1250 → "1.25 kg", 3 → "3 pcs".
String formatQty(double qty, String unit) {
  final neg = qty < 0;
  final q = qty.abs();
  String out;
  if (unit == 'pcs') {
    out = '${q == q.roundToDouble() ? q.toInt() : q.toStringAsFixed(1)} pcs';
  } else if (q >= 1000) {
    final big = unit == 'g' ? 'kg' : 'L';
    out = '${_trim((q / 1000).toStringAsFixed(2))} $big';
  } else {
    out = '${_trim(q.toStringAsFixed(q < 10 ? 1 : 0))} $unit';
  }
  return neg ? '−$out' : out;
}

String _trim(String s) => s.contains('.') ? s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '') : s;
