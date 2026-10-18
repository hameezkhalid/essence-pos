import 'package:flutter/material.dart';

/// Essence brand colours (from the logo: olive on cream, with beige and coffee brown).
/// Widgets read these through `context.ec` — never hard-code colours.
@immutable
class EssenceColors extends ThemeExtension<EssenceColors> {
  const EssenceColors({
    required this.primary,
    required this.primaryContainer,
    required this.onPrimary,
    required this.onPrimaryContainer,
    required this.bg,
    required this.surface,
    required this.surfaceAlt,
    required this.beige,
    required this.accent,
    required this.accentContainer,
    required this.text,
    required this.textMuted,
    required this.textFaint,
    required this.border,
    required this.success,
    required this.successContainer,
    required this.warning,
    required this.warningContainer,
    required this.danger,
    required this.dangerContainer,
    required this.info,
    required this.infoContainer,
    required this.paper,
    required this.ink,
    required this.shadow,
  });

  final Color primary;
  final Color primaryContainer;
  final Color onPrimary;
  final Color onPrimaryContainer;

  /// App background (off-white / espresso dark).
  final Color bg;

  /// Cards and panels.
  final Color surface;

  /// Slightly raised/sunken surface (inputs, list rows).
  final Color surfaceAlt;

  /// Beige: product tiles, cart panel.
  final Color beige;

  /// Coffee brown accent: prices, secondary actions.
  final Color accent;
  final Color accentContainer;
  final Color text;
  final Color textMuted;
  final Color textFaint;
  final Color border;
  final Color success;
  final Color successContainer;
  final Color warning;
  final Color warningContainer;
  final Color danger;
  final Color dangerContainer;
  final Color info;
  final Color infoContainer;

  /// Receipt paper and ink for on-screen receipt previews.
  final Color paper;
  final Color ink;
  final Color shadow;

  static const light = EssenceColors(
    primary: Color(0xFF4E5726),
    primaryContainer: Color(0xFFE4E7CF),
    onPrimary: Color(0xFFFFFFFF),
    onPrimaryContainer: Color(0xFF2C3212),
    bg: Color(0xFFF9F5EC),
    surface: Color(0xFFFFFDF8),
    surfaceAlt: Color(0xFFF3EDE0),
    beige: Color(0xFFEDE3CF),
    accent: Color(0xFF8A5A36),
    accentContainer: Color(0xFFF2E2D2),
    text: Color(0xFF2B2118),
    textMuted: Color(0xFF665C4E),
    textFaint: Color(0xFF9C9282),
    border: Color(0xFFE2D8C3),
    success: Color(0xFF2F6A40),
    successContainer: Color(0xFFDDEEDF),
    warning: Color(0xFF875708),
    warningContainer: Color(0xFFF7E7C8),
    danger: Color(0xFFA23A2E),
    dangerContainer: Color(0xFFF6DCD7),
    info: Color(0xFF3F6E80),
    infoContainer: Color(0xFFDCE9EE),
    paper: Color(0xFFFFFEFA),
    ink: Color(0xFF231B14),
    shadow: Color(0x1A3B2A1E),
  );

  static const dark = EssenceColors(
    primary: Color(0xFFA3AE6E),
    primaryContainer: Color(0xFF3A4119),
    onPrimary: Color(0xFF1A1C0E),
    onPrimaryContainer: Color(0xFFE4E7CF),
    bg: Color(0xFF15130F),
    surface: Color(0xFF1F1C17),
    surfaceAlt: Color(0xFF26221C),
    beige: Color(0xFF2C2720),
    accent: Color(0xFFC99366),
    accentContainer: Color(0xFF3D2C1E),
    text: Color(0xFFEFE8DA),
    textMuted: Color(0xFFA69C8B),
    textFaint: Color(0xFF7A7164),
    border: Color(0xFF3A342B),
    success: Color(0xFF7BC28E),
    successContainer: Color(0xFF1E3324),
    warning: Color(0xFFE3B25A),
    warningContainer: Color(0xFF3B2E15),
    danger: Color(0xFFE58C7F),
    dangerContainer: Color(0xFF3F201B),
    info: Color(0xFF8CC0D2),
    infoContainer: Color(0xFF1C2E35),
    paper: Color(0xFFF7F2E7),
    ink: Color(0xFF231B14),
    shadow: Color(0x66000000),
  );

  @override
  EssenceColors copyWith() => this;

  @override
  EssenceColors lerp(ThemeExtension<EssenceColors>? other, double t) {
    if (other is! EssenceColors) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return EssenceColors(
      primary: l(primary, other.primary),
      primaryContainer: l(primaryContainer, other.primaryContainer),
      onPrimary: l(onPrimary, other.onPrimary),
      onPrimaryContainer: l(onPrimaryContainer, other.onPrimaryContainer),
      bg: l(bg, other.bg),
      surface: l(surface, other.surface),
      surfaceAlt: l(surfaceAlt, other.surfaceAlt),
      beige: l(beige, other.beige),
      accent: l(accent, other.accent),
      accentContainer: l(accentContainer, other.accentContainer),
      text: l(text, other.text),
      textMuted: l(textMuted, other.textMuted),
      textFaint: l(textFaint, other.textFaint),
      border: l(border, other.border),
      success: l(success, other.success),
      successContainer: l(successContainer, other.successContainer),
      warning: l(warning, other.warning),
      warningContainer: l(warningContainer, other.warningContainer),
      danger: l(danger, other.danger),
      dangerContainer: l(dangerContainer, other.dangerContainer),
      info: l(info, other.info),
      infoContainer: l(infoContainer, other.infoContainer),
      paper: l(paper, other.paper),
      ink: l(ink, other.ink),
      shadow: l(shadow, other.shadow),
    );
  }
}

/// Spacing and radius scale.
class Sp {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
}

class Rad {
  static const sm = 10.0;
  static const md = 14.0;
  static const lg = 18.0;
  static const xl = 24.0;
}

extension EssenceContext on BuildContext {
  EssenceColors get ec => Theme.of(this).extension<EssenceColors>()!;
  TextTheme get tt => Theme.of(this).textTheme;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  double get screenW => MediaQuery.sizeOf(this).width;

  /// Layout classes: phone < 700 ≤ tablet < 1100 ≤ desktop.
  bool get isPhone => screenW < 700;
  bool get isDesktop => screenW >= 1100;
}

const tabular = [FontFeature.tabularFigures()];
