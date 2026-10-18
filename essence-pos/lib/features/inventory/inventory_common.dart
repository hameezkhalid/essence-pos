import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/providers.dart';
import '../../app/theme/tokens.dart';
import '../../core/db/database.dart';
import '../../core/models/menu_models.dart';
import '../../core/models/settings_models.dart';
import '../../core/services/inventory_service.dart';
import '../../shared/approval.dart';
import '../../shared/common.dart';

// ───────────────────────── Providers (local to the inventory feature) ─────────────────────────

/// All recent movements (Movements tab).
final inventoryMovementsProvider =
    StreamProvider.autoDispose<List<StockMovement>>((ref) => ref.watch(servicesProvider).inventory.watchMovements(limit: 500));

/// Movements of one stock item (History dialog).
final itemMovementsProvider = StreamProvider.autoDispose
    .family<List<StockMovement>, String>((ref, id) => ref.watch(servicesProvider).inventory.watchMovements(stockItemId: id, limit: 300));

// ───────────────────────── Stock state ─────────────────────────

extension StockStateUi on StockState {
  String get label => switch (this) {
        StockState.ok => 'OK',
        StockState.low => 'Low',
        StockState.critical => 'Critical',
        StockState.out => 'Out',
      };

  Tone get tone => switch (this) {
        StockState.ok => Tone.success,
        StockState.low => Tone.warning,
        StockState.critical => Tone.danger,
        StockState.out => Tone.danger,
      };

  IconData get icon => switch (this) {
        StockState.ok => Icons.check_circle_outline_rounded,
        StockState.low => Icons.trending_down_rounded,
        StockState.critical => Icons.warning_amber_rounded,
        StockState.out => Icons.remove_shopping_cart_outlined,
      };
}

class StatusPill extends StatelessWidget {
  const StatusPill(this.state, {super.key, this.dense = false});
  final StockState state;
  final bool dense;
  @override
  Widget build(BuildContext context) => Pill(state.label, tone: state.tone, icon: state.icon, dense: dense);
}

// ───────────────────────── Movement types ─────────────────────────

class MovementType {
  const MovementType(this.key, this.label, this.icon, this.tone);
  final String key;
  final String label;
  final IconData icon;
  final Tone tone;

  static const all = [
    MovementType('sale', 'Sale', Icons.point_of_sale_rounded, Tone.primary),
    MovementType('stockIn', 'Stock in', Icons.local_shipping_outlined, Tone.success),
    MovementType('wastage', 'Wastage', Icons.delete_outline_rounded, Tone.danger),
    MovementType('count', 'Count', Icons.fact_check_outlined, Tone.info),
    MovementType('refund', 'Refund', Icons.undo_rounded, Tone.accent),
    MovementType('void', 'Void', Icons.block_rounded, Tone.warning),
    MovementType('opening', 'Opening', Icons.flag_outlined, Tone.neutral),
  ];

  static MovementType of(String type) =>
      all.firstWhere((t) => t.key == type, orElse: () => MovementType(type, type, Icons.swap_vert_rounded, Tone.neutral));
}

class MovementBadge extends StatelessWidget {
  const MovementBadge(this.type, {super.key, this.size = 36});
  final MovementType type;
  final double size;
  @override
  Widget build(BuildContext context) {
    final (fg, bg) = type.tone.colors(context.ec);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(size * 0.3)),
      child: Icon(type.icon, size: size * 0.5, color: fg),
    );
  }
}

// ───────────────────────── Quantities & formatting ─────────────────────────

/// Signed quantity: "+1.2 kg", "−18 g".
String signedQty(StockItem? item, double qty, {String unit = 'pcs'}) {
  final s = item == null ? formatQty(qty.abs(), unit) : item.fmt(qty.abs());
  if (qty.abs() < 0.00001) return s;
  return qty > 0 ? '+$s' : '−$s';
}

/// Number for a text field: 2.5, 12, 0.25 (no trailing zeros).
String numText(double v, {int decimals = 3}) {
  if (v == v.roundToDouble()) return v.toInt().toString();
  var s = v.toStringAsFixed(decimals);
  if (s.contains('.')) s = s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  return s;
}

double? parseQty(String s) {
  final c = s.replaceAll(',', '').trim();
  if (c.isEmpty) return null;
  final v = double.tryParse(c);
  if (v == null || v.isNaN || v.isInfinite) return null;
  return v;
}

/// Rupee amount for a text field from paisa (1250 → "12.5").
String rupeeText(int paisa) => numText(paisa / 100, decimals: 2);

final decimalInput = [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))];

/// Display unit for a base unit: kg / L / pcs.
String bigUnitOf(String unit) => switch (unit) { 'g' => 'kg', 'ml' => 'L', _ => 'pcs' };
double perBigOf(String unit) => unit == 'pcs' ? 1 : 1000;

/// Quantity shown to staff: never below zero.
double shownQty(double qty) => qty < 0 ? 0 : qty;

final _time = DateFormat('h:mm a');
final _dayTime = DateFormat('d MMM, h:mm a');
final _day = DateFormat('EEE d MMM yyyy');

String timeOf(int ms) => _time.format(DateTime.fromMillisecondsSinceEpoch(ms));
String dayTimeOf(int ms) => _dayTime.format(DateTime.fromMillisecondsSinceEpoch(ms));

String dayLabel(DateTime d) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(d.year, d.month, d.day);
  final diff = today.difference(day).inDays;
  if (diff == 0) return 'Today';
  if (diff == 1) return 'Yesterday';
  return _day.format(d);
}

// ───────────────────────── Permissions ─────────────────────────

/// Signed-in staff if they may manage inventory, otherwise a manager who approves. Null = cancelled.
Future<StaffMember?> inventoryApproval(BuildContext context, WidgetRef ref, String why) async {
  final me = ref.read(sessionProvider);
  if (me == null) {
    toast(context, 'Sign in first', error: true);
    return null;
  }
  return requirePermission(context, ref, Perm.manageInventory, why: why);
}

/// Note suffix when someone else approved the action on the signed-in user's behalf.
String? withApprovalNote(WidgetRef ref, StaffMember approver, String? note) {
  final me = ref.read(sessionProvider);
  if (me == null || me.id == approver.id) return note;
  final by = 'Entered by ${me.name}';
  return (note == null || note.isEmpty) ? by : '$note · $by';
}

String deviceIdOf(WidgetRef ref) => ref.read(servicesProvider).device.id;

// ───────────────────────── Widgets ─────────────────────────

/// Horizontal bar of quantity vs par level, with a tick at the reorder level.
class LevelBar extends StatelessWidget {
  const LevelBar({super.key, required this.view, this.height = 8});
  final StockView view;
  final double height;

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    final item = view.item;
    final qty = shownQty(view.qty);
    final scale = item.parLevel > 0 ? item.parLevel : math.max(math.max(item.reorderLevel * 2, qty), 1).toDouble();
    final fill = (qty / scale).clamp(0.0, 1.0);
    final tick = item.reorderLevel > 0 ? (item.reorderLevel / scale).clamp(0.0, 1.0) : null;
    final color = switch (view.state) {
      StockState.ok => ec.success,
      StockState.low => ec.warning,
      _ => ec.danger,
    };
    final tip = [
      'Now ${item.fmt(qty)}',
      if (item.reorderLevel > 0) 'Reorder at ${item.fmt(item.reorderLevel)}',
      if (item.parLevel > 0) 'Par ${item.fmt(item.parLevel)}',
    ].join(' · ');
    return Tooltip(
      message: tip,
      child: SizedBox(
        height: height + 6,
        child: LayoutBuilder(builder: (context, c) {
          final w = c.maxWidth;
          return Stack(clipBehavior: Clip.none, alignment: Alignment.centerLeft, children: [
            Container(
              height: height,
              decoration: BoxDecoration(color: ec.surfaceAlt, borderRadius: BorderRadius.circular(99), border: Border.all(color: ec.border, width: 0.5)),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: w * fill,
              height: height,
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(99)),
            ),
            if (tick != null)
              Positioned(
                left: (w * tick - 1).clamp(0.0, math.max(0.0, w - 2)),
                top: 0,
                bottom: 0,
                child: Container(width: 2, decoration: BoxDecoration(color: ec.text.withValues(alpha: 0.55), borderRadius: BorderRadius.circular(1))),
              ),
          ]);
        }),
      ),
    );
  }
}

/// Quantity field with a g/kg (ml/L) unit switch. Reports the value in base units.
class QtyInput extends StatelessWidget {
  const QtyInput({
    super.key,
    required this.controller,
    required this.unit,
    required this.big,
    required this.onBigChanged,
    this.label = 'Quantity',
    this.onChanged,
    this.autofocus = false,
    this.helper,
  });
  final TextEditingController controller;
  final String unit;
  final bool big;
  final ValueChanged<bool> onBigChanged;
  final String label;
  final ValueChanged<String>? onChanged;
  final bool autofocus;
  final String? helper;

  static double? baseOf(TextEditingController c, String unit, bool big) {
    final v = parseQty(c.text);
    if (v == null) return null;
    return big && unit != 'pcs' ? v * 1000 : v;
  }

  @override
  Widget build(BuildContext context) {
    final field = TextField(
      controller: controller,
      autofocus: autofocus,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: decimalInput,
      style: context.tt.titleMedium?.copyWith(fontFeatures: tabular),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        helperText: helper,
        suffixText: unit == 'pcs' ? 'pcs' : (big ? bigUnitOf(unit) : unit),
      ),
    );
    if (unit == 'pcs') return field;
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(child: field),
      const SizedBox(width: Sp.sm),
      Padding(
        padding: const EdgeInsets.only(top: 4),
        child: SegmentedButton<bool>(
          showSelectedIcon: false,
          style: const ButtonStyle(visualDensity: VisualDensity.standard),
          segments: [
            ButtonSegment(value: false, label: Text(unit)),
            ButtonSegment(value: true, label: Text(bigUnitOf(unit))),
          ],
          selected: {big},
          onSelectionChanged: (s) => onBigChanged(s.first),
        ),
      ),
    ]);
  }
}

/// Small label/value block used in previews.
class StatBlock extends StatelessWidget {
  const StatBlock({super.key, required this.label, required this.value, this.tone, this.alignEnd = false});
  final String label;
  final String value;
  final Tone? tone;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    return Column(
      crossAxisAlignment: alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label.toUpperCase(), style: context.tt.labelSmall?.copyWith(color: ec.textMuted)),
        const SizedBox(height: 2),
        Text(
          value,
          style: context.tt.titleMedium?.copyWith(fontFeatures: tabular, color: tone == null ? ec.text : tone!.colors(ec).$1),
        ),
      ],
    );
  }
}

/// Before → after preview strip used by the stock dialogs.
class LevelPreview extends StatelessWidget {
  const LevelPreview({super.key, required this.item, required this.current, required this.next, this.extra});
  final StockItem item;
  final double current;
  final double? next;
  final Widget? extra;

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    final nv = next == null ? null : StockView(item, next!);
    return Container(
      padding: const EdgeInsets.all(Sp.md),
      decoration: BoxDecoration(color: ec.beige.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(Rad.md), border: Border.all(color: ec.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Expanded(child: StatBlock(label: 'Now', value: item.fmt(shownQty(current)))),
          Icon(Icons.arrow_forward_rounded, color: ec.textMuted, size: 20),
          Expanded(
            child: StatBlock(
              label: 'After',
              value: nv == null ? '—' : item.fmt(shownQty(nv.qty)),
              tone: nv?.state.tone,
              alignEnd: true,
            ),
          ),
        ]),
        if (nv != null) ...[
          const SizedBox(height: Sp.sm),
          LevelBar(view: nv),
          const SizedBox(height: Sp.xs),
          Row(children: [
            StatusPill(nv.state, dense: true),
            const Spacer(),
            if (item.parLevel > 0) Text('Par ${item.fmt(item.parLevel)}', style: context.tt.bodySmall),
          ]),
        ],
        if (extra != null) ...[const SizedBox(height: Sp.sm), extra!],
      ]),
    );
  }
}

/// Search field used by the tabs.
class SearchBox extends StatelessWidget {
  const SearchBox({super.key, required this.controller, required this.hint, required this.onChanged});
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          isDense: true,
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: ValueListenableBuilder(
            valueListenable: controller,
            builder: (context, v, _) => v.text.isEmpty
                ? const SizedBox.shrink()
                : IconButton(
                    tooltip: 'Clear search',
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () {
                      controller.clear();
                      onChanged('');
                    },
                  ),
          ),
        ),
      );
}

/// Chip row that wraps on wide screens and scrolls sideways on phones.
class ChipBar extends StatelessWidget {
  const ChipBar({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (!context.isPhone) return Wrap(spacing: Sp.sm, runSpacing: Sp.sm, children: children);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: [
        for (var i = 0; i < children.length; i++) ...[if (i > 0) const SizedBox(width: Sp.sm), children[i]],
      ]),
    );
  }
}

/// Loading / error wrapper for AsyncValue lists.
Widget asyncBody<T>(AsyncValue<T> v, Widget Function(T data) builder) => switch (v) {
      AsyncData(:final value) => builder(value),
      AsyncError(:final error) => EmptyState(icon: Icons.error_outline_rounded, title: 'Couldn’t load inventory', message: '$error'),
      _ => v.hasValue ? builder(v.requireValue) : const Center(child: CircularProgressIndicator()),
    };
