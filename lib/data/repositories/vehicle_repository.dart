import '../../core/config/app_settings.dart';
import '../api/overdrive_api_client.dart';
import '../models/cloud_status.dart';
import '../models/gps_snapshot.dart';
import '../models/remote_feature_models.dart';
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

  String? get drivingLabelHe {
    final driving = gps?.isDriving;
    if (driving == null) return null;
    return driving ? 'בנסיעה' : 'בחנייה';
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

  String userMessageHe({required String actionLabel}) {
    if (!success) {
      return error ?? message ?? 'פקודת $actionLabel נכשלה';
    }
    if (confirmation == 'none' || outcome == 'unconfirmed') {
      return message ?? 'פקודת $actionLabel נשלחה אך לא אושרה ברכב';
    }
    return message ?? 'פקודת $actionLabel בוצעה';
  }
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
      throw OverdriveApiException('חיבור לשרת לא הוגדר');
    }
    if (_settings.deviceToken.isNotEmpty &&
        (_client.jwt == null || _client.jwt!.isEmpty)) {
      await _client.loginWithDeviceToken(_settings.deviceToken);
    }
  }

  Future<AuthStatusResult> testConnection() => _client.testConnection();

  Future<VehicleSnapshot> fetchSnapshot() async {
    if (!_settings.isConfigured) {
      return VehicleSnapshot(
        state: VehicleState(success: false, error: 'לא הוגדר חיבור'),
        offline: true,
        errorMessage: 'הגדר כתובת מנהרה ואסימון מכשיר',
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
        message: expected ? 'הרכב ננעל' : 'הרכב נפתח',
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
        error: server.message ?? 'לא אושר בעקבות קריאת מצב',
        path: server.path,
      );
    }
    if (before != null && after == before) {
      return CommandResult(
        success: false,
        error: 'מצב נעילה לא השתנה',
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
}
