import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive_companion/core/auth/tunnel_credentials.dart';
import 'package:overdrive_companion/data/api/overdrive_api_client.dart';

import '../support/fixture_api_client.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('composed token authenticates against mock backend', () async {
    final client = await FixtureOverdriveApiClient.create();
    client.setAuthRequired(true);
    final token = composeDeviceToken(deviceId: 'mock-atto3-demo', accessCode: 'validcode1');
    expect(token, 'mock-atto3-demo-validcode1');
    await client.loginWithAccessCode(
      deviceId: 'mock-atto3-demo',
      accessCode: 'validcode1',
    );
    expect(client.jwt, isNotNull);
    expect(client.jwt, startsWith('mock.jwt.'));
  });

  test('wrong code rejected when auth required', () async {
    final client = await FixtureOverdriveApiClient.create();
    client.setAuthRequired(true);
    expect(
      () => client.loginWithDeviceToken('mock-atto3-demo-badcode99'),
      throwsA(isA<OverdriveApiException>()),
    );
  });

  test('fetch status returns deviceId before JWT', () async {
    final client = await FixtureOverdriveApiClient.create();
    final status = await client.fetchAuthStatus();
    expect(status.deviceId, 'mock-atto3-demo');
  });

  test('legacy path accepts full device token when auth not required', () async {
    final client = await FixtureOverdriveApiClient.create();
    client.setAuthRequired(false);
    await client.loginWithDeviceToken('mock-atto3-demo-legacycode1');
    expect(client.jwt, isNotNull);
  });

  test('short access code rejected before network', () async {
    final client = await FixtureOverdriveApiClient.create();
    expect(
      () => client.loginWithAccessCode(deviceId: 'id', accessCode: 'short'),
      throwsA(
        predicate<OverdriveApiException>((e) => e.message.contains('min 8')),
      ),
    );
  });

  test('html response maps to tunnel misconfiguration', () async {
    final client = _HtmlProbeClient();
    expect(
      () => client.getJson('/auth/status'),
      throwsA(
        predicate<OverdriveApiException>((e) => e.message.toLowerCase().contains('html')),
      ),
    );
  });
}

class _HtmlProbeClient extends OverdriveApiClient {
  _HtmlProbeClient() : super(baseUrl: 'https://probe.test');

  @override
  Future<Map<String, dynamic>> getJson(String path) async {
    throw OverdriveApiException('server returned HTML (200) — check tunnel URL');
  }
}
