import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/theme/icons.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/db/database.dart';
import '../../../core/models/menu_models.dart';
import '../../../core/money.dart';
import '../../../core/services/inventory_service.dart';
import '../../../core/services/repos.dart';
import '../../../shared/common.dart';
import 'menu_widgets.dart';

class _SizeDraft {
  _SizeDraft({String code = '', String label = '', String delta = ''})
      : code = TextEditingController(text: code),
        label = TextEditingController(text: label),
        delta = TextEditingController(text: delta);
  static int _seq = 0;
  final key = _seq++;
  final TextEditingController code, label, delta;
  void dispose() {
    code.dispose();
    label.dispose();
    delta.dispose();
  }
}

/// Add / edit a product. Pops with a confirmation message for the caller to toast.
class ProductDialog extends ConsumerStatefulWidget {
  const ProductDialog({super.key, this.product, this.initialCategoryId});
  final Product? product;
  final String? initialCategoryId;

  @override
  ConsumerState<ProductDialog> createState() => _ProductDialogState();
}

class _ProductDialogState extends ConsumerState<ProductDialog> {
  Product? get _p => widget.product;
  bool get _isNew => _p == null;

  late final _name = TextEditingController(text: _p?.name ?? '');
  late final _desc = TextEditingController(text: _p?.description ?? '');
  late final _price = TextEditingController(text: _p == null ? '' : rupeesInput(_p!.price));
  final _sizes = <_SizeDraft>[];
  String? _categoryId;
  late String _icon;
  late int _color;
  late Set<String> _groups;
  late bool _taxExempt, _favourite, _active, _available;

  /// For new products: follow the category's icon/colour until the user picks their own.
  bool _styleTouched = false;
  String? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = _p;
    final cats = ref.read(categoriesProvider).value ?? const <MenuCategory>[];
    _categoryId = p?.categoryId ?? widget.initialCategoryId ?? cats.where((c) => c.active).firstOrNull?.id ?? cats.firstOrNull?.id;
    final cat = cats.where((c) => c.id == _categoryId).firstOrNull;
    _icon = p?.icon ?? cat?.icon ?? 'coffee';
    _color = p?.color ?? cat?.color ?? swatches.first;
    _groups = {...?p?.modifierGroupIds};
    _taxExempt = p?.taxExempt ?? false;
    _favourite = p?.favourite ?? false;
    _active = p?.active ?? true;
    _available = p?.available ?? true;
    for (final s in p?.sizes ?? const <ProductSize>[]) {
      _sizes.add(_SizeDraft(code: s.code, label: s.label, delta: s.delta == 0 ? '0' : (s.delta > 0 ? '+${rupeesInput(s.delta)}' : rupeesInput(s.delta))));
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _desc.dispose();
    _price.dispose();
    for (final s in _sizes) {
      s.dispose();
    }
    super.dispose();
  }

  void _addSize([String code = '', String label = '', String delta = '']) => setState(() => _sizes.add(_SizeDraft(code: code, label: label, delta: delta)));

  void _useSml() => setState(() {
        _sizes
          ..add(_SizeDraft(code: 'S', label: 'Small', delta: '-100'))
          ..add(_SizeDraft(code: 'M', label: 'Medium', delta: '0'))
          ..add(_SizeDraft(code: 'L', label: 'Large', delta: '+150'));
      });

  void _removeSize(_SizeDraft s) => setState(() {
        _sizes.remove(s);
        s.dispose();
      });

  /// Sizes as typed, or an error message.
  (List<ProductSize>?, String?) _parseSizes() {
    final out = <ProductSize>[];
    final seen = <String>{};
    for (final d in _sizes) {
      final code = d.code.text.trim().toUpperCase();
      final label = d.label.text.trim();
      final deltaText = d.delta.text.trim();
      if (code.isEmpty && label.isEmpty && deltaText.isEmpty) continue;
      if (code.isEmpty) return (null, 'Each size needs a short code, e.g. S, M or L.');
      if (!seen.add(code)) return (null, 'Size code “$code” is used twice.');
      final delta = parseSignedRupees(deltaText);
      if (delta == null) return (null, 'Price difference for size $code isn’t a valid amount.');
      out.add(ProductSize(code: code, label: label.isEmpty ? code : label, delta: delta));
    }
    return (out, null);
  }

  void _fail(String msg) => setState(() {
        _error = msg;
        _saving = false;
      });

  Future<void> _save() async {
    if (_saving) return;
    final name = _name.text.trim();
    final cats = ref.read(categoriesProvider).value ?? const <MenuCategory>[];
    if (name.isEmpty) return _fail('Give the product a name.');
    if (_categoryId == null || !cats.any((c) => c.id == _categoryId)) return _fail('Choose a category.');
    final price = parseRupees(_price.text);
    if (price == null || price < 0) return _fail('Enter a valid base price in rupees.');
    final (sizes, sizeErr) = _parseSizes();
    if (sizeErr != null) return _fail(sizeErr);
    for (final s in sizes!) {
      if (price + s.delta < 0) return _fail('Size ${s.code} would cost less than Rs 0.');
    }
    setState(() {
      _saving = true;
      _error = null;
    });

    final groupIds = _groups.where(ref.read(modifierGroupMapProvider).containsKey).toList();
    final sizesJson = jsonEncode(sizes.map((s) => s.toJson()).toList());
    final groupsJson = jsonEncode(groupIds);
    final desc = _desc.text.trim();
    final menu = ref.read(servicesProvider).menu;
    try {
      if (_isNew) {
        final siblings = (ref.read(productsProvider).value ?? const <Product>[]).where((p) => p.categoryId == _categoryId);
        final sort = siblings.isEmpty ? 0 : siblings.map((p) => p.sortOrder).reduce((a, b) => a > b ? a : b) + 1;
        await menu.saveProduct(Product(
          id: newId(),
          updatedAt: nowMs(),
          deleted: false,
          categoryId: _categoryId!,
          name: name,
          description: desc.isEmpty ? null : desc,
          price: price,
          sizesJson: sizesJson,
          modifierGroupIdsJson: groupsJson,
          taxExempt: _taxExempt,
          icon: _icon,
          color: _color,
          sortOrder: sort,
          active: _active,
          available: _available,
          favourite: _favourite,
        ));
      } else {
        await menu.saveProduct(_p!.copyWith(
          categoryId: _categoryId,
          name: name,
          description: Value(desc.isEmpty ? null : desc),
          price: price,
          sizesJson: sizesJson,
          modifierGroupIdsJson: groupsJson,
          taxExempt: _taxExempt,
          icon: _icon,
          color: _color,
          active: _active,
          available: _available,
          favourite: _favourite,
        ));
      }
      if (mounted) Navigator.pop(context, _isNew ? '$name added to the menu' : '$name saved');
    } catch (e) {
      _fail('Couldn’t save: $e');
    }
  }

  Future<void> _delete() async {
    final p = _p!;
    final ok = await confirm(
      context,
      title: 'Delete ${p.name}?',
      message: 'It will disappear from the menu on every till. Past orders and reports keep their history.\n\n'
          'Tip: to hide it for today only, use the “Sold out” switch instead.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (!ok || !mounted) return;
    try {
      await ref.read(servicesProvider).menu.deleteProduct(p);
      if (mounted) Navigator.pop(context, '${p.name} deleted');
    } catch (e) {
      _fail('Couldn’t delete: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    final cats = ref.watch(categoriesProvider).value ?? const <MenuCategory>[];
    final groups = ref.watch(modifierGroupsProvider).value ?? const <ModifierGroup>[];
    final catValid = cats.any((c) => c.id == _categoryId);
    final price = parseRupees(_price.text);
    final (parsedSizes, _) = _parseSizes();

    String previewPrice() {
      if (price == null) return 'Rs —';
      final sizes = parsedSizes ?? const <ProductSize>[];
      if (sizes.length <= 1) return rs(price + (sizes.firstOrNull?.delta ?? 0));
      final min = sizes.map((s) => price + s.delta).reduce((a, b) => a < b ? a : b);
      return 'from ${rs(min)}';
    }

    final narrow = context.screenW < 560;

    final basics = Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
      TextField(
        controller: _name,
        autofocus: _isNew,
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.next,
        decoration: const InputDecoration(labelText: 'Name', hintText: 'e.g. Spanish latte'),
        onChanged: (_) => setState(() {}),
      ),
      const SizedBox(height: Sp.md),
      DropdownButtonFormField<String>(
        key: ValueKey('cat-${cats.length}-$catValid'),
        initialValue: catValid ? _categoryId : null,
        isExpanded: true,
        decoration: InputDecoration(labelText: 'Category', errorText: cats.isEmpty ? 'Create a category first' : null),
        items: [
          for (final c in cats)
            DropdownMenuItem(
              value: c.id,
              child: Row(children: [
                Icon(iconFor(c.icon), size: 18, color: ec.textMuted),
                const SizedBox(width: Sp.sm),
                Flexible(child: Text(c.active ? c.name : '${c.name} (hidden)', overflow: TextOverflow.ellipsis)),
              ]),
            ),
        ],
        onChanged: (v) => setState(() {
          _categoryId = v;
          if (_isNew && !_styleTouched) {
            final c = cats.where((c) => c.id == v).firstOrNull;
            if (c != null) {
              _icon = c.icon;
              _color = c.color;
            }
          }
        }),
      ),
      const SizedBox(height: Sp.md),
      TextField(
        controller: _price,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: moneyFormatters,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          labelText: 'Base price',
          prefixText: 'Rs ',
          helperText: _sizes.isEmpty ? 'Menu price' : 'Price of the standard size; sizes add or subtract from it',
          helperMaxLines: 2,
        ),
        onChanged: (_) => setState(() {}),
      ),
    ]);

    final preview = Column(mainAxisSize: MainAxisSize.min, children: [
      MenuTilePreview(
        icon: _icon,
        color: _color,
        title: _name.text.trim(),
        subtitle: previewPrice(),
        dimmed: !_active,
        badge: _available ? null : 'Sold out',
      ),
      const SizedBox(height: Sp.xs),
      Text('Preview', style: context.tt.labelSmall),
    ]);

    return SaveShortcut(
      onSave: _save,
      child: DialogFrame(
        title: _isNew ? 'New product' : 'Edit product',
        subtitle: _isNew ? null : _p!.name,
        icon: Icons.local_cafe_outlined,
        actions: [
          if (!_isNew) DangerTextButton(label: 'Delete', onPressed: _saving ? null : _delete),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: _saving || cats.isEmpty ? null : _save,
            child: Text(_saving ? 'Saving…' : (_isNew ? 'Add product' : 'Save')),
          ),
        ],
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
          if (narrow) ...[
            Center(child: preview),
            const SizedBox(height: Sp.lg),
            basics,
          ] else
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: basics),
              const SizedBox(width: Sp.xl),
              preview,
            ]),
          const SizedBox(height: Sp.md),
          TextField(
            controller: _desc,
            minLines: 1,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(labelText: 'Description (optional)', hintText: 'Shown on the options sheet'),
          ),
          const SizedBox(height: Sp.xl),

          // ── Look
          const FieldLabel('Icon'),
          IconPickerGrid(
            selected: _icon,
            color: _color,
            onChanged: (k) => setState(() {
              _icon = k;
              _styleTouched = true;
            }),
          ),
          const SizedBox(height: Sp.lg),
          const FieldLabel('Colour'),
          SwatchPicker(
            selected: _color,
            onChanged: (c) => setState(() {
              _color = c;
              _styleTouched = true;
            }),
          ),
          const SizedBox(height: Sp.xl),

          // ── Sizes
          FieldLabel(
            'Sizes',
            hint: _sizes.isEmpty ? 'None — this item is sold in one size.' : 'Price difference from the base price, e.g. −100 or +150.',
          ),
          for (final s in _sizes) _SizeRow(key: ValueKey(s.key), draft: s, onRemove: () => _removeSize(s), onChanged: () => setState(() {})),
          Wrap(spacing: Sp.sm, runSpacing: Sp.xs, children: [
            TextButton.icon(onPressed: () => _addSize(), icon: const Icon(Icons.add_rounded, size: 18), label: const Text('Add size')),
            if (_sizes.isEmpty)
              TextButton.icon(onPressed: _useSml, icon: const Icon(Icons.auto_awesome_outlined, size: 18), label: const Text('Use Small / Medium / Large')),
          ]),
          if (price != null && (parsedSizes?.length ?? 0) > 1)
            Padding(
              padding: const EdgeInsets.only(top: Sp.xs),
              child: Wrap(spacing: Sp.xs, runSpacing: Sp.xs, children: [
                for (final s in parsedSizes!) Pill('${s.label} ${rs(price + s.delta)}', tone: Tone.accent, dense: true),
              ]),
            ),
          const SizedBox(height: Sp.xl),

          // ── Modifiers
          FieldLabel('Modifier groups', hint: groups.isEmpty ? 'No groups yet — create them in the Modifiers tab.' : 'Choices the cashier is asked for, e.g. Milk or Extra shot.'),
          if (groups.isNotEmpty)
            Wrap(spacing: Sp.sm, runSpacing: Sp.sm, children: [
              for (final g in groups)
                FilterChip(
                  label: Text(g.name),
                  selected: _groups.contains(g.id),
                  onSelected: (on) => setState(() => on ? _groups.add(g.id) : _groups.remove(g.id)),
                ),
            ]),
          const SizedBox(height: Sp.xl),

          // ── Flags
          const FieldLabel('Options'),
          LabeledSwitch(
            title: 'Tax exempt',
            subtitle: 'Skips GST and all other taxes on this item (e.g. zero-rated goods).',
            value: _taxExempt,
            onChanged: (v) => setState(() => _taxExempt = v),
          ),
          LabeledSwitch(
            title: 'Favourite',
            subtitle: 'Shown in the Favourites tab on the Sell screen.',
            value: _favourite,
            onChanged: (v) => setState(() => _favourite = v),
          ),
          LabeledSwitch(
            title: 'Active',
            subtitle: 'Inactive products are hidden from the Sell screen but kept here.',
            value: _active,
            onChanged: (v) => setState(() => _active = v),
          ),
          LabeledSwitch(
            title: 'Available today',
            subtitle: 'Turn off when it runs out (86’d). Cashiers see it as sold out.',
            value: _available,
            onChanged: (v) => setState(() => _available = v),
          ),
          const SizedBox(height: Sp.lg),

          // ── Cost & margin
          _CostPanel(product: _p, basePrice: price, sizes: parsedSizes ?? const []),
          if (_error != null) ...[const SizedBox(height: Sp.lg), InlineNote(_error!)],
        ]),
      ),
    );
  }
}

class _SizeRow extends StatelessWidget {
  const _SizeRow({super.key, required this.draft, required this.onRemove, required this.onChanged});
  final _SizeDraft draft;
  final VoidCallback onRemove;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    const dense = InputDecoration(isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12));
    return Padding(
      padding: const EdgeInsets.only(bottom: Sp.sm),
      child: Row(children: [
        SizedBox(
          width: 64,
          child: TextField(
            controller: draft.code,
            textCapitalization: TextCapitalization.characters,
            textInputAction: TextInputAction.next,
            inputFormatters: [LengthLimitingTextInputFormatter(4), FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]'))],
            decoration: dense.copyWith(labelText: 'Code'),
            onChanged: (_) => onChanged(),
          ),
        ),
        const SizedBox(width: Sp.sm),
        Expanded(
          child: TextField(
            controller: draft.label,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            decoration: dense.copyWith(labelText: 'Label', hintText: 'Small'),
            onChanged: (_) => onChanged(),
          ),
        ),
        const SizedBox(width: Sp.sm),
        SizedBox(
          width: 104,
          child: TextField(
            controller: draft.delta,
            keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
            inputFormatters: signedMoneyFormatters,
            textInputAction: TextInputAction.next,
            decoration: dense.copyWith(labelText: '± Rs', hintText: '0'),
            onChanged: (_) => onChanged(),
          ),
        ),
        IconButton(tooltip: 'Remove size', onPressed: onRemove, icon: const Icon(Icons.remove_circle_outline_rounded)),
      ]),
    );
  }
}

/// Ingredient cost and margin from the product's recipe (read-only here).
class _CostPanel extends ConsumerWidget {
  const _CostPanel({required this.product, required this.basePrice, required this.sizes});
  final Product? product;
  final int? basePrice;
  final List<ProductSize> sizes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ec = context.ec;
    final p = product;
    final recipes = ref.watch(recipesProvider).value ?? const <Recipe>[];
    final stock = ref.watch(stockProvider).value ?? const <StockView>[];
    final hasRecipe = p != null && recipes.any((r) => r.productId == p.id);
    if (p == null || !hasRecipe) return _noRecipe(context, isNew: p == null);

    final hint = Text('Recipes are edited in Inventory › Recipes.', style: context.tt.bodySmall);
    final recipeMap = {for (final r in recipes) r.id: r};
    final items = {for (final s in stock) s.item.id: s.item};
    final rows = sizes.isEmpty ? [const ProductSize(code: '', label: 'Standard')] : sizes;

    Widget cell(String t, {TextStyle? style, TextAlign align = TextAlign.right, int flex = 2}) => Expanded(
          flex: flex,
          child: Text(t, textAlign: align, maxLines: 1, overflow: TextOverflow.ellipsis, style: (style ?? context.tt.bodyMedium)?.copyWith(fontFeatures: tabular)),
        );

    return AppCard(
      color: ec.surfaceAlt,
      padding: const EdgeInsets.all(Sp.md),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
        Row(children: [
          Icon(Icons.savings_outlined, color: ec.textMuted, size: 20),
          const SizedBox(width: Sp.sm),
          Expanded(child: Text('Ingredient cost & margin', style: context.tt.titleSmall)),
        ]),
        const SizedBox(height: Sp.sm),
        Row(children: [
          cell('Size', style: context.tt.labelSmall, align: TextAlign.left, flex: 3),
          cell('Price', style: context.tt.labelSmall),
          cell('Cost', style: context.tt.labelSmall),
          cell('Margin', style: context.tt.labelSmall, flex: 3),
        ]),
        const SizedBox(height: Sp.xs),
        for (final s in rows)
          Builder(builder: (context) {
            final cost = InventoryService.recipeCost(p, s.code, recipeMap, items);
            final price = basePrice == null ? null : basePrice! + s.delta;
            final margin = (price == null || cost == null) ? null : price - cost.round();
            final pctVal = (margin == null || price == null || price <= 0) ? null : margin / price * 100;
            final tone = pctVal == null
                ? Tone.neutral
                : pctVal >= 60
                    ? Tone.success
                    : pctVal >= 40
                        ? Tone.warning
                        : Tone.danger;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(children: [
                cell(s.label, align: TextAlign.left, flex: 3),
                cell(price == null ? '—' : rs(price)),
                cell(cost == null ? '—' : rs(cost.round())),
                Expanded(
                  flex: 3,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: margin == null
                        ? const Text('—')
                        : FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Pill('${rs(margin)} · ${pctVal?.toStringAsFixed(0) ?? '–'}%', tone: tone, dense: true),
                          ),
                  ),
                ),
              ]),
            );
          }),
        const SizedBox(height: Sp.sm),
        hint,
      ]),
    );
  }

  Widget _noRecipe(BuildContext context, {required bool isNew}) {
    final ec = context.ec;
    return AppCard(
      color: ec.surfaceAlt,
      padding: const EdgeInsets.all(Sp.md),
      child: Row(children: [
        Icon(Icons.receipt_long_outlined, color: ec.textMuted, size: 20),
        const SizedBox(width: Sp.md),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(isNew ? 'Ingredient cost' : 'No recipe yet', style: context.tt.titleSmall),
            const SizedBox(height: 2),
            Text(
              isNew
                  ? 'Save the product, then add its recipe in Inventory › Recipes to see cost and margin here.'
                  : 'Add a recipe in Inventory › Recipes to track stock and see cost and margin here.',
              style: context.tt.bodySmall,
            ),
          ]),
        ),
      ]),
    );
  }
}
