import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme/icons.dart';
import '../../app/theme/tokens.dart';
import '../../core/db/database.dart';
import '../../core/models/menu_models.dart';
import '../../core/money.dart';
import '../../core/tax/tax_engine.dart';
import '../../shared/common.dart';
import 'cart_panel.dart';
import 'product_options_sheet.dart';
import 'sell_dialogs.dart';

/// The till: menu on the left, current order on the right (bottom sheet on phones).
class SellScreen extends ConsumerStatefulWidget {
  const SellScreen({super.key});
  @override
  ConsumerState<SellScreen> createState() => _SellScreenState();
}

class _SellScreenState extends ConsumerState<SellScreen> {
  String _category = '_fav';
  String _query = '';
  final _search = TextEditingController();
  final _searchFocus = FocusNode();
  final _cartKey = GlobalKey<CartPanelState>();

  @override
  void dispose() {
    _search.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  Future<void> _tapProduct(Product p) async {
    if (!p.available) {
      toast(context, '${p.name} is sold out today', error: true, icon: Icons.block_rounded);
      return;
    }
    if (p.hasOptions) {
      await showProductOptions(context, ref, product: p);
    } else {
      ref.read(cartProvider.notifier).add(p);
      HapticFeedback.selectionClick();
    }
  }

  @override
  Widget build(BuildContext context) {
    final phone = context.isPhone;
    final wide = context.screenW >= 980;
    final menu = _MenuPanel(
      category: _category,
      query: _query,
      search: _search,
      searchFocus: _searchFocus,
      onCategory: (c) => setState(() => _category = c),
      onQuery: (q) => setState(() => _query = q),
      onProduct: _tapProduct,
      onLongPress: (p) => showProductOptions(context, ref, product: p),
    );

    final split = wide && !phone;

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.f2): () => _searchFocus.requestFocus(),
        const SingleActivator(LogicalKeyboardKey.f4): () => _cartKey.currentState?.hold(),
        const SingleActivator(LogicalKeyboardKey.f8): () => _cartKey.currentState?.charge(),
        const SingleActivator(LogicalKeyboardKey.enter, control: true): () => _cartKey.currentState?.charge(),
        const SingleActivator(LogicalKeyboardKey.escape): () {
          if (_query.isNotEmpty) {
            _search.clear();
            setState(() => _query = '');
          }
        },
      },
      child: Focus(
        autofocus: true,
        child: split
            ? Row(children: [
                Expanded(child: menu),
                Container(width: 1, color: context.ec.border),
                SizedBox(width: context.screenW >= 1400 ? 440 : 390, child: CartPanel(key: _cartKey)),
              ])
            : Column(children: [
                Expanded(child: menu),
                _CartBar(onOpen: () => showCartSheet(context)),
              ]),
      ),
    );
  }
}

/// Bottom bar on narrow screens showing the order summary.
class _CartBar extends ConsumerWidget {
  const _CartBar({required this.onOpen});
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final ec = context.ec;
    final pos = ref.watch(servicesProvider).pos;
    ref.watch(billConfigProvider);
    final total = cart.isEmpty ? 0 : pos.previewTotal(cart, RateGroup.cash);
    return Material(
      color: ec.surface,
      elevation: 0,
      child: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(border: Border(top: BorderSide(color: ec.border))),
          padding: const EdgeInsets.fromLTRB(Sp.lg, Sp.sm, Sp.lg, Sp.sm),
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                Text(cart.isEmpty ? 'No items yet' : '${cart.itemCount} item${cart.itemCount == 1 ? '' : 's'} · ${cart.type.label}',
                    style: context.tt.labelMedium?.copyWith(color: ec.textMuted)),
                Text(cart.isEmpty ? 'Tap a product to start' : rs(total), style: context.tt.titleLarge?.copyWith(fontFeatures: tabular)),
              ]),
            ),
            FilledButton.icon(
              onPressed: onOpen,
              icon: const Icon(Icons.shopping_bag_outlined),
              label: const Text('View order'),
            ),
          ]),
        ),
      ),
    );
  }
}

class _MenuPanel extends ConsumerWidget {
  const _MenuPanel({
    required this.category,
    required this.query,
    required this.search,
    required this.searchFocus,
    required this.onCategory,
    required this.onQuery,
    required this.onProduct,
    required this.onLongPress,
  });

  final String category;
  final String query;
  final TextEditingController search;
  final FocusNode searchFocus;
  final ValueChanged<String> onCategory;
  final ValueChanged<String> onQuery;
  final ValueChanged<Product> onProduct;
  final ValueChanged<Product> onLongPress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ec = context.ec;
    final cats = (ref.watch(categoriesProvider).value ?? const []).where((c) => c.active).toList();
    final all = (ref.watch(productsProvider).value ?? const []).where((p) => p.active).toList();
    final activeCatIds = cats.map((c) => c.id).toSet();
    final cart = ref.watch(cartProvider);
    final inCart = <String, int>{};
    for (final l in cart.lines) {
      inCart[l.productId] = (inCart[l.productId] ?? 0) + l.qty;
    }
    final q = query.trim().toLowerCase();
    final products = all.where((p) {
      if (!activeCatIds.contains(p.categoryId)) return false;
      if (q.isNotEmpty) return p.name.toLowerCase().contains(q) || (p.sku?.toLowerCase().contains(q) ?? false);
      if (category == '_fav') return p.favourite;
      if (category == '_all') return true;
      return p.categoryId == category;
    }).toList();
    final effectiveCat = category == '_fav' && products.isEmpty && q.isEmpty ? '_all' : category;
    final shown = effectiveCat != category
        ? all.where((p) => activeCatIds.contains(p.categoryId)).toList()
        : products;
    final compact = ref.watch(gridDensityProvider).value == 'compact';
    final pad = context.isPhone ? Sp.md : Sp.lg;
    final held = ref.watch(heldOrdersProvider).value ?? const [];

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Padding(
        padding: EdgeInsets.fromLTRB(pad, pad, pad, Sp.sm),
        child: Row(children: [
          Expanded(
            child: TextField(
              controller: search,
              focusNode: searchFocus,
              onChanged: onQuery,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) {
                if (shown.length == 1) {
                  onProduct(shown.first);
                  search.clear();
                  onQuery('');
                }
              },
              decoration: InputDecoration(
                hintText: context.isPhone ? 'Search menu' : 'Search menu or scan  (F2)',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear search',
                        onPressed: () {
                          search.clear();
                          onQuery('');
                        },
                        icon: const Icon(Icons.close_rounded),
                      ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: Sp.sm),
          Badge(
            isLabelVisible: held.isNotEmpty,
            label: Text('${held.length}'),
            backgroundColor: ec.accent,
            child: OutlinedButton.icon(
              onPressed: () => showHeldOrders(context, ref),
              icon: const Icon(Icons.pause_circle_outline_rounded),
              label: Text(context.isPhone ? 'Held' : 'Held orders'),
              style: OutlinedButton.styleFrom(backgroundColor: ec.surface),
            ),
          ),
        ]),
      ),
      SizedBox(
        height: 46,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: pad),
          children: [
            _CatChip(label: 'Favourites', icon: Icons.star_rounded, selected: effectiveCat == '_fav' && q.isEmpty, onTap: () => onCategory('_fav')),
            _CatChip(label: 'All', icon: Icons.apps_rounded, selected: effectiveCat == '_all' && q.isEmpty, onTap: () => onCategory('_all')),
            for (final c in cats)
              _CatChip(
                label: c.name,
                icon: iconFor(c.icon),
                color: Color(c.color),
                selected: effectiveCat == c.id && q.isEmpty,
                onTap: () => onCategory(c.id),
              ),
          ],
        ),
      ),
      const SizedBox(height: Sp.sm),
      Expanded(
        child: shown.isEmpty
            ? EmptyState(
                icon: q.isNotEmpty ? Icons.search_off_rounded : Icons.restaurant_menu_rounded,
                title: q.isNotEmpty ? 'Nothing matches “$query”' : 'No products here yet',
                message: q.isNotEmpty ? 'Try another name.' : 'Add products in Settings › Menu.',
              )
            : LayoutBuilder(builder: (context, c) {
                final minTile = compact ? 128.0 : (context.isPhone ? 150.0 : 168.0);
                final cols = ((c.maxWidth - pad * 2 + Sp.md) / (minTile + Sp.md)).floor().clamp(2, 10);
                return GridView.builder(
                  padding: EdgeInsets.fromLTRB(pad, Sp.xs, pad, pad + Sp.md),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cols,
                    mainAxisSpacing: Sp.md,
                    crossAxisSpacing: Sp.md,
                    mainAxisExtent: compact ? 118 : 148,
                  ),
                  itemCount: shown.length,
                  itemBuilder: (context, i) => ProductTile(
                    product: shown[i],
                    compact: compact,
                    inCart: inCart[shown[i].id] ?? 0,
                    onTap: () => onProduct(shown[i]),
                    onLongPress: () => onLongPress(shown[i]),
                  ),
                );
              }),
      ),
    ]);
  }
}

class _CatChip extends StatelessWidget {
  const _CatChip({required this.label, required this.icon, required this.selected, required this.onTap, this.color});
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    return Padding(
      padding: const EdgeInsets.only(right: Sp.sm),
      child: Material(
        color: selected ? ec.primary : ec.surface,
        shape: StadiumBorder(side: BorderSide(color: selected ? ec.primary : ec.border)),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(children: [
              Icon(icon, size: 18, color: selected ? ec.onPrimary : (color ?? ec.textMuted)),
              const SizedBox(width: 6),
              Text(label, style: context.tt.labelLarge?.copyWith(color: selected ? ec.onPrimary : ec.text)),
            ]),
          ),
        ),
      ),
    );
  }
}

class ProductTile extends StatelessWidget {
  const ProductTile({super.key, required this.product, required this.onTap, this.onLongPress, this.inCart = 0, this.compact = false});
  final Product product;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final int inCart;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    final p = product;
    final sold = !p.available;
    final color = Color(p.color);
    final sizes = p.sizes;
    final minPrice = sizes.isEmpty ? p.price : p.price + sizes.map((s) => s.delta).reduce((a, b) => a < b ? a : b);
    return Semantics(
      button: true,
      label: '${p.name}, ${rs(minPrice)}${sold ? ', sold out' : ''}',
      child: Material(
        color: inCart > 0 ? ec.primaryContainer.withValues(alpha: context.isDark ? 0.55 : 0.6) : ec.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Rad.lg),
          side: BorderSide(color: inCart > 0 ? ec.primary.withValues(alpha: 0.6) : ec.border, width: inCart > 0 ? 1.4 : 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Stack(children: [
            Padding(
              padding: EdgeInsets.all(compact ? 10 : 14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  IconBadge(icon: iconFor(p.icon), color: color, size: compact ? 34 : 44),
                  const Spacer(),
                  if (p.hasOptions && !compact) Icon(Icons.tune_rounded, size: 16, color: ec.textFaint),
                ]),
                const Spacer(),
                Text(
                  p.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: (compact ? context.tt.labelLarge : context.tt.titleSmall)?.copyWith(height: 1.2, fontSize: compact ? 13 : 14),
                ),
                const SizedBox(height: 3),
                Text(
                  sizes.length > 1 ? 'from ${rs(minPrice)}' : rs(minPrice),
                  style: context.tt.labelMedium?.copyWith(color: ec.accent, fontFeatures: tabular),
                ),
              ]),
            ),
            if (inCart > 0)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  constraints: const BoxConstraints(minWidth: 24),
                  height: 24,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(color: ec.primary, borderRadius: BorderRadius.circular(99)),
                  alignment: Alignment.center,
                  child: Text('$inCart', style: context.tt.labelMedium?.copyWith(color: ec.onPrimary, fontWeight: FontWeight.w800)),
                ),
              ),
            if (sold)
              Positioned.fill(
                child: Container(
                  color: ec.surface.withValues(alpha: 0.72),
                  alignment: Alignment.center,
                  child: const Pill('Sold out', tone: Tone.danger, icon: Icons.block_rounded),
                ),
              ),
          ]),
        ),
      ),
    );
  }
}
