import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/db/database.dart';
import '../../core/models/order_models.dart';
import '../../core/printing/templates.dart';
import '../../core/tax/tax_engine.dart';
import '../../core/money.dart';
import '../../shared/common.dart';

/// Live X-report figures for a shift.
final shiftSummaryProvider = StreamProvider.autoDispose.family<ShiftSummary, Shift>(
  (ref, shift) => ref.watch(servicesProvider).shifts.watchSummary(shift),
);

final shiftCashMovesProvider = StreamProvider.autoDispose.family<List<CashMovement>, String>(
  (ref, shiftId) => ref.watch(servicesProvider).shifts.watchCashMovements(shiftId),
);

/// Last 30 shifts on every terminal.
final shiftHistoryProvider = StreamProvider.autoDispose<List<Shift>>((ref) => ref.watch(servicesProvider).shifts.watchHistory(limit: 30));

extension ShiftSummaryX on ShiftSummary {
  /// Money paid by card, wallets and bank transfer.
  int get cardOnlineSales {
    var c = 0;
    for (final o in sales) {
      for (final p in o.payments) {
        if (p.group != RateGroup.cash) c += p.amount;
      }
    }
    return c;
  }
}

/// Counted − expected as a coloured pill: Balanced / Over / Short.
class CashDiffPill extends StatelessWidget {
  const CashDiffPill({super.key, required this.diff, this.dense = false});
  final int diff;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    if (diff == 0) return Pill('Balanced', tone: Tone.success, icon: Icons.check_rounded, dense: dense);
    if (diff > 0) return Pill('Over ${rs(diff)}', tone: Tone.info, icon: Icons.arrow_upward_rounded, dense: dense);
    return Pill('Short ${rs(-diff)}', tone: Tone.danger, icon: Icons.arrow_downward_rounded, dense: dense);
  }
}
