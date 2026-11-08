class StreamStatusState {
  StreamStatusState({
    required this.success,
    this.enabled,
    this.connected,
    this.viewMode,
    this.quality,
    this.error,
    this.raw = const {},
  });

  factory StreamStatusState.fromJson(Map<String, dynamic> json) {
    return StreamStatusState(
      success: json['success'] == true,
      enabled: json['enabled'] as bool?,
      connected: json['connected'] as bool?,
      viewMode: (json['viewMode'] as num?)?.toInt() ?? (json['view'] as num?)?.toInt(),
      quality: json['quality']?.toString(),
      error: json['error'] as String?,
      raw: json,
    );
  }

  final bool success;
  final bool? enabled;
  final bool? connected;
  final int? viewMode;
  final String? quality;
  final String? error;
  final Map<String, dynamic> raw;
}

class RecordingEntry {
  RecordingEntry({
    required this.filename,
    this.timestamp,
    this.place,
    this.durationSec,
    this.sizeBytes,
  });

  factory RecordingEntry.fromJson(Map<String, dynamic> json) {
    return RecordingEntry(
      filename: json['filename']?.toString() ?? json['name']?.toString() ?? '',
      timestamp: json['timestamp']?.toString(),
      place: json['place']?.toString(),
      durationSec: (json['durationSec'] as num?)?.toInt(),
      sizeBytes: (json['sizeBytes'] as num?)?.toInt(),
    );
  }

  final String filename;
  final String? timestamp;
  final String? place;
  final int? durationSec;
  final int? sizeBytes;
}

class RecordingsListState {
  RecordingsListState({
    required this.success,
    this.recordings = const [],
    this.error,
  });

  factory RecordingsListState.fromJson(Map<String, dynamic> json) {
    final list = <RecordingEntry>[];
    final raw = json['recordings'] ?? json['items'];
    if (raw is List) {
      for (final e in raw) {
        if (e is Map<String, dynamic>) list.add(RecordingEntry.fromJson(e));
      }
    }
    return RecordingsListState(
      success: json['success'] == true,
      recordings: list,
      error: json['error'] as String?,
    );
  }

  final bool success;
  final List<RecordingEntry> recordings;
  final String? error;
}

class SurveillanceStatusState {
  SurveillanceStatusState({
    required this.success,
    this.enabled,
    this.error,
  });

  factory SurveillanceStatusState.fromJson(Map<String, dynamic> json) {
    return SurveillanceStatusState(
      success: json['success'] == true,
      enabled: json['enabled'] as bool?,
      error: json['error'] as String?,
    );
  }

  final bool success;
  final bool? enabled;
  final String? error;
}
