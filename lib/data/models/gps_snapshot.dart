class GpsSnapshot {
  const GpsSnapshot({
    required this.success,
    this.latitude,
    this.longitude,
    this.canSpeedKmh,
    this.headingDeg,
    this.altitudeM,
    this.accuracyM,
  });

  factory GpsSnapshot.fromJson(Map<String, dynamic> json) {
    final loc = json['location'] as Map<String, dynamic>?;
    double? coord(String a, String b) {
      final v = loc?[a] ?? loc?[b];
      return (v as num?)?.toDouble();
    }

    return GpsSnapshot(
      success: json['success'] == true,
      latitude: coord('lat', 'latitude'),
      longitude: coord('lng', 'longitude'),
      canSpeedKmh: (loc?['canSpeedKmh'] as num?)?.toDouble(),
      headingDeg: (loc?['heading'] as num?)?.toDouble(),
      altitudeM: (loc?['altitude'] as num?)?.toDouble(),
      accuracyM: (loc?['accuracy'] as num?)?.toDouble(),
    );
  }

  final bool success;
  final double? latitude;
  final double? longitude;
  final double? canSpeedKmh;
  final double? headingDeg;
  final double? altitudeM;
  final double? accuracyM;

  bool get hasLocation => latitude != null && longitude != null;

  bool? get isDriving {
    if (canSpeedKmh == null) return null;
    return canSpeedKmh! > 1;
  }

  String get coordinatesLabel {
    if (!hasLocation) return '—';
    return '${latitude!.toStringAsFixed(5)}, ${longitude!.toStringAsFixed(5)}';
  }

  String get staticMapUrl {
    if (!hasLocation) return '';
    final lat = latitude!;
    final lng = longitude!;
    return 'https://staticmap.openstreetmap.de/staticmap.php'
        '?center=$lat,$lng&zoom=15&size=600x280&markers=$lat,$lng';
  }

  String get navigationUri {
    if (!hasLocation) return '';
    return 'geo:$latitude,$longitude?q=$latitude,$longitude';
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'location': {
          if (latitude != null) 'lat': latitude,
          if (longitude != null) 'lng': longitude,
          if (canSpeedKmh != null) 'canSpeedKmh': canSpeedKmh,
          if (headingDeg != null) 'heading': headingDeg,
        },
      };
}
