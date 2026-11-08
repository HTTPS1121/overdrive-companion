import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive_companion/core/config/app_settings.dart';
import 'package:overdrive_companion/core/theme/companion_theme.dart';
import 'package:overdrive_companion/data/repositories/vehicle_repository.dart';
import 'package:overdrive_companion/features/status/vehicle_status_screen.dart';
import 'package:overdrive_companion/providers/app_providers.dart';

import '../screenshot/test_fonts.dart';
import '../support/fixture_api_client.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await ensureScreenshotFonts();
  });

  testWidgets('status shows SOC from fixture client', (tester) async {
    final client = await FixtureOverdriveApiClient.create();
    final repo = VehicleRepository(
      settings: const AppSettings(
        baseUrl: 'https://fixture.test',
        deviceToken: 'fixture-token',
      ),
      client: client,
    );
    final snap = await repo.fetchSnapshot();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSettingsProvider.overrideWith(_StaticSettings.new),
          overdriveApiClientProvider.overrideWithValue(client),
          vehicleSnapshotProvider.overrideWith(() => _FixedSnapshot(snap)),
        ],
        child: MaterialApp(
          theme: companionLightTheme(),
          home: const Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(body: VehicleStatusScreen()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('%'), findsWidgets);
    expect(find.text('דמו'), findsNothing);
  });
}

class _StaticSettings extends AppSettingsNotifier {
  @override
  AppSettings build() => const AppSettings(
        baseUrl: 'https://fixture.test',
        deviceToken: 'fixture-token',
      );
}

class _FixedSnapshot extends VehicleSnapshotNotifier {
  _FixedSnapshot(this._snap);
  final VehicleSnapshot _snap;

  @override
  Future<VehicleSnapshot?> build() async => _snap;
}
