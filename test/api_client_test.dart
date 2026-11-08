import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:overdrive_companion/data/api/overdrive_api_client.dart';

void main() {
  test('normalizeBaseUrl adds scheme and strips slash', () {
    expect(normalizeBaseUrl('192.168.1.10:8080'), 'https://192.168.1.10:8080');
    expect(normalizeBaseUrl('https://car.example.com/'), 'https://car.example.com');
  });

  test('loginWithDeviceToken reads jwt field', () async {
    final client = OverdriveApiClient(
      baseUrl: 'http://test',
      httpClient: MockClient((request) async {
        if (request.url.path == '/auth/token') {
          return http.Response(
            jsonEncode({'success': true, 'jwt': 'abc.jwt.xyz', 'deviceId': 'x'}),
            200,
          );
        }
        return http.Response('{}', 404);
      }),
    );
    await client.loginWithDeviceToken('device-token');
    expect(client.jwt, 'abc.jwt.xyz');
  });

  test('testConnection accepts status ok', () async {
    final client = OverdriveApiClient(
      baseUrl: 'http://test',
      httpClient: MockClient((request) async {
        return http.Response(jsonEncode({'status': 'ok', 'deviceId': 'atto3'}), 200);
      }),
    );
    final s = await client.testConnection();
    expect(s.ok, isTrue);
    expect(s.deviceId, 'atto3');
  });
}
