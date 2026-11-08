import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive_companion/core/config/app_settings.dart';
import 'package:overdrive_companion/core/layout/phone_viewport.dart';
import 'package:overdrive_companion/core/layout/screenshot_scope.dart';
import 'package:overdrive_companion/core/theme/companion_color_schemes.dart';
import 'package:overdrive_companion/core/theme/companion_theme.dart';
import 'package:overdrive_companion/data/models/vehicle_state.dart';
import 'package:overdrive_companion/data/repositories/extended_services_repository.dart';
import 'package:overdrive_companion/data/repositories/vehicle_repository.dart';
import 'package:overdrive_companion/l10n/app_localizations.dart';
import 'package:overdrive_companion/providers/app_providers.dart';
import 'package:overdrive_companion/providers/settings_repository.dart';

import 'package:overdrive_companion/features/integrations/integrations_hub_screen.dart';
import 'package:overdrive_companion/features/screenshot/screenshot_push_navigator.dart';
import 'package:overdrive_companion/features/screenshot/screenshot_settings_stub.dart';

import '../support/fixture_api_client.dart';
import 'test_fonts.dart';

const screenshotGoldenRoot = 'goldens/v2.8.4';
const screenshotArtifactRoots = [
  '/opt/cursor/artifacts/v2.8.4/screenshots',
  '/cursor/stores/self/artifacts/v2.8.4/screenshots',
];

void configurePhoneView(WidgetTester tester) {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<GlobalKey> pumpScreenshotApp(
  WidgetTester tester, {
  required Widget child,
  required Locale locale,
  required CompanionThemeMode themeMode,
  required SettingsRepository settingsRepo,
  required FixtureOverdriveApiClient fixtureClient,
  required VehicleSnapshot fixtureSnap,
  required GlobalKey boundaryKey,
  bool pushFromParent = false,
  Widget? parentForPush,
}) async {
  await ensureScreenshotFonts();
  await initializeDateFormatting('en');
  await initializeDateFormatting('he');
  final settings = AppSettings(
    baseUrl: 'https://fixture.test',
    deviceToken: 'fixture-token',
    themeMode: themeMode,
    useDynamicColor: false,
    deviceId: 'mock-atto3-demo',
  );
  final light = CompanionColorSchemes.light;
  final dark = CompanionColorSchemes.dark;

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(settingsRepo),
        appSettingsProvider.overrideWith(() => _PinnedSettings(settings)),
        overdriveApiClientProvider.overrideWithValue(fixtureClient),
        vehicleRepositoryProvider.overrideWith(() => _FixtureRepo(fixtureClient)),
        vehicleSnapshotProvider.overrideWith(() => _FixedSnapshot(fixtureSnap)),
        extendedServicesRepositoryProvider.overrideWith(() => _FixtureExtendedRepo(fixtureClient)),
      ],
      child: ScreenshotScope(
        active: true,
        child: MaterialApp(
          locale: locale,
          theme: companionLightTheme(colorScheme: light),
          darkTheme: companionDarkTheme(colorScheme: dark),
          themeMode: themeMode == CompanionThemeMode.dark ? ThemeMode.dark : ThemeMode.light,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, appChild) => RepaintBoundary(
            key: boundaryKey,
            child: PhoneViewport(child: appChild ?? const SizedBox.shrink()),
          ),
          home: pushFromParent
              ? ScreenshotPushNavigator(
                  parent: parentForPush ?? const IntegrationsHubScreen(),
                  route: child,
                )
              : child,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle(const Duration(milliseconds: 800));
  if (pushFromParent) {
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
  }
  return boundaryKey;
}

Future<void> writeScreenshotGolden(WidgetTester tester, String name, Finder finder) async {
  final golden = '$screenshotGoldenRoot/$name.png';
  await expectLater(finder, matchesGoldenFile(golden));
  final src = File('test/screenshot/$golden');
  final bytes = src.readAsBytesSync();
  for (final root in screenshotArtifactRoots) {
    Directory(root).createSync(recursive: true);
    File('$root/$name.png').writeAsBytesSync(bytes);
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
