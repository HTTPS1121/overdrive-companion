import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config/app_settings.dart';
import '../data/api/overdrive_api_client.dart';
import '../data/repositories/extended_services_repository.dart';
import '../data/repositories/vehicle_repository.dart';
import 'settings_repository.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  throw UnimplementedError('override in main');
});

final appSettingsProvider =
    NotifierProvider<AppSettingsNotifier, AppSettings>(AppSettingsNotifier.new);

class AppSettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    final repo = ref.read(settingsRepositoryProvider);
    return repo.load();
  }

  void applyInitial(AppSettings settings) => state = settings;

  void patchDeviceId(String deviceId) => state = state.copyWith(deviceId: deviceId);

  Future<void> bootstrap() async {
    final repo = ref.read(settingsRepositoryProvider);
    final token = await repo.loadDeviceToken();
    if (token.isNotEmpty) {
      state = state.copyWith(deviceToken: token);
    }
    final jwt = await repo.loadJwt();
    if (jwt != null && jwt.isNotEmpty) {
      ref.read(vehicleRepositoryProvider).setJwt(jwt);
    }
  }

  Future<void> persist(AppSettings settings, {String? jwt, bool clearJwt = false}) async {
    state = settings;
    if (clearJwt) {
      await ref.read(settingsRepositoryProvider).saveJwt(null);
      ref.read(vehicleRepositoryProvider).setJwt(null);
      ref.read(extendedServicesRepositoryProvider).setJwt(null);
    }
    await ref.read(settingsRepositoryProvider).saveFull(
          settings.copyWith(deviceToken: settings.resolvedDeviceToken()),
          jwt: jwt,
        );
    ref.read(vehicleRepositoryProvider.notifier).rebind(state);
    ref.read(extendedServicesRepositoryProvider.notifier).rebind(state);
    if (jwt != null) {
      ref.read(vehicleRepositoryProvider).setJwt(jwt);
      ref.read(extendedServicesRepositoryProvider).setJwt(jwt);
    }
  }
}

final overdriveApiClientProvider = Provider<OverdriveApiClient>((ref) {
  final settings = ref.watch(appSettingsProvider);
  final base = settings.baseUrl.trim().isEmpty ? 'http://127.0.0.1' : settings.baseUrl;
  return OverdriveApiClient(baseUrl: base);
});

final vehicleRepositoryProvider =
    NotifierProvider<VehicleRepositoryNotifier, VehicleRepository>(
  VehicleRepositoryNotifier.new,
);

final extendedServicesRepositoryProvider =
    NotifierProvider<ExtendedServicesRepositoryNotifier, ExtendedServicesRepository>(
  ExtendedServicesRepositoryNotifier.new,
);

class ExtendedServicesRepositoryNotifier extends Notifier<ExtendedServicesRepository> {
  @override
  ExtendedServicesRepository build() {
    final settings = ref.watch(appSettingsProvider);
    final client = ref.watch(overdriveApiClientProvider);
    final repo = ExtendedServicesRepository(settings: settings, client: client);
    ref.read(settingsRepositoryProvider).loadJwt().then(repo.setJwt);
    return repo;
  }

  void rebind(AppSettings settings) {
    state.updateSettings(settings);
  }
}

class VehicleRepositoryNotifier extends Notifier<VehicleRepository> {
  @override
  VehicleRepository build() {
    final settings = ref.watch(appSettingsProvider);
    final client = ref.watch(overdriveApiClientProvider);
    final repo = VehicleRepository(settings: settings, client: client);
    ref.read(settingsRepositoryProvider).loadJwt().then(repo.setJwt);
    return repo;
  }

  void rebind(AppSettings settings) {
    state.updateSettings(settings);
  }

  Future<void> authenticateAndStoreJwt() async {
    await state.loginWithStoredCredentials();
    final token = state.sessionJwt;
    if (token != null && token.isNotEmpty) {
      await ref.read(settingsRepositoryProvider).saveJwt(token);
    }
  }
}

final vehicleSnapshotProvider =
    AsyncNotifierProvider<VehicleSnapshotNotifier, VehicleSnapshot?>(
  VehicleSnapshotNotifier.new,
);

class VehicleSnapshotNotifier extends AsyncNotifier<VehicleSnapshot?> {
  Timer? _timer;

  @override
  Future<VehicleSnapshot?> build() async {
    ref.onDispose(() => _timer?.cancel());
    final configured = ref.watch(appSettingsProvider.select((s) => s.isConfigured));
    if (!configured) {
      return null;
    }
    _schedulePoll();
    return _refresh();
  }

  void _schedulePoll() {
    _timer?.cancel();
    final seconds = ref.read(appSettingsProvider).pollIntervalSeconds;
    _timer = Timer.periodic(Duration(seconds: seconds), (_) => refresh());
  }

  Future<void> refresh() async {
    if (!ref.read(appSettingsProvider).isConfigured) {
      state = const AsyncData(null);
      return;
    }
    state = const AsyncLoading<VehicleSnapshot?>();
    state = AsyncData(await _refresh());
  }

  Future<VehicleSnapshot?> _refresh() async {
    final repo = ref.read(vehicleRepositoryProvider);
    return repo.fetchSnapshot();
  }
}

final commandInFlightProvider = StateProvider<bool>((ref) => false);
