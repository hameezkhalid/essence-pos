import 'package:flutter/material.dart';

import 'tokens.dart';

ThemeData buildTheme(Brightness b) {
  final c = b == Brightness.light ? EssenceColors.light : EssenceColors.dark;
  final scheme = ColorScheme(
    brightness: b,
    primary: c.primary,
    onPrimary: c.onPrimary,
    primaryContainer: c.primaryContainer,
    onPrimaryContainer: c.onPrimaryContainer,
    secondary: c.accent,
    onSecondary: b == Brightness.light ? Colors.white : const Color(0xFF1F150C),
    secondaryContainer: c.accentContainer,
    onSecondaryContainer: c.text,
    tertiary: c.info,
    onTertiary: Colors.white,
    error: c.danger,
    onError: Colors.white,
    errorContainer: c.dangerContainer,
    onErrorContainer: c.text,
    surface: c.surface,
    onSurface: c.text,
    onSurfaceVariant: c.textMuted,
    surfaceContainerLowest: c.bg,
    surfaceContainerLow: c.surface,
    surfaceContainer: c.surfaceAlt,
    surfaceContainerHigh: c.beige,
    surfaceContainerHighest: c.beige,
    outline: c.border,
    outlineVariant: c.border,
    shadow: c.shadow,
    scrim: Colors.black54,
    inverseSurface: c.text,
    onInverseSurface: c.bg,
    inversePrimary: c.primaryContainer,
  );

  const body = 'Inter';
  const display = 'Playfair';
  TextStyle s(double size, FontWeight w, {String family = body, double? height, double? spacing, Color? color}) =>
      TextStyle(fontFamily: family, fontSize: size, fontWeight: w, height: height, letterSpacing: spacing, color: color ?? c.text);

  final text = TextTheme(
    displayLarge: s(48, FontWeight.w600, family: display, height: 1.1),
    displayMedium: s(38, FontWeight.w600, family: display, height: 1.12),
    displaySmall: s(30, FontWeight.w600, family: display, height: 1.15),
    headlineLarge: s(28, FontWeight.w600, family: display, height: 1.2),
    headlineMedium: s(24, FontWeight.w600, family: display, height: 1.2),
    headlineSmall: s(20, FontWeight.w600, family: display, height: 1.25),
    titleLarge: s(18, FontWeight.w700, height: 1.3, spacing: -0.2),
    titleMedium: s(15, FontWeight.w600, height: 1.3, spacing: -0.1),
    titleSmall: s(13, FontWeight.w600, height: 1.3),
    bodyLarge: s(15, FontWeight.w400, height: 1.45),
    bodyMedium: s(14, FontWeight.w400, height: 1.45),
    bodySmall: s(12, FontWeight.w400, height: 1.4, color: c.textMuted),
    labelLarge: s(14, FontWeight.w600, height: 1.2),
    labelMedium: s(12, FontWeight.w600, height: 1.2, spacing: 0.1),
    labelSmall: s(11, FontWeight.w600, height: 1.2, spacing: 0.4, color: c.textMuted),
  );

  final roundedMd = RoundedRectangleBorder(borderRadius: BorderRadius.circular(Rad.md));
  const btnPadding = EdgeInsets.symmetric(horizontal: 20, vertical: 14);
  const btnMin = Size(48, 48);

  return ThemeData(
    useMaterial3: true,
    brightness: b,
    colorScheme: scheme,
    fontFamily: body,
    textTheme: text,
    scaffoldBackgroundColor: c.bg,
    canvasColor: c.bg,
    extensions: [c],
    splashFactory: InkSparkle.splashFactory,
    visualDensity: VisualDensity.standard,
    materialTapTargetSize: MaterialTapTargetSize.padded,
    dividerTheme: DividerThemeData(color: c.border, thickness: 1, space: 1),
    appBarTheme: AppBarTheme(
      backgroundColor: c.bg,
      foregroundColor: c.text,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: text.headlineSmall,
    ),
    cardTheme: CardThemeData(
      color: c.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Rad.lg), side: BorderSide(color: c.border)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: c.primary,
        foregroundColor: c.onPrimary,
        disabledBackgroundColor: c.border,
        disabledForegroundColor: c.textFaint,
        minimumSize: btnMin,
        padding: btnPadding,
        shape: roundedMd,
        textStyle: text.labelLarge,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: c.surface,
        foregroundColor: c.text,
        elevation: 0,
        minimumSize: btnMin,
        padding: btnPadding,
        shape: roundedMd,
        textStyle: text.labelLarge,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: c.text,
        side: BorderSide(color: c.border),
        minimumSize: btnMin,
        padding: btnPadding,
        shape: roundedMd,
        textStyle: text.labelLarge,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: c.primary,
        minimumSize: const Size(40, 40),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: roundedMd,
        textStyle: text.labelLarge,
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(foregroundColor: c.textMuted, minimumSize: const Size(44, 44)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: c.surfaceAlt,
      isDense: false,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: text.bodyMedium?.copyWith(color: c.textFaint),
      labelStyle: text.bodyMedium?.copyWith(color: c.textMuted),
      floatingLabelStyle: text.bodyMedium?.copyWith(color: c.primary, fontWeight: FontWeight.w600),
      prefixIconColor: c.textMuted,
      suffixIconColor: c.textMuted,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(Rad.md), borderSide: BorderSide(color: c.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(Rad.md), borderSide: BorderSide(color: c.border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(Rad.md), borderSide: BorderSide(color: c.primary, width: 1.6)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(Rad.md), borderSide: BorderSide(color: c.danger)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(Rad.md), borderSide: BorderSide(color: c.danger, width: 1.6)),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: c.surface,
      selectedColor: c.primaryContainer,
      side: BorderSide(color: c.border),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Rad.sm)),
      labelStyle: text.labelLarge,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      checkmarkColor: c.primary,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: c.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Rad.xl)),
      titleTextStyle: text.headlineSmall,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: c.surface,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      dragHandleColor: c.border,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(Rad.xl))),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: c.text,
      contentTextStyle: text.bodyMedium?.copyWith(color: c.bg),
      actionTextColor: c.primaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Rad.md)),
      width: 440,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? c.onPrimary : c.textMuted),
      trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? c.primary : c.surfaceAlt),
      trackOutlineColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? c.primary : c.border),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? c.primary : Colors.transparent),
      side: BorderSide(color: c.textFaint, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
    ),
    radioTheme: RadioThemeData(fillColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? c.primary : c.textFaint)),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: SegmentedButton.styleFrom(
        backgroundColor: c.surface,
        selectedBackgroundColor: c.primaryContainer,
        selectedForegroundColor: c.onPrimaryContainer,
        foregroundColor: c.textMuted,
        side: BorderSide(color: c.border),
        shape: roundedMd,
        textStyle: text.labelLarge,
      ),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: c.surface,
      indicatorColor: c.primaryContainer,
      selectedIconTheme: IconThemeData(color: c.onPrimaryContainer),
      unselectedIconTheme: IconThemeData(color: c.textMuted),
      selectedLabelTextStyle: text.labelMedium?.copyWith(color: c.text),
      unselectedLabelTextStyle: text.labelMedium?.copyWith(color: c.textMuted),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: c.surface,
      indicatorColor: c.primaryContainer,
      labelTextStyle: WidgetStatePropertyAll(text.labelSmall?.copyWith(color: c.text)),
      height: 68,
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: c.text,
      unselectedLabelColor: c.textMuted,
      indicatorColor: c.primary,
      dividerColor: c.border,
      labelStyle: text.labelLarge,
      unselectedLabelStyle: text.labelLarge,
      indicatorSize: TabBarIndicatorSize.label,
    ),
    listTileTheme: ListTileThemeData(
      iconColor: c.textMuted,
      textColor: c.text,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Rad.md)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: c.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Rad.md), side: BorderSide(color: c.border)),
      textStyle: text.bodyMedium,
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(color: c.text, borderRadius: BorderRadius.circular(8)),
      textStyle: text.bodySmall?.copyWith(color: c.bg),
      waitDuration: const Duration(milliseconds: 500),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: c.primary, linearTrackColor: c.surfaceAlt),
    scrollbarTheme: ScrollbarThemeData(
      thumbColor: WidgetStatePropertyAll(c.textFaint.withValues(alpha: 0.5)),
      radius: const Radius.circular(8),
      thickness: const WidgetStatePropertyAll(6),
    ),
  );
}
