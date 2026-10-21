import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/platform.dart';
import '../../app/providers.dart';
import '../../app/theme/tokens.dart';
import '../../core/models/menu_models.dart';
import '../../core/models/settings_models.dart';
import '../../core/services/inventory_service.dart';
import '../../core/services/pos_service.dart';
import '../../core/services/web_order_intake.dart';
import '../../core/money.dart';
import '../sell/sell_dialogs.dart';
import '../../shared/approval.dart';
import '../../shared/common.dart';
import '../lock/lock_screen.dart';
import '../shift/shift_dialogs.dart';
import 'status_widgets.dart';

class NavItem {
  const NavItem(this.path, this.label, this.icon, this.selectedIcon, {this.perm});
  final String path;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final Perm? perm;
}

const _tillNav = [
  NavItem('/sell', 'Sell', Icons.point_of_sale_outlined, Icons.point_of_sale_rounded),
  NavItem('/orders', 'Orders', Icons.receipt_long_outlined, Icons.receipt_long_rounded),
  NavItem('/shift', 'Shift', Icons.schedule_outlined, Icons.schedule_rounded),
  NavItem('/inventory', 'Inventory', Icons.inventory_2_outlined, Icons.inventory_2_rounded),
  NavItem('/reports', 'Reports', Icons.insights_outlined, Icons.insights_rounded, perm: Perm.viewReports),
  NavItem('/settings', 'Settings', Icons.tune_outlined, Icons.tune_rounded),
];

/// Web admin panel: the dashboard and menu first, plus the same POS screens as the till.
const _adminNav = [
  NavItem('/dashboard', 'Dashboard', Icons.space_dashboard_outlined, Icons.space_dashboard_rounded, perm: Perm.viewReports),
  NavItem('/sell', 'POS', Icons.point_of_sale_outlined, Icons.point_of_sale_rounded),
  NavItem('/menu', 'Menu', Icons.restaurant_menu_outlined, Icons.restaurant_menu_rounded, perm: Perm.manageMenu),
  NavItem('/orders', 'Orders', Icons.receipt_long_outlined, Icons.receipt_long_rounded),
  NavItem('/inventory', 'Inventory', Icons.inventory_2_outlined, Icons.inventory_2_rounded),
  NavItem('/reports', 'Reports', Icons.insights_outlined, Icons.insights_rounded, perm: Perm.viewReports),
  NavItem('/shift', 'Shift', Icons.schedule_outlined, Icons.schedule_rounded),
  NavItem('/settings', 'Settings', Icons.tune_outlined, Icons.tune_rounded),
];

const navItems = adminPanel ? _adminNav : _tillNav;

/// Main layout: navigation rail (desktop/tablet) or bottom bar (phone) + top bar.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, required this.location, required this.child});
  final String location;
  final Widget child;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  Timer? _idle;
  final _subs = <StreamSubscription<dynamic>>[];
  bool _askedShift = false;

  @override
  void initState() {
    super.initState();
    final svc = ref.read(servicesProvider);
    _subs.add(svc.pos.notices.listen(_onNotice));
    _subs.add(svc.inventory.alerts.listen(_onStockAlert));
    final web = svc.webOrders;
    if (web != null) _subs.add(web.events.listen(_onWebOrder));
    _resetIdle();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeAskShift());
  }

  @override
  void dispose() {
    _chime?.dispose();
    _idle?.cancel();
    for (final s in _subs) {
      s.cancel();
    }
    super.dispose();
  }

  void _onNotice(PrintNotice n) {
    if (mounted) toast(context, n.message, error: n.error, icon: n.error ? Icons.print_disabled_outlined : Icons.print_outlined);
  }

  AudioPlayer? _chime;

  Future<void> _onWebOrder(WebOrderArrived e) async {
    if (!mounted) return;
    toast(
      context,
      'New online order #${e.code} · ${e.order.customerName ?? ''} · ${rs(e.order.itemsGross)}',
      icon: Icons.language_rounded,
      duration: const Duration(seconds: 12),
      action: SnackBarAction(
        label: 'View',
        onPressed: () {
          context.go('/sell');
          showHeldOrders(context, ref, webOnly: true);
        },
      ),
    );
    try {
      _chime ??= AudioPlayer();
      await _chime!.play(AssetSource('sounds/chime.wav'));
    } catch (_) {}
  }

  void _onStockAlert(LowStockAlert a) {
    if (!mounted) return;
    final crit = a.state == StockState.critical || a.state == StockState.out;
    toast(
      context,
      '${a.item.name} is ${crit ? 'critically low' : 'running low'} — ${a.item.fmt(a.qty)} left',
      icon: Icons.inventory_2_outlined,
      action: SnackBarAction(label: 'View', onPressed: () => context.go('/inventory')),
    );
  }

  void _resetIdle() {
    _idle?.cancel();
    final mins = ref.read(settingsValueProvider).security.autoLockMinutes;
    if (mins <= 0) return;
    _idle = Timer(Duration(minutes: mins), () {
      if (mounted) ref.read(sessionProvider.notifier).lock();
    });
  }

  Future<void> _maybeAskShift() async {
    // The admin panel asks for a shift only when someone charges a sale.
    if (_askedShift || !mounted || adminPanel) return;
    _askedShift = true;
    final s = ref.read(settingsValueProvider);
    if (!s.security.requireOpenShift) return;
    final open = await ref.read(servicesProvider).shifts.openShift();
    if (open == null && mounted) await showOpenShiftDialog(context, ref);
  }

  List<NavItem> _visible() {
    final role = ref.watch(roleProvider);
    final perms = ref.watch(settingsValueProvider).permissions;
    return [
      for (final n in navItems)
        if (n.path == '/settings'
            ? (perms.allows(role, Perm.manageSettings) || perms.allows(role, Perm.manageMenu) || perms.allows(role, Perm.manageStaff))
            : (n.perm == null || perms.allows(role, n.perm!)))
          n,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final items = _visible();
    var index = items.indexWhere((n) => widget.location.startsWith(n.path));
    if (index < 0) index = 0;
    final phone = context.isPhone;
    final ec = context.ec;

    final content = Column(children: [
      _TopBar(phone: phone),
      Expanded(child: widget.child),
    ]);

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _resetIdle(),
      child: Scaffold(
        body: SafeArea(
          child: phone
              ? content
              : Row(children: [
                  _Rail(items: items, index: index),
                  VerticalDivider(width: 1, color: ec.border),
                  Expanded(child: content),
                ]),
        ),
        bottomNavigationBar: phone ? _PhoneNav(items: items, index: index) : null,
      ),
    );
  }
}

class _Rail extends StatelessWidget {
  const _Rail({required this.items, required this.index});
  final List<NavItem> items;
  final int index;

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    final extended = context.screenW >= 1500;
    return Container(
      width: extended ? 200 : 88,
      color: ec.surface,
      child: Column(children: [
        const SizedBox(height: Sp.md),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: Sp.sm),
          child: extended
              ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const EssenceLogo(size: 44),
                  const SizedBox(width: Sp.sm),
                  Text('Essence', style: context.tt.headlineSmall),
                ])
              : const EssenceLogo(size: 52),
        ),
        const SizedBox(height: Sp.lg),
        for (var i = 0; i < items.length; i++)
          _RailButton(item: items[i], selected: i == index, extended: extended),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.only(bottom: Sp.md),
          child: Text('Brew OS', style: context.tt.labelSmall?.copyWith(color: ec.textFaint)),
        ),
      ]),
    );
  }
}

class _RailButton extends StatelessWidget {
  const _RailButton({required this.item, required this.selected, required this.extended});
  final NavItem item;
  final bool selected;
  final bool extended;

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    final fg = selected ? ec.onPrimaryContainer : ec.textMuted;
    final child = extended
        ? Row(children: [
            Icon(selected ? item.selectedIcon : item.icon, color: fg),
            const SizedBox(width: Sp.md),
            Text(item.label, style: context.tt.labelLarge?.copyWith(color: selected ? ec.text : ec.textMuted)),
          ])
        : Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(selected ? item.selectedIcon : item.icon, color: fg),
            const SizedBox(height: 4),
            Text(item.label, style: context.tt.labelSmall?.copyWith(color: selected ? ec.text : ec.textMuted, letterSpacing: 0)),
          ]);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      child: Material(
        color: selected ? ec.primaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(Rad.md),
        child: InkWell(
          borderRadius: BorderRadius.circular(Rad.md),
          onTap: () => context.go(item.path),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: extended ? 12 : 10, horizontal: extended ? 14 : 4),
            child: SizedBox(width: double.infinity, child: child),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends ConsumerWidget {
  const _TopBar({required this.phone});
  final bool phone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ec = context.ec;
    final staff = ref.watch(sessionProvider);
    final svc = ref.watch(servicesProvider);
    final shift = ref.watch(openShiftProvider).value;
    final mode = ref.watch(themeModeProvider).value ?? ThemeMode.system;
    final dark = context.isDark;
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: Sp.lg),
      decoration: BoxDecoration(color: ec.bg, border: Border(bottom: BorderSide(color: ec.border))),
      child: Row(children: [
        if (phone) ...[const EssenceLogo(size: 34), const SizedBox(width: Sp.sm)],
        Expanded(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(ref.watch(settingsValueProvider).store.name, style: context.tt.titleMedium, overflow: TextOverflow.ellipsis),
            Text(
              '${svc.device.name} · ${svc.device.code}${shift == null ? ' · No open shift' : ''}',
              style: context.tt.labelSmall?.copyWith(color: shift == null ? ec.warning : ec.textMuted, letterSpacing: 0),
              overflow: TextOverflow.ellipsis,
            ),
          ]),
        ),
        SyncPill(compact: phone),
        if (!phone) ...[const SizedBox(width: Sp.md), const LiveClock()],
        const SizedBox(width: Sp.xs),
        IconButton(
          tooltip: dark ? 'Light theme' : 'Dark theme',
          onPressed: () {
            final next = mode == ThemeMode.system ? (dark ? 'light' : 'dark') : (mode == ThemeMode.dark ? 'light' : 'dark');
            ref.read(dbProvider).setMeta('ui.theme', next);
          },
          icon: Icon(dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
        ),
        if (staff != null)
          PopupMenuButton<String>(
            tooltip: 'Staff menu',
            position: PopupMenuPosition.under,
            onSelected: (v) async {
              switch (v) {
                case 'lock':
                  ref.read(sessionProvider.notifier).lock();
                case 'shift':
                  context.go('/shift');
                case 'drawer':
                  final ok = await requirePermission(context, ref, Perm.openDrawer, why: 'Open the cash drawer without a sale');
                  if (ok != null) {
                    final r = await svc.pos.noSaleDrawer(staff, approvedBy: ok.id == staff.id ? null : ok);
                    if (context.mounted) {
                      toast(context, r.nothingConfigured ? 'No cash drawer set up on this terminal' : (r.ok ? 'Drawer opened' : r.errors.first),
                          error: !r.ok || r.nothingConfigured);
                    }
                  }
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                enabled: false,
                child: Text('${staff.name} · ${Role.parse(staff.role).label}', style: context.tt.titleSmall),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(value: 'shift', child: ListTile(leading: Icon(Icons.schedule_rounded), title: Text('Shift & cash'))),
              const PopupMenuItem(value: 'drawer', child: ListTile(leading: Icon(Icons.point_of_sale_rounded), title: Text('Open cash drawer'))),
              const PopupMenuItem(value: 'lock', child: ListTile(leading: Icon(Icons.lock_outline_rounded), title: Text('Lock / switch user'))),
            ],
            child: Padding(
              padding: const EdgeInsets.only(left: Sp.xs),
              child: Row(children: [
                StaffAvatar(staff: staff, size: 36),
                if (!phone) ...[
                  const SizedBox(width: Sp.sm),
                  Text(staff.name.split(' ').first, style: context.tt.labelLarge),
                  Icon(Icons.expand_more_rounded, color: ec.textMuted),
                ],
              ]),
            ),
          ),
      ]),
    );
  }
}

/// Bottom bar on phones; with more than five sections the rest go under "More".
class _PhoneNav extends StatelessWidget {
  const _PhoneNav({required this.items, required this.index});
  final List<NavItem> items;
  final int index;

  @override
  Widget build(BuildContext context) {
    const maxShown = 5;
    final overflow = items.length > maxShown;
    final shown = overflow ? items.take(maxShown - 1).toList() : items;
    final rest = overflow ? items.skip(maxShown - 1).toList() : const <NavItem>[];
    final inRest = index >= shown.length;
    return NavigationBar(
      selectedIndex: inRest ? shown.length : index,
      onDestinationSelected: (i) {
        if (i < shown.length) {
          context.go(shown[i].path);
          return;
        }
        showModalBottomSheet<void>(
          context: context,
          builder: (ctx) => SafeArea(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              for (final n in rest)
                ListTile(
                  leading: Icon(n.icon),
                  title: Text(n.label),
                  onTap: () {
                    Navigator.pop(ctx);
                    context.go(n.path);
                  },
                ),
              const SizedBox(height: Sp.md),
            ]),
          ),
        );
      },
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      destinations: [
        for (final n in shown) NavigationDestination(icon: Icon(n.icon), selectedIcon: Icon(n.selectedIcon), label: n.label),
        if (overflow)
          NavigationDestination(
            icon: const Icon(Icons.more_horiz_rounded),
            selectedIcon: Icon(inRest ? items[index].selectedIcon : Icons.more_horiz_rounded),
            label: inRest ? items[index].label : 'More',
          ),
      ],
    );
  }
}
