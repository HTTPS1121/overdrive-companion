import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/io_client.dart';
import 'package:overdrive_companion/data/real_vehicle_repository.dart';
import 'package:overdrive_companion/data/secure_settings_store.dart';
import 'package:overdrive_companion/state/companion_app_controller.dart';
import 'package:overdrive_server/overdrive_server.dart';

import '../support/mock_overdrive_server.dart';

void main() {
  late IOClient ioClient;

  setUpAll(() {
    HttpOverrides.global = _LoopbackHttpOverrides();
    ioClient = IOClient(HttpClient());
  });

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    MockOverdriveServer.mode = 'ok';
    await MockOverdriveServer.start();
  });

  tearDown(() async {
    await MockOverdriveServer.stop();
    MockOverdriveServer.mode = 'ok';
  });

  test('refreshAll survives server offline without throwing', () async {
    final store = await SecureSettingsStore.open();
    final base = MockOverdriveServer.baseUri!.toString();
    final client = OverdriveApiClient(baseUrl: base, httpClient: ioClient);
    final repo = RealVehicleRepository(client);
    final ctrl = CompanionAppController(repo, store, client, skipBootstrap: true);
    ctrl.debugEnterSignedIn();

    await repo.refreshVehicleState();
    expect(repo.rangeKm, greaterThan(0));
    expect(ctrl.vehicleStateStale, isFalse);

    await MockOverdriveServer.stop();
    MockOverdriveServer.mode = 'offline';

    await ctrl.refreshAll();
    expect(ctrl.vehicleStateStale, isTrue);
    expect(ctrl.vehicleOfflineHebrew, isNotNull);
    expect(ctrl.rangeKm, greaterThan(0));
    expect(ctrl.sheetOpen, isFalse);
    expect(ctrl.recPlayId, isNull);
  });
}

class _LoopbackHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context);
  }
}
