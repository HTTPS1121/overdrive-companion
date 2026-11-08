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
}
