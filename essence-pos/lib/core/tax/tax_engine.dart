import '../money.dart';

/// Every payment method belongs to one of these groups; each tax has a rate per group.
enum RateGroup {
  cash('Cash'),
  cardOnline('Card / Online');

  const RateGroup(this.label);
  final String label;

  static RateGroup parse(String? v) => v == 'cardOnline' ? RateGroup.cardOnline : RateGroup.cash;
}

/// A tax that is currently enabled (GST and any "other" taxes).
class TaxRule {
  const TaxRule({required this.id, required this.name, required this.cashBp, required this.cardOnlineBp});
  final String id;
  final String name;

  /// Rates in basis points: 1500 = 15%.
  final int cashBp;
  final int cardOnlineBp;

  int bp(RateGroup g) => g == RateGroup.cash ? cashBp : cardOnlineBp;
}

enum DiscountKind { percent, amount }

class Discount {
  const Discount.percent(int basisPoints, {this.label})
      : kind = DiscountKind.percent,
        value = basisPoints;
  const Discount.amount(Paisa paisa, {this.label})
      : kind = DiscountKind.amount,
        value = paisa;
  const Discount({required this.kind, required this.value, this.label});

  final DiscountKind kind;

  /// Basis points for percent, paisa for amount.
  final int value;
  final String? label;

  Paisa apply(Paisa base) {
    if (base <= 0 || value <= 0) return 0;
    final d = kind == DiscountKind.percent ? (base * value / 10000).round() : value;
    return d > base ? base : d;
  }

  String get display => kind == DiscountKind.percent ? pct(value) : rs(value);

  Map<String, dynamic> toJson() => {'kind': kind.name, 'value': value, if (label != null) 'label': label};
  static Discount? fromJson(Object? j) {
    if (j is! Map) return null;
    return Discount(
      kind: j['kind'] == 'amount' ? DiscountKind.amount : DiscountKind.percent,
      value: (j['value'] as num?)?.toInt() ?? 0,
      label: j['label'] as String?,
    );
  }
}

class BillLine {
  const BillLine({required this.key, required this.unitPrice, required this.qty, this.discount, this.taxExempt = false});
  final String key;

  /// Price of one unit including size and modifier deltas.
  final Paisa unitPrice;
  final int qty;
  final Discount? discount;
  final bool taxExempt;
}

enum ChargeType { service, delivery }

enum ChargeMode { percent, fixed }

/// A charge that applies to this order (already filtered by order type by the caller).
class ChargeRule {
  const ChargeRule({required this.type, required this.label, required this.mode, required this.value, this.taxable = false});
  final ChargeType type;
  final String label;
  final ChargeMode mode;

  /// Basis points for percent, paisa for fixed.
  final int value;
  final bool taxable;
}

class BillConfig {
  const BillConfig({
    this.taxes = const [],
    this.pricesIncludeTax = false,
    this.fbrFee = 0,
    this.cashRoundingRupees = 0,
  });

  /// Enabled taxes only.
  final List<TaxRule> taxes;
  final bool pricesIncludeTax;

  /// FBR POS service fee per invoice (paisa); 0 when disabled. Never taxed.
  final Paisa fbrFee;

  /// Round the final cash portion to this many rupees (0 = no rounding).
  final int cashRoundingRupees;

  int totalBp(RateGroup g) => taxes.fold(0, (a, t) => a + t.bp(g));
}

/// How the customer is paying. The last portion with a null [amount] pays the remainder.
class PaymentPortionInput {
  const PaymentPortionInput({required this.methodId, required this.methodName, required this.group, this.amount});
  final String methodId;
  final String methodName;
  final RateGroup group;

  /// Amount this method pays (including its tax). Null = pays whatever remains.
  final Paisa? amount;
}

class LineResult {
  const LineResult(this.key, this.gross, this.lineDiscount, this.orderDiscountShare, this.taxExempt);
  final String key;
  final Paisa gross;
  final Paisa lineDiscount;
  final Paisa orderDiscountShare;
  final bool taxExempt;
  Paisa get net => gross - lineDiscount - orderDiscountShare;
}

class ChargeResult {
  const ChargeResult(this.type, this.label, this.amount, this.taxable);
  final ChargeType type;
  final String label;
  final Paisa amount;
  final bool taxable;
}

class TaxAmount {
  const TaxAmount({required this.taxId, required this.name, required this.rateBp, required this.amount});
  final String taxId;
  final String name;
  final int rateBp;
  final Paisa amount;
}

class PortionResult {
  const PortionResult({
    required this.methodId,
    required this.methodName,
    required this.group,
    required this.amount,
    required this.taxableBase,
    required this.exemptBase,
    required this.taxes,
    required this.fbrFee,
    required this.rounding,
  });
  final String methodId;
  final String methodName;
  final RateGroup group;

  /// What this method pays, including tax, fee and rounding.
  final Paisa amount;

  /// The taxable value this portion covers (pre-tax in exclusive mode, tax-inclusive in inclusive mode).
  final Paisa taxableBase;
  final Paisa exemptBase;
  final List<TaxAmount> taxes;
  final Paisa fbrFee;
  final Paisa rounding;

  Paisa get taxTotal => taxes.fold(0, (a, t) => a + t.amount);
}

/// Aggregated tax line for receipts, reports and FBR: one per tax per rate group used.
class TaxLine {
  const TaxLine({required this.taxId, required this.name, required this.rateBp, required this.group, required this.amount});
  final String taxId;
  final String name;
  final int rateBp;
  final RateGroup group;
  final Paisa amount;

  Map<String, dynamic> toJson() => {'taxId': taxId, 'name': name, 'rateBp': rateBp, 'group': group.name, 'amount': amount};
  static TaxLine fromJson(Map j) => TaxLine(
        taxId: j['taxId'] as String? ?? '',
        name: j['name'] as String? ?? 'Tax',
        rateBp: (j['rateBp'] as num?)?.toInt() ?? 0,
        group: RateGroup.parse(j['group'] as String?),
        amount: (j['amount'] as num?)?.toInt() ?? 0,
      );
}

class BillResult {
  const BillResult({
    required this.pricesIncludeTax,
    required this.lines,
    required this.charges,
    required this.portions,
    required this.taxLines,
  });

  final bool pricesIncludeTax;
  final List<LineResult> lines;
  final List<ChargeResult> charges;
  final List<PortionResult> portions;
  final List<TaxLine> taxLines;

  Paisa get itemsGross => lines.fold(0, (a, l) => a + l.gross);
  Paisa get lineDiscounts => lines.fold(0, (a, l) => a + l.lineDiscount);
  Paisa get orderDiscount => lines.fold(0, (a, l) => a + l.orderDiscountShare);
  Paisa get discountTotal => lineDiscounts + orderDiscount;
  Paisa get itemsNet => itemsGross - discountTotal;
  Paisa get chargesTotal => charges.fold(0, (a, c) => a + c.amount);
  Paisa get taxTotal => portions.fold(0, (a, p) => a + p.taxTotal);
  Paisa get fbrFee => portions.fold(0, (a, p) => a + p.fbrFee);
  Paisa get rounding => portions.fold(0, (a, p) => a + p.rounding);
  Paisa get total => portions.fold(0, (a, p) => a + p.amount);

  /// Value of the sale excluding tax, fee and rounding.
  Paisa get netExTax => total - taxTotal - fbrFee - rounding;

  bool get isEmpty => lines.isEmpty;
}

/// Pure, deterministic bill calculation. Taxes are rounded to whole rupees.
///
/// Exclusive mode: prices are before tax; tax is added on top at the paying method's rate.
/// Inclusive mode: prices contain tax; the total equals the prices and the tax inside it is
/// extracted at the paying method's rate: tax = taxable × rate ÷ (100% + rate).
/// Split payments: each portion is taxed at its own group's rate; the FBR fee and cash rounding
/// go on the final portion.
BillResult computeBill({
  required List<BillLine> lines,
  Discount? orderDiscount,
  List<ChargeRule> charges = const [],
  required BillConfig config,
  required List<PaymentPortionInput> portions,
}) {
  // 1. Lines and discounts.
  final gross = [for (final l in lines) l.unitPrice * l.qty];
  final lineDisc = [for (var i = 0; i < lines.length; i++) lines[i].discount?.apply(gross[i]) ?? 0];
  final afterLine = [for (var i = 0; i < lines.length; i++) gross[i] - lineDisc[i]];
  final afterLineTotal = afterLine.fold<int>(0, (a, b) => a + b);
  final orderDisc = orderDiscount?.apply(afterLineTotal) ?? 0;
  final shares = _distribute(orderDisc, afterLine);
  final lineResults = [
    for (var i = 0; i < lines.length; i++) LineResult(lines[i].key, gross[i], lineDisc[i], shares[i], lines[i].taxExempt),
  ];
  final itemsNet = afterLineTotal - orderDisc;

  // 2. Charges, computed on discounted items.
  final chargeResults = <ChargeResult>[];
  if (lines.isNotEmpty) {
    for (final c in charges) {
      final amt = c.mode == ChargeMode.percent ? (itemsNet * c.value / 10000).round() : c.value;
      if (amt > 0) chargeResults.add(ChargeResult(c.type, c.label, amt, c.taxable));
    }
  }

  var tRem = lineResults.where((l) => !l.taxExempt).fold<int>(0, (a, l) => a + l.net) +
      chargeResults.where((c) => c.taxable).fold<int>(0, (a, c) => a + c.amount);
  var eRem = lineResults.where((l) => l.taxExempt).fold<int>(0, (a, l) => a + l.net) +
      chargeResults.where((c) => !c.taxable).fold<int>(0, (a, c) => a + c.amount);

  if (lines.isEmpty || portions.isEmpty) {
    return BillResult(
      pricesIncludeTax: config.pricesIncludeTax,
      lines: lineResults,
      charges: chargeResults,
      portions: const [],
      taxLines: const [],
    );
  }

  List<TaxAmount> taxesOn(Paisa taxable, RateGroup g) {
    final totalBp = config.totalBp(g);
    return [
      for (final t in config.taxes)
        if (t.bp(g) > 0)
          TaxAmount(
            taxId: t.id,
            name: t.name,
            rateBp: t.bp(g),
            amount: config.pricesIncludeTax
                ? roundToRupee(taxable * t.bp(g) / (10000 + totalBp))
                : roundToRupee(taxable * t.bp(g) / 10000),
          ),
    ];
  }

  Paisa sumTax(List<TaxAmount> l) => l.fold(0, (a, t) => a + t.amount);

  PortionResult finalPortion(PaymentPortionInput p) {
    final taxes = taxesOn(tRem, p.group);
    var amount = tRem + eRem + (config.pricesIncludeTax ? 0 : sumTax(taxes)) + config.fbrFee;
    var rounding = 0;
    if (p.group == RateGroup.cash && config.cashRoundingRupees > 0) {
      final r = roundToStep(amount, config.cashRoundingRupees);
      rounding = r - amount;
      amount = r;
    }
    final res = PortionResult(
      methodId: p.methodId,
      methodName: p.methodName,
      group: p.group,
      amount: amount,
      taxableBase: tRem,
      exemptBase: eRem,
      taxes: taxes,
      fbrFee: config.fbrFee,
      rounding: rounding,
    );
    tRem = 0;
    eRem = 0;
    return res;
  }

  // 3. Payment portions.
  final results = <PortionResult>[];
  for (var i = 0; i < portions.length; i++) {
    final p = portions[i];
    final isLast = i == portions.length - 1;
    if (tRem + eRem <= 0 && results.isNotEmpty) break;

    final fullTaxes = taxesOn(tRem, p.group);
    final fullAmount = tRem + eRem + (config.pricesIncludeTax ? 0 : sumTax(fullTaxes)) + config.fbrFee;
    final a = p.amount;
    if (isLast || a == null || a >= fullAmount) {
      results.add(finalPortion(p));
      break;
    }
    if (a <= 0) continue;

    final remaining = tRem + eRem;
    final f = remaining == 0 ? 0.0 : tRem / remaining;
    Paisa t;
    Paisa e;
    List<TaxAmount> taxes;
    if (config.pricesIncludeTax) {
      t = (tRem * (a / remaining)).round();
      if (t > tRem) t = tRem;
      e = a - t;
      if (e > eRem) {
        e = eRem;
        t = a - e;
      }
      taxes = taxesOn(t, p.group);
    } else {
      final rate = config.totalBp(p.group) / 10000;
      final n = a / (1 + f * rate);
      final taxableEstimate = n * f;
      taxes = [
        for (final tr in config.taxes)
          if (tr.bp(p.group) > 0)
            TaxAmount(taxId: tr.id, name: tr.name, rateBp: tr.bp(p.group), amount: roundToRupee(taxableEstimate * tr.bp(p.group) / 10000)),
      ];
      final net = a - sumTax(taxes);
      t = (net * f).round();
      if (t > tRem) t = tRem;
      e = net - t;
      if (e > eRem) {
        e = eRem;
        t = net - e;
      }
    }
    tRem -= t;
    eRem -= e;
    results.add(PortionResult(
      methodId: p.methodId,
      methodName: p.methodName,
      group: p.group,
      amount: a,
      taxableBase: t,
      exemptBase: e,
      taxes: taxes,
      fbrFee: 0,
      rounding: 0,
    ));
  }

  // 4. Aggregate tax lines per tax + group.
  final agg = <String, TaxLine>{};
  for (final p in results) {
    for (final t in p.taxes) {
      final k = '${t.taxId}|${p.group.name}';
      final prev = agg[k];
      agg[k] = TaxLine(
        taxId: t.taxId,
        name: t.name,
        rateBp: t.rateBp,
        group: p.group,
        amount: (prev?.amount ?? 0) + t.amount,
      );
    }
  }

  return BillResult(
    pricesIncludeTax: config.pricesIncludeTax,
    lines: lineResults,
    charges: chargeResults,
    portions: results,
    taxLines: agg.values.where((t) => t.amount != 0).toList(),
  );
}

/// Convenience: the total if the whole bill were paid by a single method of [group].
Paisa totalIfPaidWith({
  required List<BillLine> lines,
  Discount? orderDiscount,
  List<ChargeRule> charges = const [],
  required BillConfig config,
  required RateGroup group,
}) =>
    computeBill(
      lines: lines,
      orderDiscount: orderDiscount,
      charges: charges,
      config: config,
      portions: [PaymentPortionInput(methodId: group.name, methodName: group.label, group: group)],
    ).total;

/// Splits [amount] across [weights] proportionally (largest remainder), so the parts sum exactly.
List<int> _distribute(int amount, List<int> weights) {
  final total = weights.fold<int>(0, (a, b) => a + b);
  if (amount <= 0 || total <= 0) return List.filled(weights.length, 0);
  final raw = [for (final w in weights) amount * w / total];
  final floors = [for (final r in raw) r.floor()];
  var left = amount - floors.fold<int>(0, (a, b) => a + b);
  final order = List.generate(weights.length, (i) => i)..sort((a, b) => (raw[b] - floors[b]).compareTo(raw[a] - floors[a]));
  for (final i in order) {
    if (left <= 0) break;
    floors[i]++;
    left--;
  }
  return floors;
}
