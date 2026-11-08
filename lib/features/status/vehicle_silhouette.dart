import 'package:flutter/material.dart';

/// Stylized compact-SUV silhouette — abstract geometry, not a branded asset.
class VehicleSilhouette extends StatelessWidget {
  const VehicleSilhouette({super.key, this.height = 120, this.color});

  final double height;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.primary.withValues(alpha: 0.35);
    return SizedBox(
      height: height,
      width: height * 1.85,
      child: CustomPaint(painter: _SuvPainter(c)),
    );
  }
}

class _SuvPainter extends CustomPainter {
  _SuvPainter(this.fill);

  final Color fill;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = fill..style = PaintingStyle.fill;
    final outline = Paint()
      ..color = fill.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final body = Path()
      ..moveTo(size.width * 0.06, size.height * 0.62)
      ..lineTo(size.width * 0.12, size.height * 0.42)
      ..lineTo(size.width * 0.28, size.height * 0.28)
      ..lineTo(size.width * 0.52, size.height * 0.22)
      ..lineTo(size.width * 0.78, size.height * 0.28)
      ..lineTo(size.width * 0.92, size.height * 0.45)
      ..lineTo(size.width * 0.94, size.height * 0.62)
      ..close();

    canvas.drawPath(body, p);
    canvas.drawPath(body, outline);

    final wheel = Paint()..color = fill.withValues(alpha: 0.65);
    for (final cx in [0.26, 0.74]) {
      canvas.drawCircle(Offset(size.width * cx, size.height * 0.72), size.height * 0.11, wheel);
    }
  }

  @override
  bool shouldRepaint(covariant _SuvPainter oldDelegate) => oldDelegate.fill != fill;
}
