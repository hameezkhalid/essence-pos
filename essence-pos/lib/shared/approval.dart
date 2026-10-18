import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/providers.dart';
import '../app/theme/tokens.dart';
import '../core/db/database.dart';
import '../core/models/settings_models.dart';
import 'common.dart';
import 'keypads.dart';

/// Returns who authorised [perm]: the signed-in staff member if allowed, otherwise a manager
/// who enters their PIN. Null when cancelled.
Future<StaffMember?> requirePermission(BuildContext context, WidgetRef ref, Perm perm, {String? why}) async {
  final me = ref.read(sessionProvider);
  if (me == null) return null;
  final perms = ref.read(settingsValueProvider).permissions;
  if (perms.allows(Role.parse(me.role), perm)) return me;
  return showAdaptive<StaffMember>(
    context,
    maxWidth: 420,
    builder: (ctx) => _ApprovalDialog(perm: perm, why: why),
  );
}

class _ApprovalDialog extends ConsumerStatefulWidget {
  const _ApprovalDialog({required this.perm, this.why});
  final Perm perm;
  final String? why;

  @override
  ConsumerState<_ApprovalDialog> createState() => _ApprovalDialogState();
}

class _ApprovalDialogState extends ConsumerState<_ApprovalDialog> {
  String? _error;

  @override
  Widget build(BuildContext context) {
    return DialogFrame(
      title: 'Manager approval',
      subtitle: widget.why ?? widget.perm.label,
      icon: Icons.verified_user_outlined,
      child: Column(children: [
        Text('Ask a manager to enter their PIN.', style: context.tt.bodyMedium?.copyWith(color: context.ec.textMuted)),
        const SizedBox(height: Sp.lg),
        PinPad(
          error: _error,
          onComplete: (pin) async {
            final s = await ref.read(servicesProvider).staff.verify(pin);
            final perms = ref.read(settingsValueProvider).permissions;
            if (s == null) {
              setState(() => _error = 'Wrong PIN');
              return false;
            }
            if (!perms.allows(Role.parse(s.role), widget.perm)) {
              setState(() => _error = '${s.name} can’t approve this');
              return false;
            }
            if (context.mounted) Navigator.pop(context, s);
            return true;
          },
        ),
      ]),
    );
  }
}
