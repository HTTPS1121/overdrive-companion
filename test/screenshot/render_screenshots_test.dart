import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive_companion/app.dart';
import 'package:overdrive_companion/core/config/app_settings.dart';
import 'package:overdrive_companion/core/theme/companion_color_schemes.dart';
import 'package:overdrive_companion/data/models/vehicle_state.dart';
import 'package:overdrive_companion/data/repositories/vehicle_repository.dart';
import 'package:overdrive_companion/features/controls/controls_commands_tab.dart';
import 'package:overdrive_companion/features/controls/controls_hub_screen.dart';
import 'package:overdrive_companion/features/integrations/integrations_hub_screen.dart';
import 'package:overdrive_companion/features/status/vehicle_hero_visual.dart';
import 'package:overdrive_companion/data/repositories/extended_services_repository.dart';
import 'package:overdrive_companion/l10n/app_localizations.dart';
import 'package:overdrive_companion/providers/app_providers.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:overdrive_companion/providers/settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/fixture_api_client.dart';
import 'screenshot_harness.dart';
import 'test_fonts.dart';

const _artifactRoots = [
  '/opt/cursor/artifacts/v2.8.3/screenshots',
  '/cursor/stores/self/artifacts/v2.8.3/screenshots',
];
const _artifactPackageRoots = [
  '/opt/cursor/artifacts/v2.8.3',
  '/cursor/stores/self/artifacts/v2.8.3',
];
const _goldenRoot = 'goldens/v2.8.3';

late SettingsRepository _settingsRepo;
late VehicleSnapshot _fixtureSnap;
late VehicleSnapshot _offlineSnap;
late FixtureOverdriveApiClient _fixtureClient;

const _navLabelsHe = ['מצב', 'שליטה', 'מצלמות', 'מיקום', 'הגדרות'];
const _navLabelsEn = ['Status', 'Controls', 'Cameras', 'Location', 'Settings'];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    await ensureScreenshotFonts();
    _stageReleaseManifest();
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
      state: VehicleState(success: false, error: 'connection_not_configured'),
      lastUpdated: DateTime.now(),
      offline: true,
      errorMessage: 'connection_not_configured',
    );
  });

  testWidgets('v2.7 setup unconfigured light he', (tester) async {
    await _capture(
      tester,
      '01_setup_unconfigured_light_he',
      settings: AppSettings.defaults().copyWith(
        themeMode: CompanionThemeMode.light,
        useDynamicColor: false,
        baseUrl: 'https://fixture.test',
        deviceId: 'mock-atto3-demo',
      ),
      snapshot: null,
      locale: const Locale('he'),
    );
  });

  testWidgets('v2.7 setup unconfigured light en', (tester) async {
    await _capture(
      tester,
      '01b_setup_unconfigured_light_en',
      settings: AppSettings.defaults().copyWith(
        themeMode: CompanionThemeMode.light,
        useDynamicColor: false,
        baseUrl: 'https://fixture.test',
        deviceId: 'mock-atto3-demo',
      ),
      snapshot: null,
      locale: const Locale('en'),
    );
  });

  testWidgets('v2.7 status fixture dark he', (tester) async {
    await _capture(
      tester,
      '02_status_fixture_dark_he',
      settings: _fixtureSettings(dark: true),
      snapshot: _fixtureSnap,
      expectNavIndex: 0,
      locale: const Locale('he'),
      afterPump: (t) async => _awaitHeroImage(t),
    );
  });

  testWidgets('v2.7 status fixture light en', (tester) async {
    await _capture(
      tester,
      '02b_status_fixture_light_en',
      settings: _fixtureSettings(),
      snapshot: _fixtureSnap,
      expectNavIndex: 0,
      locale: const Locale('en'),
      afterPump: (t) async {
        await _awaitHeroImage(t);
        expect(find.textContaining('Coordinates'), findsNothing);
      },
    );
  });

  testWidgets('v2.7 status fixture seed palette light en (not OS dynamic)', (tester) async {
    await _capture(
      tester,
      '02c_status_fixture_seed_palette_light_en',
      settings: _fixtureSettings().copyWith(useDynamicColor: true),
      snapshot: _fixtureSnap,
      expectNavIndex: 0,
      locale: const Locale('en'),
      lightScheme: CompanionColorSchemes.evAccentLight,
      darkScheme: CompanionColorSchemes.evAccentDark,
    );
  });

  testWidgets('v2.7 controls fixture light he', (tester) async {
    await _capture(
      tester,
      '03_controls_fixture_light_he',
      settings: _fixtureSettings(),
      snapshot: _fixtureSnap,
      expectNavIndex: 1,
      locale: const Locale('he'),
      afterPump: (t) async {
        await _tapControlsHubTab(t, 'פקודות', locale: const Locale('he'));
        expect(find.text('נעילה'), findsOneWidget);
      },
    );
  });

  testWidgets('v2.7 cameras fixture light he', (tester) async {
    await _capture(
      tester,
      '12_camera_hub_fixture_light_he',
      settings: _fixtureSettings(),
      snapshot: _fixtureSnap,
      expectNavIndex: 2,
      locale: const Locale('he'),
      afterPump: (t) async {
        for (var i = 0; i < 40; i++) {
          await t.pump(const Duration(milliseconds: 100));
          if (find.text('שידור חי').evaluate().isNotEmpty &&
              find.byType(CircularProgressIndicator).evaluate().isEmpty) {
            break;
          }
        }
        expect(find.textContaining('wss://'), findsNothing);
        expect(find.textContaining('MediaCodec'), findsNothing);
        expect(find.text('שידור חי'), findsOneWidget);
      },
    );
  });

  testWidgets('v2.7 cameras fixture dark en', (tester) async {
    await _capture(
      tester,
      '12b_camera_hub_fixture_dark_en',
      settings: _fixtureSettings(dark: true),
      snapshot: _fixtureSnap,
      expectNavIndex: 2,
      locale: const Locale('en'),
      afterPump: (t) async {
        for (var i = 0; i < 40; i++) {
          await t.pump(const Duration(milliseconds: 100));
          if (find.text('Live stream').evaluate().isNotEmpty &&
              find.byType(CircularProgressIndicator).evaluate().isEmpty) {
            break;
          }
        }
        expect(find.textContaining('Annex'), findsNothing);
      },
    );
  });

  testWidgets('v2.7 location fixture light he', (tester) async {
    await _capture(
      tester,
      '04_location_fixture_light_he',
      settings: _fixtureSettings(),
      snapshot: _fixtureSnap,
      expectNavIndex: 3,
      locale: const Locale('he'),
      afterPump: (t) async {
        expect(find.text('פתיחה בניווט'), findsOneWidget); // he locale
        expect(find.textContaining('32.08530'), findsOneWidget);
      },
    );
  });

  testWidgets('v2.7 schedules fixture dark he', (tester) async {
    await _capture(
      tester,
      '05_schedules_fixture_dark_he',
      settings: _fixtureSettings(dark: true),
      snapshot: _fixtureSnap,
      expectNavIndex: 1,
      locale: const Locale('he'),
      afterPump: (t) async {
        await _tapControlsHubTab(t, 'תזמונים', locale: const Locale('he'));
        await _awaitSchedulesLoaded(t);
        expect(find.text('תזמוני מיזוג מהשרת'), findsOneWidget);
      },
    );
  });

  testWidgets('v2.7 comfort fixture light he', (tester) async {
    await _capture(
      tester,
      '06_comfort_fixture_light_he',
      settings: _fixtureSettings(),
      snapshot: _fixtureSnap,
      expectNavIndex: 1,
      locale: const Locale('he'),
      afterPump: (t) async {
        await _tapControlsHubTab(t, 'נוחות', locale: const Locale('he'));
        await _awaitComfortLoaded(t);
        expect(find.text('מושב נהג'), findsOneWidget);
      },
    );
  });

  testWidgets('v2.7 charge cap fixture light he', (tester) async {
    await _capture(
      tester,
      '09_charge_cap_fixture_light_he',
      settings: _fixtureSettings(),
      snapshot: _fixtureSnap,
      expectNavIndex: 1,
      locale: const Locale('he'),
      afterPump: (t) async {
        await _tapControlsHubTab(t, 'טעינה', locale: const Locale('he'));
        await _awaitChargeCapLoaded(t);
        expect(find.text('שמירה לשרת'), findsOneWidget);
        expect(find.text('זרם טעינה AC'), findsOneWidget);
      },
    );
  });

  testWidgets('v2.7 extended controls fixture light he', (tester) async {
    await _capture(
      tester,
      '11_extended_controls_fixture_light_he',
      settings: _fixtureSettings(),
      snapshot: _fixtureSnap,
      expectNavIndex: 1,
      locale: const Locale('he'),
      afterPump: (t) async {
        await _tapControlsHubTab(t, 'פקודות', locale: const Locale('he'));
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

  testWidgets('v2.7 settings configured light he', (tester) async {
    await _capture(
      tester,
      '07_settings_light_he',
      settings: _fixtureSettings().copyWith(deviceId: 'mock-atto3-demo'),
      snapshot: _fixtureSnap,
      expectNavIndex: 4,
      locale: const Locale('he'),
      afterPump: (t) async {
        expect(find.text('חיבור'), findsOneWidget);
      },
    );
  });

  testWidgets('v2.7 status offline dark he', (tester) async {
    await _capture(
      tester,
      '08_status_offline_dark_he',
      settings: const AppSettings(
        baseUrl: 'https://offline.example.com',
        deviceToken: 'x',
        themeMode: CompanionThemeMode.dark,
        useDynamicColor: false,
      ),
      snapshot: _offlineSnap,
      expectNavIndex: 0,
      locale: const Locale('he'),
      afterPump: (t) async {
        expect(find.text('חיבור לשרת לא הוגדר'), findsOneWidget);
      },
    );
  });

  testWidgets('v2.8 integrations hub light he', (tester) async {
    configurePhoneView(tester);
    final boundaryKey = GlobalKey();
    await pumpScreenshotApp(
      tester,
      child: const IntegrationsHubScreen(),
      locale: const Locale('he'),
      themeMode: CompanionThemeMode.light,
      settingsRepo: _settingsRepo,
      fixtureClient: _fixtureClient,
      fixtureSnap: _fixtureSnap,
      boundaryKey: boundaryKey,
    );
    expect(find.text('מרכז אינטגרציות'), findsOneWidget);
    await _writeGolden(tester, '13_integrations_hub_light_he', find.byKey(boundaryKey));
  });

  testWidgets('v2.7 lock confirmation dialog he', (tester) async {
    const locale = Locale('he');
    await _pumpHarness(
      tester,
      settings: _fixtureSettings(),
      snapshot: _fixtureSnap,
      expectNavIndex: 1,
      locale: locale,
    );
    await _tapControlsHubTab(tester, 'פקודות', locale: locale);
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

List<String> _navLabelsFor(Locale? locale) =>
    locale?.languageCode == 'en' ? _navLabelsEn : _navLabelsHe;

Future<void> _tapNavIndex(WidgetTester tester, int index, {Locale? locale}) async {
  final labels = _navLabelsFor(locale);
  expect(index, inInclusiveRange(0, labels.length - 1));
  final label = labels[index];
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

Future<void> _tapControlsHubTab(WidgetTester tester, String label, {Locale? locale}) async {
  await _tapNavIndex(tester, 1, locale: locale);
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
  Locale? locale,
  ColorScheme? lightScheme,
  ColorScheme? darkScheme,
  Future<void> Function(WidgetTester)? afterPump,
}) async {
  final boundaryKey = await _pumpHarness(
    tester,
    settings: settings,
    snapshot: snapshot,
    expectNavIndex: expectNavIndex,
    locale: locale ?? const Locale('he'),
    lightScheme: lightScheme,
    darkScheme: darkScheme,
  );
  await _awaitHeroImage(tester);
  await _scrollContentToTop(tester);
  if (afterPump != null) await afterPump(tester);
  await _writeGolden(tester, name, find.byKey(boundaryKey));
}

Future<void> _awaitHeroImage(WidgetTester tester) async {
  if (find.byType(VehicleHeroVisual).evaluate().isEmpty) return;
  final element = tester.element(find.byType(MaterialApp));
  await tester.binding.runAsync(() async {
    await precacheImage(const AssetImage(VehicleHeroVisual.assetPath), element);
  });
  await tester.pumpAndSettle(const Duration(milliseconds: 200));
  final imageFinder = find.byWidgetPredicate(
    (w) =>
        w is Image &&
        w.image is AssetImage &&
        (w.image as AssetImage).assetName == VehicleHeroVisual.assetPath,
  );
  expect(imageFinder, findsOneWidget);
  final image = tester.widget<Image>(imageFinder);
  expect(image.height, isNotNull);
}

Future<void> _scrollContentToTop(WidgetTester tester) async {
  final scrollables = find.byType(Scrollable);
  if (scrollables.evaluate().isEmpty) return;
  final first = scrollables.first;
  await tester.drag(first, const Offset(0, 480));
  await tester.pumpAndSettle();
}

Future<GlobalKey> _pumpHarness(
  WidgetTester tester, {
  required AppSettings settings,
  required VehicleSnapshot? snapshot,
  int? expectNavIndex,
  Locale? locale,
  ColorScheme? lightScheme,
  ColorScheme? darkScheme,
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
        screenshotLocale: locale,
        screenshotLightScheme: lightScheme,
        screenshotDarkScheme: darkScheme,
      ),
    ),
  );
  await tester.pumpAndSettle();

  if (expectNavIndex != null) {
    if (expectNavIndex > 0) {
      await _tapNavIndex(tester, expectNavIndex, locale: locale);
    }
    final bar = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(bar.selectedIndex, expectNavIndex);
  }
  return boundaryKey;
}

void _stageReleaseManifest() {
  const manifestPath = 'docs/RELEASE_MANIFEST_v2.8.3.json';
  final src = File(manifestPath);
  if (!src.existsSync()) return;
  final bytes = src.readAsBytesSync();
  for (final root in _artifactPackageRoots) {
    Directory(root).createSync(recursive: true);
    File('$root/RELEASE_MANIFEST_v2.8.3.json').writeAsBytesSync(bytes);
  }
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

class _FixtureExtendedRepo extends ExtendedServicesRepositoryNotifier {
  _FixtureExtendedRepo(this.client);
  final FixtureOverdriveApiClient client;

  @override
  ExtendedServicesRepository build() => ExtendedServicesRepository(
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
