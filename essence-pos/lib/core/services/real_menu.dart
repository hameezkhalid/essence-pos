import 'dart:convert';

import '../db/database.dart';
import '../models/menu_models.dart';

/// Essence's dessert menu (from the printed menu), used for new stores and the go-live migration.
/// Prices are starting values — edit them in the admin panel (Menu).
class RealMenu {
  static int rs(num rupees) => (rupees * 100).round();

  static const categories = [
    ('cat-chocolate', 'Chocolate Favourites', 'cake', 0xFF5C3A24),
    ('cat-fruity', 'Fresh & Fruity', 'cupcake', 0xFF8C7A2E),
    ('cat-signature', 'Signature Desserts', 'cake', 0xFF4E5726),
  ];

  /// (id, category, name, description, price Rs, icon, colour)
  static const items = [
    ('m-brownie', 'cat-chocolate', 'Chocolate Fudge Brownie', 'Rich chocolate, cocoa, butter, a hint of vanilla.', 450, 'cookie', 0xFF4A2E1E),
    ('m-chocolate-cake', 'cat-chocolate', 'Chocolate Cake', 'Moist chocolate sponge, velvety chocolate frosting.', 650, 'cake', 0xFF5C3A24),
    ('m-og-cookies', 'cat-chocolate', 'OG Cookies', 'Classic recipe, premium ingredients, loaded with chocolate chips.', 350, 'cookie', 0xFF9A6B42),
    ('m-lemon-tart', 'cat-fruity', 'Lemon Tart', 'Buttery tart shell, zesty lemon curd, fresh cream.', 550, 'cupcake', 0xFFB7901F),
    ('m-lemon-cake', 'cat-fruity', 'Lemon Cake', 'Soft vanilla sponge, lemon glaze, fresh zest.', 550, 'cake', 0xFFC9A227),
    ('m-blueberry-cheesecake', 'cat-fruity', 'Blueberry Cheesecake', 'Creamy cheesecake, real blueberries, buttery biscuit base.', 850, 'cake', 0xFF5A5A8C),
    ('m-banana-bread', 'cat-fruity', 'Banana Bread', 'Ripe bananas, warm spices, golden finish.', 400, 'bakery', 0xFF8A5A36),
    ('m-tres-leches', 'cat-signature', 'Tres Leches Cake', 'Three milks, soft sponge, light whipped cream.', 750, 'cake', 0xFFB08A5E),
    ('m-tiramisu', 'cat-signature', 'Tiramisu', 'Mascarpone, coffee, cocoa, classic Italian style.', 850, 'cake', 0xFF6B4226),
    ('m-salted-caramel-cheesecake', 'cat-signature', 'Salted Caramel Cheesecake', 'Creamy cheesecake, salted caramel, biscuit base.', 850, 'cake', 0xFFC9954C),
    ('m-marble-cake', 'cat-signature', 'Marble Cake', 'Vanilla and chocolate, beautifully swirled.', 450, 'cake', 0xFF6B5B3E),
  ];

  static String stockId(String productId) => 'stk-${productId.substring(2)}';

  static List<MenuCategory> buildCategories(int now) => [
        for (var i = 0; i < categories.length; i++)
          MenuCategory(
            id: categories[i].$1,
            updatedAt: now,
            deleted: false,
            name: categories[i].$2,
            icon: categories[i].$3,
            color: categories[i].$4,
            sortOrder: i,
            active: true,
          ),
      ];

  static List<Product> buildProducts(int now) => [
        for (var i = 0; i < items.length; i++)
          Product(
            id: items[i].$1,
            updatedAt: now,
            deleted: false,
            categoryId: items[i].$2,
            name: items[i].$3,
            description: items[i].$4,
            price: rs(items[i].$5),
            sizesJson: '[]',
            modifierGroupIdsJson: '[]',
            taxExempt: false,
            icon: items[i].$6,
            color: items[i].$7,
            sortOrder: i,
            active: true,
            available: true,
            favourite: false,
          ),
      ];

  /// One stock item per dessert, counted in pieces; each sale deducts one.
  static List<StockItem> buildStockItems(int now) => [
        for (final it in items)
          StockItem(
            id: stockId(it.$1),
            updatedAt: now,
            deleted: false,
            name: it.$3,
            groupName: categories.firstWhere((c) => c.$1 == it.$2).$2,
            unit: 'pcs',
            reorderLevel: 4,
            parLevel: 20,
            costPerUnit: 0,
            icon: it.$6,
            active: true,
          ),
      ];

  static List<Recipe> buildRecipes(int now) => [
        for (final it in items)
          Recipe(
            id: it.$1,
            updatedAt: now,
            deleted: false,
            productId: it.$1,
            sizeCode: '',
            itemsJson: jsonEncode([RecipeItem(stockItemId: stockId(it.$1), qty: 1).toJson()]),
          ),
      ];

  /// Writes the menu through the outbox (new stores).
  static Future<void> seed(AppDatabase db) async {
    final now = nowMs();
    await db.saveAllSynced(db.categories, buildCategories(now));
    await db.saveAllSynced(db.products, buildProducts(now));
    await db.saveAllSynced(db.stockItems, buildStockItems(now));
    await db.saveAllSynced(db.recipes, buildRecipes(now));
  }
}
