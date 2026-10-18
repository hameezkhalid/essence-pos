import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../db/database.dart';
import '../models/settings_models.dart';
import '../tax/tax_engine.dart';

const _uuid = Uuid();
String newId() => _uuid.v7();

// ───────────────────────── Settings, taxes, payments, floor ─────────────────────────

class SettingsRepo {
  SettingsRepo(this.db);
  final AppDatabase db;

  Stream<AppSettings> watch() => (db.select(db.settingsEntries)..where((t) => t.deleted.equals(false))).watch().map(_toSettings);

  Future<AppSettings> get() async => _toSettings(await (db.select(db.settingsEntries)..where((t) => t.deleted.equals(false))).get());

  AppSettings _toSettings(List<SettingRow> rows) {
    final maps = <String, Map<String, dynamic>>{};
    for (final r in rows) {
      try {
        maps[r.id] = Map<String, dynamic>.from(jsonDecode(r.valueJson) as Map);
      } catch (_) {}
    }
    return AppSettings.fromMaps(maps);
  }

  Future<void> save(String key, Map<String, dynamic> value) =>
      db.saveSynced(db.settingsEntries, SettingRow(id: key, updatedAt: nowMs(), deleted: false, valueJson: jsonEncode(value)));

  Future<void> saveAll(AppSettings s) async {
    final now = nowMs();
    await db.saveAllSynced(db.settingsEntries, [
      for (final e in s.toMaps().entries) SettingRow(id: e.key, updatedAt: now, deleted: false, valueJson: jsonEncode(e.value)),
    ]);
  }

  // Taxes
  Stream<List<TaxRow>> watchTaxes() => (db.select(db.taxes)
        ..where((t) => t.deleted.equals(false))
        ..orderBy([(t) => OrderingTerm.desc(t.builtIn), (t) => OrderingTerm.asc(t.sortOrder)]))
      .watch();

  Future<void> saveTax(TaxRow t) => db.saveSynced(db.taxes, t.copyWith(updatedAt: nowMs()));

  Future<void> deleteTax(TaxRow t) async {
    if (t.builtIn) return;
    await db.saveSynced(db.taxes, t.copyWith(deleted: true, updatedAt: nowMs()));
  }

  // Payment methods
  Stream<List<PaymentMethod>> watchPaymentMethods({bool activeOnly = false}) => (db.select(db.paymentMethods)
        ..where((t) => t.deleted.equals(false) & (activeOnly ? t.active.equals(true) : const Constant(true)))
        ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
      .watch();

  Future<void> savePaymentMethod(PaymentMethod m) => db.saveSynced(db.paymentMethods, m.copyWith(updatedAt: nowMs()));

  Future<void> deletePaymentMethod(PaymentMethod m) async {
    if (m.builtIn) return;
    await db.saveSynced(db.paymentMethods, m.copyWith(deleted: true, updatedAt: nowMs()));
  }

  // Floor
  Stream<List<Area>> watchAreas() =>
      (db.select(db.areas)..where((t) => t.deleted.equals(false))..orderBy([(t) => OrderingTerm.asc(t.sortOrder)])).watch();

  Stream<List<DiningTable>> watchTables() => (db.select(db.diningTables)
        ..where((t) => t.deleted.equals(false))
        ..orderBy([(t) => OrderingTerm.asc(t.sortOrder), (t) => OrderingTerm.asc(t.label)]))
      .watch();

  Future<void> saveArea(Area a) => db.saveSynced(db.areas, a.copyWith(updatedAt: nowMs()));
  Future<void> deleteArea(Area a) => db.saveSynced(db.areas, a.copyWith(deleted: true, updatedAt: nowMs()));
  Future<void> saveTable(DiningTable t) => db.saveSynced(db.diningTables, t.copyWith(updatedAt: nowMs()));
  Future<void> deleteTable(DiningTable t) => db.saveSynced(db.diningTables, t.copyWith(deleted: true, updatedAt: nowMs()));

  Stream<List<Terminal>> watchTerminals() =>
      (db.select(db.terminals)..where((t) => t.deleted.equals(false))..orderBy([(t) => OrderingTerm.asc(t.code)])).watch();
}

/// Builds the tax engine configuration from settings + enabled taxes.
BillConfig billConfigFrom(AppSettings s, List<TaxRow> taxes) => BillConfig(
      taxes: [
        for (final t in taxes)
          if (t.enabled && !t.deleted) TaxRule(id: t.id, name: t.name, cashBp: t.cashBp, cardOnlineBp: t.cardOnlineBp),
      ],
      pricesIncludeTax: s.pricing.pricesIncludeTax,
      fbrFee: s.fbr.enabled ? s.charges.fbrFee : 0,
      cashRoundingRupees: s.pricing.cashRoundingRupees,
    );

// ───────────────────────── Menu ─────────────────────────

class MenuRepo {
  MenuRepo(this.db);
  final AppDatabase db;

  Stream<List<MenuCategory>> watchCategories({bool activeOnly = false}) => (db.select(db.categories)
        ..where((t) => t.deleted.equals(false) & (activeOnly ? t.active.equals(true) : const Constant(true)))
        ..orderBy([(t) => OrderingTerm.asc(t.sortOrder), (t) => OrderingTerm.asc(t.name)]))
      .watch();

  Stream<List<Product>> watchProducts({bool activeOnly = false}) => (db.select(db.products)
        ..where((t) => t.deleted.equals(false) & (activeOnly ? t.active.equals(true) : const Constant(true)))
        ..orderBy([(t) => OrderingTerm.asc(t.sortOrder), (t) => OrderingTerm.asc(t.name)]))
      .watch();

  Stream<List<ModifierGroup>> watchModifierGroups() => (db.select(db.modifierGroups)
        ..where((t) => t.deleted.equals(false))
        ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
      .watch();

  Future<void> saveCategory(MenuCategory c) => db.saveSynced(db.categories, c.copyWith(updatedAt: nowMs()));
  Future<void> deleteCategory(MenuCategory c) => db.saveSynced(db.categories, c.copyWith(deleted: true, updatedAt: nowMs()));
  Future<void> saveProduct(Product p) => db.saveSynced(db.products, p.copyWith(updatedAt: nowMs()));
  Future<void> deleteProduct(Product p) => db.saveSynced(db.products, p.copyWith(deleted: true, updatedAt: nowMs()));
  Future<void> saveModifierGroup(ModifierGroup g) => db.saveSynced(db.modifierGroups, g.copyWith(updatedAt: nowMs()));
  Future<void> deleteModifierGroup(ModifierGroup g) => db.saveSynced(db.modifierGroups, g.copyWith(deleted: true, updatedAt: nowMs()));

  Future<void> setAvailable(Product p, bool available) => saveProduct(p.copyWith(available: available));
}

// ───────────────────────── Staff ─────────────────────────

class StaffRepo {
  StaffRepo(this.db);
  final AppDatabase db;

  Stream<List<StaffMember>> watchStaff({bool activeOnly = false}) => (db.select(db.staff)
        ..where((t) => t.deleted.equals(false) & (activeOnly ? t.active.equals(true) : const Constant(true)))
        ..orderBy([(t) => OrderingTerm.asc(t.name)]))
      .watch();

  static String hashPin(String pin, String salt) => sha256.convert(utf8.encode('$salt:$pin:essence')).toString();

  static String newSalt() {
    final r = Random.secure();
    return base64Url.encode(List.generate(12, (_) => r.nextInt(256)));
  }

  static StaffMember build({String? id, required String name, required Role role, required String pin, int color = 0xFF4E5726}) {
    final salt = newSalt();
    return StaffMember(
      id: id ?? newId(),
      updatedAt: nowMs(),
      deleted: false,
      name: name,
      role: role.name,
      pinHash: hashPin(pin, salt),
      pinSalt: salt,
      active: true,
      color: color,
    );
  }

  Future<StaffMember?> verify(String pin, {String? staffId}) async {
    final all = await (db.select(db.staff)..where((t) => t.deleted.equals(false) & t.active.equals(true))).get();
    for (final s in all) {
      if (staffId != null && s.id != staffId) continue;
      if (hashPin(pin, s.pinSalt) == s.pinHash) return s;
    }
    return null;
  }

  /// True when another active staff member already uses this PIN.
  Future<bool> pinInUse(String pin, {String? exceptId}) async {
    final s = await verify(pin);
    return s != null && s.id != exceptId;
  }

  Future<void> save(StaffMember s) => db.saveSynced(db.staff, s.copyWith(updatedAt: nowMs()));

  Future<void> setPin(StaffMember s, String pin) {
    final salt = newSalt();
    return save(s.copyWith(pinSalt: salt, pinHash: hashPin(pin, salt)));
  }

  Future<void> delete(StaffMember s) => db.saveSynced(db.staff, s.copyWith(deleted: true, updatedAt: nowMs()));
}

// ───────────────────────── Customers ─────────────────────────

class CustomerRepo {
  CustomerRepo(this.db);
  final AppDatabase db;

  Future<List<Customer>> search(String q) {
    final like = '%${q.trim()}%';
    return (db.select(db.customers)
          ..where((t) => t.deleted.equals(false) & (t.name.like(like) | t.phone.like(like)))
          ..orderBy([(t) => OrderingTerm.asc(t.name)])
          ..limit(30))
        .get();
  }

  Future<Customer> create({required String name, String phone = '', String? address}) async {
    final now = nowMs();
    final c = Customer(id: newId(), updatedAt: now, deleted: false, name: name, phone: phone, address: address, createdAt: now);
    await db.saveSynced(db.customers, c);
    return c;
  }

  Future<void> save(Customer c) => db.saveSynced(db.customers, c.copyWith(updatedAt: nowMs()));
}

// ───────────────────────── Audit ─────────────────────────

class AuditRepo {
  AuditRepo(this.db);
  final AppDatabase db;

  Future<void> log(String action, {required StaffMember staff, StaffMember? approvedBy, Map<String, dynamic> details = const {}, String? deviceId}) {
    final now = nowMs();
    return db.saveSynced(
      db.auditLogs,
      AuditLog(
        id: newId(),
        updatedAt: now,
        deleted: false,
        action: action,
        staffId: staff.id,
        staffName: staff.name,
        approvedById: approvedBy?.id,
        approvedByName: approvedBy?.name,
        detailsJson: jsonEncode(details),
        deviceId: deviceId,
        createdAt: now,
      ),
    );
  }

  Stream<List<AuditLog>> watchRecent({int limit = 200}) => (db.select(db.auditLogs)
        ..where((t) => t.deleted.equals(false))
        ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
        ..limit(limit))
      .watch();
}
