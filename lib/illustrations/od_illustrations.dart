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
  const OdSceneView({super.key, this.label = 'חזית', this.height, this.dark = false});

  final String label;
  final double? height;
  final bool dark;

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
              CustomPaint(painter: const _ScenePainter()),
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
      ),
    );
  }
}

class _ScenePainter extends CustomPainter {
  const _ScenePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 320;
    final sy = size.height / 180;
    canvas.save();
    canvas.scale(sx, sy);

    canvas.drawRect(const Rect.fromLTWH(0, 0, 320, 180), Paint()..color = const Color(0xFFC8D8E8));
    canvas.drawRect(const Rect.fromLTWH(0, 76, 320, 104), Paint()..color = const Color(0xFF667B8F));

    final bldg = Paint()
      ..color = const Color(0xFF98AFC3)
      ..style = PaintingStyle.fill;
    final bStroke = Paint()
      ..color = const Color(0xFFB6CADA)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawRect(const Rect.fromLTWH(0, 25, 65, 50), bldg);
    canvas.drawRect(const Rect.fromLTWH(0, 25, 65, 50), bStroke);
    canvas.drawRect(const Rect.fromLTWH(82, 40, 75, 35), bldg);
    canvas.drawRect(const Rect.fromLTWH(82, 40, 75, 35), bStroke);
    canvas.drawRect(const Rect.fromLTWH(222, 15, 98, 60), bldg);
    canvas.drawRect(const Rect.fromLTWH(222, 15, 98, 60), bStroke);

    canvas.drawLine(const Offset(0, 70), const Offset(320, 70), Paint()..color = const Color(0xFF98AFC3)..strokeWidth = 3);

    final lane = Paint()
      ..color = const Color(0xFFD8E3EA)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawLine(const Offset(140, 76), const Offset(106, 180), lane);
    canvas.drawLine(const Offset(214, 76), const Offset(248, 180), lane);
    canvas.drawLine(const Offset(0, 159), const Offset(117, 144), lane);
    canvas.drawLine(const Offset(203, 144), const Offset(320, 159), lane);
    canvas.drawLine(const Offset(154, 100), const Offset(166, 100), lane);
    canvas.drawLine(const Offset(139, 125), const Offset(157, 125), lane);
    canvas.drawLine(const Offset(129, 160), const Offset(161, 160), lane);

    final parked = parseSvgPathData('M26 114h60v24H22v-15l8-9 9-14h31l12 14');
    canvas.drawPath(parked, Paint()..color = const Color(0xFFC7DAE8)..style = PaintingStyle.fill);
    canvas.drawPath(
      parked,
      Paint()
        ..color = const Color(0xFF294A69)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawCircle(const Offset(36, 138), 6, Paint()..color = const Color(0xFF203D5A));
    canvas.drawCircle(const Offset(73, 138), 6, Paint()..color = const Color(0xFF203D5A));

    final person = Paint()
      ..color = const Color(0xFF254764)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(261, 85), const Offset(261, 117), person);
    canvas.drawLine(const Offset(253, 101), const Offset(261, 92), person);
    canvas.drawLine(const Offset(269, 101), const Offset(261, 92), person);
    canvas.drawLine(const Offset(254, 130), const Offset(261, 117), person);
    canvas.drawLine(const Offset(268, 130), const Offset(261, 117), person);
    canvas.drawCircle(const Offset(261, 80), 5, Paint()..color = const Color(0xFF254764));

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
