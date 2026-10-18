import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../app/theme/tokens.dart';
import '../shared/common.dart';
import 'dashboard_app.dart';

/// Email / password sign-in with the store account (the same one the tills use).
class DashboardSignIn extends StatefulWidget {
  const DashboardSignIn({super.key});
  @override
  State<DashboardSignIn> createState() => _DashboardSignInState();
}

class _DashboardSignInState extends State<DashboardSignIn> {
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
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() => _error = switch (e.code) {
              'invalid-credential' || 'wrong-password' || 'user-not-found' || 'invalid-login-credentials' => 'Email or password is incorrect.',
              'invalid-email' => 'That email address doesn’t look right.',
              'user-disabled' => 'This account has been disabled.',
              'network-request-failed' => 'No internet connection.',
              'too-many-requests' => 'Too many attempts. Wait a minute and try again.',
              _ => e.message ?? e.code,
            });
      }
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _reset() async {
    final email = _email.text.trim();
    if (!email.contains('@')) {
      setState(() => _error = 'Enter the store email first, then tap “Forgot password”.');
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (mounted) toast(context, 'Password reset email sent to $email', icon: Icons.mark_email_read_outlined);
    } catch (e) {
      if (mounted) toast(context, 'Couldn’t send the reset email: $e', error: true);
    }
  }

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
        Text('Essence Dashboard', style: context.tt.displaySmall, textAlign: wide ? TextAlign.start : TextAlign.center),
        const SizedBox(height: Sp.sm),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Text(
            'Live sales, cash, stock and terminals from every till — on your phone or desktop.',
            textAlign: wide ? TextAlign.start : TextAlign.center,
            style: context.tt.bodyLarge?.copyWith(color: ec.textMuted),
          ),
        ),
      ],
    );

    final card = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 440),
      child: AppCard(
        padding: const EdgeInsets.all(Sp.xl),
        child: Form(
          key: _form,
          child: AutofillGroup(
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
              Text('Sign in', style: context.tt.headlineSmall),
              const SizedBox(height: 4),
              Text('Use the Essence store account — the same one the tills sign in with.', style: context.tt.bodyMedium?.copyWith(color: ec.textMuted)),
              const SizedBox(height: Sp.xl),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                textInputAction: TextInputAction.next,
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
                validator: (v) => (v == null || v.isEmpty) ? 'Enter the password' : null,
              ),
              if (_error != null) ...[
                const SizedBox(height: Sp.md),
                Container(
                  padding: const EdgeInsets.all(Sp.md),
                  decoration: BoxDecoration(color: ec.dangerContainer, borderRadius: BorderRadius.circular(Rad.md)),
                  child: Row(children: [
                    Icon(Icons.error_outline_rounded, color: ec.danger, size: 20),
                    const SizedBox(width: Sp.sm),
                    Expanded(child: Text(_error!, style: context.tt.bodyMedium?.copyWith(color: ec.text))),
                  ]),
                ),
              ],
              const SizedBox(height: Sp.xl),
              FilledButton(
                onPressed: _busy ? null : _submit,
                child: _busy
                    ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.4, color: ec.onPrimary))
                    : const Text('Sign in'),
              ),
              const SizedBox(height: Sp.sm),
              TextButton(onPressed: _busy ? null : _reset, child: const Text('Forgot password?')),
            ]),
          ),
        ),
      ),
    );

    return Scaffold(
      body: SafeArea(
        child: Stack(children: [
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(context.isPhone ? Sp.lg : Sp.xl),
              child: wide
                  ? Row(mainAxisSize: MainAxisSize.min, children: [brand, const SizedBox(width: 96), card])
                  : Column(children: [const SizedBox(height: Sp.xl), brand, const SizedBox(height: Sp.xl), card]),
            ),
          ),
          Positioned(
            top: Sp.sm,
            right: Sp.sm,
            child: IconButton(
              tooltip: context.isDark ? 'Light theme' : 'Dark theme',
              onPressed: () => toggleDashboardTheme(context),
              icon: Icon(context.isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
            ),
          ),
        ]),
      ),
    );
  }
}
