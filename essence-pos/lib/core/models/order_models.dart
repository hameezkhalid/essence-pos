import 'dart:convert';

import '../db/database.dart';
import '../tax/tax_engine.dart';
import 'menu_models.dart';

enum OrderType {
  dineIn('Dine-in', 'dineIn'),
  takeaway('Takeaway', 'takeaway'),
  delivery('Delivery', 'delivery');

  const OrderType(this.label, this.key);
  final String label;
  final String key;

  static OrderType parse(String? v) => OrderType.values.firstWhere((t) => t.key == v, orElse: () => OrderType.takeaway);
}

class OrderStatus {
  static const held = 'held';
  static const paid = 'paid';
  static const voided = 'voided';
  static const refunded = 'refunded';
  static const partiallyRefunded = 'partiallyRefunded';

  static String label(String s) => switch (s) {
        held => 'Held',
        paid => 'Paid',
        voided => 'Voided',
        refunded => 'Refunded',
        partiallyRefunded => 'Part refunded',
        _ => s,
      };

  /// Statuses that count as sales.
  static const sales = [paid, refunded, partiallyRefunded];
}

class SelectedModifier {
  const SelectedModifier({required this.groupId, required this.groupName, required this.option});
  final String groupId;
  final String groupName;
  final ModifierOption option;

  Map<String, dynamic> toJson() => {'groupId': groupId, 'groupName': groupName, 'option': option.toJson()};
  static SelectedModifier fromJson(Map j) => SelectedModifier(
        groupId: j['groupId'] as String,
        groupName: j['groupName'] as String? ?? '',
        option: ModifierOption.fromJson(j['option'] as Map),
      );
}

/// One line on an order (also used as the cart line).
class OrderLine {
  const OrderLine({
    required this.key,
    required this.productId,
    required this.categoryId,
    required this.name,
    required this.basePrice,
    this.size,
    this.modifiers = const [],
    this.qty = 1,
    this.note,
    this.discount,
    this.taxExempt = false,
    this.net = 0,
    this.sentQty = 0,
    this.refundedQty = 0,
  });

  final String key;
  final String productId;
  final String categoryId;
  final String name;
  final int basePrice;
  final ProductSize? size;
  final List<SelectedModifier> modifiers;
  final int qty;
  final String? note;
  final Discount? discount;
  final bool taxExempt;

  /// Line value after all discounts (filled when the order is saved).
  final int net;

  /// Quantity already sent to the bar on a KOT.
  final int sentQty;
  final int refundedQty;

  int get unitPrice => basePrice + (size?.delta ?? 0) + modifiers.fold<int>(0, (a, m) => a + m.option.delta);
  int get gross => unitPrice * qty;

  String get title => size == null ? name : '$name (${size!.label})';
  String get optionsText => modifiers.map((m) => m.option.name).join(', ');

  /// Identity for merging identical cart lines.
  String get signature => '$productId|${size?.code ?? ''}|${modifiers.map((m) => m.option.id).join(',')}|${note ?? ''}';

  OrderLine copyWith({
    int? qty,
    ProductSize? size,
    List<SelectedModifier>? modifiers,
    String? note,
    bool clearNote = false,
    Discount? discount,
    bool clearDiscount = false,
    int? net,
    int? sentQty,
    int? refundedQty,
  }) =>
      OrderLine(
        key: key,
        productId: productId,
        categoryId: categoryId,
        name: name,
        basePrice: basePrice,
        size: size ?? this.size,
        modifiers: modifiers ?? this.modifiers,
        qty: qty ?? this.qty,
        note: clearNote ? null : (note ?? this.note),
        discount: clearDiscount ? null : (discount ?? this.discount),
        taxExempt: taxExempt,
        net: net ?? this.net,
        sentQty: sentQty ?? this.sentQty,
        refundedQty: refundedQty ?? this.refundedQty,
      );

  BillLine toBillLine() => BillLine(key: key, unitPrice: unitPrice, qty: qty, discount: discount, taxExempt: taxExempt);

  Map<String, dynamic> toJson() => {
        'key': key,
        'productId': productId,
        'categoryId': categoryId,
        'name': name,
        'basePrice': basePrice,
        'unitPrice': unitPrice,
        if (size != null) 'size': size!.toJson(),
        'modifiers': modifiers.map((m) => m.toJson()).toList(),
        'qty': qty,
        if (note != null) 'note': note,
        if (discount != null) 'discount': discount!.toJson(),
        'taxExempt': taxExempt,
        'net': net,
        'sentQty': sentQty,
        'refundedQty': refundedQty,
      };

  static OrderLine fromJson(Map j) => OrderLine(
        key: j['key'] as String,
        productId: j['productId'] as String,
        categoryId: j['categoryId'] as String? ?? '',
        name: j['name'] as String,
        basePrice: (j['basePrice'] as num).toInt(),
        size: j['size'] is Map ? ProductSize.fromJson(j['size'] as Map) : null,
        modifiers: (j['modifiers'] as List? ?? const []).whereType<Map>().map(SelectedModifier.fromJson).toList(),
        qty: (j['qty'] as num).toInt(),
        note: j['note'] as String?,
        discount: Discount.fromJson(j['discount']),
        taxExempt: j['taxExempt'] as bool? ?? false,
        net: (j['net'] as num?)?.toInt() ?? 0,
        sentQty: (j['sentQty'] as num?)?.toInt() ?? 0,
        refundedQty: (j['refundedQty'] as num?)?.toInt() ?? 0,
      );
}

/// A payment recorded on an order.
class PaymentRecord {
  const PaymentRecord({
    required this.methodId,
    required this.methodName,
    required this.group,
    required this.amount,
    this.tendered,
    this.change = 0,
    this.taxes = const [],
  });
  final String methodId;
  final String methodName;
  final RateGroup group;
  final int amount;
  final int? tendered;
  final int change;
  final List<TaxAmount> taxes;

  Map<String, dynamic> toJson() => {
        'methodId': methodId,
        'methodName': methodName,
        'group': group.name,
        'amount': amount,
        if (tendered != null) 'tendered': tendered,
        'change': change,
        'taxes': [for (final t in taxes) {'taxId': t.taxId, 'name': t.name, 'rateBp': t.rateBp, 'amount': t.amount}],
      };

  static PaymentRecord fromJson(Map j) => PaymentRecord(
        methodId: j['methodId'] as String,
        methodName: j['methodName'] as String? ?? '',
        group: RateGroup.parse(j['group'] as String?),
        amount: (j['amount'] as num).toInt(),
        tendered: (j['tendered'] as num?)?.toInt(),
        change: (j['change'] as num?)?.toInt() ?? 0,
        taxes: [
          for (final t in (j['taxes'] as List? ?? const []).whereType<Map>())
            TaxAmount(
              taxId: t['taxId'] as String? ?? '',
              name: t['name'] as String? ?? '',
              rateBp: (t['rateBp'] as num?)?.toInt() ?? 0,
              amount: (t['amount'] as num?)?.toInt() ?? 0,
            ),
        ],
      );
}

class ChargeRecord {
  const ChargeRecord({required this.type, required this.label, required this.amount, required this.taxable});
  final String type;
  final String label;
  final int amount;
  final bool taxable;
  Map<String, dynamic> toJson() => {'type': type, 'label': label, 'amount': amount, 'taxable': taxable};
  static ChargeRecord fromJson(Map j) => ChargeRecord(
        type: j['type'] as String? ?? '',
        label: j['label'] as String? ?? '',
        amount: (j['amount'] as num?)?.toInt() ?? 0,
        taxable: j['taxable'] as bool? ?? false,
      );
}

extension OrderX on Order {
  List<OrderLine> get lines => decodeList(linesJson).map(OrderLine.fromJson).toList();
  List<PaymentRecord> get payments => decodeList(paymentsJson).map(PaymentRecord.fromJson).toList();
  List<TaxLine> get taxLines => decodeList(taxLinesJson).map(TaxLine.fromJson).toList();
  List<ChargeRecord> get charges => decodeList(chargesJson).map(ChargeRecord.fromJson).toList();
  Discount? get orderDiscount => orderDiscountJson == null ? null : Discount.fromJson(jsonDecode(orderDiscountJson!));
  OrderType get type => OrderType.parse(orderType);
  bool get isSale => OrderStatus.sales.contains(status);
  int get itemCount => lines.fold(0, (a, l) => a + l.qty);
  String get tokenLabel => token == null ? '' : '#${token.toString().padLeft(3, '0')}';
  String get displayNumber => number ?? 'Held';
  DateTime get created => DateTime.fromMillisecondsSinceEpoch(createdAt);

  /// Sales value after refunds.
  int get netSales => total - refundedTotal;
}
