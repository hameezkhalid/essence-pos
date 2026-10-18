import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/models/settings_models.dart';
import '../../../shared/common.dart';
import '../menu/menu_widgets.dart';
import 'staff_rules.dart';

const _editableRoles = [Role.manager, Role.cashier];

/// What each role may do. Owners always have everything.
class PermissionMatrix extends ConsumerWidget {
  const PermissionMatrix({super.key});

  /// Whether the signed-in user may change [role]'s column.
  /// Non-owners can't change their own role's permissions (no self-promotion).
  static bool _canEditRole(bool canEdit, Role myRole, Role role) => canEdit && (myRole == Role.owner || myRole != role);

  Future<void> _toggle(BuildContext context, WidgetRef ref, Role role, Perm perm, bool on) async {
    final perms = ref.read(settingsValueProvider).permissions;
    await guardedWrite(
      context,
      () => ref.read(servicesProvider).settingsRepo.save(SettingKeys.permissions, perms.toggle(role, perm, on).toJson()),
    );
  }

  Future<void> _reset(BuildContext context, WidgetRef ref) async {
    final ok = await confirm(
      context,
      title: 'Reset permissions?',
      message: 'Managers and cashiers go back to the default permissions on every till.',
      confirmLabel: 'Reset',
    );
    if (!ok || !context.mounted) return;
    await guardedWrite(
      context,
      () => ref.read(servicesProvider).settingsRepo.save(SettingKeys.permissions, PermissionSettings.defaults.toJson()),
      success: 'Permissions reset to defaults',
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ec = context.ec;
    final perms = ref.watch(settingsValueProvider).permissions;
    final canEdit = ref.watch(canProvider(Perm.manageStaff));
    final myRole = ref.watch(roleProvider);
    final isDefault = _sameAsDefaults(perms);

    return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      SectionHeader(
        'Permissions',
        subtitle: 'What managers and cashiers can do. Without a permission, they can still ask someone who has it to approve with their PIN.',
        trailing: canEdit && myRole == Role.owner && !isDefault
            ? TextButton.icon(onPressed: () => _reset(context, ref), icon: const Icon(Icons.restart_alt_rounded, size: 18), label: const Text('Defaults'))
            : null,
      ),
      if (canEdit && myRole != Role.owner)
        Padding(
          padding: const EdgeInsets.only(bottom: Sp.md),
          child: InlineNote('Only an owner can change the ${myRole.label.toLowerCase()} permissions.', tone: Tone.info, icon: Icons.lock_outline_rounded),
        ),
      AppCard(
        padding: EdgeInsets.zero,
        child: LayoutBuilder(builder: (context, c) {
          final narrow = c.maxWidth < 560;
          final ownerNote = Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: Sp.lg, vertical: Sp.md),
            color: ec.accentContainer.withValues(alpha: 0.5),
            child: Row(children: [
              Icon(roleIcon(Role.owner), size: 18, color: ec.accent),
              const SizedBox(width: Sp.sm),
              Expanded(child: Text('Owners can do everything.', style: context.tt.bodySmall?.copyWith(color: ec.accent, fontWeight: FontWeight.w600))),
            ]),
          );

          if (narrow) {
            return Column(mainAxisSize: MainAxisSize.min, children: [
              ownerNote,
              for (final (i, p) in Perm.values.indexed) ...[
                if (i > 0) const RowDivider(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(Sp.lg, Sp.md, Sp.sm, Sp.xs),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    Row(children: [
                      Icon(permIcon(p), size: 18, color: ec.textMuted),
                      const SizedBox(width: Sp.sm),
                      Expanded(child: Text(p.label, style: context.tt.bodyMedium?.copyWith(fontWeight: FontWeight.w500))),
                    ]),
                    Wrap(alignment: WrapAlignment.end, children: [
                      for (final r in _editableRoles)
                        InlineSwitch(
                          label: r.label,
                          value: perms.allows(r, p),
                          onChanged: _canEditRole(canEdit, myRole, r) ? (v) => _toggle(context, ref, r, p, v) : null,
                        ),
                    ]),
                  ]),
                ),
              ],
            ]);
          }

          Widget head(String t) => SizedBox(
                width: 92,
                child: Text(t, textAlign: TextAlign.center, style: context.tt.labelMedium?.copyWith(color: ec.textMuted)),
              );
          return Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              color: ec.surfaceAlt,
              padding: const EdgeInsets.fromLTRB(Sp.lg, Sp.md, Sp.md, Sp.md),
              child: Row(children: [
                Expanded(child: Text('Permission', style: context.tt.labelMedium?.copyWith(color: ec.textMuted))),
                Tooltip(message: 'Owners can do everything', child: head(Role.owner.label)),
                for (final r in _editableRoles) head(r.label),
              ]),
            ),
            for (final (i, p) in Perm.values.indexed) ...[
              if (i > 0) const RowDivider(),
              Padding(
                padding: const EdgeInsets.fromLTRB(Sp.lg, Sp.xs, Sp.md, Sp.xs),
                child: Row(children: [
                  Icon(permIcon(p), size: 18, color: ec.textMuted),
                  const SizedBox(width: Sp.md),
                  Expanded(child: Text(p.label, style: context.tt.bodyMedium)),
                  SizedBox(
                    width: 92,
                    child: Tooltip(
                      message: 'Owners can do everything',
                      child: Icon(Icons.check_circle_rounded, size: 20, color: ec.textFaint, semanticLabel: '${Role.owner.label}: always allowed'),
                    ),
                  ),
                  for (final r in _editableRoles)
                    SizedBox(
                      width: 92,
                      child: Checkbox(
                        value: perms.allows(r, p),
                        semanticLabel: '${r.label}: ${p.label}',
                        onChanged: _canEditRole(canEdit, myRole, r) ? (v) => _toggle(context, ref, r, p, v ?? false) : null,
                      ),
                    ),
                ]),
              ),
            ],
            const RowDivider(indent: 0),
            ownerNote,
          ]);
        }),
      ),
    ]);
  }

  static bool _sameAsDefaults(PermissionSettings p) {
    for (final r in _editableRoles) {
      final a = p.byRole[r] ?? const <Perm>{};
      final b = PermissionSettings.defaults.byRole[r] ?? const <Perm>{};
      if (a.length != b.length || !a.containsAll(b)) return false;
    }
    return true;
  }
}
