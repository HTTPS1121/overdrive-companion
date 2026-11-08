import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:overdrive_companion/core/config/app_settings.dart';
import 'package:overdrive_companion/l10n/app_localizations.dart';
import 'package:overdrive_companion/data/models/extended_services_models.dart';
import 'package:overdrive_companion/data/models/vehicle_state.dart';
import 'package:overdrive_companion/data/repositories/vehicle_repository.dart';
import 'package:overdrive_companion/features/controls/vehicle_hu_remote_screen.dart';
import 'package:overdrive_companion/features/integrations/diagnostics_screens.dart';
import 'package:overdrive_companion/features/integrations/family_screens.dart';
import 'package:overdrive_companion/features/integrations/integration_detail_screens.dart';
import 'package:overdrive_companion/providers/settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/fixture_api_client.dart';
import 'screenshot_harness.dart';

late SettingsRepository _settingsRepo;
late FixtureOverdriveApiClient _fixtureClient;
late VehicleSnapshot _fixtureSnap;

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

  final sampleAutomation = AutomationEntry(
    id: 'auto-1',
    name: 'Arrive home climate',
    mode: 'automatic',
    enabled: true,
  );
  final sampleTrip = TripEntry(
    id: 'trip-1',
    label: 'Commute',
    distanceKm: 24.5,
    startedAt: '2025-11-07T07:30:00Z',
  );

  final cases = [
    _PushCase('automation_settings', const AutomationSettingsScreen()),
    _PushCase('automation_edit', AutomationEditScreen(entry: sampleAutomation)),
    _PushCase('parking_signage', const ParkingSignageScreen(sessionId: 'park-1', placeLabel: 'Mall')),
    _PushCase('trip_detail', TripDetailScreen(entry: sampleTrip)),
    _PushCase('hu_remote', const VehicleHuRemoteScreen()),
    _PushCase('platform_telemetry', const PlatformConnectorsScreen(), scrollTelemetry: true),
    _PushCase('light_debug_write', const LightDebugScreen()),
    _PushCase('car_property_write', const CarPropertyDebugScreen()),
  ];

  const reps = [
    (CompanionThemeMode.light, const Locale('he')),
    (CompanionThemeMode.dark, const Locale('en')),
  ];

  for (final c in cases) {
    for (final (theme, locale) in reps) {
      final tag = 'push_${c.slug}_${theme.name}_${locale.languageCode}';
      testWidgets('v2.8.5 $tag', (tester) async {
        configurePhoneView(tester);
        final boundaryKey = GlobalKey();
        await pumpScreenshotApp(
          tester,
          child: c.widget,
          locale: locale,
          themeMode: theme,
          settingsRepo: _settingsRepo,
          fixtureClient: _fixtureClient,
          fixtureSnap: _fixtureSnap,
          boundaryKey: boundaryKey,
          pushFromParent: true,
        );
        if (c.scrollTelemetry) {
          final l10n = lookupAppLocalizations(locale);
          final body = find.byType(PlatformConnectorsScreen);
          for (var i = 0; i < 10; i++) {
            await tester.drag(body, const Offset(0, -140));
            await tester.pumpAndSettle();
            if (find.text(l10n.mqttTelemetryTitle).evaluate().isNotEmpty) break;
          }
          await tester.pumpAndSettle();
        }
        await writeScreenshotGolden(tester, tag, find.byKey(boundaryKey));
      });
    }
  }
}

class _PushCase {
  const _PushCase(this.slug, this.widget, {this.scrollTelemetry = false});
  final String slug;
  final Widget widget;
  final bool scrollTelemetry;
}
