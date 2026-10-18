import 'package:essence_pos/core/money.dart';
import 'package:essence_pos/core/tax/tax_engine.dart';
import 'package:flutter_test/flutter_test.dart';

const gst = TaxRule(id: 'gst', name: 'GST', cashBp: 1500, cardOnlineBp: 500);
const cash = PaymentPortionInput(methodId: 'cash', methodName: 'Cash', group: RateGroup.cash);
const card = PaymentPortionInput(methodId: 'card', methodName: 'Card', group: RateGroup.cardOnline);

List<BillLine> sampleLines() => const [
      BillLine(key: 'cap', unitPrice: 65000, qty: 2), // 2 × Rs 650
      BillLine(key: 'cro', unitPrice: 55000, qty: 1), // 1 × Rs 550
    ];

void main() {
  group('exclusive pricing', () {
    const cfg = BillConfig(taxes: [gst]);

    test('cash adds 15% GST on top', () {
      final b = computeBill(lines: sampleLines(), config: cfg, portions: const [cash]);
      expect(b.itemsNet, paisaFromRupees(1850));
      expect(b.taxTotal, paisaFromRupees(278)); // 277.5 rounds half up
      expect(b.total, paisaFromRupees(2128));
      expect(b.netExTax, paisaFromRupees(1850));
      expect(b.taxLines.single.rateBp, 1500);
    });

    test('card adds 5% GST on top', () {
      final b = computeBill(lines: sampleLines(), config: cfg, portions: const [card]);
      expect(b.taxTotal, paisaFromRupees(93)); // 92.5 → 93
      expect(b.total, paisaFromRupees(1943));
    });

    test('totalIfPaidWith previews both groups', () {
      expect(totalIfPaidWith(lines: sampleLines(), config: cfg, group: RateGroup.cash), paisaFromRupees(2128));
      expect(totalIfPaidWith(lines: sampleLines(), config: cfg, group: RateGroup.cardOnline), paisaFromRupees(1943));
    });

    test('FBR fee is added untaxed', () {
      const c = BillConfig(taxes: [gst], fbrFee: 100);
      final b = computeBill(lines: sampleLines(), config: c, portions: const [cash]);
      expect(b.fbrFee, 100);
      expect(b.total, paisaFromRupees(2129));
      expect(b.taxTotal, paisaFromRupees(278));
    });

    test('split: Rs 1000 cash then card pays the rest at 5%', () {
      final b = computeBill(
        lines: sampleLines(),
        config: cfg,
        portions: const [
          PaymentPortionInput(methodId: 'cash', methodName: 'Cash', group: RateGroup.cash, amount: 100000),
          card,
        ],
      );
      expect(b.portions, hasLength(2));
      final p1 = b.portions[0];
      final p2 = b.portions[1];
      expect(p1.amount, 100000);
      // 1000 / 1.15 = 869.57 net → tax 130
      expect(p1.taxTotal, paisaFromRupees(130));
      expect(p1.taxableBase, paisaFromRupees(870));
      // remaining net 980 → 5% = 49
      expect(p2.taxableBase, paisaFromRupees(980));
      expect(p2.taxTotal, paisaFromRupees(49));
      expect(p2.amount, paisaFromRupees(1029));
      expect(b.netExTax, paisaFromRupees(1850));
      expect(b.taxLines, hasLength(2));
    });

    test('explicit amount larger than the bill becomes the final portion', () {
      final b = computeBill(
        lines: sampleLines(),
        config: cfg,
        portions: const [
          PaymentPortionInput(methodId: 'cash', methodName: 'Cash', group: RateGroup.cash, amount: 500000),
          card,
        ],
      );
      expect(b.portions, hasLength(1));
      expect(b.total, paisaFromRupees(2128));
    });

    test('other taxes stack with GST, each on its own line', () {
      const other = TaxRule(id: 'pst', name: 'Other Tax', cashBp: 200, cardOnlineBp: 100);
      const c = BillConfig(taxes: [gst, other]);
      final b = computeBill(lines: sampleLines(), config: c, portions: const [cash]);
      expect(b.taxLines.map((t) => t.name), ['GST', 'Other Tax']);
      expect(b.taxLines[1].amount, paisaFromRupees(37));
      expect(b.total, paisaFromRupees(1850 + 278 + 37));
    });

    test('GST disabled means no tax', () {
      final b = computeBill(lines: sampleLines(), config: const BillConfig(), portions: const [cash]);
      expect(b.taxTotal, 0);
      expect(b.total, paisaFromRupees(1850));
    });

    test('tax-exempt items are not taxed', () {
      final b = computeBill(
        lines: const [
          BillLine(key: 'a', unitPrice: 100000, qty: 1),
          BillLine(key: 'water', unitPrice: 10000, qty: 1, taxExempt: true),
        ],
        config: cfg,
        portions: const [cash],
      );
      expect(b.taxTotal, paisaFromRupees(150));
      expect(b.total, paisaFromRupees(1250));
    });
  });

  group('inclusive pricing', () {
    const cfg = BillConfig(taxes: [gst], pricesIncludeTax: true);

    test('cash: total equals the prices, 15% GST shown inside', () {
      final b = computeBill(lines: sampleLines(), config: cfg, portions: const [cash]);
      expect(b.total, paisaFromRupees(1850));
      // 1850 × 15 / 115 = 241.30 → 241
      expect(b.taxTotal, paisaFromRupees(241));
      expect(b.netExTax, paisaFromRupees(1609));
      expect(b.taxLines.single.rateBp, 1500);
    });

    test('card: same total, 5% GST shown inside', () {
      final b = computeBill(lines: sampleLines(), config: cfg, portions: const [card]);
      expect(b.total, paisaFromRupees(1850));
      // 1850 × 5 / 105 = 88.10 → 88
      expect(b.taxTotal, paisaFromRupees(88));
      expect(b.taxLines.single.rateBp, 500);
    });

    test('split keeps the total and taxes each part at its rate', () {
      final b = computeBill(
        lines: sampleLines(),
        config: cfg,
        portions: const [
          PaymentPortionInput(methodId: 'cash', methodName: 'Cash', group: RateGroup.cash, amount: 115000),
          card,
        ],
      );
      expect(b.total, paisaFromRupees(1850));
      expect(b.portions[0].taxTotal, paisaFromRupees(150)); // 1150 × 15/115
      expect(b.portions[1].amount, paisaFromRupees(700));
      expect(b.portions[1].taxTotal, paisaFromRupees(33)); // 700 × 5/105 = 33.3
    });
  });

  group('discounts and charges', () {
    const cfg = BillConfig(taxes: [gst]);

    test('order discount is spread across lines and reduces the tax base', () {
      final b = computeBill(
        lines: sampleLines(),
        orderDiscount: const Discount.percent(1000),
        config: cfg,
        portions: const [cash],
      );
      expect(b.orderDiscount, paisaFromRupees(185));
      expect(b.itemsNet, paisaFromRupees(1665));
      expect(b.lines.fold<int>(0, (a, l) => a + l.orderDiscountShare), paisaFromRupees(185));
      expect(b.taxTotal, paisaFromRupees(250)); // 249.75
    });

    test('line discount cannot exceed the line', () {
      final b = computeBill(
        lines: const [BillLine(key: 'a', unitPrice: 50000, qty: 1, discount: Discount.amount(90000))],
        config: cfg,
        portions: const [cash],
      );
      expect(b.discountTotal, 50000);
      expect(b.total, 0);
    });

    test('service charge on discounted items, taxable when set', () {
      final b = computeBill(
        lines: sampleLines(),
        charges: const [ChargeRule(type: ChargeType.service, label: 'Service', mode: ChargeMode.percent, value: 1000, taxable: true)],
        config: cfg,
        portions: const [cash],
      );
      expect(b.chargesTotal, paisaFromRupees(185));
      expect(b.taxTotal, roundToRupee((185000 + 18500) * 0.15));
    });

    test('untaxed delivery charge', () {
      final b = computeBill(
        lines: sampleLines(),
        charges: const [ChargeRule(type: ChargeType.delivery, label: 'Delivery', mode: ChargeMode.fixed, value: 15000)],
        config: cfg,
        portions: const [card],
      );
      expect(b.total, paisaFromRupees(1850 + 93 + 150));
    });

    test('cash rounding to Rs 10 on the final cash portion only', () {
      const c = BillConfig(taxes: [gst], cashRoundingRupees: 10);
      final cashBill = computeBill(lines: sampleLines(), config: c, portions: const [cash]);
      expect(cashBill.total, paisaFromRupees(2130));
      expect(cashBill.rounding, paisaFromRupees(2));
      final cardBill = computeBill(lines: sampleLines(), config: c, portions: const [card]);
      expect(cardBill.rounding, 0);
    });
  });

  test('money formatting', () {
    expect(rs(185000), 'Rs 1,850');
    expect(rs(185050), 'Rs 1,850.50');
    expect(pct(1500), '15%');
    expect(pct(750), '7.5%');
    expect(parseRupees('1,250'), 125000);
    expect(roundToStep(212800, 10), 213000);
    expect(roundToStep(212400, 10), 212000);
  });
}
