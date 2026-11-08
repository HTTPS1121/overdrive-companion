import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive_companion/core/config/app_settings.dart';
import 'package:overdrive_companion/data/repositories/vehicle_repository.dart';
import 'package:overdrive_companion/features/shell/app_shell.dart';
import 'package:overdrive_companion/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:overdrive_companion/providers/app_providers.dart';
import 'package:overdrive_companion/providers/settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/fixture_api_client.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FixtureOverdriveApiClient client;
  late VehicleSnapshot snap;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    client = await FixtureOverdriveApiClient.create();
    snap = await VehicleRepository(
      settings: const AppSettings(
        baseUrl: 'https://fixture.test',
        deviceToken: 'fixture-token',
      ),
      client: client,
    ).fetchSnapshot();
  });

  testWidgets('each bottom nav index updates selectedIndex in RTL app', (tester) async {
    final settingsRepo = await SettingsRepository.create();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(settingsRepo),
          appSettingsProvider.overrideWith(() => _Pinned()),
          overdriveApiClientProvider.overrideWithValue(client),
          vehicleRepositoryProvider.overrideWith(() => _Repo(client)),
          vehicleSnapshotProvider.overrideWith(() => _Snap(snap)),
        ],
        child: MaterialApp(
          locale: const Locale('he'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Directionality(
            textDirection: TextDirection.rtl,
            child: AppShell(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    const labels = ['מצב', 'שליטה', 'מצלמות', 'מיקום', 'הגדרות'];
    for (var i = 0; i < labels.length; i++) {
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text(labels[i]),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex, i);
    }
  });
}

class _Pinned extends AppSettingsNotifier {
  @override
  AppSettings build() => const AppSettings(
        baseUrl: 'https://fixture.test',
        deviceToken: 'fixture-token',
      );

  @override
  Future<void> bootstrap() async {}
}

class _Repo extends VehicleRepositoryNotifier {
  _Repo(this.client);
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

class _Snap extends VehicleSnapshotNotifier {
  _Snap(this.s);
  final VehicleSnapshot s;

  @override
  Future<VehicleSnapshot?> build() async => s;
}
