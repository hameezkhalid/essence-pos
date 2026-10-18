import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme/icons.dart';
import '../../app/theme/tokens.dart';
import '../../core/models/menu_models.dart';
import '../../core/models/settings_models.dart';
import '../../core/money.dart';
import '../../core/services/inventory_service.dart';
import '../../shared/common.dart';
import 'inventory_common.dart';
import 'stock_dialogs.dart';

class StockTab extends ConsumerStatefulWidget {
  const StockTab({super.key, required this.padding});
  final double padding;

  @override
  ConsumerState<StockTab> createState() => _StockTabState();
}

class _StockTabState extends ConsumerState<StockTab> {
  final _search = TextEditingController();
  String _q = '';
  String? _group;
  bool _reorderOnly = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(stockProvider);
    return asyncBody(async, (all) => _body(context, all));
  }

  Widget _body(BuildContext context, List<StockView> all) {
    final pad = widget.padding;
    final can = ref.watch(canProvider(Perm.manageInventory));
    final active = all.where((v) => v.item.active).toList();
    final value = active.fold<double>(0, (a, v) => a + v.value);
    final reorder = active.where((v) => v.needsReorder).length;
    final critical = active.where((v) => v.state == StockState.critical || v.state == StockState.out).length;
    final groups = <String>{for (final v in all) v.item.groupName}.toList()..sort();
    final group = groups.contains(_group) ? _group : null;

    final q = _q.trim().toLowerCase();
    final shown = all.where((v) {
      if (group != null && v.item.groupName != group) return false;
      if (_reorderOnly && !(v.item.active && v.needsReorder)) return false;
      if (q.isNotEmpty && !v.item.name.toLowerCase().contains(q) && !v.item.groupName.toLowerCase().contains(q)) return false;
      return true;
    }).toList()
      ..sort((a, b) {
        if (a.item.active != b.item.active) return a.item.active ? -1 : 1;
        final g = a.item.groupName.compareTo(b.item.groupName);
        return g != 0 ? g : a.item.name.toLowerCase().compareTo(b.item.name.toLowerCase());
      });

    final kpis = ResponsiveGrid(minWidth: context.isPhone ? 150 : 210, children: [
      KpiTile(label: 'Stock value', value: rs(value.round()), icon: Icons.account_balance_wallet_outlined, caption: 'At current cost prices'),
      KpiTile(
        label: 'Needs reorder',
        value: '$reorder',
        icon: Icons.shopping_cart_outlined,
        tone: reorder > 0 ? Tone.warning : Tone.success,
        caption: reorder > 0 ? 'At or below reorder level' : 'All above reorder level',
        captionTone: reorder > 0 ? Tone.warning : Tone.success,
      ),
      KpiTile(
        label: 'Critical / out',
        value: '$critical',
        icon: Icons.warning_amber_rounded,
        tone: critical > 0 ? Tone.danger : Tone.success,
        caption: critical > 0 ? 'Below half the reorder level' : 'Nothing critical',
        captionTone: critical > 0 ? Tone.danger : null,
      ),
      KpiTile(label: 'Items', value: '${active.length}', icon: Icons.inventory_2_outlined, tone: Tone.accent, caption: '${groups.length} groups${all.length > active.length ? ' · ${all.length - active.length} inactive' : ''}'),
    ]);

    final toolbar = Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [
        Expanded(child: SearchBox(controller: _search, hint: 'Search stock items', onChanged: (v) => setState(() => _q = v))),
        const SizedBox(width: Sp.sm),
        context.isPhone
            ? IconButton.filled(
                tooltip: 'Add stock item',
                onPressed: () => showItemEditor(context, ref),
                icon: const Icon(Icons.add_rounded),
              )
            : FilledButton.icon(
                onPressed: () => showItemEditor(context, ref),
                icon: Icon(can ? Icons.add_rounded : Icons.lock_outline_rounded),
                label: const Text('Add item'),
              ),
      ]),
      const SizedBox(height: Sp.md),
      ChipBar(children: [
        FilterChip(
          avatar: Icon(Icons.shopping_cart_outlined, size: 18, color: _reorderOnly ? context.ec.onPrimaryContainer : context.ec.textMuted),
          showCheckmark: false,
          label: Text('Needs reorder only${reorder > 0 ? ' ($reorder)' : ''}'),
          selected: _reorderOnly,
          onSelected: (v) => setState(() => _reorderOnly = v),
        ),
        Container(width: 1, height: 28, color: context.ec.border),
        ChoiceChip(label: const Text('All groups'), selected: group == null, onSelected: (_) => setState(() => _group = null)),
        for (final g in groups) ChoiceChip(label: Text(g), selected: group == g, onSelected: (_) => setState(() => _group = group == g ? null : g)),
      ]),
    ]);

    final Widget list;
    if (all.isEmpty) {
      list = EmptyState(
        icon: Icons.inventory_2_outlined,
        title: 'No stock items yet',
        message: 'Add your ingredients and packaging, then link them to products in Recipes so every sale deducts stock.',
        action: FilledButton.icon(onPressed: () => showItemEditor(context, ref), icon: const Icon(Icons.add_rounded), label: const Text('Add first item')),
      );
    } else if (shown.isEmpty) {
      list = EmptyState(
        icon: _reorderOnly ? Icons.check_circle_outline_rounded : Icons.search_off_rounded,
        title: _reorderOnly ? 'Nothing needs reordering' : 'No matching items',
        message: _reorderOnly ? 'Every item is above its reorder level.' : 'Try another search or group.',
      );
    } else {
      list = _StockList(views: shown);
    }

    return ListView(
      padding: EdgeInsets.fromLTRB(pad, Sp.lg, pad, pad),
      children: [
        kpis,
        const SizedBox(height: Sp.lg),
        toolbar,
        const SizedBox(height: Sp.lg),
        list,
      ],
    );
  }
}

class _StockList extends StatelessWidget {
  const _StockList({required this.views});
  final List<StockView> views;

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, c) {
        final mode = c.maxWidth >= 900 ? _RowMode.table : (c.maxWidth >= 640 ? _RowMode.medium : _RowMode.card);
        if (mode == _RowMode.card) {
          return Column(children: [
            for (final v in views) Padding(padding: const EdgeInsets.only(bottom: Sp.sm), child: _StockCard(view: v)),
          ]);
        }
        final ec = context.ec;
        return AppCard(
          padding: EdgeInsets.zero,
          child: Column(children: [
            _HeaderRow(mode: mode),
            for (var i = 0; i < views.length; i++) ...[
              Divider(height: 1, color: ec.border),
              _StockRow(view: views[i], mode: mode),
            ],
          ]),
        );
      });
}

enum _RowMode { table, medium, card }

const _qtyW = 120.0;
const _statusW = 104.0;

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({required this.mode});
  final _RowMode mode;

  @override
  Widget build(BuildContext context) {
    final s = context.tt.labelSmall?.copyWith(color: context.ec.textMuted);
    return Container(
      color: context.ec.surfaceAlt,
      padding: const EdgeInsets.symmetric(horizontal: Sp.lg, vertical: Sp.sm + 2),
      child: Row(children: [
        Expanded(flex: 4, child: Text('ITEM', style: s)),
        const SizedBox(width: Sp.md),
        Expanded(flex: 3, child: Text('LEVEL VS PAR', style: s)),
        const SizedBox(width: Sp.md),
        SizedBox(width: _qtyW, child: Text('ON HAND', style: s, textAlign: TextAlign.right)),
        if (mode == _RowMode.table) ...[const SizedBox(width: Sp.md), SizedBox(width: _statusW, child: Text('STATUS', style: s))],
        SizedBox(width: mode == _RowMode.table ? 272 : 96, child: Text('ACTIONS', style: s, textAlign: TextAlign.right)),
      ]),
    );
  }
}

class _StockRow extends ConsumerWidget {
  const _StockRow({required this.view, required this.mode});
  final StockView view;
  final _RowMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ec = context.ec;
    final item = view.item;
    final inactive = !item.active;
    return Opacity(
      opacity: inactive ? 0.6 : 1,
      child: InkWell(
        onTap: () => showHistory(context, item),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Sp.lg, vertical: Sp.md),
          child: Row(children: [
            Expanded(
              flex: 4,
              child: Row(children: [
                IconBadge(icon: iconFor(item.icon, fallback: Icons.inventory_2_outlined), color: ec.accent),
                const SizedBox(width: Sp.md),
                Expanded(child: _NameBlock(view: view)),
              ]),
            ),
            const SizedBox(width: Sp.md),
            Expanded(flex: 3, child: _LevelBlock(view: view)),
            const SizedBox(width: Sp.md),
            SizedBox(width: _qtyW, child: _QtyBlock(view: view, alignEnd: true, withPill: mode != _RowMode.table)),
            if (mode == _RowMode.table) ...[
              const SizedBox(width: Sp.md),
              SizedBox(width: _statusW, child: Align(alignment: Alignment.centerLeft, child: StatusPill(view.state, dense: true))),
            ],
            SizedBox(
              width: mode == _RowMode.table ? 272 : 96,
              child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                if (mode == _RowMode.table) ...[
                  _ActionIcon(icon: Icons.add_box_outlined, tip: 'Stock in', onTap: () => showStockIn(context, ref, item), primary: true),
                  _ActionIcon(icon: Icons.delete_outline_rounded, tip: 'Wastage', onTap: () => showWastage(context, ref, item)),
                  _ActionIcon(icon: Icons.fact_check_outlined, tip: 'Count', onTap: () => showCount(context, ref, item)),
                  _ActionIcon(icon: Icons.edit_outlined, tip: 'Edit', onTap: () => showItemEditor(context, ref, item: item)),
                  _ActionIcon(icon: Icons.history_rounded, tip: 'History', onTap: () => showHistory(context, item)),
                ] else ...[
                  _ActionIcon(icon: Icons.add_box_outlined, tip: 'Stock in', onTap: () => showStockIn(context, ref, item), primary: true),
                  _ActionsMenu(view: view, includeStockIn: false),
                ],
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

class _StockCard extends ConsumerWidget {
  const _StockCard({required this.view});
  final StockView view;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ec = context.ec;
    final item = view.item;
    return Opacity(
      opacity: item.active ? 1 : 0.6,
      child: AppCard(
        padding: const EdgeInsets.fromLTRB(Sp.md, Sp.md, Sp.xs, Sp.md),
        onTap: () => showHistory(context, item),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            IconBadge(icon: iconFor(item.icon, fallback: Icons.inventory_2_outlined), color: ec.accent),
            const SizedBox(width: Sp.md),
            Expanded(child: _NameBlock(view: view)),
            const SizedBox(width: Sp.sm),
            _QtyBlock(view: view, alignEnd: true, withPill: true),
            _ActionsMenu(view: view, includeStockIn: true),
          ]),
          const SizedBox(height: Sp.sm),
          Padding(padding: const EdgeInsets.only(right: Sp.md), child: _LevelBlock(view: view)),
        ]),
      ),
    );
  }
}

class _NameBlock extends StatelessWidget {
  const _NameBlock({required this.view});
  final StockView view;

  @override
  Widget build(BuildContext context) {
    final item = view.item;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
      Text(item.name, style: context.tt.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
      const SizedBox(height: 2),
      Wrap(spacing: Sp.xs, runSpacing: 2, crossAxisAlignment: WrapCrossAlignment.center, children: [
        Text(item.groupName, style: context.tt.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
        if (!item.active) const Pill('Inactive', dense: true),
      ]),
    ]);
  }
}

class _LevelBlock extends StatelessWidget {
  const _LevelBlock({required this.view});
  final StockView view;

  @override
  Widget build(BuildContext context) {
    final item = view.item;
    final caption = [
      if (item.reorderLevel > 0) 'Reorder ${item.fmt(item.reorderLevel)}',
      if (item.parLevel > 0) 'Par ${item.fmt(item.parLevel)}',
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
      LevelBar(view: view),
      const SizedBox(height: 2),
      Text(
        caption.isEmpty ? 'No levels set' : caption.join(' · '),
        style: context.tt.bodySmall?.copyWith(fontFeatures: tabular, color: context.ec.textFaint),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    ]);
  }
}

class _QtyBlock extends StatelessWidget {
  const _QtyBlock({required this.view, this.alignEnd = false, this.withPill = false});
  final StockView view;
  final bool alignEnd;
  final bool withPill;

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    final negative = view.qty < 0;
    final tone = view.state == StockState.ok ? null : view.state.tone;
    return Column(crossAxisAlignment: alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
      Text(
        view.item.fmt(shownQty(view.qty)),
        style: context.tt.titleMedium?.copyWith(fontFeatures: tabular, color: tone == null ? ec.text : tone.colors(ec).$1),
        maxLines: 1,
      ),
      if (negative)
        Tooltip(
          message: 'Recorded level is ${view.item.fmt(view.qty)} — sales went past the last count. Count it to correct.',
          child: Text('Count to correct', style: context.tt.labelSmall?.copyWith(color: ec.danger, letterSpacing: 0)),
        )
      else if (!withPill)
        Text(rs(view.value.round()), style: context.tt.bodySmall?.copyWith(fontFeatures: tabular)),
      if (withPill) Padding(padding: const EdgeInsets.only(top: 4), child: StatusPill(view.state, dense: true)),
    ]);
  }
}

class _ActionIcon extends StatelessWidget {
  const _ActionIcon({required this.icon, required this.tip, required this.onTap, this.primary = false});
  final IconData icon;
  final String tip;
  final VoidCallback onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: IconButton(
        tooltip: tip,
        onPressed: onTap,
        style: primary ? IconButton.styleFrom(backgroundColor: ec.primaryContainer, foregroundColor: ec.onPrimaryContainer) : null,
        icon: Icon(icon, size: 20),
      ),
    );
  }
}

class _ActionsMenu extends ConsumerWidget {
  const _ActionsMenu({required this.view, required this.includeStockIn});
  final StockView view;
  final bool includeStockIn;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final item = view.item;
    PopupMenuItem<String> entry(String v, IconData i, String label) =>
        PopupMenuItem(value: v, child: ListTile(leading: Icon(i), title: Text(label), contentPadding: EdgeInsets.zero, dense: true));
    return PopupMenuButton<String>(
      tooltip: 'Actions for ${item.name}',
      icon: const Icon(Icons.more_vert_rounded),
      position: PopupMenuPosition.under,
      onSelected: (v) {
        switch (v) {
          case 'in':
            showStockIn(context, ref, item);
          case 'waste':
            showWastage(context, ref, item);
          case 'count':
            showCount(context, ref, item);
          case 'edit':
            showItemEditor(context, ref, item: item);
          case 'history':
            showHistory(context, item);
        }
      },
      itemBuilder: (_) => [
        if (includeStockIn) entry('in', Icons.add_box_outlined, 'Stock in'),
        entry('waste', Icons.delete_outline_rounded, 'Wastage'),
        entry('count', Icons.fact_check_outlined, 'Count'),
        entry('edit', Icons.edit_outlined, 'Edit item'),
        entry('history', Icons.history_rounded, 'History'),
      ],
    );
  }
}
