import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/io_client.dart';
import 'package:overdrive_companion/data/hebrew_errors.dart';
import 'package:overdrive_companion/data/real_vehicle_repository.dart';
import 'package:overdrive_companion/data/secure_settings_store.dart';
import 'package:overdrive_companion/models/connection_draft.dart';
import 'package:overdrive_companion/state/companion_app_controller.dart';
import 'package:overdrive_server/overdrive_server.dart';

import '../support/mock_overdrive_server.dart';

/// Uses real loopback HTTP against [MockOverdriveServer] (read-only + auth paths).
void main() {
  late IOClient ioClient;

  setUpAll(() {
    HttpOverrides.global = _LoopbackHttpOverrides();
    ioClient = IOClient(HttpClient());
  });

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    await MockOverdriveServer.start();
  });

  tearDown(() async {
    await MockOverdriveServer.stop();
    MockOverdriveServer.mode = 'ok';
  });

  test('testConnection succeeds against mock /auth/status', () async {
    final store = await SecureSettingsStore.open();
    final base = MockOverdriveServer.baseUri!.toString();
    final client = OverdriveApiClient(baseUrl: base, httpClient: ioClient);
    final repo = RealVehicleRepository(client);
    final ctrl = CompanionAppController(repo, store, client, skipBootstrap: true);
    final draft = ConnectionDraft(
      mode: CompanionConnectionMode.local,
      address: base,
      deviceId: 'atto3-il-demo-unit',
      accessCode: '12345678',
    );
    await ctrl.testConnection(draft);
    expect(ctrl.connectionTestOk, isTrue);
    expect(ctrl.connectionTestHebrew, contains('החיבור תקין'));
  });

  test('connect rejects bad token on mock', () async {
    MockOverdriveServer.mode = 'auth_fail';
    final store = await SecureSettingsStore.open();
    final base = MockOverdriveServer.baseUri!.toString();
    final client = OverdriveApiClient(baseUrl: base, httpClient: ioClient);
    final repo = RealVehicleRepository(client);
    final ctrl = CompanionAppController(repo, store, client, skipBootstrap: true);
    await ctrl.connect(
      ConnectionDraft(
        mode: CompanionConnectionMode.local,
        address: base,
        deviceId: 'atto3-il-demo-unit',
        accessCode: '12345678',
      ),
    );
    expect(ctrl.loginVisible, isTrue);
    expect(ctrl.loginErrorHebrew, hebrewAuthDenied());
  });
}

class _LoopbackHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context);
  }
}
