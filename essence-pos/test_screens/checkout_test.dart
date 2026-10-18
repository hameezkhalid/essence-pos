import 'dart:convert';

import 'package:essence_pos/core/models/settings_models.dart';
import 'package:flutter_test/flutter_test.dart';

import 'harness.dart';
import 'screens_test.dart' show desktop, phone, fillCart;

void main() {
  testWidgets('payment and sale complete', (tester) async {
    final s = await bootApp(tester, size: desktop);
    await fillCart(s);
    await tester.tap(find.text('Charge'));
    for (var i = 0; i < 5; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
      await s.settle(300);
    }
    await s.snap('payment_desktop_light');
    await tester.tap(find.text('Rs 5,000').first);
    await s.settle();
    await s.snap('payment_cash_tendered');
    await tester.tap(find.textContaining('Complete'));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 500)));
    await s.settle(1500);
    await s.snap('sale_complete_desktop_light');
    await teardown(tester, s);
  });

  testWidgets('tax inclusive cart', (tester) async {
    final s = await bootApp(tester, size: desktop, theme: 'dark');
    await tester.runAsync(() async {
      await s.services.settingsRepo.save(SettingKeys.pricing, const PricingSettings(pricesIncludeTax: true).toJson());
    });
    await s.settle();
    await fillCart(s);
    await s.snap('sell_inclusive_dark');
    await teardown(tester, s);
  });

  testWidgets('phone cart sheet', (tester) async {
    final s = await bootApp(tester, size: phone);
    await fillCart(s);
    await tester.tap(find.text('View order'));
    await s.settle(1200);
    await s.snap('cart_sheet_phone');
    await teardown(tester, s);
  });

  test('json', () => expect(jsonEncode({}), '{}'));
}
