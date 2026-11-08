import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:overdrive_companion/core/config/app_settings.dart';
import 'package:overdrive_companion/data/models/vehicle_state.dart';
import 'package:overdrive_companion/data/repositories/vehicle_repository.dart';
import 'package:overdrive_companion/features/integrations/diagnostics_screens.dart';
import 'package:overdrive_companion/features/integrations/family_screens.dart';
import 'package:overdrive_companion/features/integrations/integrations_hub_screen.dart';
import 'package:overdrive_companion/features/remote/remote_services_screen.dart';
import 'package:overdrive_companion/features/screenshot/screenshot_settings_stub.dart';
import 'package:overdrive_companion/l10n/app_localizations.dart';
import 'package:overdrive_companion/providers/settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/fixture_api_client.dart';
import 'screenshot_harness.dart';

late SettingsRepository _settingsRepo;
late VehicleSnapshot _fixtureSnap;
late FixtureOverdriveApiClient _fixtureClient;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
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

  setUp(() {
    _fixtureClient.configureRemoteServicesFixture(
      communicateVoice: true,
      communicateListener: true,
      genAiEnabled: true,
    );
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
          await _captureRoute(
            tester,
            'int_$tag',
            locale: locale,
            theme: mode,
            child: c.widget,
            pushFromParent: c.slug != 'integrations_hub',
          );
        });
      }
    }
  }

  for (final locale in const [Locale('he'), Locale('en')]) {
    for (final mode in [CompanionThemeMode.light, CompanionThemeMode.dark]) {
      testWidgets('v2.8.3 voice_remote_ready_${mode.name}_${locale.languageCode}', (tester) async {
        await _captureRemoteVoice(
          tester,
          'int_voice_ptt_ready_${mode.name}_${locale.languageCode}',
          locale: locale,
          theme: mode,
          genAiTab: false,
        );
      });
      testWidgets('v2.8.3 voice_remote_unsupported_${mode.name}_${locale.languageCode}', (tester) async {
        _fixtureClient.configureRemoteServicesFixture(communicateVoice: false, communicateListener: false);
        await _captureRemoteVoice(
          tester,
          'int_voice_ptt_unsupported_${mode.name}_${locale.languageCode}',
          locale: locale,
          theme: mode,
          genAiTab: false,
        );
      });
      testWidgets('v2.8.3 voice_genai_enabled_${mode.name}_${locale.languageCode}', (tester) async {
        await _captureRemoteVoice(
          tester,
          'int_voice_genai_enabled_${mode.name}_${locale.languageCode}',
          locale: locale,
          theme: mode,
          genAiTab: true,
        );
      });
      testWidgets('v2.8.3 voice_genai_disabled_${mode.name}_${locale.languageCode}', (tester) async {
        _fixtureClient.configureRemoteServicesFixture(genAiEnabled: false);
        await _captureRemoteVoice(
          tester,
          'int_voice_genai_disabled_${mode.name}_${locale.languageCode}',
          locale: locale,
          theme: mode,
          genAiTab: true,
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

Future<void> _captureRoute(
  WidgetTester tester,
  String name, {
  required Locale locale,
  required CompanionThemeMode theme,
  required Widget child,
  bool pushFromParent = true,
}) async {
  configurePhoneView(tester);
  final boundaryKey = GlobalKey();
  await pumpScreenshotApp(
    tester,
    child: child,
    locale: locale,
    themeMode: theme,
    settingsRepo: _settingsRepo,
    fixtureClient: _fixtureClient,
    fixtureSnap: _fixtureSnap,
    boundaryKey: boundaryKey,
    pushFromParent: pushFromParent,
  );
  await writeScreenshotGolden(tester, name, find.byKey(boundaryKey));
}

Future<void> _captureRemoteVoice(
  WidgetTester tester,
  String name, {
  required Locale locale,
  required CompanionThemeMode theme,
  required bool genAiTab,
}) async {
  configurePhoneView(tester);
  final boundaryKey = GlobalKey();
  await pumpScreenshotApp(
    tester,
    child: const RemoteServicesScreen(),
    locale: locale,
    themeMode: theme,
    settingsRepo: _settingsRepo,
    fixtureClient: _fixtureClient,
    fixtureSnap: _fixtureSnap,
    boundaryKey: boundaryKey,
    pushFromParent: true,
    parentForPush: const ScreenshotSettingsStub(),
  );
  final l10n = lookupAppLocalizations(locale);
  if (genAiTab) {
    await tester.tap(find.text(l10n.remoteGenAiTab));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.genAiLoadStatus));
  } else {
    await tester.tap(find.text(l10n.communicateLoadStatus));
  }
  await tester.pumpAndSettle(const Duration(milliseconds: 400));
  await writeScreenshotGolden(tester, name, find.byKey(boundaryKey));
}
