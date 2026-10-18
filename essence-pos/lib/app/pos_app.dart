import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'providers.dart';
import 'router.dart';
import 'theme/theme.dart';

/// The POS once the terminal is set up.
class PosApp extends ConsumerStatefulWidget {
  const PosApp({super.key});
  @override
  ConsumerState<PosApp> createState() => _PosAppState();
}

class _PosAppState extends ConsumerState<PosApp> {
  final _refresh = ValueNotifier(0);
  late final GoRouter _router = buildRouter(isSignedIn: () => ref.read(sessionProvider) != null, refresh: _refresh);

  @override
  void dispose() {
    _refresh.dispose();
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(sessionProvider, (prev, next) {
      // The cart survives locking, so an order in progress isn't lost when the till auto-locks.
      if (prev?.id != next?.id) _refresh.value++;
    });
    final mode = ref.watch(themeModeProvider).value ?? ThemeMode.system;
    return MaterialApp.router(
      title: 'Essence POS',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      themeMode: mode,
      routerConfig: _router,
    );
  }
}
