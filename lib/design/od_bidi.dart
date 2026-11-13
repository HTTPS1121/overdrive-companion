import 'package:flutter/material.dart';

import 'od_design.dart';

/// Unicode-bidi isolate + LTR direction for number/unit strings in RTL UI.
String odIsolateLtr(String value) => '\u2066$value\u2069';

/// Latin/numeric text that must read left-to-right (e.g. `31.2 GB`, `342`, `00:46`).
class OdLtrText extends StatelessWidget {
  const OdLtrText(
    this.value, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  final String value;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    return Text(
      odIsolateLtr(value),
      style: style,
      textDirection: TextDirection.ltr,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// Shorthand for tabular nums with LTR isolation.
Widget odLtrNum(
  String value, {
  double size = 14,
  FontWeight weight = FontWeight.w400,
  Color? color,
}) {
  return OdLtrText(value, style: odNum(size, weight: weight, color: color));
}
