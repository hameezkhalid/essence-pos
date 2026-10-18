import 'dart:convert';

import 'package:drift/drift.dart';

import '../db/database.dart';
import '../printing/printer_config.dart';
import '../printing/printer_service.dart';
import '../printing/templates.dart';
import 'pos_context.dart';
import 'repos.dart';

class ShiftService {
  ShiftService(this.db, this.ctx, this.printer) : audit = AuditRepo(db);

  final AppDatabase db;
  final PosContext ctx;
  final PrinterService printer;
  final AuditRepo audit;

  /// The open shift on this terminal, if any.
  Stream<Shift?> watchOpenShift() => (db.select(db.shifts)
        ..where((s) => s.deviceId.equals(ctx.device.id) & s.status.equals('open') & s.deleted.equals(false))
        ..orderBy([(s) => OrderingTerm.desc(s.openedAt)])
        ..limit(1))
      .watchSingleOrNull();

  Future<Shift?> openShift() => watchOpenShift().first;

  Stream<List<Shift>> watchHistory({int limit = 60}) => (db.select(db.shifts)
        ..where((s) => s.deleted.equals(false))
        ..orderBy([(s) => OrderingTerm.desc(s.openedAt)])
        ..limit(limit))
      .watch();

  Stream<List<CashMovement>> watchCashMovements(String shiftId) => (db.select(db.cashMovements)
        ..where((c) => c.shiftId.equals(shiftId) & c.deleted.equals(false))
        ..orderBy([(c) => OrderingTerm.desc(c.createdAt)]))
      .watch();

  Future<Shift> open({required int openingFloat, required StaffMember staff}) async {
    final existing = await openShift();
    if (existing != null) return existing;
    final now = nowMs();
    final s = Shift(
      id: newId(),
      updatedAt: now,
      deleted: false,
      deviceId: ctx.device.id,
      deviceCode: ctx.device.code,
      status: 'open',
      openedById: staff.id,
      openedByName: staff.name,
      openedAt: now,
      openingFloat: openingFloat,
    );
    await db.saveSynced(db.shifts, s);
    await audit.log('shiftOpen', staff: staff, deviceId: ctx.device.id, details: {'float': openingFloat});
    return s;
  }

  Future<void> cashMove(Shift shift, {required bool isIn, required int amount, required String reason, required StaffMember staff}) async {
    final now = nowMs();
    await db.saveSynced(
      db.cashMovements,
      CashMovement(
        id: newId(),
        updatedAt: now,
        deleted: false,
        shiftId: shift.id,
        type: isIn ? 'in' : 'out',
        amount: amount,
        reason: reason,
        staffId: staff.id,
        staffName: staff.name,
        createdAt: now,
      ),
    );
    await audit.log(isIn ? 'cashIn' : 'cashOut', staff: staff, deviceId: ctx.device.id, details: {'amount': amount, 'reason': reason});
  }

  Future<ShiftSummary> summary(Shift shift) async {
    final orders = await (db.select(db.orders)..where((o) => o.shiftId.equals(shift.id) & o.deleted.equals(false))).get();
    final refunds = await (db.select(db.refunds)..where((r) => r.shiftId.equals(shift.id) & r.deleted.equals(false))).get();
    final moves = await (db.select(db.cashMovements)..where((c) => c.shiftId.equals(shift.id) & c.deleted.equals(false))).get();
    return ShiftSummary(
      shift: shift,
      orders: orders,
      refunds: refunds,
      cashIn: moves.where((m) => m.type == 'in').fold(0, (a, m) => a + m.amount),
      cashOut: moves.where((m) => m.type == 'out').fold(0, (a, m) => a + m.amount),
    );
  }

  /// Live X-report figures (recomputed whenever orders, refunds or cash movements change).
  Stream<ShiftSummary> watchSummary(Shift shift) async* {
    yield await summary(shift);
    await for (final _ in db.tableUpdates(TableUpdateQuery.onAllTables([db.orders, db.refunds, db.cashMovements]))) {
      yield await summary(shift);
    }
  }

  Future<PrintResult> printX(Shift shift) async =>
      printer.print(buildShiftReport(await summary(shift), ctx.settings, closing: false), PrintRole.report);

  Future<Shift> close(Shift shift, {required int countedCash, required StaffMember staff, String? note}) async {
    final sm = await summary(shift);
    final now = nowMs();
    final closed = shift.copyWith(
      status: 'closed',
      closedById: Value(staff.id),
      closedByName: Value(staff.name),
      closedAt: Value(now),
      countedCash: Value(countedCash),
      expectedCash: Value(sm.expectedCash),
      note: Value(note),
      summaryJson: Value(jsonEncode(sm.toJson())),
      updatedAt: now,
    );
    await db.saveSynced(db.shifts, closed);
    await audit.log('shiftClose', staff: staff, deviceId: ctx.device.id, details: {
      'expected': sm.expectedCash,
      'counted': countedCash,
      'difference': countedCash - sm.expectedCash,
    });
    return closed;
  }

  Future<PrintResult> printZ(Shift closed) async =>
      printer.print(buildShiftReport(await summary(closed), ctx.settings, closing: true), PrintRole.report);
}
