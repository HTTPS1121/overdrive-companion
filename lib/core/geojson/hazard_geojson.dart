import 'package:latlong2/latlong.dart';

class HazardMapPoint {
  const HazardMapPoint({
    required this.position,
    required this.properties,
  });

  final LatLng position;
  final Map<String, dynamic> properties;
}

/// Parses GeoJSON `FeatureCollection.features` or a bare feature list into hazard points.
List<HazardMapPoint> parseHazardGeoJsonFeatures(List<dynamic> raw) {
  final points = <HazardMapPoint>[];
  for (final f in raw) {
    if (f is! Map) continue;
    final geom = f['geometry'];
    if (geom is! Map) continue;
    final type = geom['type']?.toString();
    if (type != 'Point') continue;
    final coords = geom['coordinates'];
    if (coords is! List || coords.length < 2) continue;
    final a = coords[0];
    final b = coords[1];
    if (a is! num || b is! num) continue;
    // GeoJSON order is [longitude, latitude].
    final lon = a.toDouble();
    final lat = b.toDouble();
    final props = f['properties'];
    points.add(
      HazardMapPoint(
        position: LatLng(lat, lon),
        properties: props is Map ? Map<String, dynamic>.from(props) : const {},
      ),
    );
  }
  return points;
}

List<HazardMapPoint> parseHazardGeoJsonDocument(Map<String, dynamic>? json) {
  if (json == null) return const [];
  final features = json['features'];
  if (features is List) return parseHazardGeoJsonFeatures(features);
  if (json['type']?.toString() == 'Feature' && json['geometry'] != null) {
    return parseHazardGeoJsonFeatures([json]);
  }
  return const [];
}
