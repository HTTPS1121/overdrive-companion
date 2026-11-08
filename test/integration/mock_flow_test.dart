import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive_companion/core/config/app_settings.dart';
import 'package:overdrive_companion/data/repositories/overdrive_endpoints.dart';
import 'package:overdrive_companion/data/repositories/vehicle_repository.dart';

import '../support/fixture_api_client.dart';
import '../support/mock_overdrive_backend.dart';

/// In-memory fixture flow — not a live vehicle or tunnel.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('fixture flow: snapshot, unlock, refresh verifies state', () async {
    final client = await FixtureOverdriveApiClient.create();
    final repo = VehicleRepository(
      settings: const AppSettings(
        baseUrl: 'https://fixture.test',
        deviceToken: 'fixture-token',
      ),
      client: client,
    );

    final before = await repo.fetchSnapshot();
    expect(before.state.isLocked, isTrue);

    final unlock = await repo.runControl(
      kCompanionControls.firstWhere((c) => c.kind == ControlKind.unlock),
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
