import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderListenable;

import '../../../app/providers.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/models/settings_models.dart';
import '../../../shared/common.dart';
import '../settings_widgets.dart';

const autoLockOptions = [0, 1, 2, 5, 10, 15];

class SecuritySection extends ConsumerStatefulWidget {
  const SecuritySection({super.key});
  @override
  ConsumerState<SecuritySection> createState() => _SecuritySectionState();
}

class _SecuritySectionState extends SettingsFormState<SecuritySection> {
  int _lock = 5;
  bool _shift = true;

  SecuritySettings get _saved => ref.read(settingsValueProvider).security;
  SecuritySettings get _draft => SecuritySettings(autoLockMinutes: _lock, requireOpenShift: _shift);

  @override
  List<ProviderListenable<Object?>> get sources => [settingsValueProvider];

  @override
  Object? savedJson() => _saved.toJson();

  @override
  Object? draftJson() => _draft.toJson();

  @override
  void load() {
    _lock = _saved.autoLockMinutes;
    _shift = _saved.requireOpenShift;
  }

  @override
  Future<void> persist() => ref.read(servicesProvider).settingsRepo.save(SettingKeys.security, _draft.toJson());

  @override
  String get savedMessage => 'Security settings saved';

  @override
  Widget build(BuildContext context) {
    final options = {...autoLockOptions, _lock}.toList()..sort();
    return SettingsScaffold(
      title: 'Security',
      subtitle: 'Keep the till safe when staff step away.',
      onSave: save,
      footer: saveBar(),
      children: [
        SettingsCard(
          title: 'Auto-lock',
          subtitle: 'Return to the PIN screen after this long without a tap.',
          icon: Icons.lock_clock_outlined,
          children: [
            Wrap(spacing: Sp.sm, runSpacing: Sp.sm, children: [
              for (final m in options)
                ChoiceChip(
                  label: Text(m == 0 ? 'Never' : '$m min'),
                  selected: _lock == m,
                  onSelected: (_) => setState(() => _lock = m),
                ),
            ]),
            const SizedBox(height: Sp.md),
            Text(
              _lock == 0
                  ? 'The till stays signed in until someone locks it from the staff menu.'
                  : 'After $_lock minute${_lock == 1 ? '' : 's'} of no activity the till locks and asks for a PIN.',
              style: context.tt.bodySmall,
            ),
          ],
        ),
        SettingsCard(
          title: 'Shifts',
          icon: Icons.schedule_outlined,
          children: [
            LabeledSwitch(
              title: 'Require an open shift before selling',
              subtitle: 'Staff are asked to count the opening float before the first sale, so the cash drawer always reconciles',
              value: _shift,
              onChanged: (v) => setState(() => _shift = v),
            ),
          ],
        ),
      ],
    );
  }
}
