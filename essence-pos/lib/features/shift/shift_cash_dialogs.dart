import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/providers.dart';
import '../../app/theme/tokens.dart';
import '../../core/db/database.dart';
import '../../core/models/settings_models.dart';
import '../../core/money.dart';
import '../../core/printing/printer_config.dart';
import '../../core/printing/printer_service.dart';
import '../../core/printing/templates.dart';
import '../../shared/approval.dart';
import '../../shared/common.dart';
import '../../shared/keypads.dart';
import '../../shared/receipt_preview.dart';
import 'shift_data.dart';

void _printToast(BuildContext context, PrintResult r, {required String done}) {
  if (r.nothingConfigured) {
    toast(context, 'No report printer set up on this terminal', error: true, icon: Icons.print_disabled_outlined);
  } else if (!r.ok) {
    toast(context, r.errors.first, error: true, icon: Icons.print_disabled_outlined);
  } else {
    toast(context, done, icon: Icons.print_outlined);
  }
}

/// Prints the X-report for the open shift.
Future<void> printXReport(BuildContext context, WidgetRef ref, Shift shift) async {
  try {
    final r = await ref.read(servicesProvider).shifts.printX(shift);
    if (context.mounted) _printToast(context, r, done: 'X-report printed');
  } catch (e) {
    if (context.mounted) toast(context, 'Printing failed: $e', error: true);
  }
}

// ───────────── Cash in / out ─────────────

/// Asks for permission, then records a cash in or cash out on [shift].
Future<void> showCashMoveFlow(BuildContext context, WidgetRef ref, Shift shift, {required bool isIn}) async {
  final staff = await requirePermission(context, ref, Perm.cashInOut, why: isIn ? 'Record cash put into the drawer' : 'Record cash taken from the drawer');
  if (staff == null || !context.mounted) return;
  await showAdaptive<void>(context, maxWidth: 460, builder: (_) => _CashMoveDialog(shift: shift, staff: staff, isIn: isIn));
}

class _CashMoveDialog extends ConsumerStatefulWidget {
  const _CashMoveDialog({required this.shift, required this.staff, required this.isIn});
  final Shift shift;
  final StaffMember staff;
  final bool isIn;

  @override
  ConsumerState<_CashMoveDialog> createState() => _CashMoveDialogState();
}

class _CashMoveDialogState extends ConsumerState<_CashMoveDialog> {
  late bool _isIn = widget.isIn;
  String _amount = '';
  final _reason = TextEditingController();
  bool _busy = false;

  static const _inReasons = ['Change from bank', 'Float top-up', 'Owner deposit'];
  static const _outReasons = ['Milk purchase', 'Petty expense', 'Supplier payment', 'Cash to bank'];

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final amount = parseRupees(_amount) ?? 0;
    final reason = _reason.text.trim();
    if (amount <= 0) return toast(context, 'Enter an amount', error: true);
    if (reason.isEmpty) return toast(context, 'Add a reason', error: true);
    setState(() => _busy = true);
    try {
      final svc = ref.read(servicesProvider);
      await svc.shifts.cashMove(widget.shift, isIn: _isIn, amount: amount, reason: reason, staff: widget.staff);
      // Best effort: pop the drawer so the cash can go in / come out.
      await svc.printer.openDrawer().catchError((_) => const PrintResult(0, []));
      if (!mounted) return;
      Navigator.pop(context);
      toast(context, '${_isIn ? 'Cash in' : 'Cash out'} ${rs(amount)} recorded');
    } catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        toast(context, 'Couldn’t record it: $e', error: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    final expected = ref.watch(shiftSummaryProvider(widget.shift)).value?.expectedCash;
    final amount = parseRupees(_amount) ?? 0;
    final reasons = _isIn ? _inReasons : _outReasons;
    return DialogFrame(
      title: _isIn ? 'Cash in' : 'Cash out',
      subtitle: expected == null ? 'Recorded on this shift' : 'Drawer should hold ${rs(expected)}',
      icon: _isIn ? Icons.south_west_rounded : Icons.north_east_rounded,
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton.icon(
          onPressed: _busy ? null : _save,
          icon: const Icon(Icons.check_rounded),
          label: Text(_isIn ? 'Record cash in' : 'Record cash out'),
        ),
      ],
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: true, label: Text('Cash in'), icon: Icon(Icons.south_west_rounded)),
            ButtonSegment(value: false, label: Text('Cash out'), icon: Icon(Icons.north_east_rounded)),
          ],
          selected: {_isIn},
          onSelectionChanged: (s) => setState(() => _isIn = s.first),
        ),
        const SizedBox(height: Sp.lg),
        Text('Amount', style: context.tt.labelMedium?.copyWith(color: ec.textMuted)),
        const SizedBox(height: Sp.xs),
        Text(
          '${_isIn ? '+' : '−'} ${rs(amount)}',
          style: context.tt.displaySmall?.copyWith(fontFamily: 'Inter', fontWeight: FontWeight.w700, fontFeatures: tabular, color: _isIn ? ec.success : ec.danger),
        ),
        if (!_isIn && expected != null && amount > expected)
          Padding(
            padding: const EdgeInsets.only(top: Sp.xs),
            child: Text('More than the drawer should hold', style: context.tt.bodySmall?.copyWith(color: ec.warning, fontWeight: FontWeight.w600)),
          ),
        const SizedBox(height: Sp.md),
        AmountPad(value: _amount, onChanged: (v) => setState(() => _amount = v)),
        const SizedBox(height: Sp.md),
        TextField(
          controller: _reason,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(labelText: 'Reason', prefixIcon: Icon(Icons.notes_rounded)),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: Sp.sm),
        Wrap(spacing: Sp.sm, runSpacing: Sp.sm, children: [
          for (final r in reasons)
            ChoiceChip(
              label: Text(r),
              selected: _reason.text == r,
              showCheckmark: false,
              onSelected: (_) => setState(() => _reason.text = r),
            ),
        ]),
      ]),
    );
  }
}

// ───────────── Close shift ─────────────

/// Asks for permission, counts the drawer, closes the shift, prints and shows the Z-report.
Future<void> showCloseShiftFlow(BuildContext context, WidgetRef ref, Shift shift) async {
  final staff = await requirePermission(context, ref, Perm.closeShift, why: 'Close the shift and print the Z-report');
  if (staff == null || !context.mounted) return;
  final closed = await showAdaptive<Shift>(context, maxWidth: 560, dismissible: false, builder: (_) => _CloseShiftDialog(shift: shift, staff: staff));
  if (closed == null || !context.mounted) return;
  final svc = ref.read(servicesProvider);
  PrintResult? printed;
  try {
    printed = await svc.shifts.printZ(closed);
  } catch (e) {
    printed = PrintResult(0, ['$e']);
  }
  if (!context.mounted) return;
  if (!printed.ok) toast(context, 'Shift closed, but the Z-report didn’t print: ${printed.errors.first}', error: true);
  if (printed.ok && !printed.nothingConfigured) toast(context, 'Shift closed · Z-report printed', icon: Icons.print_outlined);
  if (printed.nothingConfigured) toast(context, 'Shift closed · no report printer set up');
  await showShiftReport(context, ref, closed);
}

/// Shows a shift's X/Z-report as an on-screen receipt with a Reprint button.
Future<void> showShiftReport(BuildContext context, WidgetRef ref, Shift shift) =>
    showAdaptive<void>(context, maxWidth: 480, builder: (_) => _ShiftReportDialog(shift: shift));

class _ShiftReportDialog extends ConsumerStatefulWidget {
  const _ShiftReportDialog({required this.shift});
  final Shift shift;
  @override
  ConsumerState<_ShiftReportDialog> createState() => _ShiftReportDialogState();
}

class _ShiftReportDialogState extends ConsumerState<_ShiftReportDialog> {
  late final Future<ShiftSummary> _summary = ref.read(servicesProvider).shifts.summary(widget.shift);
  bool _busy = false;

  bool get _closed => widget.shift.status == 'closed';

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsValueProvider);
    final sh = widget.shift;
    return DialogFrame(
      title: _closed ? 'Z-report' : 'X-report',
      subtitle: '${sh.deviceCode} · ${DateFormat('EEE d MMM yyyy').format(DateTime.fromMillisecondsSinceEpoch(sh.openedAt))}',
      icon: Icons.receipt_long_rounded,
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Done')),
        FutureBuilder<ShiftSummary>(
          future: _summary,
          builder: (context, snap) => FilledButton.icon(
            onPressed: !snap.hasData || _busy
                ? null
                : () async {
                    setState(() => _busy = true);
                    try {
                      final r = await ref.read(servicesProvider).printer.print(buildShiftReport(snap.data!, settings, closing: _closed), PrintRole.report);
                      if (context.mounted) _printToast(context, r, done: '${_closed ? 'Z' : 'X'}-report printed');
                    } catch (e) {
                      if (context.mounted) toast(context, 'Printing failed: $e', error: true);
                    } finally {
                      if (mounted) setState(() => _busy = false);
                    }
                  },
            icon: const Icon(Icons.print_outlined),
            label: const Text('Reprint'),
          ),
        ),
      ],
      child: FutureBuilder<ShiftSummary>(
        future: _summary,
        builder: (context, snap) {
          if (snap.hasError) return Padding(padding: const EdgeInsets.all(Sp.lg), child: Text('Couldn’t load the report: ${snap.error}'));
          if (!snap.hasData) return const SizedBox(height: 240, child: Center(child: CircularProgressIndicator()));
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: Sp.sm),
            child: ReceiptPreview(doc: buildShiftReport(snap.data!, settings, closing: _closed)),
          );
        },
      ),
    );
  }
}

const _notes = [5000, 1000, 500, 100, 50, 20, 10];

class _CloseShiftDialog extends ConsumerStatefulWidget {
  const _CloseShiftDialog({required this.shift, required this.staff});
  final Shift shift;
  final StaffMember staff;

  @override
  ConsumerState<_CloseShiftDialog> createState() => _CloseShiftDialogState();
}

class _CloseShiftDialogState extends ConsumerState<_CloseShiftDialog> {
  bool _byNotes = true;
  final _counts = {for (final d in _notes) d: TextEditingController()};
  final _coins = TextEditingController();
  final _note = TextEditingController();
  String _direct = '';
  bool _busy = false;

  @override
  void dispose() {
    for (final c in _counts.values) {
      c.dispose();
    }
    _coins.dispose();
    _note.dispose();
    super.dispose();
  }

  int _count(int d) => int.tryParse(_counts[d]!.text.trim()) ?? 0;

  /// Counted cash in paisa.
  int get _counted {
    if (!_byNotes) return parseRupees(_direct) ?? 0;
    var t = 0;
    for (final d in _notes) {
      t += _count(d) * d * 100;
    }
    return t + (parseRupees(_coins.text) ?? 0);
  }

  void _bump(int d, int by) {
    final n = (_count(d) + by).clamp(0, 9999);
    setState(() => _counts[d]!.text = n == 0 ? '' : '$n');
  }

  Future<void> _close(int expected) async {
    final counted = _counted;
    if (counted == 0 && expected > 0) {
      final ok = await confirm(context, title: 'Close with Rs 0 counted?', message: 'The drawer should hold ${rs(expected)}.', confirmLabel: 'Close anyway', destructive: true);
      if (!ok || !mounted) return;
    }
    setState(() => _busy = true);
    try {
      final note = _note.text.trim();
      final closed = await ref.read(servicesProvider).shifts.close(widget.shift, countedCash: counted, staff: widget.staff, note: note.isEmpty ? null : note);
      if (mounted) Navigator.pop(context, closed);
    } catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        toast(context, 'Couldn’t close the shift: $e', error: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    final sm = ref.watch(shiftSummaryProvider(widget.shift)).value;
    final held = ref.watch(heldOrdersProvider).value?.where((o) => o.deviceId == widget.shift.deviceId).length ?? 0;
    final expected = sm?.expectedCash ?? 0;
    final counted = _counted;
    final diff = counted - expected;
    return DialogFrame(
      title: 'Close shift',
      subtitle: 'Count the cash in the drawer',
      icon: Icons.lock_clock_outlined,
      actions: [
        TextButton(onPressed: _busy ? null : () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton.icon(
          onPressed: _busy || sm == null ? null : () => _close(expected),
          icon: const Icon(Icons.lock_outline_rounded),
          label: const Text('Close shift & print Z'),
        ),
      ],
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        if (held > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: Sp.md),
            child: AppCard(
              color: ec.warningContainer,
              borderColor: ec.warningContainer,
              padding: const EdgeInsets.all(Sp.md),
              child: Row(children: [
                Icon(Icons.pause_circle_outline_rounded, color: ec.warning),
                const SizedBox(width: Sp.sm),
                Expanded(
                  child: Text('$held held order${held == 1 ? ' is' : 's are'} still open on this terminal.',
                      style: context.tt.bodyMedium?.copyWith(color: ec.text)),
                ),
              ]),
            ),
          ),
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: true, label: Text('Count notes'), icon: Icon(Icons.calculate_outlined)),
            ButtonSegment(value: false, label: Text('Enter total'), icon: Icon(Icons.dialpad_rounded)),
          ],
          selected: {_byNotes},
          onSelectionChanged: (s) => setState(() => _byNotes = s.first),
        ),
        const SizedBox(height: Sp.md),
        if (_byNotes) ...[
          for (final d in _notes) _DenomRow(label: rs(d * 100), controller: _counts[d]!, subtotal: _count(d) * d * 100, onBump: (by) => _bump(d, by), onChanged: () => setState(() {})),
          Padding(
            padding: const EdgeInsets.only(top: Sp.sm),
            child: TextField(
              controller: _coins,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
              decoration: const InputDecoration(labelText: 'Coins & loose change (Rs)', prefixIcon: Icon(Icons.toll_outlined)),
              onChanged: (_) => setState(() {}),
            ),
          ),
        ] else ...[
          AmountPad(value: _direct, onChanged: (v) => setState(() => _direct = v)),
        ],
        const SizedBox(height: Sp.lg),
        AppCard(
          color: ec.surfaceAlt,
          padding: const EdgeInsets.all(Sp.lg),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            _SumRow('Expected in drawer', sm == null ? '…' : rs(expected)),
            const SizedBox(height: Sp.xs),
            _SumRow('Counted', rs(counted), strong: true),
            const SizedBox(height: Sp.sm),
            Row(children: [
              Text('Difference', style: context.tt.labelLarge?.copyWith(color: ec.textMuted)),
              const Spacer(),
              if (sm != null) CashDiffPill(diff: diff),
            ]),
          ]),
        ),
        const SizedBox(height: Sp.md),
        TextField(
          controller: _note,
          maxLines: 2,
          minLines: 1,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            labelText: diff != 0 && sm != null ? 'Note (explain the difference)' : 'Note (optional)',
            prefixIcon: const Icon(Icons.notes_rounded),
          ),
        ),
      ]),
    );
  }
}

class _SumRow extends StatelessWidget {
  const _SumRow(this.label, this.value, {this.strong = false});
  final String label;
  final String value;
  final bool strong;
  @override
  Widget build(BuildContext context) => Row(children: [
        Text(label, style: context.tt.labelLarge?.copyWith(color: context.ec.textMuted)),
        const Spacer(),
        Text(value, style: (strong ? context.tt.titleLarge : context.tt.titleMedium)?.copyWith(fontFeatures: tabular)),
      ]);
}

class _DenomRow extends StatelessWidget {
  const _DenomRow({required this.label, required this.controller, required this.subtotal, required this.onBump, required this.onChanged});
  final String label;
  final TextEditingController controller;
  final int subtotal;
  final void Function(int by) onBump;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    Widget btn(IconData i, int by, String tip) => SizedBox(
          width: 40,
          height: 40,
          child: IconButton(
            tooltip: tip,
            padding: EdgeInsets.zero,
            style: IconButton.styleFrom(backgroundColor: ec.surfaceAlt, minimumSize: const Size(40, 40), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () => onBump(by),
            icon: Icon(i, size: 18, color: ec.text),
          ),
        );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(children: [
        SizedBox(width: 78, child: Text(label, style: context.tt.labelLarge?.copyWith(fontFeatures: tabular))),
        Text('×', style: context.tt.bodyMedium?.copyWith(color: ec.textMuted)),
        const SizedBox(width: Sp.sm),
        btn(Icons.remove_rounded, -1, 'One less'),
        const SizedBox(width: 4),
        SizedBox(
          width: 60,
          child: TextField(
            controller: controller,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)],
            style: context.tt.titleMedium?.copyWith(fontFeatures: tabular),
            decoration: const InputDecoration(hintText: '0', isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 10)),
            onChanged: (_) => onChanged(),
          ),
        ),
        const SizedBox(width: 4),
        btn(Icons.add_rounded, 1, 'One more'),
        Expanded(
          child: Text(
            subtotal == 0 ? '–' : num0(subtotal),
            textAlign: TextAlign.right,
            style: context.tt.bodyMedium?.copyWith(fontFeatures: tabular, color: subtotal == 0 ? ec.textFaint : ec.text),
          ),
        ),
      ]),
    );
  }
}
