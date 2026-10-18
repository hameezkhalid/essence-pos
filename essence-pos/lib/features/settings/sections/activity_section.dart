import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/providers.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/db/database.dart';
import '../../../core/models/menu_models.dart';
import '../../../core/money.dart';
import '../../../core/tax/tax_engine.dart';
import '../../../shared/common.dart';
import '../settings_widgets.dart';

/// Friendly label, icon and tone for an audit action key.
(String, IconData, Tone) auditStyle(String action) => switch (action) {
      'shiftOpen' => ('Shift opened', Icons.lock_open_rounded, Tone.primary),
      'shiftClose' => ('Shift closed', Icons.lock_clock_outlined, Tone.primary),
      'cashIn' => ('Cash in', Icons.add_card_rounded, Tone.success),
      'cashOut' => ('Cash out', Icons.outbox_rounded, Tone.warning),
      'discount' => ('Discount given', Icons.local_offer_outlined, Tone.accent),
      'discardHeld' => ('Held order discarded', Icons.delete_sweep_outlined, Tone.warning),
      'void' => ('Order voided', Icons.block_rounded, Tone.danger),
      'refund' => ('Refund', Icons.undo_rounded, Tone.danger),
      'drawerOpen' => ('Drawer opened (no sale)', Icons.point_of_sale_rounded, Tone.info),
      _ => (_humanize(action), Icons.history_rounded, Tone.neutral),
    };

String _humanize(String key) {
  final s = key.replaceAllMapped(RegExp(r'(?<=[a-z])([A-Z])'), (m) => ' ${m[1]!.toLowerCase()}');
  return s.isEmpty ? 'Activity' : '${s[0].toUpperCase()}${s.substring(1)}';
}

const _moneyKeys = {'amount', 'total', 'float', 'expected', 'counted'};

/// One-line summary of an audit entry's details.
String auditSummary(String action, Map<String, dynamic> d) {
  final parts = <String>[];
  final order = d['order'];
  if (order is String && order.isNotEmpty) parts.add(order);
  final token = d['token'];
  if (token is num) parts.add('Token #${token.toInt().toString().padLeft(3, '0')}');
  for (final k in _moneyKeys) {
    final v = d[k];
    if (v is num) {
      final label = switch (k) { 'float' => 'Float ', 'expected' => 'Expected ', 'counted' => 'Counted ', _ => '' };
      parts.add('$label${rs(v.toInt())}');
    }
  }
  final diff = d['difference'];
  if (diff is num && diff != 0) parts.add(diff > 0 ? 'Over ${rs(diff.toInt())}' : 'Short ${rs(-diff.toInt())}');
  final od = Discount.fromJson(d['orderDiscount']);
  if (od != null) parts.add(od.label ?? od.display);
  final method = d['method'];
  if (method is String && method.isNotEmpty) parts.add(method);
  final reason = d['reason'];
  if (reason is String && reason.trim().isNotEmpty) parts.add('“${reason.trim()}”');
  return parts.join(' · ');
}

class ActivitySection extends ConsumerStatefulWidget {
  const ActivitySection({super.key});
  @override
  ConsumerState<ActivitySection> createState() => _ActivitySectionState();
}

class _ActivitySectionState extends ConsumerState<ActivitySection> {
  late final Stream<List<AuditLog>> _logs;
  String? _filter;

  @override
  void initState() {
    super.initState();
    _logs = ref.read(servicesProvider).audit.watchRecent();
  }

  static final _day = DateFormat('EEEE, d MMM');
  static final _time = DateFormat('h:mm a');

  String _dayLabel(DateTime t) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(t.year, t.month, t.day);
    final diff = today.difference(d).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return _day.format(t);
  }

  @override
  Widget build(BuildContext context) {
    final terminals = {for (final t in ref.watch(terminalsProvider).value ?? const <Terminal>[]) t.id: t.code};
    return StreamBuilder<List<AuditLog>>(
      stream: _logs,
      builder: (context, snap) {
        final all = snap.data ?? const <AuditLog>[];
        final actions = <String>{for (final l in all) l.action}.toList()..sort((a, b) => auditStyle(a).$1.compareTo(auditStyle(b).$1));
        final filter = actions.contains(_filter) ? _filter : null;
        final logs = filter == null ? all : all.where((l) => l.action == filter).toList();

        final groups = <String, List<AuditLog>>{};
        for (final l in logs) {
          groups.putIfAbsent(_dayLabel(DateTime.fromMillisecondsSinceEpoch(l.createdAt)), () => []).add(l);
        }

        return SettingsScaffold(
          title: 'Activity log',
          subtitle: 'Sensitive actions on every terminal: voids, refunds, discounts, cash and shifts.',
          children: [
            if (actions.isNotEmpty)
              Wrap(spacing: Sp.sm, runSpacing: Sp.sm, children: [
                ChoiceChip(label: Text('All (${all.length})'), selected: filter == null, onSelected: (_) => setState(() => _filter = null)),
                for (final a in actions)
                  ChoiceChip(
                    avatar: Icon(auditStyle(a).$2, size: 16),
                    label: Text(auditStyle(a).$1),
                    selected: filter == a,
                    onSelected: (_) => setState(() => _filter = filter == a ? null : a),
                  ),
              ]),
            if (snap.connectionState == ConnectionState.waiting && all.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.all(Sp.xl), child: CircularProgressIndicator()))
            else if (logs.isEmpty)
              const AppCard(
                child: EmptyState(
                  icon: Icons.history_rounded,
                  title: 'Nothing logged yet',
                  message: 'Voids, refunds, discounts, cash in / out and shift changes will appear here.',
                ),
              )
            else
              for (final e in groups.entries)
                Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Padding(
                    padding: const EdgeInsets.only(left: Sp.xs, bottom: Sp.sm),
                    child: Text(e.key.toUpperCase(), style: context.tt.labelSmall?.copyWith(color: context.ec.textFaint, letterSpacing: 0.8)),
                  ),
                  AppCard(
                    padding: EdgeInsets.zero,
                    child: Column(children: [
                      for (var i = 0; i < e.value.length; i++) ...[
                        if (i > 0) Divider(height: 1, indent: 64, color: context.ec.border),
                        _LogTile(log: e.value[i], time: _time.format(DateTime.fromMillisecondsSinceEpoch(e.value[i].createdAt)), terminal: terminals[e.value[i].deviceId]),
                      ],
                    ]),
                  ),
                ]),
            if (all.length >= 200)
              Text('Showing the latest 200 entries.', style: context.tt.bodySmall, textAlign: TextAlign.center),
          ],
        );
      },
    );
  }
}

class _LogTile extends StatelessWidget {
  const _LogTile({required this.log, required this.time, this.terminal});
  final AuditLog log;
  final String time;
  final String? terminal;

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    final (label, icon, tone) = auditStyle(log.action);
    final (fg, bg) = tone.colors(ec);
    Map<String, dynamic> details;
    try {
      details = decodeMap(log.detailsJson);
    } catch (_) {
      details = const {};
    }
    final summary = auditSummary(log.action, details);
    final who = [
      log.staffName,
      if (log.approvedByName != null && log.approvedByName != log.staffName) 'approved by ${log.approvedByName}',
      ?terminal,
    ].join(' · ');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Sp.lg, vertical: Sp.md),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 18, color: fg),
        ),
        const SizedBox(width: Sp.md),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: Text(label, style: context.tt.titleSmall)),
              const SizedBox(width: Sp.sm),
              Text(time, style: context.tt.labelSmall?.copyWith(fontFeatures: tabular)),
            ]),
            if (summary.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(summary, style: context.tt.bodyMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
              ),
            Padding(padding: const EdgeInsets.only(top: 2), child: Text(who, style: context.tt.bodySmall)),
          ]),
        ),
      ]),
    );
  }
}
