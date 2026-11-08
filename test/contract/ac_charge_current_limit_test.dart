import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive_companion/data/models/remote_feature_models.dart';

import '../support/mock_overdrive_backend.dart';

void main() {
  late MockOverdriveBackend backend;

  setUp(() {
    backend = MockOverdriveBackend();
  });

  test('GET matches handler shape', () {
    final json = backend.handleGet('/api/vehicle/ac-charge-current-limit');
    final s = AcChargeCurrentLimitState.fromJson(json);
    expect(s.success, isTrue);
    expect(s.supported, isTrue);
    expect(s.available, isTrue);
    expect(s.state, inInclusiveRange(1, 5));
    expect(s.label, isNotNull);
  });

  test('POST sends state integer 1..5 and readback', () {
    final posted = backend.handlePost(
      '/api/vehicle/ac-charge-current-limit',
      {'state': 4},
    );
    expect(posted['success'], isTrue);
    expect(posted['state'], 4);
    final after = AcChargeCurrentLimitState.fromJson(
      backend.handleGet('/api/vehicle/ac-charge-current-limit'),
    );
    expect(after.state, 4);
  });

  test('POST rejects state outside 1..5', () {
    final bad = backend.handlePost(
      '/api/vehicle/ac-charge-current-limit',
      {'state': 0},
    );
    expect(bad['success'], isFalse);
  });
}
