import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:overdrive_companion/core/auth/tunnel_credentials.dart';
import 'package:overdrive_companion/data/api/overdrive_api_client.dart';
import 'package:overdrive_companion/data/repositories/overdrive_endpoints.dart';

void main() {
  test('rejects HTML body as tunnel mis-route', () async {
    final client = OverdriveApiClient(
      baseUrl: 'https://tunnel.example',
      httpClient: MockClient((request) async {
        return http.Response('<!DOCTYPE html><html><body>Cloudflare</body></html>', 200);
      }),
    );
    expect(() => client.fetchAuthStatus(), throwsA(isA<OverdriveApiException>()));
  });

  test('login sends composed token in JSON body', () async {
    Map<String, dynamic>? captured;
    final client = OverdriveApiClient(
      baseUrl: 'https://tunnel.example',
      httpClient: MockClient((request) async {
        if (request.url.path == OverdriveEndpoints.authToken) {
          captured = jsonDecode(request.body) as Map<String, dynamic>;
          return http.Response(
            jsonEncode({'success': true, 'jwt': 'ey.test', 'expiresIn': 3600}),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response(jsonEncode({'status': 'ok', 'deviceId': 'car-1'}), 200);
      }),
    );
    await client.loginWithAccessCode(deviceId: 'car-1', accessCode: 'MyAccess99');
    expect(captured!['token'], composeDeviceToken(deviceId: 'car-1', accessCode: 'MyAccess99'));
    expect(client.jwt, 'ey.test');
  });

  test('401 surfaces authRequired', () async {
    final client = OverdriveApiClient(
      baseUrl: 'https://tunnel.example',
      httpClient: MockClient((request) async {
        return http.Response(
          jsonEncode({'success': false, 'error': 'session expired'}),
          401,
          headers: {'content-type': 'application/json'},
        );
      }),
    );
    expect(
      () => client.getJson('/api/vehicle/state'),
      throwsA(predicate<OverdriveApiException>((e) => e.authRequired)),
    );
  });
}
