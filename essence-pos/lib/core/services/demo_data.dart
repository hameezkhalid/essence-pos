import 'dart:convert';
import 'dart:math';

import 'package:intl/intl.dart';

import '../db/database.dart';
import '../models/menu_models.dart';
import '../models/order_models.dart';
import '../models/settings_models.dart';
import '../tax/tax_engine.dart';
import 'pos_context.dart';
import 'repos.dart';

/// Builds the demo store: menu, modifiers, inventory with recipes, staff, tables, customers,
/// settings and 30 days of sales history. Everything is written through the outbox, so it
/// syncs to Firestore like any other data.
class DemoData {
  DemoData(this.db, this.device);
  final AppDatabase db;
  final DeviceInfo device;
  final _r = Random(20261016);

  static int rs(num rupees) => (rupees * 100).round();

  Future<void> seed({void Function(String step)? onStep}) async {
    final now = nowMs();
    onStep?.call('Settings & taxes');
    final settings = AppSettings(
      store: const StoreSettings(
        address: 'Shop 4, Gulberg Greens Commercial, Islamabad',
        phone: '+92 51 000 0000',
        email: 'hello@essence.pk',
        ntn: '0000000-0',
        strn: '00-00-0000-000-00',
      ),
      fbr: const FbrSettings(),
    );
    final settingsRepo = SettingsRepo(db);
    await settingsRepo.saveAll(settings);

    await db.saveAllSynced(db.taxes, [
      TaxRow(id: 'gst', updatedAt: now, deleted: false, name: 'GST', enabled: true, cashBp: 1500, cardOnlineBp: 500, builtIn: true, sortOrder: 0),
    ]);

    final methods = [
      _pm('cash', 'Cash', 'cash', 'cash', 0, drawer: true, builtIn: true),
      _pm('card', 'Card', 'cardOnline', 'card', 1),
      _pm('jazzcash', 'JazzCash', 'cardOnline', 'wallet', 2),
      _pm('easypaisa', 'Easypaisa', 'cardOnline', 'wallet', 3),
      _pm('bank', 'Bank transfer', 'cardOnline', 'bank', 4),
    ];
    await db.saveAllSynced(db.paymentMethods, methods);

    onStep?.call('Tables');
    await db.saveAllSynced(db.areas, [
      Area(id: 'ground', updatedAt: now, deleted: false, name: 'Ground floor', sortOrder: 0),
      Area(id: 'terrace', updatedAt: now, deleted: false, name: 'Terrace', sortOrder: 1),
    ]);
    final tables = [
      for (var i = 1; i <= 12; i++)
        DiningTable(
          id: 't$i',
          updatedAt: now,
          deleted: false,
          areaId: i <= 8 ? 'ground' : 'terrace',
          label: '$i',
          seats: i % 3 == 0 ? 4 : 2,
          sortOrder: i,
          active: true,
        ),
    ];
    await db.saveAllSynced(db.diningTables, tables);

    onStep?.call('Staff');
    final staff = [
      StaffRepo.build(id: 'owner', name: 'Hamza Asif', role: Role.owner, pin: '1111', color: 0xFF4E5726),
      StaffRepo.build(id: 'manager', name: 'Bilal Ahmed', role: Role.manager, pin: '2222', color: 0xFF8A5A36),
      StaffRepo.build(id: 'cashier', name: 'Sara Malik', role: Role.cashier, pin: '3333', color: 0xFF6B7F8C),
    ];
    await db.saveAllSynced(db.staff, staff);

    onStep?.call('Menu');
    await db.saveAllSynced(db.categories, _categories(now));
    await db.saveAllSynced(db.modifierGroups, _modifierGroups(now));
    final products = _products(now);
    await db.saveAllSynced(db.products, products);

    onStep?.call('Inventory & recipes');
    final items = _stockItems(now);
    await db.saveAllSynced(db.stockItems, items);
    await db.saveAllSynced(db.recipes, _recipes(now));
    final start = DateTime.now().subtract(const Duration(days: 31)).millisecondsSinceEpoch;
    await db.saveAllSynced(db.stockMovements, [
      for (final e in _openingLevels.entries)
        StockMovement(
          id: newId(),
          updatedAt: now,
          deleted: false,
          stockItemId: e.key,
          qty: e.value,
          type: 'opening',
          note: 'Opening stock',
          createdAt: start,
          staffId: 'owner',
          staffName: 'Hamza Asif',
          deviceId: device.id,
        ),
    ]);

    onStep?.call('Customers');
    final customers = _customers(now);
    await db.saveAllSynced(db.customers, customers);

    onStep?.call('30 days of sales history');
    await _history(settings, products, methods, tables, customers, staff);
  }

  PaymentMethod _pm(String id, String name, String group, String icon, int sort, {bool drawer = false, bool builtIn = false}) =>
      PaymentMethod(
        id: id,
        updatedAt: nowMs(),
        deleted: false,
        name: name,
        rateGroup: group,
        icon: icon,
        opensDrawer: drawer,
        active: true,
        builtIn: builtIn,
        sortOrder: sort,
      );

  List<MenuCategory> _categories(int now) {
    MenuCategory c(String id, String name, String icon, int color, int sort) =>
        MenuCategory(id: id, updatedAt: now, deleted: false, name: name, icon: icon, color: color, sortOrder: sort, active: true);
    return [
      c('hot', 'Hot Coffee', 'coffee', 0xFF8A5A36, 0),
      c('iced', 'Iced Coffee', 'iced', 0xFF5B7A8C, 1),
      c('tea', 'Tea & More', 'tea', 0xFF4E5726, 2),
      c('patisserie', 'Patisserie', 'croissant', 0xFFB7791F, 3),
      c('cakes', 'Cakes & Desserts', 'cake', 0xFF9C4A5A, 4),
      c('savoury', 'Savoury', 'sandwich', 0xFF6B5B3E, 5),
    ];
  }

  static const _hotSizes = [ProductSize(code: 'S', label: 'Small', delta: -10000), ProductSize(code: 'M', label: 'Medium'), ProductSize(code: 'L', label: 'Large', delta: 15000)];
  static const _icedSizes = [ProductSize(code: 'M', label: 'Regular'), ProductSize(code: 'L', label: 'Large', delta: 15000)];
  static const _espressoSizes = [ProductSize(code: 'M', label: 'Single'), ProductSize(code: 'L', label: 'Double', delta: 15000)];

  List<ModifierGroup> _modifierGroups(int now) {
    ModifierGroup g(String id, String name, int min, int max, List<ModifierOption> opts, int sort) => ModifierGroup(
          id: id,
          updatedAt: now,
          deleted: false,
          name: name,
          minSelect: min,
          maxSelect: max,
          optionsJson: jsonEncode(opts.map((o) => o.toJson()).toList()),
          sortOrder: sort,
        );
    return [
      g('milk', 'Milk', 0, 1, const [
        ModifierOption(id: 'oat', name: 'Oat milk', delta: 15000, stockItemId: 'oat', replacesStockItemId: 'milk'),
        ModifierOption(id: 'almond', name: 'Almond milk', delta: 18000, stockItemId: 'almond', replacesStockItemId: 'milk'),
      ], 0),
      g('extras', 'Extras', 0, 4, const [
        ModifierOption(id: 'shot', name: 'Extra shot', delta: 15000, stockItemId: 'beans', qty: 18),
        ModifierOption(id: 'vanilla', name: 'Vanilla syrup', delta: 12000, stockItemId: 'vanilla', qty: 15),
        ModifierOption(id: 'caramel', name: 'Caramel syrup', delta: 12000, stockItemId: 'caramel', qty: 15),
        ModifierOption(id: 'hazelnut', name: 'Hazelnut syrup', delta: 12000, stockItemId: 'hazelnut', qty: 15),
        ModifierOption(id: 'whip', name: 'Whipped cream', delta: 10000, stockItemId: 'cream', qty: 25),
      ], 1),
      g('sweet', 'Sweetness', 0, 1, const [
        ModifierOption(id: 'nosugar', name: 'No sugar'),
        ModifierOption(id: 'less', name: 'Less sweet'),
        ModifierOption(id: 'extra', name: 'Extra sweet'),
      ], 2),
      g('ice', 'Ice', 0, 1, const [
        ModifierOption(id: 'lessice', name: 'Less ice'),
        ModifierOption(id: 'noice', name: 'No ice'),
      ], 3),
      g('serve', 'Serve', 0, 1, const [
        ModifierOption(id: 'warm', name: 'Warmed'),
        ModifierOption(id: 'box', name: 'Gift box', delta: 5000, stockItemId: 'boxes', qty: 1),
      ], 4),
    ];
  }

  List<Product> _products(int now) {
    var sort = 0;
    Product p(String id, String cat, String name, num price, String icon, int color,
            {List<ProductSize> sizes = const [], List<String> mods = const [], bool fav = false, String? desc}) =>
        Product(
          id: id,
          updatedAt: now,
          deleted: false,
          categoryId: cat,
          name: name,
          description: desc,
          price: rs(price),
          sizesJson: jsonEncode(sizes.map((s) => s.toJson()).toList()),
          modifierGroupIdsJson: jsonEncode(mods),
          taxExempt: false,
          icon: icon,
          color: color,
          sortOrder: sort++,
          active: true,
          available: true,
          favourite: fav,
        );
    const coffee = 0xFF8A5A36, latte = 0xFFB08A5E, iced = 0xFF5B7A8C, tea = 0xFF4E5726, pastry = 0xFFB7791F, cake = 0xFF9C4A5A, sav = 0xFF6B5B3E;
    const hotMods = ['milk', 'extras', 'sweet'];
    const icedMods = ['milk', 'extras', 'sweet', 'ice'];
    return [
      p('espresso', 'hot', 'Espresso', 450, 'espresso', coffee, sizes: _espressoSizes, mods: const ['extras']),
      p('americano', 'hot', 'Americano', 550, 'coffee', coffee, sizes: _hotSizes, mods: const ['extras', 'sweet']),
      p('cappuccino', 'hot', 'Cappuccino', 650, 'coffee', latte, sizes: _hotSizes, mods: hotMods, fav: true),
      p('latte', 'hot', 'Café Latte', 650, 'latte', latte, sizes: _hotSizes, mods: hotMods, fav: true),
      p('flatwhite', 'hot', 'Flat White', 700, 'latte', latte, sizes: _hotSizes, mods: hotMods),
      p('cortado', 'hot', 'Cortado', 600, 'espresso', coffee, mods: const ['milk', 'sweet']),
      p('spanish', 'hot', 'Spanish Latte', 790, 'latte', 0xFFC08552, sizes: _hotSizes, mods: hotMods, fav: true),
      p('mocha', 'hot', 'Mocha', 750, 'coffee', 0xFF6B4226, sizes: _hotSizes, mods: hotMods),
      p('caramelmac', 'hot', 'Caramel Macchiato', 790, 'latte', 0xFFC9954C, sizes: _hotSizes, mods: hotMods),
      p('hazelnut', 'hot', 'Hazelnut Latte', 790, 'latte', 0xFF9A6B42, sizes: _hotSizes, mods: hotMods),
      p('icedamericano', 'iced', 'Iced Americano', 600, 'iced', iced, sizes: _icedSizes, mods: const ['extras', 'sweet', 'ice']),
      p('icedlatte', 'iced', 'Iced Latte', 750, 'iced', iced, sizes: _icedSizes, mods: icedMods, fav: true),
      p('icedspanish', 'iced', 'Iced Spanish Latte', 850, 'iced', 0xFFC08552, sizes: _icedSizes, mods: icedMods),
      p('icedmocha', 'iced', 'Iced Mocha', 850, 'iced', 0xFF6B4226, sizes: _icedSizes, mods: icedMods),
      p('coldbrew', 'iced', 'Cold Brew', 700, 'iced', 0xFF3E3A36, sizes: _icedSizes, mods: const ['sweet', 'ice']),
      p('caramelfrappe', 'iced', 'Caramel Frappé', 950, 'frappe', 0xFFC9954C, sizes: _icedSizes, mods: const ['milk', 'extras']),
      p('mochafrappe', 'iced', 'Mocha Frappé', 950, 'frappe', 0xFF6B4226, sizes: _icedSizes, mods: const ['milk', 'extras']),
      p('karak', 'tea', 'Karak Chai', 350, 'tea', 0xFFA0703E, mods: const ['sweet'], fav: true),
      p('masalachai', 'tea', 'Masala Chai Latte', 600, 'tea', 0xFFA0703E, sizes: _hotSizes, mods: const ['milk', 'sweet']),
      p('matcha', 'tea', 'Matcha Latte', 850, 'matcha', tea, sizes: _hotSizes, mods: const ['milk', 'sweet']),
      p('icedmatcha', 'tea', 'Iced Matcha', 900, 'matcha', tea, sizes: _icedSizes, mods: const ['milk', 'sweet', 'ice']),
      p('hotchoc', 'tea', 'Hot Chocolate', 700, 'chocolate', 0xFF6B4226, sizes: _hotSizes, mods: const ['milk', 'extras']),
      p('englishtea', 'tea', 'English Breakfast Tea', 400, 'tea', tea, mods: const ['sweet']),
      p('lemonade', 'tea', 'Fresh Mint Lemonade', 450, 'juice', 0xFF7A9A3A, mods: const ['sweet', 'ice']),
      p('water', 'tea', 'Mineral Water', 120, 'water', 0xFF5B7A8C),
      p('croissant', 'patisserie', 'Butter Croissant', 550, 'croissant', pastry, mods: const ['serve'], fav: true),
      p('almondcroissant', 'patisserie', 'Almond Croissant', 750, 'croissant', pastry, mods: const ['serve']),
      p('painchoc', 'patisserie', 'Pain au Chocolat', 650, 'croissant', 0xFF6B4226, mods: const ['serve']),
      p('cinnamon', 'patisserie', 'Cinnamon Roll', 600, 'bakery', pastry, mods: const ['serve']),
      p('eclair', 'patisserie', 'Chocolate Éclair', 550, 'bakery', 0xFF6B4226),
      p('macarons', 'patisserie', 'Macarons · Box of 6', 1500, 'cookie', 0xFFC77B8B, mods: const ['serve']),
      p('muffin', 'patisserie', 'Blueberry Muffin', 550, 'cupcake', 0xFF5A5A8C, mods: const ['serve']),
      p('danish', 'patisserie', 'Fruit Danish', 650, 'bakery', pastry, mods: const ['serve']),
      p('basque', 'cakes', 'Basque Cheesecake', 950, 'cake', 0xFFB7791F),
      p('lotus', 'cakes', 'Lotus Cheesecake', 990, 'cake', 0xFFA0703E),
      p('tiramisu', 'cakes', 'Tiramisu', 950, 'cake', 0xFF8A5A36),
      p('fudge', 'cakes', 'Chocolate Fudge Cake', 850, 'cake', 0xFF4A2E1E),
      p('redvelvet', 'cakes', 'Red Velvet Slice', 850, 'cake', cake),
      p('tresleches', 'cakes', 'Pistachio Tres Leches', 990, 'cake', 0xFF7A8C4A),
      p('chickencroissant', 'savoury', 'Chicken Croissant Sandwich', 1150, 'croissant', sav, mods: const ['serve']),
      p('club', 'savoury', 'Club Sandwich', 1250, 'sandwich', sav),
      p('quiche', 'savoury', 'Quiche Lorraine', 890, 'quiche', 0xFFB7791F, mods: const ['serve']),
      p('panini', 'savoury', 'Grilled Chicken Panini', 1150, 'sandwich', sav),
      p('avotoast', 'savoury', 'Avocado Toast', 1250, 'toast', 0xFF7A9A3A),
    ];
  }

  List<StockItem> _stockItems(int now) {
    StockItem s(String id, String name, String group, String unit, double reorder, double par, num costRs, String icon) => StockItem(
          id: id,
          updatedAt: now,
          deleted: false,
          name: name,
          groupName: group,
          unit: unit,
          reorderLevel: reorder,
          parLevel: par,
          costPerUnit: rs(costRs),
          icon: icon,
          active: true,
        );
    return [
      s('beans', 'Espresso beans', 'Coffee & Tea', 'g', 3000, 10000, 6500, 'beans'),
      s('tea', 'Tea leaves', 'Coffee & Tea', 'g', 500, 2000, 2000, 'tea'),
      s('matchapowder', 'Matcha powder', 'Coffee & Tea', 'g', 150, 500, 18000, 'matcha'),
      s('cocoa', 'Cocoa powder', 'Coffee & Tea', 'g', 400, 2000, 4200, 'chocolate'),
      s('milk', 'Fresh milk', 'Dairy', 'ml', 15000, 40000, 260, 'milk'),
      s('oat', 'Oat milk', 'Dairy', 'ml', 4000, 12000, 1200, 'milk'),
      s('almond', 'Almond milk', 'Dairy', 'ml', 3000, 10000, 1400, 'milk'),
      s('cream', 'Fresh cream', 'Dairy', 'ml', 2000, 6000, 900, 'milk'),
      s('condensed', 'Condensed milk', 'Dairy', 'ml', 1000, 4000, 900, 'milk'),
      s('creamcheese', 'Cream cheese', 'Dairy', 'g', 1000, 4000, 2800, 'cheese'),
      s('butter', 'Butter', 'Dairy', 'g', 1000, 5000, 2200, 'cheese'),
      s('caramel', 'Caramel syrup', 'Syrups', 'ml', 700, 3000, 2400, 'syrup'),
      s('vanilla', 'Vanilla syrup', 'Syrups', 'ml', 700, 3000, 2400, 'syrup'),
      s('hazelnutsyrup', 'Hazelnut syrup', 'Syrups', 'ml', 700, 3000, 2600, 'syrup'),
      s('dough', 'Croissant dough', 'Bakery', 'pcs', 12, 40, 120, 'croissant'),
      s('flour', 'Flour', 'Bakery', 'g', 5000, 20000, 140, 'flour'),
      s('sugar', 'Sugar', 'Bakery', 'g', 2000, 10000, 160, 'sugar'),
      s('eggs', 'Eggs', 'Bakery', 'pcs', 30, 120, 35, 'egg'),
      s('chicken', 'Chicken fillet', 'Kitchen', 'g', 2000, 6000, 1100, 'chicken'),
      s('bread', 'Sourdough bread', 'Kitchen', 'pcs', 20, 60, 30, 'bread'),
      s('avocado', 'Avocados', 'Kitchen', 'pcs', 8, 30, 220, 'avocado'),
      s('lemons', 'Lemons', 'Kitchen', 'pcs', 20, 60, 15, 'lemon'),
      s('cups', 'Hot cups 12oz', 'Packaging', 'pcs', 300, 1000, 18, 'cup'),
      s('icedcups', 'Iced cups 16oz', 'Packaging', 'pcs', 200, 600, 25, 'cup'),
      s('lids', 'Lids', 'Packaging', 'pcs', 400, 1500, 8, 'cup'),
      s('boxes', 'Pastry boxes', 'Packaging', 'pcs', 50, 200, 35, 'box'),
      s('waterbottle', 'Water bottles', 'Packaging', 'pcs', 24, 96, 60, 'water'),
    ];
  }

  static const _openingLevels = <String, double>{
    'beans': 7400, 'tea': 1650, 'matchapowder': 420, 'cocoa': 1500, 'milk': 26000, 'oat': 3500, 'almond': 6200,
    'cream': 4100, 'condensed': 2600, 'creamcheese': 2900, 'butter': 3800, 'caramel': 300, 'vanilla': 2100,
    'hazelnutsyrup': 1800, 'dough': 10, 'flour': 14500, 'sugar': 7200, 'eggs': 84, 'chicken': 4600, 'bread': 38,
    'avocado': 14, 'lemons': 42, 'cups': 640, 'icedcups': 180, 'lids': 1100, 'boxes': 130, 'waterbottle': 60,
  };

  List<Recipe> _recipes(int now) {
    Recipe r(String productId, Map<String, double> items) => Recipe(
          id: productId,
          updatedAt: now,
          deleted: false,
          productId: productId,
          sizeCode: '',
          itemsJson: jsonEncode([for (final e in items.entries) RecipeItem(stockItemId: e.key, qty: e.value).toJson()]),
        );
    const hot = {'cups': 1.0, 'lids': 1.0};
    const cold = {'icedcups': 1.0, 'lids': 1.0};
    return [
      r('espresso', {'beans': 18, 'cups': 1}),
      r('americano', {'beans': 18, ...hot}),
      r('cappuccino', {'beans': 18, 'milk': 150, ...hot}),
      r('latte', {'beans': 18, 'milk': 220, ...hot}),
      r('flatwhite', {'beans': 18, 'milk': 140, ...hot}),
      r('cortado', {'beans': 18, 'milk': 60, 'cups': 1}),
      r('spanish', {'beans': 18, 'milk': 180, 'condensed': 30, ...hot}),
      r('mocha', {'beans': 18, 'milk': 180, 'cocoa': 15, ...hot}),
      r('caramelmac', {'beans': 18, 'milk': 200, 'caramel': 20, ...hot}),
      r('hazelnut', {'beans': 18, 'milk': 200, 'hazelnutsyrup': 20, ...hot}),
      r('icedamericano', {'beans': 18, ...cold}),
      r('icedlatte', {'beans': 18, 'milk': 200, ...cold}),
      r('icedspanish', {'beans': 18, 'milk': 180, 'condensed': 30, ...cold}),
      r('icedmocha', {'beans': 18, 'milk': 180, 'cocoa': 15, ...cold}),
      r('coldbrew', {'beans': 25, ...cold}),
      r('caramelfrappe', {'beans': 18, 'milk': 200, 'caramel': 30, 'cream': 30, ...cold}),
      r('mochafrappe', {'beans': 18, 'milk': 200, 'cocoa': 20, 'cream': 30, ...cold}),
      r('karak', {'tea': 6, 'milk': 150, 'sugar': 15, 'cups': 1}),
      r('masalachai', {'tea': 6, 'milk': 200, 'sugar': 15, ...hot}),
      r('matcha', {'matchapowder': 4, 'milk': 220, ...hot}),
      r('icedmatcha', {'matchapowder': 4, 'milk': 200, ...cold}),
      r('hotchoc', {'cocoa': 25, 'milk': 220, ...hot}),
      r('englishtea', {'tea': 4, 'cups': 1}),
      r('lemonade', {'lemons': 2, 'sugar': 30, ...cold}),
      r('water', {'waterbottle': 1}),
      r('croissant', {'dough': 1}),
      r('almondcroissant', {'dough': 1, 'butter': 10, 'sugar': 10}),
      r('painchoc', {'dough': 1, 'cocoa': 5}),
      r('cinnamon', {'flour': 80, 'butter': 20, 'sugar': 20}),
      r('eclair', {'flour': 40, 'cream': 40, 'cocoa': 5, 'eggs': 1}),
      r('macarons', {'sugar': 60, 'eggs': 2, 'boxes': 1}),
      r('muffin', {'flour': 70, 'sugar': 30, 'eggs': 1, 'butter': 15}),
      r('danish', {'dough': 1, 'sugar': 10}),
      r('basque', {'creamcheese': 120, 'sugar': 25, 'eggs': 1, 'cream': 30}),
      r('lotus', {'creamcheese': 110, 'sugar': 20, 'butter': 15}),
      r('tiramisu', {'creamcheese': 80, 'cream': 50, 'beans': 5, 'sugar': 15}),
      r('fudge', {'flour': 60, 'cocoa': 20, 'eggs': 1, 'butter': 20}),
      r('redvelvet', {'flour': 60, 'creamcheese': 40, 'eggs': 1}),
      r('tresleches', {'milk': 100, 'cream': 50, 'eggs': 1, 'flour': 40}),
      r('chickencroissant', {'dough': 1, 'chicken': 80}),
      r('club', {'bread': 3, 'chicken': 100, 'eggs': 1}),
      r('quiche', {'flour': 60, 'eggs': 2, 'cream': 40, 'butter': 15}),
      r('panini', {'bread': 2, 'chicken': 90}),
      r('avotoast', {'bread': 2, 'avocado': 1, 'eggs': 1}),
    ];
  }

  List<Customer> _customers(int now) {
    const people = [
      ('Ayesha Siddiqui', '0300 1234567', 'House 12, Street 4, F-7/2, Islamabad'),
      ('Omar Farooq', '0321 7654321', 'Flat 3B, Gulberg Greens, Islamabad'),
      ('Zainab Raza', '0333 5550112', 'House 45, Bahria Town Phase 4, Rawalpindi'),
      ('Hassan Ali', '0345 1112233', 'DHA Phase 2, Sector B, Islamabad'),
      ('Mariam Khan', '0312 9988776', 'House 7, Street 22, E-11/3, Islamabad'),
      ('Fahad Mehmood', '0301 4455667', 'Satellite Town, Block C, Rawalpindi'),
      ('Hira Naveed', '0322 3344556', 'G-11/2, Street 9, Islamabad'),
      ('Danish Qureshi', '0334 6677889', 'I-8/3, Street 12, Islamabad'),
      ('Sana Javed', '0311 2233445', 'Chaklala Scheme 3, Rawalpindi'),
      ('Ali Haider', '0302 8899001', 'F-10/4, Street 33, Islamabad'),
      ('Noor Fatima', '0346 5566778', 'B-17, Block E, Islamabad'),
      ('Usman Tariq', '0315 6677880', 'Gulraiz Housing, Rawalpindi'),
    ];
    return [
      for (var i = 0; i < people.length; i++)
        Customer(
          id: 'c${i + 1}',
          updatedAt: now,
          deleted: false,
          name: people[i].$1,
          phone: people[i].$2,
          address: people[i].$3,
          createdAt: now - (40 - i) * 86400000,
        ),
    ];
  }

  // ───────────── Sales history ─────────────

  T _pick<T>(List<T> l) => l[_r.nextInt(l.length)];

  T _weighted<T>(List<(T, int)> l) {
    final total = l.fold<int>(0, (a, e) => a + e.$2);
    var x = _r.nextInt(total);
    for (final e in l) {
      if ((x -= e.$2) < 0) return e.$1;
    }
    return l.last.$1;
  }

  Future<void> _history(
    AppSettings settings,
    List<Product> products,
    List<PaymentMethod> methods,
    List<DiningTable> tables,
    List<Customer> customers,
    List<StaffMember> staff,
  ) async {
    final groups = {for (final g in _modifierGroups(0)) g.id: g};
    final config = BillConfig(
      taxes: const [TaxRule(id: 'gst', name: 'GST', cashBp: 1500, cardOnlineBp: 500)],
      fbrFee: settings.charges.fbrFee,
    );
    final byCat = <String, List<Product>>{};
    for (final p in products) {
      byCat.putIfAbsent(p.categoryId, () => []).add(p);
    }
    const hourWeights = {
      8: 6, 9: 14, 10: 16, 11: 11, 12: 9, 13: 10, 14: 8, 15: 9, 16: 11, 17: 14, 18: 15, 19: 14, 20: 12, 21: 9, 22: 5,
    };
    final dateKey = DateFormat('yyyy-MM-dd');
    final now = DateTime.now();
    final orders = <Order>[];
    final shifts = <Shift>[];
    final refunds = <Refund>[];
    var seq = 0;

    for (var d = 30; d >= 0; d--) {
      final day = DateTime(now.year, now.month, now.day).subtract(Duration(days: d));
      final weekend = day.weekday == DateTime.saturday || day.weekday == DateTime.sunday;
      final base = weekend ? 58 : 42;
      final count = base + _r.nextInt(14) - 7;
      final times = <DateTime>[];
      for (var i = 0; i < count; i++) {
        final h = _weighted(hourWeights.entries.map((e) => (e.key, e.value)).toList());
        final t = day.add(Duration(hours: h, minutes: _r.nextInt(60), seconds: _r.nextInt(60)));
        if (d == 0 && t.isAfter(now)) continue;
        times.add(t);
      }
      times.sort();
      if (times.isEmpty) continue;
      final businessDate = dateKey.format(day);
      final shiftId = 'shift-$businessDate-${device.code}';
      final dayOrders = <Order>[];
      var token = 0;

      for (final t in times) {
        token++;
        seq++;
        final lines = <OrderLine>[];
        final nLines = _weighted([(1, 40), (2, 35), (3, 18), (4, 7)]);
        for (var i = 0; i < nLines; i++) {
          final cat = _weighted([('hot', 34), ('iced', 16), ('tea', 14), ('patisserie', 18), ('cakes', 10), ('savoury', 8)]);
          final p = _pick(byCat[cat]!);
          final sizes = p.sizes;
          final size = sizes.isEmpty ? null : (sizes.length == 3 ? _weighted([(sizes[0], 2), (sizes[1], 6), (sizes[2], 3)]) : _pick(sizes));
          final mods = <SelectedModifier>[];
          for (final gid in p.modifierGroupIds) {
            if (_r.nextInt(100) < 18) {
              final g = groups[gid]!;
              mods.add(SelectedModifier(groupId: g.id, groupName: g.name, option: _pick(g.options)));
            }
          }
          final qty = _weighted([(1, 85), (2, 13), (3, 2)]);
          lines.add(OrderLine(
            key: '$seq-$i',
            productId: p.id,
            categoryId: p.categoryId,
            name: p.name,
            basePrice: p.price,
            size: size,
            modifiers: mods,
            qty: qty,
          ));
        }
        final type = _weighted([(OrderType.takeaway, 48), (OrderType.dineIn, 42), (OrderType.delivery, 10)]);
        final table = type == OrderType.dineIn ? _pick(tables) : null;
        final customer = type == OrderType.delivery || _r.nextInt(100) < 12 ? _pick(customers) : null;
        final method = _weighted([(methods[0], 50), (methods[1], 34), (methods[2], 8), (methods[3], 6), (methods[4], 2)]);
        final discount = _r.nextInt(100) < 7 ? const Discount.percent(1000, label: '10%') : null;
        final charges = settings.charges.rulesFor(type);
        final b = computeBill(
          lines: [for (final l in lines) l.toBillLine()],
          orderDiscount: discount,
          charges: charges,
          config: config,
          portions: [PaymentPortionInput(methodId: method.id, methodName: method.name, group: RateGroup.parse(method.rateGroup))],
        );
        final portion = b.portions.single;
        final tendered = method.id == 'cash' ? _cashTender(portion.amount) : null;
        final cashier = _weighted([(staff[2], 70), (staff[1], 25), (staff[0], 5)]);
        final ms = t.millisecondsSinceEpoch;
        final status = _r.nextInt(100) < 1 ? OrderStatus.voided : OrderStatus.paid;
        final number = '${settings.store.invoicePrefix}-${device.code}-${seq.toString().padLeft(6, '0')}';
        final o = Order(
          id: 'hist-$seq',
          updatedAt: ms,
          deleted: false,
          number: number,
          token: token,
          businessDate: businessDate,
          orderType: type.key,
          status: status,
          tableId: table?.id,
          tableLabel: table?.label,
          guests: table == null ? null : 1 + _r.nextInt(4),
          customerId: customer?.id,
          customerName: customer?.name,
          customerPhone: customer?.phone,
          deliveryAddress: type == OrderType.delivery ? customer?.address : null,
          linesJson: jsonEncode([
            for (var i = 0; i < lines.length; i++) lines[i].copyWith(net: b.lines[i].net, sentQty: lines[i].qty).toJson(),
          ]),
          orderDiscountJson: discount == null ? null : jsonEncode(discount.toJson()),
          chargesJson: jsonEncode([
            for (final c in b.charges) ChargeRecord(type: c.type.name, label: c.label, amount: c.amount, taxable: c.taxable).toJson(),
          ]),
          taxLinesJson: jsonEncode([for (final tl in b.taxLines) tl.toJson()]),
          paymentsJson: jsonEncode([
            PaymentRecord(
              methodId: method.id,
              methodName: method.name,
              group: portion.group,
              amount: portion.amount,
              tendered: tendered,
              change: tendered == null ? 0 : tendered - portion.amount,
              taxes: portion.taxes,
            ).toJson(),
          ]),
          pricesIncludeTax: false,
          itemsGross: b.itemsGross,
          discountTotal: b.discountTotal,
          chargesTotal: b.chargesTotal,
          taxTotal: b.taxTotal,
          fbrFee: b.fbrFee,
          rounding: b.rounding,
          total: b.total,
          netExTax: b.netExTax,
          refundedTotal: 0,
          staffId: cashier.id,
          staffName: cashier.name,
          shiftId: shiftId,
          deviceId: device.id,
          deviceCode: device.code,
          kotSent: true,
          fiscalStatus: 'reported',
          fiscalInvoiceNo: '137284-${DateFormat('MMdd').format(t)}-${DateFormat('HHmm').format(t)}-${token.toString().padLeft(2, '0')}${_r.nextInt(10)}',
          fiscalAt: ms + 1500,
          createdAt: ms,
          paidAt: ms,
          voidReason: status == OrderStatus.voided ? 'Wrong item rung up' : null,
          voidedBy: status == OrderStatus.voided ? 'Bilal Ahmed' : null,
        );
        dayOrders.add(o);
      }

      // An occasional refund.
      if (d > 0 && _r.nextInt(3) == 0) {
        final idx = _r.nextInt(dayOrders.length);
        final o = dayOrders[idx];
        if (o.status == OrderStatus.paid) {
          final line = o.lines.first;
          final v = _refundValue(o, line);
          final at = o.createdAt + 20 * 60000;
          refunds.add(Refund(
            id: 'hist-refund-${o.id}',
            updatedAt: at,
            deleted: false,
            orderId: o.id,
            orderNumber: o.number!,
            linesJson: jsonEncode([
              {'key': line.key, 'name': line.title, 'qty': 1, 'amount': line.net ~/ line.qty},
            ]),
            amount: v.$1,
            taxAmount: v.$2,
            methodId: o.payments.first.methodId,
            methodName: o.payments.first.methodName,
            rateGroup: o.payments.first.group.name,
            reason: _pick(['Drink made incorrectly', 'Customer changed mind', 'Item unavailable']),
            restock: false,
            staffId: 'manager',
            staffName: 'Bilal Ahmed',
            approvedBy: 'Bilal Ahmed',
            shiftId: shiftId,
            deviceId: device.id,
            businessDate: businessDate,
            createdAt: at,
          ));
          final newLines = o.lines.map((l) => l.key == line.key ? l.copyWith(refundedQty: 1) : l).toList();
          final all = newLines.every((l) => l.refundedQty >= l.qty);
          dayOrders[idx] = o.copyWith(
            refundedTotal: v.$1,
            status: all ? OrderStatus.refunded : OrderStatus.partiallyRefunded,
            linesJson: jsonEncode([for (final l in newLines) l.toJson()]),
          );
        }
      }
      orders.addAll(dayOrders);

      // One shift per day; today's stays open.
      final openAt = day.add(const Duration(hours: 7, minutes: 45));
      final sales = dayOrders.where((o) => o.isSale);
      final cashSales = sales.expand((o) => o.payments).where((p) => p.group == RateGroup.cash).fold<int>(0, (a, p) => a + p.amount);
      final dayRefundsCash = refunds.where((r) => r.businessDate == businessDate && r.rateGroup == 'cash').fold<int>(0, (a, r) => a + r.amount);
      final expected = rs(10000) + cashSales - rs(1500) - dayRefundsCash;
      final short = d == 0 ? 0 : [0, 0, 0, -rs(50), rs(20), 0, -rs(100)][_r.nextInt(7)];
      final closeAt = day.add(const Duration(hours: 23, minutes: 10));
      shifts.add(Shift(
        id: shiftId,
        updatedAt: (d == 0 ? openAt : closeAt).millisecondsSinceEpoch,
        deleted: false,
        deviceId: device.id,
        deviceCode: device.code,
        status: d == 0 ? 'open' : 'closed',
        openedById: 'cashier',
        openedByName: 'Sara Malik',
        openedAt: openAt.millisecondsSinceEpoch,
        openingFloat: rs(10000),
        closedById: d == 0 ? null : 'manager',
        closedByName: d == 0 ? null : 'Bilal Ahmed',
        closedAt: d == 0 ? null : closeAt.millisecondsSinceEpoch,
        countedCash: d == 0 ? null : expected + short,
        expectedCash: d == 0 ? null : expected,
      ));
    }

    // Cash paid-out for milk each day.
    final moves = <CashMovement>[
      for (final s in shifts)
        CashMovement(
          id: 'cm-${s.id}',
          updatedAt: s.openedAt + 3600000,
          deleted: false,
          shiftId: s.id,
          type: 'out',
          amount: rs(1500),
          reason: 'Fresh milk from local supplier',
          staffId: 'cashier',
          staffName: 'Sara Malik',
          createdAt: s.openedAt + 3600000,
        ),
    ];

    await db.saveAllSynced(db.orders, orders);
    await db.saveAllSynced(db.refunds, refunds);
    await db.saveAllSynced(db.shifts, shifts);
    await db.saveAllSynced(db.cashMovements, moves);

    // Continue numbering after the history.
    await db.setMeta('seq.invoice', '$seq');
    final today = dateKey.format(DateTime(now.year, now.month, now.day));
    final todayCount = orders.where((o) => o.businessDate == today).length;
    await db.setMeta('seq.token.$today', '$todayCount');
  }

  int _cashTender(int amount) {
    final rupees = (amount / 100).ceil();
    final options = [rupees, ((rupees + 99) ~/ 100) * 100, ((rupees + 499) ~/ 500) * 500, ((rupees + 999) ~/ 1000) * 1000];
    return _pick(options) * 100;
  }

  (int, int) _refundValue(Order o, OrderLine line) {
    final linesNet = o.lines.fold<int>(0, (a, l) => a + l.net);
    final phi = (line.net / line.qty) / linesNet;
    final amount = (((o.total - o.fbrFee) * phi) / 100).round() * 100;
    final tax = ((o.taxTotal * phi) / 100).round() * 100;
    return (amount, tax);
  }
}
