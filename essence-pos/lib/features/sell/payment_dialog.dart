import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme/icons.dart';
import '../../app/theme/tokens.dart';
import '../../core/db/database.dart';
import '../../core/models/order_models.dart';
import '../../core/money.dart';
import '../../core/tax/tax_engine.dart';
import '../../shared/common.dart';
import '../../shared/keypads.dart';
import '../../shared/receipt_preview.dart';

/// Takes payment for the current cart. Returns the completed order.
Future<Order?> showPaymentDialog(BuildContext context, WidgetRef ref, {Shift? shift}) =>
    showAdaptive<Order>(context, maxWidth: 900, dismissible: false, builder: (_) => _PaymentDialog(shift: shift));

class _Paid {
  _Paid(this.method, this.amount, this.tendered);
  final PaymentMethod method;
  final int amount;
  final int? tendered;
  PaymentPortionInput get input =>
      PaymentPortionInput(methodId: method.id, methodName: method.name, group: RateGroup.parse(method.rateGroup), amount: amount);
}

class _PaymentDialog extends ConsumerStatefulWidget {
  const _PaymentDialog({this.shift});
  final Shift? shift;
  @override
  ConsumerState<_PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends ConsumerState<_PaymentDialog> {
  final List<_Paid> _paid = [];
  PaymentMethod? _method;
  String _entry = '';
  bool _split = false;
  bool _busy = false;

  PaymentPortionInput _remainderFor(PaymentMethod m) =>
      PaymentPortionInput(methodId: m.id, methodName: m.name, group: RateGroup.parse(m.rateGroup));

  BillResult _bill(PaymentMethod m) =>
      ref.read(servicesProvider).pos.bill(ref.read(cartProvider), [..._paid.map((p) => p.input), _remainderFor(m)]);

  int _due(PaymentMethod m) {
    final b = _bill(m);
    return b.portions.length > _paid.length ? b.portions.last.amount : 0;
  }

  Future<void> _complete({int? tenderedForLast}) async {
    final m = _method;
    final staff = ref.read(sessionProvider);
    if (m == null || staff == null || _busy) return;
    setState(() => _busy = true);
    try {
      final portions = [..._paid.map((p) => p.input), _remainderFor(m)];
      final tendered = <int, int>{
        for (var i = 0; i < _paid.length; i++)
          if (_paid[i].tendered != null) i: _paid[i].tendered!,
        _paid.length: ?tenderedForLast,
      };
      final order = await ref.read(servicesProvider).pos.checkout(
            cart: ref.read(cartProvider),
            portions: portions,
            tenderedByPortion: tendered,
            staff: staff,
            shift: widget.shift,
          );
      if (mounted) Navigator.pop(context, order);
    } catch (e) {
      if (mounted) {
        toast(context, 'Payment failed: $e', error: true);
        setState(() => _busy = false);
      }
    }
  }

  void _addSplit(int due) {
    final m = _method!;
    final amt = parseRupees(_entry) ?? 0;
    if (amt <= 0) return;
    if (amt >= due) {
      _complete(tenderedForLast: m.rateGroup == 'cash' ? amt : null);
      return;
    }
    setState(() {
      _paid.add(_Paid(m, amt, m.rateGroup == 'cash' ? amt : null));
      _entry = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    final methods = ref.watch(activePaymentMethodsProvider);
    ref.watch(billConfigProvider);
    if (methods.isEmpty) {
      return DialogFrame(
        title: 'Payment',
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
        child: const EmptyState(icon: Icons.payments_outlined, title: 'No payment methods', message: 'Add payment methods in Settings.'),
      );
    }
    _method ??= methods.first;
    final m = _method!;
    final isCash = m.rateGroup == 'cash';
    final due = _due(m);
    final bill = _bill(m);
    final entered = parseRupees(_entry);
    final tendered = entered ?? due;
    final change = isCash && tendered > due ? tendered - due : 0;
    final taxes = ref.read(billConfigProvider).taxes;
    final group = RateGroup.parse(m.rateGroup);
    final rateText = taxes.where((t) => t.bp(group) > 0).map((t) => '${t.name} ${pct(t.bp(group))}').join(' + ');
    final wide = !context.isPhone && context.screenW >= 820;

    final summary = Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
      Container(
        padding: const EdgeInsets.all(Sp.lg),
        decoration: BoxDecoration(color: ec.beige, borderRadius: BorderRadius.circular(Rad.lg)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_paid.isEmpty ? 'Amount due · ${m.name}' : 'Remaining · ${m.name}', style: context.tt.labelMedium?.copyWith(color: ec.textMuted)),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(rs(due), style: context.tt.displayMedium?.copyWith(fontFamily: 'Inter', fontWeight: FontWeight.w800, fontFeatures: tabular)),
          ),
          if (rateText.isNotEmpty)
            Text(
              bill.pricesIncludeTax ? 'Includes $rateText' : 'Includes $rateText for ${group.label.toLowerCase()}',
              style: context.tt.bodySmall,
            ),
        ]),
      ),
      const SizedBox(height: Sp.md),
      for (final p in bill.portions)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(children: [
            Icon(iconFor(methods.where((x) => x.id == p.methodId).firstOrNull?.icon), size: 18, color: ec.textMuted),
            const SizedBox(width: Sp.sm),
            Expanded(child: Text('${p.methodName} · ${p.taxes.map((t) => '${t.name} ${pct(t.rateBp)} ${num0(t.amount)}').join(', ')}', style: context.tt.bodySmall)),
            Text(rs(p.amount), style: context.tt.titleSmall?.copyWith(fontFeatures: tabular)),
          ]),
        ),
      if (bill.portions.length > 1) const Divider(height: Sp.lg),
      Row(children: [
        Text('Bill total', style: context.tt.titleSmall),
        const Spacer(),
        Text(rs(bill.total), style: context.tt.titleMedium?.copyWith(fontFeatures: tabular)),
      ]),
      if (_paid.isNotEmpty)
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => setState(_paid.clear),
            icon: const Icon(Icons.undo_rounded, size: 18),
            label: const Text('Start payment again'),
          ),
        ),
    ]);

    final methodButtons = Wrap(spacing: Sp.sm, runSpacing: Sp.sm, children: [
      for (final x in methods)
        ChoiceChip(
          avatar: Icon(iconFor(x.icon), size: 18),
          label: Text(x.name),
          selected: x.id == m.id,
          onSelected: (_) => setState(() {
            _method = x;
            _entry = '';
          }),
        ),
    ]);

    final entry = Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
      Row(children: [
        Text(isCash ? 'Cash received' : (_split ? 'Amount on ${m.name}' : 'Charge to ${m.name}'), style: context.tt.titleSmall),
        const Spacer(),
        Text('Split', style: context.tt.labelMedium),
        Switch(value: _split, onChanged: (v) => setState(() => _split = v)),
      ]),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: Sp.lg, vertical: Sp.md),
        decoration: BoxDecoration(color: ec.surfaceAlt, borderRadius: BorderRadius.circular(Rad.md), border: Border.all(color: ec.border)),
        child: Row(children: [
          Text('Rs', style: context.tt.titleMedium?.copyWith(color: ec.textMuted)),
          const SizedBox(width: Sp.sm),
          Expanded(
            child: Text(
              _entry.isEmpty ? num0(due) : _entry,
              style: context.tt.headlineMedium?.copyWith(fontFamily: 'Inter', fontWeight: FontWeight.w700, color: _entry.isEmpty ? ec.textFaint : ec.text, fontFeatures: tabular),
            ),
          ),
          if (change > 0) Pill('Change ${rs(change)}', tone: Tone.success),
          if (isCash && entered != null && entered < due && !_split) Pill('Short ${rs(due - entered)}', tone: Tone.danger),
        ]),
      ),
      const SizedBox(height: Sp.sm),
      if (isCash)
        Wrap(spacing: Sp.sm, runSpacing: Sp.sm, children: [
          for (final v in _quickCash(due)) ActionChip(label: Text(rs(v)), onPressed: () => setState(() => _entry = '${v ~/ 100}')),
        ]),
      const SizedBox(height: Sp.sm),
      AmountPad(value: _entry, onChanged: (v) => setState(() => _entry = v)),
    ]);

    final canFinish = !_busy && (!isCash || _split || tendered >= due);
    final primary = _split && entered != null && entered < due
        ? FilledButton.icon(
            onPressed: _busy || entered <= 0 ? null : () => _addSplit(due),
            icon: const Icon(Icons.add_rounded),
            label: Text('Add ${rs(entered)} ${m.name}'),
          )
        : FilledButton.icon(
            onPressed: canFinish ? () => _complete(tenderedForLast: isCash ? tendered : null) : null,
            icon: _busy ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.check_rounded),
            label: Text(isCash ? (change > 0 ? 'Complete · change ${rs(change)}' : 'Complete ${rs(due)}') : 'Paid ${rs(due)} by ${m.name}'),
          );

    return DialogFrame(
      title: 'Payment',
      icon: Icons.payments_rounded,
      actions: [
        TextButton(onPressed: _busy ? null : () => Navigator.pop(context), child: const Text('Back to order')),
        SizedBox(height: 52, child: primary),
      ],
      child: wide
          ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: summary),
              const SizedBox(width: Sp.xl),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [methodButtons, const SizedBox(height: Sp.lg), entry])),
            ])
          : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [summary, const SizedBox(height: Sp.lg), methodButtons, const SizedBox(height: Sp.lg), entry]),
    );
  }

  /// Exact amount, then the next round notes a customer is likely to hand over.
  static List<int> _quickCash(int due) {
    final r = (due / 100).ceil();
    final out = <int>{r * 100};
    for (final step in [100, 500, 1000, 5000]) {
      final v = ((r + step - 1) ~/ step) * step;
      if (v > r) out.add(v * 100);
    }
    return out.take(5).toList();
  }
}

// ───────────────────────── Sale complete ─────────────────────────

Future<void> showSaleComplete(BuildContext context, WidgetRef ref, Order order) =>
    showAdaptive<void>(context, maxWidth: 820, builder: (_) => _SaleComplete(orderId: order.id, initial: order));

class _SaleComplete extends ConsumerWidget {
  const _SaleComplete({required this.orderId, required this.initial});
  final String orderId;
  final Order initial;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ec = context.ec;
    final pos = ref.watch(servicesProvider).pos;
    final o = ref.watch(_orderProvider(orderId)).value ?? initial;
    final change = o.payments.fold<int>(0, (a, p) => a + p.change);
    final wide = !context.isPhone && context.screenW >= 760;
    final info = Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(color: ec.successContainer, shape: BoxShape.circle),
        child: Icon(Icons.check_rounded, size: 40, color: ec.success),
      ),
      const SizedBox(height: Sp.lg),
      Text('Paid ${rs(o.total)}', style: context.tt.headlineMedium),
      const SizedBox(height: 4),
      Text('${o.number} · Token ${o.tokenLabel} · ${o.type.label}', style: context.tt.bodyMedium?.copyWith(color: ec.textMuted)),
      if (change > 0) ...[
        const SizedBox(height: Sp.lg),
        Container(
          padding: const EdgeInsets.all(Sp.lg),
          decoration: BoxDecoration(color: ec.beige, borderRadius: BorderRadius.circular(Rad.lg)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Change to give', style: context.tt.labelMedium?.copyWith(color: ec.textMuted)),
            Text(rs(change), style: context.tt.displaySmall?.copyWith(fontFamily: 'Inter', fontWeight: FontWeight.w800, fontFeatures: tabular)),
          ]),
        ),
      ],
      const SizedBox(height: Sp.lg),
      Row(children: [
        Icon(
          o.fiscalStatus == 'reported' ? Icons.verified_rounded : (o.fiscalStatus == 'pending' ? Icons.schedule_rounded : Icons.receipt_outlined),
          size: 18,
          color: o.fiscalStatus == 'reported' ? ec.success : ec.warning,
        ),
        const SizedBox(width: Sp.sm),
        Expanded(
          child: Text(
            switch (o.fiscalStatus) {
              'reported' => 'Reported to FBR · ${o.fiscalInvoiceNo}',
              'pending' => 'FBR invoice queued — reports automatically when online',
              _ => 'FBR reporting is off',
            },
            style: context.tt.bodySmall,
          ),
        ),
      ]),
    ]);
    return DialogFrame(
      title: 'Sale complete',
      icon: Icons.celebration_outlined,
      actions: [
        OutlinedButton.icon(onPressed: () => pos.reprint(o), icon: const Icon(Icons.print_outlined), label: const Text('Print receipt')),
        FilledButton.icon(autofocus: true, onPressed: () => Navigator.pop(context), icon: const Icon(Icons.add_rounded), label: const Text('New order')),
      ],
      child: wide
          ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: info),
              const SizedBox(width: Sp.xl),
              Expanded(child: ReceiptPreview(doc: pos.receiptFor(o), maxWidth: 340)),
            ])
          : Column(children: [info, const SizedBox(height: Sp.lg), ReceiptPreview(doc: pos.receiptFor(o), maxWidth: 340)]),
    );
  }
}

final _orderProvider = StreamProvider.family<Order?, String>((ref, id) => ref.watch(servicesProvider).pos.watchOrder(id));
