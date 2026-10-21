import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/theme/tokens.dart';
import '../../core/models/settings_models.dart';
import '../../shared/common.dart';
import 'menu/menu_settings.dart';
import 'sections/logins_section.dart';
import 'sections/activity_section.dart';
import 'sections/appearance_section.dart';
import 'sections/charges_section.dart';
import 'sections/data_section.dart';
import 'sections/discounts_section.dart';
import 'sections/fbr_section.dart';
import 'sections/online_section.dart';
import 'sections/orders_section.dart';
import 'sections/payments_section.dart';
import 'sections/printers_section.dart';
import 'sections/receipt_section.dart';
import 'sections/security_section.dart';
import 'sections/store_section.dart';
import 'sections/tax_section.dart';
import 'sections/terminal_section.dart';
import 'settings_widgets.dart';
import 'staff/staff_settings.dart';

/// One entry in the settings section list.
class SettingsSection {
  const SettingsSection(
    this.id,
    this.label,
    this.icon,
    this.group, {
    this.perm,
    required this.hint,
  });
  final String id;
  final String label;
  final IconData icon;
  final String group;
  final String hint;

  /// Null = open to everyone.
  final Perm? perm;
}

const settingsGroups = ['Store', 'Menu & people', 'This terminal', 'System'];

const settingsSections = [
  SettingsSection(
    'store',
    'Store profile',
    Icons.storefront_outlined,
    'Store',
    perm: Perm.manageSettings,
    hint: 'Name, address, NTN, invoices',
  ),
  SettingsSection(
    'tax',
    'Tax',
    Icons.percent_rounded,
    'Store',
    perm: Perm.manageSettings,
    hint: 'GST, other taxes, pricing',
  ),
  SettingsSection(
    'payments',
    'Payment methods',
    Icons.payments_outlined,
    'Store',
    perm: Perm.manageSettings,
    hint: 'Cash, card, wallets',
  ),
  SettingsSection(
    'orders',
    'Order types & tables',
    Icons.table_restaurant_outlined,
    'Store',
    perm: Perm.manageSettings,
    hint: 'Dine-in, takeaway, floor plan',
  ),
  SettingsSection(
    'online',
    'Online orders',
    Icons.language_rounded,
    'Store',
    perm: Perm.manageSettings,
    hint: 'Website pickup, WhatsApp',
  ),
  SettingsSection(
    'charges',
    'Charges & fees',
    Icons.request_quote_outlined,
    'Store',
    perm: Perm.manageSettings,
    hint: 'Service, delivery, FBR fee',
  ),
  SettingsSection(
    'discounts',
    'Discounts',
    Icons.local_offer_outlined,
    'Store',
    perm: Perm.manageSettings,
    hint: 'Presets and cashier limits',
  ),
  SettingsSection(
    'receipt',
    'Receipt',
    Icons.receipt_long_outlined,
    'Store',
    perm: Perm.manageSettings,
    hint: 'Header, footer, printing',
  ),
  SettingsSection(
    'menu',
    'Menu',
    Icons.restaurant_menu_rounded,
    'Menu & people',
    perm: Perm.manageMenu,
    hint: 'Categories, products, modifiers',
  ),
  SettingsSection(
    'staff',
    'Staff & roles',
    Icons.badge_outlined,
    'Menu & people',
    perm: Perm.manageStaff,
    hint: 'PINs and permissions',
  ),
  SettingsSection(
    'printers',
    'Printers',
    Icons.print_outlined,
    'This terminal',
    perm: Perm.manageSettings,
    hint: 'Receipt and bar printers',
  ),
  SettingsSection(
    'terminal',
    'Terminal',
    Icons.point_of_sale_outlined,
    'This terminal',
    perm: Perm.manageSettings,
    hint: 'Name, code, all terminals',
  ),
  SettingsSection(
    'appearance',
    'Appearance',
    Icons.palette_outlined,
    'This terminal',
    hint: 'Theme and grid density',
  ),
  SettingsSection(
    'logins',
    'Store logins',
    Icons.key_rounded,
    'System',
    perm: Perm.manageSettings,
    hint: 'Tills and dashboard access',
  ),
  SettingsSection(
    'fbr',
    'FBR integration',
    Icons.verified_outlined,
    'System',
    perm: Perm.manageSettings,
    hint: 'POS ID, reporting status',
  ),
  SettingsSection(
    'security',
    'Security',
    Icons.shield_outlined,
    'System',
    perm: Perm.manageSettings,
    hint: 'Auto-lock, shifts',
  ),
  SettingsSection(
    'activity',
    'Activity log',
    Icons.history_rounded,
    'System',
    perm: Perm.manageSettings,
    hint: 'Voids, refunds, discounts',
  ),
  SettingsSection(
    'data',
    'Data & sync',
    Icons.cloud_sync_outlined,
    'System',
    perm: Perm.manageSettings,
    hint: 'Sync, account, reset',
  ),
];

SettingsSection? sectionById(String? id) =>
    settingsSections.where((s) => s.id == id).firstOrNull;

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key, this.section});
  final String? section;

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.section;
  }

  @override
  void didUpdateWidget(covariant SettingsScreen old) {
    super.didUpdateWidget(old);
    if (widget.section != old.section) _selected = widget.section;
  }

  /// Ids of the sections the signed-in staff member may open. Call from build only.
  Set<String> _allowedIds() => {
    for (final s in settingsSections)
      if (s.perm == null || ref.watch(canProvider(s.perm!))) s.id,
  };

  String _defaultSection(Set<String> allowed) {
    final store = settingsSections.first.id;
    if (allowed.contains(store)) return store;
    return settingsSections
            .where((s) => allowed.contains(s.id))
            .firstOrNull
            ?.id ??
        store;
  }

  Future<void> _open(String id) async {
    if (id == _selected && !context.isPhone) return;
    if (!await confirmLeave(context, ref)) return;
    if (!mounted) return;
    if (context.isPhone) {
      context.go('/settings/$id');
    } else {
      setState(() => _selected = id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final phone = context.isPhone;
    final ec = context.ec;
    final allowed = _allowedIds();

    if (phone) {
      final s = sectionById(_selected);
      if (_selected == null) {
        return _SectionList(
          selected: null,
          allowed: allowed,
          onTap: _open,
          phone: true,
        );
      }
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) async {
          if (didPop) return;
          if (await confirmLeave(context, ref) && context.mounted) {
            context.go('/settings');
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PhoneSectionHeader(title: s?.label ?? 'Settings'),
            Expanded(child: _body(s, allowed)),
          ],
        ),
      );
    }

    final id = sectionById(_selected) == null
        ? _defaultSection(allowed)
        : _selected!;
    final s = sectionById(id)!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: context.isDesktop ? 272 : 248,
          decoration: BoxDecoration(
            color: ec.surface,
            border: Border(right: BorderSide(color: ec.border)),
          ),
          child: _SectionList(
            selected: id,
            allowed: allowed,
            onTap: _open,
            phone: false,
          ),
        ),
        Expanded(
          child: KeyedSubtree(key: ValueKey(id), child: _body(s, allowed)),
        ),
      ],
    );
  }

  Widget _body(SettingsSection? s, Set<String> allowed) {
    if (s == null) {
      return const EmptyState(
        icon: Icons.search_off_rounded,
        title: 'Section not found',
        message: 'Pick a section from the settings list.',
      );
    }
    if (!allowed.contains(s.id)) return LockedSection(title: s.label);
    return switch (s.id) {
      'store' => const StoreSection(),
      'tax' => const TaxSection(),
      'payments' => const PaymentsSection(),
      'orders' => const OrdersSection(),
      'online' => const OnlineSection(),
      'charges' => const ChargesSection(),
      'discounts' => const DiscountsSection(),
      'receipt' => const ReceiptSection(),
      'menu' => const SettingsScaffold(
        title: 'Menu',
        subtitle: 'Categories, products, sizes, modifiers and availability.',
        children: [MenuSettingsPane()],
      ),
      'staff' => const SettingsScaffold(
        title: 'Staff & roles',
        subtitle:
            'Who can use the till, their PINs, and what each role may do.',
        children: [StaffSettingsPane()],
      ),
      'printers' => const PrintersSection(),
      'terminal' => const TerminalSection(),
      'appearance' => const AppearanceSection(),
      'fbr' => const FbrSection(),
      'logins' => const LoginsSection(),
      'security' => const SecuritySection(),
      'activity' => const ActivitySection(),
      'data' => const DataSection(),
      _ => const SizedBox.shrink(),
    };
  }
}

class _SectionList extends ConsumerWidget {
  const _SectionList({
    required this.selected,
    required this.allowed,
    required this.onTap,
    required this.phone,
  });
  final String? selected;
  final Set<String> allowed;
  final ValueChanged<String> onTap;
  final bool phone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ec = context.ec;
    final staff = ref.watch(sessionProvider);
    final children = <Widget>[
      Padding(
        padding: EdgeInsets.fromLTRB(phone ? Sp.xs : Sp.sm, 0, Sp.sm, Sp.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Settings',
              style: phone
                  ? context.tt.headlineMedium
                  : context.tt.headlineSmall,
            ),
            if (staff != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  'Signed in as ${staff.name} · ${Role.parse(staff.role).label}',
                  style: context.tt.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    ];
    for (final g in settingsGroups) {
      final items = settingsSections.where((s) => s.group == g).toList();
      children.add(
        Padding(
          padding: EdgeInsets.fromLTRB(
            phone ? Sp.xs : Sp.sm,
            Sp.md,
            Sp.sm,
            Sp.xs,
          ),
          child: Text(
            g.toUpperCase(),
            style: context.tt.labelSmall?.copyWith(
              color: ec.textFaint,
              letterSpacing: 0.8,
            ),
          ),
        ),
      );
      if (phone) {
        children.add(
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  if (i > 0) Divider(height: 1, indent: 60, color: ec.border),
                  _SectionTile(
                    section: items[i],
                    selected: false,
                    enabled: allowed.contains(items[i].id),
                    onTap: () => onTap(items[i].id),
                    phone: true,
                  ),
                ],
              ],
            ),
          ),
        );
      } else {
        for (final s in items) {
          children.add(
            _SectionTile(
              section: s,
              selected: s.id == selected,
              enabled: allowed.contains(s.id),
              onTap: () => onTap(s.id),
              phone: false,
            ),
          );
        }
      }
    }
    children.add(const SizedBox(height: Sp.lg));
    return ListView(
      padding: EdgeInsets.all(phone ? Sp.lg : Sp.md)
          .copyWith(top: phone ? Sp.lg : Sp.xl),
      children: phone
          ? [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: settingsMaxWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: children,
                  ),
                ),
              ),
            ]
          : children,
    );
  }
}

class _SectionTile extends StatelessWidget {
  const _SectionTile({
    required this.section,
    required this.selected,
    required this.enabled,
    required this.onTap,
    required this.phone,
  });
  final SettingsSection section;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;
  final bool phone;

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    final fg = !enabled
        ? ec.textFaint
        : (selected ? ec.onPrimaryContainer : ec.textMuted);
    final tile = Material(
      color: selected ? ec.primaryContainer : Colors.transparent,
      borderRadius: BorderRadius.circular(phone ? 0 : Rad.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(phone ? 0 : Rad.md),
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: phone ? Sp.lg : Sp.md,
              vertical: phone ? Sp.md : 10,
            ),
            child: Row(
              children: [
                Icon(section.icon, size: 20, color: fg),
                SizedBox(width: phone ? Sp.lg : Sp.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        section.label,
                        style: context.tt.labelLarge?.copyWith(
                          color: !enabled
                              ? ec.textFaint
                              : (selected ? ec.text : ec.text),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (phone)
                        Text(
                          section.hint,
                          style: context.tt.bodySmall?.copyWith(
                            color: enabled ? ec.textMuted : ec.textFaint,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                if (!enabled)
                  Icon(
                    Icons.lock_outline_rounded,
                    size: 16,
                    color: ec.textFaint,
                  ),
                if (enabled && phone)
                  Icon(Icons.chevron_right_rounded, color: ec.textFaint),
              ],
            ),
          ),
        ),
      ),
    );
    return Semantics(
      selected: selected,
      button: true,
      label: enabled ? null : '${section.label}, locked',
      child: phone
          ? tile
          : Padding(
              padding: const EdgeInsets.symmetric(vertical: 1),
              child: Opacity(opacity: enabled ? 1 : 0.7, child: tile),
            ),
    );
  }
}
