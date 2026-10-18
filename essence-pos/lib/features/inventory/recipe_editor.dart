import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme/icons.dart';
import '../../app/theme/tokens.dart';
import '../../core/db/database.dart';
import '../../core/models/menu_models.dart';
import '../../core/models/settings_models.dart';
import '../../core/money.dart';
import '../../core/services/inventory_service.dart';
import '../../shared/common.dart';
import 'inventory_common.dart';

// ───────────────────────── Cost / margin helpers ─────────────────────────

/// Gross margin (0..1) of [cost] paisa against [price] paisa.
double? marginOf(int price, double? cost) => cost == null || price <= 0 ? null : (price - cost) / price;

String marginText(double? m) => m == null ? '—' : '${(m * 100).round()}%';

Tone marginTone(double? m) {
  if (m == null) return Tone.neutral;
  if (m >= 0.65) return Tone.success;
  if (m >= 0.45) return Tone.warning;
  return Tone.danger;
}

/// Ingredient cost to two decimals: "Rs 38.40".
String costText(double paisa) => rs(paisa.round());

double itemsCost(Iterable<RecipeItem> items, Map<String, StockItem> stock, [double factor = 1]) {
  var c = 0.0;
  for (final it in items) {
    final si = stock[it.stockItemId];
    if (si != null) c += si.costOf(it.qty * factor);
  }
  return c;
}

String sizeLabel(ProductSize s) => s.label.isEmpty ? s.code : s.label;

// ───────────────────────── Editor ─────────────────────────

Future<void> showRecipeEditor(BuildContext context, Product product) =>
    showAdaptive<void>(context, maxWidth: 760, builder: (_) => _RecipeEditor(product: product));

class _Row {
  _Row({this.stockItemId, String qty = ''}) : qty = TextEditingController(text: qty);
  String? stockItemId;
  final TextEditingController qty;
}

class _Draft {
  _Draft({required this.enabled, required this.rows});
  bool enabled;
  final List<_Row> rows;
}

class _RecipeEditor extends ConsumerStatefulWidget {
  const _RecipeEditor({required this.product});
  final Product product;

  @override
  ConsumerState<_RecipeEditor> createState() => _RecipeEditorState();
}

class _RecipeEditorState extends ConsumerState<_RecipeEditor> {
  late final List<ProductSize> _sizes = widget.product.sizes;
  final _drafts = <String, _Draft>{};
  late final Map<String, Recipe> _existing;
  String _code = '';
  StaffMember? _approver;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final recipes = ref.read(recipesProvider).value ?? const <Recipe>[];
    _existing = {for (final r in recipes) if (r.productId == widget.product.id) r.sizeCode: r};
    List<_Row> rowsOf(Recipe? r) => [for (final it in r?.items ?? const <RecipeItem>[]) _Row(stockItemId: it.stockItemId, qty: numText(it.qty))];
    final base = _existing[''];
    _drafts[''] = _Draft(enabled: true, rows: rowsOf(base));
    if (_drafts['']!.rows.isEmpty) _drafts['']!.rows.add(_Row());
    for (final s in _sizes) {
      final r = _existing[s.code];
      _drafts[s.code] = _Draft(enabled: r != null, rows: rowsOf(r));
    }
  }

  @override
  void dispose() {
    for (final d in _drafts.values) {
      for (final r in d.rows) {
        r.qty.dispose();
      }
    }
    super.dispose();
  }

  bool get _canEdit => _approver != null || ref.read(canProvider(Perm.manageInventory));

  Future<void> _unlock() async {
    final s = await inventoryApproval(context, ref, 'Edit recipe for ${widget.product.name}');
    if (s != null && mounted) setState(() => _approver = s);
  }

  /// Valid recipe items of a draft (merged by stock item); throws a message on invalid rows.
  List<RecipeItem> _collect(_Draft d, String where) {
    final out = <String, double>{};
    for (final r in d.rows) {
      final q = parseQty(r.qty.text);
      if (r.stockItemId == null && r.qty.text.trim().isEmpty) continue;
      if (r.stockItemId == null) throw 'Pick an ingredient for every row ($where)';
      if (q == null || q <= 0) throw 'Enter a quantity above zero for every ingredient ($where)';
      out[r.stockItemId!] = (out[r.stockItemId!] ?? 0) + q;
    }
    return [for (final e in out.entries) RecipeItem(stockItemId: e.key, qty: e.value)];
  }

  bool _same(Recipe? r, List<RecipeItem> items) {
    if (r == null) return items.isEmpty;
    final a = r.items;
    if (a.length != items.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].stockItemId != items[i].stockItemId || (a[i].qty - items[i].qty).abs() > 1e-9) return false;
    }
    return true;
  }

  Future<void> _save() async {
    final p = widget.product;
    final Map<String, List<RecipeItem>> plan = {};
    try {
      plan[''] = _collect(_drafts['']!, 'All sizes');
      for (final s in _sizes) {
        final d = _drafts[s.code]!;
        plan[s.code] = d.enabled ? _collect(d, sizeLabel(s)) : const [];
      }
    } on String catch (e) {
      setState(() => _error = e);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final svc = ref.read(servicesProvider);
      var changes = 0;
      for (final e in plan.entries) {
        final existing = _existing[e.key];
        if (_same(existing, e.value)) continue;
        if (e.value.isEmpty) {
          if (existing != null) {
            // No public delete on InventoryService: soft-delete the recipe row (falls back to the base recipe / no deduction).
            await svc.db.saveSynced(svc.db.recipes, existing.copyWith(deleted: true, updatedAt: nowMs()));
            changes++;
          }
        } else {
          await svc.inventory.saveRecipe(p.id, e.key, e.value);
          changes++;
        }
      }
      if (!mounted) return;
      Navigator.pop(context);
      toast(context, changes == 0 ? 'No changes to ${p.name}' : 'Recipe saved for ${p.name}', icon: Icons.menu_book_outlined);
    } catch (e) {
      if (mounted) setState(() => _error = 'Couldn’t save: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _customise(ProductSize s) {
    final f = sizeFactor(s.code);
    final d = _drafts[s.code]!;
    final old = [...d.rows];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final r in old) {
        r.qty.dispose();
      }
    });
    d.rows
      ..clear()
      ..addAll([
        for (final r in _drafts['']!.rows)
          if (r.stockItemId != null) _Row(stockItemId: r.stockItemId, qty: numText((parseQty(r.qty.text) ?? 0) * f, decimals: 1)),
      ]);
    if (d.rows.isEmpty) d.rows.add(_Row());
    setState(() => d.enabled = true);
  }

  /// Live items of a draft (ignores incomplete rows) for cost display.
  List<RecipeItem> _liveItems(_Draft d) => [
        for (final r in d.rows)
          if (r.stockItemId != null && (parseQty(r.qty.text) ?? 0) > 0) RecipeItem(stockItemId: r.stockItemId!, qty: parseQty(r.qty.text)!),
      ];

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    final p = widget.product;
    ref.watch(canProvider(Perm.manageInventory));
    final editable = _canEdit;
    final views = ref.watch(stockProvider).value ?? const <StockView>[];
    final stock = {for (final v in views) v.item.id: v.item};
    final options = views.map((v) => v.item).toList()
      ..sort((a, b) {
        final g = a.groupName.compareTo(b.groupName);
        return g != 0 ? g : a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
    final size = _sizes.where((s) => s.code == _code).firstOrNull;
    final draft = _drafts[_code]!;

    return DialogFrame(
      title: 'Recipe',
      subtitle: '${p.name} · ${rs(p.price)}${_sizes.isEmpty ? '' : ' base'}',
      icon: iconFor(p.icon),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(editable ? 'Cancel' : 'Close')),
        if (editable)
          FilledButton.icon(
            onPressed: _busy ? null : _save,
            icon: _busy ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.check_rounded),
            label: const Text('Save recipe'),
          )
        else
          FilledButton.icon(onPressed: _unlock, icon: const Icon(Icons.lock_open_rounded), label: const Text('Edit recipe')),
      ],
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        if (!editable)
          Padding(
            padding: const EdgeInsets.only(bottom: Sp.md),
            child: Container(
              padding: const EdgeInsets.all(Sp.md),
              decoration: BoxDecoration(color: ec.infoContainer, borderRadius: BorderRadius.circular(Rad.md)),
              child: Row(children: [
                Icon(Icons.visibility_outlined, color: ec.info, size: 20),
                const SizedBox(width: Sp.sm),
                Expanded(child: Text('View only. Editing recipes needs manager approval.', style: context.tt.bodySmall?.copyWith(color: ec.info))),
              ]),
            ),
          ),
        if (_sizes.isNotEmpty) ...[
          ChipBar(children: [
            ChoiceChip(
              label: const Text('All sizes'),
              selected: _code == '',
              onSelected: (_) => setState(() => _code = ''),
            ),
            for (final s in _sizes)
              ChoiceChip(
                avatar: _drafts[s.code]!.enabled ? Icon(Icons.tune_rounded, size: 16, color: ec.accent) : null,
                label: Text(sizeLabel(s)),
                selected: _code == s.code,
                onSelected: (_) => setState(() => _code = s.code),
              ),
          ]),
          const SizedBox(height: Sp.sm),
          Text(
            _code == ''
                ? 'Base recipe for every size. Without an override, Small uses ×0.8 and Large ×1.3 automatically.'
                : (draft.enabled ? '${sizeLabel(size!)} has its own recipe (overrides All sizes).' : '${sizeLabel(size!)} uses the All sizes recipe ×${numText(sizeFactor(_code))}.'),
            style: context.tt.bodySmall,
          ),
          const SizedBox(height: Sp.md),
        ],
        if (size != null && !draft.enabled)
          _ScaledPreview(
            items: _liveItems(_drafts['']!),
            factor: sizeFactor(size.code),
            stock: stock,
            onCustomise: editable ? () => _customise(size) : null,
            sizeName: sizeLabel(size),
          )
        else ...[
          if (draft.rows.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: Sp.md),
              child: Text('No ingredients yet.', style: context.tt.bodyMedium?.copyWith(color: ec.textMuted)),
            ),
          for (final r in draft.rows)
            _IngredientRow(
              key: ObjectKey(r),
              row: r,
              options: options,
              stock: stock,
              enabled: editable,
              onChanged: () => setState(() {}),
              onRemove: () {
                setState(() => draft.rows.remove(r));
                WidgetsBinding.instance.addPostFrameCallback((_) => r.qty.dispose());
              },
            ),
          if (editable)
            Wrap(spacing: Sp.sm, runSpacing: Sp.sm, children: [
              OutlinedButton.icon(
                onPressed: options.isEmpty ? null : () => setState(() => draft.rows.add(_Row())),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add ingredient'),
              ),
              if (size != null)
                TextButton.icon(
                  onPressed: () => setState(() => draft.enabled = false),
                  icon: const Icon(Icons.undo_rounded),
                  label: const Text('Use All sizes recipe'),
                ),
            ]),
          if (options.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: Sp.sm),
              child: Text('Add stock items on the Stock tab first.', style: context.tt.bodySmall?.copyWith(color: ec.warning)),
            ),
        ],
        const SizedBox(height: Sp.lg),
        _CostSummary(product: p, sizes: _sizes, code: _code, drafts: _drafts, liveItems: _liveItems, stock: stock),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: Sp.md),
            child: Text(_error!, style: context.tt.bodySmall?.copyWith(color: ec.danger, fontWeight: FontWeight.w600)),
          ),
      ]),
    );
  }
}

class _IngredientRow extends StatelessWidget {
  const _IngredientRow({
    super.key,
    required this.row,
    required this.options,
    required this.stock,
    required this.enabled,
    required this.onChanged,
    required this.onRemove,
  });
  final _Row row;
  final List<StockItem> options;
  final Map<String, StockItem> stock;
  final bool enabled;
  final VoidCallback onChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    final item = row.stockItemId == null ? null : stock[row.stockItemId];
    final missing = row.stockItemId != null && item == null;
    final q = parseQty(row.qty.text);
    final cost = item != null && q != null ? item.costOf(q) : null;
    final phone = context.isPhone;

    final picker = DropdownButtonFormField<String>(
      initialValue: item?.id,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: 'Ingredient',
        isDense: true,
        errorText: missing ? 'This stock item was deleted' : null,
      ),
      items: [
        for (final o in options)
          DropdownMenuItem(
            value: o.id,
            child: Row(children: [
              Icon(iconFor(o.icon, fallback: Icons.inventory_2_outlined), size: 18, color: ec.accent),
              const SizedBox(width: Sp.sm),
              Flexible(child: Text(o.name, overflow: TextOverflow.ellipsis)),
              if (!o.active) ...[const SizedBox(width: Sp.xs), Text('(inactive)', style: context.tt.bodySmall)],
            ]),
          ),
      ],
      onChanged: enabled
          ? (v) {
              row.stockItemId = v;
              onChanged();
            }
          : null,
    );
    final qty = TextField(
      controller: row.qty,
      enabled: enabled,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: decimalInput,
      onChanged: (_) => onChanged(),
      style: context.tt.bodyLarge?.copyWith(fontFeatures: tabular),
      decoration: InputDecoration(labelText: 'Qty', isDense: true, suffixText: item?.unit ?? ''),
    );
    final costLabel = SizedBox(
      width: 84,
      child: Text(
        cost == null ? '—' : costText(cost),
        textAlign: TextAlign.right,
        style: context.tt.bodyMedium?.copyWith(fontFeatures: tabular, color: ec.textMuted),
      ),
    );
    final remove = IconButton(
      tooltip: 'Remove ingredient',
      onPressed: enabled ? onRemove : null,
      icon: const Icon(Icons.remove_circle_outline_rounded),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: Sp.md),
      child: phone
          ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              picker,
              const SizedBox(height: Sp.sm),
              Row(children: [Expanded(child: qty), const SizedBox(width: Sp.sm), costLabel, remove]),
            ])
          : Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Expanded(flex: 3, child: picker),
              const SizedBox(width: Sp.sm),
              SizedBox(width: 140, child: qty),
              const SizedBox(width: Sp.sm),
              costLabel,
              remove,
            ]),
    );
  }
}

class _ScaledPreview extends StatelessWidget {
  const _ScaledPreview({required this.items, required this.factor, required this.stock, required this.onCustomise, required this.sizeName});
  final List<RecipeItem> items;
  final double factor;
  final Map<String, StockItem> stock;
  final VoidCallback? onCustomise;
  final String sizeName;

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    return Container(
      padding: const EdgeInsets.all(Sp.md),
      decoration: BoxDecoration(color: ec.surfaceAlt, borderRadius: BorderRadius.circular(Rad.md), border: Border.all(color: ec.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        if (items.isEmpty)
          Text('The All sizes recipe has no ingredients yet.', style: context.tt.bodyMedium?.copyWith(color: ec.textMuted))
        else
          for (final it in items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(children: [
                Icon(iconFor(stock[it.stockItemId]?.icon, fallback: Icons.inventory_2_outlined), size: 18, color: ec.accent),
                const SizedBox(width: Sp.sm),
                Expanded(child: Text(stock[it.stockItemId]?.name ?? 'Deleted item', overflow: TextOverflow.ellipsis)),
                Text(
                  stock[it.stockItemId] == null ? numText(it.qty * factor) : stock[it.stockItemId]!.fmt(it.qty * factor),
                  style: context.tt.bodyMedium?.copyWith(fontFeatures: tabular),
                ),
              ]),
            ),
        if (onCustomise != null) ...[
          const SizedBox(height: Sp.sm),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(onPressed: onCustomise, icon: const Icon(Icons.tune_rounded), label: Text('Customise for $sizeName')),
          ),
        ],
      ]),
    );
  }
}

class _CostSummary extends StatelessWidget {
  const _CostSummary({required this.product, required this.sizes, required this.code, required this.drafts, required this.liveItems, required this.stock});
  final Product product;
  final List<ProductSize> sizes;
  final String code;
  final Map<String, _Draft> drafts;
  final List<RecipeItem> Function(_Draft) liveItems;
  final Map<String, StockItem> stock;

  double? _costFor(String sizeCode) {
    final d = drafts[sizeCode];
    if (sizeCode.isNotEmpty && d != null && d.enabled) {
      final items = liveItems(d);
      return items.isEmpty ? null : itemsCost(items, stock);
    }
    final base = liveItems(drafts['']!);
    if (base.isEmpty) return null;
    return itemsCost(base, stock, sizeCode.isEmpty ? 1 : sizeFactor(sizeCode));
  }

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    final rows = <(String, int, double?, bool)>[
      if (sizes.isEmpty) ('Per item', product.price, _costFor(''), true),
      for (final s in sizes) (sizeLabel(s), product.price + s.delta, _costFor(s.code), code == '' || code == s.code),
    ];
    return Container(
      padding: const EdgeInsets.all(Sp.md),
      decoration: BoxDecoration(color: ec.beige.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(Rad.md), border: Border.all(color: ec.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Expanded(child: Text('INGREDIENT COST', style: context.tt.labelSmall?.copyWith(color: ec.textMuted))),
          SizedBox(width: 80, child: Text('PRICE', textAlign: TextAlign.right, style: context.tt.labelSmall?.copyWith(color: ec.textMuted))),
          SizedBox(width: 80, child: Text('COST', textAlign: TextAlign.right, style: context.tt.labelSmall?.copyWith(color: ec.textMuted))),
          SizedBox(width: 72, child: Text('MARGIN', textAlign: TextAlign.right, style: context.tt.labelSmall?.copyWith(color: ec.textMuted))),
        ]),
        const SizedBox(height: Sp.xs),
        for (final (label, price, cost, focus) in rows)
          Opacity(
            opacity: focus ? 1 : 0.5,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(children: [
                Expanded(child: Text(label, style: context.tt.titleSmall, overflow: TextOverflow.ellipsis)),
                SizedBox(width: 80, child: Text(rs(price), textAlign: TextAlign.right, style: context.tt.bodyMedium?.copyWith(fontFeatures: tabular))),
                SizedBox(width: 80, child: Text(cost == null ? '—' : costText(cost), textAlign: TextAlign.right, style: context.tt.bodyMedium?.copyWith(fontFeatures: tabular))),
                SizedBox(
                  width: 72,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Pill(marginText(marginOf(price, cost)), tone: marginTone(marginOf(price, cost)), dense: true),
                  ),
                ),
              ]),
            ),
          ),
      ]),
    );
  }
}
