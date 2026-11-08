import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive_companion/app.dart';
import 'package:overdrive_companion/core/config/app_settings.dart';
import 'package:overdrive_companion/data/mock/mock_overdrive_backend.dart';
import 'package:overdrive_companion/data/models/vehicle_state.dart';
import 'package:overdrive_companion/data/repositories/vehicle_repository.dart';
import 'package:overdrive_companion/providers/app_providers.dart';
import 'package:overdrive_companion/providers/settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'test_fonts.dart';

late SettingsRepository _settingsRepo;
late VehicleSnapshot _liveSnap;
late VehicleSnapshot _offlineSnap;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final outDir = Directory('/opt/cursor/artifacts/screenshots');
  outDir.createSync(recursive: true);

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    TestWidgetsFlutterBinding.ensureInitialized();
    await ensureScreenshotFonts();
    _settingsRepo = await SettingsRepository.create();

    final repo = VehicleRepository(
      settings: AppSettings.defaults(),
      mockBackend: MockOverdriveBackend(),
    );
    _liveSnap = await repo.fetchSnapshot();
    _offlineSnap = VehicleSnapshot(
      state: VehicleState(success: false, error: 'אין רשת לשרת הרכב'),
      lastUpdated: DateTime.now(),
      offline: true,
      errorMessage: 'אין רשת לשרת הרכב',
    );
  });

  testWidgets('01 dashboard demo golden', (tester) async {
    _preparePhoneSurface(tester);
    await _capture(tester, '01_dashboard_demo', _liveSnap);
    _copyGolden('01_dashboard_demo', outDir);
  });

  testWidgets('02 controls golden', (tester) async {
    _preparePhoneSurface(tester);
    await _capture(
      tester,
      '02_controls_demo',
      _liveSnap,
      afterPump: (t) async {
        await t.tap(find.text('שליטה'));
        await t.pump(const Duration(milliseconds: 400));
      },
    );
    _copyGolden('02_controls_demo', outDir);
  });

  testWidgets('03 settings golden', (tester) async {
    _preparePhoneSurface(tester);
    await _capture(
      tester,
      '03_settings_demo',
      _liveSnap,
      afterPump: (t) async {
        await t.tap(find.text('הגדרות'));
        await t.pump(const Duration(milliseconds: 400));
      },
    );
    _copyGolden('03_settings_demo', outDir);
  });

  testWidgets('04 dashboard offline golden', (tester) async {
    _preparePhoneSurface(tester);
    await _capture(
      tester,
      '04_dashboard_offline',
      _offlineSnap,
      afterPump: (t) async {
        expect(find.text('אין חיבור לרכב'), findsOneWidget);
        expect(find.text('BYD Atto 3'), findsNothing);
      },
    );
    _copyGolden('04_dashboard_offline', outDir);
    final s1 = File('test/screenshot/goldens/01_dashboard_demo.png').lengthSync();
    final s4 = File('test/screenshot/goldens/04_dashboard_offline.png').lengthSync();
    expect(s1, isNot(equals(s4)));
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
  String name,
  VehicleSnapshot snap, {
  Future<void> Function(WidgetTester)? afterPump,
}) async {
  await ensureScreenshotFonts();
  final boundaryKey = GlobalKey();
  final settings = AppSettings.defaults();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(_settingsRepo),
        appSettingsProvider.overrideWith(_FixedAppSettings.new),
        vehicleSnapshotProvider.overrideWith(() => _FixedSnapshot(snap)),
        mockBackendProvider.overrideWithValue(MockOverdriveBackend()),
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
  @override
  AppSettings build() => AppSettings.defaults();

  @override
  void applyInitial(AppSettings settings) {}

  @override
  Future<void> bootstrap() async {}
}

class _FixedSnapshot extends VehicleSnapshotNotifier {
  _FixedSnapshot(this._snap);
  final VehicleSnapshot _snap;

  @override
  Future<VehicleSnapshot?> build() async => _snap;
}
