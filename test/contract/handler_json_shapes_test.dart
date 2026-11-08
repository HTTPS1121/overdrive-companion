import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive_companion/data/models/remote_feature_models.dart';

/// JSON shapes traced from HTTPS1121/Overdrive-release VehicleControlApiHandler.java
/// (handleGetClimateSchedule, handleSeat body comment, handleChargeCap, handleAdasState).
void main() {
  test('climate-schedule GET uses bookings.listInfo + mainSettingTemp', () {
    final state = ClimateScheduleState.fromJson({
      'success': true,
      'supported': true,
      'source': 'cloud',
      'emptyBookingsMayBeStale': true,
      'bookings': {
        'listInfo': [
          {
            'bookingId': '9999999999999999',
            'bookingTime': 2000000000,
            'mainSettingTemp': 8,
            'timeSpan': 3,
          },
        ],
      },
    });
    expect(state.bookings, hasLength(1));
    expect(state.bookings.first.bookingId, '9999999999999999');
    expect(state.bookings.first.temp, 22);
    expect(state.bookings.first.durationMinutes, 20);
  });

  test('climate-schedule GET bookingsUnavailable omits list', () {
    final state = ClimateScheduleState.fromJson({
      'success': true,
      'supported': true,
      'bookingsUnavailable': true,
      'reason': 'vehicle_unreachable',
    });
    expect(state.bookings, isEmpty);
    expect(state.bookingsUnavailable, isTrue);
  });

  test('charge-cap state parses supported flag', () {
    final cap = ChargeCapState.fromJson({
      'success': true,
      'supported': false,
      'percent': 80,
      'enabled': false,
    });
    expect(cap.supported, isFalse);
  });

  test('bookingId larger than JS safe int round-trips as string', () {
    const huge = '18446744073709551615';
    final b = ClimateBooking.fromCloudListEntry({
      'bookingId': huge,
      'bookingTime': 1736150400,
      'mainSettingTemp': 8,
      'timeSpan': 3,
    });
    expect(b.bookingId, huge);
  });

  test('adas GET esp inverted convention', () {
    final adas = AdasState.fromJson({
      'success': true,
      'esp': {'raw': 0, 'on': true},
      'itac': {'raw': 0, 'on': false},
    });
    expect(adas.espOn, isTrue);
    expect(adas.itacOn, isFalse);
  });
}
