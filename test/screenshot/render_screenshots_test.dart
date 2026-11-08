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
import 'package:overdrive_companion/features/controls/controls_commands_tab.dart';
import 'package:overdrive_companion/features/controls/controls_hub_screen.dart';
import 'package:overdrive_companion/providers/app_providers.dart';
import 'package:overdrive_companion/providers/settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/fixture_api_client.dart';
import 'test_fonts.dart';

const _artifactRoots = [
  '/opt/cursor/artifacts/v2.5-0/screenshots',
  '/cursor/stores/self/artifacts/v2.5-0/screenshots',
];
const _goldenRoot = 'goldens/v2.5';

late SettingsRepository _settingsRepo;
late VehicleSnapshot _fixtureSnap;
late VehicleSnapshot _offlineSnap;
late FixtureOverdriveApiClient _fixtureClient;

const _navLabels = ['מצב', 'שליטה', 'מצלמות', 'מיקום', 'הגדרות'];

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

  testWidgets('v2.4 setup unconfigured light', (tester) async {
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

  testWidgets('v2.4 status fixture dark', (tester) async {
    await _capture(
      tester,
      '02_status_fixture_dark',
      settings: _fixtureSettings(dark: true),
      snapshot: _fixtureSnap,
      expectNavIndex: 0,
    );
  });

  testWidgets('v2.4 controls fixture light', (tester) async {
    await _capture(
      tester,
      '03_controls_fixture_light',
      settings: _fixtureSettings(),
      snapshot: _fixtureSnap,
      expectNavIndex: 1,
      afterPump: (t) async {
        await _tapControlsHubTab(t, 'פקודות');
        expect(find.text('נעילה'), findsOneWidget);
      },
    );
  });

  testWidgets('v2.5 cameras fixture light', (tester) async {
    await _capture(
      tester,
      '12_camera_hub_fixture_light',
      settings: _fixtureSettings(),
      snapshot: _fixtureSnap,
      expectNavIndex: 2,
      afterPump: (t) async {
        for (var i = 0; i < 40; i++) {
          await t.pump(const Duration(milliseconds: 100));
          if (find.text('שידור חי').evaluate().isNotEmpty &&
              find.byType(CircularProgressIndicator).evaluate().isEmpty) {
            break;
          }
        }
        expect(find.text('שידור חי'), findsOneWidget);
      },
    );
  });

  testWidgets('v2.4 location fixture light', (tester) async {
    await _capture(
      tester,
      '04_location_fixture_light',
      settings: _fixtureSettings(),
      snapshot: _fixtureSnap,
      expectNavIndex: 3,
      afterPump: (t) async {
        expect(find.text('פתיחה בניווט'), findsOneWidget);
        expect(find.textContaining('32.08530'), findsOneWidget);
      },
    );
  });

  testWidgets('v2.4 schedules fixture dark', (tester) async {
    await _capture(
      tester,
      '05_schedules_fixture_dark',
      settings: _fixtureSettings(dark: true),
      snapshot: _fixtureSnap,
      expectNavIndex: 1,
      afterPump: (t) async {
        await _tapControlsHubTab(t, 'תזמונים');
        await _awaitSchedulesLoaded(t);
        expect(find.text('תזמוני מיזוג מהשרת'), findsOneWidget);
      },
    );
  });

  testWidgets('v2.4 comfort fixture light', (tester) async {
    await _capture(
      tester,
      '06_comfort_fixture_light',
      settings: _fixtureSettings(),
      snapshot: _fixtureSnap,
      expectNavIndex: 1,
      afterPump: (t) async {
        await _tapControlsHubTab(t, 'נוחות');
        await _awaitComfortLoaded(t);
        expect(find.text('מושב נהג'), findsOneWidget);
      },
    );
  });

  testWidgets('v2.4 charge cap fixture light', (tester) async {
    await _capture(
      tester,
      '09_charge_cap_fixture_light',
      settings: _fixtureSettings(),
      snapshot: _fixtureSnap,
      expectNavIndex: 1,
      afterPump: (t) async {
        await _tapControlsHubTab(t, 'טעינה');
        await _awaitChargeCapLoaded(t);
        expect(find.text('שמירה לשרת'), findsOneWidget);
        expect(find.text('זרם טעינה AC'), findsOneWidget);
      },
    );
  });

  testWidgets('v2.4 extended controls fixture light', (tester) async {
    await _capture(
      tester,
      '11_extended_controls_fixture_light',
      settings: _fixtureSettings(),
      snapshot: _fixtureSnap,
      expectNavIndex: 1,
      afterPump: (t) async {
        await _tapControlsHubTab(t, 'פקודות');
        final scrollable = find.descendant(
          of: find.byType(ControlsCommandsTab),
          matching: find.byType(Scrollable),
        );
        await t.scrollUntilVisible(
          find.text('הדלקה וכיבוי'),
          120,
          scrollable: scrollable,
        );
        await t.pumpAndSettle();
        expect(find.text('צילום מסך מולטימדיה'), findsOneWidget);
      },
    );
  });

  testWidgets('v2.4 settings configured light', (tester) async {
    await _capture(
      tester,
      '07_settings_light',
      settings: _fixtureSettings(),
      snapshot: _fixtureSnap,
      expectNavIndex: 4,
      afterPump: (t) async {
        expect(find.text('חיבור'), findsOneWidget);
      },
    );
  });

  testWidgets('v2.4 status offline dark', (tester) async {
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
      expectNavIndex: 0,
    );
  });

  testWidgets('v2.4 lock confirmation dialog', (tester) async {
    await _pumpHarness(
      tester,
      settings: _fixtureSettings(),
      snapshot: _fixtureSnap,
      expectNavIndex: 1,
    );
    await _tapControlsHubTab(tester, 'פקודות');
    await tester.tap(find.text('נעילה'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('לאשר נעילה?'), findsOneWidget);
    await _writeGolden(
      tester,
      '10_controls_lock_confirm_dialog',
      find.byType(AlertDialog),
    );
  });
}

AppSettings _fixtureSettings({bool dark = false}) => AppSettings(
      baseUrl: 'https://fixture.test',
      deviceToken: 'fixture-token',
      themeMode: dark ? CompanionThemeMode.dark : CompanionThemeMode.light,
      useDynamicColor: false,
    );

Future<void> _tapNavIndex(WidgetTester tester, int index) async {
  expect(index, inInclusiveRange(0, _navLabels.length - 1));
  final label = _navLabels[index];
  await tester.tap(
    find.descendant(
      of: find.byType(NavigationBar),
      matching: find.text(label),
    ),
  );
  await tester.pumpAndSettle();
  final bar = tester.widget<NavigationBar>(find.byType(NavigationBar));
  expect(bar.selectedIndex, index, reason: 'NavigationBar selectedIndex after tap');
}

Future<void> _tapControlsHubTab(WidgetTester tester, String label) async {
  await _tapNavIndex(tester, 1);
  final tab = find.descendant(
    of: find.descendant(
      of: find.byType(ControlsHubScreen),
      matching: find.byType(TabBar),
    ),
    matching: find.text(label),
  );
  expect(tab, findsOneWidget);
  await tester.tap(tab);
  await tester.pumpAndSettle();
}

Future<void> _awaitSchedulesLoaded(WidgetTester tester) async {
  for (var i = 0; i < 30; i++) {
    await tester.pump(const Duration(milliseconds: 100));
    if (find.byType(CircularProgressIndicator).evaluate().isEmpty &&
        (find.text('תזמוני מיזוג מהשרת').evaluate().isNotEmpty ||
            find.textContaining('לא זמינה').evaluate().isNotEmpty)) {
      return;
    }
  }
  fail('schedules tab did not finish loading');
}

Future<void> _awaitComfortLoaded(WidgetTester tester) async {
  for (var i = 0; i < 30; i++) {
    await tester.pump(const Duration(milliseconds: 100));
    if (find.text('מושב נהג').evaluate().isNotEmpty) return;
  }
  fail('comfort tab did not finish loading');
}

Future<void> _awaitChargeCapLoaded(WidgetTester tester) async {
  for (var i = 0; i < 40; i++) {
    await tester.pump(const Duration(milliseconds: 100));
    final spinners = find.descendant(
      of: find.byType(ControlsHubScreen),
      matching: find.byType(CircularProgressIndicator),
    );
    if (spinners.evaluate().isEmpty &&
        find.text('מגבלת טעינה').evaluate().isNotEmpty &&
        find.text('זרם טעינה AC').evaluate().isNotEmpty) {
      return;
    }
  }
  fail('charge-cap tab stuck loading');
}

Future<void> _capture(
  WidgetTester tester,
  String name, {
  required AppSettings settings,
  required VehicleSnapshot? snapshot,
  int? expectNavIndex,
  Future<void> Function(WidgetTester)? afterPump,
}) async {
  final boundaryKey = await _pumpHarness(
    tester,
    settings: settings,
    snapshot: snapshot,
    expectNavIndex: expectNavIndex,
  );
  if (afterPump != null) await afterPump(tester);
  await _writeGolden(tester, name, find.byKey(boundaryKey));
}

Future<GlobalKey> _pumpHarness(
  WidgetTester tester, {
  required AppSettings settings,
  required VehicleSnapshot? snapshot,
  int? expectNavIndex,
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
        overdriveApiClientProvider.overrideWithValue(_fixtureClient),
        vehicleRepositoryProvider.overrideWith(() => _FixtureRepo(_fixtureClient)),
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
  await tester.pumpAndSettle();

  if (expectNavIndex != null) {
    if (expectNavIndex > 0) {
      await _tapNavIndex(tester, expectNavIndex);
    }
    final bar = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(bar.selectedIndex, expectNavIndex);
  }
  return boundaryKey;
}

Future<void> _writeGolden(WidgetTester tester, String name, Finder finder) async {
  final golden = '$_goldenRoot/$name.png';
  await expectLater(finder, matchesGoldenFile(golden));

  final src = File('test/screenshot/$golden');
  final bytes = src.readAsBytesSync();
  for (final root in _artifactRoots) {
    final artifactDir = Directory(root);
    artifactDir.createSync(recursive: true);
    File('${artifactDir.path}/$name.png').writeAsBytesSync(bytes);
  }
}

class _FixtureRepo extends VehicleRepositoryNotifier {
  _FixtureRepo(this.client);
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
