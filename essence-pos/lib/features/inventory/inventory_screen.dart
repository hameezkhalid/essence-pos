import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme/tokens.dart';
import '../../core/services/inventory_service.dart';
import '../../shared/common.dart';
import 'movements_tab.dart';
import 'recipes_tab.dart';
import 'reorder_tab.dart';
import 'stock_tab.dart';

/// Inventory: stock levels (deducted with every sale), recipes, movements and reorder list.
class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> with SingleTickerProviderStateMixin {
  late final _tabs = TabController(length: 4, vsync: this);

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    final pad = context.isDesktop ? Sp.xl : Sp.lg;
    final reorder = (ref.watch(stockProvider).value ?? const <StockView>[]).where((v) => v.item.active && v.needsReorder).length;

    Tab tab(String label, IconData icon, [int? badge]) => Tab(
          height: 48,
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 18),
            const SizedBox(width: Sp.sm),
            Text(label),
            if (badge != null && badge > 0) ...[
              const SizedBox(width: Sp.sm),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(color: ec.warningContainer, borderRadius: BorderRadius.circular(99)),
                child: Text('$badge', style: context.tt.labelSmall?.copyWith(color: ec.warning, fontFeatures: tabular, letterSpacing: 0)),
              ),
            ],
          ]),
        );

    return ColoredBox(
      color: ec.bg,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Padding(
          padding: EdgeInsets.fromLTRB(pad, pad, pad, 0),
          child: const PageTitle('Inventory', subtitle: 'Stock is deducted automatically with every sale'),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: pad),
          child: TabBar(
            controller: _tabs,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            padding: EdgeInsets.zero,
            labelPadding: const EdgeInsets.only(right: Sp.xl),
            tabs: [
              tab('Stock', Icons.inventory_2_outlined),
              tab('Recipes', Icons.menu_book_outlined),
              tab('Movements', Icons.swap_vert_rounded),
              tab('Reorder', Icons.shopping_cart_outlined, reorder),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabs,
            physics: context.isPhone ? null : const NeverScrollableScrollPhysics(),
            children: [
              StockTab(padding: pad),
              RecipesTab(padding: pad),
              MovementsTab(padding: pad),
              ReorderTab(padding: pad),
            ],
          ),
        ),
      ]),
    );
  }
}
