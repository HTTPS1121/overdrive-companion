class CommunicateStatusState {
  const CommunicateStatusState({
    required this.success,
    this.online,
    this.audioReady,
    this.messagesReady,
    this.listenerReady,
    this.busy,
    this.carState,
    this.raw = const {},
  });

  factory CommunicateStatusState.fromJson(Map<String, dynamic> json) {
    bool? ready(String k) {
      final v = json[k];
      if (v is Map<String, dynamic>) return v['ready'] as bool?;
      return json['${k}Ready'] as bool?;
    }

    return CommunicateStatusState(
      success: json['success'] == true,
      online: json['online'] as bool?,
      audioReady: ready('audio'),
      messagesReady: ready('message'),
      listenerReady: ready('listener'),
      busy: json['busy'] as bool?,
      carState: json['carState']?.toString(),
      raw: json,
    );
  }

  final bool success;
  final bool? online;
  final bool? audioReady;
  final bool? messagesReady;
  final bool? listenerReady;
  final bool? busy;
  final String? carState;
  final Map<String, dynamic> raw;
}

class CommunicateSettingsState {
  const CommunicateSettingsState({
    required this.success,
    this.voiceEnabled,
    this.messagesEnabled,
    this.listenerEnabled,
    this.emergencyDisabled,
    this.raw = const {},
  });

  factory CommunicateSettingsState.fromJson(Map<String, dynamic> json) {
    return CommunicateSettingsState(
      success: json['success'] == true,
      voiceEnabled: json['voiceEnabled'] as bool? ?? json['audioEnabled'] as bool?,
      messagesEnabled: json['messagesEnabled'] as bool?,
      listenerEnabled: json['listenerEnabled'] as bool?,
      emergencyDisabled: json['emergencyDisabled'] as bool?,
      raw: json,
    );
  }

  final bool success;
  final bool? voiceEnabled;
  final bool? messagesEnabled;
  final bool? listenerEnabled;
  final bool? emergencyDisabled;
  final Map<String, dynamic> raw;
}

class GenAiStatusState {
  const GenAiStatusState({
    required this.success,
    this.enabled,
    this.model,
    this.voiceSessions,
    this.raw = const {},
  });

  factory GenAiStatusState.fromJson(Map<String, dynamic> json) {
    return GenAiStatusState(
      success: json['success'] == true,
      enabled: json['enabled'] as bool?,
      model: json['model']?.toString(),
      voiceSessions: (json['voiceSessions'] as num?)?.toInt(),
      raw: json,
    );
  }

  final bool success;
  final bool? enabled;
  final String? model;
  final int? voiceSessions;
  final Map<String, dynamic> raw;
}

class GenAiConfigState {
  const GenAiConfigState({
    required this.success,
    this.configured,
    this.provider,
    this.raw = const {},
  });

  factory GenAiConfigState.fromJson(Map<String, dynamic> json) {
    return GenAiConfigState(
      success: json['success'] == true,
      configured: json['configured'] as bool?,
      provider: json['provider']?.toString(),
      raw: json,
    );
  }

  final bool success;
  final bool? configured;
  final String? provider;
  final Map<String, dynamic> raw;
}

class GenAiChatResult {
  const GenAiChatResult({
    required this.success,
    this.reply,
    this.error,
  });

  factory GenAiChatResult.fromJson(Map<String, dynamic> json) {
    return GenAiChatResult(
      success: json['success'] == true,
      reply: json['reply']?.toString() ?? json['message']?.toString(),
      error: json['error']?.toString(),
    );
  }

  final bool success;
  final String? reply;
  final String? error;
}

class WireGuardStatusState {
  const WireGuardStatusState({
    required this.success,
    this.configured,
    this.running,
    this.summary,
    this.raw = const {},
  });

  factory WireGuardStatusState.fromJson(Map<String, dynamic> json) {
    return WireGuardStatusState(
      success: json['success'] == true,
      configured: json['configured'] as bool?,
      running: json['running'] as bool?,
      summary: json['summary']?.toString(),
      raw: json,
    );
  }

  final bool success;
  final bool? configured;
  final bool? running;
  final String? summary;
  final Map<String, dynamic> raw;
}

class SurveillanceHeatmapState {
  const SurveillanceHeatmapState({
    required this.success,
    this.width,
    this.height,
    this.cells,
    this.pngBytes,
    this.error,
  });

  factory SurveillanceHeatmapState.fromJson(Map<String, dynamic> json) {
    return SurveillanceHeatmapState(
      success: json['success'] == true,
      width: (json['width'] as num?)?.toInt(),
      height: (json['height'] as num?)?.toInt(),
      cells: json['cells'] as List<dynamic>?,
      error: json['error']?.toString(),
    );
  }

  factory SurveillanceHeatmapState.png(List<int> bytes) {
    return SurveillanceHeatmapState(success: true, pngBytes: bytes);
  }

  final bool success;
  final int? width;
  final int? height;
  final List<dynamic>? cells;
  final List<int>? pngBytes;
  final String? error;
}

class SurveillanceFilterLogState {
  const SurveillanceFilterLogState({
    required this.success,
    this.lines = const [],
    this.error,
  });

  factory SurveillanceFilterLogState.fromJson(Map<String, dynamic> json) {
    final raw = json['lines'] ?? json['entries'];
    final lines = <String>[];
    if (raw is List) {
      for (final e in raw) {
        lines.add(e.toString());
      }
    }
    return SurveillanceFilterLogState(
      success: json['success'] == true,
      lines: lines,
      error: json['error']?.toString(),
    );
  }

  final bool success;
  final List<String> lines;
  final String? error;
}
