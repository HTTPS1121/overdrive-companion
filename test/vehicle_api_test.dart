import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'support/mock_overdrive_backend.dart';
import 'package:overdrive_companion/data/models/vehicle_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('VehicleState parses fixture JSON', () async {
    final raw = await rootBundle.loadString('fixtures/vehicle_state_sample.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final state = VehicleState.fromJson(json);

    expect(state.success, isTrue);
    expect(state.battery?.soc, closeTo(68.5, 0.01));
    expect(state.isLocked, isTrue);
    expect(state.tyres?.fl?.kPa, 250);
  });

  test('Mock backend lock toggles overall state', () async {
    final backend = await MockOverdriveBackend.fromFixture();
    expect(backend.parseVehicleState().isLocked, isTrue);

    final unlock = backend.handlePost('/api/vehicle/unlock', {});
    expect(unlock['success'], isTrue);
    expect(backend.parseVehicleState().isLocked, isFalse);
  });

  test('Mock climate power_on sets acOn', () {
    final backend = MockOverdriveBackend();
    backend.handlePost('/api/vehicle/climate', {
      'action': 'power_on',
      'temp': 20,
    });
    expect(backend.parseVehicleState().climate?.acOn, isTrue);
  });
}
