import '../../core/config/app_settings.dart';
import '../api/overdrive_api_client.dart';
import '../mock/mock_overdrive_backend.dart';
import '../models/cloud_status.dart';
import '../models/gps_snapshot.dart';
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

  /// User-visible verdict — never treat HTTP 200 + unconfirmed lock as «done».
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
    OverdriveApiClient? client,
    MockOverdriveBackend? mockBackend,
  })  : _settings = settings,
        _client = client ?? OverdriveApiClient(baseUrl: settings.baseUrl),
        _mock = mockBackend ?? MockOverdriveBackend();

  AppSettings _settings;
  final OverdriveApiClient _client;
  final MockOverdriveBackend _mock;

  AppSettings get settings => _settings;

  void updateSettings(AppSettings settings) {
    _settings = settings;
    _client.baseUrl = settings.baseUrl;
    _mock.authRequired = settings.mockRequireAuth;
  }

  void setJwt(String? jwt) => _client.jwt = jwt;

  String? get sessionJwt => _client.jwt;

  Future<void> ensureAuthenticated() async {
    if (_settings.connectionMode == ConnectionMode.embeddedMock) {
      if (_settings.mockRequireAuth) {
        await _mockLogin();
      }
      return;
    }

    if (_settings.deviceToken.isNotEmpty && (_client.jwt == null || _client.jwt!.isEmpty)) {
      await _client.loginWithDeviceToken(_settings.deviceToken);
    }
  }

  Future<void> _mockLogin() async {
    final token = _settings.deviceToken.isEmpty ? 'mock-device-token' : _settings.deviceToken;
    final res = _mock.login(token);
    if (res['success'] != true) {
      throw OverdriveApiException(res['error'] as String? ?? 'mock auth failed');
    }
    _client.jwt = res['token'] as String?;
  }

  Future<AuthStatusResult> testConnection() async {
    if (_settings.connectionMode == ConnectionMode.embeddedMock) {
      final m = _mock.authStatus();
      return AuthStatusResult(
        ok: m['success'] == true || m['status'] == 'ok',
        deviceId: m['deviceId'] as String?,
        raw: m,
      );
    }
    return _client.testConnection();
  }

  Future<VehicleSnapshot> fetchSnapshot() async {
    try {
      await ensureAuthenticated();

      if (_settings.connectionMode == ConnectionMode.embeddedMock) {
        return VehicleSnapshot(
          state: _mock.parseVehicleState(),
          cloud: _mock.cloudStatus(),
          gps: _mock.gps(),
          lastUpdated: DateTime.now(),
        );
      }

      // live + localMockServer both hit HTTP (mock server or real car).
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
      Map<String, dynamic> json;
      if (_settings.connectionMode == ConnectionMode.embeddedMock) {
        json = _mock.handlePost(cap.path, payload);
      } else {
        json = await _client.postJson(cap.path, body: payload);
      }
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
      if (_settings.connectionMode == ConnectionMode.embeddedMock) {
        return _mock.parseVehicleState().isLocked;
      }
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
        error: server.message ?? 'לא אושר ע״י קריאת מצב',
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
    return kStage1Controls.where((c) {
      if (c.requiresTyres && snapshot?.state.tyres?.available != true) {
        return false;
      }
      return true;
    }).toList(growable: false);
  }
}
