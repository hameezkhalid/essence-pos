import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/theme/icons.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/money.dart';
import '../../../shared/common.dart';

// Small building blocks shared by the Menu and Staff settings panes.

/// Paisa → editable rupee text ("1850", "1850.50", "-100").
String rupeesInput(int paisa) => paisa % 100 == 0 ? '${paisa ~/ 100}' : (paisa / 100).toStringAsFixed(2);

/// Parses a signed rupee amount ("+150", "-100", "−100") into paisa. Empty → 0, invalid → null.
int? parseSignedRupees(String input) {
  final t = input.replaceAll('−', '-').replaceAll('+', '').replaceAll(' ', '').trim();
  if (t.isEmpty || t == '-') return 0;
  return parseRupees(t);
}

/// "+Rs 150", "−Rs 100", "Rs 0".
String signedRs(int paisa) => paisa > 0 ? '+${rs(paisa)}' : rs(paisa);

/// Quantity text without trailing zeros ("200", "12.5").
String qtyInput(double q) {
  if (q == 0) return '';
  if (q == q.roundToDouble()) return q.toInt().toString();
  return q.toStringAsFixed(2).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
}

final moneyFormatters = <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))];
final signedMoneyFormatters = <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp(r'[0-9.,+\-−]'))];
final qtyFormatters = <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))];

/// Runs a write, toasting [success] or the error. Returns true when it worked.
Future<bool> guardedWrite(BuildContext context, Future<void> Function() write, {String? success}) async {
  try {
    await write();
    if (success != null && context.mounted) toast(context, success);
    return true;
  } catch (e) {
    if (context.mounted) toast(context, 'Couldn’t save: $e', error: true);
    return false;
  }
}

/// Ctrl/Cmd + Enter triggers [onSave] anywhere inside [child].
class SaveShortcut extends StatelessWidget {
  const SaveShortcut({super.key, required this.onSave, required this.child});
  final VoidCallback onSave;
  final Widget child;

  @override
  Widget build(BuildContext context) => CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.enter, control: true): onSave,
          const SingleActivator(LogicalKeyboardKey.enter, meta: true): onSave,
          const SingleActivator(LogicalKeyboardKey.keyS, control: true): onSave,
          const SingleActivator(LogicalKeyboardKey.keyS, meta: true): onSave,
        },
        child: child,
      );
}

/// Small muted heading above a group of fields in a dialog.
class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key, this.hint, this.trailing});
  final String text;
  final String? hint;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: Sp.sm),
        child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(text, style: context.tt.titleSmall),
              if (hint != null) Padding(padding: const EdgeInsets.only(top: 2), child: Text(hint!, style: context.tt.bodySmall)),
            ]),
          ),
          ?trailing,
        ]),
      );
}

/// Inline error / info banner used inside dialogs.
class InlineNote extends StatelessWidget {
  const InlineNote(this.text, {super.key, this.tone = Tone.danger, this.icon});
  final String text;
  final Tone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final (fg, bg) = tone.colors(context.ec);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: Sp.md, vertical: Sp.sm + 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(Rad.sm)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon ?? (tone == Tone.danger ? Icons.error_outline_rounded : Icons.info_outline_rounded), size: 18, color: fg),
        const SizedBox(width: Sp.sm),
        Expanded(child: Text(text, style: context.tt.bodySmall?.copyWith(color: fg, fontWeight: FontWeight.w500))),
      ]),
    );
  }
}

/// Grid of selectable icons (stored as icon keys).
class IconPickerGrid extends StatelessWidget {
  const IconPickerGrid({super.key, required this.selected, required this.onChanged, required this.color, this.keys = menuIconKeys});
  final String selected;
  final ValueChanged<String> onChanged;
  final int color;
  final List<String> keys;

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final k in keys)
          Semantics(
            selected: k == selected,
            button: true,
            label: 'Icon $k',
            child: Tooltip(
              message: k,
              waitDuration: const Duration(milliseconds: 600),
              child: Material(
                color: k == selected ? ec.primaryContainer : ec.surfaceAlt,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Rad.sm),
                  side: BorderSide(color: k == selected ? ec.primary : Colors.transparent, width: 1.6),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(Rad.sm),
                  onTap: () => onChanged(k),
                  child: SizedBox(
                    width: 44,
                    height: 44,
                    child: Icon(iconFor(k), size: 22, color: k == selected ? ec.onPrimaryContainer : ec.textMuted),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Row of colour swatches.
class SwatchPicker extends StatelessWidget {
  const SwatchPicker({super.key, required this.selected, required this.onChanged, this.colors = swatches});
  final int selected;
  final ValueChanged<int> onChanged;
  final List<int> colors;

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        for (final c in colors)
          Semantics(
            selected: c == selected,
            button: true,
            label: 'Colour #${(c & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}',
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => onChanged(c),
              child: SizedBox(
                width: 44,
                height: 44,
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 140),
                    width: c == selected ? 34 : 30,
                    height: c == selected ? 34 : 30,
                    decoration: BoxDecoration(
                      color: Color(c),
                      shape: BoxShape.circle,
                      border: Border.all(color: c == selected ? ec.text : ec.border, width: c == selected ? 2.4 : 1),
                    ),
                    child: c == selected ? const Icon(Icons.check_rounded, size: 18, color: Colors.white) : null,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Look-alike of the Sell screen tile, used as a live preview in editors.
class MenuTilePreview extends StatelessWidget {
  const MenuTilePreview({super.key, required this.icon, required this.color, required this.title, this.subtitle, this.dimmed = false, this.badge});
  final String icon;
  final int color;
  final String title;
  final String? subtitle;
  final bool dimmed;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    return Opacity(
      opacity: dimmed ? 0.55 : 1,
      child: Container(
        width: 150,
        constraints: const BoxConstraints(minHeight: 132),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: ec.surface,
          borderRadius: BorderRadius.circular(Rad.lg),
          border: Border.all(color: ec.border),
          boxShadow: [BoxShadow(color: ec.shadow, blurRadius: 14, offset: const Offset(0, 4))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            IconBadge(icon: iconFor(icon), color: Color(color), size: 44),
            const Spacer(),
            if (badge != null) Flexible(child: FittedBox(fit: BoxFit.scaleDown, child: Pill(badge!, tone: Tone.warning, dense: true))),
          ]),
          const SizedBox(height: 22),
          Text(
            title.isEmpty ? 'Name' : title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.tt.titleSmall?.copyWith(height: 1.2, fontSize: 14, color: title.isEmpty ? ec.textFaint : null),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 3),
            Text(subtitle!, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.tt.labelMedium?.copyWith(color: ec.accent, fontFeatures: tabular)),
          ],
        ]),
      ),
    );
  }
}

/// Compact label + switch, for list rows.
class InlineSwitch extends StatelessWidget {
  const InlineSwitch({super.key, required this.label, required this.value, required this.onChanged, this.warn = false, this.vertical = false});
  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;

  /// Uses the warning colour when on (e.g. "Sold out").
  final bool warn;
  final bool vertical;

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    final sw = Semantics(
      label: label,
      child: Switch(
        value: value,
        onChanged: onChanged,
        activeTrackColor: warn ? ec.warning : null,
        trackOutlineColor: warn
            ? WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? ec.warning : ec.border)
            : null,
      ),
    );
    final text = Text(label, style: context.tt.labelSmall?.copyWith(color: value && warn ? ec.warning : ec.textMuted));
    if (vertical) {
      return Column(mainAxisSize: MainAxisSize.min, children: [text, sw]);
    }
    return InkWell(
      borderRadius: BorderRadius.circular(Rad.sm),
      onTap: onChanged == null ? null : () => onChanged!(!value),
      child: Padding(
        padding: const EdgeInsets.only(left: Sp.sm),
        child: Row(mainAxisSize: MainAxisSize.min, children: [text, const SizedBox(width: 2), sw]),
      ),
    );
  }
}

/// Note shown when the signed-in user can only view a pane.
class ViewOnlyNote extends StatelessWidget {
  const ViewOnlyNote(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: Sp.md),
        child: InlineNote(text, tone: Tone.info, icon: Icons.lock_outline_rounded),
      );
}

/// Loading placeholder sized for embedded panes.
class PaneLoading extends StatelessWidget {
  const PaneLoading({super.key});
  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.all(Sp.xxl),
        child: Center(child: SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 2.6))),
      );
}

/// Destructive text button for dialog actions.
class DangerTextButton extends StatelessWidget {
  const DangerTextButton({super.key, required this.label, required this.onPressed, this.icon = Icons.delete_outline_rounded});
  final String label;
  final VoidCallback? onPressed;
  final IconData icon;
  @override
  Widget build(BuildContext context) => TextButton.icon(
        style: TextButton.styleFrom(foregroundColor: context.ec.danger),
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
      );
}

/// Thin divider for rows inside an [AppCard] with zero padding.
class RowDivider extends StatelessWidget {
  const RowDivider({super.key, this.indent = Sp.lg});
  final double indent;
  @override
  Widget build(BuildContext context) => Divider(height: 1, indent: indent, endIndent: 0, color: context.ec.border);
}
