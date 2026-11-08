import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../layout/screenshot_scope.dart';
import '../l10n/l10n_x.dart';

/// GeoJSON `FeatureCollection` hazards on OSM tiles (online) or lat/lon grid (offline / fixtures).
class GeoJsonPointMap extends StatefulWidget {
  const GeoJsonPointMap({
    super.key,
    required this.features,
    this.height = 260,
    this.onFeatureTap,
  });

  final List<dynamic> features;
  final double height;
  final void Function(Map<String, dynamic> properties)? onFeatureTap;

  @override
  State<GeoJsonPointMap> createState() => _GeoJsonPointMapState();
}

class _GeoJsonPointMapState extends State<GeoJsonPointMap> {
  final MapController _controller = MapController();
  bool _tileLoadFailed = false;

  List<_HazardPoint> _parsePoints() {
    final points = <_HazardPoint>[];
    for (final f in widget.features) {
      if (f is! Map) continue;
      final geom = f['geometry'];
      final props = f['properties'];
      if (geom is Map && geom['type'] == 'Point') {
        final coords = geom['coordinates'];
        if (coords is List && coords.length >= 2) {
          final lon = (coords[0] as num).toDouble();
          final lat = (coords[1] as num).toDouble();
          points.add(
            _HazardPoint(
              position: LatLng(lat, lon),
              properties: props is Map ? Map<String, dynamic>.from(props) : const {},
            ),
          );
        }
      }
    }
    return points;
  }

  LatLngBounds _boundsFor(List<_HazardPoint> points) {
    const pad = 0.018;
    if (points.isEmpty) {
      return LatLngBounds(const LatLng(32.08, 34.78), const LatLng(32.085, 34.785));
    }
    var minLat = points.first.position.latitude;
    var maxLat = minLat;
    var minLon = points.first.position.longitude;
    var maxLon = minLon;
    for (final p in points) {
      minLat = math.min(minLat, p.position.latitude);
      maxLat = math.max(maxLat, p.position.latitude);
      minLon = math.min(minLon, p.position.longitude);
      maxLon = math.max(maxLon, p.position.longitude);
    }
    if ((maxLat - minLat).abs() < 1e-5) {
      minLat -= pad;
      maxLat += pad;
    } else {
      final latPad = (maxLat - minLat) * 0.2;
      minLat -= latPad;
      maxLat += latPad;
    }
    if ((maxLon - minLon).abs() < 1e-5) {
      minLon -= pad;
      maxLon += pad;
    } else {
      final lonPad = (maxLon - minLon) * 0.2;
      minLon -= lonPad;
      maxLon += lonPad;
    }
    return LatLngBounds(LatLng(minLat, minLon), LatLng(maxLat, maxLon));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final points = _parsePoints();
    final bounds = _boundsFor(points);
    final center = LatLng(
      (bounds.north + bounds.south) / 2,
      (bounds.east + bounds.west) / 2,
    );
    final fixtureOrOffline = ScreenshotScope.of(context);
    final useTiles = !fixtureOrOffline && !_tileLoadFailed;
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: widget.height,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                FlutterMap(
                  mapController: _controller,
                  options: MapOptions(
                    backgroundColor: Colors.transparent,
                    initialCenter: center,
                    initialZoom: 14,
                    initialCameraFit: CameraFit.bounds(
                      bounds: bounds,
                      padding: const EdgeInsets.all(28),
                    ),
                    onMapReady: () {
                      _controller.fitCamera(
                        CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(28)),
                      );
                    },
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                    ),
                  ),
                  children: [
                    if (useTiles)
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.overdrive.companion',
                        errorTileCallback: (tile, error, stackTrace) {
                          if (!_tileLoadFailed && mounted) {
                            setState(() => _tileLoadFailed = true);
                          }
                        },
                      ),
                    MarkerLayer(
                      markers: [
                        for (final p in points)
                          Marker(
                            point: p.position,
                            width: 44,
                            height: 44,
                            child: Tooltip(
                              message: p.properties['kind']?.toString() ?? p.properties['id']?.toString() ?? '',
                              child: Icon(Icons.place, color: theme.colorScheme.error, size: 36),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                if (!useTiles)
                  IgnorePointer(
                    child: CustomPaint(
                      painter: _LatLonGridPainter(
                        bounds: bounds,
                        color: theme.colorScheme.outline.withValues(alpha: 0.35),
                        labelColor: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                Positioned(
                  left: 8,
                  top: 8,
                  right: 8,
                  child: Material(
                    color: theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      child: Text(
                        useTiles ? l10n.roadSenseMapOnline : l10n.roadSenseMapOfflineGrid,
                        style: theme.textTheme.labelMedium,
                      ),
                    ),
                  ),
                ),
                if (points.isNotEmpty)
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: Material(
                      color: theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(6),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Text(
                          l10n.roadSenseMapCoordSummary(
                            points.first.position.latitude.toStringAsFixed(4),
                            points.first.position.longitude.toStringAsFixed(4),
                          ),
                          style: theme.textTheme.labelSmall,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (points.isEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(l10n.integrationsEmptyList, textAlign: TextAlign.center),
            ),
        ],
      ),
    );
  }
}

class _HazardPoint {
  const _HazardPoint({required this.position, required this.properties});
  final LatLng position;
  final Map<String, dynamic> properties;
}

/// Lat/lon grid drawn when basemap tiles are unavailable (fixtures / offline).
class _LatLonGridPainter extends CustomPainter {
  _LatLonGridPainter({
    required this.bounds,
    required this.color,
    required this.labelColor,
  });

  final LatLngBounds bounds;
  final Color color;
  final Color labelColor;

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = const Color(0xFFE8ECEF);
    canvas.drawRect(Offset.zero & size, bg);

    final gridPaint = Paint()
      ..color = color
      ..strokeWidth = 1;

    const lines = 5;
    for (var i = 0; i <= lines; i++) {
      final y = size.height * i / lines;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
      final x = size.width * i / lines;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    final latSpan = bounds.north - bounds.south;
    final lonSpan = bounds.east - bounds.west;
    final tp = TextPainter(textDirection: TextDirection.ltr);
    for (var i = 0; i <= lines; i++) {
      final lat = bounds.south + latSpan * (1 - i / lines);
      final lon = bounds.west + lonSpan * (i / lines);
      final latLabel = lat.toStringAsFixed(3);
      final lonLabel = lon.toStringAsFixed(3);
      tp.text = TextSpan(text: latLabel, style: TextStyle(fontSize: 9, color: labelColor));
      tp.layout();
      tp.paint(canvas, Offset(4, size.height * i / lines - 4));
      if (i == 0 || i == lines) {
        tp.text = TextSpan(text: lonLabel, style: TextStyle(fontSize: 9, color: labelColor));
        tp.layout();
        tp.paint(canvas, Offset(size.width * i / lines + 2, size.height - 14));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _LatLonGridPainter oldDelegate) =>
      oldDelegate.bounds != bounds || oldDelegate.color != color;
}
