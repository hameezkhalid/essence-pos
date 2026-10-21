// Generates the one-time go-live update for the live store (run with `flutter test tool/golive`).
// Output: build/golive.json — applied with tool/golive/apply.py.
import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:essence_pos/core/db/database.dart';
import 'package:essence_pos/core/models/settings_models.dart';
import 'package:essence_pos/core/services/demo_data.dart';
import 'package:essence_pos/core/services/pos_context.dart';
import 'package:essence_pos/core/services/real_menu.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('generate go-live writes', () async {
    final db = AppDatabase(NativeDatabase.memory());
    await DemoData(db, const DeviceInfo(id: 'x', code: 'T1', name: 'x')).seed();
    final now = DateTime.now().millisecondsSinceEpoch;
    final writes = <Map<String, dynamic>>[];

    // 1. Hide the demo menu (soft delete keeps it in the database).
    Future<void> hide(String collection, List<String> ids) async {
      for (final id in ids) {
        writes.add({'collection': collection, 'id': id, 'mask': ['deleted', 'updatedAt'], 'data': {'deleted': true, 'updatedAt': now}});
      }
    }

    await hide('categories', [for (final r in await db.select(db.categories).get()) r.id]);
    await hide('products', [for (final r in await db.select(db.products).get()) r.id]);
    await hide('modifierGroups', [for (final r in await db.select(db.modifierGroups).get()) r.id]);
    await hide('recipes', [for (final r in await db.select(db.recipes).get()) r.id]);
    await hide('stockItems', [for (final r in await db.select(db.stockItems).get()) r.id]);

    // 2. The real dessert menu.
    void put(String collection, SyncSpec spec, List<dynamic> rows) {
      for (final r in rows) {
        final json = (r as dynamic).toJson() as Map<String, dynamic>;
        writes.add({'collection': collection, 'id': json['id'], 'data': spec.toRemote(json)});
      }
    }

    put('categories', db.specByCollection['categories']!, RealMenu.buildCategories(now));
    put('products', db.specByCollection['products']!, RealMenu.buildProducts(now));
    put('stockItems', db.specByCollection['stockItems']!, RealMenu.buildStockItems(now));
    put('recipes', db.specByCollection['recipes']!, RealMenu.buildRecipes(now));

    // 3. Settings: FBR invoices off until credentials arrive; clear demo placeholders on receipts.
    final settingsSpec = db.specByCollection['settings']!;
    SettingRow row(String key, Map<String, dynamic> value) =>
        SettingRow(id: key, updatedAt: now, deleted: false, valueJson: jsonEncode(value));
    put('settings', settingsSpec, [
      row(SettingKeys.fbr, const FbrSettings().toJson()),
      row(SettingKeys.store, const StoreSettings().toJson()),
      row(SettingKeys.receipt, const ReceiptSettings().toJson()),
    ]);

    final out = File('build/golive.json')..createSync(recursive: true);
    out.writeAsStringSync(const JsonEncoder.withIndent(' ').convert(writes));
    // ignore: avoid_print
    print('wrote ${writes.length} writes to ${out.path}');
    await db.close();
  });
}
