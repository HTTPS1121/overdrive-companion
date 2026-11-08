class AutomationEntry {
  AutomationEntry({required this.id, required this.name, this.mode, this.enabled});

  factory AutomationEntry.fromJson(Map<String, dynamic> json) => AutomationEntry(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? json['id']?.toString() ?? '',
        mode: json['mode']?.toString(),
        enabled: json['enabled'] as bool?,
      );

  final String id;
  final String name;
  final String? mode;
  final bool? enabled;
}

class AutomationsListState {
  AutomationsListState({required this.success, this.automations = const []});

  factory AutomationsListState.fromJson(Map<String, dynamic> json) {
    final list = <AutomationEntry>[];
    final raw = json['automations'] ?? json['items'];
    if (raw is List) {
      for (final e in raw) {
        if (e is Map<String, dynamic>) list.add(AutomationEntry.fromJson(e));
      }
    }
    return AutomationsListState(
      success: json['success'] == true || list.isNotEmpty,
      automations: list,
    );
  }

  final bool success;
  final List<AutomationEntry> automations;
}

class ParkingStatusState {
  ParkingStatusState({
    required this.success,
    this.enabled,
    this.openSessionId,
    this.latestSessionId,
  });

  factory ParkingStatusState.fromJson(Map<String, dynamic> json) {
    final open = json['openSession'];
    final latest = json['latestSession'];
    return ParkingStatusState(
      success: json['success'] == true,
      enabled: json['enabled'] as bool? ?? (json['config'] as Map?)?['enabled'] as bool?,
      openSessionId: open is Map ? open['id']?.toString() : null,
      latestSessionId: latest is Map ? latest['id']?.toString() : null,
    );
  }

  final bool success;
  final bool? enabled;
  final String? openSessionId;
  final String? latestSessionId;
}

class ParkingSessionEntry {
  ParkingSessionEntry({required this.id, this.startedAt, this.endedAt, this.place});

  factory ParkingSessionEntry.fromJson(Map<String, dynamic> json) => ParkingSessionEntry(
        id: json['id']?.toString() ?? '',
        startedAt: json['startedAt']?.toString(),
        endedAt: json['endedAt']?.toString(),
        place: json['place']?.toString(),
      );

  final String id;
  final String? startedAt;
  final String? endedAt;
  final String? place;
}

class TripEntry {
  TripEntry({required this.id, this.label, this.distanceKm, this.startedAt});

  factory TripEntry.fromJson(Map<String, dynamic> json) => TripEntry(
        id: json['id']?.toString() ?? '',
        label: json['label']?.toString() ?? json['name']?.toString(),
        distanceKm: (json['distanceKm'] as num?)?.toDouble(),
        startedAt: json['startTime']?.toString() ?? json['startedAt']?.toString(),
      );

  final String id;
  final String? label;
  final double? distanceKm;
  final String? startedAt;
}

class AudioLibraryEntry {
  AudioLibraryEntry({required this.name, this.sizeBytes});

  factory AudioLibraryEntry.fromJson(Map<String, dynamic> json) => AudioLibraryEntry(
        name: json['name']?.toString() ?? '',
        sizeBytes: (json['size'] as num?)?.toInt() ?? (json['sizeBytes'] as num?)?.toInt(),
      );

  final String name;
  final int? sizeBytes;
}

class TelegramStatusState {
  TelegramStatusState({
    required this.success,
    this.configured,
    this.paired,
    this.botUsername,
    this.videoUploads,
  });

  factory TelegramStatusState.fromJson(Map<String, dynamic> json) => TelegramStatusState(
        success: json['success'] == true,
        configured: json['configured'] as bool?,
        paired: json['paired'] as bool?,
        botUsername: json['botUsername']?.toString(),
        videoUploads: json['videoUploads'] as bool?,
      );

  final bool success;
  final bool? configured;
  final bool? paired;
  final String? botUsername;
  final bool? videoUploads;
}

class GenAiRoutinesState {
  GenAiRoutinesState({
    required this.success,
    this.enabled,
    this.pendingSuggestions = const [],
  });

  factory GenAiRoutinesState.fromJson(Map<String, dynamic> json) {
    final suggestions = <String>[];
    final raw = json['suggestions'] ?? json['pending'];
    if (raw is List) {
      for (final e in raw) {
        if (e is Map) {
          suggestions.add(e['title']?.toString() ?? e['id']?.toString() ?? '');
        } else {
          suggestions.add(e.toString());
        }
      }
    }
    return GenAiRoutinesState(
      success: json['success'] == true || json.containsKey('enabled'),
      enabled: json['enabled'] as bool? ?? json['routineLearningEnabled'] as bool?,
      pendingSuggestions: suggestions,
    );
  }

  final bool success;
  final bool? enabled;
  final List<String> pendingSuggestions;
}

class GenAiIncidentPack {
  GenAiIncidentPack({required this.id, this.title, this.createdAt});

  factory GenAiIncidentPack.fromJson(Map<String, dynamic> json) => GenAiIncidentPack(
        id: json['id']?.toString() ?? json['packId']?.toString() ?? '',
        title: json['title']?.toString(),
        createdAt: json['createdAt']?.toString(),
      );

  final String id;
  final String? title;
  final String? createdAt;
}
