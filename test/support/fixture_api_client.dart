import 'package:overdrive_companion/data/api/overdrive_api_client.dart';
import 'package:overdrive_companion/data/repositories/overdrive_endpoints.dart';
import 'mock_overdrive_backend.dart';

/// Test-only HTTP stand-in backed by [MockOverdriveBackend] fixtures.
class FixtureOverdriveApiClient extends OverdriveApiClient {
  FixtureOverdriveApiClient(this._backend)
      : super(baseUrl: 'https://fixture.test', jwt: 'fixture-jwt');

  final MockOverdriveBackend _backend;

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
      default:
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
    return _backend.handlePost(path, body);
  }

  @override
  Future<void> loginWithDeviceToken(String token) async {
    final res = await postJson(OverdriveEndpoints.authToken, body: {'token': token});
    jwt = (res['jwt'] ?? res['token']) as String?;
  }

  @override
  Future<AuthStatusResult> testConnection() async {
    return AuthStatusResult.fromJson(await getJson(OverdriveEndpoints.authStatus));
  }
}
