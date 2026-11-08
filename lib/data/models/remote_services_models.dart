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
      success: json['success'] == true || json.containsKey('reachable'),
      online: json['online'] as bool?,
      audioReady: ready('audio') ?? json['audioReady'] as bool?,
      messagesReady: ready('message') ?? json['messagesReady'] as bool?,
      listenerReady: ready('listener') ?? json['listenerReady'] as bool?,
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
      success: json['success'] == true || json.containsKey('enabled'),
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
    this.exposeDashboard,
    this.raw = const {},
  });

  factory WireGuardStatusState.fromJson(Map<String, dynamic> json) {
    return WireGuardStatusState(
      success: json['success'] == true || json.containsKey('configured'),
      configured: json['configured'] as bool?,
      running: json['running'] as bool?,
      summary: json['summary']?.toString(),
      exposeDashboard: json['expose_dashboard'] as bool?,
      raw: json,
    );
  }

  final bool success;
  final bool? configured;
  final bool? running;
  final String? summary;
  final bool? exposeDashboard;
  final Map<String, dynamic> raw;
}

class SurveillanceHeatmapQuadrant {
  const SurveillanceHeatmapQuadrant({
    required this.id,
    this.name,
    this.enabled,
    this.activeBlocks,
    this.threatLevel,
    this.confidence = const [],
  });

  factory SurveillanceHeatmapQuadrant.fromJson(Map<String, dynamic> json) {
    final conf = <double>[];
    final raw = json['confidence'];
    if (raw is List) {
      for (final v in raw) {
        if (v is num) conf.add(v.toDouble());
      }
    }
    return SurveillanceHeatmapQuadrant(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString(),
      enabled: json['enabled'] as bool?,
      activeBlocks: (json['activeBlocks'] as num?)?.toInt(),
      threatLevel: (json['threatLevel'] as num?)?.toInt(),
      confidence: conf,
    );
  }

  final int id;
  final String? name;
  final bool? enabled;
  final int? activeBlocks;
  final int? threatLevel;
  final List<double> confidence;
}

class SurveillanceHeatmapState {
  const SurveillanceHeatmapState({
    required this.success,
    this.viewMode,
    this.quadrants = const [],
    this.gridCols,
    this.gridRows,
    this.pngBytes,
    this.error,
  });

  factory SurveillanceHeatmapState.fromJson(Map<String, dynamic> json) {
    final rawQuadrants = json['quadrants'];
    final quadrants = <SurveillanceHeatmapQuadrant>[];
    if (rawQuadrants is List) {
      for (final q in rawQuadrants) {
        if (q is Map<String, dynamic>) {
          quadrants.add(SurveillanceHeatmapQuadrant.fromJson(q));
        }
      }
    }
    return SurveillanceHeatmapState(
      success: json['success'] == true || quadrants.isNotEmpty || json.containsKey('viewMode'),
      viewMode: (json['viewMode'] as num?)?.toInt(),
      quadrants: quadrants,
      gridCols: (json['gridCols'] as num?)?.toInt(),
      gridRows: (json['gridRows'] as num?)?.toInt(),
      error: json['error']?.toString(),
    );
  }

  factory SurveillanceHeatmapState.png(List<int> bytes) {
    return SurveillanceHeatmapState(success: true, pngBytes: bytes);
  }

  final bool success;
  final int? viewMode;
  final List<SurveillanceHeatmapQuadrant> quadrants;
  final int? gridCols;
  final int? gridRows;
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
      success: json['success'] == true || json.containsKey('entries') || json.containsKey('lines'),
      lines: lines,
      error: json['error']?.toString(),
    );
  }

  final bool success;
  final List<String> lines;
  final String? error;
}
