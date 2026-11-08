import 'package:flutter/material.dart';

/// Hebrew label + LTR numeric/unit value (RTL shell, metrics read left-to-right).
class LtrMetricRow extends StatelessWidget {
  const LtrMetricRow({
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
    final base = style ?? Theme.of(context).textTheme.bodyLarge;
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: '$label: '),
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Text(value, style: base),
            ),
          ),
        ],
      ),
      textDirection: TextDirection.rtl,
    );
  }
}

class LtrMetricText extends StatelessWidget {
  const LtrMetricText(this.value, {super.key, this.style});

  final String value;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Text(value, style: style, textAlign: TextAlign.left),
    );
  }
}
