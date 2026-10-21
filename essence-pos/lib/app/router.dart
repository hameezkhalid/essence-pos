import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../dashboard/dashboard_page.dart';
import '../features/inventory/inventory_screen.dart';
import '../features/lock/lock_screen.dart';
import '../features/menu/menu_page.dart';
import '../features/orders/orders_screen.dart';
import '../features/reports/reports_screen.dart';
import '../features/sell/sell_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/shell/app_shell.dart';
import '../features/shift/shift_screen.dart';
import 'platform.dart';

/// Routes. [isSignedIn] gates everything behind the staff lock screen.
GoRouter buildRouter({required bool Function() isSignedIn, required Listenable refresh}) {
  Page<void> fade(Widget child, GoRouterState s) => CustomTransitionPage(
        key: s.pageKey,
        child: child,
        transitionDuration: const Duration(milliseconds: 160),
        transitionsBuilder: (_, a, _, c) => FadeTransition(opacity: a, child: c),
      );

  return GoRouter(
    initialLocation: homeRoute,
    refreshListenable: refresh,
    redirect: (context, state) {
      final atLock = state.matchedLocation == '/lock';
      if (!isSignedIn()) return atLock ? null : '/lock';
      if (atLock) return homeRoute;
      return null;
    },
    routes: [
      GoRoute(path: '/lock', pageBuilder: (c, s) => fade(const LockScreen(), s)),
      ShellRoute(
        builder: (context, state, child) => AppShell(location: state.matchedLocation, child: child),
        routes: [
          GoRoute(path: '/dashboard', pageBuilder: (c, s) => fade(const DashboardPage(), s)),
          GoRoute(path: '/menu', pageBuilder: (c, s) => fade(const MenuPage(), s)),
          GoRoute(path: '/sell', pageBuilder: (c, s) => fade(const SellScreen(), s)),
          GoRoute(
            path: '/orders',
            pageBuilder: (c, s) => fade(OrdersScreen(initialOrderId: s.uri.queryParameters['id']), s),
          ),
          GoRoute(path: '/shift', pageBuilder: (c, s) => fade(const ShiftScreen(), s)),
          GoRoute(path: '/inventory', pageBuilder: (c, s) => fade(const InventoryScreen(), s)),
          GoRoute(path: '/reports', pageBuilder: (c, s) => fade(const ReportsScreen(), s)),
          GoRoute(path: '/settings', pageBuilder: (c, s) => fade(const SettingsScreen(), s)),
          GoRoute(path: '/settings/:section', pageBuilder: (c, s) => fade(SettingsScreen(section: s.pathParameters['section']), s)),
        ],
      ),
    ],
  );
}
