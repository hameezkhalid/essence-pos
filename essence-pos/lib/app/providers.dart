import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/db/database.dart';
import '../core/models/cart.dart';
import '../core/models/menu_models.dart';
import '../core/models/order_models.dart';
import '../core/models/settings_models.dart';
import '../core/printing/printer_config.dart';
import '../core/services/inventory_service.dart';
import '../core/sync/firestore_remote.dart';
import '../core/sync/sync_engine.dart';
import '../core/tax/tax_engine.dart';
import 'services.dart';

/// Overridden at the root once the terminal is set up.
final servicesProvider = Provider<AppServices>((ref) => throw UnimplementedError('servicesProvider not overridden'));

final dbProvider = Provider<AppDatabase>((ref) => ref.watch(servicesProvider).db);

// ───────────── Settings & reference data ─────────────

final settingsProvider = StreamProvider<AppSettings>((ref) => ref.watch(servicesProvider).settingsRepo.watch());

/// Settings with defaults while loading, for widgets that just need a value.
final settingsValueProvider = Provider<AppSettings>((ref) => ref.watch(settingsProvider).value ?? ref.watch(servicesProvider).ctx.settings);

final taxesProvider = StreamProvider<List<TaxRow>>((ref) => ref.watch(servicesProvider).settingsRepo.watchTaxes());

final paymentMethodsProvider = StreamProvider<List<PaymentMethod>>((ref) => ref.watch(servicesProvider).settingsRepo.watchPaymentMethods());

final activePaymentMethodsProvider =
    Provider<List<PaymentMethod>>((ref) => (ref.watch(paymentMethodsProvider).value ?? const []).where((m) => m.active).toList());

final areasProvider = StreamProvider<List<Area>>((ref) => ref.watch(servicesProvider).settingsRepo.watchAreas());
final tablesProvider = StreamProvider<List<DiningTable>>((ref) => ref.watch(servicesProvider).settingsRepo.watchTables());
final terminalsProvider = StreamProvider<List<Terminal>>((ref) => ref.watch(servicesProvider).settingsRepo.watchTerminals());

final billConfigProvider = Provider<BillConfig>((ref) {
  final s = ref.watch(settingsValueProvider);
  final taxes = ref.watch(taxesProvider).value ?? const [];
  return BillConfig(
    taxes: [
      for (final t in taxes)
        if (t.enabled) TaxRule(id: t.id, name: t.name, cashBp: t.cashBp, cardOnlineBp: t.cardOnlineBp),
    ],
    pricesIncludeTax: s.pricing.pricesIncludeTax,
    fbrFee: s.fbr.enabled ? s.charges.fbrFee : 0,
    cashRoundingRupees: s.pricing.cashRoundingRupees,
  );
});

// ───────────── Menu ─────────────

final categoriesProvider = StreamProvider<List<MenuCategory>>((ref) => ref.watch(servicesProvider).menu.watchCategories());
final productsProvider = StreamProvider<List<Product>>((ref) => ref.watch(servicesProvider).menu.watchProducts());
final modifierGroupsProvider = StreamProvider<List<ModifierGroup>>((ref) => ref.watch(servicesProvider).menu.watchModifierGroups());

final modifierGroupMapProvider = Provider<Map<String, ModifierGroup>>(
  (ref) => {for (final g in ref.watch(modifierGroupsProvider).value ?? const <ModifierGroup>[]) g.id: g},
);

// ───────────── People ─────────────

final staffListProvider = StreamProvider<List<StaffMember>>((ref) => ref.watch(servicesProvider).staff.watchStaff());

/// The staff member using the terminal (null = locked).
final sessionProvider = NotifierProvider<SessionNotifier, StaffMember?>(SessionNotifier.new);

class SessionNotifier extends Notifier<StaffMember?> {
  @override
  StaffMember? build() => null;
  void signIn(StaffMember s) => state = s;
  void lock() => state = null;
}

final roleProvider = Provider<Role>((ref) => Role.parse(ref.watch(sessionProvider)?.role));

/// Whether the signed-in staff member has [perm].
final canProvider = Provider.family<bool, Perm>((ref, perm) {
  final s = ref.watch(sessionProvider);
  if (s == null) return false;
  return ref.watch(settingsValueProvider).permissions.allows(Role.parse(s.role), perm);
});

// ───────────── Store logins ─────────────

/// Firebase uid of the store login signed in on this terminal.
final authUidProvider = Provider<String?>((ref) => Firebase.apps.isEmpty ? null : FirebaseAuth.instance.currentUser?.uid);

/// Logins with access to the store (live from Firestore; empty offline or in tests).
final storeAccessProvider = StreamProvider<StoreAccess>((ref) {
  final fs = ref.watch(servicesProvider).firestore;
  return fs == null ? Stream.value(const StoreAccess()) : fs.watchAccess();
});

/// Whether this terminal's login is a store admin (can add and remove logins).
final isStoreAdminProvider = Provider<bool>((ref) => ref.watch(storeAccessProvider).value?.isAdmin(ref.watch(authUidProvider)) ?? false);

// ───────────── Live status ─────────────

final syncStatusProvider = StreamProvider<SyncStatus>((ref) => ref.watch(servicesProvider).sync.statusStream);

final openShiftProvider = StreamProvider<Shift?>((ref) => ref.watch(servicesProvider).shifts.watchOpenShift());

final heldOrdersProvider = StreamProvider<List<Order>>((ref) => ref.watch(servicesProvider).pos.watchHeld());

final stockProvider = StreamProvider<List<StockView>>((ref) => ref.watch(servicesProvider).inventory.watchStock());

final recipesProvider = StreamProvider<List<Recipe>>((ref) => ref.watch(servicesProvider).inventory.watchRecipes());

final printersProvider = StreamProvider<List<PrinterConfig>>((ref) => ref.watch(servicesProvider).printer.watchPrinters());

// ───────────── Device preferences ─────────────

final themeModeProvider = StreamProvider<ThemeMode>((ref) => ref.watch(dbProvider).watchMeta('ui.theme').map(themeModeFrom));

ThemeMode themeModeFrom(String? v) => switch (v) { 'light' => ThemeMode.light, 'dark' => ThemeMode.dark, _ => ThemeMode.system };

/// Product grid tile size on this device: 'comfortable' | 'compact'.
final gridDensityProvider = StreamProvider<String>((ref) => ref.watch(dbProvider).watchMeta('ui.density').map((v) => v ?? 'comfortable'));

// ───────────── Cart ─────────────

final cartProvider = NotifierProvider<CartNotifier, CartState>(CartNotifier.new);

class CartNotifier extends Notifier<CartState> {
  @override
  CartState build() => CartState(type: ref.read(settingsValueProvider).orderTypes.effectiveDefault);

  int _seq = 0;
  String _key() => '${DateTime.now().microsecondsSinceEpoch}-${_seq++}';

  void add(Product p, {ProductSize? size, List<SelectedModifier> modifiers = const [], int qty = 1, String? note}) {
    final sizes = p.sizes;
    final chosen = size ?? (sizes.isEmpty ? null : sizes.firstWhere((s) => s.delta == 0, orElse: () => sizes.first));
    final line = OrderLine(
      key: _key(),
      productId: p.id,
      categoryId: p.categoryId,
      name: p.name,
      basePrice: p.price,
      size: chosen,
      modifiers: modifiers,
      qty: qty,
      note: note,
      taxExempt: p.taxExempt,
    );
    final i = state.lines.indexWhere((l) => l.signature == line.signature && l.discount == null && l.sentQty == 0);
    if (i >= 0) {
      final l = state.lines[i];
      state = state.copyWith(lines: [...state.lines]..[i] = l.copyWith(qty: l.qty + qty));
    } else {
      state = state.copyWith(lines: [...state.lines, line]);
    }
  }

  void replaceLine(OrderLine line) =>
      state = state.copyWith(lines: [for (final l in state.lines) l.key == line.key ? line : l]);

  void setQty(String key, int qty) {
    if (qty <= 0) {
      remove(key);
      return;
    }
    state = state.copyWith(lines: [for (final l in state.lines) l.key == key ? l.copyWith(qty: qty) : l]);
  }

  OrderLine? remove(String key) {
    final l = state.lines.where((x) => x.key == key).firstOrNull;
    state = state.copyWith(lines: state.lines.where((x) => x.key != key).toList());
    return l;
  }

  void restore(OrderLine line, int index) {
    final lines = [...state.lines]..insert(index.clamp(0, state.lines.length), line);
    state = state.copyWith(lines: lines);
  }

  void setType(OrderType t) {
    state = t == OrderType.dineIn ? state.copyWith(type: t) : state.copyWith(type: t, clearTable: true);
  }

  void setTable(DiningTable? t, {int? guests}) => state = t == null
      ? state.copyWith(clearTable: true)
      : state.copyWith(type: OrderType.dineIn, tableId: t.id, tableLabel: t.label, guests: guests);

  void setCustomer(Customer? c, {String? address}) => state = c == null
      ? state.copyWith(clearCustomer: true)
      : state.copyWith(customerId: c.id, customerName: c.name, customerPhone: c.phone, deliveryAddress: address ?? c.address);

  void setOrderDiscount(Discount? d, {String? approvedBy}) =>
      state = d == null ? state.copyWith(clearDiscount: true) : state.copyWith(orderDiscount: d, discountApprovedBy: approvedBy);

  void setNote(String? n) => state = (n == null || n.trim().isEmpty) ? state.copyWith(clearNote: true) : state.copyWith(note: n.trim());

  void load(CartState c) => state = c;

  void clear() => state = CartState(type: ref.read(settingsValueProvider).orderTypes.effectiveDefault);
}
