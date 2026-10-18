import 'package:flutter/material.dart';

/// Icon keys stored in the database (products, categories, stock, payments) → icons.
const appIcons = <String, IconData>{
  // Menu
  'coffee': Icons.coffee_rounded,
  'latte': Icons.local_cafe_rounded,
  'espresso': Icons.coffee_maker_rounded,
  'iced': Icons.local_drink_rounded,
  'frappe': Icons.blender_rounded,
  'tea': Icons.emoji_food_beverage_rounded,
  'matcha': Icons.eco_rounded,
  'chocolate': Icons.local_cafe_outlined,
  'juice': Icons.local_bar_rounded,
  'water': Icons.water_drop_rounded,
  'croissant': Icons.bakery_dining_rounded,
  'bakery': Icons.breakfast_dining_rounded,
  'cookie': Icons.cookie_rounded,
  'cupcake': Icons.cake_outlined,
  'cake': Icons.cake_rounded,
  'sandwich': Icons.lunch_dining_rounded,
  'quiche': Icons.egg_alt_rounded,
  'toast': Icons.breakfast_dining_outlined,
  'icecream': Icons.icecream_rounded,
  'food': Icons.restaurant_rounded,
  // Inventory
  'beans': Icons.grain_rounded,
  'milk': Icons.local_drink_outlined,
  'cheese': Icons.egg_rounded,
  'syrup': Icons.liquor_rounded,
  'flour': Icons.grain_outlined,
  'sugar': Icons.blur_on_rounded,
  'egg': Icons.egg_outlined,
  'chicken': Icons.set_meal_rounded,
  'bread': Icons.breakfast_dining_rounded,
  'avocado': Icons.spa_rounded,
  'lemon': Icons.brightness_5_rounded,
  'cup': Icons.local_cafe_outlined,
  'box': Icons.inventory_2_rounded,
  'inventory': Icons.inventory_2_outlined,
  // Payments
  'cash': Icons.payments_rounded,
  'card': Icons.credit_card_rounded,
  'wallet': Icons.account_balance_wallet_rounded,
  'bank': Icons.account_balance_rounded,
  'qr': Icons.qr_code_rounded,
  'payments': Icons.point_of_sale_rounded,
};

IconData iconFor(String? key, {IconData fallback = Icons.local_cafe_rounded}) => appIcons[key] ?? fallback;

const menuIconKeys = [
  'coffee', 'latte', 'espresso', 'iced', 'frappe', 'tea', 'matcha', 'chocolate', 'juice', 'water', //
  'croissant', 'bakery', 'cookie', 'cupcake', 'cake', 'sandwich', 'quiche', 'toast', 'icecream', 'food',
];

const stockIconKeys = [
  'beans', 'tea', 'matcha', 'chocolate', 'milk', 'cheese', 'syrup', 'flour', 'sugar', 'egg', //
  'chicken', 'bread', 'avocado', 'lemon', 'cup', 'box', 'water', 'croissant', 'inventory',
];

const paymentIconKeys = ['cash', 'card', 'wallet', 'bank', 'qr', 'payments'];

/// Swatches offered when picking a product/category colour (they read well in both themes).
const swatches = <int>[
  0xFF8A5A36, 0xFFB08A5E, 0xFFC08552, 0xFF6B4226, 0xFF3E3A36, 0xFF4E5726, 0xFF7A9A3A, 0xFF7A8C4A, //
  0xFF5B7A8C, 0xFF5A5A8C, 0xFF9C4A5A, 0xFFC77B8B, 0xFFB7791F, 0xFFC9954C, 0xFFA0703E, 0xFF6B5B3E,
];
