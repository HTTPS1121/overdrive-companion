import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive_companion/core/auth/tunnel_credentials.dart';
import 'package:overdrive_companion/data/api/overdrive_api_client.dart';

import '../support/local_overdrive_http_server.dart';
import '../support/mock_overdrive_backend.dart';

void main() {
  late LocalOverdriveHttpServer server;
  late MockOverdriveBackend backend;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    backend = MockOverdriveBackend();
    server = LocalOverdriveHttpServer(backend);
    await server.start();
  });

  tearDown(() async {
    await server.stop();
    HttpOverrides.global = null;
  });

  test('real HttpClient login against shelf mock', () async {
    HttpOverrides.global = _RealHttpOverrides();
    backend.authRequired = true;
    final client = OverdriveApiClient(baseUrl: server.baseUrl);
    final status = await client.fetchAuthStatus();
    expect(status.deviceId, isNotNull);
    await client.loginWithAccessCode(
      deviceId: status.deviceId!,
      accessCode: 'validcode1',
    );
    expect(client.jwt, isNotEmpty);
    final state = await client.getJson('/api/vehicle/state');
    expect(state['success'], isTrue);
  });

  test('composed token format', () {
    expect(
      composeDeviceToken(deviceId: 'abc', accessCode: 'ValidCode1'),
      'abc-validcode1',
    );
  });
}

class _RealHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context);
  }
}
