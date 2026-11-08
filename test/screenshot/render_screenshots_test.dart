import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive_companion/app.dart';
import 'package:overdrive_companion/core/config/app_settings.dart';
import 'package:overdrive_companion/data/api/overdrive_api_client.dart';
import 'package:overdrive_companion/data/models/vehicle_state.dart';
import 'package:overdrive_companion/data/repositories/vehicle_repository.dart';
import 'package:overdrive_companion/providers/app_providers.dart';
import 'package:overdrive_companion/providers/settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/fixture_api_client.dart';
import 'test_fonts.dart';

late SettingsRepository _settingsRepo;
late VehicleSnapshot _fixtureSnap;
late VehicleSnapshot _offlineSnap;
late FixtureOverdriveApiClient _fixtureClient;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final outDir = Directory('/opt/cursor/artifacts/screenshots');
  outDir.createSync(recursive: true);

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    await ensureScreenshotFonts();
    _settingsRepo = await SettingsRepository.create();
    _fixtureClient = await FixtureOverdriveApiClient.create();
    final repo = VehicleRepository(
      settings: const AppSettings(
        baseUrl: 'https://fixture.test',
        deviceToken: 'fixture-token',
      ),
      client: _fixtureClient,
    );
    _fixtureSnap = await repo.fetchSnapshot();
    _offlineSnap = VehicleSnapshot(
      state: VehicleState(success: false, error: 'אין רשת לשרת הרכב'),
      lastUpdated: DateTime.now(),
      offline: true,
      errorMessage: 'אין רשת לשרת הרכב',
    );
  });

  testWidgets('01_setup_unconfigured golden', (tester) async {
    _preparePhoneSurface(tester);
    await _capture(
      tester,
      '01_setup_unconfigured',
      settings: AppSettings.defaults(),
      snapshot: null,
    );
    _copyGolden('01_setup_unconfigured', outDir);
    expect(find.text('התחבר למנהרה של Overdrive ברכב'), findsOneWidget);
  });

  testWidgets('02_status_offline golden', (tester) async {
    _preparePhoneSurface(tester);
    await _capture(
      tester,
      '02_status_offline',
      settings: const AppSettings(
        baseUrl: 'https://offline.example.com',
        deviceToken: 'x',
      ),
      snapshot: _offlineSnap,
    );
    _copyGolden('02_status_offline', outDir);
  });

  testWidgets('03_status_fixture golden', (tester) async {
    _preparePhoneSurface(tester);
    await _capture(
      tester,
      '03_status_fixture',
      settings: const AppSettings(
        baseUrl: 'https://fixture.test',
        deviceToken: 'fixture-token',
      ),
      snapshot: _fixtureSnap,
      clientOverride: _fixtureClient,
    );
    _copyGolden('03_status_fixture', outDir);
    expect(find.textContaining('%'), findsWidgets);
  });

  testWidgets('04_settings_configured golden', (tester) async {
    _preparePhoneSurface(tester);
    await _capture(
      tester,
      '04_settings_configured',
      settings: const AppSettings(
        baseUrl: 'https://fixture.test',
        deviceToken: 'fixture-token',
      ),
      snapshot: _fixtureSnap,
      clientOverride: _fixtureClient,
      afterPump: (t) async {
        await t.tap(find.text('הגדרות'));
        await t.pump(const Duration(milliseconds: 400));
      },
    );
    _copyGolden('04_settings_configured', outDir);
  });
}

void _preparePhoneSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void _copyGolden(String name, Directory outDir) {
  final golden = File('test/screenshot/goldens/$name.png');
  final dest = File('${outDir.path}/$name.png');
  dest.writeAsBytesSync(golden.readAsBytesSync());
}

Future<void> _capture(
  WidgetTester tester,
  String name, {
  required AppSettings settings,
  required VehicleSnapshot? snapshot,
  OverdriveApiClient? clientOverride,
  Future<void> Function(WidgetTester)? afterPump,
}) async {
  await ensureScreenshotFonts();
  final boundaryKey = GlobalKey();
  _FixedAppSettings.pinned = settings;

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(_settingsRepo),
        appSettingsProvider.overrideWith(_FixedAppSettings.new),
        if (clientOverride != null)
          overdriveApiClientProvider.overrideWithValue(clientOverride),
        vehicleSnapshotProvider.overrideWith(() => _FixedSnapshot(snapshot)),
      ],
      child: OverdriveApp(
        initialSettings: settings,
        screenshotBoundaryKey: boundaryKey,
        lockPhoneViewport: true,
        screenshotMode: true,
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 600));
  if (afterPump != null) await afterPump(tester);

  await expectLater(find.byKey(boundaryKey), matchesGoldenFile('goldens/$name.png'));
}

class _FixedAppSettings extends AppSettingsNotifier {
  static AppSettings? pinned;

  @override
  AppSettings build() => pinned ?? AppSettings.defaults();

  @override
  Future<void> bootstrap() async {}
}

class _FixedSnapshot extends VehicleSnapshotNotifier {
  _FixedSnapshot(this._snap);
  final VehicleSnapshot? _snap;

  @override
  Future<VehicleSnapshot?> build() async => _snap;
}
