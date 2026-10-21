import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme/tokens.dart';
import '../../core/db/database.dart';
import '../../core/models/cart.dart';
import '../../core/models/order_models.dart';
import '../../core/models/settings_models.dart';
import '../../core/money.dart';
import '../../core/services/web_order_intake.dart';
import '../../core/tax/tax_engine.dart';
import '../../shared/approval.dart';
import '../../shared/common.dart';
import '../../shared/whatsapp.dart';

// ───────────────────────── Tables ─────────────────────────

/// Pick a table (and guest count) for a dine-in order. Returns true when a table was chosen.
Future<bool?> showTablePicker(BuildContext context, WidgetRef ref) =>
    showAdaptive<bool>(context, maxWidth: 720, builder: (_) => const _TablePicker());

class _TablePicker extends ConsumerStatefulWidget {
  const _TablePicker();
  @override
  ConsumerState<_TablePicker> createState() => _TablePickerState();
}

class _TablePickerState extends ConsumerState<_TablePicker> {
  String? _area;
  int _guests = 2;

  @override
  void initState() {
    super.initState();
    _guests = ref.read(cartProvider).guests ?? 2;
  }

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    final areas = ref.watch(areasProvider).value ?? const [];
    final tables = (ref.watch(tablesProvider).value ?? const []).where((t) => t.active).toList();
    final held = ref.watch(heldOrdersProvider).value ?? const [];
    final cart = ref.watch(cartProvider);
    final area = _area ?? (areas.isNotEmpty ? areas.first.id : null);
    final shown = tables.where((t) => area == null || t.areaId == area).toList();
    final busy = <String, Order>{for (final o in held) if (o.tableId != null && o.id != cart.heldOrderId) o.tableId!: o};

    return DialogFrame(
      title: 'Choose a table',
      icon: Icons.table_restaurant_outlined,
      actions: [
        Row(mainAxisSize: MainAxisSize.min, children: [
          Text('Guests', style: context.tt.labelLarge),
          const SizedBox(width: Sp.sm),
          QtyStepper(value: _guests, min: 1, max: 30, onChanged: (v) => setState(() => _guests = v)),
        ]),
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
      ],
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        if (areas.length > 1)
          Padding(
            padding: const EdgeInsets.only(bottom: Sp.md),
            child: Wrap(spacing: Sp.sm, children: [
              for (final a in areas) ChoiceChip(label: Text(a.name), selected: a.id == area, onSelected: (_) => setState(() => _area = a.id)),
            ]),
          ),
        if (shown.isEmpty)
          const EmptyState(icon: Icons.table_restaurant_outlined, title: 'No tables', message: 'Add tables in Settings › Order types & tables.')
        else
          ResponsiveGrid(
            minWidth: 110,
            spacing: Sp.sm,
            children: [
              for (final t in shown)
                Builder(builder: (context) {
                  final o = busy[t.id];
                  final selected = cart.tableId == t.id;
                  return Material(
                    color: selected ? ec.primary : (o != null ? ec.accentContainer : ec.surfaceAlt),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Rad.md),
                      side: BorderSide(color: selected ? ec.primary : (o != null ? ec.accent.withValues(alpha: 0.5) : ec.border)),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(Rad.md),
                      onTap: () async {
                        if (o != null && cart.isEmpty) {
                          ref.read(cartProvider.notifier).load(CartState.fromOrder(o));
                          Navigator.pop(context, true);
                          toast(context, 'Opened table ${t.label}’s order');
                          return;
                        }
                        ref.read(cartProvider.notifier).setTable(t, guests: _guests);
                        Navigator.pop(context, true);
                      },
                      child: SizedBox(
                        height: 84,
                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Text(t.label, style: context.tt.headlineSmall?.copyWith(color: selected ? ec.onPrimary : ec.text)),
                          Text(
                            o != null ? '${o.tokenLabel} · ${num0(o.total)}' : '${t.seats} seats',
                            style: context.tt.labelSmall?.copyWith(color: selected ? ec.onPrimary : (o != null ? ec.accent : ec.textMuted)),
                          ),
                        ]),
                      ),
                    ),
                  );
                }),
            ],
          ),
        const SizedBox(height: Sp.sm),
        Text('Tables with an open order are shaded. Tap one with an empty cart to continue its order.', style: context.tt.bodySmall),
      ]),
    );
  }
}

// ───────────────────────── Customers ─────────────────────────

Future<void> showCustomerDialog(BuildContext context, WidgetRef ref, {bool delivery = false}) =>
    showAdaptive<void>(context, maxWidth: 520, builder: (_) => _CustomerDialog(delivery: delivery));

class _CustomerDialog extends ConsumerStatefulWidget {
  const _CustomerDialog({required this.delivery});
  final bool delivery;
  @override
  ConsumerState<_CustomerDialog> createState() => _CustomerDialogState();
}

class _CustomerDialogState extends ConsumerState<_CustomerDialog> {
  final _q = TextEditingController();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  List<Customer> _results = const [];
  Customer? _picked;
  bool _creating = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    final cart = ref.read(cartProvider);
    _address.text = cart.deliveryAddress ?? '';
    _search('');
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _q.dispose();
    _name.dispose();
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  void _search(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 180), () async {
      final r = await ref.read(servicesProvider).customers.search(q);
      if (mounted) setState(() => _results = r);
    });
  }

  Future<void> _done() async {
    final cart = ref.read(cartProvider.notifier);
    if (_creating) {
      if (_name.text.trim().isEmpty) {
        toast(context, 'Enter the customer’s name', error: true);
        return;
      }
      if (widget.delivery && _phone.text.trim().isEmpty) {
        toast(context, 'A phone number is needed for delivery', error: true);
        return;
      }
      final c = await ref.read(servicesProvider).customers.create(name: _name.text.trim(), phone: _phone.text.trim(), address: _address.text.trim().isEmpty ? null : _address.text.trim());
      cart.setCustomer(c, address: _address.text.trim().isEmpty ? null : _address.text.trim());
    } else if (_picked != null) {
      final addr = _address.text.trim();
      if (widget.delivery && addr.isNotEmpty && addr != (_picked!.address ?? '')) {
        await ref.read(servicesProvider).customers.save(_picked!.copyWith(address: Value(addr)));
      }
      cart.setCustomer(_picked, address: addr.isEmpty ? null : addr);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    return DialogFrame(
      title: widget.delivery ? 'Delivery customer' : 'Customer',
      icon: Icons.person_outline_rounded,
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: (_creating || _picked != null) ? _done : null, child: Text(_creating ? 'Save & add' : 'Add to order')),
      ],
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: false, label: Text('Find'), icon: Icon(Icons.search_rounded)),
            ButtonSegment(value: true, label: Text('New customer'), icon: Icon(Icons.person_add_alt_rounded)),
          ],
          selected: {_creating},
          onSelectionChanged: (v) => setState(() => _creating = v.first),
        ),
        const SizedBox(height: Sp.md),
        if (!_creating) ...[
          TextField(
            controller: _q,
            autofocus: true,
            onChanged: _search,
            decoration: const InputDecoration(hintText: 'Search by phone or name', prefixIcon: Icon(Icons.search_rounded)),
          ),
          const SizedBox(height: Sp.sm),
          if (_results.isEmpty)
            Padding(
              padding: const EdgeInsets.all(Sp.lg),
              child: Text('No customers found. Add a new one.', style: context.tt.bodyMedium?.copyWith(color: ec.textMuted), textAlign: TextAlign.center),
            )
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 280),
              child: ListView(shrinkWrap: true, children: [
                for (final c in _results)
                  ListTile(
                    selected: _picked?.id == c.id,
                    selectedTileColor: ec.primaryContainer,
                    leading: CircleAvatar(backgroundColor: ec.beige, child: Text(c.name.isEmpty ? '?' : c.name[0], style: TextStyle(color: ec.accent))),
                    title: Text(c.name),
                    subtitle: Text([c.phone, if (c.address != null) c.address!].join(' · '), maxLines: 1, overflow: TextOverflow.ellipsis),
                    onTap: () => setState(() {
                      _picked = c;
                      if (widget.delivery && (c.address?.isNotEmpty ?? false)) _address.text = c.address!;
                    }),
                  ),
              ]),
            ),
        ] else ...[
          TextField(controller: _name, autofocus: true, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(labelText: 'Name')),
          const SizedBox(height: Sp.md),
          TextField(controller: _phone, keyboardType: TextInputType.phone, decoration: InputDecoration(labelText: widget.delivery ? 'Phone (required)' : 'Phone')),
        ],
        if (widget.delivery) ...[
          const SizedBox(height: Sp.md),
          TextField(controller: _address, maxLines: 2, decoration: const InputDecoration(labelText: 'Delivery address', prefixIcon: Icon(Icons.location_on_outlined))),
        ],
      ]),
    );
  }
}

// ───────────────────────── Order discount ─────────────────────────

Future<void> showDiscountDialog(BuildContext context, WidgetRef ref) =>
    showAdaptive<void>(context, maxWidth: 480, builder: (_) => const _DiscountDialog());

class _DiscountDialog extends ConsumerStatefulWidget {
  const _DiscountDialog();
  @override
  ConsumerState<_DiscountDialog> createState() => _DiscountDialogState();
}

class _DiscountDialogState extends ConsumerState<_DiscountDialog> {
  DiscountKind _kind = DiscountKind.percent;
  final _value = TextEditingController();
  final _reason = TextEditingController();
  Discount? _preset;

  @override
  void dispose() {
    _value.dispose();
    _reason.dispose();
    super.dispose();
  }

  Discount? get _discount {
    if (_preset != null) return _preset;
    final v = double.tryParse(_value.text.trim());
    if (v == null || v <= 0) return null;
    return _kind == DiscountKind.percent ? Discount.percent((v * 100).round().clamp(0, 10000)) : Discount.amount(paisaFromRupees(v));
  }

  Future<void> _apply() async {
    final d = _discount;
    if (d == null) return;
    final s = ref.read(settingsValueProvider).discounts;
    if (s.requireReason && _reason.text.trim().isEmpty) {
      toast(context, 'Add a reason for the discount', error: true);
      return;
    }
    final cart = ref.read(cartProvider);
    final b = ref.read(servicesProvider).pos.bill(cart, const [PaymentPortionInput(methodId: 'cash', methodName: 'Cash', group: RateGroup.cash)]);
    final base = b.itemsGross - b.lineDiscounts;
    final bp = base == 0 ? 0 : (d.apply(base) * 10000 / base).round();
    StaffMember? approver;
    if (bp > s.cashierMaxBp) {
      approver = await requirePermission(context, ref, Perm.discountOverride, why: '${pct(bp)} discount is above the cashier limit of ${pct(s.cashierMaxBp)}');
      if (approver == null) return;
    }
    final label = [d.label ?? d.display, if (_reason.text.trim().isNotEmpty) _reason.text.trim()].join(' · ');
    ref.read(cartProvider.notifier).setOrderDiscount(Discount(kind: d.kind, value: d.value, label: label), approvedBy: approver?.name);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(settingsValueProvider).discounts;
    final cart = ref.watch(cartProvider);
    return DialogFrame(
      title: 'Discount',
      subtitle: 'Applies to the whole order · cashier limit ${pct(s.cashierMaxBp)}',
      icon: Icons.percent_rounded,
      actions: [
        if (cart.orderDiscount != null)
          TextButton(
            onPressed: () {
              ref.read(cartProvider.notifier).setOrderDiscount(null);
              Navigator.pop(context);
            },
            child: const Text('Remove discount'),
          ),
        FilledButton(onPressed: _discount == null ? null : _apply, child: const Text('Apply')),
      ],
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Wrap(spacing: Sp.sm, runSpacing: Sp.sm, children: [
          for (final p in s.presets)
            ChoiceChip(
              label: Text(p.label ?? p.display),
              selected: _preset == p,
              onSelected: (v) => setState(() {
                _preset = v ? p : null;
                _value.clear();
              }),
            ),
        ]),
        const SizedBox(height: Sp.lg),
        Text('Custom', style: context.tt.titleSmall),
        const SizedBox(height: Sp.sm),
        Row(children: [
          SegmentedButton<DiscountKind>(
            showSelectedIcon: false,
            segments: const [ButtonSegment(value: DiscountKind.percent, label: Text('%')), ButtonSegment(value: DiscountKind.amount, label: Text('Rs'))],
            selected: {_kind},
            onSelectionChanged: (v) => setState(() => _kind = v.first),
          ),
          const SizedBox(width: Sp.md),
          Expanded(
            child: TextField(
              controller: _value,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => setState(() => _preset = null),
              decoration: InputDecoration(hintText: _kind == DiscountKind.percent ? 'e.g. 10' : 'e.g. 200'),
            ),
          ),
        ]),
        const SizedBox(height: Sp.md),
        TextField(
          controller: _reason,
          decoration: InputDecoration(labelText: s.requireReason ? 'Reason (required)' : 'Reason', hintText: 'e.g. Regular customer, staff meal'),
        ),
      ]),
    );
  }
}

// ───────────────────────── Note ─────────────────────────

Future<void> showOrderNoteDialog(BuildContext context, WidgetRef ref) async {
  final c = TextEditingController(text: ref.read(cartProvider).note ?? '');
  final r = await showAdaptive<String>(
    context,
    maxWidth: 460,
    builder: (ctx) => DialogFrame(
      title: 'Order note',
      icon: Icons.sticky_note_2_outlined,
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(ctx, c.text), child: const Text('Save')),
      ],
      child: TextField(controller: c, autofocus: true, maxLines: 3, decoration: const InputDecoration(hintText: 'Printed on the bar ticket and receipt')),
    ),
  );
  if (r != null) ref.read(cartProvider.notifier).setNote(r);
}

// ───────────────────────── Held orders ─────────────────────────

Future<void> showHeldOrders(BuildContext context, WidgetRef ref, {bool webOnly = false}) =>
    showAdaptive<void>(context, maxWidth: 680, builder: (_) => _HeldOrders(webOnly: webOnly));

class _HeldOrders extends ConsumerStatefulWidget {
  const _HeldOrders({this.webOnly = false});
  final bool webOnly;
  @override
  ConsumerState<_HeldOrders> createState() => _HeldOrdersState();
}

class _HeldOrdersState extends ConsumerState<_HeldOrders> {
  late bool _webOnly = widget.webOnly;
  String _q = '';

  String _age(int ms) {
    final m = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(ms)).inMinutes;
    if (m < 1) return 'just now';
    if (m < 60) return '$m min';
    return '${m ~/ 60} h ${m % 60} min';
  }

  bool _matches(Order o) {
    if (_webOnly && !o.isWeb) return false;
    final q = _q.trim().toUpperCase().replaceAll('#', '');
    if (q.isEmpty) return true;
    return (o.webCode ?? '').contains(q) ||
        o.tokenLabel.contains(q) ||
        (o.customerName ?? '').toUpperCase().contains(q) ||
        (o.customerPhone ?? '').replaceAll(RegExp(r'\D'), '').contains(q);
  }

  Future<void> _whatsApp(Order o, String template) async {
    final s = ref.read(settingsValueProvider);
    final ok = await openWhatsApp(o.customerPhone ?? '', fillTemplate(template, o, s));
    if (!ok && mounted) toast(context, 'Couldn’t open WhatsApp on this device', error: true);
  }

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    final all = ref.watch(heldOrdersProvider).value ?? const [];
    final online = ref.watch(settingsValueProvider).online;
    final webCount = all.where((o) => o.isWeb).length;
    final held = all.where(_matches).toList();
    return DialogFrame(
      title: _webOnly ? 'Online orders' : 'Held orders',
      subtitle: _webOnly ? 'Website pickups, waiting to be collected' : 'Shared across all tills',
      icon: _webOnly ? Icons.language_rounded : Icons.pause_circle_outline_rounded,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        if (all.length > 3 || webCount > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: Sp.md),
            child: Row(children: [
              Expanded(
                child: TextField(
                  autofocus: _webOnly,
                  onChanged: (v) => setState(() => _q = v),
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    hintText: 'Order ID, name or phone',
                    prefixIcon: Icon(Icons.search_rounded),
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              if (webCount > 0) ...[
                const SizedBox(width: Sp.sm),
                FilterChip(
                  label: Text('Online ($webCount)'),
                  selected: _webOnly,
                  onSelected: (v) => setState(() => _webOnly = v),
                ),
              ],
            ]),
          ),
        if (held.isEmpty)
          all.isEmpty
              ? const EmptyState(icon: Icons.inbox_outlined, title: 'No held orders', message: 'Hold an order (F4) to serve the next customer, then recall it here.')
              : const EmptyState(icon: Icons.search_off_rounded, title: 'No matching orders')
        else
          for (final o in held)
            Padding(
              padding: const EdgeInsets.only(bottom: Sp.sm),
              child: AppCard(
                padding: const EdgeInsets.all(Sp.md),
                child: Row(children: [
                  Container(
                    width: 64,
                    height: 54,
                    decoration: BoxDecoration(color: o.isWeb ? ec.primaryContainer : ec.accentContainer, borderRadius: BorderRadius.circular(Rad.md)),
                    alignment: Alignment.center,
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      if (o.isWeb) Text('WEB', style: context.tt.labelSmall?.copyWith(color: ec.onPrimaryContainer, letterSpacing: 1)),
                      Text(
                        o.isWeb ? '#${o.webCode}' : o.tokenLabel,
                        style: context.tt.titleSmall?.copyWith(color: o.isWeb ? ec.onPrimaryContainer : ec.accent),
                      ),
                    ]),
                  ),
                  const SizedBox(width: Sp.md),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(
                        [
                          o.isWeb ? 'Pickup' : o.type.label,
                          if (o.tableLabel != null) 'Table ${o.tableLabel}',
                          if (o.customerName != null) o.customerName!,
                          if (o.isWeb && (o.customerPhone ?? '').isNotEmpty) o.customerPhone!,
                        ].join(' · '),
                        style: context.tt.titleSmall,
                      ),
                      Text(o.lines.map((l) => '${l.qty}× ${l.name}').join(', '), maxLines: 1, overflow: TextOverflow.ellipsis, style: context.tt.bodySmall),
                      Text('${_age(o.createdAt)} · ${o.staffName} · ${o.deviceCode}${o.kotSent ? ' · sent to bar' : ''}', style: context.tt.labelSmall),
                    ]),
                  ),
                  const SizedBox(width: Sp.sm),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text(rs(o.isWeb ? o.itemsGross : o.total), style: context.tt.titleSmall?.copyWith(fontFeatures: tabular)),
                    const SizedBox(height: 4),
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      if (o.isWeb && (o.customerPhone ?? '').isNotEmpty)
                        PopupMenuButton<String>(
                          tooltip: 'Message on WhatsApp',
                          icon: Icon(Icons.chat_outlined, color: ec.success),
                          onSelected: (t) => _whatsApp(o, t),
                          itemBuilder: (_) => [
                            PopupMenuItem(value: online.placedTemplate, child: const Text('Order placed')),
                            PopupMenuItem(value: online.readyTemplate, child: const Text('Ready for pickup')),
                            PopupMenuItem(value: online.cancelledTemplate, child: const Text('Cancelled')),
                          ],
                        ),
                      IconButton(
                        tooltip: 'Discard',
                        onPressed: () async {
                          final staff = ref.read(sessionProvider);
                          if (staff == null) return;
                          final what = o.isWeb ? 'online order #${o.webCode}' : o.tokenLabel;
                          if (await confirm(
                            context,
                            title: 'Discard $what?',
                            message: o.isWeb
                                ? 'This removes the order from every till. Send the customer the “Cancelled” WhatsApp message if they haven’t been told.'
                                : 'This removes the held order from every till.',
                            confirmLabel: 'Discard',
                            destructive: true,
                          )) {
                            final svc = ref.read(servicesProvider);
                            await svc.pos.discardHeld(o.id, staff);
                            if (o.isWeb) unawaited(svc.webOrders?.cancel(o) ?? svc.webInbox?.markCancelled(o.webCode!));
                          }
                        },
                        icon: Icon(Icons.delete_outline_rounded, color: ec.danger),
                      ),
                      FilledButton(
                        onPressed: () async {
                          final cart = ref.read(cartProvider);
                          if (!cart.isEmpty && cart.heldOrderId != o.id) {
                            final staff = ref.read(sessionProvider);
                            final ok = await confirm(context, title: 'Hold the current order?', message: 'Your current order will be held so you can recall ${o.isWeb ? '#${o.webCode}' : o.tokenLabel}.', confirmLabel: 'Hold & recall');
                            if (!ok || staff == null) return;
                            await ref.read(servicesProvider).pos.hold(cart, staff: staff);
                          }
                          ref.read(cartProvider.notifier).load(CartState.fromOrder(o));
                          if (context.mounted) Navigator.pop(context);
                        },
                        child: const Text('Recall'),
                      ),
                    ]),
                  ]),
                ]),
              ),
            ),
      ]),
    );
  }
}
