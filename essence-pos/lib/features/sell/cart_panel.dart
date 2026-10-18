import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme/tokens.dart';
import '../../core/models/order_models.dart';
import '../../core/money.dart';
import '../../core/tax/tax_engine.dart';
import '../../shared/common.dart';
import '../shift/shift_dialogs.dart';
import 'payment_dialog.dart';
import 'product_options_sheet.dart';
import 'sell_dialogs.dart';

const cashPortion = PaymentPortionInput(methodId: 'cash', methodName: 'Cash', group: RateGroup.cash);
const cardPortion = PaymentPortionInput(methodId: 'card', methodName: 'Card', group: RateGroup.cardOnline);

/// Opens the order as a sheet (phones and narrow tablets).
Future<void> showCartSheet(BuildContext context) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => SizedBox(height: MediaQuery.sizeOf(ctx).height * 0.92, child: const CartPanel(inSheet: true)),
    );

class CartPanel extends ConsumerStatefulWidget {
  const CartPanel({super.key, this.inSheet = false});
  final bool inSheet;
  @override
  ConsumerState<CartPanel> createState() => CartPanelState();
}

class CartPanelState extends ConsumerState<CartPanel> {
  bool _busy = false;

  CartNotifier get _cart => ref.read(cartProvider.notifier);

  /// Validates the order and opens payment.
  Future<void> charge() async {
    final cart = ref.read(cartProvider);
    if (cart.isEmpty || _busy) return;
    final s = ref.read(settingsValueProvider);
    final svc = ref.read(servicesProvider);
    var shift = await svc.shifts.openShift();
    if (!mounted) return;
    if (shift == null && s.security.requireOpenShift) {
      shift = await showOpenShiftDialog(context, ref);
      if (shift == null || !mounted) return;
    }
    if (cart.type == OrderType.dineIn && s.orderTypes.requireTableForDineIn && cart.tableId == null) {
      final ok = await showTablePicker(context, ref);
      if (ok != true || !mounted) return;
    }
    final c2 = ref.read(cartProvider);
    if (c2.type == OrderType.delivery && s.orderTypes.requirePhoneForDelivery && (c2.customerPhone?.isEmpty ?? true)) {
      toast(context, 'Add the customer’s phone for delivery', icon: Icons.phone_outlined);
      await showCustomerDialog(context, ref, delivery: true);
      if (!mounted) return;
      final c3 = ref.read(cartProvider);
      if (c3.customerPhone?.isEmpty ?? true) return;
    }
    if (!mounted) return;
    final order = await showPaymentDialog(context, ref, shift: shift);
    if (order != null && mounted) {
      _cart.clear();
      if (widget.inSheet && Navigator.canPop(context)) Navigator.pop(context);
      await showSaleComplete(context, ref, order);
    }
  }

  /// Parks the order; dine-in orders are also sent to the bar.
  Future<void> hold() async {
    final cart = ref.read(cartProvider);
    final staff = ref.read(sessionProvider);
    if (cart.isEmpty || staff == null || _busy) return;
    setState(() => _busy = true);
    try {
      final send = cart.type == OrderType.dineIn;
      final shift = await ref.read(servicesProvider).shifts.openShift();
      final o = await ref.read(servicesProvider).pos.hold(cart, staff: staff, shift: shift, sendToBar: send);
      _cart.clear();
      if (mounted) {
        toast(context, send ? 'Order ${o.tokenLabel} sent to the bar and held' : 'Order ${o.tokenLabel} held', icon: Icons.pause_circle_outline_rounded);
        if (widget.inSheet && Navigator.canPop(context)) Navigator.pop(context);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    final cart = ref.watch(cartProvider);
    final s = ref.watch(settingsValueProvider);
    final pos = ref.watch(servicesProvider).pos;
    final config = ref.watch(billConfigProvider);
    final types = s.orderTypes.enabledTypes;

    final cash = pos.bill(cart, const [cashPortion]);
    final card = pos.bill(cart, const [cardPortion]);
    final twoTotals = config.taxes.isNotEmpty && cash.total != card.total;

    return Material(
      color: widget.inSheet ? ec.surface : ec.bg,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // Header
        Padding(
          padding: EdgeInsets.fromLTRB(Sp.lg, widget.inSheet ? 0 : Sp.lg, Sp.sm, Sp.sm),
          child: Row(children: [
            Text('Current order', style: context.tt.titleLarge),
            if (cart.token != null) ...[
              const SizedBox(width: Sp.sm),
              Pill('#${cart.token.toString().padLeft(3, '0')}', tone: Tone.accent, dense: true),
            ],
            const Spacer(),
            PopupMenuButton<String>(
              tooltip: 'Order options',
              icon: const Icon(Icons.more_horiz_rounded),
              onSelected: (v) async {
                switch (v) {
                  case 'note':
                    await showOrderNoteDialog(context, ref);
                  case 'clear':
                    if (cart.isEmpty) return;
                    if (await confirm(context, title: 'Clear this order?', message: cart.heldOrderId != null ? 'The held order stays in Held orders.' : null, confirmLabel: 'Clear')) {
                      _cart.clear();
                    }
                  case 'discard':
                    final staff = ref.read(sessionProvider);
                    if (cart.heldOrderId == null || staff == null) return;
                    if (await confirm(context, title: 'Discard held order?', message: 'It will be removed from Held orders on every till.', confirmLabel: 'Discard', destructive: true)) {
                      await ref.read(servicesProvider).pos.discardHeld(cart.heldOrderId!, staff);
                      _cart.clear();
                    }
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'note', child: ListTile(leading: Icon(Icons.sticky_note_2_outlined), title: Text('Order note'))),
                const PopupMenuItem(value: 'clear', child: ListTile(leading: Icon(Icons.clear_all_rounded), title: Text('Clear order'))),
                if (cart.heldOrderId != null)
                  const PopupMenuItem(value: 'discard', child: ListTile(leading: Icon(Icons.delete_outline_rounded), title: Text('Discard held order'))),
              ],
            ),
          ]),
        ),
        // Order type
        if (types.length > 1)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Sp.lg),
            child: SegmentedButton<OrderType>(
              showSelectedIcon: false,
              segments: [
                for (final t in types)
                  ButtonSegment(
                    value: t,
                    label: Text(t.label, maxLines: 1, softWrap: false),
                    icon: context.screenW < 1400 ? null : Icon(switch (t) {
                      OrderType.dineIn => Icons.table_restaurant_outlined,
                      OrderType.takeaway => Icons.shopping_bag_outlined,
                      OrderType.delivery => Icons.delivery_dining_outlined,
                    }, size: 18),
                  ),
              ],
              selected: {cart.type},
              onSelectionChanged: (v) async {
                _cart.setType(v.first);
                if (v.first == OrderType.dineIn && cart.tableId == null && s.orderTypes.requireTableForDineIn) {
                  await showTablePicker(context, ref);
                }
              },
            ),
          ),
        // Table / customer chips
        Padding(
          padding: const EdgeInsets.fromLTRB(Sp.lg, Sp.sm, Sp.lg, 0),
          child: Wrap(spacing: Sp.sm, runSpacing: Sp.sm, children: [
            if (cart.type == OrderType.dineIn)
              _ContextChip(
                icon: Icons.table_restaurant_outlined,
                label: cart.tableLabel == null ? 'Choose table' : 'Table ${cart.tableLabel}${cart.guests != null ? ' · ${cart.guests} guests' : ''}',
                highlight: cart.tableLabel == null,
                onTap: () => showTablePicker(context, ref),
              ),
            _ContextChip(
              icon: Icons.person_outline_rounded,
              label: cart.hasCustomer ? cart.customerName! : (cart.type == OrderType.delivery ? 'Add customer & address' : 'Add customer'),
              highlight: cart.type == OrderType.delivery && !cart.hasCustomer,
              onTap: () => showCustomerDialog(context, ref, delivery: cart.type == OrderType.delivery),
              onClear: cart.hasCustomer ? () => _cart.setCustomer(null) : null,
            ),
            if (cart.note != null)
              _ContextChip(icon: Icons.sticky_note_2_outlined, label: cart.note!, onTap: () => showOrderNoteDialog(context, ref), onClear: () => _cart.setNote(null)),
          ]),
        ),
        const SizedBox(height: Sp.sm),
        // Lines
        Expanded(
          child: cart.isEmpty
              ? const EmptyState(icon: Icons.local_cafe_outlined, title: 'No items yet', message: 'Tap a product to add it. Long-press for sizes and extras.')
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(Sp.md, Sp.xs, Sp.md, Sp.md),
                  itemCount: cart.lines.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 6),
                  itemBuilder: (context, i) => _LineTile(line: cart.lines[i], index: i),
                ),
        ),
        // Totals & actions
        Container(
          decoration: BoxDecoration(color: ec.surface, border: Border(top: BorderSide(color: ec.border))),
          padding: const EdgeInsets.fromLTRB(Sp.lg, Sp.md, Sp.lg, Sp.lg),
          child: SafeArea(
            top: false,
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              if (!cart.isEmpty) ...[
                _row(context, 'Subtotal · ${cart.itemCount} item${cart.itemCount == 1 ? '' : 's'}', rs(cash.itemsGross)),
                if (cash.discountTotal > 0)
                  _row(context, 'Discount${cart.orderDiscount != null ? ' ${cart.orderDiscount!.label ?? cart.orderDiscount!.display}' : ''}', '−${rs(cash.discountTotal)}', color: ec.success),
                for (final c in cash.charges) _row(context, c.label, rs(c.amount)),
                if (!cash.pricesIncludeTax)
                  for (final t in config.taxes)
                    _row(
                      context,
                      t.cashBp == t.cardOnlineBp ? '${t.name} ${pct(t.cashBp)}' : '${t.name} ${pct(t.cashBp)} cash · ${pct(t.cardOnlineBp)} card',
                      twoTotals
                          ? '${num0(_taxOf(cash, t.id))} · ${num0(_taxOf(card, t.id))}'
                          : rs(_taxOf(cash, t.id)),
                    ),
                if (cash.fbrFee > 0) _row(context, 'FBR POS fee', rs(cash.fbrFee)),
                const SizedBox(height: Sp.sm),
                if (twoTotals)
                  Row(children: [
                    Expanded(child: _TotalBox(label: 'Cash total', amount: cash.total, sub: cash.pricesIncludeTax ? 'incl. ${_taxText(cash)}' : null)),
                    const SizedBox(width: Sp.sm),
                    Expanded(child: _TotalBox(label: 'Card / online', amount: card.total, sub: card.pricesIncludeTax ? 'incl. ${_taxText(card)}' : null)),
                  ])
                else
                  _TotalBox(
                    label: 'Total',
                    amount: cash.total,
                    sub: cash.pricesIncludeTax && cash.taxTotal > 0
                        ? (cash.taxTotal != card.taxTotal ? 'incl. ${_taxText(cash)} cash · ${_taxText(card)} card' : 'incl. ${_taxText(cash)}')
                        : null,
                    wide: true,
                  ),
                const SizedBox(height: Sp.md),
              ],
              Row(children: [
                _SquareAction(
                  icon: Icons.percent_rounded,
                  tooltip: 'Discount',
                  active: cart.orderDiscount != null,
                  onTap: cart.isEmpty ? null : () => showDiscountDialog(context, ref),
                ),
                const SizedBox(width: Sp.sm),
                _SquareAction(
                  icon: cart.type == OrderType.dineIn ? Icons.send_rounded : Icons.pause_rounded,
                  tooltip: cart.type == OrderType.dineIn ? 'Send to bar & hold (F4)' : 'Hold order (F4)',
                  onTap: cart.isEmpty || _busy ? null : hold,
                ),
                const SizedBox(width: Sp.sm),
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: FilledButton(
                      onPressed: cart.isEmpty || _busy ? null : charge,
                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        const Icon(Icons.payments_rounded),
                        const SizedBox(width: Sp.sm),
                        Flexible(
                          child: Text(
                            cart.isEmpty ? 'Charge' : (twoTotals ? 'Charge' : 'Charge ${rs(cash.total)}'),
                            overflow: TextOverflow.ellipsis,
                            style: context.tt.titleMedium?.copyWith(color: ec.onPrimary, fontFeatures: tabular),
                          ),
                        ),
                      ]),
                    ),
                  ),
                ),
              ]),
            ]),
          ),
        ),
      ]),
    );
  }

  static int _taxOf(BillResult b, String id) => b.taxLines.where((t) => t.taxId == id).fold(0, (a, t) => a + t.amount);
  static String _taxText(BillResult b) => b.taxLines.map((t) => '${t.name} ${pct(t.rateBp)} ${num0(t.amount)}').join(' · ');

  Widget _row(BuildContext context, String k, String v, {Color? color}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(children: [
          Expanded(child: Text(k, style: context.tt.bodyMedium?.copyWith(color: context.ec.textMuted), overflow: TextOverflow.ellipsis)),
          Text(v, style: context.tt.bodyMedium?.copyWith(fontFeatures: tabular, color: color, fontWeight: FontWeight.w500)),
        ]),
      );
}

class _TotalBox extends StatelessWidget {
  const _TotalBox({required this.label, required this.amount, this.sub, this.wide = false});
  final String label;
  final int amount;
  final String? sub;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Sp.md, vertical: Sp.sm),
      decoration: BoxDecoration(color: ec.beige, borderRadius: BorderRadius.circular(Rad.md)),
      child: wide
          ? Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(label, style: context.tt.labelMedium?.copyWith(color: ec.textMuted)),
                  if (sub != null) Text(sub!, style: context.tt.labelSmall, maxLines: 2),
                ]),
              ),
              Text(rs(amount), style: context.tt.headlineMedium?.copyWith(fontFamily: 'Inter', fontWeight: FontWeight.w800, fontFeatures: tabular)),
            ])
          : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: context.tt.labelMedium?.copyWith(color: ec.textMuted)),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(rs(amount), style: context.tt.titleLarge?.copyWith(fontSize: 22, fontWeight: FontWeight.w800, fontFeatures: tabular)),
              ),
              if (sub != null) Text(sub!, style: context.tt.labelSmall, maxLines: 2, overflow: TextOverflow.ellipsis),
            ]),
    );
  }
}

class _SquareAction extends StatelessWidget {
  const _SquareAction({required this.icon, required this.tooltip, required this.onTap, this.active = false});
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    return Tooltip(
      message: tooltip,
      child: SizedBox(
        width: 56,
        height: 56,
        child: OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.zero,
            backgroundColor: active ? ec.primaryContainer : ec.surface,
            side: BorderSide(color: active ? ec.primary : ec.border),
          ),
          child: Icon(icon, color: onTap == null ? ec.textFaint : (active ? ec.onPrimaryContainer : ec.text)),
        ),
      ),
    );
  }
}

class _ContextChip extends StatelessWidget {
  const _ContextChip({required this.icon, required this.label, required this.onTap, this.onClear, this.highlight = false});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final VoidCallback? onClear;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    return Material(
      color: highlight ? ec.warningContainer : ec.surface,
      shape: StadiumBorder(side: BorderSide(color: highlight ? ec.warning.withValues(alpha: 0.5) : ec.border)),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.fromLTRB(12, 7, onClear == null ? 14 : 4, 7),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 16, color: highlight ? ec.warning : ec.textMuted),
            const SizedBox(width: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 200),
              child: Text(label, overflow: TextOverflow.ellipsis, style: context.tt.labelMedium?.copyWith(color: highlight ? ec.warning : ec.text)),
            ),
            if (onClear != null)
              InkWell(
                onTap: onClear,
                customBorder: const CircleBorder(),
                child: Padding(padding: const EdgeInsets.all(4), child: Icon(Icons.close_rounded, size: 14, color: ec.textMuted)),
              ),
          ]),
        ),
      ),
    );
  }
}

class _LineTile extends ConsumerWidget {
  const _LineTile({required this.line, required this.index});
  final OrderLine line;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ec = context.ec;
    final l = line;
    final disc = l.discount?.apply(l.gross) ?? 0;
    final locked = l.sentQty > 0;
    return Dismissible(
      key: ValueKey(l.key),
      direction: locked ? DismissDirection.none : DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: Sp.lg),
        decoration: BoxDecoration(color: ec.dangerContainer, borderRadius: BorderRadius.circular(Rad.md)),
        child: Icon(Icons.delete_outline_rounded, color: ec.danger),
      ),
      onDismissed: (_) {
        final removed = ref.read(cartProvider.notifier).remove(l.key);
        if (removed != null) {
          toast(context, '${removed.title} removed',
              icon: Icons.delete_outline_rounded,
              action: SnackBarAction(label: 'Undo', onPressed: () => ref.read(cartProvider.notifier).restore(removed, index)));
        }
      },
      child: Material(
        color: ec.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Rad.md), side: BorderSide(color: ec.border)),
        child: InkWell(
          borderRadius: BorderRadius.circular(Rad.md),
          onTap: () => showProductOptions(context, ref, editLine: l),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(Sp.md, 10, Sp.sm, 10),
            child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(l.title, style: context.tt.titleSmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                  if (l.modifiers.isNotEmpty)
                    Text(l.optionsText, style: context.tt.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                  if (l.note != null && l.note!.isNotEmpty)
                    Text('“${l.note}”', style: context.tt.bodySmall?.copyWith(fontStyle: FontStyle.italic), maxLines: 1, overflow: TextOverflow.ellipsis),
                  if (disc > 0 || locked)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Wrap(spacing: 4, children: [
                        if (disc > 0) Pill('−${rs(disc)} · ${l.discount!.display}', tone: Tone.success, dense: true),
                        if (locked) Pill('Sent ${l.sentQty}', tone: Tone.info, icon: Icons.check_rounded, dense: true),
                      ]),
                    ),
                ]),
              ),
              const SizedBox(width: Sp.sm),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(rs(l.gross - disc), style: context.tt.titleSmall?.copyWith(fontFeatures: tabular)),
                const SizedBox(height: 4),
                QtyStepper(
                  compact: true,
                  value: l.qty,
                  min: locked ? l.sentQty : 0,
                  onChanged: (q) => ref.read(cartProvider.notifier).setQty(l.key, q),
                ),
              ]),
            ]),
          ),
        ),
      ),
    );
  }
}
