import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/providers.dart';
import '../../app/theme/tokens.dart';
import '../../core/db/database.dart';
import '../../core/models/settings_models.dart';
import '../../core/money.dart';
import '../../core/printing/templates.dart';
import '../../shared/common.dart';
import '../reports/report_widgets.dart';
import 'shift_cash_dialogs.dart';
import 'shift_data.dart';
import 'shift_dialogs.dart';

final _time = DateFormat('h:mm a');
final _dayTime = DateFormat('EEE d MMM · h:mm a');

class ShiftScreen extends ConsumerWidget {
  const ShiftScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pad = context.isPhone ? Sp.lg : Sp.xl;
    final open = ref.watch(openShiftProvider);
    final svc = ref.watch(servicesProvider);
    final shift = open.value;
    final canCash = ref.watch(canProvider(Perm.cashInOut));
    final canClose = ref.watch(canProvider(Perm.closeShift));

    final actions = <Widget>[
      if (shift == null && !open.isLoading)
        FilledButton.icon(onPressed: () => showOpenShiftDialog(context, ref), icon: const Icon(Icons.play_arrow_rounded), label: const Text('Open shift')),
      if (shift != null) ...[
        OutlinedButton.icon(
          onPressed: () => showCashMoveFlow(context, ref, shift, isIn: true),
          icon: Icon(Icons.south_west_rounded, color: canCash ? null : context.ec.textFaint),
          label: const Text('Cash in'),
        ),
        OutlinedButton.icon(
          onPressed: () => showCashMoveFlow(context, ref, shift, isIn: false),
          icon: Icon(Icons.north_east_rounded, color: canCash ? null : context.ec.textFaint),
          label: const Text('Cash out'),
        ),
        OutlinedButton.icon(onPressed: () => printXReport(context, ref, shift), icon: const Icon(Icons.print_outlined), label: const Text('Print X-report')),
        FilledButton.icon(
          onPressed: () => showCloseShiftFlow(context, ref, shift),
          icon: Icon(canClose ? Icons.lock_outline_rounded : Icons.verified_user_outlined),
          label: const Text('Close shift'),
        ),
      ],
    ];

    return ListView(
      padding: EdgeInsets.all(pad),
      children: [
        PageTitle(
          'Shift & cash',
          subtitle: '${svc.device.name} · ${svc.device.code}',
          actions: actions,
        ),
        if (open.isLoading && shift == null)
          const Padding(padding: EdgeInsets.symmetric(vertical: 80), child: Center(child: CircularProgressIndicator()))
        else if (open.hasError)
          EmptyState(icon: Icons.error_outline_rounded, title: 'Couldn’t load the shift', message: '${open.error}')
        else if (shift == null)
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: Sp.xl),
            child: EmptyState(
              icon: Icons.schedule_rounded,
              title: 'No open shift on this terminal',
              message: 'Open a shift and count the opening float before taking cash sales.',
              action: FilledButton.icon(onPressed: () => showOpenShiftDialog(context, ref), icon: const Icon(Icons.play_arrow_rounded), label: const Text('Open shift')),
            ),
          )
        else
          _OpenShiftPanel(shift: shift),
        const SizedBox(height: Sp.xl),
        const _History(),
      ],
    );
  }
}

// ───────────── Open shift ─────────────

class _OpenShiftPanel extends ConsumerWidget {
  const _OpenShiftPanel({required this.shift});
  final Shift shift;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(shiftSummaryProvider(shift));
    final sm = summary.value;
    final svc = ref.watch(servicesProvider);

    final header = AppCard(
      child: Wrap(
        spacing: Sp.xl,
        runSpacing: Sp.md,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Row(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: context.ec.successContainer, borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.lock_open_rounded, color: context.ec.success),
            ),
            const SizedBox(width: Sp.md),
            Flexible(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Text('Shift open', style: context.tt.titleMedium),
                  const SizedBox(width: Sp.sm),
                  _OpenFor(since: shift.openedAt),
                ]),
                Text('Opened by ${shift.openedByName} · ${_dayTime.format(DateTime.fromMillisecondsSinceEpoch(shift.openedAt))}', style: context.tt.bodySmall),
              ]),
            ),
          ]),
          _HeaderFact('Opening float', rs(shift.openingFloat)),
          _HeaderFact('Terminal', '${svc.device.name} · ${shift.deviceCode}'),
        ],
      ),
    );

    if (sm == null) {
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        header,
        const SizedBox(height: Sp.lg),
        if (summary.hasError) Text('Couldn’t load shift figures: ${summary.error}') else const Center(child: Padding(padding: EdgeInsets.all(Sp.xl), child: CircularProgressIndicator())),
      ]);
    }

    final hero = _ExpectedCashCard(summary: sm);
    final figures = KpiGrid(columns: const [2, 4], minWidth: 150, children: [
      KpiTile(label: 'Orders', value: '${sm.sales.length}', icon: Icons.receipt_long_outlined, tone: Tone.accent, caption: sm.voids.isEmpty ? null : '${sm.voids.length} voided'),
      KpiTile(label: 'Net sales', value: rs(sm.netSales), icon: Icons.payments_outlined, caption: 'Tax ${rs(sm.tax)}'),
      KpiTile(label: 'Cash sales', value: rs(sm.cashSales), icon: Icons.money_rounded, tone: Tone.success),
      KpiTile(label: 'Card / online', value: rs(sm.cardOnlineSales), icon: Icons.credit_card_rounded, tone: Tone.info),
      KpiTile(label: 'Cash in', value: rs(sm.cashIn), icon: Icons.south_west_rounded, tone: Tone.neutral),
      KpiTile(label: 'Cash out', value: rs(sm.cashOut), icon: Icons.north_east_rounded, tone: Tone.neutral),
      KpiTile(label: 'Cash refunds', value: rs(sm.cashRefunds), icon: Icons.undo_rounded, tone: Tone.danger, caption: sm.refunds.isEmpty ? null : '${sm.refunds.length} refund${sm.refunds.length == 1 ? '' : 's'} · ${rs(sm.refundTotal)}'),
      KpiTile(label: 'Discounts', value: rs(sm.discounts), icon: Icons.sell_outlined, tone: Tone.warning, caption: 'Gross ${rs(sm.grossSales)}'),
    ]);

    final payments = ReportCard(
      title: 'Payments by method',
      subtitle: 'This shift',
      child: BarList(empty: 'No payments yet this shift', entries: [for (final e in sm.byMethod.entries) BarListEntry(e.key, e.value)]),
    );

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      header,
      const SizedBox(height: Sp.lg),
      SplitRow(
        flex: const [3, 2],
        minChildWidth: 360,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [hero, const SizedBox(height: Sp.lg), figures]),
          Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [payments, const SizedBox(height: Sp.lg), _CashMoves(shift: shift)]),
        ],
      ),
    ]);
  }
}

class _HeaderFact extends StatelessWidget {
  const _HeaderFact(this.label, this.value);
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        Text(label.toUpperCase(), style: context.tt.labelSmall),
        const SizedBox(height: 2),
        Text(value, style: context.tt.titleMedium?.copyWith(fontFeatures: tabular)),
      ]);
}

/// "3h 12m" pill that ticks every minute.
class _OpenFor extends StatefulWidget {
  const _OpenFor({required this.since});
  final int since;
  @override
  State<_OpenFor> createState() => _OpenForState();
}

class _OpenForState extends State<_OpenFor> {
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(widget.since));
    final text = d.inHours > 0 ? '${d.inHours}h ${d.inMinutes % 60}m' : '${d.inMinutes}m';
    return Pill(text, tone: Tone.success, dense: true, icon: Icons.timer_outlined);
  }
}

class _ExpectedCashCard extends StatelessWidget {
  const _ExpectedCashCard({required this.summary});
  final ShiftSummary summary;

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    final sm = summary;
    Widget part(String label, int v, {bool minus = false}) => Text.rich(TextSpan(children: [
          TextSpan(text: '$label ', style: context.tt.bodySmall?.copyWith(color: ec.onPrimaryContainer.withValues(alpha: 0.75))),
          TextSpan(
            text: '${minus ? '−' : '+'} ${num0(v)}',
            style: context.tt.labelMedium?.copyWith(color: ec.onPrimaryContainer, fontFeatures: tabular),
          ),
        ]));
    return AppCard(
      color: ec.primaryContainer,
      borderColor: ec.primaryContainer,
      padding: const EdgeInsets.all(Sp.xl),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.point_of_sale_rounded, color: ec.onPrimaryContainer, size: 20),
          const SizedBox(width: Sp.sm),
          Expanded(child: Text('EXPECTED CASH IN DRAWER', style: context.tt.labelSmall?.copyWith(color: ec.onPrimaryContainer, letterSpacing: 0.8))),
          Pill('Live', tone: Tone.primary, dense: true, icon: Icons.sensors_rounded),
        ]),
        const SizedBox(height: Sp.sm),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            rs(sm.expectedCash),
            style: TextStyle(fontFamily: 'Inter', fontSize: 52, height: 1.1, fontWeight: FontWeight.w700, letterSpacing: -1, color: ec.onPrimaryContainer),
          ),
        ),
        const SizedBox(height: Sp.md),
        Wrap(spacing: Sp.lg, runSpacing: 4, children: [
          Text.rich(TextSpan(children: [
            TextSpan(text: 'Float ', style: context.tt.bodySmall?.copyWith(color: ec.onPrimaryContainer.withValues(alpha: 0.75))),
            TextSpan(text: num0(sm.shift.openingFloat), style: context.tt.labelMedium?.copyWith(color: ec.onPrimaryContainer, fontFeatures: tabular)),
          ])),
          part('Cash sales', sm.cashSales),
          part('Cash in', sm.cashIn),
          part('Cash out', sm.cashOut, minus: true),
          part('Refunds', sm.cashRefunds, minus: true),
        ]),
      ]),
    );
  }
}

class _CashMoves extends ConsumerWidget {
  const _CashMoves({required this.shift});
  final Shift shift;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ec = context.ec;
    final moves = ref.watch(shiftCashMovesProvider(shift.id));
    final list = moves.value ?? const <CashMovement>[];
    return ReportCard(
      title: 'Cash movements',
      subtitle: list.isEmpty ? 'Cash put in or taken out of the drawer' : '${list.length} this shift',
      child: moves.isLoading && list.isEmpty
          ? const SizedBox(height: 80, child: Center(child: CircularProgressIndicator()))
          : list.isEmpty
              ? const ChartEmpty(height: 90, message: 'No cash in or out yet')
              : Column(children: [
                  for (final m in list)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(color: m.type == 'in' ? ec.successContainer : ec.dangerContainer, borderRadius: BorderRadius.circular(10)),
                          child: Icon(m.type == 'in' ? Icons.south_west_rounded : Icons.north_east_rounded, size: 18, color: m.type == 'in' ? ec.success : ec.danger),
                        ),
                        const SizedBox(width: Sp.md),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(m.reason, style: context.tt.labelLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
                            Text('${m.staffName} · ${_time.format(DateTime.fromMillisecondsSinceEpoch(m.createdAt))}', style: context.tt.bodySmall),
                          ]),
                        ),
                        Text(
                          '${m.type == 'in' ? '+' : '−'}${num0(m.amount)}',
                          style: context.tt.titleSmall?.copyWith(fontFeatures: tabular, color: m.type == 'in' ? ec.success : ec.danger),
                        ),
                      ]),
                    ),
                ]),
    );
  }
}

// ───────────── History ─────────────

class _History extends ConsumerWidget {
  const _History();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(shiftHistoryProvider);
    final list = history.value ?? const <Shift>[];
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const SectionHeader('Shift history', subtitle: 'Last 30 shifts on every terminal · tap one for its report'),
      if (history.isLoading && list.isEmpty)
        const SizedBox(height: 120, child: Center(child: CircularProgressIndicator()))
      else if (list.isEmpty)
        const AppCard(child: EmptyState(icon: Icons.history_rounded, title: 'No shifts yet', message: 'Closed shifts and their Z-reports appear here.'))
      else
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(children: [
            for (var i = 0; i < list.length; i++) ...[
              if (i > 0) Divider(height: 1, color: context.ec.border),
              _HistoryRow(shift: list[i]),
            ],
          ]),
        ),
    ]);
  }
}

class _HistoryRow extends ConsumerWidget {
  const _HistoryRow({required this.shift});
  final Shift shift;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ec = context.ec;
    final s = shift;
    final open = s.status == 'open';
    final opened = DateTime.fromMillisecondsSinceEpoch(s.openedAt);
    final closed = s.closedAt == null ? null : DateTime.fromMillisecondsSinceEpoch(s.closedAt!);
    final diff = s.countedCash != null && s.expectedCash != null ? s.countedCash! - s.expectedCash! : null;
    final phone = context.isPhone;

    final date = SizedBox(
      width: 56,
      child: Column(children: [
        Text(DateFormat('d').format(opened), style: context.tt.titleLarge?.copyWith(fontFeatures: tabular, height: 1.1)),
        Text(DateFormat('MMM').format(opened).toUpperCase(), style: context.tt.labelSmall),
      ]),
    );

    final who = Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
      Wrap(spacing: Sp.sm, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center, children: [
        Pill(s.deviceCode, dense: true, icon: Icons.point_of_sale_outlined),
        Text('${_time.format(opened)} – ${closed == null ? 'now' : _time.format(closed)}', style: context.tt.labelLarge?.copyWith(fontFeatures: tabular)),
      ]),
      const SizedBox(height: 4),
      Text(
        open ? 'Opened by ${s.openedByName}' : '${s.openedByName} → ${s.closedByName ?? '—'}',
        style: context.tt.bodySmall,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    ]);

    final figures = open
        ? const Pill('Open', tone: Tone.success, icon: Icons.lock_open_rounded, dense: true)
        : Column(crossAxisAlignment: phone ? CrossAxisAlignment.start : CrossAxisAlignment.end, mainAxisSize: MainAxisSize.min, children: [
            Text.rich(
              TextSpan(children: [
                TextSpan(text: 'Expected ', style: context.tt.bodySmall),
                TextSpan(text: num0(s.expectedCash ?? 0), style: context.tt.labelMedium?.copyWith(fontFeatures: tabular)),
                TextSpan(text: '  Counted ', style: context.tt.bodySmall),
                TextSpan(text: num0(s.countedCash ?? 0), style: context.tt.labelMedium?.copyWith(fontFeatures: tabular)),
              ]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            if (diff != null) CashDiffPill(diff: diff, dense: true),
          ]);

    return InkWell(
      onTap: () => showShiftReport(context, ref, shift),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Sp.lg, vertical: Sp.md),
        child: phone
            ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                date,
                const SizedBox(width: Sp.sm),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [who, const SizedBox(height: Sp.sm), figures])),
              ])
            : Row(children: [
                date,
                const SizedBox(width: Sp.md),
                Expanded(child: who),
                const SizedBox(width: Sp.md),
                figures,
                const SizedBox(width: Sp.sm),
                Icon(Icons.chevron_right_rounded, color: ec.textFaint),
              ]),
      ),
    );
  }
}
