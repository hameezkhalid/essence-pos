import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/providers.dart';
import '../../app/theme/icons.dart';
import '../../app/theme/tokens.dart';
import '../../core/models/menu_models.dart';
import '../../core/money.dart';
import '../../core/printing/printer_config.dart';
import '../../core/printing/receipt_doc.dart';
import '../../core/services/inventory_service.dart';
import '../../shared/common.dart';
import 'inventory_common.dart';
import 'stock_dialogs.dart';

/// One line of the purchase list.
class PurchaseLine {
  const PurchaseLine(this.view, this.qty);
  final StockView view;

  /// Suggested purchase in base units.
  final double qty;
  double get cost => view.item.costOf(qty);
}

/// Suggested purchase to reach par, rounded up to a sensible pack size
/// (100 g / 100 ml, whole pieces). Without a par level, tops up to twice the reorder level.
double suggestedPurchase(StockView v) {
  final item = v.item;
  var q = item.parLevel > 0 ? v.suggestedOrder : math.max(0.0, item.reorderLevel * 2 - v.qty).toDouble();
  if (q <= 0) return 0;
  final step = item.unit == 'pcs' ? 1.0 : 100.0;
  q = (q / step).ceil() * step;
  return q;
}

class ReorderTab extends ConsumerStatefulWidget {
  const ReorderTab({super.key, required this.padding});
  final double padding;

  @override
  ConsumerState<ReorderTab> createState() => _ReorderTabState();
}

class _ReorderTabState extends ConsumerState<ReorderTab> {
  /// Items the user unticked from the purchase list.
  final Set<String> _excluded = {};
  bool _printing = false;

  List<PurchaseLine> _lines(List<StockView> all) {
    final list = [
      for (final v in all)
        if (v.item.active && v.needsReorder) PurchaseLine(v, suggestedPurchase(v)),
    ]..sort((a, b) {
        final g = a.view.item.groupName.compareTo(b.view.item.groupName);
        if (g != 0) return g;
        final s = b.view.state.index.compareTo(a.view.state.index);
        return s != 0 ? s : a.view.item.name.compareTo(b.view.item.name);
      });
    return list;
  }

  String _qtyText(PurchaseLine l) => l.view.item.fmt(l.qty);

  String _plainText(List<PurchaseLine> lines) {
    final store = ref.read(settingsValueProvider).store.name;
    final b = StringBuffer()
      ..writeln('$store — Purchase list')
      ..writeln(DateFormat('EEE d MMM yyyy, h:mm a').format(DateTime.now()))
      ..writeln();
    String? group;
    for (final l in lines) {
      if (l.view.item.groupName != group) {
        if (group != null) b.writeln();
        group = l.view.item.groupName;
        b.writeln(group.toUpperCase());
      }
      final cost = l.cost > 0 ? ' (~${rs(l.cost.round())})' : '';
      b.writeln('- ${l.view.item.name}: ${_qtyText(l)}$cost  [have ${l.view.item.fmt(shownQty(l.view.qty))}]');
    }
    final total = lines.fold<double>(0, (a, l) => a + l.cost);
    b
      ..writeln()
      ..writeln('Estimated total: ${rs(total.round())}');
    return b.toString();
  }

  ReceiptDoc _doc(List<PurchaseLine> lines) {
    final s = ref.read(settingsValueProvider).store;
    final total = lines.fold<double>(0, (a, l) => a + l.cost);
    final out = <RLine>[
      RText(s.name, align: RAlign.center, bold: true, big: true),
      const RText('PURCHASE LIST', align: RAlign.center, bold: true),
      RText(DateFormat('d MMM yyyy, h:mm a').format(DateTime.now()), align: RAlign.center),
      if (ref.read(sessionProvider) != null) RText('By ${ref.read(sessionProvider)!.name}', align: RAlign.center),
      const RDivider(),
    ];
    String? group;
    for (final l in lines) {
      if (l.view.item.groupName != group) {
        if (group != null) out.add(const RFeed());
        group = l.view.item.groupName;
        out.add(RText(group.toUpperCase(), bold: true));
      }
      out.add(RRow(l.view.item.name, _qtyText(l), bold: true));
      out.add(RRow('Have ${l.view.item.fmt(shownQty(l.view.qty))}', l.cost > 0 ? '~${rs(l.cost.round())}' : '', indent: 2));
    }
    out.addAll([
      const RDivider(),
      RRow('${lines.length} item${lines.length == 1 ? '' : 's'} · Est. total', rs(total.round()), bold: true),
      const RFeed(2),
    ]);
    return ReceiptDoc(out, title: 'Purchase list');
  }

  Future<void> _copy(List<PurchaseLine> lines) async {
    await Clipboard.setData(ClipboardData(text: _plainText(lines)));
    if (mounted) toast(context, 'Purchase list copied', icon: Icons.content_copy_rounded);
  }

  Future<void> _print(List<PurchaseLine> lines) async {
    setState(() => _printing = true);
    try {
      final r = await ref.read(servicesProvider).printer.print(_doc(lines), PrintRole.report);
      if (!mounted) return;
      if (r.nothingConfigured) {
        toast(context, 'No report printer set up on this terminal', error: true, icon: Icons.print_disabled_outlined);
      } else if (!r.ok) {
        toast(context, r.errors.first, error: true, icon: Icons.print_disabled_outlined);
      } else {
        toast(context, 'Purchase list printed', icon: Icons.print_outlined);
      }
    } catch (e) {
      if (mounted) toast(context, 'Couldn’t print: $e', error: true);
    } finally {
      if (mounted) setState(() => _printing = false);
    }
  }

  @override
  Widget build(BuildContext context) => asyncBody(ref.watch(stockProvider), (all) => _body(context, all));

  Widget _body(BuildContext context, List<StockView> all) {
    final pad = widget.padding;
    final ec = context.ec;
    final lines = _lines(all);
    final selected = lines.where((l) => !_excluded.contains(l.view.item.id) && l.qty > 0).toList();
    final total = selected.fold<double>(0, (a, l) => a + l.cost);
    final critical = lines.where((l) => l.view.state.index >= StockState.critical.index).length;

    if (lines.isEmpty) {
      return ListView(padding: EdgeInsets.fromLTRB(pad, Sp.lg, pad, pad), children: const [
        SizedBox(height: Sp.xxl),
        EmptyState(
          icon: Icons.check_circle_outline_rounded,
          title: 'Nothing to reorder',
          message: 'Every active item is above its reorder level. Items appear here as sales use them up.',
        ),
      ]);
    }

    final summary = AppCard(
      child: Wrap(
        spacing: Sp.xl,
        runSpacing: Sp.md,
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.spaceBetween,
        children: [
          Wrap(spacing: Sp.xl, runSpacing: Sp.md, children: [
            StatBlock(label: 'To order', value: '${selected.length} of ${lines.length}'),
            StatBlock(label: 'Critical / out', value: '$critical', tone: critical > 0 ? Tone.danger : null),
            StatBlock(label: 'Estimated cost', value: rs(total.round())),
          ]),
          Wrap(spacing: Sp.sm, runSpacing: Sp.sm, children: [
            OutlinedButton.icon(
              onPressed: selected.isEmpty ? null : () => _copy(selected),
              icon: const Icon(Icons.content_copy_rounded),
              label: const Text('Copy purchase list'),
            ),
            FilledButton.icon(
              onPressed: selected.isEmpty || _printing ? null : () => _print(selected),
              icon: _printing ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.print_outlined),
              label: const Text('Print purchase list'),
            ),
          ]),
        ],
      ),
    );

    final groups = <String, List<PurchaseLine>>{};
    for (final l in lines) {
      groups.putIfAbsent(l.view.item.groupName, () => []).add(l);
    }

    return ListView(
      padding: EdgeInsets.fromLTRB(pad, Sp.lg, pad, pad),
      children: [
        summary,
        const SizedBox(height: Sp.sm),
        Text('Suggested quantities top each item up to its par level, rounded up. Untick anything you don’t want to buy.', style: context.tt.bodySmall),
        const SizedBox(height: Sp.md),
        for (final e in groups.entries) ...[
          SectionHeader(
            e.key,
            subtitle: rs(e.value.where((l) => !_excluded.contains(l.view.item.id)).fold<double>(0, (a, l) => a + l.cost).round()),
            padding: const EdgeInsets.only(top: Sp.sm, bottom: Sp.sm),
          ),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(children: [
              for (var i = 0; i < e.value.length; i++) ...[
                if (i > 0) Divider(height: 1, color: ec.border),
                _ReorderRow(
                  line: e.value[i],
                  included: !_excluded.contains(e.value[i].view.item.id),
                  onToggle: (v) => setState(() => v ? _excluded.remove(e.value[i].view.item.id) : _excluded.add(e.value[i].view.item.id)),
                ),
              ],
            ]),
          ),
          const SizedBox(height: Sp.md),
        ],
      ],
    );
  }
}

class _ReorderRow extends ConsumerWidget {
  const _ReorderRow({required this.line, required this.included, required this.onToggle});
  final PurchaseLine line;
  final bool included;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ec = context.ec;
    final v = line.view;
    final item = v.item;
    final phone = context.isPhone;
    final receive = phone
        ? IconButton(
            tooltip: 'Receive ${item.name}',
            onPressed: () => showStockIn(context, ref, item, suggestedQty: line.qty),
            style: IconButton.styleFrom(backgroundColor: ec.primaryContainer, foregroundColor: ec.onPrimaryContainer),
            icon: const Icon(Icons.add_box_outlined, size: 20),
          )
        : OutlinedButton.icon(
            onPressed: () => showStockIn(context, ref, item, suggestedQty: line.qty),
            icon: const Icon(Icons.add_box_outlined, size: 18),
            label: const Text('Receive'),
          );
    return InkWell(
      onTap: () => onToggle(!included),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Sp.sm, Sp.md, Sp.md, Sp.md),
        child: Row(children: [
          Checkbox(value: included, onChanged: (x) => onToggle(x ?? false)),
          IconBadge(icon: iconFor(item.icon, fallback: Icons.inventory_2_outlined), color: ec.accent, size: phone ? 36 : 40),
          const SizedBox(width: Sp.md),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Wrap(spacing: Sp.sm, runSpacing: 2, crossAxisAlignment: WrapCrossAlignment.center, children: [
                Text(item.name, style: context.tt.titleSmall),
                StatusPill(v.state, dense: true),
              ]),
              const SizedBox(height: 2),
              Text(
                'Have ${item.fmt(shownQty(v.qty))}${item.parLevel > 0 ? ' · par ${item.fmt(item.parLevel)}' : ''}',
                style: context.tt.bodySmall?.copyWith(fontFeatures: tabular),
              ),
              if (!phone) ...[const SizedBox(height: Sp.xs), SizedBox(width: 220, child: LevelBar(view: v, height: 6))],
            ]),
          ),
          const SizedBox(width: Sp.sm),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(
              line.qty > 0 ? item.fmt(line.qty) : 'Set par',
              style: context.tt.titleMedium?.copyWith(fontFeatures: tabular, color: included ? ec.text : ec.textFaint),
            ),
            Text(
              line.cost > 0 ? '~${rs(line.cost.round())}' : (item.costPerUnit == 0 ? 'No cost set' : ''),
              style: context.tt.bodySmall?.copyWith(fontFeatures: tabular),
            ),
          ]),
          const SizedBox(width: Sp.md),
          receive,
        ]),
      ),
    );
  }
}
