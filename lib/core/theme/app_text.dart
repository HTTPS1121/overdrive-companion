import 'package:flutter/material.dart';

const kHebrewFontFamily = 'NotoSansHebrew';
const kLatinFontFamily = 'NotoSans';

/// Hebrew UI copy.
TextStyle hebrewTextStyle(TextStyle? base, {FontWeight? weight}) {
  return (base ?? const TextStyle()).copyWith(
    fontFamily: kHebrewFontFamily,
    fontWeight: weight,
  );
}

/// Numbers, URLs, ASCII (SOC, km, TPMS).
TextStyle numericTextStyle(TextStyle? base, {FontWeight? weight, double? size}) {
  return (base ?? const TextStyle()).copyWith(
    fontFamily: kLatinFontFamily,
    fontWeight: weight,
    fontSize: size,
  );
}
