import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app/theme/tokens.dart';
import '../../core/money.dart';
import '../../core/services/reports.dart';
import '../../shared/common.dart';

/// Chart and table building blocks shared by the POS reports screen and the owner dashboard.
/// No providers or database access here, so the web dashboard can use them directly.

// ───────────── Formatting ─────────────

/// Compact rupee figure for axes and small labels: 850 · 12.5K · 1.2M.
String compactRupees(num paisa) {
  final r = paisa / 100;
  final a = r.abs();
  String trim(double v) => v >= 100 || v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');
  if (a >= 1000000) return '${r < 0 ? '−' : ''}${trim(a / 1000000)}M';
  if (a >= 1000) return '${r < 0 ? '−' : ''}${trim(a / 1000)}K';
  return '${r < 0 ? '−' : ''}${a.toStringAsFixed(0)}';
}

/// 9 AM / 12 PM; short form 9a / 12p for tight axes.
String hourLabel(int h, {bool short = false}) {
  final hh = h % 24;
  final h12 = hh % 12 == 0 ? 12 : hh % 12;
  final am = hh < 12;
  return short ? '$h12${am ? 'a' : 'p'}' : '$h12 ${am ? 'AM' : 'PM'}';
}

String hourRangeLabel(int h) => '${hourLabel(h)} – ${hourLabel(h + 1)}';

/// Hours in business-day order (starting at [dayStartHour]) trimmed to the span that has data.
List<int> hourAxis(Iterable<Map<int, int>> series, int dayStartHour, {int? includeHour}) {
  final ordered = [for (var i = 0; i < 24; i++) (dayStartHour + i) % 24];
  bool has(int h) => h == includeHour || series.any((m) => (m[h] ?? 0) != 0);
  final first = ordered.indexWhere(has);
  if (first < 0) return const [];
  final last = ordered.lastIndexWhere(has);
  return ordered.sublist(first, last + 1);
}

/// Percentage change caption and its tone (null tone = neutral).
(String, Tone?) deltaCaption(int cur, int prev, {String vs = 'vs previous', bool upIsGood = true, String? noPrev}) {
  if (prev == 0) return (cur == 0 ? 'No change $vs' : (noPrev ?? 'Nothing $vs'), null);
  final change = (cur - prev) / prev.abs() * 100;
  if (change.abs() < 0.5) return ('Same as ${vs.replaceFirst('vs ', '')}', null);
  final up = change > 0;
  final text = '${up ? '+' : '−'}${change.abs() >= 10 ? change.abs().toStringAsFixed(0) : change.abs().toStringAsFixed(1)}% $vs';
  return (text, up == upIsGood ? Tone.success : Tone.danger);
}

/// A rounded, readable axis step and top value for [maxValue] (in rupees).
(double interval, double maxY) niceAxis(double maxValue, {int ticks = 4}) {
  if (maxValue <= 0) return (250, 1000);
  final raw = maxValue / ticks;
  final mag = math.pow(10, (math.log(raw) / math.ln10).floor()).toDouble();
  final n = raw / mag;
  final step = (n <= 1 ? 1 : n <= 2 ? 2 : n <= 2.5 ? 2.5 : n <= 5 ? 5 : 10) * mag;
  return (step, (maxValue / step).ceil() * step);
}

// ───────────── Chrome ─────────────

class LegendItem {
  const LegendItem(this.label, this.color);
  final String label;
  final Color color;
}

class ChartLegend extends StatelessWidget {
  const ChartLegend(this.items, {super.key});
  final List<LegendItem> items;

  @override
  Widget build(BuildContext context) => Wrap(spacing: Sp.md, runSpacing: Sp.xs, children: [
        for (final i in items)
          Row(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 10, height: 10, decoration: BoxDecoration(color: i.color, borderRadius: BorderRadius.circular(3))),
            const SizedBox(width: 6),
            Text(i.label, style: context.tt.labelMedium?.copyWith(color: context.ec.textMuted)),
          ]),
      ]);
}

/// Card with a title row, optional legend/trailing and body.
class ReportCard extends StatelessWidget {
  const ReportCard({super.key, required this.title, this.subtitle, this.trailing, this.legend, required this.child});
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget? legend;
  final Widget child;

  @override
  Widget build(BuildContext context) => AppCard(
        padding: const EdgeInsets.fromLTRB(Sp.lg, Sp.lg, Sp.lg, Sp.lg),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
          SectionHeader(title, subtitle: subtitle, trailing: trailing, padding: EdgeInsets.only(bottom: legend == null ? Sp.md : Sp.sm)),
          if (legend != null) Padding(padding: const EdgeInsets.only(bottom: Sp.md), child: legend),
          child,
        ]),
      );
}

/// Places [children] side by side when there is room, otherwise stacks them.
class SplitRow extends StatelessWidget {
  const SplitRow({super.key, required this.children, this.minChildWidth = 420, this.flex});
  final List<Widget> children;
  final double minChildWidth;
  final List<int>? flex;

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, c) {
        final fits = c.maxWidth >= minChildWidth * children.length + Sp.lg * (children.length - 1);
        if (!fits) {
          return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            for (var i = 0; i < children.length; i++) ...[if (i > 0) const SizedBox(height: Sp.lg), children[i]],
          ]);
        }
        return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(width: Sp.lg),
            Expanded(flex: flex?[i] ?? 1, child: children[i]),
          ],
        ]);
      });
}

/// Grid of KPI tiles that only uses column counts from [columns], so rows stay balanced
/// (e.g. 6 tiles as 2×3, 3×2 or 6×1 — never 4 + 2).
class KpiGrid extends StatelessWidget {
  const KpiGrid({super.key, required this.children, this.columns = const [2, 3, 6], this.minWidth = 165, this.spacing = Sp.md});
  final List<Widget> children;
  final List<int> columns;
  final double minWidth;
  final double spacing;

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, c) {
        final fit = (c.maxWidth / minWidth).floor();
        final cols = columns.lastWhere((n) => n <= fit, orElse: () => columns.first);
        final w = (c.maxWidth - spacing * (cols - 1)) / cols;
        return Wrap(spacing: spacing, runSpacing: spacing, children: [for (final ch in children) SizedBox(width: w, child: ch)]);
      });
}

/// Small centred message used inside a chart card when there is nothing to plot.
class ChartEmpty extends StatelessWidget {
  const ChartEmpty({super.key, this.height = 160, this.message = 'No sales in this period yet'});
  final double height;
  final String message;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: height,
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.bar_chart_rounded, color: context.ec.textFaint, size: 32),
            const SizedBox(height: Sp.sm),
            Text(message, style: context.tt.bodyMedium?.copyWith(color: context.ec.textMuted), textAlign: TextAlign.center),
          ]),
        ),
      );
}

TextStyle? _axisStyle(BuildContext context) => context.tt.labelSmall?.copyWith(color: context.ec.textMuted, letterSpacing: 0, fontFeatures: tabular, fontWeight: FontWeight.w500);
TextStyle? _tipStyle(BuildContext context, {bool bold = false}) =>
    context.tt.bodySmall?.copyWith(color: context.ec.bg, fontFeatures: tabular, fontWeight: bold ? FontWeight.w700 : FontWeight.w500, height: 1.45);

// ───────────── Bar chart (hours / days) ─────────────

class BarSeries {
  const BarSeries({required this.label, required this.color, required this.values});
  final String label;
  final Color color;

  /// Value (paisa) per x slot; same length as the chart's labels.
  final List<int> values;
}

/// Column chart of money values with an optional comparison series (grouped bars).
/// Values are paisa, plotted in rupees. Hover/tap shows a tooltip for the slot.
class MoneyBarChart extends StatelessWidget {
  const MoneyBarChart({
    super.key,
    required this.labels,
    required this.series,
    this.tooltipTitles,
    this.height = 220,
    this.minLabelWidth = 34,
    this.extraTooltip,
  });

  /// Bottom axis label per slot.
  final List<String> labels;

  /// Long title per slot for the tooltip (defaults to [labels]).
  final List<String>? tooltipTitles;
  final List<BarSeries> series;
  final double height;
  final double minLabelWidth;

  /// Optional extra tooltip line per slot (e.g. order count).
  final String Function(int index)? extraTooltip;

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    final n = labels.length;
    final maxV = series.fold<int>(0, (a, s) => math.max(a, s.values.fold<int>(0, math.max))) / 100;
    final (interval, maxY) = niceAxis(maxV.toDouble());
    const leftReserved = 44.0;
    return SizedBox(
      height: height,
      child: LayoutBuilder(builder: (context, c) {
        final plotW = math.max(40.0, c.maxWidth - leftReserved);
        final slot = plotW / math.max(1, n);
        final rods = series.length;
        final rodW = ((slot * 0.62 - (rods - 1) * 2) / rods).clamp(2.0, 24.0);
        final radius = Radius.circular(math.min(4, rodW / 2));
        final every = math.max(1, (minLabelWidth / slot).ceil());
        return BarChart(
          duration: const Duration(milliseconds: 260),
          BarChartData(
            minY: 0,
            maxY: maxY,
            alignment: BarChartAlignment.spaceAround,
            groupsSpace: 0,
            barGroups: [
              for (var i = 0; i < n; i++)
                BarChartGroupData(
                  x: i,
                  barsSpace: 2,
                  barRods: [
                    for (final s in series)
                      BarChartRodData(
                        toY: (s.values[i] / 100).toDouble(),
                        color: s.color,
                        width: rodW,
                        borderRadius: BorderRadius.vertical(top: radius),
                      ),
                  ],
                ),
            ],
            gridData: FlGridData(
              drawVerticalLine: false,
              horizontalInterval: interval,
              getDrawingHorizontalLine: (_) => FlLine(color: ec.border, strokeWidth: 1),
            ),
            borderData: FlBorderData(show: true, border: Border(bottom: BorderSide(color: ec.border))),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(),
              rightTitles: const AxisTitles(),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: leftReserved,
                  interval: interval,
                  getTitlesWidget: (v, meta) => SideTitleWidget(
                    meta: meta,
                    space: 6,
                    child: Text(compactRupees(v * 100), style: _axisStyle(context)),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 26,
                  getTitlesWidget: (v, meta) {
                    final i = v.toInt();
                    if (i < 0 || i >= n || i % every != 0) return const SizedBox.shrink();
                    return SideTitleWidget(meta: meta, space: 6, child: Text(labels[i], style: _axisStyle(context)));
                  },
                ),
              ),
            ),
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (_) => ec.text,
                tooltipBorderRadius: BorderRadius.circular(8),
                tooltipPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                tooltipMargin: 8,
                maxContentWidth: 200,
                fitInsideHorizontally: true,
                fitInsideVertically: true,
                getTooltipItem: (group, gi, rod, ri) {
                  final s = series[ri];
                  final value = rs(s.values[gi]);
                  final line = rods > 1 ? '${s.label}  $value' : value;
                  final title = (tooltipTitles ?? labels)[gi];
                  final extra = ri == rods - 1 && extraTooltip != null ? '\n${extraTooltip!(gi)}' : '';
                  return BarTooltipItem(
                    ri == 0 ? '$title\n' : '',
                    _tipStyle(context, bold: true)!,
                    textAlign: TextAlign.left,
                    children: [TextSpan(text: '$line$extra', style: _tipStyle(context))],
                  );
                },
              ),
            ),
          ),
        );
      }),
    );
  }
}

/// Line chart of money per slot (used for long date ranges).
class MoneyLineChart extends StatelessWidget {
  const MoneyLineChart({super.key, required this.labels, required this.values, this.tooltipTitles, this.height = 220, this.minLabelWidth = 48});
  final List<String> labels;
  final List<String>? tooltipTitles;
  final List<int> values;
  final double height;
  final double minLabelWidth;

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    final n = values.length;
    final (interval, maxY) = niceAxis(values.fold<int>(0, math.max) / 100);
    const leftReserved = 44.0;
    return SizedBox(
      height: height,
      child: LayoutBuilder(builder: (context, c) {
        final plotW = math.max(40.0, c.maxWidth - leftReserved);
        final every = math.max(1, (minLabelWidth / (plotW / math.max(1, n - 1))).ceil());
        return LineChart(
          duration: const Duration(milliseconds: 260),
          LineChartData(
            minY: 0,
            maxY: maxY,
            minX: 0,
            maxX: math.max(1, n - 1).toDouble(),
            lineBarsData: [
              LineChartBarData(
                spots: [for (var i = 0; i < n; i++) FlSpot(i.toDouble(), values[i] / 100)],
                color: ec.primary,
                barWidth: 2,
                isCurved: false,
                isStrokeCapRound: true,
                isStrokeJoinRound: true,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(show: true, color: ec.primary.withValues(alpha: 0.10)),
              ),
            ],
            gridData: FlGridData(
              drawVerticalLine: false,
              horizontalInterval: interval,
              getDrawingHorizontalLine: (_) => FlLine(color: ec.border, strokeWidth: 1),
            ),
            borderData: FlBorderData(show: true, border: Border(bottom: BorderSide(color: ec.border))),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(),
              rightTitles: const AxisTitles(),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: leftReserved,
                  interval: interval,
                  getTitlesWidget: (v, meta) => SideTitleWidget(meta: meta, space: 6, child: Text(compactRupees(v * 100), style: _axisStyle(context))),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 26,
                  interval: 1,
                  getTitlesWidget: (v, meta) {
                    final i = v.round();
                    if ((v - i).abs() > 0.01 || i < 0 || i >= n || i % every != 0) return const SizedBox.shrink();
                    return SideTitleWidget(meta: meta, space: 6, child: Text(labels[i], style: _axisStyle(context)));
                  },
                ),
              ),
            ),
            lineTouchData: LineTouchData(
              getTouchedSpotIndicator: (bar, idx) => [
                for (final _ in idx)
                  TouchedSpotIndicatorData(
                    FlLine(color: ec.textFaint, strokeWidth: 1),
                    FlDotData(
                      getDotPainter: (s, p, b, i) => FlDotCirclePainter(radius: 4.5, color: ec.primary, strokeWidth: 2, strokeColor: ec.surface),
                    ),
                  ),
              ],
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (_) => ec.text,
                tooltipBorderRadius: BorderRadius.circular(8),
                tooltipPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                fitInsideHorizontally: true,
                fitInsideVertically: true,
                maxContentWidth: 200,
                getTooltipItems: (spots) => [
                  for (final s in spots)
                    LineTooltipItem(
                      '${(tooltipTitles ?? labels)[s.x.round()]}\n',
                      _tipStyle(context, bold: true)!,
                      textAlign: TextAlign.left,
                      children: [TextSpan(text: rs(values[s.x.round()]), style: _tipStyle(context))],
                    ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

/// Business dates from [from] to [to] inclusive (yyyy-MM-dd).
List<String> datesBetween(String from, String to) {
  final f = DateFormat('yyyy-MM-dd');
  DateTime p(String s) {
    final d = DateTime.parse(s);
    return DateTime.utc(d.year, d.month, d.day);
  }

  final out = <String>[];
  var d = p(from);
  final end = p(to);
  while (!d.isAfter(end) && out.length < 1000) {
    out.add(f.format(d));
    d = d.add(const Duration(days: 1));
  }
  return out;
}

// ───────────── Horizontal bars ─────────────

class BarListEntry {
  const BarListEntry(this.label, this.value, {this.detail, this.icon});
  final String label;

  /// Paisa.
  final int value;
  final String? detail;
  final IconData? icon;
}

/// Ranked horizontal bars with direct labels: label · value, then a share bar and %.
class BarList extends StatelessWidget {
  const BarList({super.key, required this.entries, this.empty = 'Nothing yet', this.color});
  final List<BarListEntry> entries;
  final String empty;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    final total = entries.fold<int>(0, (a, e) => a + e.value);
    if (entries.isEmpty || total == 0) return ChartEmpty(height: 110, message: empty);
    final max = entries.fold<int>(0, (a, e) => math.max(a, e.value));
    final sorted = [...entries]..sort((a, b) => b.value.compareTo(a.value));
    return Column(children: [
      for (final e in sorted)
        Tooltip(
          message: '${e.label}: ${rs(e.value)} · ${(e.value / total * 100).toStringAsFixed(1)}%${e.detail == null ? '' : ' · ${e.detail}'}',
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Row(children: [
                if (e.icon != null) ...[Icon(e.icon, size: 16, color: ec.textMuted), const SizedBox(width: 6)],
                Expanded(
                  child: Text.rich(
                    TextSpan(children: [
                      TextSpan(text: e.label, style: context.tt.labelLarge),
                      if (e.detail != null) TextSpan(text: '  ${e.detail}', style: context.tt.bodySmall?.copyWith(fontFeatures: tabular)),
                    ]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: Sp.sm),
                Text(rs(e.value), style: context.tt.labelLarge?.copyWith(fontFeatures: tabular)),
              ]),
              const SizedBox(height: 6),
              Row(children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      height: 8,
                      color: ec.surfaceAlt,
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: max == 0 ? 0 : (e.value / max).clamp(0.0, 1.0),
                        child: Container(decoration: BoxDecoration(color: color ?? ec.primary, borderRadius: BorderRadius.circular(4))),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 52,
                  child: Text('${(e.value / total * 100).round()}%',
                      textAlign: TextAlign.right, style: context.tt.bodySmall?.copyWith(fontFeatures: tabular, color: ec.textMuted)),
                ),
              ]),
            ]),
          ),
        ),
    ]);
  }
}

// ───────────── Tables ─────────────

/// One row of a compact numeric table. [cells] after the first are right-aligned.
class TableRowLine extends StatelessWidget {
  const TableRowLine({super.key, required this.cells, this.widths = const [], this.header = false, this.bold = false, this.leading});
  final List<String> cells;

  /// Fixed widths for the numeric columns (one per cell after the first).
  final List<double> widths;
  final bool header;
  final bool bold;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    final base = header
        ? context.tt.labelSmall?.copyWith(color: ec.textMuted)
        : (bold ? context.tt.labelLarge : context.tt.bodyMedium)?.copyWith(fontFeatures: tabular);
    return Container(
      padding: EdgeInsets.symmetric(vertical: header ? 6 : 9),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: header ? ec.border : ec.border.withValues(alpha: 0.6)))),
      child: Row(children: [
        if (leading != null) ...[leading!, const SizedBox(width: Sp.sm)],
        Expanded(child: Text(header ? cells.first.toUpperCase() : cells.first, style: base?.copyWith(fontFeatures: const []), maxLines: 1, overflow: TextOverflow.ellipsis)),
        for (var i = 1; i < cells.length; i++)
          SizedBox(
            width: i - 1 < widths.length ? widths[i - 1] : 88,
            child: Text(header ? cells[i].toUpperCase() : cells[i], textAlign: TextAlign.right, style: base, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
      ]),
    );
  }
}

/// Top items by quantity: rank, name, qty, sales.
class TopItemsTable extends StatelessWidget {
  const TopItemsTable({super.key, required this.items, this.empty = 'No items sold yet'});
  final List<ItemStat> items;
  final String empty;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return ChartEmpty(height: 110, message: empty);
    final ec = context.ec;
    const widths = [52.0, 96.0];
    return Column(children: [
      const TableRowLine(cells: ['Item', 'Qty', 'Sales'], widths: widths, header: true),
      for (var i = 0; i < items.length; i++)
        TableRowLine(
          leading: Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: i < 3 ? ec.primaryContainer : ec.surfaceAlt, borderRadius: BorderRadius.circular(6)),
            child: Text('${i + 1}', style: context.tt.labelSmall?.copyWith(color: i < 3 ? ec.onPrimaryContainer : ec.textMuted, letterSpacing: 0)),
          ),
          cells: [items[i].name, '${items[i].qty}', num0(items[i].amount)],
          widths: widths,
        ),
    ]);
  }
}

/// Splits a SalesReport tax key ("GST 15% · Cash") into its rate label and payment group.
(String rate, String group) splitTaxKey(String key) {
  final i = key.lastIndexOf(' · ');
  if (i < 0) return (key, '');
  return (key.substring(0, i), key.substring(i + 3));
}

/// Tax collected per rate and payment group, so cash vs card/online rates are visible.
class TaxByRateTable extends StatelessWidget {
  const TaxByRateTable({super.key, required this.taxByRate});
  final Map<String, int> taxByRate;

  @override
  Widget build(BuildContext context) {
    if (taxByRate.isEmpty) return const ChartEmpty(height: 90, message: 'No tax collected in this period');
    final rows = taxByRate.entries.toList()
      ..sort((a, b) {
        final ga = splitTaxKey(a.key).$2, gb = splitTaxKey(b.key).$2;
        final g = ga.compareTo(gb);
        return g != 0 ? g : b.value.compareTo(a.value);
      });
    final total = rows.fold<int>(0, (a, e) => a + e.value);
    return Column(children: [
      const TableRowLine(cells: ['Tax · paid by', 'Amount'], widths: [110], header: true),
      for (final e in rows)
        Builder(builder: (context) {
          final (rate, group) = splitTaxKey(e.key);
          final cash = group.toLowerCase().startsWith('cash');
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: context.ec.border.withValues(alpha: 0.6)))),
            child: Row(children: [
              Expanded(
                child: Wrap(spacing: Sp.sm, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center, children: [
                  Text(rate, style: context.tt.labelLarge),
                  if (group.isNotEmpty)
                    Pill(group, dense: true, tone: cash ? Tone.accent : Tone.info, icon: cash ? Icons.payments_outlined : Icons.credit_card_rounded),
                ]),
              ),
              SizedBox(width: 110, child: Text(num0(e.value), textAlign: TextAlign.right, style: context.tt.bodyMedium?.copyWith(fontFeatures: tabular))),
            ]),
          );
        }),
      TableRowLine(cells: ['Total tax', rs(total)], widths: const [110], bold: true),
    ]);
  }
}
