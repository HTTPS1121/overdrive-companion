import 'package:flutter/material.dart';

/// Dark automotive dashboard — tuned for BYD Atto 3 companion (phone, RTL).
ThemeData buildOverdriveTheme() {
  const bg = Color(0xFF0B0F14);
  const surface = Color(0xFF151B24);
  const surfaceHigh = Color(0xFF1C2533);
  const accent = Color(0xFF2DD4BF);
  const accentDim = Color(0xFF0D9488);
  const warn = Color(0xFFF59E0B);
  const danger = Color(0xFFEF4444);
  const onSurface = Color(0xFFE8EDF4);
  const muted = Color(0xFF8B9BB0);

  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'Roboto',
    scaffoldBackgroundColor: bg,
    colorScheme: const ColorScheme.dark(
      surface: surface,
      surfaceContainerHighest: surfaceHigh,
      primary: accent,
      onPrimary: Color(0xFF042F2E),
      secondary: accentDim,
      error: danger,
      onSurface: onSurface,
      outline: Color(0xFF2A3545),
    ),
    dividerColor: const Color(0xFF2A3545),
    splashFactory: InkSparkle.splashFactory,
  );

  return base.copyWith(
    textTheme: base.textTheme.apply(
      bodyColor: onSurface,
      displayColor: onSurface,
    ).copyWith(
      headlineLarge: base.textTheme.headlineLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      titleLarge: base.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      titleMedium: base.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      bodyMedium: base.textTheme.bodyMedium?.copyWith(color: muted, height: 1.35),
      labelLarge: base.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
    ),
    appBarTheme: AppBarTheme(
      centerTitle: true,
      backgroundColor: bg,
      foregroundColor: onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: base.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: surface,
      indicatorColor: accent.withValues(alpha: 0.18),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return base.textTheme.labelMedium?.copyWith(
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected ? accent : muted,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(color: selected ? accent : muted, size: 26);
      }),
      height: 68,
    ),
    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF243044)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(88, 48),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceHigh,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF2A3545)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF2A3545)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: accent, width: 1.5),
      ),
      labelStyle: const TextStyle(color: muted),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: surfaceHigh,
    ),
    extensions: [
      OverdriveColors(
        accent: accent,
        warn: warn,
        danger: danger,
        muted: muted,
        demoBanner: const Color(0xFF422006),
        demoBannerBorder: warn,
      ),
    ],
  );
}

class OverdriveColors extends ThemeExtension<OverdriveColors> {
  const OverdriveColors({
    required this.accent,
    required this.warn,
    required this.danger,
    required this.muted,
    required this.demoBanner,
    required this.demoBannerBorder,
  });

  final Color accent;
  final Color warn;
  final Color danger;
  final Color muted;
  final Color demoBanner;
  final Color demoBannerBorder;

  static OverdriveColors of(BuildContext context) =>
      Theme.of(context).extension<OverdriveColors>()!;

  @override
  OverdriveColors copyWith() => this;

  @override
  ThemeExtension<OverdriveColors> lerp(
    covariant ThemeExtension<OverdriveColors>? other,
    double t,
  ) =>
      this;
}
