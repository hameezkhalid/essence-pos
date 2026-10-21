import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderListenable;

import '../../../app/providers.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/models/settings_models.dart';
import '../../../core/sync/sync_engine.dart';
import '../../../shared/common.dart';
import '../settings_widgets.dart';
import 'fbr_queries.dart';

class FbrSection extends ConsumerStatefulWidget {
  const FbrSection({super.key});
  @override
  ConsumerState<FbrSection> createState() => _FbrSectionState();
}

class _FbrSectionState extends SettingsFormState<FbrSection> {
  late final _posId = ctrl();
  late final _token = ctrl();
  late final _pct = ctrl();
  bool _enabled = false;
  FbrMode _mode = FbrMode.live;
  bool _reveal = false;
  bool _reporting = false;
  late final Stream<Map<String, int>> _counts;

  @override
  void initState() {
    super.initState();
    final svc = ref.read(servicesProvider);
    _counts = watchFiscalCounts(svc.db, svc.ctx.businessDate());
  }

  FbrSettings get _saved => ref.read(settingsValueProvider).fbr;
  FbrSettings get _draft => FbrSettings(enabled: _enabled, mode: _mode, posId: _posId.text.trim(), token: _token.text.trim(), pctCode: _pct.text.trim());

  @override
  List<ProviderListenable<Object?>> get sources => [settingsValueProvider];

  @override
  Object? savedJson() => _saved.toJson();

  @override
  Object? draftJson() => _draft.toJson();

  @override
  void load() {
    final s = _saved;
    _enabled = s.enabled;
    _mode = s.mode;
    setText(_posId, s.posId);
    setText(_token, s.token);
    setText(_pct, s.pctCode);
  }

  @override
  Future<void> persist() => ref.read(servicesProvider).settingsRepo.save(SettingKeys.fbr, _draft.toJson());

  @override
  String get savedMessage => 'FBR settings saved';

  Future<void> _reportNow() async {
    final svc = ref.read(servicesProvider);
    if (!svc.sync.status.online) {
      toast(context, 'This terminal is offline. Pending invoices are reported automatically when it reconnects.', error: true, icon: Icons.cloud_off_rounded);
      return;
    }
    setState(() => _reporting = true);
    try {
      await svc.fiscal.run();
      if (mounted) toast(context, 'Pending invoices sent to FBR', icon: Icons.verified_outlined);
    } catch (e) {
      if (mounted) toast(context, 'Reporting failed: $e', error: true);
    } finally {
      if (mounted) setState(() => _reporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    final online = (ref.watch(syncStatusProvider).value ?? const SyncStatus()).online;
    return SettingsScaffold(
      title: 'FBR invoices',
      subtitle: 'Report every sale to FBR and print the FBR invoice number and QR code on the receipt.',
      formKey: formKey,
      onSave: save,
      footer: saveBar(),
      children: [
        SettingsCard(
          title: 'Reporting',
          icon: Icons.verified_outlined,
          children: [
            LabeledSwitch(
              title: 'FBR invoices',
              subtitle: _enabled
                  ? 'On — each sale is reported to FBR; receipts are sales tax invoices with the FBR number, QR code and FBR POS fee.'
                  : 'Off — FBR is bypassed: plain sales receipts, no FBR POS fee, nothing reported. Sales made while off are never sent to FBR.',
              value: _enabled,
              onChanged: (v) => setState(() => _enabled = v),
            ),
            const SizedBox(height: Sp.md),
            Text('Environment', style: context.tt.titleSmall),
            const SizedBox(height: Sp.sm),
            Segments<FbrMode>(
              values: FbrMode.values,
              selected: _mode,
              enabled: _enabled,
              minWidth: 360,
              label: (m) => switch (m) { FbrMode.sandbox => 'Sandbox (testing)', FbrMode.live => 'Live' },
              onChanged: (m) => setState(() => _mode = m),
            ),
            const SizedBox(height: Sp.sm),
            if (_enabled && (_posId.text.trim().isEmpty || _token.text.trim().isEmpty))
              const InfoBanner(
                'Enter the POS ID and token from FBR below. Until then invoices wait in the queue and receipts say “FBR invoice pending”.',
                tone: Tone.warning,
                icon: Icons.key_off_outlined,
              )
            else
              Text(
                _mode == FbrMode.live
                    ? 'Live: invoices go to FBR’s production system (gw.fbr.gov.pk).'
                    : 'Sandbox: invoices go to FBR’s test system and are not real tax records.',
                style: context.tt.bodySmall,
              ),
          ],
        ),
        SettingsCard(
          title: 'Credentials',
          subtitle: 'Issued by FBR when the POS is registered (IRIS › POS registration).',
          icon: Icons.key_outlined,
          children: [
            TextFormField(
              controller: _posId,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'POS ID', hintText: 'e.g. 137284'),
            ),
            fieldGap,
            TextFormField(
              controller: _token,
              obscureText: !_reveal,
              autocorrect: false,
              enableSuggestions: false,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: 'Access token',
                suffixIcon: IconButton(
                  tooltip: _reveal ? 'Hide token' : 'Show token',
                  onPressed: () => setState(() => _reveal = !_reveal),
                  icon: Icon(_reveal ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                ),
              ),
              onFieldSubmitted: (_) => save(),
            ),
            fieldGap,
            TextFormField(
              controller: _pct,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'PCT code',
                hintText: 'As advised by FBR / your tax consultant',
                helperText: 'Harmonised (PCT) code reported for each item.',
              ),
            ),
          ],
        ),
        SettingsCard(
          title: 'Today',
          subtitle: 'Invoices for the current business day across all terminals.',
          icon: Icons.today_outlined,
          trailing: online ? null : const Pill('Offline', tone: Tone.danger, icon: Icons.cloud_off_rounded, dense: true),
          children: [
            StreamBuilder<Map<String, int>>(
              stream: _counts,
              builder: (context, snap) {
                final m = snap.data ?? const <String, int>{};
                final reported = m['reported'] ?? 0;
                final pending = (m['pending'] ?? 0) + (m['failed'] ?? 0);
                final none = m['none'] ?? 0;
                return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  ResponsiveGrid(minWidth: 150, children: [
                    _StatTile(label: 'Reported', value: '$reported', tone: Tone.success, icon: Icons.check_circle_outline_rounded),
                    _StatTile(label: 'Pending', value: '$pending', tone: pending > 0 ? Tone.warning : Tone.neutral, icon: Icons.hourglass_empty_rounded),
                    if (none > 0) _StatTile(label: 'Not reported', value: '$none', tone: Tone.neutral, icon: Icons.remove_circle_outline_rounded),
                  ]),
                  const SizedBox(height: Sp.md),
                  Wrap(spacing: Sp.md, runSpacing: Sp.sm, crossAxisAlignment: WrapCrossAlignment.center, children: [
                    FilledButton.icon(
                      onPressed: _reporting || pending == 0 ? null : _reportNow,
                      icon: _reporting
                          ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: ec.onPrimary))
                          : const Icon(Icons.send_outlined, size: 18),
                      label: const Text('Report pending now'),
                    ),
                    Text(
                      pending == 0 ? 'Nothing waiting.' : 'Each terminal reports its own invoices automatically when online.',
                      style: context.tt.bodySmall,
                    ),
                  ]),
                ]);
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value, required this.tone, required this.icon});
  final String label;
  final String value;
  final Tone tone;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final (fg, bg) = tone.colors(context.ec);
    return Container(
      padding: const EdgeInsets.all(Sp.md),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(Rad.md)),
      child: Row(children: [
        Icon(icon, color: fg, size: 22),
        const SizedBox(width: Sp.md),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(value, style: context.tt.headlineSmall?.copyWith(color: fg, fontFeatures: tabular)),
            Text(label, style: context.tt.labelMedium?.copyWith(color: context.ec.text)),
          ]),
        ),
      ]),
    );
  }
}
