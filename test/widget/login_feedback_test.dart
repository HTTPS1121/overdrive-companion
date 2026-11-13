import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive_companion/data/hebrew_errors.dart';
import 'package:overdrive_companion/data/real_vehicle_repository.dart';
import 'package:overdrive_companion/data/secure_settings_store.dart';
import 'package:overdrive_companion/models/connection_draft.dart';
import 'package:overdrive_companion/state/companion_app_controller.dart';
import 'package:overdrive_companion/ui/screens/login_screen.dart';
import 'package:overdrive_server/overdrive_server.dart';

import '../support/test_app_scope.dart';

void main() {
  test('connect clears prior test-connection message immediately', () async {
    FlutterSecureStorage.setMockInitialValues({});
    final store = await SecureSettingsStore.open();
    final client = OverdriveApiClient(baseUrl: 'http://127.0.0.1:9');
    final repo = RealVehicleRepository(client);
    final ctrl = CompanionAppController(repo, store, client, skipBootstrap: true);
    ctrl.connectionTestHebrew = hebrewForOffline();

    final draft = ConnectionDraft(
      mode: CompanionConnectionMode.local,
      address: 'http://127.0.0.1:9',
      deviceId: 'unit',
      accessCode: '12345678',
    );

    await ctrl.connect(draft).catchError((_) {});
    expect(ctrl.connectionTestHebrew, isNull);
  });

  testWidgets('login UI shows only the latest feedback line', (tester) async {
    final overrides = await emptyAppOverrides();
    final store = await SecureSettingsStore.open();
    final client = OverdriveApiClient(baseUrl: 'http://127.0.0.1:9');
    final repo = RealVehicleRepository(client);
    final ctrl = CompanionAppController(repo, store, client, skipBootstrap: true);
    ctrl.connectionTestHebrew = hebrewForOffline();
    ctrl.loginErrorHebrew = null;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...overrides,
          companionAppControllerProvider.overrideWith((ref) => ctrl),
        ],
        child: const MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(body: LoginScreen()),
          ),
        ),
      ),
    );

    expect(find.text(hebrewForOffline()), findsOneWidget);

    ctrl.clearLoginFeedback();
    ctrl.loginErrorHebrew = hebrewAuthDenied();
    await tester.pump();

    expect(find.text(hebrewForOffline()), findsNothing);
    expect(find.text(hebrewAuthDenied()), findsOneWidget);
  });

  testWidgets('editing a login field clears feedback via onChanged', (tester) async {
    final overrides = await emptyAppOverrides();
    final store = await SecureSettingsStore.open();
    final client = OverdriveApiClient(baseUrl: 'http://127.0.0.1:9');
    final repo = RealVehicleRepository(client);
    final ctrl = CompanionAppController(repo, store, client, skipBootstrap: true);
    ctrl.connectionTestHebrew = hebrewForOffline();
    ctrl.loginErrorHebrew = hebrewAuthDenied();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...overrides,
          companionAppControllerProvider.overrideWith((ref) => ctrl),
        ],
        child: const MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(body: LoginScreen()),
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField).at(0), 'http://10.0.0.2:8080');
    await tester.pump();

    expect(find.text(hebrewForOffline()), findsNothing);
    expect(find.text(hebrewAuthDenied()), findsNothing);
  });
}
