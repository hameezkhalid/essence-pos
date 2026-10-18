import 'package:flutter/material.dart';

import '../../../core/db/database.dart';
import '../../../core/models/settings_models.dart';
import '../../../shared/common.dart';

// Safety rules for editing staff, shared by the list and the editor.

bool isOwner(StaffMember? s) => s != null && Role.parse(s.role) == Role.owner;

int activeOwnerCount(List<StaffMember> all) => all.where((s) => !s.deleted && s.active && isOwner(s)).length;

/// True when [s] is the only active owner left.
bool isLastActiveOwner(StaffMember s, List<StaffMember> all) => s.active && isOwner(s) && activeOwnerCount(all) <= 1;

/// Only owners may edit owners (so a manager with "Manage staff" can't lock out or impersonate an owner).
bool canManageMember(StaffMember? me, StaffMember target) => isOwner(me) || !isOwner(target);

/// Why [s] can't be deactivated or deleted, or null when it's fine.
String? deactivateBlockReason(StaffMember s, List<StaffMember> all, StaffMember? me, {bool deleting = false}) {
  if (me?.id == s.id) return deleting ? 'You can’t delete yourself while signed in.' : 'You can’t deactivate yourself while signed in.';
  if (isLastActiveOwner(s, all)) {
    return '${s.name} is the only active owner. Make someone else an owner first.';
  }
  return null;
}

Tone roleTone(Role r) => switch (r) { Role.owner => Tone.accent, Role.manager => Tone.primary, Role.cashier => Tone.neutral };

IconData roleIcon(Role r) => switch (r) {
      Role.owner => Icons.workspace_premium_outlined,
      Role.manager => Icons.manage_accounts_outlined,
      Role.cashier => Icons.point_of_sale_outlined,
    };

IconData permIcon(Perm p) => switch (p) {
      Perm.discountOverride => Icons.percent_rounded,
      Perm.voidOrder => Icons.block_rounded,
      Perm.refund => Icons.undo_rounded,
      Perm.openDrawer => Icons.point_of_sale_outlined,
      Perm.cashInOut => Icons.swap_vert_rounded,
      Perm.closeShift => Icons.lock_clock_outlined,
      Perm.viewReports => Icons.insights_outlined,
      Perm.manageInventory => Icons.inventory_2_outlined,
      Perm.manageMenu => Icons.restaurant_menu_rounded,
      Perm.manageStaff => Icons.badge_outlined,
      Perm.manageSettings => Icons.tune_rounded,
    };
