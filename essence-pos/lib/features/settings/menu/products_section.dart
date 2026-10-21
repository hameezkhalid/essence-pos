import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/product_thumb.dart';
import '../../../app/providers.dart';
import '../../../app/theme/icons.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/db/database.dart';
import '../../../core/models/menu_models.dart';
import '../../../core/models/settings_models.dart';
import '../../../core/money.dart';
import '../../../shared/common.dart';
import 'menu_widgets.dart';
import 'product_dialog.dart';

/// Products list: search, category filter, quick sold-out / active toggles.
class ProductsSection extends ConsumerStatefulWidget {
  const ProductsSection({super.key, this.onOpenCategories});
  final VoidCallback? onOpenCategories;

  @override
  ConsumerState<ProductsSection> createState() => _ProductsSectionState();
}

class _ProductsSectionState extends ConsumerState<ProductsSection> {
  final _search = TextEditingController();
  String _q = '';
  String? _cat;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _edit(Product? p) async {
    if (!ref.read(canProvider(Perm.manageMenu))) return;
    final msg = await showAdaptive<String>(
      context,
      maxWidth: 680,
      builder: (_) => ProductDialog(product: p, initialCategoryId: p == null ? _cat : null),
    );
    if (msg != null && mounted) toast(context, msg);
  }

  Future<void> _setSoldOut(Product p, bool soldOut) => guardedWrite(
        context,
        () => ref.read(servicesProvider).menu.setAvailable(p, !soldOut),
        success: soldOut ? '${p.name} marked sold out' : '${p.name} is back on the menu',
      );

  Future<void> _setActive(Product p, bool active) => guardedWrite(
        context,
        () => ref.read(servicesProvider).menu.saveProduct(p.copyWith(active: active)),
        success: active ? '${p.name} is shown on the Sell screen' : '${p.name} hidden from the Sell screen',
      );

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    final canEdit = ref.watch(canProvider(Perm.manageMenu));
    final productsAsync = ref.watch(productsProvider);
    final cats = ref.watch(categoriesProvider).value ?? const <MenuCategory>[];
    final catById = {for (final c in cats) c.id: c};
    final catOrder = {for (final (i, c) in cats.indexed) c.id: i};

    if (productsAsync.hasError && !productsAsync.hasValue) {
      return EmptyState(icon: Icons.error_outline_rounded, title: 'Couldn’t load products', message: '${productsAsync.error}');
    }
    if (!productsAsync.hasValue) return const PaneLoading();

    final all = [...productsAsync.value!]
      ..sort((a, b) {
        final ca = catOrder[a.categoryId] ?? 1 << 20, cb = catOrder[b.categoryId] ?? 1 << 20;
        if (ca != cb) return ca.compareTo(cb);
        if (a.sortOrder != b.sortOrder) return a.sortOrder.compareTo(b.sortOrder);
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
    if (_cat != null && !catById.containsKey(_cat)) _cat = null;
    final shown = all.where((p) {
      if (_cat != null && p.categoryId != _cat) return false;
      if (_q.isEmpty) return true;
      return p.name.toLowerCase().contains(_q) || (p.description ?? '').toLowerCase().contains(_q) || (p.sku ?? '').toLowerCase().contains(_q);
    }).toList();
    final soldOut = all.where((p) => p.active && !p.available).length;

    final addBtn = FilledButton.icon(
      onPressed: canEdit && cats.isNotEmpty ? () => _edit(null) : null,
      icon: const Icon(Icons.add_rounded),
      label: const Text('Add product'),
    );

    if (all.isEmpty) {
      return AppCard(
        child: EmptyState(
          icon: Icons.restaurant_menu_rounded,
          title: 'No products yet',
          message: cats.isEmpty
              ? 'Start by creating a category such as Hot coffee or Bakery, then add the items you sell.'
              : 'Add the drinks and bakes you sell. Each one can have sizes and modifiers.',
          action: cats.isEmpty
              ? FilledButton.icon(
                  onPressed: widget.onOpenCategories,
                  icon: const Icon(Icons.category_outlined),
                  label: const Text('Go to categories'),
                )
              : (canEdit ? addBtn : null),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(builder: (context, c) {
          final search = TextField(
            controller: _search,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search products',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _q.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear search',
                      onPressed: () => setState(() {
                        _search.clear();
                        _q = '';
                      }),
                      icon: const Icon(Icons.close_rounded),
                    ),
            ),
            onChanged: (v) => setState(() => _q = v.trim().toLowerCase()),
          );
          if (c.maxWidth < 520) {
            return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [search, const SizedBox(height: Sp.sm), addBtn]);
          }
          return Row(children: [Expanded(child: search), const SizedBox(width: Sp.md), addBtn]);
        }),
        const SizedBox(height: Sp.md),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            Padding(
              padding: const EdgeInsets.only(right: Sp.sm),
              child: ChoiceChip(
                label: Text('All · ${all.length}'),
                selected: _cat == null,
                onSelected: (_) => setState(() => _cat = null),
              ),
            ),
            for (final c in cats)
              Padding(
                padding: const EdgeInsets.only(right: Sp.sm),
                child: ChoiceChip(
                  avatar: Icon(iconFor(c.icon), size: 16, color: _cat == c.id ? ec.onPrimaryContainer : ec.textMuted),
                  label: Text('${c.name} · ${all.where((p) => p.categoryId == c.id).length}'),
                  selected: _cat == c.id,
                  showCheckmark: false,
                  onSelected: (sel) => setState(() => _cat = sel ? c.id : null),
                ),
              ),
          ]),
        ),
        if (soldOut > 0)
          Padding(
            padding: const EdgeInsets.only(top: Sp.md),
            child: InlineNote(
              '$soldOut item${soldOut == 1 ? ' is' : 's are'} marked sold out. Turn the switch off when they’re back.',
              tone: Tone.warning,
              icon: Icons.do_not_disturb_on_outlined,
            ),
          ),
        const SizedBox(height: Sp.md),
        if (shown.isEmpty)
          AppCard(
            child: EmptyState(
              icon: Icons.search_off_rounded,
              title: 'No matching products',
              message: _q.isNotEmpty ? 'Nothing matches “${_search.text.trim()}”. Try another name.' : 'This category has no products yet.',
              action: _q.isEmpty && canEdit ? addBtn : null,
            ),
          )
        else
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              for (final (i, p) in shown.indexed) ...[
                if (i > 0) const RowDivider(indent: 68),
                _ProductRow(
                  product: p,
                  category: catById[p.categoryId],
                  canEdit: canEdit,
                  onTap: () => _edit(p),
                  onSoldOut: (v) => _setSoldOut(p, v),
                  onActive: (v) => _setActive(p, v),
                ),
              ],
            ]),
          ),
      ],
    );
  }
}

class _ProductRow extends StatelessWidget {
  const _ProductRow({
    required this.product,
    required this.category,
    required this.canEdit,
    required this.onTap,
    required this.onSoldOut,
    required this.onActive,
  });
  final Product product;
  final MenuCategory? category;
  final bool canEdit;
  final VoidCallback onTap;
  final ValueChanged<bool> onSoldOut;
  final ValueChanged<bool> onActive;

  String _priceText() {
    final p = product;
    final sizes = p.sizes;
    if (sizes.isEmpty) return rs(p.price);
    final prices = sizes.map((s) => p.price + s.delta).toList()..sort();
    return prices.first == prices.last ? rs(prices.first) : '${rs(prices.first)}–${num0(prices.last)}';
  }

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    final p = product;
    final sizes = p.sizes;
    final groups = p.modifierGroupIds.length;
    final meta = [
      category?.name ?? 'No category',
      if (sizes.length > 1) '${sizes.length} sizes' else if (sizes.length == 1) '1 size',
      if (groups > 0) '$groups modifier${groups == 1 ? '' : 's'}',
    ].join(' · ');

    final flags = [
      if (!p.active) const Pill('Hidden', dense: true, icon: Icons.visibility_off_outlined),
      if (!p.available) const Pill('Sold out', tone: Tone.warning, dense: true),
      if (p.taxExempt) const Pill('Tax exempt', tone: Tone.info, dense: true),
    ];

    final info = Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
      Row(children: [
        Flexible(
          child: Text(
            p.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.tt.titleSmall?.copyWith(color: p.active ? null : ec.textMuted),
          ),
        ),
        if (p.favourite) Padding(padding: const EdgeInsets.only(left: 4), child: Icon(Icons.star_rounded, size: 16, color: ec.accent, semanticLabel: 'Favourite')),
      ]),
      const SizedBox(height: 2),
      Text(meta, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.tt.bodySmall),
      if (flags.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 5), child: Wrap(spacing: 4, runSpacing: 4, children: flags)),
    ]);

    final price = Text(_priceText(), textAlign: TextAlign.right, style: context.tt.titleSmall?.copyWith(color: ec.accent, fontFeatures: tabular));
    final badge = Opacity(opacity: p.active ? 1 : 0.5, child: ProductThumb(product: p, size: 40));

    return InkWell(
        onTap: canEdit ? onTap : null,
        child: LayoutBuilder(builder: (context, c) {
          final narrow = c.maxWidth < 560;
          if (narrow) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(Sp.lg, Sp.md, Sp.sm, Sp.xs),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  badge,
                  const SizedBox(width: Sp.md),
                  Expanded(child: info),
                  const SizedBox(width: Sp.sm),
                  Padding(padding: const EdgeInsets.only(right: Sp.sm), child: price),
                ]),
                Padding(
                  padding: const EdgeInsets.only(left: 44),
                  child: Wrap(alignment: WrapAlignment.end, crossAxisAlignment: WrapCrossAlignment.center, children: [
                    InlineSwitch(label: 'Sold out', value: !p.available, warn: true, onChanged: canEdit ? onSoldOut : null),
                    InlineSwitch(label: 'Active', value: p.active, onChanged: canEdit ? onActive : null),
                  ]),
                ),
              ]),
            );
          }
          return Padding(
            padding: const EdgeInsets.fromLTRB(Sp.lg, Sp.md, Sp.md, Sp.md),
            child: Row(children: [
              badge,
              const SizedBox(width: Sp.md),
              Expanded(child: info),
              const SizedBox(width: Sp.md),
              SizedBox(width: 120, child: price),
              const SizedBox(width: Sp.md),
              InlineSwitch(label: 'Sold out', value: !p.available, warn: true, vertical: true, onChanged: canEdit ? onSoldOut : null),
              const SizedBox(width: Sp.xs),
              InlineSwitch(label: 'Active', value: p.active, vertical: true, onChanged: canEdit ? onActive : null),
              if (canEdit) Icon(Icons.chevron_right_rounded, color: ec.textFaint),
            ]),
          );
        }),
    );
  }
}
