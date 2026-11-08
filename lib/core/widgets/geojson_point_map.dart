import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Simple GeoJSON `FeatureCollection` point map (lon/lat) without tile services.
class GeoJsonPointMap extends StatelessWidget {
  const GeoJsonPointMap({
    super.key,
    required this.features,
    this.height = 220,
    this.onFeatureTap,
  });

  final List<dynamic> features;
  final double height;
  final void Function(Map<String, dynamic> properties)? onFeatureTap;

  @override
  Widget build(BuildContext context) {
    final points = <_GeoPoint>[];
    for (final f in features) {
      if (f is! Map) continue;
      final geom = f['geometry'];
      final props = f['properties'];
      if (geom is Map && geom['type'] == 'Point') {
        final coords = geom['coordinates'];
        if (coords is List && coords.length >= 2) {
          final lon = (coords[0] as num).toDouble();
          final lat = (coords[1] as num).toDouble();
          points.add(
            _GeoPoint(
              lon: lon,
              lat: lat,
              properties: props is Map ? Map<String, dynamic>.from(props) : const {},
            ),
          );
        }
      }
    }
    final color = Theme.of(context).colorScheme.primary;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: points.isEmpty
            ? const Center(child: Text('—'))
            : InteractiveViewer(
                minScale: 0.8,
                maxScale: 4,
                child: CustomPaint(
                  painter: _GeoPainter(points: points, dotColor: color),
                  child: Stack(
                    children: [
                      for (var i = 0; i < points.length; i++)
                        _HitTarget(
                          point: points[i],
                          index: i,
                          total: points.length,
                          onTap: onFeatureTap,
                        ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class _GeoPoint {
  const _GeoPoint({required this.lon, required this.lat, required this.properties});
  final double lon;
  final double lat;
  final Map<String, dynamic> properties;
}

class _GeoPainter extends CustomPainter {
  _GeoPainter({required this.points, required this.dotColor});

  final List<_GeoPoint> points;
  final Color dotColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;
    final lons = points.map((p) => p.lon);
    final lats = points.map((p) => p.lat);
    final minLon = lons.reduce(math.min);
    final maxLon = lons.reduce(math.max);
    final minLat = lats.reduce(math.min);
    final maxLat = lats.reduce(math.max);
    final lonSpan = (maxLon - minLon).abs() < 1e-6 ? 0.01 : (maxLon - minLon);
    final latSpan = (maxLat - minLat).abs() < 1e-6 ? 0.01 : (maxLat - minLat);

    final paint = Paint()..color = dotColor;
    for (final p in points) {
      final x = ((p.lon - minLon) / lonSpan) * (size.width - 24) + 12;
      final y = size.height - (((p.lat - minLat) / latSpan) * (size.height - 24) + 12);
      canvas.drawCircle(Offset(x, y), 6, paint);
      canvas.drawCircle(Offset(x, y), 10, paint..color = dotColor.withValues(alpha: 0.25));
      paint.color = dotColor;
    }
  }

  @override
  bool shouldRepaint(covariant _GeoPainter oldDelegate) =>
      oldDelegate.points != points || oldDelegate.dotColor != dotColor;
}

class _HitTarget extends StatelessWidget {
  const _HitTarget({
    required this.point,
    required this.index,
    required this.total,
    this.onTap,
  });

  final _GeoPoint point;
  final int index;
  final int total;
  final void Function(Map<String, dynamic> properties)? onTap;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
