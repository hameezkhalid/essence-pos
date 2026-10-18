import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/providers.dart';
import '../../app/theme/tokens.dart';
import '../../core/db/database.dart';
import '../../core/models/settings_models.dart';
import '../../shared/common.dart';
import '../../shared/keypads.dart';
import '../shell/status_widgets.dart';

/// Staff sign-in: pick your name (or just type your PIN).
class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});
  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  StaffMember? _selected;
  late Timer _clock;
  DateTime _now = DateTime.now();
  bool _demo = false;

  @override
  void initState() {
    super.initState();
    _clock = Timer.periodic(const Duration(seconds: 15), (_) => setState(() => _now = DateTime.now()));
    ref.read(dbProvider).getMeta('demo.seeded').then((v) {
      if (mounted) setState(() => _demo = v == 'true');
    });
  }

  @override
  void dispose() {
    _clock.cancel();
    super.dispose();
  }

  Future<bool> _try(String pin) async {
    final s = await ref.read(servicesProvider).staff.verify(pin, staffId: _selected?.id);
    if (s == null) return false;
    ref.read(sessionProvider.notifier).signIn(s);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    final staff = (ref.watch(staffListProvider).value ?? const []).where((s) => s.active).toList();
    final store = ref.watch(settingsValueProvider).store;
    final wide = context.screenW >= 900;

    final left = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: wide ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        EssenceLogo(size: wide ? 132 : 96),
        const SizedBox(height: Sp.xl),
        Text(DateFormat('h:mm').format(_now), style: context.tt.displayLarge?.copyWith(fontSize: wide ? 64 : 48, fontFeatures: tabular)),
        Text(DateFormat('EEEE, d MMMM').format(_now), style: context.tt.titleMedium?.copyWith(color: ec.textMuted)),
        const SizedBox(height: Sp.lg),
        Text('${store.name} · ${ref.watch(servicesProvider).device.name}', style: context.tt.bodyMedium?.copyWith(color: ec.textMuted)),
        const SizedBox(height: Sp.md),
        const SyncPill(),
      ],
    );

    final right = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: AppCard(
        padding: const EdgeInsets.all(Sp.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_selected == null ? 'Who’s on the till?' : 'Hi ${_selected!.name.split(' ').first}', style: context.tt.headlineSmall),
            const SizedBox(height: 4),
            Text(_selected == null ? 'Tap your name or type your PIN' : 'Enter your 4-digit PIN', style: context.tt.bodySmall),
            const SizedBox(height: Sp.lg),
            if (staff.isNotEmpty)
              Wrap(
                alignment: WrapAlignment.center,
                spacing: Sp.sm,
                runSpacing: Sp.sm,
                children: [
                  for (final s in staff)
                    _StaffChip(
                      staff: s,
                      selected: _selected?.id == s.id,
                      onTap: () => setState(() => _selected = _selected?.id == s.id ? null : s),
                    ),
                ],
              ),
            const SizedBox(height: Sp.lg),
            PinPad(key: ValueKey(_selected?.id), onComplete: _try),
            if (_demo)
              Padding(
                padding: const EdgeInsets.only(top: Sp.sm),
                child: Pill('Demo PINs · Owner 1111 · Manager 2222 · Cashier 3333', tone: Tone.info, icon: Icons.info_outline_rounded, dense: true),
              ),
          ],
        ),
      ),
    );

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(Sp.xl),
            child: wide
                ? Row(mainAxisSize: MainAxisSize.min, children: [left, const SizedBox(width: 96), right])
                : Column(children: [left, const SizedBox(height: Sp.xl), right]),
          ),
        ),
      ),
    );
  }
}

class _StaffChip extends StatelessWidget {
  const _StaffChip({required this.staff, required this.selected, required this.onTap});
  final StaffMember staff;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    return Material(
      color: selected ? ec.primaryContainer : ec.surfaceAlt,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Rad.md), side: BorderSide(color: selected ? ec.primary : ec.border)),
      child: InkWell(
        borderRadius: BorderRadius.circular(Rad.md),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 14, 8),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            StaffAvatar(staff: staff, size: 34),
            const SizedBox(width: Sp.sm),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(staff.name, style: context.tt.titleSmall),
              Text(Role.parse(staff.role).label, style: context.tt.labelSmall),
            ]),
          ]),
        ),
      ),
    );
  }
}

class StaffAvatar extends StatelessWidget {
  const StaffAvatar({super.key, required this.staff, this.size = 36});
  final StaffMember staff;
  final double size;
  @override
  Widget build(BuildContext context) {
    final initials = staff.name.trim().split(RegExp(r'\s+')).take(2).map((p) => p.isEmpty ? '' : p[0].toUpperCase()).join();
    final color = Color(staff.color);
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: color,
      child: Text(initials, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: size * 0.36)),
    );
  }
}
