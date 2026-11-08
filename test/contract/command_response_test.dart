import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive_companion/data/repositories/vehicle_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('confirmed lock response is userConfirmed', () async {
    final raw = await rootBundle.loadString('fixtures/command_lock_confirmed.json');
    final r = CommandResult.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    expect(r.userConfirmed, isTrue);
    expect(r.message, isNotNull);
    expect(r.success, isTrue);
  });

  test('unconfirmed lock response is not userConfirmed', () async {
    final raw = await rootBundle.loadString('fixtures/command_lock_unconfirmed.json');
    final r = CommandResult.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    expect(r.userConfirmed, isFalse);
    expect(r.success, isFalse);
  });
}
