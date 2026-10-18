import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/theme/icons.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/db/database.dart';
import '../../../core/models/settings_models.dart';
import '../../../core/services/repos.dart';
import '../../../shared/common.dart';
import 'menu_widgets.dart';

/// Ordered category list with move up/down, product counts and an editor.
class CategoriesSection extends ConsumerWidget {
  const CategoriesSection({super.key});

  Future<void> _edit(BuildContext context, WidgetRef ref, MenuCategory? c) async {
    if (!ref.read(canProvider(Perm.manageMenu))) return;
    final msg = await showAdaptive<String>(context, maxWidth: 560, builder: (_) => CategoryDialog(category: c));
    if (msg != null && context.mounted) toast(context, msg);
  }

  Future<void> _move(BuildContext context, WidgetRef ref, List<MenuCategory> cats, int i, int dir) async {
    final j = i + dir;
    if (j < 0 || j >= cats.length) return;
    final list = [...cats];
    final tmp = list[i];
    list[i] = list[j];
    list[j] = tmp;
    final menu = ref.read(servicesProvider).menu;
    await guardedWrite(context, () async {
      for (final (k, c) in list.indexed) {
        if (c.sortOrder != k) await menu.saveCategory(c.copyWith(sortOrder: k));
      }
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ec = context.ec;
    final canEdit = ref.watch(canProvider(Perm.manageMenu));
    final catsAsync = ref.watch(categoriesProvider);
    final products = ref.watch(productsProvider).value ?? const <Product>[];

    if (catsAsync.hasError && !catsAsync.hasValue) {
      return EmptyState(icon: Icons.error_outline_rounded, title: 'Couldn’t load categories', message: '${catsAsync.error}');
    }
    if (!catsAsync.hasValue) return const PaneLoading();
    final cats = catsAsync.value!;

    final addBtn = FilledButton.icon(
      onPressed: canEdit ? () => _edit(context, ref, null) : null,
      icon: const Icon(Icons.add_rounded),
      label: const Text('Add category'),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          'Categories',
          subtitle: 'This order is used for the tabs on the Sell screen.',
          trailing: cats.isEmpty ? null : addBtn,
        ),
        if (cats.isEmpty)
          AppCard(
            child: EmptyState(
              icon: Icons.category_outlined,
              title: 'No categories yet',
              message: 'Group the menu into categories such as Hot coffee, Iced drinks, Tea and Bakery.',
              action: canEdit ? addBtn : null,
            ),
          )
        else
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              for (final (i, c) in cats.indexed) ...[
                if (i > 0) const RowDivider(indent: 68),
                Builder(builder: (context) {
                  final inCat = products.where((p) => p.categoryId == c.id);
                  final active = inCat.where((p) => p.active).length;
                  final hidden = inCat.length - active;
                  return InkWell(
                    onTap: canEdit ? () => _edit(context, ref, c) : null,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(Sp.lg, Sp.md, Sp.sm, Sp.md),
                      child: Row(children: [
                        Opacity(opacity: c.active ? 1 : 0.5, child: IconBadge(icon: iconFor(c.icon), color: Color(c.color), size: 40)),
                        const SizedBox(width: Sp.md),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(c.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.tt.titleSmall?.copyWith(color: c.active ? null : ec.textMuted)),
                            const SizedBox(height: 2),
                            Text(
                              [
                                inCat.isEmpty ? 'No products' : '$active product${active == 1 ? '' : 's'}',
                                if (hidden > 0) '$hidden hidden',
                              ].join(' · '),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.tt.bodySmall,
                            ),
                            if (!c.active)
                              const Padding(
                                padding: EdgeInsets.only(top: 5),
                                child: Pill('Hidden from Sell', dense: true, icon: Icons.visibility_off_outlined),
                              ),
                          ]),
                        ),
                        if (canEdit) ...[
                          IconButton(
                            tooltip: 'Move up',
                            onPressed: i == 0 ? null : () => _move(context, ref, cats, i, -1),
                            icon: const Icon(Icons.arrow_upward_rounded),
                          ),
                          IconButton(
                            tooltip: 'Move down',
                            onPressed: i == cats.length - 1 ? null : () => _move(context, ref, cats, i, 1),
                            icon: const Icon(Icons.arrow_downward_rounded),
                          ),
                        ],
                      ]),
                    ),
                  );
                }),
              ],
            ]),
          ),
      ],
    );
  }
}

/// Add / edit a category. Pops with a message for the caller to toast.
class CategoryDialog extends ConsumerStatefulWidget {
  const CategoryDialog({super.key, this.category});
  final MenuCategory? category;

  @override
  ConsumerState<CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends ConsumerState<CategoryDialog> {
  MenuCategory? get _c => widget.category;
  bool get _isNew => _c == null;

  late final _name = TextEditingController(text: _c?.name ?? '');
  late String _icon = _c?.icon ?? 'coffee';
  late int _color = _c?.color ?? swatches.first;
  late bool _active = _c?.active ?? true;
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _fail(String m) => setState(() {
        _error = m;
        _saving = false;
      });

  Future<void> _save() async {
    if (_saving) return;
    final name = _name.text.trim();
    if (name.isEmpty) return _fail('Give the category a name.');
    final cats = ref.read(categoriesProvider).value ?? const <MenuCategory>[];
    if (cats.any((c) => c.id != _c?.id && c.name.trim().toLowerCase() == name.toLowerCase())) {
      return _fail('There’s already a category called “$name”.');
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final menu = ref.read(servicesProvider).menu;
    try {
      if (_isNew) {
        final sort = cats.isEmpty ? 0 : cats.map((c) => c.sortOrder).reduce((a, b) => a > b ? a : b) + 1;
        await menu.saveCategory(MenuCategory(
          id: newId(),
          updatedAt: nowMs(),
          deleted: false,
          name: name,
          icon: _icon,
          color: _color,
          sortOrder: sort,
          active: _active,
        ));
      } else {
        await menu.saveCategory(_c!.copyWith(name: name, icon: _icon, color: _color, active: _active));
      }
      if (mounted) Navigator.pop(context, _isNew ? 'Category $name added' : '$name saved');
    } catch (e) {
      _fail('Couldn’t save: $e');
    }
  }

  Future<void> _delete() async {
    final c = _c!;
    final inCat = (ref.read(productsProvider).value ?? const <Product>[]).where((p) => p.categoryId == c.id).toList();
    final active = inCat.where((p) => p.active).length;
    if (active > 0) {
      return _fail('${c.name} still has $active active product${active == 1 ? '' : 's'}. '
          'Move them to another category or delete them first — or just switch the category off to hide it.');
    }
    final hidden = inCat.length;
    final ok = await confirm(
      context,
      title: 'Delete ${c.name}?',
      message: hidden == 0
          ? 'The category will be removed from every till.'
          : 'It still holds $hidden hidden product${hidden == 1 ? '' : 's'}. They’ll stay hidden and show as “No category” until you move them.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (!ok || !mounted) return;
    try {
      await ref.read(servicesProvider).menu.deleteCategory(c);
      if (mounted) Navigator.pop(context, '${c.name} deleted');
    } catch (e) {
      _fail('Couldn’t delete: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final count = _c == null ? 0 : (ref.watch(productsProvider).value ?? const <Product>[]).where((p) => p.categoryId == _c!.id).length;
    return SaveShortcut(
      onSave: _save,
      child: DialogFrame(
        title: _isNew ? 'New category' : 'Edit category',
        subtitle: _isNew ? null : '$count product${count == 1 ? '' : 's'}',
        icon: Icons.category_outlined,
        actions: [
          if (!_isNew) DangerTextButton(label: 'Delete', onPressed: _saving ? null : _delete),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(onPressed: _saving ? null : _save, child: Text(_saving ? 'Saving…' : (_isNew ? 'Add category' : 'Save'))),
        ],
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            IconBadge(icon: iconFor(_icon), color: Color(_color), size: 52),
            const SizedBox(width: Sp.lg),
            Expanded(
              child: TextField(
                controller: _name,
                autofocus: _isNew,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Name', hintText: 'e.g. Hot coffee'),
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _save(),
              ),
            ),
          ]),
          const SizedBox(height: Sp.xl),
          const FieldLabel('Icon'),
          IconPickerGrid(selected: _icon, color: _color, onChanged: (k) => setState(() => _icon = k)),
          const SizedBox(height: Sp.lg),
          const FieldLabel('Colour', hint: 'New products in this category start with this icon and colour.'),
          SwatchPicker(selected: _color, onChanged: (c) => setState(() => _color = c)),
          const SizedBox(height: Sp.lg),
          LabeledSwitch(
            title: 'Active',
            subtitle: 'Inactive categories (and their products) are hidden from the Sell screen.',
            value: _active,
            onChanged: (v) => setState(() => _active = v),
          ),
          if (_error != null) ...[const SizedBox(height: Sp.md), InlineNote(_error!)],
        ]),
      ),
    );
  }
}
