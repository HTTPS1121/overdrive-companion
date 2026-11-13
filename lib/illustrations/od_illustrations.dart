import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';

import '../design/od_design.dart';

/// Side-view car from overdrive-chosen.html `car()` SVG.
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
    canvas.drawPath(body, Paint()..color = const Color(0xFFD1E1F0)..style = PaintingStyle.fill);
    canvas.drawPath(
      body,
      Paint()
        ..color = const Color(0xFF456787)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );
    final glass = parseSvgPathData('m72 41 27-21h42v23zm77 2V20h37l31 24z');
    canvas.drawPath(glass, Paint()..color = const Color(0xFF21476D)..style = PaintingStyle.fill);
    canvas.drawPath(
      glass,
      Paint()
        ..color = const Color(0xFF718DA7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    final lights = parseSvgPathData('M36 53h24l-3 7H34M284 58h14l6 9h-19');
    canvas.drawPath(lights, Paint()..color = const Color(0xFFFFF5C4)..style = PaintingStyle.fill);
    canvas.drawPath(
      lights,
      Paint()
        ..color = const Color(0xFF738DA5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    final stroke = Paint()
      ..color = const Color(0xFF6E8CA6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawLine(const Offset(66, 48), const Offset(232, 48), stroke);
    canvas.drawLine(const Offset(145, 47), const Offset(145, 76), stroke);
    canvas.drawLine(const Offset(226, 48), const Offset(234, 73), stroke);
    canvas.drawLine(const Offset(156, 53), const Offset(169, 53), stroke);
    canvas.drawLine(const Offset(203, 54), const Offset(216, 54), stroke);
    for (final cx in [78.0, 260.0]) {
      canvas.drawCircle(Offset(cx, 78), 17, Paint()..color = const Color(0xFF203D5A));
      canvas.drawCircle(Offset(cx, 78), 9, Paint()..color = const Color(0xFFC8D9E8));
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Parking-lot scene from overdrive-chosen.html `scene()`.
class OdSceneView extends StatelessWidget {
  const OdSceneView({
    super.key,
    this.label = 'חזית',
    this.height,
    this.dark = false,
    this.thumbnailOverlay = false,
  });

  final String label;
  final double? height;
  final bool dark;
  final bool thumbnailOverlay;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height == null ? 16 : 0),
      child: ColoredBox(
        color: dark ? const Color(0xFF0E2238) : Colors.transparent,
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(painter: _ScenePainter(dark: dark)),
              if (!dark && thumbnailOverlay)
                Positioned(
                  top: 10,
                  right: 10,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0xE80C2348),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                      child: Text(
                        '$label · הדמיה',
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScenePainter extends CustomPainter {
  _ScenePainter({required this.dark});

  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 340;
    final sy = size.height / 200;
    canvas.save();
    canvas.scale(sx, sy);
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, 340, 200),
      Paint()..color = dark ? const Color(0xFF13273F) : const Color(0xFFE9EEF4),
    );
    canvas.drawRect(const Rect.fromLTWH(0, 0, 340, 200), Paint()..color = const Color(0xFFC9D5E1));
    final grid = Paint()
      ..color = const Color(0xFFB8C6D6)
      ..strokeWidth = 0.75;
    for (var y = 0.0; y < 200; y += 14) {
      canvas.drawLine(Offset(0, y), Offset(340, y), grid);
    }
    for (var x = 0.0; x < 340; x += 14) {
      canvas.drawLine(Offset(x, 0), Offset(x, 200), grid);
    }
    canvas.drawRect(
      const Rect.fromLTWH(0, 128, 340, 72),
      Paint()..color = const Color(0xFFCAD5DF),
    );
    final lane = Paint()
      ..color = const Color(0xFF98A9B9)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(const Offset(0, 164), const Offset(340, 164), lane);
    canvas.drawRect(const Rect.fromLTWH(56, 78, 98, 50), Paint()..color = const Color(0xFF737373));
    canvas.drawRect(const Rect.fromLTWH(214, 78, 72, 50), Paint()..color = const Color(0xFF5F5F5F));
    final car = parseSvgPathData('M92 138h144l12 14H80z');
    canvas.drawPath(car, Paint()..color = const Color(0xFF90B2CC)..style = PaintingStyle.fill);
    canvas.drawPath(
      car,
      Paint()
        ..color = const Color(0xFF5A7E9B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    canvas.drawCircle(const Offset(114, 154), 8, Paint()..color = const Color(0xFF203D5A));
    canvas.drawCircle(const Offset(214, 154), 8, Paint()..color = const Color(0xFF203D5A));
    canvas.drawCircle(const Offset(170, 90), 11, Paint()..color = const Color(0xFF51606E));
    canvas.drawCircle(const Offset(170, 84), 9, Paint()..color = const Color(0xFF344250));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ScenePainter oldDelegate) => dark != oldDelegate.dark;
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
          child: Align(
            alignment: const Alignment(0, 0.75),
            child: Text('תרשים המחשה בלבד', style: odMuted(12).copyWith(color: const Color(0xFF476181))),
          ),
        ),
      ),
    );
  }
}

/// Matches HTML `map()` SVG (340×200).
class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 340;
    final sy = size.height / 200;
    canvas.save();
    canvas.scale(sx, sy);
    canvas.drawRect(const Rect.fromLTWH(0, 0, 340, 200), Paint()..color = const Color(0xFFE1E8F1));
    final street = Paint()
      ..color = Colors.white
      ..strokeWidth = 15;
    canvas.drawLine(const Offset(0, 45), const Offset(340, 45), street);
    canvas.drawLine(const Offset(0, 136), const Offset(340, 136), street);
    canvas.drawLine(const Offset(70, 0), const Offset(70, 200), street);
    canvas.drawLine(const Offset(268, 0), const Offset(268, 200), street);
    canvas.drawLine(const Offset(88, 200), const Offset(225, 0), street);
    final route = Paint()
      ..color = const Color(0xFF215DBE)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(
      Path()
        ..moveTo(70, 136)
        ..lineTo(170, 136)
        ..lineTo(170, 45)
        ..lineTo(268, 45),
      route,
    );
    canvas.drawCircle(
      const Offset(70, 136),
      8,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      const Offset(70, 136),
      8,
      Paint()
        ..color = const Color(0xFF215DBE)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    canvas.drawCircle(const Offset(268, 45), 8, Paint()..color = const Color(0xFF215DBE));
    canvas.restore();
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
    canvas.drawRRect(rrect, Paint()..color = const Color(0xFFD1E1F0)..style = PaintingStyle.fill);
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
