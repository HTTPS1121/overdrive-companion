import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive_companion/data/models/remote_feature_models.dart';

import '../support/mock_overdrive_backend.dart';

void main() {
  late MockOverdriveBackend backend;

  setUp(() {
    backend = MockOverdriveBackend();
  });

  test('bookingId stays decimal string through GET listInfo', () {
    final json = backend.handleGet('/api/vehicle/climate-schedule');
    final state = ClimateScheduleState.fromJson(json);
    for (final b in state.bookings) {
      expect(b.bookingId, isNotNull);
      expect(b.bookingId, matches(r'^\d+$|^[a-zA-Z0-9_-]+$'));
      expect(b.bookingId, isNot(contains('e')));
    }
  });

  test('update/delete target existing string bookingId (not max uint sentinel)', () {
    const existingId = '8844123456789012';
    final update = backend.handlePost('/api/vehicle/climate-schedule', {
      'action': 'update',
      'bookingId': existingId,
      'temp': 23,
      'durationMinutes': 25,
      'bookingTime': 1736150400,
    });
    expect(update['success'], isTrue);

    final delete = backend.handlePost('/api/vehicle/climate-schedule', {
      'action': 'delete',
      'bookingId': existingId,
    });
    expect(delete['success'], isTrue);

    final after = ClimateScheduleState.fromJson(
      backend.handleGet('/api/vehicle/climate-schedule'),
    );
    expect(after.bookings.where((b) => b.bookingId == existingId), isEmpty);
  });

  test('create without bookingId mints new string id', () {
    final before = ClimateScheduleState.fromJson(
      backend.handleGet('/api/vehicle/climate-schedule'),
    ).bookings.length;
    final created = backend.handlePost('/api/vehicle/climate-schedule', {
      'action': 'create',
      'bookingTime': 1736500000,
      'temp': 21,
      'durationMinutes': 15,
    });
    expect(created['success'], isTrue);
    final after = ClimateScheduleState.fromJson(
      backend.handleGet('/api/vehicle/climate-schedule'),
    );
    expect(after.bookings.length, before + 1);
    expect(after.bookings.last.bookingId, startsWith('mock-climate-'));
  });

  test('numeric JSON bookingId is coerced to string for matching', () {
    // Server may echo id as number in broken clients; companion must send strings only.
    backend.handlePost('/api/vehicle/climate-schedule', {
      'action': 'delete',
      'bookingId': '8844987654321098',
    });
    final del = backend.handlePost('/api/vehicle/climate-schedule', {
      'action': 'delete',
      'bookingId': '8844123456789012',
    });
    expect(del['success'], isTrue);
  });
}
