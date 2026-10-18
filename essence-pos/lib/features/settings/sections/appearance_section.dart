import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/theme/tokens.dart';
import '../settings_widgets.dart';

class AppearanceSection extends ConsumerWidget {
  const AppearanceSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider).value ?? ThemeMode.system;
    final density = ref.watch(gridDensityProvider).value ?? 'comfortable';
    final db = ref.read(dbProvider);
    return SettingsScaffold(
      title: 'Appearance',
      subtitle: 'How the app looks on this device. Other terminals keep their own choice.',
      children: [
        SettingsCard(
          title: 'Theme',
          subtitle: 'System follows this device’s light / dark setting.',
          icon: Icons.contrast_rounded,
          children: [
            Segments<ThemeMode>(
              values: const [ThemeMode.light, ThemeMode.dark, ThemeMode.system],
              selected: mode,
              minWidth: 320,
              icon: (m) => switch (m) {
                ThemeMode.light => Icons.light_mode_outlined,
                ThemeMode.dark => Icons.dark_mode_outlined,
                ThemeMode.system => Icons.brightness_auto_outlined,
              },
              label: (m) => switch (m) { ThemeMode.light => 'Light', ThemeMode.dark => 'Dark', ThemeMode.system => 'System' },
              onChanged: (m) => db.setMeta('ui.theme', switch (m) { ThemeMode.light => 'light', ThemeMode.dark => 'dark', ThemeMode.system => 'system' }),
            ),
          ],
        ),
        SettingsCard(
          title: 'Product grid',
          subtitle: 'Size of the product tiles on the Sell screen.',
          icon: Icons.grid_view_rounded,
          children: [
            Segments<String>(
              values: const ['comfortable', 'compact'],
              selected: density,
              minWidth: 300,
              icon: (d) => d == 'compact' ? Icons.apps_rounded : Icons.grid_view_rounded,
              label: (d) => d == 'compact' ? 'Compact' : 'Comfortable',
              onChanged: (d) => db.setMeta('ui.density', d),
            ),
            const SizedBox(height: Sp.sm),
            Text(
              density == 'compact' ? 'Smaller tiles fit more products on screen — good for large menus.' : 'Larger tiles that are easy to tap on a touch screen.',
              style: context.tt.bodySmall,
            ),
          ],
        ),
      ],
    );
  }
}
