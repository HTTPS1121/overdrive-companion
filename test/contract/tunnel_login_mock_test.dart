import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive_companion/data/api/overdrive_api_client.dart';

import '../support/fixture_api_client.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('composed token authenticates against mock backend', () async {
    final client = await FixtureOverdriveApiClient.create();
    client.setAuthRequired(true);
    await client.loginWithAccessCode(
      deviceId: 'mock-atto3-demo',
      accessCode: 'validcode1',
    );
    expect(client.jwt, isNotNull);
  });

  test('wrong code rejected when auth required', () async {
    final client = await FixtureOverdriveApiClient.create();
    client.setAuthRequired(true);
    expect(
      () => client.loginWithDeviceToken('mock-atto3-demo-bad'),
      throwsA(isA<OverdriveApiException>()),
    );
  });

  test('fetch status returns deviceId before JWT', () async {
    final client = await FixtureOverdriveApiClient.create();
    final status = await client.fetchAuthStatus();
    expect(status.deviceId, 'mock-atto3-demo');
  });
}
