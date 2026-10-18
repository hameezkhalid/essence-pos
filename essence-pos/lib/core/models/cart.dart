import '../db/database.dart';
import '../tax/tax_engine.dart';
import 'order_models.dart';

/// The order being built on the sell screen.
class CartState {
  const CartState({
    this.lines = const [],
    this.type = OrderType.takeaway,
    this.tableId,
    this.tableLabel,
    this.guests,
    this.customerId,
    this.customerName,
    this.customerPhone,
    this.deliveryAddress,
    this.orderDiscount,
    this.discountApprovedBy,
    this.note,
    this.heldOrderId,
    this.token,
  });

  final List<OrderLine> lines;
  final OrderType type;
  final String? tableId;
  final String? tableLabel;
  final int? guests;
  final String? customerId;
  final String? customerName;
  final String? customerPhone;
  final String? deliveryAddress;
  final Discount? orderDiscount;

  /// Manager who approved a discount above the cashier limit.
  final String? discountApprovedBy;
  final String? note;

  /// Set when this cart was held or recalled (paying it completes that held order).
  final String? heldOrderId;
  final int? token;

  bool get isEmpty => lines.isEmpty;
  int get itemCount => lines.fold(0, (a, l) => a + l.qty);
  bool get hasCustomer => customerName != null && customerName!.isNotEmpty;
  bool get hasDiscount => orderDiscount != null || lines.any((l) => l.discount != null);
  bool get hasUnsentItems => lines.any((l) => l.qty > l.sentQty);

  List<BillLine> get billLines => [for (final l in lines) l.toBillLine()];

  CartState copyWith({
    List<OrderLine>? lines,
    OrderType? type,
    String? tableId,
    String? tableLabel,
    int? guests,
    bool clearTable = false,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? deliveryAddress,
    bool clearCustomer = false,
    Discount? orderDiscount,
    String? discountApprovedBy,
    bool clearDiscount = false,
    String? note,
    bool clearNote = false,
    String? heldOrderId,
    int? token,
  }) =>
      CartState(
        lines: lines ?? this.lines,
        type: type ?? this.type,
        tableId: clearTable ? null : (tableId ?? this.tableId),
        tableLabel: clearTable ? null : (tableLabel ?? this.tableLabel),
        guests: clearTable ? null : (guests ?? this.guests),
        customerId: clearCustomer ? null : (customerId ?? this.customerId),
        customerName: clearCustomer ? null : (customerName ?? this.customerName),
        customerPhone: clearCustomer ? null : (customerPhone ?? this.customerPhone),
        deliveryAddress: clearCustomer ? null : (deliveryAddress ?? this.deliveryAddress),
        orderDiscount: clearDiscount ? null : (orderDiscount ?? this.orderDiscount),
        discountApprovedBy: clearDiscount ? null : (discountApprovedBy ?? this.discountApprovedBy),
        note: clearNote ? null : (note ?? this.note),
        heldOrderId: heldOrderId ?? this.heldOrderId,
        token: token ?? this.token,
      );

  static CartState fromOrder(Order o) => CartState(
        lines: o.lines,
        type: o.type,
        tableId: o.tableId,
        tableLabel: o.tableLabel,
        guests: o.guests,
        customerId: o.customerId,
        customerName: o.customerName,
        customerPhone: o.customerPhone,
        deliveryAddress: o.deliveryAddress,
        orderDiscount: o.orderDiscount,
        note: o.note,
        heldOrderId: o.id,
        token: o.token,
      );
}
