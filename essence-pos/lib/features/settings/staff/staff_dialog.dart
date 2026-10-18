import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/theme/icons.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/db/database.dart';
import '../../../core/models/settings_models.dart';
import '../../../core/services/repos.dart';
import '../../../shared/common.dart';
import '../../lock/lock_screen.dart';
import '../menu/menu_widgets.dart';
import 'staff_rules.dart';

/// Add / edit a staff member, including their PIN. Pops with a message for the caller to toast.
class StaffDialog extends ConsumerStatefulWidget {
  const StaffDialog({super.key, this.staff});
  final StaffMember? staff;

  @override
  ConsumerState<StaffDialog> createState() => _StaffDialogState();
}

class _StaffDialogState extends ConsumerState<StaffDialog> {
  StaffMember? get _s => widget.staff;
  bool get _isNew => _s == null;

  late final _name = TextEditingController(text: _s?.name ?? '');
  final _pin1 = TextEditingController();
  final _pin2 = TextEditingController();
  final _pin2Focus = FocusNode();
  late Role _role = _s == null ? Role.cashier : Role.parse(_s!.role);
  late int _color = _s?.color ?? swatches[5];
  late bool _active = _s?.active ?? true;
  late bool _setPin = _isNew;
  bool _showPin = false;
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _pin1.dispose();
    _pin2.dispose();
    _pin2Focus.dispose();
    super.dispose();
  }

  void _fail(String m) => setState(() {
        _error = m;
        _saving = false;
      });

  Future<void> _save() async {
    if (_saving) return;
    final name = _name.text.trim();
    final all = ref.read(staffListProvider).value ?? const <StaffMember>[];
    final me = ref.read(sessionProvider);
    final s = _s;
    if (name.isEmpty) return _fail('Enter a name.');
    if (_role == Role.owner && !isOwner(me)) return _fail('Only an owner can make someone an owner.');
    if (s != null && isLastActiveOwner(s, all) && (_role != Role.owner || !_active)) {
      return _fail('${s.name} is the only active owner. Make someone else an owner before changing this.');
    }
    if (s != null && s.id == me?.id && !_active) return _fail('You can’t deactivate yourself while signed in.');

    String? pin;
    if (_setPin) {
      pin = _pin1.text.trim();
      if (!RegExp(r'^\d{4}$').hasMatch(pin)) return _fail('The PIN must be exactly 4 digits.');
      if (_pin2.text.trim() != pin) return _fail('The two PINs don’t match.');
    }

    setState(() {
      _saving = true;
      _error = null;
    });
    final repo = ref.read(servicesProvider).staff;
    try {
      if (pin != null && await repo.pinInUse(pin, exceptId: s?.id)) {
        _pin1.clear();
        _pin2.clear();
        return _fail('That PIN is already used by another active team member. Choose a different one.');
      }
      if (s == null) {
        final created = StaffRepo.build(name: name, role: _role, pin: pin!, color: _color).copyWith(active: _active);
        await repo.save(created);
      } else {
        final updated = s.copyWith(name: name, role: _role.name, color: _color, active: _active);
        if (pin != null) {
          await repo.setPin(updated, pin);
        } else {
          await repo.save(updated);
        }
        // Keep the signed-in session in step when editing yourself.
        if (me?.id == s.id) {
          final fresh = pin != null ? await repo.verify(pin, staffId: s.id) : updated;
          if (fresh != null) ref.read(sessionProvider.notifier).signIn(fresh);
        }
      }
      if (mounted) {
        Navigator.pop(
          context,
          s == null ? '$name added as ${_role.label.toLowerCase()}' : (pin != null ? '$name saved with a new PIN' : '$name saved'),
        );
      }
    } catch (e) {
      _fail('Couldn’t save: $e');
    }
  }

  Future<void> _delete() async {
    final s = _s!;
    final all = ref.read(staffListProvider).value ?? const <StaffMember>[];
    final block = deactivateBlockReason(s, all, ref.read(sessionProvider), deleting: true);
    if (block != null) return _fail(block);
    final ok = await confirm(
      context,
      title: 'Remove ${s.name}?',
      message: '${s.name} won’t be able to sign in on any till. Their past sales and shifts stay in reports.\n\n'
          'Tip: switch them to inactive instead if they might come back.',
      confirmLabel: 'Remove',
      destructive: true,
    );
    if (!ok || !mounted) return;
    try {
      await ref.read(servicesProvider).staff.delete(s);
      if (mounted) Navigator.pop(context, '${s.name} removed');
    } catch (e) {
      _fail('Couldn’t remove: $e');
    }
  }

  String _roleBlurb(PermissionSettings perms) {
    if (_role == Role.owner) return 'Owners can do everything, including staff, permissions and settings.';
    final n = perms.byRole[_role]?.length ?? 0;
    return '${_role.label}s have $n of ${Perm.values.length} permissions. Change them in the Permissions table below.';
  }

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    final me = ref.watch(sessionProvider);
    final perms = ref.watch(settingsValueProvider).permissions;
    final all = ref.watch(staffListProvider).value ?? const <StaffMember>[];
    final s = _s;
    final lastOwner = s != null && isLastActiveOwner(s, all);
    final isMe = s != null && s.id == me?.id;
    final preview = StaffMember(
      id: s?.id ?? '_preview',
      updatedAt: 0,
      deleted: false,
      name: _name.text.trim().isEmpty ? '?' : _name.text.trim(),
      role: _role.name,
      pinHash: '',
      pinSalt: '',
      active: _active,
      color: _color,
    );

    InputDecoration pinDeco(String label) => InputDecoration(
          labelText: label,
          counterText: '',
          prefixIcon: const Icon(Icons.pin_outlined),
          suffixIcon: IconButton(
            tooltip: _showPin ? 'Hide PIN' : 'Show PIN',
            onPressed: () => setState(() => _showPin = !_showPin),
            icon: Icon(_showPin ? Icons.visibility_off_outlined : Icons.visibility_outlined),
          ),
        );
    final pinFormatters = [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)];

    final pin1 = TextField(
      controller: _pin1,
      obscureText: !_showPin,
      keyboardType: TextInputType.number,
      inputFormatters: pinFormatters,
      maxLength: 4,
      autofillHints: const <String>[],
      textInputAction: TextInputAction.next,
      decoration: pinDeco(_isNew ? 'PIN' : 'New PIN'),
      onChanged: (v) {
        if (v.length == 4) _pin2Focus.requestFocus();
      },
    );
    final pin2 = TextField(
      controller: _pin2,
      focusNode: _pin2Focus,
      obscureText: !_showPin,
      keyboardType: TextInputType.number,
      inputFormatters: pinFormatters,
      maxLength: 4,
      textInputAction: TextInputAction.done,
      decoration: pinDeco('Repeat PIN'),
      onSubmitted: (_) => _save(),
    );

    return SaveShortcut(
      onSave: _save,
      child: DialogFrame(
        title: _isNew ? 'Add staff member' : 'Edit staff member',
        subtitle: _isNew ? null : (isMe ? 'This is you' : s!.name),
        icon: Icons.badge_outlined,
        actions: [
          if (!_isNew && !isMe && !lastOwner) DangerTextButton(label: 'Remove', onPressed: _saving ? null : _delete),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(onPressed: _saving ? null : _save, child: Text(_saving ? 'Saving…' : (_isNew ? 'Add staff' : 'Save'))),
        ],
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
          Row(children: [
            StaffAvatar(staff: preview, size: 52),
            const SizedBox(width: Sp.lg),
            Expanded(
              child: TextField(
                controller: _name,
                autofocus: _isNew,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Name', hintText: 'e.g. Ayesha Khan'),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ]),
          const SizedBox(height: Sp.xl),
          const FieldLabel('Role'),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<Role>(
              showSelectedIcon: false,
              segments: [
                for (final r in Role.values)
                  ButtonSegment(
                    value: r,
                    label: Text(r.label, maxLines: 1, overflow: TextOverflow.ellipsis),
                    enabled: lastOwner ? r == Role.owner : (r != Role.owner || isOwner(me) || _role == Role.owner),
                    tooltip: r == Role.owner && !isOwner(me) ? 'Only an owner can make someone an owner' : null,
                  ),
              ],
              selected: {_role},
              onSelectionChanged: (v) => setState(() => _role = v.first),
            ),
          ),
          const SizedBox(height: Sp.sm),
          Text(_roleBlurb(perms), style: context.tt.bodySmall),
          if (lastOwner) ...[
            const SizedBox(height: Sp.sm),
            const InlineNote('This is the only active owner, so the role can’t be changed and they can’t be deactivated.', tone: Tone.info),
          ],
          const SizedBox(height: Sp.xl),
          const FieldLabel('Colour', hint: 'Shown on their avatar on the lock screen.'),
          SwatchPicker(selected: _color, onChanged: (c) => setState(() => _color = c)),
          const SizedBox(height: Sp.lg),
          LabeledSwitch(
            title: 'Active',
            subtitle: isMe ? 'You can’t deactivate yourself.' : 'Inactive staff can’t sign in, but stay in reports.',
            value: _active,
            onChanged: isMe || lastOwner ? null : (v) => setState(() => _active = v),
          ),
          const SizedBox(height: Sp.lg),

          // ── PIN
          FieldLabel(
            'PIN',
            hint: _isNew ? '4 digits, used to sign in and approve actions. Must be different from everyone else’s.' : null,
            trailing: _isNew
                ? null
                : TextButton.icon(
                    onPressed: () => setState(() {
                      _setPin = !_setPin;
                      _pin1.clear();
                      _pin2.clear();
                    }),
                    icon: Icon(_setPin ? Icons.close_rounded : Icons.lock_reset_rounded, size: 18),
                    label: Text(_setPin ? 'Keep current PIN' : 'Reset PIN'),
                  ),
          ),
          if (!_setPin)
            Row(children: [
              Icon(Icons.lock_outline_rounded, size: 18, color: ec.textMuted),
              const SizedBox(width: Sp.sm),
              Expanded(child: Text('PIN is set. Reset it if they’ve forgotten it.', style: context.tt.bodySmall)),
            ])
          else
            LayoutBuilder(builder: (context, c) {
              if (c.maxWidth < 300) {
                return Column(children: [pin1, const SizedBox(height: Sp.md), pin2]);
              }
              return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: pin1),
                const SizedBox(width: Sp.md),
                Expanded(child: pin2),
              ]);
            }),
          if (_error != null) ...[const SizedBox(height: Sp.md), InlineNote(_error!)],
        ]),
      ),
    );
  }
}
