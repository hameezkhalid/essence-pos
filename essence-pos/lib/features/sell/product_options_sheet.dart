import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme/icons.dart';
import '../../app/theme/tokens.dart';
import '../../core/db/database.dart';
import '../../core/models/menu_models.dart';
import '../../core/models/order_models.dart';
import '../../core/models/settings_models.dart';
import '../../core/money.dart';
import '../../core/tax/tax_engine.dart';
import '../../shared/approval.dart';
import '../../shared/common.dart';

/// Size, extras, quantity and note for a product — for a new line, or editing [editLine].
Future<void> showProductOptions(BuildContext context, WidgetRef ref, {Product? product, OrderLine? editLine}) {
  final p = product ?? (ref.read(productsProvider).value ?? const []).where((x) => x.id == editLine?.productId).firstOrNull;
  if (p == null && editLine == null) return Future.value();
  return showAdaptive<void>(context, maxWidth: 560, builder: (_) => _OptionsSheet(product: p, line: editLine));
}

class _OptionsSheet extends ConsumerStatefulWidget {
  const _OptionsSheet({this.product, this.line});
  final Product? product;
  final OrderLine? line;
  @override
  ConsumerState<_OptionsSheet> createState() => _OptionsSheetState();
}

class _OptionsSheetState extends ConsumerState<_OptionsSheet> {
  ProductSize? _size;
  final Map<String, List<ModifierOption>> _picked = {};
  int _qty = 1;
  late final TextEditingController _note;
  Discount? _discount;

  bool get _editing => widget.line != null;

  @override
  void initState() {
    super.initState();
    final l = widget.line;
    final sizes = widget.product?.sizes ?? const <ProductSize>[];
    if (l != null) {
      _size = l.size;
      _qty = l.qty;
      _discount = l.discount;
      for (final m in l.modifiers) {
        _picked.putIfAbsent(m.groupId, () => []).add(m.option);
      }
    } else if (sizes.isNotEmpty) {
      _size = sizes.firstWhere((s) => s.delta == 0, orElse: () => sizes.first);
    }
    _note = TextEditingController(text: l?.note ?? '');
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  List<ModifierGroup> get _groups {
    final map = ref.read(modifierGroupMapProvider);
    return [
      for (final id in widget.product?.modifierGroupIds ?? const <String>[])
        if (map[id] != null) map[id]!,
    ];
  }

  int get _unit {
    final base = widget.product?.price ?? widget.line!.basePrice;
    return base + (_size?.delta ?? 0) + _picked.values.expand((e) => e).fold<int>(0, (a, o) => a + o.delta);
  }

  List<SelectedModifier> _selected(List<ModifierGroup> groups) => [
        for (final g in groups)
          for (final o in _picked[g.id] ?? const <ModifierOption>[]) SelectedModifier(groupId: g.id, groupName: g.name, option: o),
      ];

  String? _missingRequired(List<ModifierGroup> groups) {
    for (final g in groups) {
      if ((_picked[g.id]?.length ?? 0) < g.minSelect) return 'Choose ${g.name.toLowerCase()}';
    }
    return null;
  }

  void _toggle(ModifierGroup g, ModifierOption o) {
    setState(() {
      final list = _picked.putIfAbsent(g.id, () => []);
      final has = list.any((x) => x.id == o.id);
      if (g.maxSelect <= 1) {
        list.clear();
        if (!has) list.add(o);
      } else if (has) {
        list.removeWhere((x) => x.id == o.id);
      } else if (list.length < g.maxSelect) {
        list.add(o);
      } else {
        toast(context, 'Up to ${g.maxSelect} ${g.name.toLowerCase()}');
      }
    });
  }

  Future<void> _pickDiscount() async {
    final s = ref.read(settingsValueProvider).discounts;
    final gross = _unit * _qty;
    final d = await showModalBottomSheet<Discount?>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Sp.xl, 0, Sp.xl, Sp.xl),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('Item discount', style: ctx.tt.headlineSmall),
            const SizedBox(height: Sp.md),
            Wrap(spacing: Sp.sm, runSpacing: Sp.sm, children: [
              for (final p in s.presets) ActionChip(label: Text(p.label ?? p.display), onPressed: () => Navigator.pop(ctx, p)),
              ActionChip(label: const Text('Free (100%)'), onPressed: () => Navigator.pop(ctx, const Discount.percent(10000, label: 'Free'))),
              if (_discount != null) ActionChip(avatar: const Icon(Icons.close_rounded, size: 16), label: const Text('Remove'), onPressed: () => Navigator.pop(ctx, const Discount.amount(0))),
            ]),
          ]),
        ),
      ),
    );
    if (d == null || !mounted) return;
    if (d.value == 0) {
      setState(() => _discount = null);
      return;
    }
    final bp = gross == 0 ? 0 : (d.apply(gross) * 10000 / gross).round();
    if (bp > s.cashierMaxBp) {
      final ok = await requirePermission(context, ref, Perm.discountOverride, why: 'Discount of ${pct(bp)} is above the cashier limit (${pct(s.cashierMaxBp)})');
      if (ok == null) return;
    }
    setState(() => _discount = d);
  }

  void _save() {
    final groups = _groups;
    final missing = _missingRequired(groups);
    if (missing != null) {
      toast(context, missing, error: true);
      return;
    }
    final cart = ref.read(cartProvider.notifier);
    final note = _note.text.trim().isEmpty ? null : _note.text.trim();
    if (_editing) {
      final l = widget.line!;
      cart.replaceLine(l.copyWith(
        qty: _qty,
        size: _size,
        modifiers: _selected(groups),
        note: note,
        clearNote: note == null,
        discount: _discount,
        clearDiscount: _discount == null,
      ));
    } else {
      cart.add(widget.product!, size: _size, modifiers: _selected(groups), qty: _qty, note: note);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    final p = widget.product;
    final sizes = p?.sizes ?? const <ProductSize>[];
    final groups = _groups;
    final title = p?.name ?? widget.line!.name;
    final locked = (widget.line?.sentQty ?? 0) > 0;
    return DialogFrame(
      title: title,
      subtitle: p?.description ?? (rs(_unit)),
      actions: [
        if (_editing)
          TextButton.icon(
            onPressed: locked
                ? null
                : () {
                    ref.read(cartProvider.notifier).remove(widget.line!.key);
                    Navigator.pop(context);
                  },
            style: TextButton.styleFrom(foregroundColor: ec.danger),
            icon: const Icon(Icons.delete_outline_rounded),
            label: const Text('Remove'),
          ),
        FilledButton(
          onPressed: _save,
          child: Text('${_editing ? 'Update' : 'Add to order'} · ${rs(_unit * _qty - (_discount?.apply(_unit * _qty) ?? 0))}', style: const TextStyle(fontFeatures: tabular)),
        ),
      ],
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        if (p != null)
          Row(children: [
            IconBadge(icon: iconFor(p.icon), color: Color(p.color), size: 52),
            const SizedBox(width: Sp.md),
            Expanded(child: Text(rs(_unit), style: context.tt.headlineSmall?.copyWith(fontFamily: 'Inter', fontWeight: FontWeight.w700, color: ec.accent, fontFeatures: tabular))),
            QtyStepper(value: _qty, min: locked ? widget.line!.sentQty : 1, onChanged: (v) => setState(() => _qty = v)),
          ]),
        if (sizes.isNotEmpty) ...[
          const SizedBox(height: Sp.lg),
          Text('Size', style: context.tt.titleSmall),
          const SizedBox(height: Sp.sm),
          Wrap(spacing: Sp.sm, runSpacing: Sp.sm, children: [
            for (final s in sizes)
              ChoiceChip(
                label: Text(s.delta == 0 ? s.label : '${s.label}  ${s.delta > 0 ? '+' : '−'}${num0(s.delta.abs())}'),
                selected: _size?.code == s.code,
                onSelected: (_) => setState(() => _size = s),
              ),
          ]),
        ],
        for (final g in groups) ...[
          const SizedBox(height: Sp.lg),
          Row(children: [
            Text(g.name, style: context.tt.titleSmall),
            const SizedBox(width: Sp.sm),
            if (g.minSelect > 0) const Pill('Required', tone: Tone.warning, dense: true) else Text(g.maxSelect > 1 ? 'up to ${g.maxSelect}' : 'optional', style: context.tt.labelSmall),
          ]),
          const SizedBox(height: Sp.sm),
          Wrap(spacing: Sp.sm, runSpacing: Sp.sm, children: [
            for (final o in g.options)
              FilterChip(
                label: Text(o.delta == 0 ? o.name : '${o.name}  +${num0(o.delta)}'),
                selected: _picked[g.id]?.any((x) => x.id == o.id) ?? false,
                onSelected: (_) => _toggle(g, o),
              ),
          ]),
        ],
        const SizedBox(height: Sp.lg),
        TextField(
          controller: _note,
          maxLines: 1,
          decoration: const InputDecoration(labelText: 'Note for the bar (optional)', hintText: 'e.g. extra hot, no sugar', prefixIcon: Icon(Icons.sticky_note_2_outlined)),
        ),
        if (_editing) ...[
          const SizedBox(height: Sp.md),
          Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickDiscount,
                icon: const Icon(Icons.percent_rounded),
                label: Text(_discount == null ? 'Discount this item' : 'Discount: ${_discount!.label ?? _discount!.display}'),
              ),
            ),
          ]),
        ],
      ]),
    );
  }
}
