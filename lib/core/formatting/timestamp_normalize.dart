/// Normalizes vehicle/telemetry time fields (ISO, Unix s/ms/µs) to local [DateTime].
DateTime? parseVehicleTimestampValue(Object? raw) {
  if (raw == null) return null;
  if (raw is DateTime) return raw.toLocal();

  if (raw is num) {
    return _fromEpochNumber(raw.toDouble());
  }

  final text = raw.toString().trim();
  if (text.isEmpty) return null;

  final iso = DateTime.tryParse(text);
  if (iso != null) return iso.toLocal();

  final digits = RegExp(r'^-?\d+$').firstMatch(text);
  if (digits != null) {
    return _fromEpochNumber(double.parse(text));
  }

  return null;
}

DateTime? _fromEpochNumber(double n) {
  final abs = n.abs();
  // µs since epoch (e.g. 1.7e15)
  if (abs >= 1e14) {
    return DateTime.fromMicrosecondsSinceEpoch(n.round(), isUtc: true).toLocal();
  }
  // ms since epoch (e.g. 1.73e12)
  if (abs >= 1e11) {
    return DateTime.fromMillisecondsSinceEpoch(n.round(), isUtc: true).toLocal();
  }
  // seconds since epoch (e.g. 1.73e9)
  if (abs >= 1e9) {
    return DateTime.fromMillisecondsSinceEpoch((n * 1000).round(), isUtc: true).toLocal();
  }
  return null;
}
