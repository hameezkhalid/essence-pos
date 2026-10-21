import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../app/theme/tokens.dart';
import '../core/db/database.dart';
import '../core/models/order_models.dart';
import '../core/money.dart';
import '../core/services/reports.dart';
import '../features/reports/report_widgets.dart';
import '../shared/common.dart';
import 'live_store.dart';

final _clock = DateFormat('h:mm a');

String _ago(int ms) {
  if (ms <= 0) return 'never';
  final d = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(ms));
  if (d.inSeconds < 60) return 'just now';
  if (d.inMinutes < 60) return '${d.inMinutes} min ago';
  if (d.inHours < 24) return '${d.inHours}h ago';
  if (d.inDays < 7) return '${d.inDays}d ago';
  return DateFormat('d MMM').format(DateTime.fromMillisecondsSinceEpoch(ms));
}

IconData _typeIcon(OrderType t) => switch (t) {
      OrderType.dineIn => Icons.table_restaurant_outlined,
      OrderType.takeaway => Icons.shopping_bag_outlined,
      OrderType.delivery => Icons.delivery_dining_outlined,
    };

/// Live owner dashboard (reads Firestore directly). Shown as the Dashboard tab of the web admin panel.
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late final LiveStore _store = LiveStore(FirebaseFirestore.instance)..start();

  /// Orders already on screen; anything else in the feed animates in.
  final _seen = <String>{};
  bool _seeded = false;
  bool _everLoaded = false;

  @override
  void dispose() {
    _store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation: _store, builder: (context, _) => _build(context));

  Widget _build(BuildContext context) {
    final s = _store;
    final pad = context.isPhone ? Sp.lg : Sp.xl;
    if (s.salesLoaded) _everLoaded = true;
    if (!_seeded && s.ordersLoaded) {
      _seen.addAll(s.recent.map((o) => o.id));
      _seeded = true;
    }

    final Widget content;
    if (!_everLoaded && s.error == null) {
      content = const Padding(padding: EdgeInsets.only(top: 120), child: Center(child: CircularProgressIndicator()));
    } else {
      content = Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        if (s.error != null) ...[_ErrorBanner(error: s.error!), const SizedBox(height: Sp.lg)],
        _Kpis(store: s),
        const SizedBox(height: Sp.lg),
        SplitRow(flex: const [3, 2], minChildWidth: 400, children: [_HourlyCard(store: s), _PaymentsCard(report: s.todayReport)]),
        const SizedBox(height: Sp.lg),
        SplitRow(flex: const [3, 2], minChildWidth: 400, children: [
          _feed(context),
          Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            ReportCard(
              title: 'Top items today',
              subtitle: '${s.todayReport.itemsSold} items sold',
              child: TopItemsTable(items: s.todayReport.topItems(8), empty: 'Nothing sold yet today'),
            ),
            const SizedBox(height: Sp.lg),
            _StockCard(store: s),
            const SizedBox(height: Sp.lg),
            _TerminalsCard(store: s),
          ]),
        ]),
        const SizedBox(height: Sp.xl),
        Center(
          child: Text('Essence Dashboard · updates live from every till', style: context.tt.bodySmall?.copyWith(color: context.ec.textFaint)),
        ),
      ]);
    }

    return ListView(
      padding: EdgeInsets.all(pad),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1600),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [_Header(store: s), content]),
          ),
        ),
      ],
    );
  }

  Widget _feed(BuildContext context) {
    final s = _store;
    final rows = <Widget>[];
    for (final o in s.recent) {
      final isNew = _seeded && !_seen.contains(o.id);
      _seen.add(o.id);
      rows.add(_FeedRow(key: ValueKey(o.id), order: o, animate: isNew, yesterday: o.businessDate == s.yesterday));
    }
    final todayCount = s.todayReport.orderCount;
    return ReportCard(
      title: 'Live orders',
      subtitle: 'Latest ${math.min(15, s.recent.length)} · today and yesterday',
      trailing: Pill('$todayCount today', tone: Tone.primary, icon: Icons.receipt_long_outlined),
      child: rows.isEmpty
          ? const ChartEmpty(height: 140, message: 'No orders yet — new sales appear here the moment they’re paid')
          : Column(children: [
              for (var i = 0; i < rows.length; i++) ...[
                if (i > 0) Divider(height: 1, color: context.ec.border.withValues(alpha: 0.6)),
                rows[i],
              ],
            ]),
    );
  }
}

// ───────────── Header ─────────────

class _Header extends StatelessWidget {
  const _Header({required this.store});
  final LiveStore store;

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    final live = store.error == null && !store.fromCache;
    final date = DateFormat(context.isPhone ? 'EEE d MMM' : 'EEEE d MMMM yyyy').format(DateTime.now());
    return PageTitle(
      'Dashboard',
      subtitle: date,
      actions: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(color: live ? ec.successContainer : ec.warningContainer, borderRadius: BorderRadius.circular(99)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            _LiveDot(color: live ? ec.success : ec.warning, pulse: live),
            const SizedBox(width: 8),
            Text(live ? 'Live from every till' : (store.error != null ? 'Paused' : 'Connecting…'),
                style: context.tt.labelMedium?.copyWith(color: live ? ec.success : ec.warning)),
          ]),
        ),
      ],
    );
  }
}

/// Small status dot with a soft pulse ring (static when animations are reduced).
class _LiveDot extends StatefulWidget {
  const _LiveDot({required this.color, required this.pulse});
  final Color color;
  final bool pulse;
  @override
  State<_LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<_LiveDot> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800));

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animate = widget.pulse && !MediaQuery.disableAnimationsOf(context);
    if (animate && !_c.isAnimating) _c.repeat();
    if (!animate && _c.isAnimating) _c.stop();
    return SizedBox(
      width: 18,
      height: 18,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final t = Curves.easeOut.transform(_c.value);
          return Stack(alignment: Alignment.center, children: [
            if (animate)
              Container(
                width: 8 + 10 * t,
                height: 8 + 10 * t,
                decoration: BoxDecoration(shape: BoxShape.circle, color: widget.color.withValues(alpha: 0.45 * (1 - t))),
              ),
            Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: widget.color)),
          ]);
        },
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.error});
  final Object error;
  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    final denied = error is FirebaseException && (error as FirebaseException).code == 'permission-denied';
    return AppCard(
      color: ec.dangerContainer,
      borderColor: ec.dangerContainer,
      padding: const EdgeInsets.all(Sp.md),
      child: Row(children: [
        Icon(denied ? Icons.lock_outline_rounded : Icons.cloud_off_rounded, color: ec.danger),
        const SizedBox(width: Sp.md),
        Expanded(
          child: Text(
            denied ? 'This account doesn’t have access to the Essence store.' : 'Live updates paused: $error',
            style: context.tt.bodyMedium?.copyWith(color: ec.text),
          ),
        ),
      ]),
    );
  }
}

// ───────────── KPIs ─────────────

class _Kpis extends StatelessWidget {
  const _Kpis({required this.store});
  final LiveStore store;

  @override
  Widget build(BuildContext context) {
    final t = store.todayReport;
    final y = store.yesterdaySoFar;
    const vs = 'vs yesterday';
    final net = deltaCaption(t.netSales, y.netSales, vs: vs, noPrev: 'No sales yesterday by now');
    final cnt = deltaCaption(t.orderCount, y.orderCount, vs: vs, noPrev: 'No orders yesterday by now');
    final avg = deltaCaption(t.avgTicket, y.avgTicket, vs: vs, noPrev: 'Nothing to compare yet');
    var cashTax = 0, cardTax = 0;
    for (final e in t.taxByRate.entries) {
      if (splitTaxKey(e.key).$2.toLowerCase().startsWith('cash')) {
        cashTax += e.value;
      } else {
        cardTax += e.value;
      }
    }
    final tiles = [
      KpiTile(label: 'Net sales today', value: rs(t.netSales), icon: Icons.payments_outlined, caption: net.$1, captionTone: net.$2),
      KpiTile(label: 'Orders', value: '${t.orderCount}', icon: Icons.receipt_long_outlined, tone: Tone.accent, caption: cnt.$1, captionTone: cnt.$2),
      KpiTile(label: 'Average ticket', value: rs(t.avgTicket), icon: Icons.local_cafe_outlined, tone: Tone.info, caption: avg.$1, captionTone: avg.$2),
      KpiTile(
        label: 'Tax collected',
        value: rs(t.tax),
        icon: Icons.account_balance_outlined,
        tone: Tone.neutral,
        caption: t.tax == 0 ? 'No tax yet today' : 'Cash ${num0(cashTax)} · Card ${num0(cardTax)}',
      ),
      KpiTile(
        label: 'Refunds',
        value: rs(t.refundTotal),
        icon: Icons.undo_rounded,
        tone: Tone.danger,
        caption: t.refunds.isEmpty ? 'No refunds today' : '${t.refunds.length} refund${t.refunds.length == 1 ? '' : 's'}',
      ),
    ];
    return LayoutBuilder(builder: (context, c) {
      const gap = Sp.md;
      final cols = (c.maxWidth / 190).floor().clamp(2, 5);
      final w = (c.maxWidth - gap * (cols - 1)) / cols;
      // On two-column phones the headline figure spans the full width.
      final heroFull = cols == 2;
      return Wrap(spacing: gap, runSpacing: gap, children: [
        for (var i = 0; i < tiles.length; i++) SizedBox(width: heroFull && i == 0 ? c.maxWidth : w, child: tiles[i]),
      ]);
    });
  }
}

// ───────────── Charts ─────────────

class _HourlyCard extends StatelessWidget {
  const _HourlyCard({required this.store});
  final LiveStore store;

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    final t = store.todayReport.byHour;
    final y = store.yesterdayFull.byHour;
    final hours = hourAxis([t, y], store.settings.dayStartHour, includeHour: DateTime.now().hour);
    final hasData = t.isNotEmpty || y.isNotEmpty;
    return ReportCard(
      title: 'Sales by hour',
      subtitle: 'Today compared with all of yesterday',
      legend: hasData ? ChartLegend([LegendItem('Today', ec.primary), LegendItem('Yesterday', ec.textFaint)]) : null,
      child: !hasData
          ? const ChartEmpty(height: 200, message: 'No sales yet today or yesterday')
          : MoneyBarChart(
              height: 240,
              labels: [for (final h in hours) hourLabel(h, short: true)],
              tooltipTitles: [for (final h in hours) hourRangeLabel(h)],
              series: [
                BarSeries(label: 'Today', color: ec.primary, values: [for (final h in hours) t[h] ?? 0]),
                BarSeries(label: 'Yesterday', color: ec.textFaint, values: [for (final h in hours) y[h] ?? 0]),
              ],
            ),
    );
  }
}

class _PaymentsCard extends StatelessWidget {
  const _PaymentsCard({required this.report});
  final SalesReport report;

  @override
  Widget build(BuildContext context) {
    final types = [
      for (final t in OrderType.values)
        if ((report.byType[t] ?? 0) > 0)
          BarListEntry(t.label, report.byType[t]!, icon: _typeIcon(t), detail: '${report.orders.where((o) => o.type == t).length}'),
    ];
    return ReportCard(
      title: 'Payment mix',
      subtitle: 'Money collected today by method',
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        BarList(
          empty: 'No payments yet today',
          entries: [
            for (final e in report.byMethod.entries)
              BarListEntry(e.key, e.value, icon: e.key.toLowerCase().contains('cash') ? Icons.payments_outlined : Icons.credit_card_rounded),
          ],
        ),
        if (types.isNotEmpty) ...[
          const SizedBox(height: Sp.md),
          Text('ORDER TYPES', style: context.tt.labelSmall),
          const SizedBox(height: Sp.xs),
          BarList(entries: types, color: context.ec.accent),
        ],
      ]),
    );
  }
}

// ───────────── Live feed ─────────────

class _FeedRow extends StatefulWidget {
  const _FeedRow({super.key, required this.order, required this.animate, required this.yesterday});
  final Order order;
  final bool animate;
  final bool yesterday;

  @override
  State<_FeedRow> createState() => _FeedRowState();
}

class _FeedRowState extends State<_FeedRow> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2600), value: widget.animate ? 0 : 1);
  late final Animation<double> _size = CurvedAnimation(parent: _c, curve: const Interval(0, 0.18, curve: Curves.easeOutCubic));
  late final Animation<double> _fade = CurvedAnimation(parent: _c, curve: const Interval(0.05, 0.25, curve: Curves.easeOut));
  late final Animation<double> _glow = CurvedAnimation(parent: _c, curve: const Interval(0.3, 1, curve: Curves.easeIn));

  @override
  void initState() {
    super.initState();
    if (widget.animate) _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    final o = widget.order;
    final voided = o.status == OrderStatus.voided;
    final refunded = o.status == OrderStatus.refunded || o.status == OrderStatus.partiallyRefunded;
    final methods = o.payments.map((p) => p.methodName).toSet().join(' + ');
    final items = o.itemCount;
    final meta = [
      '${widget.yesterday ? 'Yesterday ' : ''}${_clock.format(o.created)}',
      o.type.label,
      '$items item${items == 1 ? '' : 's'}',
      if (methods.isNotEmpty) methods,
    ].join(' · ');

    final row = Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: Sp.sm),
      child: Row(children: [
        IconBadge(icon: _typeIcon(o.type), color: voided ? ec.danger : ec.primary, size: 38),
        const SizedBox(width: Sp.md),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text.rich(
              TextSpan(children: [
                TextSpan(text: o.displayNumber, style: context.tt.labelLarge?.copyWith(fontFeatures: tabular)),
                if (o.token != null) TextSpan(text: '  ${o.tokenLabel}', style: context.tt.labelMedium?.copyWith(color: ec.textMuted, fontFeatures: tabular)),
              ]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(meta, style: context.tt.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
          ]),
        ),
        const SizedBox(width: Sp.sm),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(
            rs(o.total),
            style: context.tt.titleSmall?.copyWith(
              fontFeatures: tabular,
              decoration: voided ? TextDecoration.lineThrough : null,
              color: voided ? ec.textMuted : ec.text,
            ),
          ),
          const SizedBox(height: 3),
          Row(mainAxisSize: MainAxisSize.min, children: [
            if (voided) const Pill('Voided', tone: Tone.danger, dense: true),
            if (refunded) Pill(o.status == OrderStatus.refunded ? 'Refunded' : 'Part refund', tone: Tone.warning, dense: true),
            if (voided || refunded) const SizedBox(width: 4),
            _FbrIcon(order: o),
          ]),
        ]),
      ]),
    );

    return SizeTransition(
      sizeFactor: _size,
      alignment: Alignment.topCenter,
      child: FadeTransition(
        opacity: _fade,
        child: AnimatedBuilder(
          animation: _glow,
          builder: (context, child) => DecoratedBox(
            decoration: BoxDecoration(
              color: Color.lerp(ec.primaryContainer, ec.primaryContainer.withValues(alpha: 0), _glow.value),
              borderRadius: BorderRadius.circular(Rad.sm),
            ),
            child: child,
          ),
          child: row,
        ),
      ),
    );
  }
}

class _FbrIcon extends StatelessWidget {
  const _FbrIcon({required this.order});
  final Order order;
  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    final (icon, color, tip) = switch (order.fiscalStatus) {
      'reported' => (Icons.verified_rounded, ec.success, 'Reported to FBR${order.fiscalInvoiceNo == null ? '' : ' · ${order.fiscalInvoiceNo}'}'),
      'pending' => (Icons.schedule_rounded, ec.warning, 'FBR pending — reports automatically'),
      'failed' => (Icons.error_outline_rounded, ec.danger, 'FBR reporting failed${order.fiscalError == null ? '' : ': ${order.fiscalError}'}'),
      _ => (Icons.remove_rounded, ec.textFaint, 'Not reported to FBR'),
    };
    return Tooltip(message: tip, child: Icon(icon, size: 16, color: color, semanticLabel: tip));
  }
}

// ───────────── Stock & terminals ─────────────

class _StockCard extends StatelessWidget {
  const _StockCard({required this.store});
  final LiveStore store;

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    final st = store.stock;
    if (!store.stockLoaded) {
      return const ReportCard(title: 'Low stock', child: SizedBox(height: 80, child: Center(child: CircularProgressIndicator())));
    }
    if (st == null) {
      return const ReportCard(
        title: 'Low stock',
        child: ChartEmpty(height: 110, message: 'Stock levels appear here once a till with inventory is online'),
      );
    }
    final low = st.low;
    return ReportCard(
      title: 'Low stock',
      subtitle: 'Updated ${_ago(st.updatedAt)} · ${st.items} items · value ${rs(st.stockValue)}',
      trailing: low.isEmpty ? const Pill('All good', tone: Tone.success, icon: Icons.check_rounded) : Pill('${low.length}', tone: Tone.warning, icon: Icons.inventory_2_outlined),
      child: low.isEmpty
          ? const ChartEmpty(height: 90, message: 'Everything is above its reorder level')
          : Column(children: [
              for (final l in low.take(8))
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(children: [
                    Icon(Icons.inventory_2_outlined, size: 18, color: ec.textMuted),
                    const SizedBox(width: Sp.sm),
                    Expanded(child: Text(l.name, style: context.tt.labelLarge, maxLines: 1, overflow: TextOverflow.ellipsis)),
                    const SizedBox(width: Sp.sm),
                    Text(l.display, style: context.tt.bodySmall?.copyWith(fontFeatures: tabular)),
                    const SizedBox(width: Sp.sm),
                    switch (l.state) {
                      'out' => const Pill('Out', tone: Tone.danger, dense: true),
                      'critical' => const Pill('Critical', tone: Tone.danger, dense: true),
                      _ => const Pill('Low', tone: Tone.warning, dense: true),
                    },
                  ]),
                ),
              if (low.length > 8)
                Padding(
                  padding: const EdgeInsets.only(top: Sp.xs),
                  child: Text('+ ${low.length - 8} more', style: context.tt.bodySmall),
                ),
            ]),
    );
  }
}

class _TerminalsCard extends StatelessWidget {
  const _TerminalsCard({required this.store});
  final LiveStore store;

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    final list = store.terminals;
    final now = DateTime.now().millisecondsSinceEpoch;
    bool online(Terminal t) => t.lastSeenAt > 0 && now - t.lastSeenAt <= const Duration(minutes: 10).inMilliseconds;
    final up = list.where(online).length;
    return ReportCard(
      title: 'Terminals',
      subtitle: list.isEmpty ? null : '$up of ${list.length} online',
      child: !store.terminalsLoaded
          ? const SizedBox(height: 80, child: Center(child: CircularProgressIndicator()))
          : list.isEmpty
              ? const ChartEmpty(height: 90, message: 'No tills have connected yet')
              : Column(children: [
                  for (final t in list)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: online(t) ? ec.success : ec.textFaint),
                        ),
                        const SizedBox(width: Sp.md),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(t.name, style: context.tt.labelLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
                            Text(
                              [
                                online(t) ? 'Online' : 'Last seen ${_ago(t.lastSeenAt)}',
                                if (t.appVersion.isNotEmpty) 'v${t.appVersion}',
                              ].join(' · '),
                              style: context.tt.bodySmall?.copyWith(color: online(t) ? ec.success : ec.textMuted),
                            ),
                          ]),
                        ),
                        Pill(t.code, dense: true, icon: Icons.point_of_sale_outlined),
                      ]),
                    ),
                ]),
    );
  }
}
