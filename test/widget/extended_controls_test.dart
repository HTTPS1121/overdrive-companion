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
    expect(fixtureSnap.state.batteryHeat, isNotNull);
  });

  Future<void> pumpCommands(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
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
    await tester.scrollUntilVisible(
      find.text('הדלקה וכיבוי'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
  }

  testWidgets('extended controls visible with battery heat toggle', (tester) async {
    await pumpCommands(tester);
    expect(find.text('הדלקת רכב (power-on)'), findsOneWidget);
    expect(find.text('חימום מקדים לסוללה'), findsOneWidget);
    expect(find.text('צילום מסך מולטימדיה'), findsOneWidget);
  });

  testWidgets('power-on shows confirm dialog', (tester) async {
    await pumpCommands(tester);
    await tester.tap(find.text('הדלקת רכב (power-on)'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('להדליק את הרכב?'), findsOneWidget);
  });

  testWidgets('screenshot shows confirm dialog', (tester) async {
    await pumpCommands(tester);
    await tester.scrollUntilVisible(
      find.text('צילום מסך מולטימדיה'),
      80,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.text('צילום מסך מולטימדיה'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('צילום מסך מולטימדיה'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('לאשר צילום מסך מולטימדיה?'), findsOneWidget);
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
