import 'dart:convert';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/providers.dart';
import '../../app/theme/icons.dart';
import '../../app/theme/tokens.dart';
import '../../core/db/database.dart';
import '../../core/models/order_models.dart';
import '../../core/models/settings_models.dart';
import '../../core/money.dart';
import '../../core/printing/printer_config.dart';
import '../../core/services/reports.dart';
import '../../shared/common.dart';
import 'report_print.dart';
import 'report_widgets.dart';
import 'reports_data.dart';

const _day = Duration(days: 1);

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  RangePreset _preset = RangePreset.today;
  DateSpan? _custom;
  bool _busy = false;

  /// Last rendered report, held (dimmed) while a new range loads so the layout doesn't jump.
  SalesReport? _last;

  // Previous-period report cache.
  Object? _prevKey;
  SalesReport? _prev;

  String get _today => ref.read(servicesProvider).ctx.businessDate();

  DateSpan _span(String today) => _preset == RangePreset.custom && _custom != null ? _custom! : _preset.span(today);

  String _rangeLabel(DateSpan s) {
    final f = DateFormat('EEE d MMM yyyy');
    if (s.from == s.to) return f.format(spanDay(s.from));
    final a = spanDay(s.from), b = spanDay(s.to);
    final left = a.year == b.year ? DateFormat('d MMM').format(a) : DateFormat('d MMM yyyy').format(a);
    return '$left – ${DateFormat('d MMM yyyy').format(b)} · ${spanDays(s)} days';
  }

  Future<void> _pickCustom(String today) async {
    final cur = _span(today);
    final last = spanDay(today);
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime(last.year, last.month, last.day),
      initialDateRange: DateTimeRange(
        start: DateTime(spanDay(cur.from).year, spanDay(cur.from).month, spanDay(cur.from).day),
        end: DateTime(spanDay(cur.to).year, spanDay(cur.to).month, spanDay(cur.to).day),
      ),
      helpText: 'Select report dates',
      saveText: 'Show report',
    );
    if (picked == null || !mounted) return;
    final k = DateFormat('yyyy-MM-dd');
    setState(() {
      _custom = (from: k.format(picked.start), to: k.format(picked.end));
      _preset = RangePreset.custom;
    });
  }

  /// Previous equal-length period. When the range ends today it is cut at the same time of
  /// day, so a half-finished day is compared with the same hours before it.
  SalesReport? _previous(DateSpan span, String today, Map<String, String> cats) {
    final prev = previousSpan(span);
    final po = ref.watch(reportOrdersProvider(prev)).value;
    final pr = ref.watch(reportRefundsProvider(prev)).value;
    if (po == null || pr == null) return _prev;
    final cut = span.to == today ? DateTime.now().subtract(_day * spanDays(span)).millisecondsSinceEpoch : null;
    final key = (identityHashCode(po), identityHashCode(pr), cut == null ? null : cut ~/ 60000, cats.length);
    if (key == _prevKey && _prev != null) return _prev;
    _prevKey = key;
    return _prev = SalesReport(
      cut == null ? po : po.where((o) => o.createdAt <= cut).toList(),
      cut == null ? pr : pr.where((r) => r.createdAt <= cut).toList(),
      categoryNames: cats,
    );
  }

  Future<void> _exportCsv(SalesReport r, DateSpan s) async {
    setState(() => _busy = true);
    try {
      final loc = await getSaveLocation(
        suggestedName: 'essence-sales-${s.from}-${s.to}.csv',
        acceptedTypeGroups: const [XTypeGroup(label: 'CSV', extensions: ['csv'], mimeTypes: ['text/csv'])],
      );
      if (loc == null) return;
      await XFile.fromData(utf8.encode(r.toCsv()), mimeType: 'text/csv').saveTo(loc.path);
      if (mounted) toast(context, 'Exported ${r.orderCount + r.voids.length} orders to CSV', icon: Icons.download_done_rounded);
    } catch (e) {
      if (mounted) toast(context, 'Couldn’t save the CSV: $e', error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _printSummary(SalesReport r, DateSpan s) async {
    setState(() => _busy = true);
    try {
      final doc = buildSalesSummary(r, ref.read(settingsValueProvider), rangeLabel: _rangeLabel(s));
      final res = await ref.read(servicesProvider).printer.print(doc, PrintRole.report);
      if (!mounted) return;
      if (res.nothingConfigured) {
        toast(context, 'No report printer set up on this terminal', error: true, icon: Icons.print_disabled_outlined);
      } else if (!res.ok) {
        toast(context, res.errors.first, error: true, icon: Icons.print_disabled_outlined);
      } else {
        toast(context, 'Sales summary printed', icon: Icons.print_outlined);
      }
    } catch (e) {
      if (mounted) toast(context, 'Printing failed: $e', error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pad = context.isPhone ? Sp.lg : Sp.xl;
    if (!ref.watch(canProvider(Perm.viewReports))) {
      return const EmptyState(
        icon: Icons.lock_outline_rounded,
        title: 'Reports are locked',
        message: 'Your role can’t view sales reports. Ask a manager or the owner.',
      );
    }
    final settings = ref.watch(settingsValueProvider);
    final today = _today;
    final span = _span(today);
    final cats = {for (final c in ref.watch(categoriesProvider).value ?? const <MenuCategory>[]) c.id: c.name};
    final async = ref.watch(salesReportProvider(span));
    final fresh = async.value;
    if (fresh != null) _last = fresh;
    final report = fresh ?? _last;
    final stale = fresh == null && report != null;
    final prev = _previous(span, today, cats);

    final header = PageTitle(
      'Reports',
      subtitle: _rangeLabel(span),
      actions: [
        OutlinedButton.icon(
          onPressed: report == null || _busy ? null : () => _exportCsv(report, span),
          icon: const Icon(Icons.file_download_outlined),
          label: const Text('Export CSV'),
        ),
        FilledButton.icon(
          onPressed: report == null || _busy ? null : () => _printSummary(report, span),
          icon: const Icon(Icons.print_outlined),
          label: const Text('Print summary'),
        ),
      ],
    );

    final chips = Wrap(spacing: Sp.sm, runSpacing: Sp.sm, children: [
      for (final p in RangePreset.values)
        ChoiceChip(
          label: Text(p == RangePreset.custom && _preset == RangePreset.custom && _custom != null ? 'Custom · ${spanDays(_custom!)}d' : p.label),
          avatar: p == RangePreset.custom ? const Icon(Icons.date_range_rounded, size: 18) : null,
          selected: _preset == p,
          showCheckmark: false,
          onSelected: (_) => p == RangePreset.custom ? _pickCustom(today) : setState(() => _preset = p),
        ),
    ]);

    Widget body;
    if (async.hasError && report == null) {
      body = Padding(
        padding: const EdgeInsets.only(top: Sp.xxl),
        child: EmptyState(icon: Icons.error_outline_rounded, title: 'Couldn’t load the report', message: '${async.error}'),
      );
    } else if (report == null) {
      body = const Padding(padding: EdgeInsets.only(top: 80), child: Center(child: CircularProgressIndicator()));
    } else {
      body = AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: stale ? 0.5 : 1,
        child: _ReportBody(report: report, prev: prev, span: span, today: today, settings: settings),
      );
    }

    return Stack(children: [
      ListView(
        padding: EdgeInsets.all(pad),
        children: [
          header,
          chips,
          const SizedBox(height: Sp.lg),
          body,
        ],
      ),
      if (stale || _busy) const Positioned(top: 0, left: 0, right: 0, child: LinearProgressIndicator(minHeight: 2)),
    ]);
  }
}

class _ReportBody extends ConsumerWidget {
  const _ReportBody({required this.report, required this.prev, required this.span, required this.today, required this.settings});
  final SalesReport report;
  final SalesReport? prev;
  final DateSpan span;
  final String today;
  final AppSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ec = context.ec;
    final r = report;
    final n = spanDays(span);
    final endsToday = span.to == today;
    final vs = n == 1 ? (endsToday ? 'vs same time yesterday' : 'vs day before') : 'vs prior $n days';
    (String, Tone?) d(int Function(SalesReport) f, {bool upIsGood = true}) =>
        prev == null ? ('…', null) : deltaCaption(f(r), f(prev!), vs: vs, upIsGood: upIsGood, noPrev: 'Nothing in prior period');

    final net = d((x) => x.netSales);
    final cnt = d((x) => x.orderCount);
    final avg = d((x) => x.avgTicket);
    final tax = d((x) => x.tax);
    final kpis = KpiGrid(children: [
      KpiTile(label: 'Net sales', value: rs(r.netSales), icon: Icons.payments_outlined, caption: net.$1, captionTone: net.$2),
      KpiTile(label: 'Orders', value: '${r.orderCount}', icon: Icons.receipt_long_outlined, caption: cnt.$1, captionTone: cnt.$2, tone: Tone.accent),
      KpiTile(label: 'Average ticket', value: rs(r.avgTicket), icon: Icons.local_cafe_outlined, caption: avg.$1, captionTone: avg.$2, tone: Tone.info),
      KpiTile(label: 'Tax collected', value: rs(r.tax), icon: Icons.account_balance_outlined, caption: tax.$1, tone: Tone.neutral),
      KpiTile(
        label: 'Discounts',
        value: rs(r.discounts),
        icon: Icons.sell_outlined,
        tone: Tone.warning,
        caption: r.gross == 0 ? 'No discounts' : '${(r.discounts / r.gross * 100).toStringAsFixed(1)}% of gross',
      ),
      KpiTile(
        label: 'Refunds',
        value: rs(r.refundTotal),
        icon: Icons.undo_rounded,
        tone: Tone.danger,
        caption: r.refunds.isEmpty ? 'No refunds' : '${r.refunds.length} refund${r.refunds.length == 1 ? '' : 's'}',
      ),
    ]);

    final hasData = r.orderCount > 0 || r.voids.isNotEmpty || r.refunds.isNotEmpty;
    if (!hasData) {
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        kpis,
        const SizedBox(height: Sp.lg),
        const AppCard(
          padding: EdgeInsets.symmetric(vertical: Sp.xl),
          child: EmptyState(
            icon: Icons.insights_outlined,
            title: 'No sales in this period',
            message: 'Pick another range, or check back after the first orders are paid.',
          ),
        ),
      ]);
    }

    // Sales by hour.
    final hours = hourAxis([r.byHour], settings.store.dayStartHour);
    final hourCard = ReportCard(
      title: 'Sales by hour',
      subtitle: n == 1 ? 'Total collected per hour' : 'All $n days combined',
      child: hours.isEmpty
          ? const ChartEmpty()
          : MoneyBarChart(
              labels: [for (final h in hours) hourLabel(h, short: true)],
              tooltipTitles: [for (final h in hours) hourRangeLabel(h)],
              series: [BarSeries(label: 'Sales', color: ec.primary, values: [for (final h in hours) r.byHour[h] ?? 0])],
            ),
    );

    // Payment methods.
    final methodIcons = {for (final m in ref.watch(paymentMethodsProvider).value ?? const <PaymentMethod>[]) m.name: iconFor(m.icon, fallback: Icons.payments_outlined)};
    final payCard = ReportCard(
      title: 'Payment methods',
      subtitle: 'Share of money collected',
      child: BarList(
        empty: 'No payments yet',
        entries: [for (final e in r.byMethod.entries) BarListEntry(e.key, e.value, icon: methodIcons[e.key] ?? Icons.payments_outlined)],
      ),
    );

    // Sales by day.
    Widget? dayCard;
    if (n > 1) {
      final dates = datesBetween(span.from, span.to);
      final short = dates.length <= 7;
      final labels = [for (final x in dates) DateFormat(short ? 'EEE' : 'd MMM').format(spanDay(x))];
      final titles = [for (final x in dates) DateFormat('EEE d MMM').format(spanDay(x))];
      final values = [for (final x in dates) r.byDay[x] ?? 0];
      final best = r.byDay.entries.fold<MapEntry<String, int>?>(null, (a, e) => a == null || e.value > a.value ? e : a);
      dayCard = ReportCard(
        title: 'Sales by day',
        subtitle: best == null ? 'Total collected per business day' : 'Best day ${DateFormat('EEE d MMM').format(spanDay(best.key))} · ${rs(best.value)}',
        child: dates.length > 31
            ? MoneyLineChart(labels: labels, tooltipTitles: titles, values: values)
            : MoneyBarChart(
                labels: labels,
                tooltipTitles: titles,
                minLabelWidth: short ? 34 : 50,
                series: [BarSeries(label: 'Sales', color: ec.primary, values: values)],
                extraTooltip: (i) {
                  final c = r.ordersByDay[dates[i]] ?? 0;
                  return '$c order${c == 1 ? '' : 's'}';
                },
              ),
      );
    }

    // Order types.
    final typeCard = ReportCard(
      title: 'Order types',
      subtitle: 'Dine-in, takeaway and delivery',
      child: BarList(
        empty: 'No orders yet',
        entries: [
          for (final t in OrderType.values)
            if ((r.byType[t] ?? 0) > 0)
              BarListEntry(t.label, r.byType[t]!, icon: _typeIcon(t), detail: _count(r.orders.where((o) => o.type == t).length, 'order')),
        ],
      ),
    );

    final catCard = ReportCard(
      title: 'Sales by category',
      subtitle: 'Item value after discounts',
      child: BarList(empty: 'No items sold yet', entries: [for (final e in r.byCategory.entries) BarListEntry(e.key, e.value)]),
    );

    final topCard = ReportCard(
      title: 'Top items',
      subtitle: '${r.itemsSold} items sold',
      child: TopItemsTable(items: r.topItems(10)),
    );

    final taxCard = ReportCard(
      title: 'Tax by rate',
      subtitle: 'Cash and card / online are taxed at different rates',
      child: TaxByRateTable(taxByRate: r.taxByRate),
    );

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      kpis,
      const SizedBox(height: Sp.lg),
      SplitRow(flex: const [3, 2], minChildWidth: 380, children: [hourCard, payCard]),
      if (dayCard != null) ...[const SizedBox(height: Sp.lg), dayCard],
      const SizedBox(height: Sp.lg),
      SplitRow(minChildWidth: 380, children: [typeCard, catCard]),
      const SizedBox(height: Sp.lg),
      SplitRow(minChildWidth: 380, children: [topCard, taxCard]),
      const SizedBox(height: Sp.lg),
      SplitRow(minChildWidth: 380, children: [_FbrCard(report: r, fbrEnabled: settings.fbr.enabled), _VoidsCard(report: r)]),
    ]);
  }
}

String _count(int n, String noun) => '$n $noun${n == 1 ? '' : 's'}';

IconData _typeIcon(OrderType t) => switch (t) {
      OrderType.dineIn => Icons.table_restaurant_outlined,
      OrderType.takeaway => Icons.shopping_bag_outlined,
      OrderType.delivery => Icons.delivery_dining_outlined,
    };

class _StatLine extends StatelessWidget {
  const _StatLine({required this.icon, required this.tone, required this.label, required this.value, this.detail});
  final IconData icon;
  final Tone tone;
  final String label;
  final String value;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    final (fg, bg) = tone.colors(context.ec);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 18, color: fg),
        ),
        const SizedBox(width: Sp.md),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: context.tt.labelLarge),
            if (detail != null) Text(detail!, style: context.tt.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
          ]),
        ),
        const SizedBox(width: Sp.sm),
        Text(value, style: context.tt.titleMedium?.copyWith(fontFeatures: tabular)),
      ]),
    );
  }
}

class _FbrCard extends StatelessWidget {
  const _FbrCard({required this.report, required this.fbrEnabled});
  final SalesReport report;
  final bool fbrEnabled;

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    final r = report;
    final failed = r.orders.where((o) => o.fiscalStatus == 'failed').length;
    final none = r.orderCount - r.fiscalReported - r.fiscalPending - failed;
    final fiscal = r.fiscalReported + r.fiscalPending + failed;
    final share = fiscal == 0 ? 0.0 : r.fiscalReported / fiscal;
    return ReportCard(
      title: 'FBR invoices',
      subtitle: fbrEnabled ? 'Sales reported to FBR' : 'FBR integration is off in settings',
      trailing: fiscal == 0
          ? null
          : Pill(
              r.fiscalPending + failed == 0 ? 'All reported' : '${r.fiscalPending + failed} waiting',
              tone: r.fiscalPending + failed == 0 ? Tone.success : Tone.warning,
              icon: r.fiscalPending + failed == 0 ? Icons.verified_outlined : Icons.schedule_rounded,
            ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        if (fiscal > 0) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(value: share, minHeight: 8, color: ec.success, backgroundColor: ec.surfaceAlt),
          ),
          const SizedBox(height: Sp.sm),
        ],
        _StatLine(icon: Icons.check_circle_outline_rounded, tone: Tone.success, label: 'Reported', value: '${r.fiscalReported}', detail: 'FBR invoice number issued'),
        _StatLine(
          icon: Icons.schedule_rounded,
          tone: Tone.warning,
          label: 'Pending',
          value: '${r.fiscalPending}',
          detail: 'Will report automatically when online',
        ),
        if (failed > 0) _StatLine(icon: Icons.error_outline_rounded, tone: Tone.danger, label: 'Failed', value: '$failed', detail: 'Retried by the till; check Orders'),
        if (none > 0) _StatLine(icon: Icons.remove_circle_outline_rounded, tone: Tone.neutral, label: 'Not fiscal', value: '$none', detail: 'Sold while FBR was off'),
      ]),
    );
  }
}

class _VoidsCard extends StatelessWidget {
  const _VoidsCard({required this.report});
  final SalesReport report;

  @override
  Widget build(BuildContext context) {
    final r = report;
    final voids = [...r.voids]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final t = DateFormat('d MMM h:mm a');
    return ReportCard(
      title: 'Voids',
      subtitle: voids.isEmpty ? 'No voided orders' : '${_count(voids.length, 'order')} · ${rs(r.voidTotal)}',
      trailing: voids.isEmpty ? const Pill('None', tone: Tone.success, icon: Icons.check_rounded) : Pill('${voids.length}', tone: Tone.danger, icon: Icons.block_rounded),
      child: voids.isEmpty
          ? const ChartEmpty(height: 90, message: 'Nothing was voided in this period')
          : Column(children: [
              for (final o in voids.take(6))
                _StatLine(
                  icon: Icons.block_rounded,
                  tone: Tone.danger,
                  label: o.displayNumber,
                  value: num0(o.total),
                  detail: [
                    t.format(o.created),
                    if (o.voidedBy?.isNotEmpty == true) o.voidedBy!,
                    if (o.voidReason?.isNotEmpty == true) o.voidReason!,
                  ].join(' · '),
                ),
              if (voids.length > 6)
                Padding(
                  padding: const EdgeInsets.only(top: Sp.xs),
                  child: Text('+ ${voids.length - 6} more in the CSV export', style: context.tt.bodySmall),
                ),
            ]),
    );
  }
}
