import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive_companion/core/config/app_settings.dart';
import 'package:overdrive_companion/core/layout/screenshot_scope.dart';
import 'package:overdrive_companion/core/theme/companion_color_schemes.dart';
import 'package:overdrive_companion/data/models/vehicle_state.dart';
import 'package:overdrive_companion/data/repositories/extended_services_repository.dart';
import 'package:overdrive_companion/data/repositories/vehicle_repository.dart';
import 'package:overdrive_companion/features/integrations/diagnostics_screens.dart';
import 'package:overdrive_companion/features/integrations/family_screens.dart';
import 'package:overdrive_companion/features/integrations/integrations_hub_screen.dart';
import 'package:overdrive_companion/features/remote/communicate_voice_panel.dart';
import 'package:overdrive_companion/features/remote/genai_voice_panel.dart';
import 'package:overdrive_companion/l10n/app_localizations.dart';
import 'package:overdrive_companion/providers/app_providers.dart';
import 'package:overdrive_companion/providers/settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/fixture_api_client.dart';
import 'test_fonts.dart';

const _artifactRoots = [
  '/opt/cursor/artifacts/v2.8.3/screenshots',
  '/cursor/stores/self/artifacts/v2.8.3/screenshots',
];
const _goldenRoot = 'goldens/v2.8.3';

late SettingsRepository _settingsRepo;
late VehicleSnapshot _fixtureSnap;
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
  });

  const matrix = [
    _Case('automations', AutomationsFamilyScreen()),
    _Case('parking', ParkingFamilyScreen()),
    _Case('trips', TripsFamilyScreen()),
    _Case('audio', AudioLibraryFamilyScreen()),
    _Case('genai_tools', GenAiToolsFamilyScreen()),
    _Case('telegram', TelegramFamilyScreen()),
    _Case('platform', PlatformConnectorsScreen()),
    _Case('integrations_hub', IntegrationsHubScreen()),
    _Case('diagnostics_hub', DiagnosticsHubScreen()),
    _Case('roadsense', RoadSenseToolsScreen()),
    _Case('seat_debug', SeatDebugScreen()),
  ];

  for (final locale in const [Locale('he'), Locale('en')]) {
    for (final mode in CompanionThemeMode.values) {
      if (mode == CompanionThemeMode.system) continue;
      for (final c in matrix) {
        final tag = '${c.slug}_${mode.name}_${locale.languageCode}';
        testWidgets('v2.8.3 integration $tag', (tester) async {
          await _capture(tester, 'int_$tag', locale: locale, theme: mode, child: c.widget);
        });
      }
    }
  }

  for (final locale in const [Locale('he'), Locale('en')]) {
    for (final mode in [CompanionThemeMode.light, CompanionThemeMode.dark]) {
      final tag = 'voice_ptt_ready_${mode.name}_${locale.languageCode}';
      testWidgets('v2.8.3 $tag', (tester) async {
        await _capture(
          tester,
          'int_$tag',
          locale: locale,
          theme: mode,
          child: const CommunicateVoicePanel(voiceReady: true, listenerReady: true),
        );
      });
      final unavail = 'voice_ptt_unsupported_${mode.name}_${locale.languageCode}';
      testWidgets('v2.8.3 $unavail', (tester) async {
        await _capture(
          tester,
          'int_$unavail',
          locale: locale,
          theme: mode,
          child: const CommunicateVoicePanel(voiceReady: false, listenerReady: false),
        );
      });
      final genTag = 'voice_genai_enabled_${mode.name}_${locale.languageCode}';
      testWidgets('v2.8.3 $genTag', (tester) async {
        await _capture(
          tester,
          'int_$genTag',
          locale: locale,
          theme: mode,
          child: const GenAiVoicePanel(enabled: true),
        );
      });
      final genOff = 'voice_genai_disabled_${mode.name}_${locale.languageCode}';
      testWidgets('v2.8.3 $genOff', (tester) async {
        await _capture(
          tester,
          'int_$genOff',
          locale: locale,
          theme: mode,
          child: const GenAiVoicePanel(enabled: false),
        );
      });
    }
  }
}

class _Case {
  const _Case(this.slug, this.widget);
  final String slug;
  final Widget widget;
}

Future<void> _capture(
  WidgetTester tester,
  String name, {
  required Locale locale,
  required CompanionThemeMode theme,
  required Widget child,
}) async {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final boundaryKey = GlobalKey();
  final settings = AppSettings(
    baseUrl: 'https://fixture.test',
    deviceToken: 'fixture-token',
    themeMode: theme,
    useDynamicColor: false,
    deviceId: 'mock-atto3-demo',
  );

  final light = CompanionColorSchemes.light;
  final dark = CompanionColorSchemes.dark;

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(_settingsRepo),
        appSettingsProvider.overrideWith(() => _PinnedSettings(settings)),
        overdriveApiClientProvider.overrideWithValue(_fixtureClient),
        vehicleRepositoryProvider.overrideWith(() => _FixtureRepo(_fixtureClient)),
        vehicleSnapshotProvider.overrideWith(() => _FixedSnapshot(_fixtureSnap)),
        extendedServicesRepositoryProvider.overrideWith(() => _FixtureExtendedRepo(_fixtureClient)),
      ],
      child: ScreenshotScope(
        active: true,
        child: MaterialApp(
          locale: locale,
          theme: ThemeData(colorScheme: light, useMaterial3: true),
          darkTheme: ThemeData(colorScheme: dark, useMaterial3: true),
          themeMode: switch (theme) {
            CompanionThemeMode.dark => ThemeMode.dark,
            _ => ThemeMode.light,
          },
          home: Scaffold(key: boundaryKey, body: child),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle(const Duration(milliseconds: 400));
  await _writeGolden(tester, name, find.byKey(boundaryKey));
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

class _PinnedSettings extends AppSettingsNotifier {
  _PinnedSettings(this._s);
  final AppSettings _s;

  @override
  AppSettings build() => _s;
}

class _FixtureRepo extends VehicleRepositoryNotifier {
  _FixtureRepo(this.client);
  final FixtureOverdriveApiClient client;

  @override
  VehicleRepository build() => VehicleRepository(
        settings: const AppSettings(baseUrl: 'https://fixture.test', deviceToken: 'fixture-token'),
        client: client,
      );
}

class _FixtureExtendedRepo extends ExtendedServicesRepositoryNotifier {
  _FixtureExtendedRepo(this.client);
  final FixtureOverdriveApiClient client;

  @override
  ExtendedServicesRepository build() => ExtendedServicesRepository(
        settings: const AppSettings(baseUrl: 'https://fixture.test', deviceToken: 'fixture-token'),
        client: client,
      );
}

class _FixedSnapshot extends VehicleSnapshotNotifier {
  _FixedSnapshot(this._snap);
  final VehicleSnapshot _snap;

  @override
  Future<VehicleSnapshot?> build() async => _snap;
}
