import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive_companion/core/auth/tunnel_credentials.dart';

void main() {
  test('compose matches login.html deviceId + accessCode', () {
    expect(
      composeDeviceToken(deviceId: 'atto3-il-demo', accessCode: 'AbCdEfGh'),
      'atto3-il-demo-abcdefgh',
    );
  });

  test('parse round-trip', () {
    const full = 'mock-atto3-demo-mysecret12';
    final p = parseDeviceToken(full);
    expect(p, isNotNull);
    expect(p!.deviceId, 'mock-atto3-demo');
    expect(p.accessCode, 'mysecret12');
  });
}
