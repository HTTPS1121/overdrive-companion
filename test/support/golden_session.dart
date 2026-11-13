import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive_companion/data/real_vehicle_repository.dart';
import 'package:overdrive_companion/data/secure_settings_store.dart';
import 'package:overdrive_companion/models/companion_models.dart';
import 'package:overdrive_companion/state/companion_app_controller.dart';
import 'package:overdrive_server/overdrive_server.dart';

/// Golden / screenshot tests: signed-in UI with fixture vehicle state (no HTTP).
class GoldenSession {
  static Future<List<Override>> overrides() async {
    FlutterSecureStorage.setMockInitialValues({});
    final store = await SecureSettingsStore.open();
    final client = OverdriveApiClient(baseUrl: 'http://127.0.0.1:1', jwt: 'test');
    final repo = RealVehicleRepository(client);
    final stateJson = await File('fixtures/vehicle_state_sample.json').readAsString();
    applyFixtureJson(repo, stateJson);
    repo
      ..recordingsKnown = true
      ..recordingsState = DataLoadState.empty
      ..streamKnown = true
      ..streamState = DataLoadState.empty
      ..streamErrorHebrew = 'אין שידור חי מהמצלמות כרגע.';
    final controller = CompanionAppController(repo, store, client, skipBootstrap: true)
      ..debugEnterSignedIn();
    return [
      secureSettingsStoreProvider.overrideWithValue(store),
      vehicleRepoProvider.overrideWithValue(repo),
      apiClientProvider.overrideWithValue(client),
      companionAppControllerProvider.overrideWith((ref) => controller),
    ];
  }
}
