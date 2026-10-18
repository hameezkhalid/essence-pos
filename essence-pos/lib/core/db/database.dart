import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables.dart';

export 'tables.dart';

part 'database.g.dart';

int nowMs() => DateTime.now().millisecondsSinceEpoch;

@DriftDatabase(tables: [
  Categories,
  Products,
  ModifierGroups,
  Taxes,
  PaymentMethods,
  Areas,
  DiningTables,
  Staff,
  Customers,
  Orders,
  Refunds,
  Shifts,
  CashMovements,
  StockItems,
  Recipes,
  StockMovements,
  AuditLogs,
  SettingsEntries,
  Terminals,
  Outbox,
  LocalMeta,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _open());

  static QueryExecutor _open() => driftDatabase(
        name: 'essence_pos',
        web: DriftWebOptions(sqlite3Wasm: Uri.parse('sqlite3.wasm'), driftWorker: Uri.parse('drift_worker.js')),
      );

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await customStatement('CREATE INDEX IF NOT EXISTS idx_orders_date ON orders (business_date)');
          await customStatement('CREATE INDEX IF NOT EXISTS idx_orders_status ON orders (status)');
          await customStatement('CREATE INDEX IF NOT EXISTS idx_moves_item ON stock_movements (stock_item_id)');
          await customStatement('CREATE INDEX IF NOT EXISTS idx_refunds_date ON refunds (business_date)');
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = OFF');
        },
      );

  late final List<SyncSpec> syncSpecs = [
    SyncSpec('categories', categories, MenuCategory.fromJson),
    SyncSpec('products', products, Product.fromJson),
    SyncSpec('modifierGroups', modifierGroups, ModifierGroup.fromJson),
    SyncSpec('taxes', taxes, TaxRow.fromJson),
    SyncSpec('paymentMethods', paymentMethods, PaymentMethod.fromJson),
    SyncSpec('areas', areas, Area.fromJson),
    SyncSpec('tables', diningTables, DiningTable.fromJson),
    SyncSpec('staff', staff, StaffMember.fromJson),
    SyncSpec('customers', customers, Customer.fromJson),
    SyncSpec('orders', orders, Order.fromJson),
    SyncSpec('refunds', refunds, Refund.fromJson),
    SyncSpec('shifts', shifts, Shift.fromJson),
    SyncSpec('cashMovements', cashMovements, CashMovement.fromJson),
    SyncSpec('stockItems', stockItems, StockItem.fromJson),
    SyncSpec('recipes', recipes, Recipe.fromJson),
    SyncSpec('stockMovements', stockMovements, StockMovement.fromJson),
    SyncSpec('auditLogs', auditLogs, AuditLog.fromJson),
    SyncSpec('settings', settingsEntries, SettingRow.fromJson),
    SyncSpec('devices', terminals, Terminal.fromJson),
  ];

  late final Map<String, SyncSpec> specByCollection = {for (final s in syncSpecs) s.collection: s};
  late final Map<String, SyncSpec> _specByTable = {for (final s in syncSpecs) s.table.actualTableName: s};

  SyncSpec specFor(TableInfo table) => _specByTable[table.actualTableName]!;

  // ───────────── Writes that sync ─────────────

  /// Upserts a row locally and queues it for Firestore in one transaction.
  Future<void> saveSynced<T extends Table, D extends DataClass>(TableInfo<T, D> table, D row) {
    return transaction(() async {
      await into(table).insertOnConflictUpdate(row as Insertable<D>);
      await enqueue(specFor(table).collection, _idOf(row), row.toJson());
    });
  }

  /// Saves many rows in one transaction (used by seeding and bulk edits).
  Future<void> saveAllSynced<T extends Table, D extends DataClass>(TableInfo<T, D> table, List<D> rows) async {
    if (rows.isEmpty) return;
    final spec = specFor(table);
    for (var i = 0; i < rows.length; i += 500) {
      final chunk = rows.sublist(i, i + 500 > rows.length ? rows.length : i + 500);
      await transaction(() async {
        await batch((b) => b.insertAllOnConflictUpdate(table, chunk.cast<Insertable<D>>()));
        final now = nowMs();
        await batch((b) => b.insertAll(outbox, [
              for (final r in chunk)
                OutboxCompanion.insert(collection: spec.collection, docId: _idOf(r), payload: jsonEncode(r.toJson()), createdAt: now),
            ]));
      });
    }
  }

  String _idOf(DataClass d) => d.toJson()['id'] as String;

  Future<void> enqueue(String collection, String docId, Map<String, dynamic> json) =>
      into(outbox).insert(OutboxCompanion.insert(collection: collection, docId: docId, payload: jsonEncode(json), createdAt: nowMs()));

  Stream<int> watchOutboxCount() {
    final c = outbox.seq.count();
    return (selectOnly(outbox)..addColumns([c])).map((r) => r.read(c) ?? 0).watchSingle();
  }

  // ───────────── Local meta ─────────────

  Future<String?> getMeta(String key) async =>
      (await (select(localMeta)..where((t) => t.key.equals(key))).getSingleOrNull())?.value;

  Future<void> setMeta(String key, String value) =>
      into(localMeta).insertOnConflictUpdate(LocalMetaCompanion.insert(key: key, value: value));

  Stream<String?> watchMeta(String key) =>
      (select(localMeta)..where((t) => t.key.equals(key))).watchSingleOrNull().map((r) => r?.value);

  /// Atomically increments a local counter and returns the new value.
  Future<int> nextCounter(String key) => transaction(() async {
        final cur = int.tryParse(await getMeta(key) ?? '') ?? 0;
        final next = cur + 1;
        await setMeta(key, '$next');
        return next;
      });

  // ───────────── Stock ─────────────

  /// Current quantity per stock item = sum of all its movements.
  Stream<Map<String, double>> watchStockLevels() {
    final sum = stockMovements.qty.sum();
    final q = selectOnly(stockMovements)
      ..addColumns([stockMovements.stockItemId, sum])
      ..where(stockMovements.deleted.equals(false))
      ..groupBy([stockMovements.stockItemId]);
    return q.watch().map((rows) => {for (final r in rows) r.read(stockMovements.stockItemId)!: r.read(sum) ?? 0});
  }

  Future<Map<String, double>> stockLevels() => watchStockLevels().first;

  /// Removes everything (used by "Reset demo data" on a fresh store).
  Future<void> wipeAll() => transaction(() async {
        for (final t in allTables) {
          if (t.actualTableName == localMeta.actualTableName) continue;
          await delete(t).go();
        }
      });
}

/// Maps a local table to its Firestore collection.
class SyncSpec<T extends Table, D extends DataClass> {
  SyncSpec(this.collection, this.table, this._fromJson);

  final String collection;
  final TableInfo<T, D> table;
  final D Function(Map<String, dynamic> json, {ValueSerializer? serializer}) _fromJson;

  /// Text columns ending in `Json` are stored as real maps/lists in Firestore without the suffix.
  late final Set<String> jsonFields = {
    for (final c in table.$columns)
      if (_camel(c.name).endsWith('Json')) _camel(c.name),
  };

  late final Set<String> realFields = {
    for (final c in table.$columns)
      if (c.type == DriftSqlType.double) _camel(c.name),
  };

  D fromJson(Map<String, dynamic> json) => _fromJson(json);

  /// Local row JSON → Firestore document map.
  Map<String, dynamic> toRemote(Map<String, dynamic> local) {
    final out = <String, dynamic>{};
    local.forEach((k, v) {
      if (jsonFields.contains(k)) {
        out[k.substring(0, k.length - 4)] = v is String ? _tryDecode(v) : v;
      } else {
        out[k] = v;
      }
    });
    return out;
  }

  /// Firestore document map → local row JSON.
  Map<String, dynamic> fromRemote(Map<String, dynamic> remote) {
    final out = <String, dynamic>{};
    remote.forEach((k, v) {
      if (k == 'syncedAt') return;
      final jsonKey = '${k}Json';
      if (jsonFields.contains(jsonKey)) {
        out[jsonKey] = v is String ? v : jsonEncode(v);
      } else if (realFields.contains(k) && v is num) {
        out[k] = v.toDouble();
      } else {
        out[k] = v;
      }
    });
    return out;
  }

  Future<void> upsert(AppDatabase db, Map<String, dynamic> localJson) =>
      db.into(table).insertOnConflictUpdate(fromJson(localJson) as Insertable<D>);

  /// Last-write-wins: true when the incoming row is at least as new as the local one.
  Future<bool> isNewer(AppDatabase db, String id, int updatedAt) async {
    final row = await db
        .customSelect('SELECT updated_at FROM ${table.actualTableName} WHERE id = ?', variables: [Variable.withString(id)])
        .getSingleOrNull();
    if (row == null) return true;
    return updatedAt >= row.read<int>('updated_at');
  }

  static Object? _tryDecode(String s) {
    try {
      return jsonDecode(s);
    } catch (_) {
      return s;
    }
  }

  static String _camel(String snake) {
    final parts = snake.split('_');
    return parts.first + parts.skip(1).map((p) => p.isEmpty ? '' : p[0].toUpperCase() + p.substring(1)).join();
  }
}
