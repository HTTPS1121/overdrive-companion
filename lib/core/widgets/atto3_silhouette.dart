import 'package:flutter/material.dart';

import '../theme/app_text.dart';
import '../theme/app_theme.dart';

/// Stylized BYD Atto 3 crossover silhouette — honest vector art, not a photo.
class Atto3Silhouette extends StatelessWidget {
  const Atto3Silhouette({
    super.key,
    this.socProgress = 0.72,
    this.socLabel = '72%',
    this.accent,
  });

  final double socProgress;
  final String socLabel;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final colors = OverdriveColors.of(context);
    final accentColor = accent ?? colors.accent;

    return SizedBox(
      height: 168,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(280, 120),
            painter: _SilhouettePainter(accent: accentColor),
          ),
          Positioned(
            right: 12,
            top: 18,
            child: SizedBox(
              width: 64,
              height: 64,
              child: CustomPaint(
                painter: _SocBadgePainter(
                  progress: socProgress,
                  color: accentColor,
                ),
                child: Center(
                  child: Text(
                    socLabel,
                    style: TextStyle(
                      fontFamily: kLatinFontFamily,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: colors.accent,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SilhouettePainter extends CustomPainter {
  _SilhouettePainter({required this.accent});

  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final body = Path()
      ..moveTo(w * 0.08, h * 0.72)
      ..quadraticBezierTo(w * 0.12, h * 0.42, w * 0.28, h * 0.38)
      ..lineTo(w * 0.45, h * 0.22)
      ..quadraticBezierTo(w * 0.55, h * 0.14, w * 0.68, h * 0.22)
      ..lineTo(w * 0.88, h * 0.32)
      ..quadraticBezierTo(w * 0.96, h * 0.42, w * 0.94, h * 0.58)
      ..lineTo(w * 0.9, h * 0.72)
      ..lineTo(w * 0.08, h * 0.72)
      ..close();

    final glass = Path()
      ..moveTo(w * 0.32, h * 0.38)
      ..lineTo(w * 0.44, h * 0.26)
      ..lineTo(w * 0.62, h * 0.28)
      ..lineTo(w * 0.76, h * 0.38)
      ..lineTo(w * 0.32, h * 0.38);

    final fill = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          accent.withValues(alpha: 0.35),
          const Color(0xFF1A2535),
        ],
      ).createShader(Offset.zero & size);

    canvas.drawPath(
      body,
      fill,
    );
    canvas.drawPath(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = accent.withValues(alpha: 0.55),
    );
    canvas.drawPath(
      glass,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = const Color(0xFF5EEAD4).withValues(alpha: 0.5),
    );

    void wheel(double cx) {
      canvas.drawCircle(
        Offset(cx, h * 0.74),
        h * 0.14,
        Paint()..color = const Color(0xFF0B0F14),
      );
      canvas.drawCircle(
        Offset(cx, h * 0.74),
        h * 0.14,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = const Color(0xFF3D4F66),
      );
      canvas.drawCircle(
        Offset(cx, h * 0.74),
        h * 0.05,
        Paint()..color = accent.withValues(alpha: 0.4),
      );
    }

    wheel(w * 0.26);
    wheel(w * 0.78);
  }

  @override
  bool shouldRepaint(covariant _SilhouettePainter oldDelegate) =>
      oldDelegate.accent != accent;
}

class _SocBadgePainter extends CustomPainter {
  _SocBadgePainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = 5.0;
    final rect = Offset.zero & size;
    final bg = Paint()
      ..color = const Color(0xFF243044)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    final fg = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect.deflate(stroke / 2), 0, 6.283, false, bg);
    canvas.drawArc(
      rect.deflate(stroke / 2),
      -1.57,
      6.283 * progress.clamp(0, 1),
      false,
      fg,
    );
  }

  @override
  bool shouldRepaint(covariant _SocBadgePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
