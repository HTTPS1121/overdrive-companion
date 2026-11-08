import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive_companion/core/config/app_settings.dart';
import 'package:overdrive_companion/data/repositories/vehicle_repository.dart';
import 'package:overdrive_companion/features/controls/controls_commands_tab.dart';
import 'package:overdrive_companion/providers/app_providers.dart';
import 'package:overdrive_companion/providers/settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/fixture_api_client.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late VehicleSnapshot fixtureSnap;
  late FixtureOverdriveApiClient client;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    client = await FixtureOverdriveApiClient.create();
    final repo = VehicleRepository(
      settings: const AppSettings(
        baseUrl: 'https://fixture.test',
        deviceToken: 'fixture-token',
      ),
      client: client,
    );
    fixtureSnap = await repo.fetchSnapshot();
  });

  testWidgets('lock shows confirmation before POST', (tester) async {
    final settingsRepo = await SettingsRepository.create();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(settingsRepo),
          appSettingsProvider.overrideWith(() => _PinnedSettings()),
          overdriveApiClientProvider.overrideWithValue(client),
          vehicleRepositoryProvider.overrideWith(() => _RepoNotif(client)),
          vehicleSnapshotProvider.overrideWith(() => _FixedSnap(fixtureSnap)),
        ],
        child: const MaterialApp(home: Scaffold(body: ControlsCommandsTab())),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('נעילה'));
    await tester.pumpAndSettle();
    expect(find.text('לאשר נעילה?'), findsOneWidget);

    await tester.tap(find.text('ביטול'));
    await tester.pumpAndSettle();
    expect(find.text('לאשר נעילה?'), findsNothing);
  });
}

class _PinnedSettings extends AppSettingsNotifier {
  @override
  AppSettings build() => const AppSettings(
        baseUrl: 'https://fixture.test',
        deviceToken: 'fixture-token',
      );

  @override
  Future<void> bootstrap() async {}
}

class _RepoNotif extends VehicleRepositoryNotifier {
  _RepoNotif(this.client);
  final FixtureOverdriveApiClient client;

  @override
  VehicleRepository build() => VehicleRepository(
        settings: const AppSettings(
          baseUrl: 'https://fixture.test',
          deviceToken: 'fixture-token',
        ),
        client: client,
      );
}

class _FixedSnap extends VehicleSnapshotNotifier {
  _FixedSnap(this._snap);
  final VehicleSnapshot _snap;

  @override
  Future<VehicleSnapshot?> build() async => _snap;
}
