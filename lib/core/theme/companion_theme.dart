import 'package:flutter/material.dart';

import 'companion_color_schemes.dart';

const kCompanionFontFamily = 'NotoSansHebrew';
const kCompanionFontFallback = ['NotoSans', 'sans-serif'];

const _expressiveShapes = BorderRadiusTheme(
  extraSmall: BorderRadius.all(Radius.circular(8)),
  small: BorderRadius.all(Radius.circular(12)),
  medium: BorderRadius.all(Radius.circular(20)),
  large: BorderRadius.all(Radius.circular(28)),
  extraLarge: BorderRadius.all(Radius.circular(36)),
);

/// M3 type scale aligned with VoiceDial ExpressiveTypography (sizes/weights).
TextTheme _companionTypography(TextTheme base) {
  return base.copyWith(
    displaySmall: base.displaySmall?.copyWith(
      fontSize: 36,
      height: 44 / 36,
      fontWeight: FontWeight.bold,
    ),
    headlineLarge: base.headlineLarge?.copyWith(
      fontSize: 32,
      height: 40 / 32,
      fontWeight: FontWeight.bold,
    ),
    headlineMedium: base.headlineMedium?.copyWith(
      fontSize: 26,
      height: 34 / 26,
      fontWeight: FontWeight.w600,
    ),
    headlineSmall: base.headlineSmall?.copyWith(
      fontSize: 22,
      height: 30 / 22,
      fontWeight: FontWeight.w600,
    ),
    titleLarge: base.titleLarge?.copyWith(
      fontSize: 20,
      height: 28 / 20,
      fontWeight: FontWeight.w600,
    ),
    titleMedium: base.titleMedium?.copyWith(
      fontSize: 16,
      height: 24 / 16,
      fontWeight: FontWeight.w500,
    ),
    bodyLarge: base.bodyLarge?.copyWith(fontSize: 16, height: 24 / 16),
    bodyMedium: base.bodyMedium?.copyWith(fontSize: 14, height: 20 / 14),
    labelLarge: base.labelLarge?.copyWith(
      fontSize: 14,
      height: 20 / 14,
      fontWeight: FontWeight.w600,
    ),
  );
}

ThemeData _buildTheme(ColorScheme colorScheme, Brightness brightness) {
  final base = ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: colorScheme,
    fontFamily: kCompanionFontFamily,
    fontFamilyFallback: kCompanionFontFallback,
  );
  return base.copyWith(
    textTheme: _companionTypography(base.textTheme),
    appBarTheme: AppBarTheme(
      centerTitle: true,
      scrolledUnderElevation: 0,
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      surfaceTintColor: colorScheme.surfaceTint,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: colorScheme.surfaceContainer,
      indicatorColor: colorScheme.secondaryContainer,
      labelTextStyle: WidgetStatePropertyAll(
        base.textTheme.labelLarge?.copyWith(fontFamily: kCompanionFontFamily),
      ),
    ),
    cardTheme: CardThemeData(
      color: colorScheme.surfaceContainerLow,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: _expressiveShapes.medium),
      margin: EdgeInsets.zero,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 48),
        shape: RoundedRectangleBorder(borderRadius: _expressiveShapes.small),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(48, 48),
        shape: RoundedRectangleBorder(borderRadius: _expressiveShapes.small),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest,
      border: OutlineInputBorder(borderRadius: _expressiveShapes.small),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: _expressiveShapes.small),
    ),
    dialogTheme: DialogThemeData(
      shape: RoundedRectangleBorder(borderRadius: _expressiveShapes.large),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      shape: RoundedRectangleBorder(borderRadius: _expressiveShapes.large),
    ),
  );
}

ThemeData companionLightTheme({ColorScheme? colorScheme}) =>
    _buildTheme(colorScheme ?? CompanionColorSchemes.light, Brightness.light);

ThemeData companionDarkTheme({ColorScheme? colorScheme}) =>
    _buildTheme(colorScheme ?? CompanionColorSchemes.dark, Brightness.dark);

class BorderRadiusTheme {
  const BorderRadiusTheme({
    required this.extraSmall,
    required this.small,
    required this.medium,
    required this.large,
    required this.extraLarge,
  });

  final BorderRadius extraSmall;
  final BorderRadius small;
  final BorderRadius medium;
  final BorderRadius large;
  final BorderRadius extraLarge;
}
