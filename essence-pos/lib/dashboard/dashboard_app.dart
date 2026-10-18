import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../app/theme/theme.dart';
import '../app/theme/tokens.dart';
import '../firebase_options.dart';
import '../shared/common.dart';
import 'dashboard_page.dart';
import 'dashboard_sign_in.dart';
import 'live_store.dart';

/// Light / dark / system for the dashboard (toggled from the header and the sign-in page).
final dashboardThemeMode = ValueNotifier<ThemeMode>(ThemeMode.system);

/// Flips between light and dark, starting from what is currently on screen.
void toggleDashboardTheme(BuildContext context) =>
    dashboardThemeMode.value = context.isDark ? ThemeMode.light : ThemeMode.dark;

/// The owner's live dashboard (web build). Reads Firestore directly; no local database.
class DashboardApp extends StatelessWidget {
  const DashboardApp({super.key});

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<ThemeMode>(
        valueListenable: dashboardThemeMode,
        builder: (context, mode, _) => MaterialApp(
          title: 'Essence Dashboard',
          debugShowCheckedModeBanner: false,
          theme: buildTheme(Brightness.light),
          darkTheme: buildTheme(Brightness.dark),
          themeMode: mode,
          home: const _Startup(),
        ),
      );
}

class _Startup extends StatefulWidget {
  const _Startup();
  @override
  State<_Startup> createState() => _StartupState();
}

class _StartupState extends State<_Startup> {
  late Future<FirebaseApp> _init = _start();

  Future<FirebaseApp> _start() => Firebase.apps.isNotEmpty
      ? Future.value(Firebase.app())
      : Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  @override
  Widget build(BuildContext context) => FutureBuilder<FirebaseApp>(
        future: _init,
        builder: (context, snap) {
          if (snap.hasError) {
            return Scaffold(
              body: EmptyState(
                icon: Icons.cloud_off_rounded,
                title: 'The dashboard couldn’t start',
                message: '${snap.error}',
                action: FilledButton(onPressed: () => setState(() => _init = _start()), child: const Text('Try again')),
              ),
            );
          }
          if (!snap.hasData) return const DashboardSplash();
          return const _AuthGate();
        },
      );
}

class DashboardSplash extends StatelessWidget {
  const DashboardSplash({super.key, this.message});
  final String? message;
  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const EssenceLogo(size: 110),
            const SizedBox(height: Sp.xl),
            SizedBox(width: 160, child: LinearProgressIndicator(borderRadius: BorderRadius.circular(99))),
            if (message != null) ...[
              const SizedBox(height: Sp.md),
              Text(message!, style: context.tt.bodyMedium?.copyWith(color: context.ec.textMuted)),
            ],
          ]),
        ),
      );
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();
  @override
  Widget build(BuildContext context) => StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) return const DashboardSplash();
          final user = snap.data;
          if (user == null) return const DashboardSignIn();
          return _MembershipGate(key: ValueKey(user.uid), user: user);
        },
      );
}

enum _Access { checking, ok, denied, missing, error }

/// Confirms the signed-in account belongs to the Essence store before showing data.
class _MembershipGate extends StatefulWidget {
  const _MembershipGate({super.key, required this.user});
  final User user;
  @override
  State<_MembershipGate> createState() => _MembershipGateState();
}

class _MembershipGateState extends State<_MembershipGate> {
  _Access _access = _Access.checking;
  String? _error;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    setState(() {
      _access = _Access.checking;
      _error = null;
    });
    try {
      final snap = await FirebaseFirestore.instance.collection('stores').doc(dashboardStoreId).get();
      final members = snap.data()?['memberUids'];
      final a = !snap.exists
          ? _Access.missing
          : (members is List && members.isNotEmpty && !members.contains(widget.user.uid))
              ? _Access.denied
              : _Access.ok;
      if (mounted) setState(() => _access = a);
    } on FirebaseException catch (e) {
      if (!mounted) return;
      setState(() {
        _access = e.code == 'permission-denied' ? _Access.denied : _Access.error;
        _error = e.message ?? e.code;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _access = _Access.error;
          _error = '$e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget blocked({required IconData icon, required String title, required String message, bool retry = false}) => Scaffold(
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(Sp.xl),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: AppCard(
                    padding: const EdgeInsets.all(Sp.xl),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      const EssenceLogo(size: 72),
                      EmptyState(icon: icon, title: title, message: message),
                      Text(widget.user.email ?? '', style: context.tt.bodySmall),
                      const SizedBox(height: Sp.lg),
                      Wrap(spacing: Sp.sm, runSpacing: Sp.sm, alignment: WrapAlignment.center, children: [
                        if (retry) OutlinedButton.icon(onPressed: _check, icon: const Icon(Icons.refresh_rounded), label: const Text('Try again')),
                        FilledButton.icon(
                          onPressed: () => FirebaseAuth.instance.signOut(),
                          icon: const Icon(Icons.logout_rounded),
                          label: const Text('Sign out'),
                        ),
                      ]),
                    ]),
                  ),
                ),
              ),
            ),
          ),
        );

    return switch (_access) {
      _Access.checking => const DashboardSplash(message: 'Checking store access…'),
      _Access.ok => DashboardPage(user: widget.user),
      _Access.denied => blocked(
          icon: Icons.lock_outline_rounded,
          title: 'No access',
          message: 'This account doesn’t have access to the Essence store. Sign in with the store account the tills use.',
        ),
      _Access.missing => blocked(
          icon: Icons.storefront_outlined,
          title: 'Store not set up yet',
          message: 'Set up the first till with this account, then come back to see live sales here.',
          retry: true,
        ),
      _Access.error => blocked(
          icon: Icons.cloud_off_rounded,
          title: 'Couldn’t reach the store',
          message: _error ?? 'Check the internet connection and try again.',
          retry: true,
        ),
    };
  }
}
