import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/providers.dart';
import '../../app/theme/tokens.dart';
import '../../core/sync/sync_engine.dart';
import '../../shared/common.dart';

/// Online / offline / syncing indicator. Tap for details and the demo "go offline" switch.
class SyncPill extends ConsumerWidget {
  const SyncPill({super.key, this.compact = false});
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(syncStatusProvider).value ?? const SyncStatus();
    final ec = context.ec;
    final (Tone tone, IconData icon, String label) = !s.online
        ? (Tone.danger, Icons.cloud_off_rounded, 'Offline')
        : s.error != null && s.pending > 0
            ? (Tone.warning, Icons.sync_problem_rounded, 'Sync issue')
            : s.pending > 0
                ? (Tone.warning, Icons.cloud_upload_outlined, 'Syncing')
                : (Tone.success, Icons.cloud_done_rounded, 'Online');
    final (fg, bg) = tone.colors(ec);
    return Tooltip(
      message: 'Sync status',
      child: Material(
        color: bg,
        shape: const StadiumBorder(),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: () => showDialog<void>(context: context, builder: (_) => const SyncDetailsDialog()),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 12, vertical: 7),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon, size: 16, color: fg),
              if (!compact) ...[
                const SizedBox(width: 6),
                Text(label, style: context.tt.labelMedium?.copyWith(color: fg)),
              ],
              if (s.pending > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(color: fg, borderRadius: BorderRadius.circular(99)),
                  child: Text(s.pending > 999 ? '999+' : '${s.pending}', style: context.tt.labelSmall?.copyWith(color: bg, fontWeight: FontWeight.w800)),
                ),
              ],
            ]),
          ),
        ),
      ),
    );
  }
}

class SyncDetailsDialog extends ConsumerWidget {
  const SyncDetailsDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(syncStatusProvider).value ?? const SyncStatus();
    final svc = ref.watch(servicesProvider);
    final ec = context.ec;
    Widget row(String k, String v, {Color? color}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(children: [
            Expanded(child: Text(k, style: context.tt.bodyMedium?.copyWith(color: ec.textMuted))),
            Text(v, style: context.tt.titleSmall?.copyWith(color: color)),
          ]),
        );
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: DialogFrame(
          title: 'Sync & connection',
          icon: Icons.cloud_sync_outlined,
          actions: [
            OutlinedButton.icon(
              onPressed: s.online ? () => svc.sync.pump() : null,
              icon: const Icon(Icons.sync_rounded, size: 18),
              label: const Text('Sync now'),
            ),
            FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Done')),
          ],
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            row('Internet', s.networkUp ? 'Connected' : 'No connection', color: s.networkUp ? ec.success : ec.danger),
            row('Waiting to upload', '${s.pending} change${s.pending == 1 ? '' : 's'}', color: s.pending > 0 ? ec.warning : null),
            row('Last synced', s.lastSyncAt == null ? '—' : DateFormat('h:mm:ss a').format(s.lastSyncAt!)),
            if (s.error != null)
              Container(
                margin: const EdgeInsets.only(top: Sp.sm),
                padding: const EdgeInsets.all(Sp.md),
                decoration: BoxDecoration(color: ec.warningContainer, borderRadius: BorderRadius.circular(Rad.md)),
                child: Text(s.error!, style: context.tt.bodySmall?.copyWith(color: ec.warning)),
              ),
            const Divider(height: Sp.xl),
            LabeledSwitch(
              title: 'Work offline (demo)',
              subtitle: 'Simulates an internet outage. Sales keep working and save on this device; '
                  'they upload in order — with no duplicates — when you switch back.',
              value: s.forcedOffline,
              onChanged: (v) => svc.sync.setForcedOffline(v),
            ),
            const SizedBox(height: Sp.sm),
            Text('Sales are always saved on this computer first, so the till never waits for the internet.', style: context.tt.bodySmall),
          ]),
        ),
      ),
    );
  }
}

class LiveClock extends StatefulWidget {
  const LiveClock({super.key, this.style});
  final TextStyle? style;
  @override
  State<LiveClock> createState() => _LiveClockState();
}

class _LiveClockState extends State<LiveClock> {
  late Timer _t;
  DateTime _now = DateTime.now();
  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(const Duration(seconds: 20), (_) => setState(() => _now = DateTime.now()));
  }

  @override
  void dispose() {
    _t.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      Text(DateFormat('h:mm a').format(_now), style: widget.style ?? context.tt.labelLarge?.copyWith(color: context.ec.textMuted, fontFeatures: tabular));
}
