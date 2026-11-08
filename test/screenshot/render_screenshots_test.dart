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

const _artifactRoot = '/opt/cursor/artifacts/v2.1-0/screenshots';
const _goldenRoot = 'goldens/v2.1';

late SettingsRepository _settingsRepo;
late VehicleSnapshot _fixtureSnap;
late VehicleSnapshot _offlineSnap;
late FixtureOverdriveApiClient _fixtureClient;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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
        useDynamicColor: false,
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

  testWidgets('v2.1 setup unconfigured light', (tester) async {
    await _capture(
      tester,
      '01_setup_unconfigured_light',
      settings: AppSettings.defaults().copyWith(
        themeMode: CompanionThemeMode.light,
        useDynamicColor: false,
      ),
      snapshot: null,
    );
  });

  testWidgets('v2.1 status fixture dark', (tester) async {
    await _capture(
      tester,
      '02_status_fixture_dark',
      settings: const AppSettings(
        baseUrl: 'https://fixture.test',
        deviceToken: 'fixture-token',
        themeMode: CompanionThemeMode.dark,
        useDynamicColor: false,
      ),
      snapshot: _fixtureSnap,
      clientOverride: _fixtureClient,
    );
  });

  testWidgets('v2.1 controls fixture light', (tester) async {
    await _capture(
      tester,
      '03_controls_fixture_light',
      settings: const AppSettings(
        baseUrl: 'https://fixture.test',
        deviceToken: 'fixture-token',
        themeMode: CompanionThemeMode.light,
        useDynamicColor: false,
      ),
      snapshot: _fixtureSnap,
      clientOverride: _fixtureClient,
      afterPump: (t) async {
        await _tapNav(t, 'שליטה');
      },
    );
  });

  testWidgets('v2.1 location fixture light', (tester) async {
    await _capture(
      tester,
      '04_location_fixture_light',
      settings: const AppSettings(
        baseUrl: 'https://fixture.test',
        deviceToken: 'fixture-token',
        themeMode: CompanionThemeMode.light,
        useDynamicColor: false,
      ),
      snapshot: _fixtureSnap,
      clientOverride: _fixtureClient,
      afterPump: (t) async {
        await _tapNav(t, 'מיקום');
      },
    );
  });

  testWidgets('v2.1 schedules fixture dark', (tester) async {
    await _capture(
      tester,
      '05_schedules_fixture_dark',
      settings: const AppSettings(
        baseUrl: 'https://fixture.test',
        deviceToken: 'fixture-token',
        themeMode: CompanionThemeMode.dark,
        useDynamicColor: false,
      ),
      snapshot: _fixtureSnap,
      clientOverride: _fixtureClient,
      afterPump: (t) async {
        await _tapNav(t, 'תזמונים');
      },
    );
  });

  testWidgets('v2.1 comfort fixture light', (tester) async {
    await _capture(
      tester,
      '06_comfort_fixture_light',
      settings: const AppSettings(
        baseUrl: 'https://fixture.test',
        deviceToken: 'fixture-token',
        themeMode: CompanionThemeMode.light,
        useDynamicColor: false,
      ),
      snapshot: _fixtureSnap,
      clientOverride: _fixtureClient,
      afterPump: (t) async {
        await _tapNav(t, 'נוחות');
      },
    );
  });

  testWidgets('v2.1 settings configured light', (tester) async {
    await _capture(
      tester,
      '07_settings_light',
      settings: const AppSettings(
        baseUrl: 'https://fixture.test',
        deviceToken: 'fixture-token',
        themeMode: CompanionThemeMode.light,
        useDynamicColor: false,
      ),
      snapshot: _fixtureSnap,
      clientOverride: _fixtureClient,
      afterPump: (t) async {
        await _tapNav(t, 'הגדרות');
      },
    );
  });

  testWidgets('v2.1 status offline dark', (tester) async {
    await _capture(
      tester,
      '08_status_offline_dark',
      settings: const AppSettings(
        baseUrl: 'https://offline.example.com',
        deviceToken: 'x',
        themeMode: CompanionThemeMode.dark,
        useDynamicColor: false,
      ),
      snapshot: _offlineSnap,
    );
  });
}

Future<void> _tapNav(WidgetTester tester, String label) async {
  await tester.tap(
    find.descendant(
      of: find.byType(NavigationBar),
      matching: find.text(label),
    ),
  );
  await tester.pump(const Duration(milliseconds: 400));
}

Future<void> _capture(
  WidgetTester tester,
  String name, {
  required AppSettings settings,
  required VehicleSnapshot? snapshot,
  OverdriveApiClient? clientOverride,
  Future<void> Function(WidgetTester)? afterPump,
}) async {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

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

  final golden = '$_goldenRoot/$name.png';
  await expectLater(find.byKey(boundaryKey), matchesGoldenFile(golden));

  final artifactDir = Directory(_artifactRoot);
  artifactDir.createSync(recursive: true);
  final src = File('test/screenshot/$golden');
  File('${artifactDir.path}/$name.png').writeAsBytesSync(src.readAsBytesSync());
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
