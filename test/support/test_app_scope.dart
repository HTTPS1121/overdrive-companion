import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:overdrive_companion/data/secure_settings_store.dart';
import 'package:overdrive_companion/state/companion_app_controller.dart';

/// Empty secure store + providers for widget tests (no car, no network).
Future<List<Override>> emptyAppOverrides() async {
  FlutterSecureStorage.setMockInitialValues({});
  final store = await SecureSettingsStore.open();
  return [
    secureSettingsStoreProvider.overrideWithValue(store),
  ];
}
