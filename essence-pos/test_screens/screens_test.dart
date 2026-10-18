import 'package:essence_pos/app/providers.dart';
import 'package:essence_pos/core/db/database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'harness.dart';

const desktop = Size(1440, 900);
const tablet = Size(1024, 768);
const phone = Size(390, 844);

Future<void> fillCart(Shot s) async {
  await s.tester.runAsync(() async {
    final products = {for (final p in await s.services.db.select(s.services.db.products).get()) p.id: p};
    final cart = s.container.read(cartProvider.notifier);
    cart.add(products['cappuccino']!);
    cart.add(products['spanish']!);
    cart.add(products['croissant']!, qty: 2);
    cart.add(products['basque']!);
  });
  await s.settle();
}

void main() {
  for (final theme in ['light', 'dark']) {
    testWidgets('sell desktop $theme', (tester) async {
      final s = await bootApp(tester, size: desktop, theme: theme);
      await fillCart(s);
      await s.snap('sell_desktop_$theme');
      await teardown(tester, s);
    });
  }

  testWidgets('sell tablet', (tester) async {
    final s = await bootApp(tester, size: tablet);
    await fillCart(s);
    await s.snap('sell_tablet_light');
    await teardown(tester, s);
  });

  testWidgets('sell phone', (tester) async {
    final s = await bootApp(tester, size: phone);
    await fillCart(s);
    await s.snap('sell_phone_light');
    await teardown(tester, s);
  });

  testWidgets('lock', (tester) async {
    final s = await bootApp(tester, size: desktop);
    s.container.read(sessionProvider.notifier).lock();
    await s.settle(1200);
    await s.snap('lock_desktop_light');
    await teardown(tester, s);
  });

  for (final route in ['orders', 'shift', 'inventory', 'reports', 'settings']) {
    for (final theme in ['light', 'dark']) {
      testWidgets('$route desktop $theme', (tester) async {
        final s = await bootApp(tester, size: desktop, theme: theme);
        await s.go('/$route');
        await s.snap('${route}_desktop_$theme');
        await teardown(tester, s);
      });
    }
    testWidgets('$route phone', (tester) async {
      final s = await bootApp(tester, size: phone);
      await s.go('/$route');
      await s.snap('${route}_phone_light');
      await teardown(tester, s);
    });
  }

  // Keep StaffMember import used for analyzer.
  test('types', () => expect(StaffMember, isNotNull));
}
