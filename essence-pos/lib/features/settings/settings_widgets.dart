import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderListenable;
import 'package:go_router/go_router.dart';

import '../../app/theme/tokens.dart';
import '../../core/money.dart';
import '../../shared/common.dart';

// ───────────────────────── Number helpers ─────────────────────────

/// Basis points → text for a "%" field: 1500 → "15", 750 → "7.5".
String bpText(int bp) {
  final v = bp / 100;
  if (v == v.roundToDouble()) return '${v.toInt()}';
  return v.toStringAsFixed(2).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
}

/// Typed percentage → basis points ("7.5" → 750). Null when invalid or outside [0, max]%.
int? parseBp(String s, {double max = 100}) {
  final v = double.tryParse(s.trim().replaceAll('%', ''));
  if (v == null || v.isNaN || v < 0 || v > max) return null;
  return (v * 100).round();
}

/// Paisa → text for a rupee field without symbol or separators: 15000 → "150", 150 → "1.5".
String rupeeText(int paisa) {
  if (paisa % 100 == 0) return '${paisa ~/ 100}';
  return (paisa / 100).toStringAsFixed(2).replaceAll(RegExp(r'0+$'), '');
}

/// Input formatter for decimal numbers (digits and one dot).
final decimalInput = <TextInputFormatter>[
  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
  TextInputFormatter.withFunction((o, n) => '.'.allMatches(n.text).length > 1 ? o : n),
];

final digitsInput = <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly];

String? pctValidator(String? v, {bool required = true}) {
  if ((v ?? '').trim().isEmpty) return required ? 'Enter a percentage' : null;
  return parseBp(v!) == null ? 'Enter 0 – 100' : null;
}

String? rupeeValidator(String? v, {bool required = true}) {
  if ((v ?? '').trim().isEmpty) return required ? 'Enter an amount' : null;
  final p = parseRupees(v!);
  return p == null || p < 0 ? 'Enter a valid amount' : null;
}

/// "just now", "3 min ago", "2 h ago", "4 days ago".
String timeAgo(DateTime t, {DateTime? now}) {
  final d = (now ?? DateTime.now()).difference(t);
  if (d.inSeconds < 45) return 'just now';
  if (d.inMinutes < 60) return '${d.inMinutes.clamp(1, 59)} min ago';
  if (d.inHours < 24) return '${d.inHours} h ago';
  if (d.inDays < 30) return '${d.inDays} day${d.inDays == 1 ? '' : 's'} ago';
  return '${(d.inDays / 30).floor()} mo ago';
}

// ───────────────────────── Unsaved-changes tracking ─────────────────────────

/// True while the open settings section has unsaved edits (used to confirm before leaving).
final settingsDirtyProvider = NotifierProvider<SettingsDirty, bool>(SettingsDirty.new);

class SettingsDirty extends Notifier<bool> {
  @override
  bool build() => false;
  void set(bool v) {
    if (state != v) state = v;
  }
}

/// Asks before discarding unsaved edits. Returns true when it is fine to leave.
Future<bool> confirmLeave(BuildContext context, WidgetRef ref) async {
  if (!ref.read(settingsDirtyProvider)) return true;
  final ok = await confirm(
    context,
    title: 'Discard changes?',
    message: 'You have unsaved changes in this section. Leave without saving?',
    confirmLabel: 'Discard',
    destructive: true,
  );
  if (ok) ref.read(settingsDirtyProvider.notifier).set(false);
  return ok;
}

/// Base for a settings form that edits a draft and saves explicitly.
///
/// Subclasses describe the saved values ([savedJson]), the draft ([draftJson]), how to fill
/// the fields ([load]) and how to [persist]. Outside changes (other terminals, sync) are
/// picked up live while the form has no unsaved edits.
abstract class SettingsFormState<W extends ConsumerStatefulWidget> extends ConsumerState<W> {
  final formKey = GlobalKey<FormState>();
  final _ctrls = <TextEditingController>[];
  String _savedSig = '';
  bool _loading = false;
  bool saving = false;
  bool? _reported;
  SettingsDirty? _dirtyNotifier;

  /// Saved values as JSON-able data (read with `ref.read`).
  Object? savedJson();

  /// Draft values as JSON-able data, in the same shape as [savedJson].
  Object? draftJson();

  /// Fills the fields from the saved values (read with `ref.read`).
  void load();

  /// Providers whose changes may change [savedJson].
  List<ProviderListenable<Object?>> get sources;

  /// Writes the draft.
  Future<void> persist();

  /// Extra validation beyond the form fields. Return an error message to block saving.
  String? validate() => null;

  String get savedMessage => 'Settings saved';

  /// A text controller that rebuilds the form when edited and is disposed with it.
  TextEditingController ctrl([String text = '']) {
    final c = TextEditingController(text: text);
    c.addListener(() {
      if (!_loading && mounted) setState(() {});
    });
    _ctrls.add(c);
    return c;
  }

  /// Sets a controller's text without triggering a rebuild loop.
  void setText(TextEditingController c, String text) {
    if (c.text != text) c.text = text;
  }

  static String _sig(Object? o) => jsonEncode(o);

  bool get dirty => _sig(draftJson()) != _savedSig;

  @override
  void initState() {
    super.initState();
    _dirtyNotifier = ref.read(settingsDirtyProvider.notifier);
    _reload();
    for (final s in sources) {
      ref.listenManual<Object?>(s, (_, _) => _onSaved());
    }
  }

  /// Bumped every time the fields are (re)loaded; use in keys of fields that only read an initial value.
  int loadGen = 0;

  void _reload() {
    loadGen++;
    _loading = true;
    try {
      load();
    } finally {
      _loading = false;
    }
    _savedSig = _sig(savedJson());
  }

  void _onSaved() {
    // Provider listeners can fire while another widget is building; apply after the frame then.
    if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.persistentCallbacks) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _applySaved());
    } else {
      _applySaved();
    }
  }

  void _applySaved() {
    if (!mounted) return;
    final s = _sig(savedJson());
    if (s == _savedSig) return;
    if (dirty) {
      _savedSig = s;
    } else {
      _reload();
    }
    setState(() {});
  }

  void discard() {
    setState(_reload);
  }

  Future<void> save() async {
    if (saving || !dirty) return;
    if (formKey.currentState?.validate() == false) {
      toast(context, 'Please fix the highlighted fields', error: true);
      return;
    }
    final err = validate();
    if (err != null) {
      toast(context, err, error: true);
      return;
    }
    setState(() => saving = true);
    try {
      final sig = _sig(draftJson());
      await persist();
      _savedSig = sig;
      if (mounted) toast(context, savedMessage);
    } catch (e) {
      if (mounted) toast(context, 'Could not save: $e', error: true);
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  void _report(bool d) {
    if (_reported == d) return;
    _reported = d;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        _dirtyNotifier?.set(d);
      } catch (_) {}
    });
  }

  /// The pinned footer with Discard / Save. Call from build.
  Widget saveBar() {
    final d = dirty;
    _report(d);
    return SaveBar(dirty: d, saving: saving, onSave: save, onDiscard: discard);
  }

  @override
  void dispose() {
    for (final c in _ctrls) {
      c.dispose();
    }
    if (_reported == true) {
      final n = _dirtyNotifier;
      scheduleMicrotask(() {
        try {
          n?.set(false);
        } catch (_) {}
      });
    }
    super.dispose();
  }
}

// ───────────────────────── Layout ─────────────────────────

const settingsMaxWidth = 760.0;

/// Scrollable section body with a title, max content width and an optional pinned footer.
class SettingsScaffold extends StatelessWidget {
  const SettingsScaffold({
    super.key,
    required this.title,
    this.subtitle,
    required this.children,
    this.footer,
    this.onSave,
    this.actions = const [],
    this.formKey,
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;
  final Widget? footer;

  /// Ctrl/⌘+S saves.
  final VoidCallback? onSave;
  final List<Widget> actions;
  final GlobalKey<FormState>? formKey;

  @override
  Widget build(BuildContext context) {
    final pad = context.isPhone ? Sp.lg : Sp.xl;
    Widget body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!context.isPhone) PageTitle(title, subtitle: subtitle, actions: actions),
        if (context.isPhone && (subtitle != null || actions.isNotEmpty))
          Padding(
            padding: const EdgeInsets.only(bottom: Sp.lg),
            child: Wrap(
              spacing: Sp.sm,
              runSpacing: Sp.sm,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (subtitle != null) Text(subtitle!, style: context.tt.bodyMedium?.copyWith(color: context.ec.textMuted)),
                ...actions,
              ],
            ),
          ),
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(height: Sp.lg),
          children[i],
        ],
      ],
    );
    if (formKey != null) body = Form(key: formKey, child: body);
    Widget scroll = SingleChildScrollView(
      padding: EdgeInsets.all(pad),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: settingsMaxWidth), child: body),
      ),
    );
    if (footer != null) {
      scroll = Column(children: [
        Expanded(child: scroll),
        footer!,
      ]);
    }
    if (onSave != null) {
      scroll = CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.keyS, control: true): onSave!,
          const SingleActivator(LogicalKeyboardKey.keyS, meta: true): onSave!,
        },
        child: FocusTraversalGroup(child: scroll),
      );
    }
    return scroll;
  }
}

/// Footer with the unsaved-changes state and Discard / Save buttons.
class SaveBar extends StatelessWidget {
  const SaveBar({super.key, required this.dirty, required this.saving, required this.onSave, required this.onDiscard});
  final bool dirty;
  final bool saving;
  final VoidCallback onSave;
  final VoidCallback onDiscard;

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    final pad = context.isPhone ? Sp.lg : Sp.xl;
    return Container(
      decoration: BoxDecoration(color: ec.surface, border: Border(top: BorderSide(color: ec.border))),
      padding: EdgeInsets.symmetric(horizontal: pad, vertical: Sp.md),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: settingsMaxWidth),
          child: Row(children: [
            Icon(
              dirty ? Icons.edit_note_rounded : Icons.check_circle_outline_rounded,
              size: 20,
              color: dirty ? ec.warning : ec.success,
            ),
            const SizedBox(width: Sp.sm),
            Expanded(
              child: Text(
                dirty ? 'Unsaved changes' : 'All changes saved',
                style: context.tt.bodyMedium?.copyWith(color: dirty ? ec.text : ec.textMuted),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (dirty) ...[
              TextButton(onPressed: saving ? null : onDiscard, child: const Text('Discard')),
              const SizedBox(width: Sp.xs),
            ],
            FilledButton.icon(
              onPressed: dirty && !saving ? onSave : null,
              icon: saving
                  ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: ec.onPrimary))
                  : const Icon(Icons.save_outlined, size: 18),
              label: const Text('Save'),
            ),
          ]),
        ),
      ),
    );
  }
}

/// A card with an optional heading.
class SettingsCard extends StatelessWidget {
  const SettingsCard({super.key, this.title, this.subtitle, this.trailing, this.icon, required this.children, this.padding});
  final String? title;
  final String? subtitle;
  final Widget? trailing;
  final IconData? icon;
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    return AppCard(
      padding: padding ?? EdgeInsets.all(context.isPhone ? Sp.lg : Sp.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.only(bottom: Sp.md),
              child: Row(children: [
                if (icon != null) ...[
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(color: ec.primaryContainer, borderRadius: BorderRadius.circular(10)),
                    child: Icon(icon, size: 18, color: ec.onPrimaryContainer),
                  ),
                  const SizedBox(width: Sp.md),
                ],
                Expanded(child: SectionHeader(title!, subtitle: subtitle, padding: EdgeInsets.zero)),
                if (trailing != null) ...[const SizedBox(width: Sp.sm), trailing!],
              ]),
            ),
          ...children,
        ],
      ),
    );
  }
}

/// Lays out fields side by side when there is room, stacked otherwise.
class FieldRow extends StatelessWidget {
  const FieldRow({super.key, required this.children, this.breakpoint = 480, this.flex});
  final List<Widget> children;
  final double breakpoint;
  final List<int>? flex;

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, c) {
        if (c.maxWidth < breakpoint) {
          return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            for (var i = 0; i < children.length; i++) ...[if (i > 0) const SizedBox(height: Sp.md), children[i]],
          ]);
        }
        return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(width: Sp.md),
            Expanded(flex: flex?[i] ?? 1, child: children[i]),
          ],
        ]);
      });
}

/// Vertical gap between fields.
const fieldGap = SizedBox(height: Sp.md);

/// A coloured information strip.
class InfoBanner extends StatelessWidget {
  const InfoBanner(this.text, {super.key, this.tone = Tone.info, this.icon, this.title, this.action});
  final String text;
  final String? title;
  final Tone tone;
  final IconData? icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final (fg, bg) = tone.colors(context.ec);
    return Container(
      padding: const EdgeInsets.all(Sp.md),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(Rad.md)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon ?? Icons.info_outline_rounded, size: 20, color: fg),
        const SizedBox(width: Sp.md),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (title != null) Text(title!, style: context.tt.titleSmall?.copyWith(color: fg)),
            Text(text, style: context.tt.bodySmall?.copyWith(color: context.ec.text)),
            if (action != null) Padding(padding: const EdgeInsets.only(top: Sp.sm), child: action),
          ]),
        ),
      ]),
    );
  }
}

/// A segmented choice that falls back to a vertical list when there isn't room.
class Segments<T> extends StatelessWidget {
  const Segments({
    super.key,
    required this.values,
    required this.selected,
    required this.label,
    required this.onChanged,
    this.icon,
    this.minWidth = 360,
    this.enabled = true,
  });

  final List<T> values;
  final T selected;
  final String Function(T) label;
  final IconData Function(T)? icon;
  final ValueChanged<T> onChanged;

  /// Below this width the options stack vertically.
  final double minWidth;
  final bool enabled;

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, c) {
        if (c.maxWidth >= minWidth) {
          return SizedBox(
            width: double.infinity,
            child: SegmentedButton<T>(
              showSelectedIcon: icon == null,
              segments: [
                for (final v in values) ButtonSegment<T>(value: v, label: Text(label(v), overflow: TextOverflow.ellipsis), icon: icon == null ? null : Icon(icon!(v))),
              ],
              selected: {selected},
              onSelectionChanged: enabled ? (s) => onChanged(s.first) : null,
            ),
          );
        }
        final ec = context.ec;
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          for (final v in values)
            Padding(
              padding: const EdgeInsets.only(bottom: Sp.xs),
              child: Material(
                color: v == selected ? ec.primaryContainer : ec.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Rad.md),
                  side: BorderSide(color: v == selected ? ec.primary : ec.border),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(Rad.md),
                  onTap: enabled ? () => onChanged(v) : null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Sp.md, vertical: Sp.md),
                    child: Row(children: [
                      Icon(
                        v == selected ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded,
                        size: 20,
                        color: v == selected ? ec.primary : ec.textFaint,
                      ),
                      const SizedBox(width: Sp.md),
                      if (icon != null) ...[Icon(icon!(v), size: 18, color: ec.textMuted), const SizedBox(width: Sp.sm)],
                      Expanded(child: Text(label(v), style: context.tt.labelLarge)),
                    ]),
                  ),
                ),
              ),
            ),
        ]);
      });
}

/// Shown instead of a section the signed-in staff member can't open.
class LockedSection extends StatelessWidget {
  const LockedSection({super.key, required this.title});
  final String title;
  @override
  Widget build(BuildContext context) => EmptyState(
        icon: Icons.lock_outline_rounded,
        title: '$title is locked',
        message: 'Your role doesn’t have permission to change this. Ask the owner or a manager.',
      );
}

/// Header shown above a section page on phones, with a back button to the section list.
class PhoneSectionHeader extends ConsumerWidget {
  const PhoneSectionHeader({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ec = context.ec;
    return Container(
      decoration: BoxDecoration(color: ec.bg, border: Border(bottom: BorderSide(color: ec.border))),
      padding: const EdgeInsets.fromLTRB(Sp.xs, Sp.xs, Sp.lg, Sp.xs),
      child: Row(children: [
        IconButton(
          tooltip: 'Back to settings',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () async {
            if (await confirmLeave(context, ref) && context.mounted) context.go('/settings');
          },
        ),
        const SizedBox(width: Sp.xs),
        Expanded(child: Text(title, style: context.tt.headlineSmall, overflow: TextOverflow.ellipsis)),
      ]),
    );
  }
}

/// Small key/value row used in status cards.
class InfoRow extends StatelessWidget {
  const InfoRow(this.label, this.value, {super.key, this.valueColor, this.trailing});
  final String label;
  final String value;
  final Color? valueColor;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(flex: 2, child: Text(label, style: context.tt.bodyMedium?.copyWith(color: context.ec.textMuted))),
          const SizedBox(width: Sp.md),
          Expanded(
            flex: 3,
            child: Text(value, textAlign: TextAlign.right, style: context.tt.titleSmall?.copyWith(color: valueColor, fontFeatures: tabular)),
          ),
          if (trailing != null) ...[const SizedBox(width: Sp.sm), trailing!],
        ]),
      );
}

/// Primary/secondary action buttons for dialogs.
List<Widget> dialogActions(BuildContext context, {required String saveLabel, required VoidCallback? onSave, Widget? leading}) => [
      ?leading,
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
      FilledButton(onPressed: onSave, child: Text(saveLabel)),
    ];
