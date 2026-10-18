import 'package:drift/drift.dart';

/// Columns shared by every table that syncs to Firestore.
/// Times are epoch milliseconds. Rows are never hard-deleted; `deleted` hides them.
mixin SyncColumns on Table {
  TextColumn get id => text()();
  IntColumn get updatedAt => integer()();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// ───────────────────────── Menu ─────────────────────────

@DataClassName('MenuCategory')
class Categories extends Table with SyncColumns {
  TextColumn get name => text()();
  TextColumn get icon => text().withDefault(const Constant('coffee'))();
  IntColumn get color => integer().withDefault(const Constant(0xFF8A5A36))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
}

class Products extends Table with SyncColumns {
  TextColumn get categoryId => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();

  /// Base price in paisa (for the default/first size).
  IntColumn get price => integer()();

  /// JSON list: [{"code":"S","label":"Small","delta":-5000}]
  TextColumn get sizesJson => text().withDefault(const Constant('[]'))();

  /// JSON list of modifier group ids.
  TextColumn get modifierGroupIdsJson => text().withDefault(const Constant('[]'))();
  BoolColumn get taxExempt => boolean().withDefault(const Constant(false))();
  TextColumn get icon => text().withDefault(const Constant('coffee'))();
  IntColumn get color => integer().withDefault(const Constant(0xFF8A5A36))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get active => boolean().withDefault(const Constant(true))();

  /// False when "86'd" (sold out today).
  BoolColumn get available => boolean().withDefault(const Constant(true))();
  BoolColumn get favourite => boolean().withDefault(const Constant(false))();
  TextColumn get sku => text().nullable()();
}

class ModifierGroups extends Table with SyncColumns {
  TextColumn get name => text()();
  IntColumn get minSelect => integer().withDefault(const Constant(0))();
  IntColumn get maxSelect => integer().withDefault(const Constant(1))();

  /// JSON list: [{"id":"oat","name":"Oat milk","delta":15000,
  ///   "stockItemId":"oat","qty":200,"replacesStockItemId":"milk"}]
  TextColumn get optionsJson => text().withDefault(const Constant('[]'))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

// ───────────────────────── Tax & payments ─────────────────────────

@DataClassName('TaxRow')
class Taxes extends Table with SyncColumns {
  TextColumn get name => text()();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
  IntColumn get cashBp => integer()();
  IntColumn get cardOnlineBp => integer()();

  /// GST is built in: its name is fixed and it can't be deleted.
  BoolColumn get builtIn => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

class PaymentMethods extends Table with SyncColumns {
  TextColumn get name => text()();

  /// 'cash' or 'cardOnline'.
  TextColumn get rateGroup => text()();
  TextColumn get icon => text().withDefault(const Constant('payments'))();
  BoolColumn get opensDrawer => boolean().withDefault(const Constant(false))();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
  BoolColumn get builtIn => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

// ───────────────────────── Floor ─────────────────────────

class Areas extends Table with SyncColumns {
  TextColumn get name => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

@DataClassName('DiningTable')
class DiningTables extends Table with SyncColumns {
  TextColumn get areaId => text()();
  TextColumn get label => text()();
  IntColumn get seats => integer().withDefault(const Constant(4))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
}

// ───────────────────────── People ─────────────────────────

@DataClassName('StaffMember')
class Staff extends Table with SyncColumns {
  TextColumn get name => text()();

  /// 'owner' | 'manager' | 'cashier'
  TextColumn get role => text()();
  TextColumn get pinHash => text()();
  TextColumn get pinSalt => text()();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
  IntColumn get color => integer().withDefault(const Constant(0xFF4E5726))();
}

class Customers extends Table with SyncColumns {
  TextColumn get name => text()();
  TextColumn get phone => text().withDefault(const Constant(''))();
  TextColumn get address => text().nullable()();
  TextColumn get notes => text().nullable()();
  IntColumn get createdAt => integer()();
}

// ───────────────────────── Sales ─────────────────────────

class Orders extends Table with SyncColumns {
  /// Invoice number, e.g. ESS-T1-000482. Null while held.
  TextColumn get number => text().nullable()();

  /// Daily order token for calling orders (#001…).
  IntColumn get token => integer().nullable()();
  TextColumn get businessDate => text()();

  /// 'dineIn' | 'takeaway' | 'delivery'
  TextColumn get orderType => text()();

  /// 'held' | 'paid' | 'voided' | 'refunded' | 'partiallyRefunded'
  TextColumn get status => text()();
  TextColumn get tableId => text().nullable()();
  TextColumn get tableLabel => text().nullable()();
  IntColumn get guests => integer().nullable()();
  TextColumn get customerId => text().nullable()();
  TextColumn get customerName => text().nullable()();
  TextColumn get customerPhone => text().nullable()();
  TextColumn get deliveryAddress => text().nullable()();
  TextColumn get linesJson => text()();
  TextColumn get orderDiscountJson => text().nullable()();
  TextColumn get chargesJson => text().withDefault(const Constant('[]'))();
  TextColumn get taxLinesJson => text().withDefault(const Constant('[]'))();
  TextColumn get paymentsJson => text().withDefault(const Constant('[]'))();
  BoolColumn get pricesIncludeTax => boolean().withDefault(const Constant(false))();
  IntColumn get itemsGross => integer().withDefault(const Constant(0))();
  IntColumn get discountTotal => integer().withDefault(const Constant(0))();
  IntColumn get chargesTotal => integer().withDefault(const Constant(0))();
  IntColumn get taxTotal => integer().withDefault(const Constant(0))();
  IntColumn get fbrFee => integer().withDefault(const Constant(0))();
  IntColumn get rounding => integer().withDefault(const Constant(0))();
  IntColumn get total => integer().withDefault(const Constant(0))();
  IntColumn get netExTax => integer().withDefault(const Constant(0))();
  IntColumn get refundedTotal => integer().withDefault(const Constant(0))();
  TextColumn get note => text().nullable()();
  TextColumn get staffId => text()();
  TextColumn get staffName => text()();
  TextColumn get shiftId => text().nullable()();
  TextColumn get deviceId => text()();
  TextColumn get deviceCode => text()();
  BoolColumn get kotSent => boolean().withDefault(const Constant(false))();

  /// 'none' | 'pending' | 'reported' | 'failed'
  TextColumn get fiscalStatus => text().withDefault(const Constant('none'))();
  TextColumn get fiscalInvoiceNo => text().nullable()();
  TextColumn get fiscalError => text().nullable()();
  IntColumn get fiscalAt => integer().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get paidAt => integer().nullable()();
  TextColumn get voidReason => text().nullable()();
  TextColumn get voidedBy => text().nullable()();
}

class Refunds extends Table with SyncColumns {
  TextColumn get orderId => text()();
  TextColumn get orderNumber => text()();

  /// JSON list: [{"key":..,"name":..,"qty":..,"amount":..}]
  TextColumn get linesJson => text()();
  IntColumn get amount => integer()();
  IntColumn get taxAmount => integer()();
  TextColumn get methodId => text()();
  TextColumn get methodName => text()();
  TextColumn get rateGroup => text()();
  TextColumn get reason => text()();
  BoolColumn get restock => boolean().withDefault(const Constant(true))();
  TextColumn get staffId => text()();
  TextColumn get staffName => text()();
  TextColumn get approvedBy => text().nullable()();
  TextColumn get shiftId => text().nullable()();
  TextColumn get deviceId => text()();
  TextColumn get businessDate => text()();
  IntColumn get createdAt => integer()();
}

// ───────────────────────── Shifts ─────────────────────────

class Shifts extends Table with SyncColumns {
  TextColumn get deviceId => text()();
  TextColumn get deviceCode => text()();

  /// 'open' | 'closed'
  TextColumn get status => text()();
  TextColumn get openedById => text()();
  TextColumn get openedByName => text()();
  IntColumn get openedAt => integer()();
  IntColumn get openingFloat => integer()();
  TextColumn get closedById => text().nullable()();
  TextColumn get closedByName => text().nullable()();
  IntColumn get closedAt => integer().nullable()();
  IntColumn get countedCash => integer().nullable()();
  IntColumn get expectedCash => integer().nullable()();
  TextColumn get note => text().nullable()();

  /// Frozen Z-report figures written when the shift closes.
  TextColumn get summaryJson => text().nullable()();
}

class CashMovements extends Table with SyncColumns {
  TextColumn get shiftId => text()();

  /// 'in' | 'out'
  TextColumn get type => text()();
  IntColumn get amount => integer()();
  TextColumn get reason => text()();
  TextColumn get staffId => text()();
  TextColumn get staffName => text()();
  IntColumn get createdAt => integer()();
}

// ───────────────────────── Inventory ─────────────────────────

class StockItems extends Table with SyncColumns {
  TextColumn get name => text()();

  /// Group shown in the list, e.g. Coffee, Dairy, Bakery, Packaging.
  TextColumn get groupName => text().withDefault(const Constant('General'))();

  /// Base unit for quantities: 'g' | 'ml' | 'pcs'.
  TextColumn get unit => text()();

  /// Quantities below this need reordering (base units).
  RealColumn get reorderLevel => real().withDefault(const Constant(0))();

  /// Target level used for suggested purchase quantities (base units).
  RealColumn get parLevel => real().withDefault(const Constant(0))();

  /// Cost in paisa per purchase unit (kg for g, L for ml, piece for pcs).
  IntColumn get costPerUnit => integer().withDefault(const Constant(0))();
  TextColumn get icon => text().withDefault(const Constant('inventory'))();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
}

class Recipes extends Table with SyncColumns {
  TextColumn get productId => text()();

  /// Size code this recipe is for; empty = all sizes (scaled S 0.8 / L 1.3 when no size recipe).
  TextColumn get sizeCode => text().withDefault(const Constant(''))();

  /// JSON list: [{"stockItemId":"beans","qty":18}]
  TextColumn get itemsJson => text().withDefault(const Constant('[]'))();
}

class StockMovements extends Table with SyncColumns {
  TextColumn get stockItemId => text()();

  /// Signed quantity in base units.
  RealColumn get qty => real()();

  /// 'opening' | 'sale' | 'stockIn' | 'wastage' | 'count' | 'refund' | 'void'
  TextColumn get type => text()();
  TextColumn get refId => text().nullable()();
  TextColumn get note => text().nullable()();

  /// Paisa per purchase unit for stock-ins.
  IntColumn get unitCost => integer().nullable()();
  TextColumn get staffId => text().nullable()();
  TextColumn get staffName => text().nullable()();
  TextColumn get deviceId => text().nullable()();
  IntColumn get createdAt => integer()();
}

// ───────────────────────── System ─────────────────────────

class AuditLogs extends Table with SyncColumns {
  TextColumn get action => text()();
  TextColumn get staffId => text()();
  TextColumn get staffName => text()();
  TextColumn get approvedById => text().nullable()();
  TextColumn get approvedByName => text().nullable()();
  TextColumn get detailsJson => text().withDefault(const Constant('{}'))();
  TextColumn get deviceId => text().nullable()();
  IntColumn get createdAt => integer()();
}

/// Store-wide settings documents, one row per section (store, pricing, receipt, …).
@DataClassName('SettingRow')
class SettingsEntries extends Table with SyncColumns {
  TextColumn get valueJson => text()();
}

@DataClassName('Terminal')
class Terminals extends Table with SyncColumns {
  TextColumn get name => text()();
  TextColumn get code => text()();
  IntColumn get lastSeenAt => integer().withDefault(const Constant(0))();
  TextColumn get appVersion => text().withDefault(const Constant(''))();
}

// ───────────────────────── Local only ─────────────────────────

/// Writes waiting to be pushed to Firestore, in order.
@DataClassName('OutboxEntry')
class Outbox extends Table {
  IntColumn get seq => integer().autoIncrement()();
  TextColumn get collection => text()();
  TextColumn get docId => text()();
  TextColumn get payload => text()();
  IntColumn get createdAt => integer()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
}

/// Device-local key/value (device id, counters, printers, theme, pull cursors).
@DataClassName('LocalMetaEntry')
class LocalMeta extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
