import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme/tokens.dart';
import '../../core/db/database.dart';
import '../../core/money.dart';
import '../../shared/common.dart';
import '../../shared/keypads.dart';

/// Asks for the opening cash float and opens a shift on this terminal.
Future<Shift?> showOpenShiftDialog(BuildContext context, WidgetRef ref) =>
    showAdaptive<Shift>(context, maxWidth: 440, builder: (_) => const _OpenShiftDialog());

class _OpenShiftDialog extends ConsumerStatefulWidget {
  const _OpenShiftDialog();
  @override
  ConsumerState<_OpenShiftDialog> createState() => _OpenShiftDialogState();
}

class _OpenShiftDialogState extends ConsumerState<_OpenShiftDialog> {
  String _amount = '10000';
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final staff = ref.watch(sessionProvider);
    return DialogFrame(
      title: 'Open shift',
      subtitle: 'Count the cash in the drawer before the first sale',
      icon: Icons.schedule_rounded,
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Later')),
        FilledButton.icon(
          onPressed: staff == null || _busy
              ? null
              : () async {
                  setState(() => _busy = true);
                  final s = await ref.read(servicesProvider).shifts.open(openingFloat: parseRupees(_amount) ?? 0, staff: staff);
                  if (context.mounted) {
                    Navigator.pop(context, s);
                    toast(context, 'Shift opened with ${rs(s.openingFloat)} float');
                  }
                },
          icon: const Icon(Icons.play_arrow_rounded),
          label: const Text('Open shift'),
        ),
      ],
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('Opening float', style: context.tt.labelMedium?.copyWith(color: context.ec.textMuted)),
        const SizedBox(height: Sp.xs),
        Text(rs(parseRupees(_amount) ?? 0), style: context.tt.displaySmall?.copyWith(fontFeatures: tabular)),
        const SizedBox(height: Sp.md),
        Wrap(spacing: Sp.sm, children: [
          for (final v in const [5000, 10000, 15000, 20000])
            ActionChip(label: Text(rs(v * 100)), onPressed: () => setState(() => _amount = '$v')),
        ]),
        const SizedBox(height: Sp.md),
        AmountPad(value: _amount, onChanged: (v) => setState(() => _amount = v)),
      ]),
    );
  }
}
