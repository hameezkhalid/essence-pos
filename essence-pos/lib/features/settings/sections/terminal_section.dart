import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderListenable;

import '../../../app/boot_actions.dart';
import '../../../app/providers.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/db/database.dart';
import '../../../shared/common.dart';
import '../settings_widgets.dart';

class TerminalSection extends ConsumerStatefulWidget {
  const TerminalSection({super.key});
  @override
  ConsumerState<TerminalSection> createState() => _TerminalSectionState();
}

class _TerminalSectionState extends SettingsFormState<TerminalSection> {
  late final _name = ctrl();
  late final _code = ctrl();
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  @override
  List<ProviderListenable<Object?>> get sources => const [];

  @override
  Object? savedJson() {
    final d = ref.read(servicesProvider).device;
    return {'name': d.name, 'code': d.code};
  }

  @override
  Object? draftJson() => {'name': _name.text.trim(), 'code': _code.text.trim().toUpperCase()};

  @override
  void load() {
    final d = ref.read(servicesProvider).device;
    setText(_name, d.name);
    setText(_code, d.code);
  }

  @override
  Future<void> save() async {
    if (!dirty || saving) return;
    if (formKey.currentState?.validate() == false) return;
    final ok = await confirm(
      context,
      title: 'Rename this terminal?',
      message: 'The app restarts its services to apply the new name and code. This takes a few seconds and '
          'returns to the staff sign-in screen.',
      confirmLabel: 'Rename & restart',
    );
    if (!ok || !mounted) return;
    await super.save();
  }

  @override
  Future<void> persist() => ref.read(bootActionsProvider).renameTerminal(_name.text.trim(), _code.text.trim().toUpperCase());

  @override
  String get savedMessage => 'Terminal renamed';

  @override
  Widget build(BuildContext context) {
    final svc = ref.watch(servicesProvider);
    final terminals = ref.watch(terminalsProvider).value ?? const <Terminal>[];
    final prefix = ref.watch(settingsValueProvider).store.invoicePrefix;
    final code = _code.text.trim().isEmpty ? 'T1' : _code.text.trim().toUpperCase();
    final codeChanged = code != svc.device.code;
    return SettingsScaffold(
      title: 'Terminal',
      subtitle: 'This device’s name and invoice code, and every till in the store.',
      formKey: formKey,
      onSave: save,
      footer: saveBar(),
      children: [
        SettingsCard(
          title: 'This terminal',
          icon: Icons.point_of_sale_outlined,
          children: [
            FieldRow(flex: const [2, 1], breakpoint: 420, children: [
              TextFormField(
                controller: _name,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Terminal name', hintText: 'e.g. Counter 1, Bar till'),
                validator: (v) => (v ?? '').trim().isEmpty ? 'Enter a name' : null,
              ),
              TextFormField(
                controller: _code,
                textInputAction: TextInputAction.done,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                  LengthLimitingTextInputFormatter(4),
                  TextInputFormatter.withFunction((o, n) => n.copyWith(text: n.text.toUpperCase())),
                ],
                decoration: const InputDecoration(labelText: 'Code', hintText: 'T1'),
                validator: (v) {
                  final c = (v ?? '').trim().toUpperCase();
                  if (c.isEmpty) return 'Enter a code';
                  final clash = terminals.where((t) => t.id != svc.device.id && t.code.toUpperCase() == c).firstOrNull;
                  return clash == null ? null : 'Used by ${clash.name}';
                },
                onFieldSubmitted: (_) => save(),
              ),
            ]),
            const SizedBox(height: Sp.sm),
            Text('Invoices from this terminal are numbered $prefix-$code-000001, $prefix-$code-000002…', style: context.tt.bodySmall),
            if (codeChanged) ...[
              const SizedBox(height: Sp.md),
              const InfoBanner(
                'Each terminal needs its own code so invoice numbers never clash. Saving restarts the app’s services.',
                tone: Tone.warning,
                icon: Icons.restart_alt_rounded,
              ),
            ],
          ],
        ),
        SettingsCard(
          title: 'All terminals',
          subtitle: 'Terminals report in every few minutes while online.',
          icon: Icons.devices_other_outlined,
          children: [
            if (terminals.isEmpty)
              Text('No terminals have reported in yet.', style: context.tt.bodyMedium?.copyWith(color: context.ec.textMuted))
            else
              for (var i = 0; i < terminals.length; i++) ...[
                if (i > 0) Divider(height: Sp.lg, color: context.ec.border),
                _TerminalRow(terminal: terminals[i], isThis: terminals[i].id == svc.device.id),
              ],
          ],
        ),
      ],
    );
  }
}

class _TerminalRow extends StatelessWidget {
  const _TerminalRow({required this.terminal, required this.isThis});
  final Terminal terminal;
  final bool isThis;

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    final t = terminal;
    final seen = t.lastSeenAt > 0 ? DateTime.fromMillisecondsSinceEpoch(t.lastSeenAt) : null;
    final online = seen != null && DateTime.now().difference(seen) <= const Duration(minutes: 10);
    return Row(children: [
      Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: ec.beige, borderRadius: BorderRadius.circular(12)),
        child: Text(t.code, style: context.tt.titleSmall?.copyWith(color: ec.accent)),
      ),
      const SizedBox(width: Sp.md),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Wrap(spacing: Sp.sm, runSpacing: 2, crossAxisAlignment: WrapCrossAlignment.center, children: [
            Text(t.name, style: context.tt.titleSmall),
            if (isThis) const Pill('This terminal', dense: true, tone: Tone.primary),
          ]),
          const SizedBox(height: Sp.xs),
          Wrap(spacing: Sp.sm, runSpacing: 2, crossAxisAlignment: WrapCrossAlignment.center, children: [
            Pill(
              online ? 'Online' : (seen == null ? 'Never seen' : 'Last seen ${timeAgo(seen)}'),
              dense: true,
              tone: online ? Tone.success : Tone.neutral,
              icon: online ? Icons.circle : Icons.schedule_rounded,
            ),
            Text(t.appVersion.isEmpty ? 'Version unknown' : 'App ${t.appVersion}', style: context.tt.bodySmall),
          ]),
        ]),
      ),
    ]);
  }
}
