import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../geojson/hazard_geojson.dart';
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

  List<HazardMapPoint> _parsePoints() => parseHazardGeoJsonFeatures(widget.features);

  LatLngBounds _boundsFor(List<HazardMapPoint> points) {
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
              clipBehavior: Clip.hardEdge,
              children: [
                if (!useTiles)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _LatLonGridPainter(
                        bounds: bounds,
                        color: theme.colorScheme.outline.withValues(alpha: 0.35),
                        labelColor: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
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
                            alignment: Alignment.center,
                            child: IgnorePointer(
                              child: Icon(Icons.place, color: theme.colorScheme.error, size: 36),
                            ),
                          ),
                      ],
                    ),
                  ],
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
                        textDirection: TextDirection.ltr,
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
                          l10n.roadSenseMapMarkersSummary(points.length),
                          style: theme.textTheme.labelSmall,
                          textDirection: TextDirection.ltr,
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

/// Lat/lon grid drawn behind markers when basemap tiles are unavailable.
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
    canvas.save();
    canvas.clipRect(Offset.zero & size);

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
      if (i == 0 || i == lines) {
        final lat = bounds.south + latSpan * (1 - i / lines);
        final latLabel = lat.toStringAsFixed(3);
        tp.text = TextSpan(text: latLabel, style: TextStyle(fontSize: 9, color: labelColor));
        tp.layout();
        final y = (size.height * i / lines).clamp(2.0, size.height - tp.height - 2);
        tp.paint(canvas, Offset(6, y));
      }
    }
    for (var i in [0, lines]) {
      final lon = bounds.west + lonSpan * (i / lines);
      final lonLabel = lon.toStringAsFixed(3);
      tp.text = TextSpan(text: lonLabel, style: TextStyle(fontSize: 9, color: labelColor));
      tp.layout();
      final x = (size.width * i / lines + 4).clamp(4.0, size.width - tp.width - 4);
      tp.paint(canvas, Offset(x, size.height - tp.height - 4));
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _LatLonGridPainter oldDelegate) =>
      oldDelegate.bounds != bounds || oldDelegate.color != color;
}
