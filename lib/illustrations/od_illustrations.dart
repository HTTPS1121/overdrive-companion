import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';

import '../design/od_design.dart';

/// Side-view car from overdrive-chosen.html `car()` SVG (simplified paths).
class OdCarSideView extends StatelessWidget {
  const OdCarSideView({super.key, this.height = 92});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: CustomPaint(painter: _CarSidePainter()),
    );
  }
}

class _CarSidePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 340;
    final sy = size.height / 105;
    canvas.save();
    canvas.scale(sx, sy);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(170, 88), width: 270, height: 16),
      Paint()..color = const Color(0x1F0B2548),
    );
    final body = parseSvgPathData(
      'M28 72v-23l31-8 34-27h98l42 31 66 13 10 15-6 9H34z',
    );
    canvas.drawPath(
      body,
      Paint()
        ..color = const Color(0xFFD1E1F0)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      body,
      Paint()
        ..color = const Color(0xFF456787)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );
    for (final cx in [78.0, 260.0]) {
      canvas.drawCircle(Offset(cx, 78), 17, Paint()..color = const Color(0xFF203D5A));
      canvas.drawCircle(Offset(cx, 78), 9, Paint()..color = const Color(0xFFC8D9E8));
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Parking-lot scene placeholder (synthetic camera frame).
class OdSceneView extends StatelessWidget {
  const OdSceneView({super.key, this.label = 'חזית', this.height, this.dark = false});

  final String label;
  final double? height;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height == null ? 16 : 0),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(painter: _ScenePainter(dark: dark)),
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xE80C2348),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$label · הדמיה',
                  style: odBody(11, FontWeight.w400, Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScenePainter extends CustomPainter {
  const _ScenePainter({this.dark = false});

  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 320;
    final sy = size.height / 180;
    canvas.save();
    canvas.scale(sx, sy);
    if (dark) {
      canvas.drawRect(const Rect.fromLTWH(0, 0, 320, 180), Paint()..color = const Color(0xFF123D5A));
      canvas.drawRect(const Rect.fromLTWH(0, 76, 320, 104), Paint()..color = const Color(0xFF4A6278));
      canvas.drawLine(const Offset(0, 70), const Offset(320, 70), Paint()..color = const Color(0xFF7A92AA)..strokeWidth = 3);
    } else {
      canvas.drawRect(const Rect.fromLTWH(0, 0, 320, 180), Paint()..color = const Color(0xFFC8D8E8));
      canvas.drawRect(const Rect.fromLTWH(0, 76, 320, 104), Paint()..color = const Color(0xFF667B8F));
      canvas.drawLine(const Offset(0, 70), const Offset(320, 70), Paint()..color = const Color(0xFF98AFC3)..strokeWidth = 3);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ScenePainter oldDelegate) => oldDelegate.dark != dark;
}

class OdMapIllustration extends StatelessWidget {
  const OdMapIllustration({super.key, this.height = 200});

  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: CustomPaint(
          painter: _MapPainter(),
          child: const Align(
            alignment: Alignment(0, 0.75),
            child: Text(
              'תרשים המחשה בלבד',
              style: TextStyle(
                fontFamily: 'NotoSansHebrew',
                fontFamilyFallback: ['NotoSans', 'sans-serif'],
                fontSize: 12,
                color: Color(0xFF476181),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFFE1E8F1));
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 12;
    canvas.drawLine(Offset(0, size.height * 0.22), Offset(size.width, size.height * 0.22), paint);
    canvas.drawLine(Offset(0, size.height * 0.68), Offset(size.width, size.height * 0.68), paint);
    final route = Paint()
      ..color = OdColors.blue
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.2, size.height * 0.68)
        ..lineTo(size.width * 0.49, size.height * 0.68)
        ..lineTo(size.width * 0.49, size.height * 0.22)
        ..lineTo(size.width * 0.79, size.height * 0.22),
      route,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class OdCarTopDown extends StatelessWidget {
  const OdCarTopDown({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 126,
      child: CustomPaint(painter: _CarTopPainter()),
    );
  }
}

class _CarTopPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 60;
    final sy = size.height / 126;
    canvas.save();
    canvas.scale(sx, sy);
    final rrect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(12, 18, 36, 96),
      const Radius.circular(14),
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = const Color(0xFFD1E1F0)
        ..style = PaintingStyle.fill,
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = const Color(0xFF5F7F9C)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    for (final o in [const Offset(12, 42), const Offset(48, 42), const Offset(12, 88), const Offset(48, 88)]) {
      canvas.drawCircle(o, 5, Paint()..color = const Color(0xFF203D5A));
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
