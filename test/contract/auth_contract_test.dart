import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive_companion/data/api/overdrive_api_client.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('auth status fixture matches AuthApiHandler shape', () async {
    final raw = await rootBundle.loadString('fixtures/auth_status.json');
    final status = AuthStatusResult.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    expect(status.ok, isTrue);
    expect(status.deviceId, isNotEmpty);
  });

  test('auth token fixture uses jwt field from server', () async {
    final raw = await rootBundle.loadString('fixtures/auth_token_success.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    expect(json['success'], isTrue);
    expect(json['jwt'], isNotNull);
    expect(json['token'], isNull);
  });
}
