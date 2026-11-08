import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive_companion/core/config/app_settings.dart';
import 'package:overdrive_companion/data/mock/mock_overdrive_backend.dart';
import 'package:overdrive_companion/data/repositories/overdrive_endpoints.dart';
import 'package:overdrive_companion/data/repositories/vehicle_repository.dart';

/// Simulated end-to-end against in-memory mock — not a live vehicle.
void main() {
  test('mock flow: snapshot, unlock, refresh verifies state', () async {
    final repo = VehicleRepository(
      settings: AppSettings.defaults(),
      mockBackend: MockOverdriveBackend(),
    );

    final before = await repo.fetchSnapshot();
    expect(before.state.isLocked, isTrue);

    final unlock = await repo.runControl(
      kStage1Controls.firstWhere((c) => c.kind == ControlKind.unlock),
    );
    expect(unlock.userConfirmed, isTrue);

    final after = await repo.fetchSnapshot();
    expect(after.state.isLocked, isFalse);
  });

  test('HTTP-style failure does not claim success', () {
    final backend = MockOverdriveBackend();
    final bad = backend.handlePost('/api/nope', {});
    expect(bad['success'], isFalse);
  });
}
