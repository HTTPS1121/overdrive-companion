import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive_companion/data/hebrew_errors.dart';
import 'package:overdrive_server/overdrive_server.dart';

void main() {
  test('timeout hebrew message', () {
    expect(hebrewForTimeout(), contains('פסקת זמן'));
  });

  test('api 404 unsupported', () {
    expect(
      hebrewApiException(OverdriveApiException('nope', statusCode: 404)),
      contains('אינה נתמכת'),
    );
  });

  test('connection failure auth', () {
    final f = ConnectionFailure(ConnectionFailureKind.authRejected);
    expect(hebrewConnectionFailure(f), contains('אימות'));
  });
}
