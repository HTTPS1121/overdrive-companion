import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive_companion/core/formatting/timestamp_normalize.dart';

void main() {
  test('Unix seconds (fixture mqtt telemetry)', () {
    final dt = parseVehicleTimestampValue(1730000000);
    expect(dt, isNotNull);
    expect(dt!.year, greaterThan(2020));
    expect(dt.year, lessThan(2040));
  });

  test('Unix milliseconds', () {
    final dt = parseVehicleTimestampValue(1730000000000);
    expect(dt, isNotNull);
    expect(dt!.year, greaterThan(2020));
  });

  test('ISO-8601 string', () {
    final dt = parseVehicleTimestampValue('2025-11-07T18:00:00Z');
    expect(dt, isNotNull);
    expect(dt!.year, 2025);
  });

  test('invalid numeric garbage returns null', () {
    expect(parseVehicleTimestampValue(42), isNull);
    expect(parseVehicleTimestampValue('not-a-date'), isNull);
  });
}
