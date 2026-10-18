import 'package:flutter/material.dart';

import '../app/theme/tokens.dart';

class EssenceLogo extends StatelessWidget {
  const EssenceLogo({super.key, this.size = 40});
  final double size;
  @override
  Widget build(BuildContext context) => Image.asset(
        'assets/images/logo.png',
        width: size,
        height: size,
        filterQuality: FilterQuality.medium,
        semanticLabel: 'Essence',
      );
}

/// Surface panel with the standard border and radius.
class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.padding = const EdgeInsets.all(Sp.lg), this.color, this.onTap, this.radius = Rad.lg, this.borderColor});
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final VoidCallback? onTap;
  final double radius;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    return Material(
      color: color ?? ec.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius), side: BorderSide(color: borderColor ?? ec.border)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(onTap: onTap, child: Padding(padding: padding, child: child)),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.subtitle, this.trailing, this.padding = const EdgeInsets.only(bottom: Sp.md)});
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => Padding(
        padding: padding,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: context.tt.titleMedium),
                  if (subtitle != null) Padding(padding: const EdgeInsets.only(top: 2), child: Text(subtitle!, style: context.tt.bodySmall)),
                ],
              ),
            ),
            ?trailing,
          ],
        ),
      );
}

/// Page title used at the top of each screen.
class PageTitle extends StatelessWidget {
  const PageTitle(this.title, {super.key, this.subtitle, this.actions = const []});
  final String title;
  final String? subtitle;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, Sp.lg),
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: Sp.md,
          runSpacing: Sp.md,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: context.tt.headlineMedium),
                if (subtitle != null) Padding(padding: const EdgeInsets.only(top: 4), child: Text(subtitle!, style: context.tt.bodyMedium?.copyWith(color: context.ec.textMuted))),
              ],
            ),
            if (actions.isNotEmpty) Wrap(spacing: Sp.sm, runSpacing: Sp.sm, children: actions),
          ],
        ),
      );
}

enum Tone { neutral, primary, success, warning, danger, info, accent }

extension ToneColors on Tone {
  (Color fg, Color bg) colors(EssenceColors ec) => switch (this) {
        Tone.neutral => (ec.textMuted, ec.surfaceAlt),
        Tone.primary => (ec.onPrimaryContainer, ec.primaryContainer),
        Tone.success => (ec.success, ec.successContainer),
        Tone.warning => (ec.warning, ec.warningContainer),
        Tone.danger => (ec.danger, ec.dangerContainer),
        Tone.info => (ec.info, ec.infoContainer),
        Tone.accent => (ec.accent, ec.accentContainer),
      };
}

class Pill extends StatelessWidget {
  const Pill(this.text, {super.key, this.tone = Tone.neutral, this.icon, this.dense = false});
  final String text;
  final Tone tone;
  final IconData? icon;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final (fg, bg) = tone.colors(context.ec);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: dense ? 7 : 10, vertical: dense ? 3 : 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: dense ? 12 : 14, color: fg), SizedBox(width: dense ? 3 : 5)],
          Text(text, style: (dense ? context.tt.labelSmall : context.tt.labelMedium)?.copyWith(color: fg, letterSpacing: 0.1)),
        ],
      ),
    );
  }
}

class KpiTile extends StatelessWidget {
  const KpiTile({super.key, required this.label, required this.value, this.icon, this.caption, this.tone = Tone.primary, this.captionTone});
  final String label;
  final String value;
  final IconData? icon;
  final String? caption;
  final Tone tone;
  final Tone? captionTone;

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    final (fg, bg) = tone.colors(ec);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(children: [
            if (icon != null)
              Container(
                width: 32,
                height: 32,
                margin: const EdgeInsets.only(right: Sp.sm),
                decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, size: 18, color: fg),
              ),
            Expanded(child: Text(label.toUpperCase(), style: context.tt.labelSmall, maxLines: 1, overflow: TextOverflow.ellipsis)),
          ]),
          const SizedBox(height: Sp.md),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: context.tt.headlineMedium?.copyWith(fontFeatures: tabular)),
          ),
          if (caption != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                caption!,
                style: context.tt.bodySmall?.copyWith(color: captionTone == null ? ec.textMuted : captionTone!.colors(ec).$1, fontWeight: captionTone == null ? null : FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, this.message, this.action});
  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(Sp.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(color: context.ec.beige, shape: BoxShape.circle),
                child: Icon(icon, size: 30, color: context.ec.accent),
              ),
              const SizedBox(height: Sp.lg),
              Text(title, style: context.tt.titleMedium, textAlign: TextAlign.center),
              if (message != null)
                Padding(
                  padding: const EdgeInsets.only(top: Sp.xs),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 320),
                    child: Text(message!, style: context.tt.bodyMedium?.copyWith(color: context.ec.textMuted), textAlign: TextAlign.center),
                  ),
                ),
              if (action != null) Padding(padding: const EdgeInsets.only(top: Sp.lg), child: action),
            ],
          ),
        ),
      );
}

/// Snackbar helper.
void toast(BuildContext context, String message, {bool error = false, IconData? icon, SnackBarAction? action, Duration? duration}) {
  final ec = context.ec;
  final m = ScaffoldMessenger.maybeOf(context);
  if (m == null) return;
  m.hideCurrentSnackBar();
  m.showSnackBar(SnackBar(
    duration: duration ?? Duration(milliseconds: error ? 5000 : 2600),
    backgroundColor: error ? ec.danger : ec.text,
    action: action,
    content: Row(children: [
      Icon(icon ?? (error ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded), color: ec.bg, size: 20),
      const SizedBox(width: Sp.md),
      Expanded(child: Text(message, style: TextStyle(color: ec.bg))),
    ]),
  ));
}

Future<bool> confirm(
  BuildContext context, {
  required String title,
  String? message,
  String confirmLabel = 'Confirm',
  bool destructive = false,
}) async {
  final ec = context.ec;
  final r = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: message == null ? null : ConstrainedBox(constraints: const BoxConstraints(maxWidth: 420), child: Text(message)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
        FilledButton(
          style: destructive ? FilledButton.styleFrom(backgroundColor: ec.danger, foregroundColor: Colors.white) : null,
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return r ?? false;
}

/// Shows [child] as a centred dialog on wide screens and a full-height sheet on phones.
Future<T?> showAdaptive<T>(BuildContext context, {required Widget Function(BuildContext) builder, double maxWidth = 560, bool dismissible = true}) {
  if (context.isPhone) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      isDismissible: dismissible,
      enableDrag: dismissible,
      builder: (ctx) => Padding(padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom), child: builder(ctx)),
    );
  }
  return showDialog<T>(
    context: context,
    barrierDismissible: dismissible,
    builder: (ctx) => Dialog(
      insetPadding: const EdgeInsets.all(Sp.xl),
      child: ConstrainedBox(constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: MediaQuery.sizeOf(ctx).height * 0.9), child: builder(ctx)),
    ),
  );
}

/// Standard dialog body: title row, scrollable content, actions.
class DialogFrame extends StatelessWidget {
  const DialogFrame({super.key, required this.title, required this.child, this.actions = const [], this.subtitle, this.scroll = true, this.icon});
  final String title;
  final String? subtitle;
  final Widget child;
  final List<Widget> actions;
  final bool scroll;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final body = Padding(padding: const EdgeInsets.symmetric(horizontal: Sp.xl), child: child);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(Sp.xl, context.isPhone ? 0 : Sp.xl, Sp.md, Sp.lg),
          child: Row(children: [
            if (icon != null)
              Container(
                width: 40,
                height: 40,
                margin: const EdgeInsets.only(right: Sp.md),
                decoration: BoxDecoration(color: context.ec.primaryContainer, borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: context.ec.onPrimaryContainer, size: 22),
              ),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: context.tt.headlineSmall),
                if (subtitle != null) Text(subtitle!, style: context.tt.bodySmall),
              ]),
            ),
            if (!context.isPhone) IconButton(onPressed: () => Navigator.maybePop(context), icon: const Icon(Icons.close_rounded), tooltip: 'Close'),
          ]),
        ),
        Flexible(child: scroll ? SingleChildScrollView(child: body) : body),
        if (actions.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(Sp.xl, Sp.lg, Sp.xl, Sp.xl),
            child: Wrap(alignment: WrapAlignment.end, spacing: Sp.sm, runSpacing: Sp.sm, children: actions),
          )
        else
          const SizedBox(height: Sp.xl),
      ],
    );
  }
}

class LabeledSwitch extends StatelessWidget {
  const LabeledSwitch({super.key, required this.title, this.subtitle, required this.value, required this.onChanged});
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) => InkWell(
        borderRadius: BorderRadius.circular(Rad.md),
        onTap: onChanged == null ? null : () => onChanged!(!value),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: Sp.sm),
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: context.tt.titleSmall),
                if (subtitle != null) Padding(padding: const EdgeInsets.only(top: 2), child: Text(subtitle!, style: context.tt.bodySmall)),
              ]),
            ),
            const SizedBox(width: Sp.md),
            Switch(value: value, onChanged: onChanged),
          ]),
        ),
      );
}

class QtyStepper extends StatelessWidget {
  const QtyStepper({super.key, required this.value, required this.onChanged, this.min = 0, this.max = 999, this.compact = false});
  final int value;
  final ValueChanged<int> onChanged;
  final int min, max;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    final s = compact ? 30.0 : 40.0;
    Widget btn(IconData i, VoidCallback? f, String tip) => SizedBox(
          width: s,
          height: s,
          child: IconButton(
            tooltip: tip,
            padding: EdgeInsets.zero,
            style: IconButton.styleFrom(backgroundColor: ec.surfaceAlt, minimumSize: Size(s, s), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: f,
            icon: Icon(i, size: compact ? 16 : 20, color: ec.text),
          ),
        );
    return Row(mainAxisSize: MainAxisSize.min, children: [
      btn(Icons.remove_rounded, value > min ? () => onChanged(value - 1) : null, 'Less'),
      SizedBox(width: compact ? 30 : 40, child: Text('$value', textAlign: TextAlign.center, style: context.tt.titleMedium?.copyWith(fontFeatures: tabular))),
      btn(Icons.add_rounded, value < max ? () => onChanged(value + 1) : null, 'More'),
    ]);
  }
}

/// Square tile with an icon on a tinted background (products, categories, stock).
class IconBadge extends StatelessWidget {
  const IconBadge({super.key, required this.icon, required this.color, this.size = 40});
  final IconData icon;
  final Color color;
  final double size;
  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: dark ? 0.28 : 0.14),
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Icon(icon, size: size * 0.52, color: dark ? Color.lerp(color, Colors.white, 0.45) : color),
    );
  }
}

/// Responsive grid of fixed-min-width cells.
class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({super.key, required this.children, this.minWidth = 220, this.spacing = Sp.md});
  final List<Widget> children;
  final double minWidth;
  final double spacing;

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, c) {
        final cols = (c.maxWidth / minWidth).floor().clamp(1, 8);
        final w = (c.maxWidth - spacing * (cols - 1)) / cols;
        return Wrap(spacing: spacing, runSpacing: spacing, children: [for (final ch in children) SizedBox(width: w, child: ch)]);
      });
}
