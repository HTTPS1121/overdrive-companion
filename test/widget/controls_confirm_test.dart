import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive_companion/core/config/app_settings.dart';
import 'package:overdrive_companion/data/repositories/vehicle_repository.dart';
import 'package:overdrive_companion/features/controls/controls_commands_tab.dart';
import 'package:overdrive_companion/l10n/app_localizations.dart';
import 'package:overdrive_companion/providers/app_providers.dart';
import 'package:overdrive_companion/providers/settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/fixture_api_client.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late VehicleSnapshot fixtureSnap;
  late FixtureOverdriveApiClient client;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    client = await FixtureOverdriveApiClient.create();
    final repo = VehicleRepository(
      settings: const AppSettings(
        baseUrl: 'https://fixture.test',
        deviceToken: 'fixture-token',
      ),
      client: client,
    );
    fixtureSnap = await repo.fetchSnapshot();
  });

  Future<void> pumpCommands(WidgetTester tester) async {
    final settingsRepo = await SettingsRepository.create();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(settingsRepo),
          appSettingsProvider.overrideWith(() => _PinnedSettings()),
          overdriveApiClientProvider.overrideWithValue(client),
          vehicleRepositoryProvider.overrideWith(() => _RepoNotif(client)),
          vehicleSnapshotProvider.overrideWith(() => _FixedSnap(fixtureSnap)),
        ],
        child: const MaterialApp(
          locale: Locale('he'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: ControlsCommandsTab()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> expectConfirmDialog(
    WidgetTester tester, {
    required String tapLabel,
    required String dialogTitle,
  }) async {
    await tester.tap(find.text(tapLabel));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text(dialogTitle), findsOneWidget);
    await tester.tap(find.text('ביטול'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
  }

  testWidgets('lock shows confirmation before POST', (tester) async {
    await pumpCommands(tester);
    await expectConfirmDialog(tester, tapLabel: 'נעילה', dialogTitle: 'לאשר נעילה?');
  });

  testWidgets('unlock trunk and windows require confirmation', (tester) async {
    await pumpCommands(tester);
    await expectConfirmDialog(tester, tapLabel: 'פתיחה', dialogTitle: 'לאשר פתיחה?');
    await expectConfirmDialog(
      tester,
      tapLabel: 'פתיחת תא מטען',
      dialogTitle: 'לאשר פתיחת תא מטען?',
    );
    await expectConfirmDialog(
      tester,
      tapLabel: 'פתיחת חלונות',
      dialogTitle: 'לאשר פתיחת חלונות?',
    );
  });

  testWidgets('lock confirm sends POST when approved', (tester) async {
    await pumpCommands(tester);
    await tester.tap(find.text('נעילה'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('לאשר נעילה?'), findsOneWidget);
    await tester.tap(find.text('שליחה'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.textContaining('נעילה'), findsWidgets);
  });
}

class _PinnedSettings extends AppSettingsNotifier {
  @override
  AppSettings build() => const AppSettings(
        baseUrl: 'https://fixture.test',
        deviceToken: 'fixture-token',
      );

  @override
  Future<void> bootstrap() async {}
}

class _RepoNotif extends VehicleRepositoryNotifier {
  _RepoNotif(this.client);
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

class _FixedSnap extends VehicleSnapshotNotifier {
  _FixedSnap(this._snap);
  final VehicleSnapshot _snap;

  @override
  Future<VehicleSnapshot?> build() async => _snap;
}
