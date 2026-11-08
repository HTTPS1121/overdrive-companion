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
    this.recordingId,
    this.timestamp,
    this.place,
    this.durationSec,
    this.sizeBytes,
    this.thumbUrl,
    this.videoUrl,
  });

  factory RecordingEntry.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? json['recordingId']?.toString();
    return RecordingEntry(
      filename: json['filename']?.toString() ?? json['name']?.toString() ?? '',
      recordingId: id,
      timestamp: json['timestamp']?.toString(),
      place: json['place']?.toString(),
      durationSec: (json['durationSec'] as num?)?.toInt(),
      sizeBytes: (json['sizeBytes'] as num?)?.toInt(),
      thumbUrl: json['thumbUrl']?.toString(),
      videoUrl: json['videoUrl']?.toString(),
    );
  }

  final String filename;
  final String? recordingId;
  final String? timestamp;
  final String? place;
  final int? durationSec;
  final int? sizeBytes;
  final String? thumbUrl;
  final String? videoUrl;

  /// Upstream prefers `/video/id/{32hex}` when id is present.
  String? get canonicalRecordingId =>
      (recordingId != null && _isHex32(recordingId!)) ? recordingId : null;

  static bool _isHex32(String v) => RegExp(r'^[0-9a-f]{32}$').hasMatch(v);
}

class RecordingsListState {
  RecordingsListState({
    required this.success,
    this.recordings = const [],
    this.error,
    this.totalCount,
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
      totalCount: (json['totalCount'] as num?)?.toInt(),
    );
  }

  final bool success;
  final List<RecordingEntry> recordings;
  final String? error;
  final int? totalCount;
}

class SurveillanceStatusState {
  SurveillanceStatusState({
    required this.success,
    this.enabled,
    this.error,
    this.raw = const {},
  });

  factory SurveillanceStatusState.fromJson(Map<String, dynamic> json) {
    return SurveillanceStatusState(
      success: json['success'] == true,
      enabled: json['enabled'] as bool?,
      error: json['error'] as String?,
      raw: json,
    );
  }

  final bool success;
  final bool? enabled;
  final String? error;
  final Map<String, dynamic> raw;
}

class SurveillanceConfigState {
  SurveillanceConfigState({
    required this.success,
    this.enabled,
    this.sensitivity,
    this.distance,
    this.raw = const {},
  });

  factory SurveillanceConfigState.fromJson(Map<String, dynamic> json) {
    return SurveillanceConfigState(
      success: json['success'] != false,
      enabled: json['enabled'] as bool?,
      sensitivity: (json['sensitivity'] as num?)?.toInt(),
      distance: (json['distance'] as num?)?.toInt(),
      raw: json,
    );
  }

  final bool success;
  final bool? enabled;
  final int? sensitivity;
  final int? distance;
  final Map<String, dynamic> raw;
}
