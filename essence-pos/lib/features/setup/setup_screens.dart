import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../app/boot.dart';
import '../../app/platform.dart';
import '../../app/theme/tokens.dart';
import '../../core/sync/firestore_remote.dart';
import '../../shared/common.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const EssenceLogo(size: 120),
            const SizedBox(height: Sp.xl),
            SizedBox(width: 160, child: LinearProgressIndicator(borderRadius: BorderRadius.circular(99))),
          ]),
        ),
      );
}

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key, required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Scaffold(
        body: EmptyState(
          icon: Icons.error_outline_rounded,
          title: 'Essence POS couldn’t start',
          message: message,
          action: FilledButton(onPressed: onRetry, child: const Text('Try again')),
        ),
      );
}

/// Two-column layout used by the sign-in and setup screens.
class _SetupFrame extends StatelessWidget {
  const _SetupFrame({required this.title, required this.subtitle, required this.child});
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    final wide = context.screenW >= 900;
    final brand = Column(
      crossAxisAlignment: wide ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        EssenceLogo(size: wide ? 150 : 96),
        const SizedBox(height: Sp.xl),
        Text(adminPanel ? 'Essence Admin' : 'Essence POS', style: context.tt.displaySmall),
        const SizedBox(height: Sp.sm),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Text(
            adminPanel
                ? 'Live dashboard, menu, inventory and reports — plus the same POS as the tills.'
                : 'Offline-first point of sale with live sync, inventory and FBR invoicing.',
            textAlign: wide ? TextAlign.start : TextAlign.center,
            style: context.tt.bodyLarge?.copyWith(color: ec.textMuted),
          ),
        ),
      ],
    );
    final card = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 460),
      child: AppCard(
        padding: const EdgeInsets.all(Sp.xl),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
          Text(title, style: context.tt.headlineSmall),
          const SizedBox(height: 4),
          Text(subtitle, style: context.tt.bodyMedium?.copyWith(color: ec.textMuted)),
          const SizedBox(height: Sp.xl),
          child,
        ]),
      ),
    );
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(Sp.xl),
            child: wide
                ? Row(mainAxisSize: MainAxisSize.min, children: [brand, const SizedBox(width: 96), card])
                : Column(children: [brand, const SizedBox(height: Sp.xl), card]),
          ),
        ),
      ),
    );
  }
}

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key, required this.boot});
  final BootAppState boot;
  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: _email.text.trim(), password: _password.text);
      await widget.boot.onSignedIn();
    } on FirebaseAuthException catch (e) {
      setState(() => _error = switch (e.code) {
            'invalid-credential' || 'wrong-password' || 'user-not-found' => 'Email or password is incorrect.',
            'user-disabled' => 'This login has been disabled.',
            'invalid-email' => 'That email address doesn’t look right.',
            'network-request-failed' => 'No internet connection. The first sign-in needs the internet.',
            'too-many-requests' => 'Too many attempts. Wait a minute and try again.',
            'operation-not-allowed' => 'Email sign-in is not enabled for this Firebase project.',
            _ => e.message ?? e.code,
          });
    } catch (e) {
      setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _SetupFrame(
      title: 'Sign in to Essence',
      subtitle: 'Use the store login given to you by an admin. Staff sign in with their PIN afterwards.',
      child: Form(
        key: _form,
        child: AutofillGroup(
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              decoration: const InputDecoration(labelText: 'Store email', prefixIcon: Icon(Icons.mail_outline_rounded)),
              validator: (v) => (v == null || !v.contains('@')) ? 'Enter the store email' : null,
            ),
            const SizedBox(height: Sp.md),
            TextFormField(
              controller: _password,
              obscureText: _obscure,
              autofillHints: const [AutofillHints.password],
              onFieldSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  tooltip: _obscure ? 'Show password' : 'Hide password',
                  onPressed: () => setState(() => _obscure = !_obscure),
                  icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                ),
              ),
              validator: (v) => (v == null || v.length < 6) ? 'At least 6 characters' : null,
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: Sp.md),
                child: Text(_error!, style: context.tt.bodySmall?.copyWith(color: context.ec.danger, fontWeight: FontWeight.w600)),
              ),
            const SizedBox(height: Sp.xl),
            FilledButton(
              onPressed: _busy ? null : _submit,
              child: _busy
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.4))
                  : const Text('Sign in'),
            ),
            const SizedBox(height: Sp.md),
            Text(
              'No login yet? An Essence admin can create one in Settings › Store logins.',
              textAlign: TextAlign.center,
              style: context.tt.bodySmall,
            ),
          ]),
        ),
      ),
    );
  }
}

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key, required this.boot});
  final BootAppState boot;
  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  StoreClaim? _claim;
  String? _error;
  bool _checking = true;
  bool _busy = false;
  String _step = '';
  final _name = TextEditingController(text: adminPanel ? 'Admin panel' : 'Counter 1');
  final _code = TextEditingController(text: adminPanel ? 'WEB' : 'T1');
  final _owner = TextEditingController();
  final _pin = TextEditingController();

  @override
  void initState() {
    super.initState();
    _check();
  }

  @override
  void dispose() {
    _name.dispose();
    _code.dispose();
    _owner.dispose();
    _pin.dispose();
    super.dispose();
  }

  Future<void> _check() async {
    setState(() {
      _checking = true;
      _error = null;
    });
    try {
      final u = FirebaseAuth.instance.currentUser!;
      final c = await widget.boot.remote.claimOrJoin(u.uid, u.email ?? '').timeout(const Duration(seconds: 20));
      setState(() {
        _claim = c;
        if (c == StoreClaim.member && !adminPanel) {
          _name.text = 'Counter 2';
          _code.text = 'T2';
        }
      });
    } catch (e) {
      final s = '$e';
      setState(() => _error = s.contains('permission-denied')
          ? 'This login doesn’t have access to the Essence store. Ask an admin to add it in Settings › Store logins.'
          : s.contains('unavailable') || s.contains('Timeout')
              ? 'Can’t reach the server. The first setup needs the internet.'
              : s);
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  Future<void> _finish() async {
    if (_claim == StoreClaim.created) {
      if (_owner.text.trim().isEmpty || !RegExp(r'^\d{4}$').hasMatch(_pin.text)) {
        setState(() => _error = 'Enter the owner’s name and a 4-digit PIN');
        return;
      }
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      if (_claim == StoreClaim.created) {
        await widget.boot.setupNewStore(
          terminalName: _name.text,
          terminalCode: _code.text,
          ownerName: _owner.text.trim(),
          ownerPin: _pin.text,
          onStep: (s) => mounted ? setState(() => _step = s) : null,
        );
      } else {
        await widget.boot.setupJoin(
          terminalName: _name.text,
          terminalCode: _code.text,
          onStep: (s) => mounted ? setState(() => _step = s) : null,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = '$e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    if (_checking) {
      return const _SetupFrame(
        title: 'Connecting to your store…',
        subtitle: 'Checking the Essence store on the server.',
        child: LinearProgressIndicator(),
      );
    }
    if (_claim == null || _claim == StoreClaim.denied) {
      return _SetupFrame(
        title: 'Can’t open the store',
        subtitle: _error ?? 'This login isn’t on the Essence store yet. Ask an admin to add it in Settings › Store logins.',
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          FilledButton(onPressed: _check, child: const Text('Try again')),
          const SizedBox(height: Sp.sm),
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              widget.boot.setState(() => widget.boot.phase = BootPhase.signIn);
            },
            child: const Text('Use a different account'),
          ),
        ]),
      );
    }
    final isNew = _claim == StoreClaim.created;
    if (_busy) {
      return _SetupFrame(
        title: isNew ? 'Setting up Essence…' : 'Joining Essence…',
        subtitle: 'This only happens once on this computer.',
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const LinearProgressIndicator(),
          const SizedBox(height: Sp.md),
          Text(_step, style: context.tt.bodyMedium?.copyWith(color: ec.textMuted)),
        ]),
      );
    }
    return _SetupFrame(
      title: isNew ? 'Set up this till' : (adminPanel ? 'Open the admin panel' : 'Add this till to Essence'),
      subtitle: isNew
          ? 'You’re creating the Essence store. Name this terminal and choose how to start.'
          : (adminPanel
              ? 'This browser downloads the store’s menu, staff, settings and sales once, then stays in sync live.'
              : 'The store already exists. This terminal will download its menu, staff, settings and sales.'),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Expanded(flex: 3, child: TextField(controller: _name, decoration: const InputDecoration(labelText: 'Terminal name'))),
          const SizedBox(width: Sp.md),
          Expanded(
            flex: 2,
            child: TextField(
              controller: _code,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(labelText: 'Code', helperText: 'On invoices'),
            ),
          ),
        ]),
        if (isNew) ...[
          const SizedBox(height: Sp.lg),
          Text('The Essence dessert menu is added for you. Now add the owner, who unlocks the till with a PIN.',
              style: context.tt.bodySmall),
          ...[
            const SizedBox(height: Sp.md),
            TextField(controller: _owner, decoration: const InputDecoration(labelText: 'Owner name')),
            const SizedBox(height: Sp.md),
            TextField(
              controller: _pin,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Owner PIN (4 digits)', counterText: ''),
            ),
          ],
        ],
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: Sp.md),
            child: Text(_error!, style: context.tt.bodySmall?.copyWith(color: ec.danger, fontWeight: FontWeight.w600)),
          ),
        const SizedBox(height: Sp.xl),
        FilledButton.icon(
          onPressed: _finish,
          icon: const Icon(Icons.arrow_forward_rounded),
          label: Text(isNew ? 'Set up the store' : (adminPanel ? 'Continue' : 'Join and download')),
        ),
      ]),
    );
  }
}
