import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/models/settings_models.dart';
import 'categories_section.dart';
import 'menu_widgets.dart';
import 'modifiers_section.dart';
import 'products_section.dart';

enum _MenuTab { products, categories, modifiers }

/// Settings › Menu: categories, products, sizes, modifier groups, availability.
///
/// Embedded in the scrollable Settings page, so it sizes itself (no Scaffold, no own scrolling).
class MenuSettingsPane extends ConsumerStatefulWidget {
  const MenuSettingsPane({super.key});

  @override
  ConsumerState<MenuSettingsPane> createState() => _MenuSettingsPaneState();
}

class _MenuSettingsPaneState extends ConsumerState<MenuSettingsPane> {
  _MenuTab _tab = _MenuTab.products;

  void _go(_MenuTab t) => setState(() => _tab = t);

  @override
  Widget build(BuildContext context) {
    final canEdit = ref.watch(canProvider(Perm.manageMenu));
    final products = ref.watch(productsProvider).value?.length;
    final cats = ref.watch(categoriesProvider).value?.length;
    final groups = ref.watch(modifierGroupsProvider).value?.length;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!canEdit) const ViewOnlyNote('You can view the menu, but changing it needs the “Edit menu & prices” permission.'),
        LayoutBuilder(builder: (context, c) {
          final narrow = c.maxWidth < 460;
          String label(String s, int? n) => narrow || n == null ? s : '$s · $n';
          return SizedBox(
            width: double.infinity,
            child: SegmentedButton<_MenuTab>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: _MenuTab.products,
                  icon: narrow ? null : const Icon(Icons.local_cafe_outlined, size: 18),
                  label: Text(label('Products', products), maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
                ButtonSegment(
                  value: _MenuTab.categories,
                  icon: narrow ? null : const Icon(Icons.category_outlined, size: 18),
                  label: Text(label('Categories', cats), maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
                ButtonSegment(
                  value: _MenuTab.modifiers,
                  icon: narrow ? null : const Icon(Icons.tune_rounded, size: 18),
                  label: Text(label('Modifiers', groups), maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              ],
              selected: {_tab},
              onSelectionChanged: (s) => _go(s.first),
            ),
          );
        }),
        const SizedBox(height: Sp.lg),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          layoutBuilder: (current, previous) => current ?? const SizedBox.shrink(),
          child: switch (_tab) {
            _MenuTab.products => ProductsSection(key: const ValueKey('products'), onOpenCategories: () => _go(_MenuTab.categories)),
            _MenuTab.categories => const CategoriesSection(key: ValueKey('categories')),
            _MenuTab.modifiers => const ModifiersSection(key: ValueKey('modifiers')),
          },
        ),
      ],
    );
  }
}
