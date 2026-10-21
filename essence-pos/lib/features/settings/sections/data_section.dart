import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/boot_actions.dart';
import '../../../app/providers.dart';
import '../../../app/services.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/models/settings_models.dart';
import '../../../core/sync/sync_engine.dart';
import '../../../shared/common.dart';
import '../settings_widgets.dart';

class DataSection extends ConsumerStatefulWidget {
  const DataSection({super.key});
  @override
  ConsumerState<DataSection> createState() => _DataSectionState();
}

class _DataSectionState extends ConsumerState<DataSection> {
  bool _pumping = false;
  bool _signingOut = false;

  Future<void> _syncNow() async {
    setState(() => _pumping = true);
    try {
      await ref.read(servicesProvider).sync.pump();
      if (!mounted) return;
      final s = ref.read(servicesProvider).sync.status;
      toast(context, s.error != null ? s.error! : (s.pending == 0 ? 'Everything is synced' : '${s.pending} changes still waiting'), error: s.error != null);
    } finally {
      if (mounted) setState(() => _pumping = false);
    }
  }

  Future<void> _signOut() async {
    final ok = await confirm(
      context,
      title: 'Sign out of this terminal?',
      message: 'This device forgets the store account and its local data. Sales already uploaded stay safe in the cloud. '
          'You will need the store account email and password to set it up again.',
      confirmLabel: 'Sign out',
      destructive: true,
    );
    if (!ok || !mounted) return;
    final boot = ref.read(bootActionsProvider);
    setState(() => _signingOut = true);
    final err = await boot.signOut();
    if (!mounted) return;
    setState(() => _signingOut = false);
    if (err != null) {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Can’t sign out yet'),
          content: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 420), child: Text(err)),
          actions: [FilledButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
        ),
      );
    }
  }

  Future<void> _danger({
    required String title,
    required String message,
    required String doneMessage,
    required Future<String?> Function(BootActions boot, void Function(String) onStep) run,
  }) async {
    final svc = ref.read(servicesProvider);
    if (!svc.sync.status.online) {
      toast(context, 'Connect to the internet first — the cloud copy is changed too.', error: true, icon: Icons.cloud_off_rounded);
      return;
    }
    final first = await confirm(context, title: title, message: message, confirmLabel: 'Continue', destructive: true);
    if (!first || !mounted) return;
    final typed = await showAdaptive<bool>(context, maxWidth: 460, builder: (_) => _TypeToConfirm(title: title));
    if (typed != true || !mounted) return;

    final boot = ref.read(bootActionsProvider);
    final step = ValueNotifier<String>('Starting…');
    final nav = Navigator.of(context, rootNavigator: true);
    // Not awaited: closed below, or removed with the whole app when it restarts.
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (_) => PopScope(canPop: false, child: _ProgressDialog(title: title, step: step)),
    );
    String? err;
    try {
      err = await run(boot, (s) => step.value = s);
    } catch (e) {
      err = '$e';
    }
    // On success the app tree is rebuilt, so this screen is usually gone by now.
    if (!mounted) return;
    if (nav.canPop()) nav.pop();
    if (err != null) {
      toast(context, err, error: true);
    } else {
      toast(context, doneMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    final s = ref.watch(syncStatusProvider).value ?? const SyncStatus();
    final svc = ref.watch(servicesProvider);
    final boot = ref.watch(bootActionsProvider);
    final owner = ref.watch(roleProvider) == Role.owner;

    final (Tone tone, IconData icon, String label) = !s.online
        ? (Tone.danger, Icons.cloud_off_rounded, 'Offline — no internet')
        : s.error != null && s.pending > 0
            ? (Tone.warning, Icons.sync_problem_rounded, 'Sync issue')
            : s.pending > 0 || s.syncing
                ? (Tone.warning, Icons.cloud_upload_outlined, 'Syncing')
                : (Tone.success, Icons.cloud_done_rounded, 'Online · up to date');

    return SettingsScaffold(
      title: 'Data & sync',
      subtitle: 'Everything is saved on this device first and uploaded to the cloud when online.',
      children: [
        SettingsCard(
          title: 'Sync',
          icon: Icons.cloud_sync_outlined,
          trailing: Pill(label, tone: tone, icon: icon, dense: context.isPhone),
          children: [
            InfoRow('Waiting to upload', s.pending == 0 ? 'Nothing' : '${s.pending} change${s.pending == 1 ? '' : 's'}',
                valueColor: s.pending > 0 ? ec.warning : null),
            InfoRow('Last sync', s.lastSyncAt == null ? 'Not yet' : timeAgo(s.lastSyncAt!)),
            if (s.error != null) ...[
              const SizedBox(height: Sp.sm),
              InfoBanner(s.error!, title: 'Last error', tone: Tone.danger, icon: Icons.error_outline_rounded),
            ],
            const SizedBox(height: Sp.md),
            Wrap(spacing: Sp.sm, runSpacing: Sp.sm, children: [
              FilledButton.icon(
                onPressed: !s.online || _pumping ? null : _syncNow,
                icon: _pumping || s.syncing
                    ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: s.online && !_pumping ? ec.onPrimary : ec.textFaint))
                    : const Icon(Icons.sync_rounded, size: 18),
                label: const Text('Sync now'),
              ),
            ]),
          ],
        ),
        SettingsCard(
          title: 'Account',
          icon: Icons.account_circle_outlined,
          children: [
            InfoRow('Store account', boot.accountEmail ?? 'Unknown'),
            InfoRow('This terminal', '${svc.device.name} · ${svc.device.code}'),
            InfoRow('App version', appVersion),
            const SizedBox(height: Sp.md),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: _signingOut ? null : _signOut,
                icon: _signingOut
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.logout_rounded, size: 18),
                label: const Text('Sign out of this terminal'),
              ),
            ),
          ],
        ),
        if (owner)
          AppCard(
            borderColor: ec.danger.withValues(alpha: 0.5),
            padding: EdgeInsets.all(context.isPhone ? Sp.lg : Sp.xl),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Row(children: [
                Icon(Icons.warning_amber_rounded, color: ec.danger),
                const SizedBox(width: Sp.sm),
                Expanded(child: Text('Danger zone', style: context.tt.titleMedium?.copyWith(color: ec.danger))),
              ]),
              const SizedBox(height: 2),
              Text('Owner only. These change the data on every terminal and in the cloud, and can’t be undone.', style: context.tt.bodySmall),
              const SizedBox(height: Sp.md),
              _DangerRow(
                title: 'Clear sales history',
                subtitle: 'Deletes orders, refunds, shifts, cash movements and the activity log. Keeps the menu, staff, settings and current stock levels.',
                button: 'Clear history',
                onPressed: () => _danger(
                  title: 'Clear sales history',
                  message: 'All orders, refunds, shifts, cash movements and the activity log are deleted on every terminal. '
                      'Menu, staff, settings and stock levels are kept, and invoice numbers keep counting up.',
                  doneMessage: 'Sales history cleared',
                  run: (b, onStep) => b.clearSalesHistory(onStep),
                ),
              ),
            ]),
          ),
      ],
    );
  }
}

class _DangerRow extends StatelessWidget {
  const _DangerRow({required this.title, required this.subtitle, required this.button, required this.onPressed});
  final String title;
  final String subtitle;
  final String button;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    final text = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: context.tt.titleSmall),
      const SizedBox(height: 2),
      Text(subtitle, style: context.tt.bodySmall),
    ]);
    final btn = OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(foregroundColor: ec.danger, side: BorderSide(color: ec.danger.withValues(alpha: 0.6))),
      child: Text(button),
    );
    return LayoutBuilder(builder: (context, c) {
      if (c.maxWidth < 460) {
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [text, const SizedBox(height: Sp.sm), btn]);
      }
      return Row(children: [Expanded(child: text), const SizedBox(width: Sp.lg), btn]);
    });
  }
}

class _TypeToConfirm extends StatefulWidget {
  const _TypeToConfirm({required this.title});
  final String title;
  @override
  State<_TypeToConfirm> createState() => _TypeToConfirmState();
}

class _TypeToConfirmState extends State<_TypeToConfirm> {
  final _c = TextEditingController();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  bool get _ok => _c.text.trim() == 'RESET';

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    return DialogFrame(
      title: widget.title,
      subtitle: 'This can’t be undone',
      icon: Icons.warning_amber_rounded,
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: ec.danger, foregroundColor: ec.surface),
          onPressed: _ok ? () => Navigator.pop(context, true) : null,
          child: Text(widget.title),
        ),
      ],
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text.rich(
          TextSpan(children: [
            const TextSpan(text: 'Type '),
            TextSpan(text: 'RESET', style: TextStyle(fontWeight: FontWeight.w800, color: ec.danger)),
            const TextSpan(text: ' to confirm.'),
          ]),
          style: context.tt.bodyMedium,
        ),
        const SizedBox(height: Sp.md),
        TextField(
          controller: _c,
          autofocus: true,
          autocorrect: false,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(labelText: 'Confirmation', hintText: 'RESET'),
          onChanged: (_) => setState(() {}),
          onSubmitted: (_) {
            if (_ok) Navigator.pop(context, true);
          },
        ),
      ]),
    );
  }
}

class _ProgressDialog extends StatelessWidget {
  const _ProgressDialog({required this.title, required this.step});
  final String title;
  final ValueNotifier<String> step;

  @override
  Widget build(BuildContext context) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(Sp.xl),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const SizedBox(width: 36, height: 36, child: CircularProgressIndicator(strokeWidth: 3)),
              const SizedBox(height: Sp.lg),
              Text(title, style: context.tt.headlineSmall, textAlign: TextAlign.center),
              const SizedBox(height: Sp.sm),
              ValueListenableBuilder<String>(
                valueListenable: step,
                builder: (_, s, _) => Text(s, style: context.tt.bodyMedium?.copyWith(color: context.ec.textMuted), textAlign: TextAlign.center),
              ),
              const SizedBox(height: Sp.sm),
              Text('Keep the app open. It restarts when finished.', style: context.tt.bodySmall, textAlign: TextAlign.center),
            ]),
          ),
        ),
      );
}
