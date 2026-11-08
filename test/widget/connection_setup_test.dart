import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:overdrive_companion/l10n/app_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive_companion/core/config/app_settings.dart';
import 'package:overdrive_companion/features/setup/connection_setup_screen.dart';
import 'package:overdrive_companion/data/models/vehicle_state.dart';
import 'package:overdrive_companion/data/repositories/vehicle_repository.dart';
import 'package:overdrive_companion/features/shell/app_root.dart';
import 'package:overdrive_companion/providers/app_providers.dart';
import 'package:overdrive_companion/providers/settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/fixture_api_client.dart';

Widget _testApp(Widget home) {
  return MaterialApp(
    locale: const Locale('he'),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: home,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('setup fields then successful ID reaches AppRoot', (tester) async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    final settingsRepo = await SettingsRepository.create();
    final client = await FixtureOverdriveApiClient.create();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(settingsRepo),
          overdriveApiClientProvider.overrideWithValue(client),
          vehicleRepositoryProvider.overrideWith(VehicleRepositoryNotifier.new),
          appSettingsProvider.overrideWith(AppSettingsNotifier.new),
          vehicleSnapshotProvider.overrideWith(() => _IdleSnapshot()),
        ],
        child: _testApp(const AppRoot()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('מזהה מכשיר (Device ID)'), findsOneWidget);
    expect(find.text('קוד גישה'), findsOneWidget);
    expect(find.text('אסימון מכשיר'), findsNothing);
    expect(find.text('התחבר ושמור'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'https://fixture.test');
    await tester.tap(find.byIcon(Icons.refresh));
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (find.text('mock-atto3-demo').evaluate().isNotEmpty) break;
    }
    expect(find.text('mock-atto3-demo'), findsOneWidget);

    await tester.enterText(find.byType(TextField).last, 'testcode99');
    await tester.tap(find.text('התחבר ושמור'));
    await tester.pump();
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (find.byType(NavigationBar).evaluate().isNotEmpty) break;
    }

    expect(find.text('התחבר ושמור'), findsNothing);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

}

class _IdleSnapshot extends VehicleSnapshotNotifier {
  @override
  Future<VehicleSnapshot?> build() async => null;
}
