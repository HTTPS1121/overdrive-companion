import 'package:flutter/material.dart';

import 'od_fonts.dart';

export 'od_bidi.dart';

/// Tokens from `overdrive-chosen.html` :root and typography.
abstract final class OdColors {
  static const ink = Color(0xFF142F50);
  static const blue = Color(0xFF1957BD);
  static const muted = Color(0xFF53667E);
  static const line = Color(0xFFDCE3EE);
  static const bg = Color(0xFFEEF1F6);
  static const pageChrome = Color(0xFFDCE3ED);
  static const white = Colors.white;
  static const iconBtnBg = Color(0xABFFFFFF);
  static const iconBtnBorder = Color(0xFFD5DFEC);
  static const navActiveBg = Color(0xFFE3ECFB);
  static const navActiveFg = Color(0xFF174B9A);
  static const navInactive = Color(0xFF52657D);
  static const dotGreen = Color(0xFF267B61);
  static const stateGreenBg = Color(0xFFE5F2EC);
  static const stateGreenFg = Color(0xFF165A45);
  static const pillDemoBg = Color(0xFFE6EDF8);
  static const cardBorder = Color(0xFFE1E7EF);
  static const cardShadow = Color(0x04142E4E);
  static const sheetShade = Color(0x770C254A);
  static const closeBtnBg = Color(0xFFE0E7F1);
  static const primaryBtn = blue;
  static const secondaryBtnBg = Color(0xFFE0E8F6);
  static const secondaryBtnFg = Color(0xFF174A94);
  static const energyGradStart = Color(0xFF1D4F86);
  static const energyGradEnd = Color(0xFF102F59);
  static const vgIconBg = Color(0xFFEEF3FC);
  static const focusOutline = Color(0xFFE3A52C);
}

class OdRadii {
  static const card = 22.0;
  static const control = 14.0;
  static const nav = 28.0;
  static const navItem = 22.0;
  static const chip = 99.0;
  static const sheet = 26.0;
}

class OdShadows {
  static const card = BoxShadow(
    color: OdColors.cardShadow,
    blurRadius: 16,
    offset: Offset(0, 6),
  );
  static const nav = BoxShadow(
    color: Color(0x26132F59),
    blurRadius: 30,
    offset: Offset(0, 8),
  );
}

ThemeData buildOdTheme() {
  final base = ThemeData(
    useMaterial3: false,
    brightness: Brightness.light,
    fontFamily: OdFonts.hebrew,
    fontFamilyFallback: OdFonts.fallback,
    scaffoldBackgroundColor: OdColors.bg,
    colorScheme: const ColorScheme.light(
      primary: OdColors.blue,
      onPrimary: Colors.white,
      surface: OdColors.white,
      onSurface: OdColors.ink,
    ),
  );
  return base.copyWith(
    textTheme: base.textTheme.apply(
      bodyColor: OdColors.ink,
      displayColor: OdColors.ink,
    ),
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
  );
}

TextStyle _hebrew(double size, {FontWeight? weight, Color? color, double? height, double? letterSpacing}) =>
    TextStyle(
      fontFamily: OdFonts.hebrew,
      fontFamilyFallback: OdFonts.fallback,
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );

TextStyle _latin(double size, {FontWeight? weight, Color? color, double? height, double? letterSpacing}) =>
    TextStyle(
      fontFamily: OdFonts.latin,
      fontFamilyFallback: const [OdFonts.hebrew, ...OdFonts.fallback],
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );

TextStyle odH1([double size = 29]) => _hebrew(
      size,
      height: 1.25,
      letterSpacing: -0.7,
      weight: FontWeight.w700,
      color: OdColors.ink,
    );

TextStyle odH2() => _hebrew(19, weight: FontWeight.w700, color: OdColors.ink);

TextStyle odMuted([double size = 14]) =>
    _hebrew(size, weight: FontWeight.w400, height: 1.5, color: OdColors.muted);

TextStyle odEyebrow() =>
    _hebrew(12, weight: FontWeight.w700, letterSpacing: 0.7, color: OdColors.blue);

/// Latin wordmark (OVERDRIVE) — matches HTML system sans for Latin.
TextStyle odBrand() => _latin(16, weight: FontWeight.w800, letterSpacing: 1.2, color: OdColors.ink);

TextStyle odNum(double size, {FontWeight weight = FontWeight.w400, Color? color}) => _latin(
      size,
      weight: weight,
      color: color ?? OdColors.ink,
    ).copyWith(fontFeatures: const [FontFeature.tabularFigures()]);

/// Body text that mixes Hebrew with Latin model names / digits.
TextStyle odBody([double size = 14, FontWeight weight = FontWeight.w400, Color? color]) =>
    _hebrew(size, weight: weight, color: color ?? OdColors.ink, height: 1.5);
