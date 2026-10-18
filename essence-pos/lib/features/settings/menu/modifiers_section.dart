import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/db/database.dart';
import '../../../core/models/menu_models.dart';
import '../../../core/models/settings_models.dart';
import '../../../core/services/inventory_service.dart';
import '../../../core/services/repos.dart';
import '../../../shared/common.dart';
import 'menu_widgets.dart';

/// "Optional · pick one", "Required · pick 1–2"…
String selectionRule(int min, int max) {
  if (min <= 0) return max <= 1 ? 'Optional · pick one' : 'Optional · up to $max';
  if (min == max) return min == 1 ? 'Required · pick one' : 'Required · pick $min';
  return 'Required · pick $min–$max';
}

/// Modifier groups (Milk, Extra shot, Sweetness…) with their options.
class ModifiersSection extends ConsumerWidget {
  const ModifiersSection({super.key});

  Future<void> _edit(BuildContext context, WidgetRef ref, ModifierGroup? g) async {
    if (!ref.read(canProvider(Perm.manageMenu))) return;
    final msg = await showAdaptive<String>(context, maxWidth: 680, builder: (_) => ModifierGroupDialog(group: g));
    if (msg != null && context.mounted) toast(context, msg);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canEdit = ref.watch(canProvider(Perm.manageMenu));
    final groupsAsync = ref.watch(modifierGroupsProvider);
    final products = ref.watch(productsProvider).value ?? const <Product>[];
    final stock = {for (final s in ref.watch(stockProvider).value ?? const <StockView>[]) s.item.id: s.item};

    if (groupsAsync.hasError && !groupsAsync.hasValue) {
      return EmptyState(icon: Icons.error_outline_rounded, title: 'Couldn’t load modifiers', message: '${groupsAsync.error}');
    }
    if (!groupsAsync.hasValue) return const PaneLoading();
    final groups = groupsAsync.value!;

    final addBtn = FilledButton.icon(
      onPressed: canEdit ? () => _edit(context, ref, null) : null,
      icon: const Icon(Icons.add_rounded),
      label: const Text('Add group'),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          'Modifier groups',
          subtitle: 'Choices asked when an item is added, e.g. milk, extra shot or sweetness.',
          trailing: groups.isEmpty ? null : addBtn,
        ),
        if (groups.isEmpty)
          AppCard(
            child: EmptyState(
              icon: Icons.tune_rounded,
              title: 'No modifier groups yet',
              message: 'Create groups like “Milk” (Fresh, Oat +Rs 150, Almond +Rs 200) and attach them to products.',
              action: canEdit ? addBtn : null,
            ),
          )
        else
          for (final (i, g) in groups.indexed) ...[
            if (i > 0) const SizedBox(height: Sp.md),
            _GroupCard(
              group: g,
              usedBy: products.where((p) => p.modifierGroupIds.contains(g.id)).length,
              stock: stock,
              onTap: canEdit ? () => _edit(context, ref, g) : null,
            ),
          ],
      ],
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({required this.group, required this.usedBy, required this.stock, required this.onTap});
  final ModifierGroup group;
  final int usedBy;
  final Map<String, StockItem> stock;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    final g = group;
    final options = g.options;
    return AppCard(
      onTap: onTap,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
        Row(children: [
          IconBadge(icon: Icons.tune_rounded, color: ec.primary, size: 36),
          const SizedBox(width: Sp.md),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(g.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.tt.titleSmall),
              const SizedBox(height: 2),
              Text(
                '${selectionRule(g.minSelect, g.maxSelect)} · ${usedBy == 0 ? 'not used yet' : 'used by $usedBy product${usedBy == 1 ? '' : 's'}'}',
                style: context.tt.bodySmall,
              ),
            ]),
          ),
          if (onTap != null) Icon(Icons.edit_outlined, size: 20, color: ec.textFaint),
        ]),
        const SizedBox(height: Sp.md),
        if (options.isEmpty)
          Text('No options — edit the group to add some.', style: context.tt.bodySmall?.copyWith(color: ec.warning))
        else
          Wrap(spacing: Sp.xs + 2, runSpacing: Sp.xs + 2, children: [
            for (final o in options) _OptionChip(option: o, stock: stock),
          ]),
      ]),
    );
  }
}

class _OptionChip extends StatelessWidget {
  const _OptionChip({required this.option, required this.stock});
  final ModifierOption option;
  final Map<String, StockItem> stock;

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    final o = option;
    final item = o.stockItemId == null ? null : stock[o.stockItemId];
    final replaces = o.replacesStockItemId == null ? null : stock[o.replacesStockItemId];
    final tip = item == null
        ? null
        : [
            if (o.qty > 0) 'Uses ${item.fmt(o.qty)} ${item.name}' else 'Uses ${item.name}',
            if (replaces != null) 'instead of ${replaces.name}',
          ].join(' ');
    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: ec.surfaceAlt, borderRadius: BorderRadius.circular(Rad.sm), border: Border.all(color: ec.border)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Flexible(child: Text(o.name, overflow: TextOverflow.ellipsis, style: context.tt.labelMedium?.copyWith(color: ec.text))),
        if (o.delta != 0) ...[
          const SizedBox(width: 6),
          Text(signedRs(o.delta), style: context.tt.labelMedium?.copyWith(color: ec.accent, fontFeatures: tabular)),
        ],
        if (item != null) ...[
          const SizedBox(width: 6),
          Icon(Icons.inventory_2_outlined, size: 14, color: ec.textMuted, semanticLabel: tip),
        ],
      ]),
    );
    return tip == null ? chip : Tooltip(message: tip, child: chip);
  }
}

// ───────────────────────── Editor ─────────────────────────

class _OptionDraft {
  _OptionDraft(ModifierOption? o)
      : id = o?.id ?? newId(),
        name = TextEditingController(text: o?.name ?? ''),
        delta = TextEditingController(text: o == null || o.delta == 0 ? '' : rupeesInput(o.delta)),
        qty = TextEditingController(text: o == null ? '' : qtyInput(o.qty)),
        stockItemId = o?.stockItemId,
        replacesId = o?.replacesStockItemId;
  final String id;
  final TextEditingController name, delta, qty;
  String? stockItemId;
  String? replacesId;

  void dispose() {
    name.dispose();
    delta.dispose();
    qty.dispose();
  }
}

/// Add / edit a modifier group. Pops with a message for the caller to toast.
class ModifierGroupDialog extends ConsumerStatefulWidget {
  const ModifierGroupDialog({super.key, this.group});
  final ModifierGroup? group;

  @override
  ConsumerState<ModifierGroupDialog> createState() => _ModifierGroupDialogState();
}

class _ModifierGroupDialogState extends ConsumerState<ModifierGroupDialog> {
  ModifierGroup? get _g => widget.group;
  bool get _isNew => _g == null;

  late final _name = TextEditingController(text: _g?.name ?? '');
  late int _min = _g?.minSelect ?? 0;
  late int _max = _g?.maxSelect ?? 1;
  late final List<_OptionDraft> _options = [for (final o in _g?.options ?? const <ModifierOption>[]) _OptionDraft(o)];
  String? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (_options.isEmpty) _options.add(_OptionDraft(null));
  }

  @override
  void dispose() {
    _name.dispose();
    for (final o in _options) {
      o.dispose();
    }
    super.dispose();
  }

  void _fail(String m) => setState(() {
        _error = m;
        _saving = false;
      });

  int get _maxLimit => _options.isEmpty ? 1 : _options.length;

  Future<void> _save() async {
    if (_saving) return;
    final name = _name.text.trim();
    if (name.isEmpty) return _fail('Give the group a name, e.g. Milk.');
    final stock = {for (final s in ref.read(stockProvider).value ?? const <StockView>[]) s.item.id: s.item};
    final out = <ModifierOption>[];
    final names = <String>{};
    for (final d in _options) {
      final n = d.name.text.trim();
      if (n.isEmpty && d.delta.text.trim().isEmpty && d.stockItemId == null) continue;
      if (n.isEmpty) return _fail('Every option needs a name.');
      if (!names.add(n.toLowerCase())) return _fail('“$n” is listed twice.');
      final delta = parseSignedRupees(d.delta.text);
      if (delta == null) return _fail('The price for “$n” isn’t a valid amount.');
      var qty = 0.0;
      String? replaces;
      if (d.stockItemId != null) {
        final qt = d.qty.text.trim();
        final q = qt.isEmpty ? 0.0 : double.tryParse(qt);
        if (q == null || q < 0) return _fail('The stock quantity for “$n” isn’t a valid number.');
        qty = q;
        replaces = d.replacesId;
        if (replaces == d.stockItemId) return _fail('“$n” can’t replace the same stock item it uses.');
        if (qty == 0 && replaces == null) {
          final unit = stock[d.stockItemId]?.unit ?? 'units';
          return _fail('Enter how much ($unit) “$n” uses, or pick the item it replaces.');
        }
      }
      out.add(ModifierOption(id: d.id, name: n, delta: delta, stockItemId: d.stockItemId, qty: qty, replacesStockItemId: replaces));
    }
    if (out.isEmpty) return _fail('Add at least one option.');
    final max = _max.clamp(1, out.length);
    if (_min > max) return _fail('Minimum can’t be more than the maximum.');

    setState(() {
      _saving = true;
      _error = null;
    });
    final menu = ref.read(servicesProvider).menu;
    final optionsJson = jsonEncode(out.map((o) => o.toJson()).toList());
    try {
      if (_isNew) {
        final groups = ref.read(modifierGroupsProvider).value ?? const <ModifierGroup>[];
        final sort = groups.isEmpty ? 0 : groups.map((g) => g.sortOrder).reduce((a, b) => a > b ? a : b) + 1;
        await menu.saveModifierGroup(ModifierGroup(
          id: newId(),
          updatedAt: nowMs(),
          deleted: false,
          name: name,
          minSelect: _min,
          maxSelect: max,
          optionsJson: optionsJson,
          sortOrder: sort,
        ));
      } else {
        await menu.saveModifierGroup(_g!.copyWith(name: name, minSelect: _min, maxSelect: max, optionsJson: optionsJson));
      }
      if (mounted) Navigator.pop(context, _isNew ? 'Modifier group $name added' : '$name saved');
    } catch (e) {
      _fail('Couldn’t save: $e');
    }
  }

  Future<void> _delete() async {
    final g = _g!;
    final using = (ref.read(productsProvider).value ?? const <Product>[]).where((p) => p.modifierGroupIds.contains(g.id)).toList();
    final ok = await confirm(
      context,
      title: 'Delete ${g.name}?',
      message: using.isEmpty
          ? 'No products use this group.'
          : 'It is used by ${using.length} product${using.length == 1 ? '' : 's'} '
              '(${using.take(3).map((p) => p.name).join(', ')}${using.length > 3 ? '…' : ''}). '
              'Cashiers will no longer be asked for it.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (!ok || !mounted) return;
    final menu = ref.read(servicesProvider).menu;
    try {
      await menu.deleteModifierGroup(g);
      for (final p in using) {
        await menu.saveProduct(p.copyWith(modifierGroupIdsJson: jsonEncode(p.modifierGroupIds.where((id) => id != g.id).toList())));
      }
      if (mounted) Navigator.pop(context, '${g.name} deleted');
    } catch (e) {
      _fail('Couldn’t delete: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    final stockViews = ref.watch(stockProvider).value ?? const <StockView>[];
    final stock = [for (final s in stockViews) s.item]..sort((a, b) {
        final g = a.groupName.compareTo(b.groupName);
        return g != 0 ? g : a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
    final usedBy = _g == null ? 0 : (ref.watch(productsProvider).value ?? const <Product>[]).where((p) => p.modifierGroupIds.contains(_g!.id)).length;
    final maxLimit = _maxLimit;
    if (_max > maxLimit) _max = maxLimit;
    if (_min > maxLimit) _min = maxLimit;

    Widget stepper(String label, int value, int min, int max, ValueChanged<int> onChanged) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: context.tt.labelMedium?.copyWith(color: ec.textMuted)),
            const SizedBox(height: Sp.xs),
            QtyStepper(value: value, min: min, max: max, onChanged: onChanged),
          ],
        );

    return SaveShortcut(
      onSave: _save,
      child: DialogFrame(
        title: _isNew ? 'New modifier group' : 'Edit modifier group',
        subtitle: _isNew ? null : (usedBy == 0 ? 'Not used by any product yet' : 'Used by $usedBy product${usedBy == 1 ? '' : 's'}'),
        icon: Icons.tune_rounded,
        actions: [
          if (!_isNew) DangerTextButton(label: 'Delete', onPressed: _saving ? null : _delete),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(onPressed: _saving ? null : _save, child: Text(_saving ? 'Saving…' : (_isNew ? 'Add group' : 'Save'))),
        ],
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
          TextField(
            controller: _name,
            autofocus: _isNew,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(labelText: 'Group name', hintText: 'e.g. Milk, Extra shot, Sweetness'),
          ),
          const SizedBox(height: Sp.lg),
          Wrap(spacing: Sp.xl, runSpacing: Sp.md, crossAxisAlignment: WrapCrossAlignment.end, children: [
            stepper('Minimum', _min, 0, maxLimit, (v) => setState(() {
                  _min = v;
                  if (_max < v) _max = v;
                })),
            stepper('Maximum', _max, 1, maxLimit, (v) => setState(() {
                  _max = v;
                  if (_min > v) _min = v;
                })),
            Padding(padding: const EdgeInsets.only(bottom: 10), child: Pill(selectionRule(_min, _max), tone: _min > 0 ? Tone.warning : Tone.neutral)),
          ]),
          const SizedBox(height: Sp.xs),
          Text('Minimum 1 or more makes the choice required before the item can be added.', style: context.tt.bodySmall),
          const SizedBox(height: Sp.xl),
          const FieldLabel(
            'Options',
            hint: 'Price is added to the item, e.g. +150 for oat milk. Link stock so sales deduct it: '
                '“Oat milk” uses 200 ml of Oat milk and replaces Fresh milk in the recipe. '
                'Leave the quantity empty to use the replaced item’s recipe amount.',
          ),
          for (final (i, d) in _options.indexed)
            _OptionEditor(
              key: ValueKey(d.id),
              index: i,
              draft: d,
              stock: stock,
              canRemove: _options.length > 1,
              onRemove: () => setState(() {
                _options.remove(d);
                d.dispose();
              }),
              onChanged: () => setState(() {}),
            ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => setState(() => _options.add(_OptionDraft(null))),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add option'),
            ),
          ),
          if (stock.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: Sp.xs),
              child: Text('Add stock items in Inventory to link options to stock.', style: context.tt.bodySmall),
            ),
          if (_error != null) ...[const SizedBox(height: Sp.md), InlineNote(_error!)],
        ]),
      ),
    );
  }
}

class _OptionEditor extends StatelessWidget {
  const _OptionEditor({
    super.key,
    required this.index,
    required this.draft,
    required this.stock,
    required this.canRemove,
    required this.onRemove,
    required this.onChanged,
  });
  final int index;
  final _OptionDraft draft;
  final List<StockItem> stock;
  final bool canRemove;
  final VoidCallback onRemove;
  final VoidCallback onChanged;

  List<DropdownMenuItem<String?>> _items(String? current, {String noneLabel = 'Not linked'}) {
    final ids = stock.map((s) => s.id).toSet();
    return [
      DropdownMenuItem<String?>(value: null, child: Text(noneLabel)),
      for (final s in stock)
        DropdownMenuItem<String?>(
          value: s.id,
          child: Text('${s.name} (${s.unit})${s.active ? '' : ' · inactive'}', overflow: TextOverflow.ellipsis),
        ),
      if (current != null && !ids.contains(current)) DropdownMenuItem<String?>(value: current, child: const Text('Removed stock item')),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    const dense = InputDecoration(isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12));
    final item = draft.stockItemId == null ? null : stock.where((s) => s.id == draft.stockItemId).firstOrNull;

    final nameField = TextField(
      controller: draft.name,
      textCapitalization: TextCapitalization.words,
      textInputAction: TextInputAction.next,
      decoration: dense.copyWith(labelText: 'Option ${index + 1}', hintText: 'e.g. Oat milk'),
      onChanged: (_) => onChanged(),
    );
    final priceField = TextField(
      controller: draft.delta,
      keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
      inputFormatters: signedMoneyFormatters,
      textInputAction: TextInputAction.next,
      decoration: dense.copyWith(labelText: '± Rs', hintText: '0'),
    );
    final stockField = DropdownButtonFormField<String?>(
      initialValue: draft.stockItemId,
      isExpanded: true,
      decoration: dense.copyWith(labelText: 'Uses stock item', prefixIcon: const Icon(Icons.inventory_2_outlined, size: 18)),
      items: _items(draft.stockItemId),
      onChanged: (v) {
        draft.stockItemId = v;
        if (v == null) {
          draft.replacesId = null;
          draft.qty.clear();
        }
        onChanged();
      },
    );

    return Container(
      margin: const EdgeInsets.only(bottom: Sp.sm),
      padding: const EdgeInsets.fromLTRB(Sp.md, Sp.md, Sp.xs, Sp.md),
      decoration: BoxDecoration(color: ec.surfaceAlt.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(Rad.md), border: Border.all(color: ec.border)),
      child: LayoutBuilder(builder: (context, c) {
        final narrow = c.maxWidth < 440;
        final removeBtn = IconButton(
          tooltip: 'Remove option',
          onPressed: canRemove ? onRemove : null,
          icon: const Icon(Icons.remove_circle_outline_rounded),
        );
        final children = <Widget>[
          Row(children: [
            Expanded(child: nameField),
            const SizedBox(width: Sp.sm),
            SizedBox(width: narrow ? 96 : 120, child: priceField),
            removeBtn,
          ]),
          const SizedBox(height: Sp.sm),
          Padding(padding: const EdgeInsets.only(right: Sp.sm), child: stockField),
        ];
        if (item != null || draft.stockItemId != null) {
          final unit = item?.unit ?? '';
          final qtyField = TextField(
            controller: draft.qty,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: qtyFormatters,
            decoration: dense.copyWith(labelText: 'Quantity', suffixText: unit, hintText: draft.replacesId == null ? null : 'same'),
            onChanged: (_) => onChanged(),
          );
          final replacesField = DropdownButtonFormField<String?>(
            key: ValueKey('rep-${draft.stockItemId}'),
            initialValue: draft.replacesId,
            isExpanded: true,
            decoration: dense.copyWith(labelText: 'Replaces (optional)'),
            items: _items(draft.replacesId, noneLabel: 'Nothing — adds to recipe'),
            onChanged: (v) {
              draft.replacesId = v;
              onChanged();
            },
          );
          children.add(const SizedBox(height: Sp.sm));
          children.add(Padding(
            padding: const EdgeInsets.only(right: Sp.sm),
            child: narrow
                ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [qtyField, const SizedBox(height: Sp.sm), replacesField])
                : Row(children: [SizedBox(width: 150, child: qtyField), const SizedBox(width: Sp.sm), Expanded(child: replacesField)]),
          ));
          final replaced = draft.replacesId == null ? null : stock.where((s) => s.id == draft.replacesId).firstOrNull;
          final q = double.tryParse(draft.qty.text.trim()) ?? 0;
          final itemName = item?.name ?? 'this item';
          children.add(Padding(
            padding: const EdgeInsets.only(top: Sp.xs, right: Sp.sm),
            child: Text(
              replaced != null
                  ? (q > 0
                      ? 'Each sale uses ${formatQty(q, unit)} of $itemName instead of the recipe’s ${replaced.name}.'
                      : 'Each sale uses $itemName in place of the recipe’s ${replaced.name}, same amount.')
                  : (q > 0 ? 'Each sale also uses ${formatQty(q, unit)} of $itemName.' : 'Enter the quantity used per item.'),
              style: context.tt.bodySmall,
            ),
          ));
        }
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: children);
      }),
    );
  }
}
