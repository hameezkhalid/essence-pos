import 'package:flutter/material.dart';

import '../app/theme/icons.dart';
import '../core/db/database.dart';
import 'common.dart';

/// A product's photo when it has one, otherwise its icon badge.
class ProductThumb extends StatelessWidget {
  const ProductThumb({super.key, required this.product, this.size = 40});
  final Product product;
  final double size;

  @override
  Widget build(BuildContext context) {
    final photo = productPhoto(product.id);
    if (photo == null) return IconBadge(icon: iconFor(product.icon), color: Color(product.color), size: size);
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.3),
      child: Image.asset(photo, width: size, height: size, fit: BoxFit.cover),
    );
  }
}
