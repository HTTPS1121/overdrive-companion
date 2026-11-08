import '../../core/config/app_settings.dart';
import '../api/overdrive_api_client.dart';
import '../models/extended_services_models.dart';
import 'extended_endpoints.dart';

class ExtendedServicesRepository {
  ExtendedServicesRepository({
    required AppSettings settings,
    required OverdriveApiClient client,
  })  : _settings = settings,
        _client = client {
    _client.baseUrl = settings.baseUrl;
  }

  AppSettings _settings;
  final OverdriveApiClient _client;

  void updateSettings(AppSettings settings) {
    _settings = settings;
    _client.baseUrl = settings.baseUrl;
  }

  void setJwt(String? jwt) => _client.jwt = jwt;

  Future<AutomationsListState> listAutomations() async {
    final json = await _client.getJson(ExtendedEndpoints.automationsList);
    return AutomationsListState.fromJson(json);
  }

  Future<Map<String, dynamic>> fetchAutomationSchema() =>
      _client.getJson(ExtendedEndpoints.automationsSchema);

  Future<Map<String, dynamic>> fetchAutomationState() =>
      _client.getJson(ExtendedEndpoints.automationsState);

  Future<Map<String, dynamic>> fetchAutomationSettings() =>
      _client.getJson(ExtendedEndpoints.automationsSettings);

  Future<Map<String, dynamic>> saveAutomationSettings(Map<String, dynamic> body) =>
      _client.postJson(ExtendedEndpoints.automationsSettings, body: body);

  Future<Map<String, dynamic>> updateAutomation(
    String id, {
    required String name,
    bool? enabled,
    String? mode,
    List<Map<String, dynamic>>? rules,
    List<Map<String, dynamic>>? actions,
  }) =>
      _client.putJson(
        ExtendedEndpoints.automationsUpdate(id),
        body: {
          'name': name,
          if (enabled != null) 'enabled': enabled,
          if (mode != null) 'mode': mode,
          if (rules != null) 'rules': rules,
          if (actions != null) 'actions': actions,
        },
      );

  Future<Map<String, dynamic>> createAutomation({required String name, bool enabled = true}) =>
      _client.postJson(
        ExtendedEndpoints.automationsCreate,
        body: {
          'name': name,
          'enabled': enabled,
          'rules': <Map<String, dynamic>>[],
          'actions': <Map<String, dynamic>>[],
        },
      );

  Future<Map<String, dynamic>> deleteAutomation(String id) =>
      _client.deleteJson(ExtendedEndpoints.automationsDelete(id));

  Future<Map<String, dynamic>> testAutomation(String id) =>
      _client.postJson(ExtendedEndpoints.automationsTest(id));

  Future<Map<String, dynamic>> setAutomationMode(String id, String mode) =>
      _client.postJson(ExtendedEndpoints.automationsMode(id), body: {'mode': mode});

  Future<ParkingStatusState> fetchParkingStatus() async {
    final json = await _client.getJson(ExtendedEndpoints.parkingStatus);
    return ParkingStatusState.fromJson(json);
  }

  Future<Map<String, dynamic>> fetchParkingConfig() =>
      _client.getJson(ExtendedEndpoints.parkingConfig);

  Future<Map<String, dynamic>> saveParkingConfig({required bool enabled}) =>
      _client.postJson(ExtendedEndpoints.parkingConfig, body: {'enabled': enabled});

  Future<List<ParkingSessionEntry>> listParkingSessions() async {
    final json = await _client.getJson(ExtendedEndpoints.parkingSessions);
    final list = <ParkingSessionEntry>[];
    final raw = json['sessions'] ?? json['items'];
    if (raw is List) {
      for (final e in raw) {
        if (e is Map<String, dynamic>) list.add(ParkingSessionEntry.fromJson(e));
      }
    }
    return list;
  }

  Future<Map<String, dynamic>> deleteParkingSession(String id) =>
      _client.deleteJson(ExtendedEndpoints.parkingSession(id));

  Future<Map<String, dynamic>> fetchParkingSignage(String sessionId) =>
      _client.getJson(ExtendedEndpoints.parkingSignage(sessionId));

  Future<Map<String, dynamic>> saveParkingSignage(
    String sessionId, {
    required String message,
    bool? enabled,
  }) =>
      _client.postJson(
        ExtendedEndpoints.parkingSignage(sessionId),
        body: {
          'message': message,
          if (enabled != null) 'enabled': enabled,
        },
      );

  Future<List<TripEntry>> listTrips({int days = 14}) async {
    final json = await _client.getJson('${ExtendedEndpoints.tripsList}?days=$days');
    final list = <TripEntry>[];
    final raw = json['trips'] ?? json['items'];
    if (raw is List) {
      for (final e in raw) {
        if (e is Map<String, dynamic>) list.add(TripEntry.fromJson(e));
      }
    }
    return list;
  }

  Future<Map<String, dynamic>> fetchTripSummary() =>
      _client.getJson(ExtendedEndpoints.tripsSummary);

  Future<Map<String, dynamic>> deleteTrip(String id) =>
      _client.deleteJson(ExtendedEndpoints.tripDelete(id));

  Future<Map<String, dynamic>> fetchTripDetail(String id) =>
      _client.getJson(ExtendedEndpoints.tripDetail(id));

  Future<Map<String, dynamic>> fetchTripConfig() =>
      _client.getJson(ExtendedEndpoints.tripsConfig);

  Future<Map<String, dynamic>> saveTripConfig({required bool enabled, int? historyDays}) =>
      _client.postJson(
        ExtendedEndpoints.tripsConfig,
        body: {
          'enabled': enabled,
          if (historyDays != null) 'historyDays': historyDays,
        },
      );

  Future<Map<String, dynamic>> bootstrapTrips() =>
      _client.postJson(ExtendedEndpoints.tripsBootstrap);

  Future<Map<String, dynamic>> fetchAudioAvasState() =>
      _client.getJson(ExtendedEndpoints.audioAvasState);

  Future<Map<String, dynamic>> submitTelegramPin(String pin) =>
      _client.postJson(ExtendedEndpoints.telegramPin, body: {'pin': pin});

  Future<List<AudioLibraryEntry>> listAudioLibrary() async {
    final json = await _client.getJson(ExtendedEndpoints.audioLibrary);
    final list = <AudioLibraryEntry>[];
    final raw = json['library'] ?? json['items'] ?? json['files'];
    if (raw is List) {
      for (final e in raw) {
        if (e is Map<String, dynamic>) {
          list.add(AudioLibraryEntry.fromJson(e));
        } else if (e is String) {
          list.add(AudioLibraryEntry(name: e));
        }
      }
    }
    return list;
  }

  Future<Map<String, dynamic>> playAudioClip(String name) =>
      _client.postJson(ExtendedEndpoints.audioLibraryPlay, body: {'name': name});

  Future<Map<String, dynamic>> stopAudioPlayback() =>
      _client.postJson(ExtendedEndpoints.audioLibraryStop);

  Future<TelegramStatusState> fetchTelegramStatus() async {
    final json = await _client.getJson(ExtendedEndpoints.telegramStatus);
    return TelegramStatusState.fromJson(json);
  }

  Future<Map<String, dynamic>> saveTelegramPreferences({bool? videoUploads}) => _client.postJson(
        ExtendedEndpoints.telegramPreferences,
        body: {if (videoUploads != null) 'videoUploads': videoUploads},
      );

  Future<Map<String, dynamic>> clearTelegramOwner() =>
      _client.postJson(ExtendedEndpoints.telegramOwnerClear);

  Future<GenAiRoutinesState> fetchGenAiRoutines() async {
    final json = await _client.getJson(ExtendedEndpoints.genaiRoutines);
    return GenAiRoutinesState.fromJson(json);
  }

  Future<Map<String, dynamic>> saveGenAiRoutinesConfig({required bool enabled}) =>
      _client.postJson(ExtendedEndpoints.genaiRoutinesConfig, body: {'enabled': enabled});

  Future<Map<String, dynamic>> decideGenAiRoutine(String id, bool accept) => _client.postJson(
        ExtendedEndpoints.genaiRoutinesDecision,
        body: {'id': id, 'decision': accept ? 'accept' : 'reject'},
      );

  Future<List<GenAiIncidentPack>> listGenAiIncidents({int limit = 20}) async {
    final json = await _client.getJson('${ExtendedEndpoints.genaiIncidents}?limit=$limit');
    final list = <GenAiIncidentPack>[];
    final raw = json['packs'] ?? json['items'];
    if (raw is List) {
      for (final e in raw) {
        if (e is Map<String, dynamic>) list.add(GenAiIncidentPack.fromJson(e));
      }
    }
    return list;
  }

  Future<Map<String, dynamic>> createGenAiIncident({required String recordingId}) =>
      _client.postJson(ExtendedEndpoints.genaiIncidents, body: {'recordingId': recordingId});

  Future<Map<String, dynamic>> executeGenAiAction(Map<String, dynamic> action) =>
      _client.postJson(ExtendedEndpoints.genaiActionExecute, body: {'action': action});

  Future<Map<String, dynamic>> fetchAbrpStatus() =>
      _client.getJson(ExtendedEndpoints.abrpStatus);

  Future<Map<String, dynamic>> fetchAbrpConfig() =>
      _client.getJson(ExtendedEndpoints.abrpConfig);

  Future<Map<String, dynamic>> saveAbrpConfig(Map<String, dynamic> body) =>
      _client.postJson(ExtendedEndpoints.abrpConfig, body: body);

  Future<Map<String, dynamic>> deleteAbrpToken() => _client.deleteJson(ExtendedEndpoints.abrpToken);

  Future<Map<String, dynamic>> addMqttConnection(Map<String, dynamic> body) =>
      _client.postJson(ExtendedEndpoints.mqttConnections, body: body);

  Future<Map<String, dynamic>> updateMqttConnection(String id, Map<String, dynamic> body) =>
      _client.putJson('${ExtendedEndpoints.mqttConnections}/$id', body: body);

  Future<Map<String, dynamic>> deleteMqttConnection(String id) =>
      _client.deleteJson('${ExtendedEndpoints.mqttConnections}/$id');

  Future<Map<String, dynamic>> importCommunityAutomation(String id) =>
      _client.postJson('/api/community/import/$id');

  Future<Map<String, dynamic>> fetchMqttStatus() =>
      _client.getJson(ExtendedEndpoints.mqttStatus);

  Future<Map<String, dynamic>> listMqttConnections() =>
      _client.getJson(ExtendedEndpoints.mqttConnections);

  Future<Map<String, dynamic>> fetchMqttTelemetry() =>
      _client.getJson(ExtendedEndpoints.mqttTelemetry);

  Future<Map<String, dynamic>> fetchLauncherSummary() =>
      _client.getJson(ExtendedEndpoints.launcherSummary);

  Future<Map<String, dynamic>> fetchLauncherAppearance() =>
      _client.getJson(ExtendedEndpoints.launcherAppearance);

  Future<Map<String, dynamic>> fetchRoadSenseHazards({String? bbox}) {
    final q = bbox != null ? '?bbox=$bbox' : '';
    return _client.getJson('${ExtendedEndpoints.roadsenseHazards}$q');
  }

  Future<Map<String, dynamic>> fetchBydCloudStatus() =>
      _client.getJson(ExtendedEndpoints.bydCloudStatus);

  Future<Map<String, dynamic>> listCommunityAutomations({int page = 1}) =>
      _client.getJson('${ExtendedEndpoints.communityList}?page=$page&pageSize=10');

  Future<Map<String, dynamic>> readSeatDebug({String group = 'all'}) =>
      _client.getJson('${ExtendedEndpoints.debugSeatRead}?group=$group');

  Future<Map<String, dynamic>> writeSeatDebug({
    required String register,
    required int value,
    required String confirmToken,
    String group = 'all',
  }) =>
      _client.postJson(
        ExtendedEndpoints.debugSeatWrite,
        body: {
          'group': group,
          'register': register,
          'value': value,
          'confirm': confirmToken,
        },
      );

  Future<Map<String, dynamic>> fetchLogsAvailable() =>
      _client.getJson(ExtendedEndpoints.logsAvailable);

  Future<Map<String, dynamic>> uploadLogDaemon(String daemon) =>
      _client.postJson('${ExtendedEndpoints.logsUpload}?daemon=$daemon');

  Future<Map<String, dynamic>> fetchCarPropertyStatus() =>
      _client.getJson(ExtendedEndpoints.debugCarPropertyStatus);

  Future<Map<String, dynamic>> readCarProperty(String key) =>
      _client.getJson('${ExtendedEndpoints.debugCarPropertyGet}?key=$key');

  Future<Map<String, dynamic>> writeCarProperty({
    required String key,
    required String value,
    required String confirmToken,
  }) =>
      _client.postJson(
        ExtendedEndpoints.debugCarPropertySet,
        body: {'key': key, 'value': value, 'confirm': confirmToken},
      );

  Future<Map<String, dynamic>> resolveAdas() =>
      _client.getJson(ExtendedEndpoints.debugAdasResolve);

  Future<Map<String, dynamic>> readAdasRegisters() =>
      _client.getJson(ExtendedEndpoints.debugAdasRead);

  Future<Map<String, dynamic>> resolveLightDebug() =>
      _client.getJson(ExtendedEndpoints.debugLightResolve);

  Future<Map<String, dynamic>> writeLightDebug({
    required String zone,
    required int level,
    required String confirmToken,
  }) =>
      _client.postJson(
        ExtendedEndpoints.debugLightWrite,
        body: {'zone': zone, 'level': level, 'confirm': confirmToken},
      );

  Future<Map<String, dynamic>> fetchRemoteKeyDebug() =>
      _client.getJson(ExtendedEndpoints.debugRemoteKey);

  Future<Map<String, dynamic>> fetchAutoServiceDebugStatus() =>
      _client.getJson(ExtendedEndpoints.debugAutoServiceStatus);

  Future<Map<String, dynamic>> postRoadSenseDeleteLocal() =>
      _client.postJson(ExtendedEndpoints.roadsenseDeleteLocal);

  Future<Map<String, dynamic>> postRoadSenseDeleteCloud() =>
      _client.postJson(ExtendedEndpoints.roadsenseDeleteCloud);

  Future<Map<String, dynamic>> postRoadSenseTestChime(Map<String, dynamic> body) =>
      _client.postJson(ExtendedEndpoints.roadsenseTestChime, body: body);

  Future<Map<String, dynamic>> postRoadSenseHazardVerdict(String id, bool confirm) =>
      _client.postJson(
        ExtendedEndpoints.roadsenseHazardAction(id, confirm ? 'confirm' : 'reject'),
      );
}
