class GpsSnapshot {
  const GpsSnapshot({
    required this.success,
    this.canSpeedKmh,
    this.hasLocation = false,
  });

  factory GpsSnapshot.fromJson(Map<String, dynamic> json) {
    final loc = json['location'] as Map<String, dynamic>?;
    return GpsSnapshot(
      success: json['success'] == true,
      canSpeedKmh: (loc?['canSpeedKmh'] as num?)?.toDouble(),
      hasLocation: loc != null && loc.isNotEmpty,
    );
  }

  final bool success;
  final double? canSpeedKmh;
  final bool hasLocation;

  bool? get isDriving {
    if (canSpeedKmh == null) return null;
    return canSpeedKmh! > 1;
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'location': {
          if (canSpeedKmh != null) 'canSpeedKmh': canSpeedKmh,
          if (hasLocation) 'lat': -32.0,
          if (hasLocation) 'lng': 34.8,
        },
      };
}
