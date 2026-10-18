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
import '../../core/tax/tax_engine.dart';
import '../../shared/approval.dart';
import '../../shared/common.dart';

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

Future<void> showHeldOrders(BuildContext context, WidgetRef ref) =>
    showAdaptive<void>(context, maxWidth: 640, builder: (_) => const _HeldOrders());

class _HeldOrders extends ConsumerWidget {
  const _HeldOrders();

  String _age(int ms) {
    final m = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(ms)).inMinutes;
    if (m < 1) return 'just now';
    if (m < 60) return '$m min';
    return '${m ~/ 60} h ${m % 60} min';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ec = context.ec;
    final held = ref.watch(heldOrdersProvider).value ?? const [];
    return DialogFrame(
      title: 'Held orders',
      subtitle: 'Shared across all tills',
      icon: Icons.pause_circle_outline_rounded,
      child: held.isEmpty
          ? const EmptyState(icon: Icons.inbox_outlined, title: 'No held orders', message: 'Hold an order (F4) to serve the next customer, then recall it here.')
          : Column(children: [
              for (final o in held)
                Padding(
                  padding: const EdgeInsets.only(bottom: Sp.sm),
                  child: AppCard(
                    padding: const EdgeInsets.all(Sp.md),
                    child: Row(children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(color: ec.accentContainer, borderRadius: BorderRadius.circular(Rad.md)),
                        alignment: Alignment.center,
                        child: Text(o.tokenLabel, style: context.tt.titleSmall?.copyWith(color: ec.accent)),
                      ),
                      const SizedBox(width: Sp.md),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(
                            [o.type.label, if (o.tableLabel != null) 'Table ${o.tableLabel}', if (o.customerName != null) o.customerName!].join(' · '),
                            style: context.tt.titleSmall,
                          ),
                          Text(o.lines.map((l) => '${l.qty}× ${l.name}').join(', '), maxLines: 1, overflow: TextOverflow.ellipsis, style: context.tt.bodySmall),
                          Text('${_age(o.createdAt)} · ${o.staffName} · ${o.deviceCode}${o.kotSent ? ' · sent to bar' : ''}', style: context.tt.labelSmall),
                        ]),
                      ),
                      const SizedBox(width: Sp.sm),
                      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Text(rs(o.total), style: context.tt.titleSmall?.copyWith(fontFeatures: tabular)),
                        const SizedBox(height: 4),
                        Row(mainAxisSize: MainAxisSize.min, children: [
                          IconButton(
                            tooltip: 'Discard',
                            onPressed: () async {
                              final staff = ref.read(sessionProvider);
                              if (staff == null) return;
                              if (await confirm(context, title: 'Discard ${o.tokenLabel}?', message: 'This removes the held order from every till.', confirmLabel: 'Discard', destructive: true)) {
                                await ref.read(servicesProvider).pos.discardHeld(o.id, staff);
                              }
                            },
                            icon: Icon(Icons.delete_outline_rounded, color: ec.danger),
                          ),
                          FilledButton(
                            onPressed: () async {
                              final cart = ref.read(cartProvider);
                              if (!cart.isEmpty && cart.heldOrderId != o.id) {
                                final staff = ref.read(sessionProvider);
                                final ok = await confirm(context, title: 'Hold the current order?', message: 'Your current order will be held so you can recall ${o.tokenLabel}.', confirmLabel: 'Hold & recall');
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
