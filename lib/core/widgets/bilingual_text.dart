import 'package:flutter/material.dart';

import '../theme/app_text.dart';

/// App bar / titles: Hebrew + Latin brand without mixed-font tofu.
class HebrewLatinTitle extends StatelessWidget {
  const HebrewLatinTitle({
    super.key,
    required this.hebrew,
    required this.latin,
    this.style,
  });

  final String hebrew;
  final String latin;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final base = style ?? Theme.of(context).textTheme.titleLarge;
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: hebrew, style: hebrewTextStyle(base)),
          TextSpan(text: ' ', style: hebrewTextStyle(base)),
          TextSpan(text: latin, style: numericTextStyle(base)),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}

/// Inline Hebrew label + LTR numeric value (km, %, temps).
class HebrewMetricLine extends StatelessWidget {
  const HebrewMetricLine({
    super.key,
    required this.label,
    required this.value,
    this.style,
  });

  final String label;
  final String value;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final base = style ?? Theme.of(context).textTheme.bodySmall;
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: label, style: hebrewTextStyle(base)),
          TextSpan(text: value, style: numericTextStyle(base)),
        ],
      ),
    );
  }
}
