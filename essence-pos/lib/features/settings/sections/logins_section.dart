import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/sync/firestore_remote.dart';
import '../../../shared/common.dart';
import '../settings_widgets.dart';

/// Store logins (Firebase accounts) that can open the tills and the owner dashboard.
/// Only admin logins can add or remove them; there is no public sign-up.
class LoginsSection extends ConsumerWidget {
  const LoginsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ec = context.ec;
    final svc = ref.watch(servicesProvider);
    final access = ref.watch(storeAccessProvider);
    final me = ref.watch(authUidProvider);
    final admin = ref.watch(isStoreAdminProvider);
    final online = ref.watch(syncStatusProvider).value?.online ?? false;

    return SettingsScaffold(
      title: 'Store logins',
      subtitle: 'Email logins for each till and the owner dashboard. Staff still use their PIN on the till.',
      actions: [
        if (admin)
          FilledButton.icon(
            onPressed: online && svc.firestore != null ? () => _addLogin(context, ref) : null,
            icon: const Icon(Icons.person_add_alt_rounded),
            label: const Text('Add login'),
          ),
      ],
      children: [
        if (svc.firestore == null)
          const InfoBanner('Store logins are managed online through Firebase.')
        else if (!online)
          const InfoBanner('You’re offline. Logins can be managed when this till is back online.', tone: Tone.warning, icon: Icons.cloud_off_rounded)
        else if (!admin)
          const InfoBanner('Only admin logins can add or remove store logins. Ask an admin.', icon: Icons.lock_outline_rounded),
        SettingsCard(
          title: 'Logins',
          icon: Icons.key_rounded,
          children: [
            switch (access) {
              AsyncData(:final value) when value.accounts.isNotEmpty => Column(children: [
                  for (final a in value.accounts)
                    _LoginTile(
                      account: a,
                      isMe: a.uid == me,
                      canManage: admin && online,
                      lastAdmin: a.admin && value.adminUids.length <= 1,
                    ),
                ]),
              AsyncError() => Text('Couldn’t load logins. Check the connection.', style: context.tt.bodyMedium?.copyWith(color: ec.danger)),
              AsyncLoading() => const Padding(padding: EdgeInsets.all(Sp.lg), child: Center(child: CircularProgressIndicator())),
              _ => Text('No logins found.', style: context.tt.bodyMedium?.copyWith(color: ec.textMuted)),
            },
          ],
        ),
        const InfoBanner(
          'Admin logins can add and remove logins. Till logins can run the POS and open the owner dashboard. '
          'What each person can do on the till (refunds, reports, settings) is set by their staff role in Staff & roles.',
        ),
      ],
    );
  }

  Future<void> _addLogin(BuildContext context, WidgetRef ref) async {
    final created = await showAdaptive<bool>(context, maxWidth: 480, builder: (_) => const _AddLoginDialog());
    if (created == true && context.mounted) toast(context, 'Login added — share the email and password with its user');
  }
}

class _LoginTile extends ConsumerWidget {
  const _LoginTile({required this.account, required this.isMe, required this.canManage, required this.lastAdmin});
  final StoreAccount account;
  final bool isMe;
  final bool canManage;
  final bool lastAdmin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ec = context.ec;
    final svc = ref.watch(servicesProvider);
    final fs = svc.firestore!;
    Future<void> run(Future<void> Function() f, String done) async {
      try {
        await f();
        if (context.mounted) toast(context, done);
      } catch (e) {
        if (context.mounted) toast(context, '$e', error: true);
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Sp.xs),
      child: Row(children: [
        CircleAvatar(
          backgroundColor: account.admin ? ec.primaryContainer : ec.beige,
          child: Icon(account.admin ? Icons.admin_panel_settings_outlined : Icons.point_of_sale_outlined,
              color: account.admin ? ec.onPrimaryContainer : ec.accent, size: 20),
        ),
        const SizedBox(width: Sp.md),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(account.email, style: context.tt.titleSmall, overflow: TextOverflow.ellipsis),
            Wrap(spacing: Sp.xs, runSpacing: Sp.xs, crossAxisAlignment: WrapCrossAlignment.center, children: [
              if (account.name.isNotEmpty) Text(account.name, style: context.tt.bodySmall),
              Pill(account.admin ? 'Admin' : 'Till', tone: account.admin ? Tone.primary : Tone.neutral, dense: true),
              if (isMe) const Pill('This till', tone: Tone.info, dense: true),
            ]),
          ]),
        ),
        if (canManage)
          PopupMenuButton<String>(
            tooltip: 'Login options',
            onSelected: (v) async {
              switch (v) {
                case 'reset':
                  await run(() => svc.accounts.sendPasswordReset(account.email), 'Password reset email sent to ${account.email}');
                case 'admin':
                  await run(() => fs.setAdmin(account.uid, true), '${account.email} is now an admin');
                case 'till':
                  await run(() => fs.setAdmin(account.uid, false), '${account.email} is now a till login');
                case 'remove':
                  if (await confirm(context,
                      title: 'Remove ${account.email}?',
                      message: 'Tills and dashboards signed in with this login lose access straight away.',
                      confirmLabel: 'Remove',
                      destructive: true)) {
                    await run(() => fs.removeAccount(account.uid), 'Access removed');
                  }
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'reset', child: ListTile(leading: Icon(Icons.mark_email_read_outlined), title: Text('Send password reset email'))),
              if (!account.admin)
                const PopupMenuItem(value: 'admin', child: ListTile(leading: Icon(Icons.admin_panel_settings_outlined), title: Text('Make admin'))),
              if (account.admin && !isMe && !lastAdmin)
                const PopupMenuItem(value: 'till', child: ListTile(leading: Icon(Icons.point_of_sale_outlined), title: Text('Make till login'))),
              if (!isMe && !lastAdmin)
                const PopupMenuItem(value: 'remove', child: ListTile(leading: Icon(Icons.person_remove_outlined), title: Text('Remove access'))),
            ],
          ),
      ]),
    );
  }
}

class _AddLoginDialog extends ConsumerStatefulWidget {
  const _AddLoginDialog();
  @override
  ConsumerState<_AddLoginDialog> createState() => _AddLoginDialogState();
}

class _AddLoginDialogState extends ConsumerState<_AddLoginDialog> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _admin = false;
  bool _busy = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final svc = ref.read(servicesProvider);
    try {
      final uid = await svc.accounts.createLogin(email: _email.text, password: _password.text);
      await svc.firestore!.addAccount(uid: uid, email: _email.text.trim(), name: _name.text.trim(), admin: _admin);
      if (mounted) Navigator.pop(context, true);
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
    return DialogFrame(
      title: 'Add login',
      subtitle: 'For a new till or the owner’s dashboard',
      icon: Icons.person_add_alt_rounded,
      actions: [
        TextButton(onPressed: _busy ? null : () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: _busy ? null : _create,
          child: _busy ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Create login'),
        ),
      ],
      child: Form(
        key: _form,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          TextFormField(
            controller: _name,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Label', hintText: 'e.g. Counter 2, Owner phone'),
          ),
          fieldGap,
          TextFormField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.mail_outline_rounded)),
            validator: (v) => (v == null || !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim())) ? 'Enter a valid email' : null,
          ),
          fieldGap,
          TextFormField(
            controller: _password,
            obscureText: _obscure,
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
          fieldGap,
          LabeledSwitch(
            title: 'Admin',
            subtitle: 'Admins can add and remove store logins',
            value: _admin,
            onChanged: (v) => setState(() => _admin = v),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: Sp.sm),
              child: Text(_error!, style: context.tt.bodySmall?.copyWith(color: context.ec.danger, fontWeight: FontWeight.w600)),
            ),
        ]),
      ),
    );
  }
}
