import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';

/// Stroke icons from `paths` in overdrive-chosen.html (24×24, stroke 1.5).
enum OdIconName {
  user,
  menu,
  home,
  camera,
  record,
  trip,
  more,
  lock,
  unlock,
  power,
  off,
  flash,
  pin,
  trunk,
  down,
  battery,
  shield,
  settings,
  wave,
  link,
  window,
  climate,
  tire,
}

const _paths = <OdIconName, String>{
  OdIconName.user: 'M20 21v-2a7 7 0 0 0-14 0v2M16 7a4 4 0 1 1-8 0 4 4 0 0 1 8 0',
  OdIconName.menu: 'M4 6h16M4 12h16M4 18h16',
  OdIconName.home: 'm3 11 9-8 9 8M5 10v11h5v-7h4v7h5V10',
  OdIconName.camera: 'M15 10l6-4v12l-6-4M3 6h12v12H3z',
  OdIconName.record: 'M4 3h16v18H4zM8 3v18M16 3v18M8 8h8M8 16h8',
  OdIconName.trip: 'M5 6a2 2 0 1 0 0 .1M19 18a2 2 0 1 0 0 .1M7 6h8a4 4 0 0 1 0 8H9a4 4 0 0 0 0 8h8',
  OdIconName.more: 'M4 6h16M4 12h16M4 18h16',
  OdIconName.lock: 'M6 10h12v11H6zM8 10V6a4 4 0 0 1 8 0v4',
  OdIconName.unlock: 'M6 10h12v11H6zM8 10V6a4 4 0 0 1 7-3',
  OdIconName.power: 'M12 2v10M6 5a9 9 0 1 0 12 0',
  OdIconName.off:
      'M12 2v9M6 5a9 9 0 0 0-2 12M18 5a9 9 0 0 1 2 12M3 3l18 18',
  OdIconName.flash: 'm13 2-9 12h7l-1 8 10-13h-8z',
  OdIconName.pin: 'M20 10c0 6-8 12-8 12S4 16 4 10a8 8 0 1 1 16 0M15 10a3 3 0 1 1-6 0 3 3 0 0 1 6 0',
  OdIconName.trunk: 'M3 13h18v7H3zM5 13V9l14-6v10M8 17h8',
  OdIconName.down: 'M3 11h18v9H3zM12 2v7m-4-4 4 4 4-4',
  OdIconName.battery: 'M4 6h16v15H4zM9 3h6M7 10h10M7 14h7',
  OdIconName.shield: 'm12 2 9 4v6c0 5-9 10-9 10S3 17 3 12V6zM8 12l3 3 5-6',
  OdIconName.settings: 'M4 7h16M4 17h16M8 4v6M16 14v6',
  OdIconName.wave: 'm2 12 4-6 4 12 4-12 4 12 4-6',
  OdIconName.link:
      'M10 14l4-4M9 16l-2 2a4 4 0 0 1-5-5l5-5a4 4 0 0 1 5 0M15 8l2-2a4 4 0 0 1 5 5l-5 5a4 4 0 0 1-5 0',
  OdIconName.window: 'M4 7h16v13H4zM7 7V5h10v2M9 12h6',
  OdIconName.climate:
      'M12 4v3M12 17v3M6.3 7.3l2.2 2.1M15.5 14.6l2.2 2.1M4 12h3M17 12h3M6.3 16.7l2.2-2.1M15.5 9.4l2.2-2.1M12 9a3 3 0 1 0 0 6',
  OdIconName.tire: 'M12 18a6 6 0 1 0 0-.1M8.5 18h7',
};

class OdIcon extends StatelessWidget {
  const OdIcon(this.name, {super.key, this.size = 23, this.color});

  final OdIconName name;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
  final d = _paths[name] ?? _paths[OdIconName.settings]!;
    return CustomPaint(
      size: Size.square(size),
      painter: _OdStrokePainter(
        pathData: d,
        color: color ?? Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

class _OdStrokePainter extends CustomPainter {
  _OdStrokePainter({required this.pathData, required this.color});

  final String pathData;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = parseSvgPathData(pathData);
    final bounds = path.getBounds();
    final scale = size.width / 24;
    canvas.save();
    canvas.scale(scale, scale);
    if (bounds.width > 0 && bounds.height > 0) {
      // paths are authored in 24×24 viewBox
    }
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _OdStrokePainter oldDelegate) =>
      oldDelegate.pathData != pathData || oldDelegate.color != color;
}
