import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/providers.dart';
import '../../app/theme/tokens.dart';
import '../../core/db/database.dart';
import '../../core/models/order_models.dart';
import '../../core/money.dart';
import '../../core/services/pos_context.dart';
import '../../shared/common.dart';
import '../../shared/receipt_preview.dart';
import 'order_actions.dart';

enum _Range { today, yesterday, week, month }

extension on _Range {
  String get label => switch (this) { _Range.today => 'Today', _Range.yesterday => 'Yesterday', _Range.week => 'Last 7 days', _Range.month => 'Last 30 days' };
}

final _rangeProvider = NotifierProvider<_RangeNotifier, _Range>(_RangeNotifier.new);

class _RangeNotifier extends Notifier<_Range> {
  @override
  _Range build() => _Range.today;
  void set(_Range r) => state = r;
}

final _ordersProvider = StreamProvider<List<Order>>((ref) {
  final svc = ref.watch(servicesProvider);
  final r = ref.watch(_rangeProvider);
  final today = DateTime.parse(svc.ctx.businessDate());
  String d(DateTime t) => DateFormat('yyyy-MM-dd').format(t);
  final (from, to) = switch (r) {
    _Range.today => (d(today), d(today)),
    _Range.yesterday => (d(today.subtract(const Duration(days: 1))), d(today.subtract(const Duration(days: 1)))),
    _Range.week => (d(today.subtract(const Duration(days: 6))), d(today)),
    _Range.month => (d(today.subtract(const Duration(days: 29))), d(today)),
  };
  return svc.pos.watchOrders(fromDate: from, toDate: to, limit: 2000);
});

/// Today's and past orders: receipts, reprints, refunds, voids.
class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key, this.initialOrderId});
  final String? initialOrderId;
  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  String? _selected;
  String _query = '';
  String _status = 'all';

  @override
  void initState() {
    super.initState();
    _selected = widget.initialOrderId;
  }

  bool _match(Order o) {
    if (_status == 'fbrPending' && o.fiscalStatus != 'pending') return false;
    if (_status != 'all' && _status != 'fbrPending' && o.status != _status) return false;
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return (o.number ?? '').toLowerCase().contains(q) ||
        o.tokenLabel.contains(q) ||
        (o.customerName ?? '').toLowerCase().contains(q) ||
        (o.customerPhone ?? '').contains(q) ||
        (o.fiscalInvoiceNo ?? '').contains(q) ||
        o.staffName.toLowerCase().contains(q);
  }

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    final all = ref.watch(_ordersProvider).value ?? const <Order>[];
    final orders = all.where(_match).toList();
    final range = ref.watch(_rangeProvider);
    final wide = context.screenW >= 1100;
    final pad = context.isPhone ? Sp.lg : Sp.xl;
    final selected = orders.where((o) => o.id == _selected).firstOrNull ?? (wide && orders.isNotEmpty ? orders.first : null);
    final sales = all.where((o) => o.isSale);
    final total = sales.fold<int>(0, (a, o) => a + o.netSales);

    final list = Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Padding(
        padding: EdgeInsets.fromLTRB(pad, pad, pad, 0),
        child: PageTitle(
          'Orders',
          subtitle: '${sales.length} sales · ${rs(total)} · ${range.label.toLowerCase()}',
          actions: [
            PopupMenuButton<_Range>(
              tooltip: 'Date range',
              initialValue: range,
              onSelected: (r) => ref.read(_rangeProvider.notifier).set(r),
              itemBuilder: (_) => [for (final r in _Range.values) PopupMenuItem(value: r, child: Text(r.label))],
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(color: ec.surface, borderRadius: BorderRadius.circular(Rad.md), border: Border.all(color: ec.border)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.calendar_today_outlined, size: 18, color: ec.textMuted),
                  const SizedBox(width: Sp.sm),
                  Text(range.label, style: context.tt.labelLarge),
                  Icon(Icons.expand_more_rounded, color: ec.textMuted),
                ]),
              ),
            ),
          ],
        ),
      ),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: pad),
        child: TextField(
          onChanged: (v) => setState(() => _query = v),
          decoration: const InputDecoration(hintText: 'Search invoice, token, customer, FBR number', prefixIcon: Icon(Icons.search_rounded)),
        ),
      ),
      SizedBox(
        height: 52,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.fromLTRB(pad, Sp.sm, pad, 0),
          children: [
            for (final (k, l) in const [
              ('all', 'All'),
              (OrderStatus.paid, 'Paid'),
              (OrderStatus.partiallyRefunded, 'Part refunded'),
              (OrderStatus.refunded, 'Refunded'),
              (OrderStatus.voided, 'Voided'),
              ('fbrPending', 'FBR pending'),
            ])
              Padding(
                padding: const EdgeInsets.only(right: Sp.sm),
                child: ChoiceChip(label: Text(l), selected: _status == k, onSelected: (_) => setState(() => _status = k)),
              ),
          ],
        ),
      ),
      const SizedBox(height: Sp.sm),
      Expanded(
        child: orders.isEmpty
            ? const EmptyState(icon: Icons.receipt_long_outlined, title: 'No orders', message: 'Sales you ring up appear here instantly, from every till.')
            : ListView.separated(
                padding: EdgeInsets.fromLTRB(pad, 0, pad, pad),
                itemCount: orders.length,
                separatorBuilder: (_, _) => const SizedBox(height: 6),
                itemBuilder: (context, i) => _OrderRow(
                  order: orders[i],
                  selected: wide && orders[i].id == selected?.id,
                  onTap: () {
                    if (wide) {
                      setState(() => _selected = orders[i].id);
                    } else {
                      showAdaptive<void>(context, maxWidth: 560, builder: (_) => _DetailSheet(orderId: orders[i].id));
                    }
                  },
                ),
              ),
      ),
    ]);

    if (!wide) return list;
    return Row(children: [
      Expanded(flex: 5, child: list),
      Container(width: 1, color: ec.border),
      Expanded(
        flex: 4,
        child: selected == null
            ? const EmptyState(icon: Icons.touch_app_outlined, title: 'Select an order')
            : OrderDetail(key: ValueKey(selected.id), orderId: selected.id),
      ),
    ]);
  }
}

class _OrderRow extends StatelessWidget {
  const _OrderRow({required this.order, required this.onTap, this.selected = false});
  final Order order;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    final o = order;
    final t = o.created;
    final pays = o.payments.map((p) => p.methodName).toSet().join(' + ');
    return Material(
      color: selected ? ec.primaryContainer : ec.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Rad.md), side: BorderSide(color: selected ? ec.primary : ec.border)),
      child: InkWell(
        borderRadius: BorderRadius.circular(Rad.md),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Sp.md, vertical: 10),
          child: Row(children: [
            SizedBox(
              width: 58,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(DateFormat('h:mm').format(t), style: context.tt.titleSmall?.copyWith(fontFeatures: tabular)),
                Text(DateFormat('a · d MMM').format(t), style: context.tt.labelSmall),
              ]),
            ),
            const SizedBox(width: Sp.sm),
            Icon(switch (o.type) {
              OrderType.dineIn => Icons.table_restaurant_outlined,
              OrderType.takeaway => Icons.shopping_bag_outlined,
              OrderType.delivery => Icons.delivery_dining_outlined,
            }, size: 20, color: ec.textMuted),
            const SizedBox(width: Sp.md),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${o.displayNumber}  ${o.tokenLabel}', style: context.tt.titleSmall, overflow: TextOverflow.ellipsis),
                Text(
                  [
                    '${o.itemCount} item${o.itemCount == 1 ? '' : 's'}',
                    if (o.tableLabel != null) 'Table ${o.tableLabel}',
                    if (o.customerName != null) o.customerName!,
                    pays,
                    o.staffName,
                  ].join(' · '),
                  style: context.tt.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ]),
            ),
            const SizedBox(width: Sp.sm),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(rs(o.total), style: context.tt.titleSmall?.copyWith(fontFeatures: tabular, decoration: o.status == OrderStatus.voided ? TextDecoration.lineThrough : null)),
              const SizedBox(height: 3),
              Row(mainAxisSize: MainAxisSize.min, children: [
                if (o.status != OrderStatus.paid) ...[StatusPill(status: o.status), const SizedBox(width: 4)],
                FiscalIcon(status: o.fiscalStatus),
              ]),
            ]),
          ]),
        ),
      ),
    );
  }
}

class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.status});
  final String status;
  @override
  Widget build(BuildContext context) => Pill(
        OrderStatus.label(status),
        dense: true,
        tone: switch (status) {
          OrderStatus.paid => Tone.success,
          OrderStatus.voided => Tone.danger,
          OrderStatus.refunded || OrderStatus.partiallyRefunded => Tone.warning,
          _ => Tone.neutral,
        },
      );
}

class FiscalIcon extends StatelessWidget {
  const FiscalIcon({super.key, required this.status});
  final String status;
  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    return switch (status) {
      'reported' => Tooltip(message: 'Reported to FBR', child: Icon(Icons.verified_rounded, size: 16, color: ec.success)),
      'pending' => Tooltip(message: 'FBR invoice queued', child: Icon(Icons.schedule_rounded, size: 16, color: ec.warning)),
      'failed' => Tooltip(message: 'FBR reporting failed', child: Icon(Icons.error_outline_rounded, size: 16, color: ec.danger)),
      _ => const SizedBox.shrink(),
    };
  }
}

final orderStreamProvider = StreamProvider.family<Order?, String>((ref, id) => ref.watch(servicesProvider).pos.watchOrder(id));
final refundsForProvider = StreamProvider.family<List<Refund>, String>((ref, id) => ref.watch(servicesProvider).pos.watchRefunds(id));

class _DetailSheet extends StatelessWidget {
  const _DetailSheet({required this.orderId});
  final String orderId;
  @override
  Widget build(BuildContext context) => SizedBox(height: MediaQuery.sizeOf(context).height * 0.85, child: OrderDetail(orderId: orderId));
}

/// Order detail with the exact receipt and the available actions.
class OrderDetail extends ConsumerWidget {
  const OrderDetail({super.key, required this.orderId});
  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ec = context.ec;
    final o = ref.watch(orderStreamProvider(orderId)).value;
    if (o == null) return const Center(child: CircularProgressIndicator());
    final refunds = ref.watch(refundsForProvider(orderId)).value ?? const [];
    final svc = ref.watch(servicesProvider);
    final pad = context.isPhone ? Sp.lg : Sp.xl;
    final canRefund = (o.status == OrderStatus.paid || o.status == OrderStatus.partiallyRefunded) && o.netSales > 0;
    final canVoid = o.status == OrderStatus.paid && o.refundedTotal == 0 && o.businessDate == businessDateFor(DateTime.now(), svc.ctx.settings.store.dayStartHour);

    return ListView(padding: EdgeInsets.all(pad), children: [
      Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(o.displayNumber, style: context.tt.headlineSmall),
            Text('${DateFormat('EEE d MMM yyyy, h:mm a').format(o.created)} · ${o.deviceCode} · ${o.staffName}', style: context.tt.bodySmall),
          ]),
        ),
        StatusPill(status: o.status),
      ]),
      const SizedBox(height: Sp.lg),
      Wrap(spacing: Sp.sm, runSpacing: Sp.sm, children: [
        OutlinedButton.icon(onPressed: () => svc.pos.reprint(o), icon: const Icon(Icons.print_outlined, size: 18), label: const Text('Reprint')),
        OutlinedButton.icon(onPressed: () => svc.pos.reprintKot(o), icon: const Icon(Icons.local_cafe_outlined, size: 18), label: const Text('Bar ticket')),
        if (canRefund)
          OutlinedButton.icon(
            onPressed: () => showRefundDialog(context, ref, o),
            icon: const Icon(Icons.undo_rounded, size: 18),
            label: const Text('Refund'),
          ),
        if (canVoid)
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(foregroundColor: ec.danger),
            onPressed: () => voidOrderFlow(context, ref, o),
            icon: const Icon(Icons.block_rounded, size: 18),
            label: const Text('Void'),
          ),
        if (o.fiscalStatus == 'pending')
          OutlinedButton.icon(
            onPressed: () {
              svc.fiscal.run();
              toast(context, svc.sync.status.online ? 'Reporting to FBR…' : 'Offline — it will report automatically when back online');
            },
            icon: const Icon(Icons.sync_rounded, size: 18),
            label: const Text('Report to FBR'),
          ),
      ]),
      if (o.status == OrderStatus.voided)
        Padding(
          padding: const EdgeInsets.only(top: Sp.md),
          child: AppCard(
            color: ec.dangerContainer,
            borderColor: ec.danger.withValues(alpha: 0.3),
            child: Text('Voided by ${o.voidedBy ?? '—'}: ${o.voidReason ?? ''}', style: context.tt.bodyMedium?.copyWith(color: ec.danger)),
          ),
        ),
      if (refunds.isNotEmpty) ...[
        const SizedBox(height: Sp.lg),
        const SectionHeader('Refunds'),
        for (final r in refunds)
          Padding(
            padding: const EdgeInsets.only(bottom: Sp.sm),
            child: AppCard(
              padding: const EdgeInsets.all(Sp.md),
              child: Row(children: [
                Icon(Icons.undo_rounded, color: ec.warning),
                const SizedBox(width: Sp.md),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${rs(r.amount)} · ${r.methodName}', style: context.tt.titleSmall),
                    Text('${r.reason} · ${r.staffName}${r.approvedBy != null ? ' (approved ${r.approvedBy})' : ''} · ${DateFormat('d MMM h:mm a').format(DateTime.fromMillisecondsSinceEpoch(r.createdAt))}',
                        style: context.tt.bodySmall),
                  ]),
                ),
              ]),
            ),
          ),
      ],
      const SizedBox(height: Sp.lg),
      ReceiptPreview(doc: svc.pos.receiptFor(o), maxWidth: 380),
    ]);
  }
}
