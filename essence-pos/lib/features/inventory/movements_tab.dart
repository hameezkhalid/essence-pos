import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme/tokens.dart';
import '../../core/db/database.dart';
import '../../core/models/menu_models.dart';
import '../../core/money.dart';
import '../../core/services/inventory_service.dart';
import '../../shared/common.dart';
import 'inventory_common.dart';
import 'stock_dialogs.dart';

class MovementsTab extends ConsumerStatefulWidget {
  const MovementsTab({super.key, required this.padding});
  final double padding;

  @override
  ConsumerState<MovementsTab> createState() => _MovementsTabState();
}

class _MovementsTabState extends ConsumerState<MovementsTab> {
  final _search = TextEditingController();
  String _q = '';
  final Set<String> _types = {};

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(inventoryMovementsProvider);
    final stock = ref.watch(stockProvider).value ?? const <StockView>[];
    return asyncBody(async, (moves) => _body(context, moves, {for (final v in stock) v.item.id: v.item}));
  }

  Widget _body(BuildContext context, List<StockMovement> moves, Map<String, StockItem> items) {
    final pad = widget.padding;
    final ec = context.ec;
    final q = _q.trim().toLowerCase();
    final shown = moves.where((m) {
      if (_types.isNotEmpty && !_types.contains(m.type)) return false;
      if (q.isNotEmpty) {
        final name = items[m.stockItemId]?.name.toLowerCase() ?? '';
        if (!name.contains(q) && !(m.note?.toLowerCase().contains(q) ?? false)) return false;
      }
      return true;
    }).toList();

    // Group by calendar day (movements arrive newest first).
    final days = <(DateTime, List<StockMovement>)>[];
    for (final m in shown) {
      final d = DateTime.fromMillisecondsSinceEpoch(m.createdAt);
      final day = DateTime(d.year, d.month, d.day);
      if (days.isEmpty || days.last.$1 != day) days.add((day, []));
      days.last.$2.add(m);
    }

    final present = {for (final m in moves) m.type};
    final types = MovementType.all.where((t) => present.contains(t.key) || t.key != 'opening').toList();

    final header = Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      SearchBox(controller: _search, hint: 'Search by item or note', onChanged: (v) => setState(() => _q = v)),
      const SizedBox(height: Sp.md),
      ChipBar(children: [
        ChoiceChip(label: const Text('All types'), selected: _types.isEmpty, onSelected: (_) => setState(_types.clear)),
        for (final t in types)
          FilterChip(
            avatar: Icon(t.icon, size: 16, color: t.tone.colors(ec).$1),
            label: Text(t.label),
            showCheckmark: false,
            selected: _types.contains(t.key),
            onSelected: (v) => setState(() => v ? _types.add(t.key) : _types.remove(t.key)),
          ),
      ]),
      const SizedBox(height: Sp.sm),
      Text(
        moves.length >= 500 ? 'Showing the latest 500 movements' : '${moves.length} movement${moves.length == 1 ? '' : 's'}',
        style: context.tt.bodySmall,
      ),
      const SizedBox(height: Sp.sm),
    ]);

    return CustomScrollView(slivers: [
      SliverPadding(padding: EdgeInsets.fromLTRB(pad, Sp.lg, pad, 0), sliver: SliverToBoxAdapter(child: header)),
      if (shown.isEmpty)
        SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyState(
            icon: Icons.swap_vert_rounded,
            title: moves.isEmpty ? 'No stock movements yet' : 'No matching movements',
            message: moves.isEmpty ? 'Sales, deliveries, wastage and counts will be listed here.' : 'Try another search or type.',
          ),
        )
      else
        SliverPadding(
          padding: EdgeInsets.fromLTRB(pad, 0, pad, pad),
          sliver: SliverList.builder(
            itemCount: days.length,
            itemBuilder: (context, i) {
              final (day, list) = days[i];
              var waste = 0.0;
              for (final m in list) {
                final it = items[m.stockItemId];
                if (it != null && m.type == 'wastage') waste += it.costOf(-m.qty);
              }
              return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Padding(
                  padding: EdgeInsets.only(top: i == 0 ? Sp.sm : Sp.lg, bottom: Sp.sm),
                  child: Row(children: [
                    Text(dayLabel(day), style: context.tt.titleSmall),
                    const SizedBox(width: Sp.sm),
                    Pill('${list.length}', dense: true),
                    const Spacer(),
                    if (waste > 0) Text('Wastage ${rs(waste.round())}', style: context.tt.bodySmall?.copyWith(color: ec.danger, fontFeatures: tabular)),
                  ]),
                ),
                AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(children: [
                    for (var j = 0; j < list.length; j++) ...[
                      if (j > 0) Divider(height: 1, color: ec.border),
                      _Row(movement: list[j], item: items[list[j].stockItemId]),
                    ],
                  ]),
                ),
              ]);
            },
          ),
        ),
    ]);
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.movement, required this.item});
  final StockMovement movement;
  final StockItem? item;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: item == null ? null : () => showHistory(context, item!),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Sp.lg),
          child: MovementTile(movement: movement, item: item, showDate: false),
        ),
      );
}
