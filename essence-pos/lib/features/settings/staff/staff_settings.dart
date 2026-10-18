import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/db/database.dart';
import '../../../core/models/settings_models.dart';
import '../../../shared/common.dart';
import '../../lock/lock_screen.dart';
import '../menu/menu_widgets.dart';
import 'permission_matrix.dart';
import 'staff_dialog.dart';
import 'staff_rules.dart';

/// Settings › Staff & roles: staff list, PINs, roles, permission matrix.
///
/// Embedded in the scrollable Settings page, so it sizes itself (no Scaffold, no own scrolling).
class StaffSettingsPane extends ConsumerWidget {
  const StaffSettingsPane({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canEdit = ref.watch(canProvider(Perm.manageStaff));
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!canEdit) const ViewOnlyNote('You can view staff, but changing them needs the “Manage staff & permissions” permission.'),
        const _StaffList(),
        const SizedBox(height: Sp.xxl),
        const PermissionMatrix(),
      ],
    );
  }
}

class _StaffList extends ConsumerWidget {
  const _StaffList();

  Future<void> _edit(BuildContext context, WidgetRef ref, StaffMember? s) async {
    if (!ref.read(canProvider(Perm.manageStaff))) return;
    final me = ref.read(sessionProvider);
    if (s != null && !canManageMember(me, s)) {
      toast(context, 'Only an owner can change an owner’s details.', error: true, icon: Icons.lock_outline_rounded);
      return;
    }
    final msg = await showAdaptive<String>(context, maxWidth: 520, builder: (_) => StaffDialog(staff: s));
    if (msg != null && context.mounted) toast(context, msg);
  }

  Future<void> _setActive(BuildContext context, WidgetRef ref, List<StaffMember> all, StaffMember s, bool active) async {
    final me = ref.read(sessionProvider);
    final block = active ? null : deactivateBlockReason(s, all, me);
    if (block != null) {
      toast(context, block, error: true, icon: Icons.lock_outline_rounded);
      return;
    }
    await guardedWrite(
      context,
      () => ref.read(servicesProvider).staff.save(s.copyWith(active: active)),
      success: active ? '${s.name} can sign in again' : '${s.name} can no longer sign in',
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ec = context.ec;
    final canEdit = ref.watch(canProvider(Perm.manageStaff));
    final me = ref.watch(sessionProvider);
    final async = ref.watch(staffListProvider);

    if (async.hasError && !async.hasValue) {
      return EmptyState(icon: Icons.error_outline_rounded, title: 'Couldn’t load staff', message: '${async.error}');
    }
    if (!async.hasValue) return const PaneLoading();

    final all = [...async.value!]
      ..sort((a, b) {
        if (a.active != b.active) return a.active ? -1 : 1;
        final r = Role.parse(a.role).index.compareTo(Role.parse(b.role).index);
        return r != 0 ? r : a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
    final activeCount = all.where((s) => s.active).length;

    final addBtn = FilledButton.icon(
      onPressed: canEdit ? () => _edit(context, ref, null) : null,
      icon: const Icon(Icons.person_add_alt_1_rounded),
      label: const Text('Add staff'),
    );

    return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      SectionHeader(
        'Team',
        subtitle: all.isEmpty ? 'People who can sign in to the tills with a PIN.' : '$activeCount active · ${all.length - activeCount} inactive',
        trailing: addBtn,
      ),
      if (all.isEmpty)
        const AppCard(
          child: EmptyState(icon: Icons.badge_outlined, title: 'No staff yet', message: 'Add the people who work the till. Each gets a 4-digit PIN.'),
        )
      else
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            for (final (i, s) in all.indexed) ...[
              if (i > 0) const RowDivider(indent: 72),
              Builder(builder: (context) {
                final role = Role.parse(s.role);
                final isMe = me?.id == s.id;
                final manageable = canEdit && canManageMember(me, s);
                return InkWell(
                  onTap: canEdit ? () => _edit(context, ref, s) : null,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(Sp.lg, Sp.md, Sp.md, Sp.md),
                    child: Row(children: [
                      Opacity(opacity: s.active ? 1 : 0.45, child: StaffAvatar(staff: s, size: 40)),
                      const SizedBox(width: Sp.md),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(s.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.tt.titleSmall?.copyWith(color: s.active ? null : ec.textMuted)),
                          const SizedBox(height: 4),
                          Wrap(spacing: 4, runSpacing: 4, children: [
                            Pill(role.label, tone: roleTone(role), dense: true, icon: roleIcon(role)),
                            if (isMe) const Pill('You', tone: Tone.success, dense: true),
                            if (!s.active) const Pill('Inactive', dense: true),
                          ]),
                        ]),
                      ),
                      const SizedBox(width: Sp.sm),
                      Tooltip(
                        message: s.active ? 'Can sign in' : 'Can’t sign in',
                        child: Switch(
                          value: s.active,
                          onChanged: manageable ? (v) => _setActive(context, ref, all, s, v) : null,
                        ),
                      ),
                      if (canEdit) Icon(Icons.chevron_right_rounded, color: manageable ? ec.textFaint : ec.border),
                    ]),
                  ),
                );
              }),
            ],
          ]),
        ),
    ]);
  }
}
