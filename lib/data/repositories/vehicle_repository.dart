import '../../core/auth/connection_errors.dart';
import '../../core/auth/tunnel_credentials.dart';
import '../../core/config/app_settings.dart';
import '../api/overdrive_api_client.dart';
import '../models/camera_models.dart';
import '../models/cloud_status.dart';
import '../models/gps_snapshot.dart';
import '../models/remote_feature_models.dart';
import '../models/remote_services_models.dart';
import '../models/vehicle_state.dart';
import 'overdrive_endpoints.dart';

export '../api/overdrive_api_client.dart' show AuthStatusResult;
export 'overdrive_endpoints.dart' show ControlCapability, ControlKind, OverdriveEndpoints;

class VehicleSnapshot {
  VehicleSnapshot({
    required this.state,
    this.cloud,
    this.gps,
    this.lastUpdated,
    this.offline = false,
    this.errorMessage,
  });

  final VehicleState state;
  final CloudStatus? cloud;
  final GpsSnapshot? gps;
  final DateTime? lastUpdated;
  final bool offline;
  final String? errorMessage;

  bool? get isDriving {
    final driving = gps?.isDriving;
    if (driving != null) return driving;
    final speed = gps?.canSpeedKmh;
    if (speed != null) return speed > 1;
    return null;
  }
}

class CommandResult {
  CommandResult({
    required this.success,
    this.message,
    this.error,
    this.path,
    this.confirmation,
    this.outcome,
    this.commandSuccess,
  });

  factory CommandResult.fromJson(Map<String, dynamic> json) {
    return CommandResult(
      success: json['success'] == true,
      message: json['message'] as String?,
      error: json['error'] as String?,
      path: json['path'] as String?,
      confirmation: json['confirmation'] as String?,
      outcome: json['outcome'] as String?,
      commandSuccess: json['commandSuccess'] as bool?,
    );
  }

  final bool success;
  final String? message;
  final String? error;
  final String? path;
  final String? confirmation;
  final String? outcome;
  final bool? commandSuccess;

  bool get userConfirmed =>
      success && (confirmation == null || confirmation == 'local');

}

class VehicleRepository {
  VehicleRepository({
    required AppSettings settings,
    required OverdriveApiClient client,
  })  : _settings = settings,
        _client = client {
    _client.baseUrl = settings.baseUrl;
  }

  AppSettings _settings;
  final OverdriveApiClient _client;

  AppSettings get settings => _settings;

  void updateSettings(AppSettings settings) {
    _settings = settings;
    _client.baseUrl = settings.baseUrl;
  }

  void setJwt(String? jwt) => _client.jwt = jwt;

  String? get sessionJwt => _client.jwt;

  Future<void> ensureAuthenticated() async {
    if (!_settings.isConfigured) {
      throw OverdriveApiException('connection not configured');
    }
    if (_client.jwt != null && _client.jwt!.isNotEmpty) return;
    try {
      await loginWithStoredCredentials();
    } on ConnectionFailure {
      rethrow;
    } on OverdriveApiException catch (e) {
      if (e.authRequired) _client.jwt = null;
      throw ConnectionFailure.fromApi(e);
    }
  }

  Future<AuthStatusResult> testConnection() => _client.testConnection();

  /// Probe tunnel without JWT — returns car `deviceId` for login.html parity.
  Future<AuthStatusResult> fetchTunnelDeviceId() async {
    try {
      return await _client.fetchAuthStatus();
    } on OverdriveApiException catch (e) {
      throw ConnectionFailure.fromApi(e);
    }
  }

  Future<void> loginWithStoredCredentials() async {
    final id = _settings.deviceId.trim();
    final code = _settings.accessCode;
    try {
      if (id.isNotEmpty && code.isNotEmpty) {
        await _client.loginWithAccessCode(deviceId: id, accessCode: code);
        return;
      }
      final legacy = _settings.resolvedDeviceToken();
      if (legacy.isNotEmpty) {
        await _client.loginWithDeviceToken(legacy);
        return;
      }
      throw ConnectionFailure(ConnectionFailureKind.deviceIdMissing);
    } on OverdriveApiException catch (e) {
      throw ConnectionFailure.fromApi(e);
    }
  }

  Future<VehicleSnapshot> fetchSnapshot() async {
    if (!_settings.isConfigured) {
      return VehicleSnapshot(
        state: VehicleState(success: false, error: 'connection_not_configured'),
        offline: true,
        errorMessage: 'connection_not_configured',
      );
    }
    try {
      await ensureAuthenticated();

      final stateJson = await _client.getJson(OverdriveEndpoints.vehicleState);
      final state = VehicleState.fromJson(stateJson);

      CloudStatus? cloud;
      GpsSnapshot? gps;
      try {
        cloud = CloudStatus.fromJson(
          await _client.getJson(OverdriveEndpoints.cloudStatus),
        );
      } catch (_) {}
      try {
        gps = GpsSnapshot.fromJson(await _client.getJson(OverdriveEndpoints.gps));
      } catch (_) {}

      return VehicleSnapshot(
        state: state,
        cloud: cloud,
        gps: gps,
        lastUpdated: DateTime.now(),
        offline: !state.success,
        errorMessage: state.error,
      );
    } on OverdriveApiException catch (e) {
      return VehicleSnapshot(
        state: VehicleState(success: false, error: e.message),
        lastUpdated: DateTime.now(),
        offline: true,
        errorMessage: e.message,
      );
    } catch (e) {
      return VehicleSnapshot(
        state: VehicleState(success: false, error: e.toString()),
        lastUpdated: DateTime.now(),
        offline: true,
        errorMessage: e.toString(),
      );
    }
  }

  Future<CommandResult> runControl(
    ControlCapability cap, {
    Map<String, dynamic>? body,
    bool verifyWithRefresh = true,
  }) async {
    final payload = body ?? cap.defaultBody ?? const {};
    final before = verifyWithRefresh ? await _peekLockState() : null;
    try {
      await ensureAuthenticated();
      final json = await _client.postJson(cap.path, body: payload);
      var result = CommandResult.fromJson(json);
      if (verifyWithRefresh && result.success && _isLockKind(cap.kind)) {
        result = await _reconcileLockCommand(cap.kind, result, before);
      }
      return result;
    } on OverdriveApiException catch (e) {
      return CommandResult(success: false, error: e.message);
    } catch (e) {
      return CommandResult(success: false, error: e.toString());
    }
  }

  bool _isLockKind(ControlKind kind) =>
      kind == ControlKind.lock || kind == ControlKind.unlock;

  Future<bool?> _peekLockState() async {
    try {
      final json = await _client.getJson(OverdriveEndpoints.vehicleState);
      return VehicleState.fromJson(json).isLocked;
    } catch (_) {
      return null;
    }
  }

  Future<CommandResult> _reconcileLockCommand(
    ControlKind kind,
    CommandResult server,
    bool? before,
  ) async {
    if (server.confirmation == 'local' && server.userConfirmed) return server;
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final after = await _peekLockState();
    final expected = kind == ControlKind.lock;
    if (after != null && after == expected) {
      return CommandResult(
        success: true,
        commandSuccess: true,
        confirmation: 'local',
        outcome: 'success',
        message: expected ? 'locked' : 'unlocked',
        path: server.path,
      );
    }
    if (server.success && server.confirmation != 'local') {
      return CommandResult(
        success: false,
        commandSuccess: false,
        confirmation: 'none',
        outcome: 'unconfirmed',
        message: server.message,
        error: server.message ?? 'state poll unconfirmed',
        path: server.path,
      );
    }
    if (before != null && after == before) {
      return CommandResult(
        success: false,
        error: 'lock state unchanged',
        path: server.path,
      );
    }
    return server;
  }

  List<ControlCapability> availableControls(VehicleSnapshot? snapshot) {
    return kCompanionControls.where((c) {
      if (c.requiresTyres && snapshot?.state.tyres?.available != true) {
        return false;
      }
      return true;
    }).toList(growable: false);
  }

  Future<CommandResult> postJsonCommand(
    String path, {
    Map<String, dynamic> body = const {},
  }) async {
    await ensureAuthenticated();
    try {
      final json = await _client.postJson(path, body: body);
      return CommandResult.fromJson(json);
    } on OverdriveApiException catch (e) {
      return CommandResult(success: false, error: e.message, path: path);
    }
  }

  Future<ClimateScheduleState> fetchClimateSchedule() async {
    await ensureAuthenticated();
    final json = await _client.getJson(OverdriveEndpoints.climateSchedule);
    return ClimateScheduleState.fromJson(json);
  }

  Future<ChargingScheduleState> fetchChargingSchedule() async {
    await ensureAuthenticated();
    final json = await _client.getJson(OverdriveEndpoints.chargingSchedule);
    return ChargingScheduleState.fromJson(json);
  }

  Future<AdasState> fetchAdasState() async {
    await ensureAuthenticated();
    final json = await _client.getJson(OverdriveEndpoints.adas);
    return AdasState.fromJson(json);
  }

  Future<ChargeCapState> fetchChargeCap() async {
    await ensureAuthenticated();
    final json = await _client.getJson(OverdriveEndpoints.chargeCap);
    return ChargeCapState.fromJson(json);
  }

  Future<CommandResult> findCar() => postJsonCommand(OverdriveEndpoints.findCar);

  Future<CommandResult> startCharging() =>
      postJsonCommand(OverdriveEndpoints.startCharging);

  Future<CommandResult> saveClimateSchedule(Map<String, dynamic> body) =>
      postJsonCommand(OverdriveEndpoints.climateSchedule, body: body);

  Future<CommandResult> saveChargingSchedule(Map<String, dynamic> body) =>
      postJsonCommand(OverdriveEndpoints.chargingSchedule, body: body);

  Future<CommandResult> postSeat({
    required String action,
    required int position,
    int? level,
    List<int>? seatHeat,
    List<int>? seatCool,
  }) {
    final body = <String, dynamic>{
      'action': action,
      'position': position,
      if (level != null) 'level': level,
      if (seatHeat != null && seatCool != null) ...{
        'driverHeat': seatHeat[0],
        'driverVent': seatCool[0],
        'passengerHeat': seatHeat[1],
        'passengerVent': seatCool[1],
      },
    };
    return postJsonCommand(OverdriveEndpoints.seat, body: body);
  }

  Future<CommandResult> postAdas({
    required String target,
    bool? enable,
    int? mode,
  }) {
    return postJsonCommand(
      OverdriveEndpoints.adas,
      body: {
        'target': target,
        if (enable != null) 'enable': enable,
        if (mode != null) 'mode': mode,
      },
    );
  }

  Future<CommandResult> postVehicleSetting({
    required String target,
    required int value,
  }) {
    return postJsonCommand(
      OverdriveEndpoints.vehicleSetting,
      body: {'target': target, 'value': value},
    );
  }

  Future<CommandResult> postMedia({
    required String target,
    int? value,
    String? key,
  }) {
    return postJsonCommand(
      OverdriveEndpoints.media,
      body: {
        'target': target,
        if (value != null) 'value': value,
        if (key != null) 'key': key,
      },
    );
  }

  Future<CommandResult> postChargeCap({int? percent, bool? enabled}) {
    return postJsonCommand(
      OverdriveEndpoints.chargeCap,
      body: {
        if (percent != null) 'percent': percent,
        if (enabled != null) 'enabled': enabled,
      },
    );
  }

  Future<CommandResult> vehiclePowerOn() => postJsonCommand(OverdriveEndpoints.powerOn);

  Future<CommandResult> vehiclePowerOff() => postJsonCommand(OverdriveEndpoints.powerOff);

  Future<CommandResult> setBatteryHeat(bool enabled) => postJsonCommand(
        OverdriveEndpoints.batteryHeat,
        body: {'enabled': enabled},
      );

  Future<CommandResult> systemScreenshot({required int display}) => postJsonCommand(
        OverdriveEndpoints.system,
        body: {'target': 'screenshot', 'display': display},
      );

  Future<CommandResult> systemShellAction({
    required String target,
    int? display,
    int? x,
    int? y,
  }) =>
      postJsonCommand(
        OverdriveEndpoints.system,
        body: {
          'target': target,
          if (display != null) 'display': display,
          if (x != null) 'x': x,
          if (y != null) 'y': y,
        },
      );

  Future<CommandResult> playHeadUnitAudio(String file) => postJsonCommand(
        OverdriveEndpoints.playAudio,
        body: {'file': file},
      );

  Future<CommandResult> stopHeadUnitAudio() => postJsonCommand(OverdriveEndpoints.stopAudio);

  Future<CommandResult> speakOnHeadUnit(String text) => postJsonCommand(
        OverdriveEndpoints.speak,
        body: {'text': text},
      );

  Future<CommandResult> messageOnHeadUnit(String text) => postJsonCommand(
        OverdriveEndpoints.vehicleMessage,
        body: {'text': text},
      );

  Future<Map<String, dynamic>> fetchClusterApps() async {
    await ensureAuthenticated();
    return _client.getJson(OverdriveEndpoints.clusterApps);
  }

  Future<CommandResult> clusterCast({required String action, String? app}) => postJsonCommand(
        OverdriveEndpoints.clusterCast,
        body: {
          'action': action,
          if (app != null && app.isNotEmpty) 'app': app,
        },
      );

  Future<CommandResult> clusterStop() => postJsonCommand(OverdriveEndpoints.clusterStop);

  Future<AcChargeCurrentLimitState> fetchAcChargeCurrentLimit() async {
    await ensureAuthenticated();
    final json = await _client.getJson(OverdriveEndpoints.acChargeCurrentLimit);
    return AcChargeCurrentLimitState.fromJson(json);
  }

  Future<CommandResult> setAcChargeCurrentLimit(int state) => postJsonCommand(
        OverdriveEndpoints.acChargeCurrentLimit,
        body: {'state': state},
      );

  Future<StreamStatusState> fetchStreamStatus() async {
    await ensureAuthenticated();
    final json = await _client.getJson(OverdriveEndpoints.streamStatus);
    return StreamStatusState.fromJson(json);
  }

  Future<RecordingsListState> fetchRecordingsList() async {
    await ensureAuthenticated();
    final json = await _client.getJson(OverdriveEndpoints.recordings);
    return RecordingsListState.fromJson(json);
  }

  Future<SurveillanceStatusState> fetchSurveillanceStatus() async {
    await ensureAuthenticated();
    final json = await _client.getJson(OverdriveEndpoints.surveillanceStatus);
    return SurveillanceStatusState.fromJson(json);
  }

  Future<void> enableStream() async {
    await postJsonCommand(OverdriveEndpoints.streamEnable);
  }

  Future<void> disableStream() async {
    await postJsonCommand(OverdriveEndpoints.streamDisable);
  }

  Future<void> setStreamViewMode(int mode) async {
    await _client.postJson('${OverdriveEndpoints.streamView}/$mode');
  }

  Future<void> setStreamQuality(String quality) async {
    await _client.postJson(OverdriveEndpoints.streamQuality, body: {'quality': quality});
  }

  Uri videoUrlForRecording(RecordingEntry entry) {
    final id = entry.canonicalRecordingId;
    if (id != null) return _client.uri(OverdriveEndpoints.videoById(id));
    return _client.uri('/api/recordings/${Uri.encodeComponent(entry.filename)}');
  }

  Uri thumbUrlForRecording(RecordingEntry entry) {
    final id = entry.canonicalRecordingId;
    if (id != null) return _client.uri(OverdriveEndpoints.thumbById(id));
    return _client.uri('/thumb/${Uri.encodeComponent(entry.filename)}');
  }

  Future<List<int>> downloadRecordingBytes(RecordingEntry entry) async {
    await ensureAuthenticated();
    final path = entry.canonicalRecordingId != null
        ? OverdriveEndpoints.videoById(entry.canonicalRecordingId!)
        : '/api/recordings/${Uri.encodeComponent(entry.filename)}';
    return _client.getBytes(path);
  }

  Future<CommandResult> deleteRecording(RecordingEntry entry) async {
    await ensureAuthenticated();
    if (entry.canonicalRecordingId != null) {
      final json =
          await _client.deleteJson(OverdriveEndpoints.recordingDeleteById(entry.canonicalRecordingId!));
      return CommandResult.fromJson(json);
    }
    return CommandResult.fromJson(
      await _client.deleteJson('/api/recordings/${Uri.encodeComponent(entry.filename)}'),
    );
  }

  Future<SurveillanceConfigState> fetchSurveillanceConfig() async {
    await ensureAuthenticated();
    final json = await _client.getJson(OverdriveEndpoints.surveillanceConfig);
    return SurveillanceConfigState.fromJson(json);
  }

  Future<void> postSurveillanceConfig(Map<String, dynamic> body) async {
    await ensureAuthenticated();
    await _client.postJson(OverdriveEndpoints.surveillanceConfig, body: body);
  }

  Future<void> enableSurveillance() async {
    await postJsonCommand(OverdriveEndpoints.surveillanceEnable);
  }

  Future<void> disableSurveillance() async {
    await postJsonCommand(OverdriveEndpoints.surveillanceDisable);
  }

  Future<List<int>> fetchSurveillanceSnapshot(int quadrant) async {
    await ensureAuthenticated();
    return _client.getBytes(OverdriveEndpoints.surveillanceSnapshot(quadrant));
  }

  Future<SurveillanceHeatmapState> fetchSurveillanceHeatmap() async {
    await ensureAuthenticated();
    final json = await _client.getJson(OverdriveEndpoints.surveillanceHeatmap);
    return SurveillanceHeatmapState.fromJson(json);
  }

  Future<SurveillanceFilterLogState> fetchSurveillanceFilterLog() async {
    await ensureAuthenticated();
    final json = await _client.getJson(OverdriveEndpoints.surveillanceFilterLog);
    return SurveillanceFilterLogState.fromJson(json);
  }

  Future<List<int>> fetchScreenDeterrentImage() async {
    await ensureAuthenticated();
    return _client.getBytes(OverdriveEndpoints.surveillanceScreenDeterrentImage);
  }

  Future<CommandResult> postScreenDeterrentTest() async {
    await ensureAuthenticated();
    final json = await _client.postJson(OverdriveEndpoints.surveillanceScreenDeterrentTest);
    return CommandResult.fromJson(json);
  }

  Future<CommunicateStatusState> fetchCommunicateStatus() async {
    await ensureAuthenticated();
    final json = await _client.getJson(OverdriveEndpoints.communicateStatus);
    return CommunicateStatusState.fromJson(json);
  }

  Future<CommunicateSettingsState> fetchCommunicateSettings() async {
    await ensureAuthenticated();
    final json = await _client.getJson(OverdriveEndpoints.communicateSettings);
    return CommunicateSettingsState.fromJson(json);
  }

  Future<CommunicateSettingsState> postCommunicateSettings(Map<String, dynamic> body) async {
    await ensureAuthenticated();
    final json = await _client.postJson(OverdriveEndpoints.communicateSettings, body: body);
    return CommunicateSettingsState.fromJson(json);
  }

  Future<CommandResult> postCommunicateMessage({
    required String message,
    String kind = 'toast',
    String severity = 'info',
    String position = 'bottom',
    String duration = 'short',
    String? title,
  }) async {
    await ensureAuthenticated();
    final body = <String, dynamic>{
      'kind': kind,
      'message': message,
      'severity': severity,
      'position': position,
      'duration': duration,
    };
    if (title != null && title.isNotEmpty) body['title'] = title;
    final json = await _client.postJson(OverdriveEndpoints.communicateMessage, body: body);
    return CommandResult.fromJson({
      'success': json['success'] == true || json['status'] == 'displayed',
      'message': json['status']?.toString(),
      'error': json['reason']?.toString(),
      ...json,
    });
  }

  Future<CommandResult> postCommunicateTestSpeaker() async {
    await ensureAuthenticated();
    final json = await _client.postJson(OverdriveEndpoints.communicateTestSpeaker);
    return CommandResult.fromJson(json);
  }

  Future<CommandResult> postCommunicateEmergencyStop() async {
    await ensureAuthenticated();
    final json = await _client.postJson(OverdriveEndpoints.communicateEmergencyStop);
    return CommandResult.fromJson(json);
  }

  Future<GenAiStatusState> fetchGenAiStatus() async {
    await ensureAuthenticated();
    final json = await _client.getJson(OverdriveEndpoints.genaiStatus);
    return GenAiStatusState.fromJson(json);
  }

  Future<GenAiConfigState> fetchGenAiConfig() async {
    await ensureAuthenticated();
    final json = await _client.getJson(OverdriveEndpoints.genaiConfig);
    return GenAiConfigState.fromJson(json);
  }

  Future<Map<String, dynamic>> fetchGenAiInsights({int limit = 20}) async {
    await ensureAuthenticated();
    return _client.getJson('${OverdriveEndpoints.genaiInsights}?limit=$limit');
  }

  Future<CommandResult> postGenAiTest() async {
    await ensureAuthenticated();
    final json = await _client.postJson(OverdriveEndpoints.genaiTest);
    return CommandResult.fromJson(json);
  }

  Future<GenAiChatResult> postGenAiChat(String message) async {
    await ensureAuthenticated();
    final json = await _client.postJson(
      OverdriveEndpoints.genaiChat,
      body: {
        'messages': [
          {'role': 'user', 'content': message, 'text': message},
        ],
      },
    );
    return GenAiChatResult.fromJson(json);
  }

  Future<Map<String, dynamic>> fetchGenAiInsightsDashboard() async {
    await ensureAuthenticated();
    return _client.getJson(OverdriveEndpoints.genaiInsightsDashboard);
  }

  Future<WireGuardStatusState> fetchWireGuardStatus() async {
    await ensureAuthenticated();
    final json = await _client.getJson(OverdriveEndpoints.wireguardStatus);
    return WireGuardStatusState.fromJson(json);
  }

  Future<CommandResult> postWireGuardExpose({required bool enabled}) async {
    await ensureAuthenticated();
    final json = await _client.postJson(
      OverdriveEndpoints.wireguardExpose,
      body: {'enabled': enabled},
    );
    return CommandResult.fromJson(json);
  }

  Future<CommandResult> postWireGuardConfig(String wgQuickText) async {
    await ensureAuthenticated();
    final json = await _client.postJson(
      OverdriveEndpoints.wireguardConfig,
      body: {'config': wgQuickText},
    );
    return CommandResult.fromJson(json);
  }

  Future<CommandResult> deleteWireGuardConfig() async {
    await ensureAuthenticated();
    final json = await _client.deleteJson(OverdriveEndpoints.wireguardConfigDelete);
    return CommandResult.fromJson(json);
  }
}
