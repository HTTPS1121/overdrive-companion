import 'package:overdrive_companion/data/api/overdrive_api_client.dart';
import 'package:overdrive_companion/data/repositories/overdrive_endpoints.dart';
import 'mock_overdrive_backend.dart';

/// Test-only HTTP stand-in backed by [MockOverdriveBackend] fixtures.
class FixtureOverdriveApiClient extends OverdriveApiClient {
  FixtureOverdriveApiClient(this._backend)
      : super(baseUrl: 'https://fixture.test', jwt: 'fixture-jwt');

  final MockOverdriveBackend _backend;

  MockOverdriveBackend get backend => _backend;

  void setAuthRequired(bool value) => _backend.authRequired = value;

  void configureRemoteServicesFixture({
    bool communicateVoice = true,
    bool communicateListener = true,
    bool genAiEnabled = true,
  }) {
    _backend.configureRemoteServicesFixture(
      communicateVoice: communicateVoice,
      communicateListener: communicateListener,
      genAiEnabled: genAiEnabled,
    );
  }

  static Future<FixtureOverdriveApiClient> create() async {
    final backend = await MockOverdriveBackend.fromFixture();
    return FixtureOverdriveApiClient(backend);
  }

  @override
  Future<Map<String, dynamic>> getJson(String path) async {
    switch (path) {
      case OverdriveEndpoints.authStatus:
        return _backend.authStatus();
      case OverdriveEndpoints.vehicleState:
        return _backend.vehicleState();
      case OverdriveEndpoints.cloudStatus:
        return _backend.cloudStatus().toJson();
      case OverdriveEndpoints.gps:
        return _backend.gps().toJson();
      case OverdriveEndpoints.climateSchedule:
      case OverdriveEndpoints.chargingSchedule:
      case OverdriveEndpoints.adas:
      case OverdriveEndpoints.chargeCap:
      case OverdriveEndpoints.acChargeCurrentLimit:
      case OverdriveEndpoints.streamStatus:
      case OverdriveEndpoints.recordings:
      case OverdriveEndpoints.surveillanceStatus:
      case OverdriveEndpoints.surveillanceConfig:
      case OverdriveEndpoints.surveillanceHeatmap:
      case OverdriveEndpoints.surveillanceFilterLog:
      case OverdriveEndpoints.communicateStatus:
      case OverdriveEndpoints.genaiStatus:
      case OverdriveEndpoints.genaiInsightsDashboard:
      case OverdriveEndpoints.wireguardStatus:
      case OverdriveEndpoints.communicateSettings:
      case OverdriveEndpoints.genaiConfig:
      case OverdriveEndpoints.genaiInsights:
        return _backend.handleGet(path);
      default:
        if (path.startsWith(OverdriveEndpoints.streamView)) {
          return _backend.handlePost(path, const {});
        }
        final base = path.split('?').first;
        if (base == OverdriveEndpoints.genaiInsights) {
          return _backend.handleGet(base);
        }
        final ext = _backend.handleGet(path);
        if (ext['error']?.toString().startsWith('unsupported GET') != true) {
          return ext;
        }
        throw OverdriveApiException('fixture: unknown GET $path');
    }
  }

  @override
  Future<Map<String, dynamic>> postJson(
    String path, {
    Map<String, dynamic> body = const {},
  }) async {
    if (path == OverdriveEndpoints.authToken) {
      final token = body['token'] as String? ?? '';
      return _backend.login(token);
    }
    if (path == OverdriveEndpoints.surveillanceScreenDeterrentTest ||
        path == OverdriveEndpoints.communicateMessage ||
        path == OverdriveEndpoints.communicateSettings ||
        path == OverdriveEndpoints.communicateTestSpeaker ||
        path == OverdriveEndpoints.communicateEmergencyStop ||
        path == OverdriveEndpoints.genaiChat ||
        path == OverdriveEndpoints.genaiTest ||
        path == OverdriveEndpoints.wireguardExpose ||
        path == OverdriveEndpoints.wireguardConfig) {
      return _backend.handlePost(path, body);
    }
    final result = _backend.handlePost(path, body);
    if (result['error']?.toString().startsWith('unsupported path') == true) {
      throw OverdriveApiException('fixture: unknown POST $path');
    }
    return result;
  }

  @override
  Future<Map<String, dynamic>> putJson(
    String path, {
    Map<String, dynamic> body = const {},
  }) async {
    final result = _backend.handlePut(path, body);
    if (result['error']?.toString().startsWith('unsupported PUT') != true) {
      return result;
    }
    throw OverdriveApiException('fixture: unknown PUT $path');
  }

  @override
  Future<void> loginWithDeviceToken(String token) async {
    await super.loginWithDeviceToken(token);
  }

  static final _tinyJpeg = <int>[
    0xFF, 0xD8, 0xFF, 0xDB, 0x00, 0x43, 0x00, 0x08, 0x06, 0x06, 0x07, 0x06, 0x05, 0x08,
    0x07, 0x07, 0x07, 0x09, 0x09, 0x08, 0x0A, 0x0C, 0x14, 0x0D, 0x0C, 0x0B, 0x0B, 0x0C,
    0x19, 0x12, 0x13, 0x0F, 0x14, 0x1D, 0x1A, 0x1F, 0x1E, 0x1D, 0x1A, 0x1C, 0x1C, 0x20,
    0x24, 0x2E, 0x27, 0x20, 0x22, 0x2C, 0x23, 0x1C, 0x1C, 0x28, 0x37, 0x29, 0x2C, 0x30,
    0x31, 0x34, 0x34, 0x34, 0x1F, 0x27, 0x39, 0x3D, 0x38, 0x32, 0x3C, 0x2E, 0x33, 0x34,
    0x32, 0xFF, 0xC0, 0x00, 0x0B, 0x08, 0x00, 0x01, 0x00, 0x01, 0x01, 0x01, 0x11, 0x00,
    0xFF, 0xC4, 0x00, 0x14, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0xFF, 0xC4, 0x00, 0x14, 0x10, 0x01,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0xFF, 0xDA, 0x00, 0x08, 0x01, 0x01, 0x00, 0x00, 0x3F, 0x00, 0x7F, 0xA0,
    0xFF, 0xD9,
  ];

  @override
  Future<List<int>> getBytes(String path, {Map<String, String>? extraHeaders, int? offset, int? length}) async {
    if (path.startsWith('/api/surveillance/snapshot/')) return _tinyJpeg;
    if (path == OverdriveEndpoints.surveillanceScreenDeterrentImage) {
      return _backend.screenDeterrentJpeg();
    }
    if (path.startsWith('/video/id/')) {
      return [0x00, 0x00, 0x00, 0x18, 0x66, 0x74, 0x79, 0x70]; // minimal ftyp header stub
    }
    throw OverdriveApiException('fixture: unknown GET bytes $path');
  }

  @override
  Future<Map<String, dynamic>> deleteJson(String path) async {
    if (path.startsWith('/api/recordings/id/')) {
      return {'success': true};
    }
    if (path == OverdriveEndpoints.wireguardConfigDelete) {
      return _backend.deleteWireGuardConfig();
    }
    final result = _backend.handleDelete(path);
    if (result['error']?.toString().startsWith('unsupported DELETE') != true) {
      return result;
    }
    throw OverdriveApiException('fixture: unknown DELETE $path');
  }

  @override
  Future<AuthStatusResult> testConnection() async {
    return AuthStatusResult.fromJson(await getJson(OverdriveEndpoints.authStatus));
  }
}
