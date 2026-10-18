import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme/tokens.dart';
import '../../core/db/database.dart';
import '../../core/models/order_models.dart';
import '../../core/models/settings_models.dart';
import '../../core/money.dart';
import '../../core/services/pos_service.dart';
import '../../shared/approval.dart';
import '../../shared/common.dart';

const _reasons = ['Wrong item', 'Quality issue', 'Customer changed mind', 'Long wait', 'Other'];

Future<void> voidOrderFlow(BuildContext context, WidgetRef ref, Order o) async {
  final staff = ref.read(sessionProvider);
  if (staff == null) return;
  final approver = await requirePermission(context, ref, Perm.voidOrder, why: 'Void ${o.displayNumber} (${rs(o.total)})');
  if (approver == null || !context.mounted) return;
  final reason = await _askReason(context, title: 'Void ${o.displayNumber}?', message: 'The sale is cancelled and its ingredients go back into stock.');
  if (reason == null || !context.mounted) return;
  try {
    await ref.read(servicesProvider).pos.voidOrder(o, reason: reason, staff: staff, approvedBy: approver.id == staff.id ? null : approver);
    if (context.mounted) toast(context, '${o.displayNumber} voided');
  } catch (e) {
    if (context.mounted) toast(context, '$e', error: true);
  }
}

Future<String?> _askReason(BuildContext context, {required String title, String? message}) {
  String? picked;
  final other = TextEditingController();
  return showAdaptive<String>(
    context,
    maxWidth: 460,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, set) => DialogFrame(
        title: title,
        subtitle: message,
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: ctx.ec.danger, foregroundColor: Colors.white),
            onPressed: picked == null || (picked == 'Other' && other.text.trim().isEmpty)
                ? null
                : () => Navigator.pop(ctx, picked == 'Other' ? other.text.trim() : picked),
            child: const Text('Confirm'),
          ),
        ],
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Wrap(spacing: Sp.sm, runSpacing: Sp.sm, children: [
            for (final r in _reasons) ChoiceChip(label: Text(r), selected: picked == r, onSelected: (_) => set(() => picked = r)),
          ]),
          if (picked == 'Other') ...[
            const SizedBox(height: Sp.md),
            TextField(controller: other, autofocus: true, onChanged: (_) => set(() {}), decoration: const InputDecoration(labelText: 'Reason')),
          ],
        ]),
      ),
    ),
  );
}

Future<void> showRefundDialog(BuildContext context, WidgetRef ref, Order o) async {
  final staff = ref.read(sessionProvider);
  if (staff == null) return;
  final approver = await requirePermission(context, ref, Perm.refund, why: 'Refund on ${o.displayNumber}');
  if (approver == null || !context.mounted) return;
  await showAdaptive<void>(context, maxWidth: 560, builder: (_) => _RefundDialog(order: o, approver: approver));
}

class _RefundDialog extends ConsumerStatefulWidget {
  const _RefundDialog({required this.order, required this.approver});
  final Order order;
  final StaffMember approver;
  @override
  ConsumerState<_RefundDialog> createState() => _RefundDialogState();
}

class _RefundDialogState extends ConsumerState<_RefundDialog> {
  final Map<String, int> _qty = {};
  PaymentMethod? _method;
  String? _reason;
  bool _restock = true;
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    final o = widget.order;
    final lines = o.lines.where((l) => l.qty - l.refundedQty > 0).toList();
    final methods = ref.watch(activePaymentMethodsProvider);
    _method ??= methods.where((m) => m.id == o.payments.firstOrNull?.methodId).firstOrNull ?? methods.firstOrNull;
    final value = PosService.refundValue(o, _qty);
    final any = _qty.values.any((q) => q > 0);

    return DialogFrame(
      title: 'Refund',
      subtitle: '${o.displayNumber} · paid ${rs(o.total)}${o.refundedTotal > 0 ? ' · already refunded ${rs(o.refundedTotal)}' : ''}',
      icon: Icons.undo_rounded,
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton.icon(
          onPressed: !any || _reason == null || _method == null || _busy
              ? null
              : () async {
                  setState(() => _busy = true);
                  final staff = ref.read(sessionProvider)!;
                  try {
                    final r = await ref.read(servicesProvider).pos.refund(
                          o,
                          qtyByKey: _qty,
                          method: _method!,
                          reason: _reason!,
                          restock: _restock,
                          staff: staff,
                          approvedBy: widget.approver.id == staff.id ? null : widget.approver,
                          shift: await ref.read(servicesProvider).shifts.openShift(),
                        );
                    if (context.mounted) {
                      Navigator.pop(context);
                      toast(context, 'Refunded ${rs(r.amount)} by ${r.methodName}');
                    }
                  } catch (e) {
                    if (context.mounted) {
                      toast(context, '$e', error: true);
                      setState(() => _busy = false);
                    }
                  }
                },
          icon: const Icon(Icons.undo_rounded),
          label: Text(any ? 'Refund ${rs(value.amount)}' : 'Refund'),
        ),
      ],
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Text('Items to return', style: context.tt.titleSmall),
          const Spacer(),
          TextButton(
            onPressed: () => setState(() {
              for (final l in lines) {
                _qty[l.key] = l.qty - l.refundedQty;
              }
            }),
            child: const Text('Select all'),
          ),
        ]),
        for (final l in lines)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(l.title, style: context.tt.titleSmall),
                  Text('${l.qty - l.refundedQty} of ${l.qty} returnable · ${rs(l.net)}', style: context.tt.bodySmall),
                ]),
              ),
              QtyStepper(compact: true, value: _qty[l.key] ?? 0, max: l.qty - l.refundedQty, onChanged: (v) => setState(() => _qty[l.key] = v)),
            ]),
          ),
        const Divider(height: Sp.xl),
        Text('Refund to', style: context.tt.titleSmall),
        const SizedBox(height: Sp.sm),
        Wrap(spacing: Sp.sm, runSpacing: Sp.sm, children: [
          for (final m in methods) ChoiceChip(label: Text(m.name), selected: _method?.id == m.id, onSelected: (_) => setState(() => _method = m)),
        ]),
        const SizedBox(height: Sp.md),
        Text('Reason', style: context.tt.titleSmall),
        const SizedBox(height: Sp.sm),
        Wrap(spacing: Sp.sm, runSpacing: Sp.sm, children: [
          for (final r in _reasons) ChoiceChip(label: Text(r), selected: _reason == r, onSelected: (_) => setState(() => _reason = r)),
        ]),
        const SizedBox(height: Sp.sm),
        LabeledSwitch(
          title: 'Return items to stock',
          subtitle: 'Turn off for drinks or food that were made and thrown away',
          value: _restock,
          onChanged: (v) => setState(() => _restock = v),
        ),
        if (any)
          Container(
            margin: const EdgeInsets.only(top: Sp.sm),
            padding: const EdgeInsets.all(Sp.md),
            decoration: BoxDecoration(color: ec.beige, borderRadius: BorderRadius.circular(Rad.md)),
            child: Row(children: [
              Expanded(child: Text('Refund incl. ${rs(value.tax)} tax', style: context.tt.bodyMedium)),
              Text(rs(value.amount), style: context.tt.titleLarge?.copyWith(fontFeatures: tabular)),
            ]),
          ),
      ]),
    );
  }
}
