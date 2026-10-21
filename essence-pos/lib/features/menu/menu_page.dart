import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme/tokens.dart';
import '../../core/models/settings_models.dart';
import '../../shared/common.dart';
import '../settings/menu/menu_settings.dart';

/// Admin panel › Menu: add, edit, hide and delete products, categories and options.
class MenuPage extends ConsumerWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pad = context.isPhone ? Sp.lg : Sp.xl;
    if (!ref.watch(canProvider(Perm.manageMenu))) {
      return const EmptyState(icon: Icons.lock_outline_rounded, title: 'Menu is locked', message: 'Your role can’t edit the menu. Ask the owner.');
    }
    return ListView(
      padding: EdgeInsets.all(pad),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: const Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              PageTitle('Menu', subtitle: 'Changes appear on every till straight away'),
              MenuSettingsPane(),
            ]),
          ),
        ),
      ],
    );
  }
}
