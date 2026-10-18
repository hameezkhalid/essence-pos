import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme/icons.dart';
import '../../app/theme/tokens.dart';
import '../../core/db/database.dart';
import '../../core/models/menu_models.dart';
import '../../core/money.dart';
import '../../core/services/inventory_service.dart';
import '../../core/services/repos.dart';
import '../../shared/common.dart';
import 'inventory_common.dart';

// ───────────────────────── Entry points ─────────────────────────

Future<void> showStockIn(BuildContext context, WidgetRef ref, StockItem item, {double? suggestedQty}) async {
  final approver = await inventoryApproval(context, ref, 'Receive stock for ${item.name}');
  if (approver == null || !context.mounted) return;
  await showAdaptive<void>(context, builder: (_) => _StockInDialog(item: item, approver: approver, suggestedQty: suggestedQty));
}

Future<void> showWastage(BuildContext context, WidgetRef ref, StockItem item) async {
  final approver = await inventoryApproval(context, ref, 'Record wastage of ${item.name}');
  if (approver == null || !context.mounted) return;
  await showAdaptive<void>(context, builder: (_) => _WastageDialog(item: item, approver: approver));
}

Future<void> showCount(BuildContext context, WidgetRef ref, StockItem item) async {
  final approver = await inventoryApproval(context, ref, 'Count ${item.name}');
  if (approver == null || !context.mounted) return;
  await showAdaptive<void>(context, builder: (_) => _CountDialog(item: item, approver: approver));
}

Future<void> showItemEditor(BuildContext context, WidgetRef ref, {StockItem? item}) async {
  final approver = await inventoryApproval(context, ref, item == null ? 'Add a stock item' : 'Edit ${item.name}');
  if (approver == null || !context.mounted) return;
  await showAdaptive<void>(context, maxWidth: 620, builder: (_) => _ItemEditor(item: item, approver: approver));
}

Future<void> showHistory(BuildContext context, StockItem item) =>
    showAdaptive<void>(context, maxWidth: 680, builder: (_) => _HistoryDialog(item: item));

/// Live quantity of [item] from the stock stream (falls back to [fallback]).
double _liveQty(WidgetRef ref, StockItem item, [double fallback = 0]) {
  final list = ref.watch(stockProvider).value;
  if (list == null) return fallback;
  for (final v in list) {
    if (v.item.id == item.id) return v.qty;
  }
  return fallback;
}

StockItem _liveItem(WidgetRef ref, StockItem item) {
  final list = ref.watch(stockProvider).value;
  if (list == null) return item;
  for (final v in list) {
    if (v.item.id == item.id) return v.item;
  }
  return item;
}

Widget _busyButton({required bool busy, required VoidCallback? onPressed, required IconData icon, required String label, Color? color}) =>
    FilledButton.icon(
      style: color == null ? null : FilledButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white),
      onPressed: busy ? null : onPressed,
      icon: busy ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : Icon(icon),
      label: Text(label),
    );

// ───────────────────────── Stock in ─────────────────────────

class _StockInDialog extends ConsumerStatefulWidget {
  const _StockInDialog({required this.item, required this.approver, this.suggestedQty});
  final StockItem item;
  final StaffMember approver;
  final double? suggestedQty;

  @override
  ConsumerState<_StockInDialog> createState() => _StockInDialogState();
}

class _StockInDialogState extends ConsumerState<_StockInDialog> {
  late final _qty = TextEditingController();
  late final _cost = TextEditingController(text: widget.item.costPerUnit > 0 ? rupeeText(widget.item.costPerUnit) : '');
  final _note = TextEditingController();
  late bool _big = widget.item.unit != 'pcs';
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final s = widget.suggestedQty;
    if (s != null && s > 0) _qty.text = numText(_big ? s / 1000 : s);
  }

  @override
  void dispose() {
    _qty.dispose();
    _cost.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final item = widget.item;
    final base = QtyInput.baseOf(_qty, item.unit, _big);
    if (base == null || base <= 0) {
      setState(() => _error = 'Enter the quantity received');
      return;
    }
    final costText = _cost.text.trim();
    final cost = costText.isEmpty ? null : parseRupees(costText);
    if (costText.isNotEmpty && (cost == null || cost < 0)) {
      setState(() => _error = 'Enter a valid cost');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final note = _note.text.trim();
      await ref.read(servicesProvider).inventory.stockIn(
            item,
            base,
            unitCost: cost,
            note: withApprovalNote(ref, widget.approver, note.isEmpty ? null : note),
            staff: widget.approver,
            deviceId: deviceIdOf(ref),
          );
      if (!mounted) return;
      Navigator.pop(context);
      toast(context, 'Received ${item.fmt(base)} of ${item.name}', icon: Icons.local_shipping_outlined);
    } catch (e) {
      if (mounted) setState(() => _error = 'Couldn’t save: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = _liveItem(ref, widget.item);
    final current = _liveQty(ref, item);
    final base = QtyInput.baseOf(_qty, item.unit, _big);
    final cost = parseRupees(_cost.text);
    final total = base != null && cost != null ? base / item.perBig * cost : null;
    return DialogFrame(
      title: 'Stock in',
      subtitle: 'Receive a delivery · ${item.name}',
      icon: Icons.local_shipping_outlined,
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        _busyButton(busy: _busy, onPressed: _save, icon: Icons.add_rounded, label: 'Receive stock'),
      ],
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        QtyInput(
          controller: _qty,
          unit: item.unit,
          big: _big,
          autofocus: true,
          label: 'Quantity received',
          onChanged: (_) => setState(() {}),
          onBigChanged: (b) => setState(() => _big = b),
        ),
        const SizedBox(height: Sp.md),
        TextField(
          controller: _cost,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: decimalInput,
          style: context.tt.bodyLarge?.copyWith(fontFeatures: tabular),
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            labelText: 'Cost per ${item.bigUnit}',
            prefixText: 'Rs ',
            suffixText: '/ ${item.bigUnit}',
            helperText: item.costPerUnit > 0 ? 'Last cost ${rs(item.costPerUnit)} / ${item.bigUnit}' : 'Updates the item cost',
          ),
        ),
        const SizedBox(height: Sp.md),
        TextField(
          controller: _note,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(labelText: 'Supplier / note', hintText: 'e.g. Bean Bros, invoice 2231'),
        ),
        const SizedBox(height: Sp.lg),
        LevelPreview(
          item: item,
          current: current,
          next: base == null ? null : shownQty(current) + base,
          extra: total == null
              ? null
              : Row(children: [
                  Text('Delivery value', style: context.tt.bodyMedium?.copyWith(color: context.ec.textMuted)),
                  const Spacer(),
                  Text(rs(total.round()), style: context.tt.titleSmall?.copyWith(fontFeatures: tabular)),
                ]),
        ),
        if (current < 0)
          Padding(
            padding: const EdgeInsets.only(top: Sp.sm),
            child: Text(
              'Recorded level is below zero (${item.fmt(current)}). Do a count after receiving to correct it.',
              style: context.tt.bodySmall?.copyWith(color: context.ec.warning),
            ),
          ),
        if (_error != null) _ErrorText(_error!),
      ]),
    );
  }
}

// ───────────────────────── Wastage ─────────────────────────

const _wasteReasons = ['Spilled', 'Expired', 'Damaged', 'Other'];

class _WastageDialog extends ConsumerStatefulWidget {
  const _WastageDialog({required this.item, required this.approver});
  final StockItem item;
  final StaffMember approver;

  @override
  ConsumerState<_WastageDialog> createState() => _WastageDialogState();
}

class _WastageDialogState extends ConsumerState<_WastageDialog> {
  final _qty = TextEditingController();
  final _note = TextEditingController();
  late bool _big = false;
  String _reason = _wasteReasons.first;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _qty.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final item = widget.item;
    final base = QtyInput.baseOf(_qty, item.unit, _big);
    if (base == null || base <= 0) {
      setState(() => _error = 'Enter the quantity wasted');
      return;
    }
    final detail = _note.text.trim();
    if (_reason == 'Other' && detail.isEmpty) {
      setState(() => _error = 'Add a short note for “Other”');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final note = detail.isEmpty ? _reason : '$_reason — $detail';
      await ref.read(servicesProvider).inventory.wastage(
            item,
            base,
            note: withApprovalNote(ref, widget.approver, note),
            staff: widget.approver,
            deviceId: deviceIdOf(ref),
          );
      if (!mounted) return;
      Navigator.pop(context);
      toast(context, 'Recorded ${item.fmt(base)} of ${item.name} as wastage', icon: Icons.delete_outline_rounded);
    } catch (e) {
      if (mounted) setState(() => _error = 'Couldn’t save: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    final item = _liveItem(ref, widget.item);
    final current = _liveQty(ref, item);
    final base = QtyInput.baseOf(_qty, item.unit, _big);
    final tooMuch = base != null && base > shownQty(current) + 0.0001;
    return DialogFrame(
      title: 'Wastage',
      subtitle: item.name,
      icon: Icons.delete_outline_rounded,
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        _busyButton(busy: _busy, onPressed: _save, icon: Icons.remove_rounded, label: 'Record wastage', color: ec.danger),
      ],
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        QtyInput(
          controller: _qty,
          unit: item.unit,
          big: _big,
          autofocus: true,
          label: 'Quantity wasted',
          onChanged: (_) => setState(() {}),
          onBigChanged: (b) => setState(() => _big = b),
        ),
        const SizedBox(height: Sp.lg),
        Text('Reason', style: context.tt.labelLarge),
        const SizedBox(height: Sp.sm),
        Wrap(spacing: Sp.sm, runSpacing: Sp.sm, children: [
          for (final r in _wasteReasons)
            ChoiceChip(
              label: Text(r),
              selected: _reason == r,
              onSelected: (_) => setState(() => _reason = r),
            ),
        ]),
        const SizedBox(height: Sp.md),
        TextField(
          controller: _note,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(labelText: _reason == 'Other' ? 'What happened? (required)' : 'Note (optional)'),
        ),
        const SizedBox(height: Sp.lg),
        LevelPreview(
          item: item,
          current: current,
          next: base == null ? null : current - base,
          extra: base == null
              ? null
              : Row(children: [
                  Text('Value lost', style: context.tt.bodyMedium?.copyWith(color: ec.textMuted)),
                  const Spacer(),
                  Text(rs(item.costOf(base).round()), style: context.tt.titleSmall?.copyWith(fontFeatures: tabular, color: ec.danger)),
                ]),
        ),
        if (tooMuch)
          Padding(
            padding: const EdgeInsets.only(top: Sp.sm),
            child: Text('That’s more than the recorded stock — consider a count instead.', style: context.tt.bodySmall?.copyWith(color: ec.warning)),
          ),
        if (_error != null) _ErrorText(_error!),
      ]),
    );
  }
}

// ───────────────────────── Count ─────────────────────────

class _CountDialog extends ConsumerStatefulWidget {
  const _CountDialog({required this.item, required this.approver});
  final StockItem item;
  final StaffMember approver;

  @override
  ConsumerState<_CountDialog> createState() => _CountDialogState();
}

class _CountDialogState extends ConsumerState<_CountDialog> {
  final _qty = TextEditingController();
  late bool _big = widget.item.unit != 'pcs';
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _qty.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final item = widget.item;
    final counted = QtyInput.baseOf(_qty, item.unit, _big);
    if (counted == null || counted < 0) {
      setState(() => _error = 'Enter the quantity you counted');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(servicesProvider).inventory.count(item, counted, staff: widget.approver, deviceId: deviceIdOf(ref));
      if (!mounted) return;
      Navigator.pop(context);
      toast(context, '${item.name} set to ${item.fmt(counted)}', icon: Icons.fact_check_outlined);
    } catch (e) {
      if (mounted) setState(() => _error = 'Couldn’t save: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    final item = _liveItem(ref, widget.item);
    final current = _liveQty(ref, item);
    final counted = QtyInput.baseOf(_qty, item.unit, _big);
    final diff = counted == null ? null : counted - current;
    final diffTone = diff == null || diff.abs() < 0.0001 ? Tone.neutral : (diff > 0 ? Tone.success : Tone.danger);
    return DialogFrame(
      title: 'Stock count',
      subtitle: item.name,
      icon: Icons.fact_check_outlined,
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        _busyButton(busy: _busy, onPressed: _save, icon: Icons.check_rounded, label: 'Save count'),
      ],
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('Weigh or count what’s on the shelf and enter the total.', style: context.tt.bodyMedium?.copyWith(color: ec.textMuted)),
        const SizedBox(height: Sp.lg),
        QtyInput(
          controller: _qty,
          unit: item.unit,
          big: _big,
          autofocus: true,
          label: 'Counted quantity',
          onChanged: (_) => setState(() {}),
          onBigChanged: (b) => setState(() => _big = b),
        ),
        const SizedBox(height: Sp.lg),
        Container(
          padding: const EdgeInsets.all(Sp.md),
          decoration: BoxDecoration(color: ec.beige.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(Rad.md), border: Border.all(color: ec.border)),
          child: Row(children: [
            Expanded(child: StatBlock(label: 'System level', value: current < 0 ? signedQty(item, current) : item.fmt(current))),
            Expanded(child: StatBlock(label: 'Counted', value: counted == null ? '—' : item.fmt(counted))),
            Expanded(
              child: StatBlock(
                label: 'Difference',
                value: diff == null ? '—' : (diff.abs() < 0.0001 ? 'No change' : signedQty(item, diff)),
                tone: diffTone,
                alignEnd: true,
              ),
            ),
          ]),
        ),
        if (diff != null && diff.abs() >= 0.0001)
          Padding(
            padding: const EdgeInsets.only(top: Sp.sm),
            child: Text(
              '${diff > 0 ? 'Gain' : 'Loss'} worth ${rs(item.costOf(diff.abs()).round())} will be recorded as a count adjustment.',
              style: context.tt.bodySmall,
            ),
          ),
        if (_error != null) _ErrorText(_error!),
      ]),
    );
  }
}

// ───────────────────────── Add / edit item ─────────────────────────

class _ItemEditor extends ConsumerStatefulWidget {
  const _ItemEditor({this.item, required this.approver});
  final StockItem? item;
  final StaffMember approver;

  @override
  ConsumerState<_ItemEditor> createState() => _ItemEditorState();
}

class _ItemEditorState extends ConsumerState<_ItemEditor> {
  late final StockItem? _i = widget.item;
  late final _name = TextEditingController(text: _i?.name ?? '');
  late final _group = TextEditingController(text: _i?.groupName ?? '');
  late String _unit = _i?.unit ?? 'g';
  late final _reorder = TextEditingController(text: _i == null ? '' : numText(_i.reorderLevel / perBigOf(_i.unit)));
  late final _par = TextEditingController(text: _i == null ? '' : numText(_i.parLevel / perBigOf(_i.unit)));
  late final _cost = TextEditingController(text: _i == null || _i.costPerUnit == 0 ? '' : rupeeText(_i.costPerUnit));
  final _opening = TextEditingController();
  late String _icon = _i?.icon ?? 'inventory';
  late bool _active = _i?.active ?? true;
  bool _unitLocked = false;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final i = _i;
    if (i != null) {
      ref.read(servicesProvider).inventory.watchMovements(stockItemId: i.id, limit: 1).first.then((m) {
        if (mounted && m.isNotEmpty) setState(() => _unitLocked = true);
      });
    }
  }

  @override
  void dispose() {
    for (final c in [_name, _group, _reorder, _par, _cost, _opening]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) return setState(() => _error = 'Give the item a name');
    final group = _group.text.trim().isEmpty ? 'General' : _group.text.trim();
    final per = perBigOf(_unit);
    final reorder = parseQty(_reorder.text) ?? 0;
    final par = parseQty(_par.text) ?? 0;
    if (reorder < 0 || par < 0) return setState(() => _error = 'Levels can’t be negative');
    if (par > 0 && par < reorder) return setState(() => _error = 'Par (target) level should be at or above the reorder level');
    final costText = _cost.text.trim();
    final cost = costText.isEmpty ? 0 : parseRupees(costText);
    if (cost == null || cost < 0) return setState(() => _error = 'Enter a valid cost');
    final opening = parseQty(_opening.text);
    if (opening != null && opening < 0) return setState(() => _error = 'Opening stock can’t be negative');

    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final svc = ref.read(servicesProvider);
      final now = nowMs();
      final item = StockItem(
        id: _i?.id ?? newId(),
        updatedAt: now,
        deleted: false,
        name: name,
        groupName: group,
        unit: _unit,
        reorderLevel: reorder * per,
        parLevel: par * per,
        costPerUnit: cost,
        icon: _icon,
        active: _active,
      );
      await svc.inventory.saveItem(item);
      if (_i == null && opening != null && opening > 0) {
        // Opening balance for a new item (InventoryService has no public "opening" move).
        await svc.db.saveSynced(
          svc.db.stockMovements,
          StockMovement(
            id: newId(),
            updatedAt: now,
            deleted: false,
            stockItemId: item.id,
            qty: opening * per,
            type: 'opening',
            note: withApprovalNote(ref, widget.approver, 'Opening stock'),
            unitCost: cost > 0 ? cost : null,
            staffId: widget.approver.id,
            staffName: widget.approver.name,
            deviceId: deviceIdOf(ref),
            createdAt: now,
          ),
        );
      }
      if (!mounted) return;
      Navigator.pop(context);
      toast(context, _i == null ? '$name added' : '$name saved');
    } catch (e) {
      if (mounted) setState(() => _error = 'Couldn’t save: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete() async {
    final i = _i;
    if (i == null) return;
    final recipes = ref.read(recipesProvider).value ?? const <Recipe>[];
    final used = recipes.where((r) => r.items.any((x) => x.stockItemId == i.id)).length;
    final ok = await confirm(
      context,
      title: 'Delete ${i.name}?',
      message: [
        'It will be removed from the stock list and its movement history hidden.',
        if (used > 0) 'It is used in $used recipe${used == 1 ? '' : 's'} — those ingredients will no longer be deducted.',
        'Tip: switch it to inactive instead if you may stock it again.',
      ].join('\n\n'),
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (!ok || !mounted) return;
    try {
      await ref.read(servicesProvider).inventory.deleteItem(i);
      if (!mounted) return;
      Navigator.pop(context);
      toast(context, '${i.name} deleted', icon: Icons.delete_outline_rounded);
    } catch (e) {
      if (mounted) toast(context, 'Couldn’t delete: $e', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    final phone = context.isPhone;
    final groups = <String>{
      for (final v in ref.watch(stockProvider).value ?? const <StockView>[]) v.item.groupName,
    }.toList()
      ..sort();
    final big = bigUnitOf(_unit);
    final editing = _i != null;

    Widget pair(Widget a, Widget b) => phone
        ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [a, const SizedBox(height: Sp.md), b])
        : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: a), const SizedBox(width: Sp.md), Expanded(child: b)]);

    TextField numField(TextEditingController c, String label, {String? helper, String? prefix, String? suffix}) => TextField(
          controller: c,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: decimalInput,
          style: context.tt.bodyLarge?.copyWith(fontFeatures: tabular),
          decoration: InputDecoration(labelText: label, helperText: helper, prefixText: prefix, suffixText: suffix),
        );

    return DialogFrame(
      title: editing ? 'Edit stock item' : 'New stock item',
      subtitle: editing ? _i.name : 'Ingredients, packaging or anything you count',
      icon: iconFor(_icon, fallback: Icons.inventory_2_outlined),
      actions: [
        if (editing)
          TextButton.icon(
            onPressed: _busy ? null : _delete,
            style: TextButton.styleFrom(foregroundColor: ec.danger),
            icon: const Icon(Icons.delete_outline_rounded),
            label: const Text('Delete'),
          ),
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        _busyButton(busy: _busy, onPressed: _save, icon: Icons.check_rounded, label: editing ? 'Save' : 'Add item'),
      ],
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        TextField(
          controller: _name,
          autofocus: !editing,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Name', hintText: 'e.g. Espresso beans'),
        ),
        const SizedBox(height: Sp.md),
        TextField(
          controller: _group,
          textCapitalization: TextCapitalization.words,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(labelText: 'Group', hintText: 'Pick below or type a new one'),
        ),
        if (groups.isNotEmpty) ...[
          const SizedBox(height: Sp.sm),
          Wrap(spacing: Sp.xs, runSpacing: Sp.xs, children: [
            for (final g in groups)
              ChoiceChip(
                label: Text(g),
                visualDensity: VisualDensity.compact,
                selected: _group.text.trim() == g,
                onSelected: (_) => setState(() => _group.text = g),
              ),
          ]),
        ],
        const SizedBox(height: Sp.lg),
        Row(children: [
          Expanded(child: Text('Base unit', style: context.tt.labelLarge)),
          if (_unitLocked)
            Tooltip(
              message: 'This item already has stock movements, so its unit can’t change.',
              child: Pill('Locked', icon: Icons.lock_outline_rounded, dense: true),
            ),
        ]),
        const SizedBox(height: Sp.sm),
        SegmentedButton<String>(
          showSelectedIcon: false,
          segments: [
            ButtonSegment(value: 'g', label: Text(phone ? 'g' : 'Grams (g)')),
            ButtonSegment(value: 'ml', label: Text(phone ? 'ml' : 'Millilitres (ml)')),
            ButtonSegment(value: 'pcs', label: Text(phone ? 'pcs' : 'Pieces')),
          ],
          selected: {_unit},
          onSelectionChanged: _unitLocked ? null : (s) => setState(() => _unit = s.first),
        ),
        Padding(
          padding: const EdgeInsets.only(top: Sp.xs),
          child: Text(
            _unit == 'pcs' ? 'Recipes use whole or part pieces.' : 'Recipes use $_unit; deliveries and levels are entered in $big.',
            style: context.tt.bodySmall,
          ),
        ),
        const SizedBox(height: Sp.lg),
        pair(
          numField(_reorder, 'Reorder at', suffix: big, helper: 'Flag as low at this level'),
          numField(_par, 'Par (target) level', suffix: big, helper: 'Suggested orders top up to this'),
        ),
        const SizedBox(height: Sp.md),
        pair(
          numField(_cost, 'Cost per $big', prefix: 'Rs ', suffix: '/ $big', helper: 'Used for stock value & recipe costs'),
          editing
              ? const SizedBox.shrink()
              : numField(_opening, 'Opening stock (optional)', suffix: big, helper: 'What you have on hand now'),
        ),
        const SizedBox(height: Sp.lg),
        Text('Icon', style: context.tt.labelLarge),
        const SizedBox(height: Sp.sm),
        Wrap(spacing: Sp.sm, runSpacing: Sp.sm, children: [
          for (final k in stockIconKeys)
            Tooltip(
              message: k,
              child: InkWell(
                borderRadius: BorderRadius.circular(Rad.sm),
                onTap: () => setState(() => _icon = k),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: _icon == k ? ec.primaryContainer : ec.surfaceAlt,
                    borderRadius: BorderRadius.circular(Rad.sm),
                    border: Border.all(color: _icon == k ? ec.primary : ec.border, width: _icon == k ? 1.6 : 1),
                  ),
                  child: Icon(iconFor(k), size: 22, color: _icon == k ? ec.onPrimaryContainer : ec.textMuted),
                ),
              ),
            ),
        ]),
        const SizedBox(height: Sp.md),
        LabeledSwitch(
          title: 'Active',
          subtitle: 'Inactive items are hidden from reorder lists and the stock value',
          value: _active,
          onChanged: (v) => setState(() => _active = v),
        ),
        if (_error != null) _ErrorText(_error!),
      ]),
    );
  }
}

// ───────────────────────── History ─────────────────────────

class _HistoryDialog extends ConsumerWidget {
  const _HistoryDialog({required this.item});
  final StockItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ec = context.ec;
    final live = _liveItem(ref, item);
    final current = _liveQty(ref, live);
    final async = ref.watch(itemMovementsProvider(item.id));
    final moves = async.value ?? const <StockMovement>[];

    // Last 7 days summary.
    final since = DateTime.now().subtract(const Duration(days: 7)).millisecondsSinceEpoch;
    double used = 0, wasted = 0, received = 0;
    for (final m in moves) {
      if (m.createdAt < since) continue;
      switch (m.type) {
        case 'sale' || 'refund' || 'void':
          used -= m.qty;
        case 'wastage':
          wasted -= m.qty;
        case 'stockIn':
          received += m.qty;
      }
    }

    // Balance after each movement, walking back from the current level.
    final balances = <double>[];
    var bal = current;
    for (final m in moves) {
      balances.add(bal);
      bal -= m.qty;
    }

    return DialogFrame(
      title: 'History',
      subtitle: '${live.name} · ${live.groupName}',
      icon: Icons.history_rounded,
      scroll: false,
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(
          padding: const EdgeInsets.all(Sp.md),
          decoration: BoxDecoration(color: ec.beige.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(Rad.md), border: Border.all(color: ec.border)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Wrap(spacing: Sp.xl, runSpacing: Sp.sm, children: [
              StatBlock(label: 'On hand', value: live.fmt(shownQty(current)), tone: StockView(live, current).state.tone),
              StatBlock(label: 'Used · 7 days', value: live.fmt(used < 0 ? 0 : used)),
              StatBlock(label: 'Received · 7 days', value: live.fmt(received)),
              StatBlock(label: 'Wasted · 7 days', value: live.fmt(wasted), tone: wasted > 0 ? Tone.danger : null),
            ]),
            const SizedBox(height: Sp.sm),
            LevelBar(view: StockView(live, current)),
          ]),
        ),
        const SizedBox(height: Sp.md),
        Flexible(
          child: async.isLoading && !async.hasValue
              ? const Padding(padding: EdgeInsets.all(Sp.xl), child: Center(child: CircularProgressIndicator()))
              : moves.isEmpty
                  ? const EmptyState(icon: Icons.history_rounded, title: 'No movements yet', message: 'Sales, deliveries, wastage and counts will appear here.')
                  : ListView.separated(
                      shrinkWrap: true,
                      itemCount: moves.length,
                      separatorBuilder: (_, _) => Divider(height: 1, color: ec.border),
                      itemBuilder: (context, i) => MovementTile(movement: moves[i], item: live, balanceAfter: balances[i], showItem: false),
                    ),
        ),
      ]),
    );
  }
}

/// One stock movement row (History dialog and Movements tab).
class MovementTile extends StatelessWidget {
  const MovementTile({super.key, required this.movement, required this.item, this.balanceAfter, this.showItem = true, this.showDate = true});
  final StockMovement movement;
  final StockItem? item;
  final double? balanceAfter;
  final bool showItem;
  final bool showDate;

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    final m = movement;
    final t = MovementType.of(m.type);
    final unit = item?.unit ?? 'pcs';
    final meta = [
      if (m.staffName != null && m.staffName!.isNotEmpty) m.staffName!,
      showDate ? dayTimeOf(m.createdAt) : timeOf(m.createdAt),
    ].join(' · ');
    final value = m.type == 'stockIn' && m.unitCost != null && item != null ? rs((m.qty / item!.perBig * m.unitCost!).round()) : null;
    final qtyColor = m.qty > 0 ? ec.success : (m.qty < 0 ? (m.type == 'wastage' ? ec.danger : ec.text) : ec.textMuted);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Sp.sm + 2),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        MovementBadge(t),
        const SizedBox(width: Sp.md),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Wrap(spacing: Sp.sm, runSpacing: 2, crossAxisAlignment: WrapCrossAlignment.center, children: [
              if (showItem) Text(item?.name ?? 'Deleted item', style: context.tt.titleSmall),
              Pill(t.label, tone: t.tone, dense: true),
            ]),
            if (m.note != null && m.note!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(m.note!, style: context.tt.bodySmall?.copyWith(color: ec.text), maxLines: 2, overflow: TextOverflow.ellipsis),
              ),
            Padding(padding: const EdgeInsets.only(top: 2), child: Text(meta, style: context.tt.bodySmall)),
          ]),
        ),
        const SizedBox(width: Sp.sm),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(signedQty(item, m.qty, unit: unit), style: context.tt.titleSmall?.copyWith(fontFeatures: tabular, color: qtyColor)),
          if (value != null) Text(value, style: context.tt.bodySmall?.copyWith(fontFeatures: tabular)),
          if (balanceAfter != null && item != null)
            Text('→ ${item!.fmt(shownQty(balanceAfter!))}', style: context.tt.bodySmall?.copyWith(fontFeatures: tabular, color: ec.textFaint)),
        ]),
      ]),
    );
  }
}

class _ErrorText extends StatelessWidget {
  const _ErrorText(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: Sp.md),
        child: Row(children: [
          Icon(Icons.error_outline_rounded, size: 18, color: context.ec.danger),
          const SizedBox(width: Sp.sm),
          Expanded(child: Text(text, style: context.tt.bodySmall?.copyWith(color: context.ec.danger, fontWeight: FontWeight.w600))),
        ]),
      );
}
