import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme/icons.dart';
import '../../app/theme/tokens.dart';
import '../../core/db/database.dart';
import '../../core/models/menu_models.dart';
import '../../core/money.dart';
import '../../core/services/inventory_service.dart';
import '../../shared/common.dart';
import 'inventory_common.dart';
import 'recipe_editor.dart';

enum _RecipeStatus { complete, partial, missing }

class _ProductCost {
  _ProductCost(this.product, this.status, this.lines, this.ingredients);
  final Product product;
  final _RecipeStatus status;

  /// (label, price, cost) per size, or a single line without sizes.
  final List<(String, int, double?)> lines;
  final int ingredients;

  double? get worstMargin {
    double? m;
    for (final (_, price, cost) in lines) {
      final x = marginOf(price, cost);
      if (x != null && (m == null || x < m)) m = x;
    }
    return m;
  }
}

enum _Filter { all, missing, lowMargin }

class RecipesTab extends ConsumerStatefulWidget {
  const RecipesTab({super.key, required this.padding});
  final double padding;

  @override
  ConsumerState<RecipesTab> createState() => _RecipesTabState();
}

class _RecipesTabState extends ConsumerState<RecipesTab> {
  final _search = TextEditingController();
  String _q = '';
  _Filter _filter = _Filter.all;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productsProvider);
    final recipes = ref.watch(recipesProvider).value ?? const <Recipe>[];
    final categories = ref.watch(categoriesProvider).value ?? const <MenuCategory>[];
    final stock = ref.watch(stockProvider).value ?? const <StockView>[];
    return asyncBody(products, (list) => _body(context, list, recipes, categories, stock));
  }

  Widget _body(BuildContext context, List<Product> products, List<Recipe> recipes, List<MenuCategory> categories, List<StockView> stock) {
    final pad = widget.padding;
    final ec = context.ec;
    final recipesById = {for (final r in recipes) r.id: r};
    final items = {for (final v in stock) v.item.id: v.item};

    _ProductCost costOf(Product p) {
      final sizes = p.sizes;
      final base = recipesById[InventoryService.recipeId(p.id, '')];
      final lines = <(String, int, double?)>[
        if (sizes.isEmpty) ('', p.price, InventoryService.recipeCost(p, '', recipesById, items)),
        for (final s in sizes) (sizeLabel(s), p.price + s.delta, InventoryService.recipeCost(p, s.code, recipesById, items)),
      ];
      final have = lines.where((l) => l.$3 != null).length;
      final status = have == 0 ? _RecipeStatus.missing : (have < lines.length ? _RecipeStatus.partial : _RecipeStatus.complete);
      final ids = <String>{
        for (final r in recipes)
          if (r.productId == p.id) ...r.items.map((e) => e.stockItemId),
      };
      return _ProductCost(p, status, lines, base?.items.length ?? ids.length);
    }

    final all = [for (final p in products) costOf(p)];
    final active = all.where((c) => c.product.active).toList();
    final withRecipe = active.where((c) => c.status != _RecipeStatus.missing).length;
    final missing = active.length - withRecipe;
    final margins = [for (final c in active) ?c.worstMargin];
    final avg = margins.isEmpty ? null : margins.reduce((a, b) => a + b) / margins.length;
    final lowest = active.where((c) => c.worstMargin != null).fold<_ProductCost?>(null, (a, c) => a == null || c.worstMargin! < a.worstMargin! ? c : a);

    final q = _q.trim().toLowerCase();
    final shown = all.where((c) {
      if (q.isNotEmpty && !c.product.name.toLowerCase().contains(q)) return false;
      return switch (_filter) {
        _Filter.all => true,
        _Filter.missing => c.status != _RecipeStatus.complete,
        _Filter.lowMargin => (c.worstMargin ?? 1) < 0.45,
      };
    }).toList();

    // Group by category in menu order.
    final catOrder = {for (var i = 0; i < categories.length; i++) categories[i].id: i};
    final catName = {for (final c in categories) c.id: c.name};
    final byCat = <String, List<_ProductCost>>{};
    for (final c in shown) {
      byCat.putIfAbsent(c.product.categoryId, () => []).add(c);
    }
    final catIds = byCat.keys.toList()..sort((a, b) => (catOrder[a] ?? 999).compareTo(catOrder[b] ?? 999));

    final kpis = ResponsiveGrid(minWidth: context.isPhone ? 150 : 210, children: [
      KpiTile(
        label: 'With recipe',
        value: '$withRecipe / ${active.length}',
        icon: Icons.menu_book_outlined,
        caption: 'Products that deduct stock',
      ),
      KpiTile(
        label: 'Missing recipe',
        value: '$missing',
        icon: Icons.help_outline_rounded,
        tone: missing > 0 ? Tone.warning : Tone.success,
        caption: missing > 0 ? 'Sales won’t deduct stock' : 'Every product is covered',
        captionTone: missing > 0 ? Tone.warning : Tone.success,
      ),
      KpiTile(label: 'Average margin', value: marginText(avg), icon: Icons.percent_rounded, tone: marginTone(avg), caption: 'Menu price vs ingredient cost'),
      KpiTile(
        label: 'Lowest margin',
        value: marginText(lowest?.worstMargin),
        icon: Icons.trending_down_rounded,
        tone: marginTone(lowest?.worstMargin),
        caption: lowest?.product.name ?? 'No costed products yet',
      ),
    ]);

    final toolbar = Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      SearchBox(controller: _search, hint: 'Search products', onChanged: (v) => setState(() => _q = v)),
      const SizedBox(height: Sp.md),
      ChipBar(children: [
        ChoiceChip(label: const Text('All products'), selected: _filter == _Filter.all, onSelected: (_) => setState(() => _filter = _Filter.all)),
        ChoiceChip(
          label: Text('Missing / partial${all.where((c) => c.status != _RecipeStatus.complete).isNotEmpty ? ' (${all.where((c) => c.status != _RecipeStatus.complete).length})' : ''}'),
          selected: _filter == _Filter.missing,
          onSelected: (_) => setState(() => _filter = _Filter.missing),
        ),
        ChoiceChip(label: const Text('Margin under 45%'), selected: _filter == _Filter.lowMargin, onSelected: (_) => setState(() => _filter = _Filter.lowMargin)),
      ]),
    ]);

    return ListView(
      padding: EdgeInsets.fromLTRB(pad, Sp.lg, pad, pad),
      children: [
        kpis,
        const SizedBox(height: Sp.lg),
        toolbar,
        const SizedBox(height: Sp.lg),
        if (products.isEmpty)
          const EmptyState(icon: Icons.restaurant_menu_rounded, title: 'No products yet', message: 'Add products in Settings → Menu, then give each a recipe here.')
        else if (shown.isEmpty)
          EmptyState(
            icon: _filter == _Filter.missing ? Icons.check_circle_outline_rounded : Icons.search_off_rounded,
            title: _filter == _Filter.missing ? 'Every product has a recipe' : 'No matching products',
          )
        else
          for (final cid in catIds) ...[
            SectionHeader(
              catName[cid] ?? 'Other',
              subtitle: '${byCat[cid]!.length} product${byCat[cid]!.length == 1 ? '' : 's'}',
              padding: const EdgeInsets.only(bottom: Sp.sm, top: Sp.sm),
            ),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(children: [
                for (var i = 0; i < byCat[cid]!.length; i++) ...[
                  if (i > 0) Divider(height: 1, color: ec.border),
                  _ProductRow(cost: byCat[cid]![i]),
                ],
              ]),
            ),
            const SizedBox(height: Sp.lg),
          ],
      ],
    );
  }
}

class _ProductRow extends StatelessWidget {
  const _ProductRow({required this.cost});
  final _ProductCost cost;

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    final p = cost.product;
    final (label, tone, icon) = switch (cost.status) {
      _RecipeStatus.complete => ('Recipe', Tone.success, Icons.check_rounded),
      _RecipeStatus.partial => ('Partial', Tone.warning, Icons.timelapse_rounded),
      _RecipeStatus.missing => ('Missing', Tone.danger, Icons.close_rounded),
    };
    final costs = Wrap(spacing: Sp.sm, runSpacing: Sp.xs, children: [
      for (final (name, price, c) in cost.lines) _CostChip(label: name, price: price, cost: c),
    ]);
    return Opacity(
      opacity: p.active ? 1 : 0.6,
      child: InkWell(
        onTap: () => showRecipeEditor(context, p),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Sp.lg, vertical: Sp.md),
          child: LayoutBuilder(builder: (context, c) {
            final wide = c.maxWidth >= 720;
            final head = Row(children: [
              IconBadge(icon: iconFor(p.icon), color: Color(p.color)),
              const SizedBox(width: Sp.md),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(p.name, style: context.tt.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(
                    [
                      rs(p.price),
                      if (cost.status != _RecipeStatus.missing) '${cost.ingredients} ingredient${cost.ingredients == 1 ? '' : 's'}',
                      if (!p.active) 'inactive',
                    ].join(' · '),
                    style: context.tt.bodySmall?.copyWith(fontFeatures: tabular),
                  ),
                ]),
              ),
              const SizedBox(width: Sp.sm),
              Pill(label, tone: tone, icon: icon, dense: true),
            ]);
            if (wide) {
              return Row(children: [
                Expanded(flex: 2, child: head),
                const SizedBox(width: Sp.lg),
                Expanded(flex: 3, child: Align(alignment: Alignment.centerRight, child: costs)),
                const SizedBox(width: Sp.sm),
                Icon(Icons.chevron_right_rounded, color: ec.textFaint),
              ]);
            }
            return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              head,
              if (cost.status != _RecipeStatus.missing) ...[const SizedBox(height: Sp.sm), costs],
            ]);
          }),
        ),
      ),
    );
  }
}

class _CostChip extends StatelessWidget {
  const _CostChip({required this.label, required this.price, required this.cost});
  final String label;
  final int price;
  final double? cost;

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    final m = marginOf(price, cost);
    final (fg, _) = marginTone(m).colors(ec);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: ec.surfaceAlt, borderRadius: BorderRadius.circular(Rad.sm), border: Border.all(color: ec.border)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (label.isNotEmpty) ...[Text(label, style: context.tt.labelMedium), const SizedBox(width: Sp.sm)],
        Text(cost == null ? 'No recipe' : costText(cost!), style: context.tt.bodySmall?.copyWith(fontFeatures: tabular, color: ec.text)),
        if (m != null) ...[
          const SizedBox(width: Sp.sm),
          Text(marginText(m), style: context.tt.labelMedium?.copyWith(fontFeatures: tabular, color: fg, fontWeight: FontWeight.w700)),
        ],
      ]),
    );
  }
}
