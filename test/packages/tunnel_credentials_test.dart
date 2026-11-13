import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive_server/overdrive_server.dart';

void main() {
  test('compose and parse device token', () {
    final full = composeDeviceToken(deviceId: 'dev-1', accessCode: 'abcd1234');
    expect(full, 'dev-1-abcd1234');
    final p = parseDeviceToken(full);
    expect(p?.deviceId, 'dev-1');
    expect(p?.accessCode, 'abcd1234');
  });
}
