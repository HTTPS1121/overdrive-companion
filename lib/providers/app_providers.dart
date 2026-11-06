import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config/app_settings.dart';
import '../data/mock/mock_overdrive_backend.dart';
import '../data/repositories/vehicle_repository.dart';
import 'settings_repository.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  throw UnimplementedError('override in main');
});

final appSettingsProvider =
    NotifierProvider<AppSettingsNotifier, AppSettings>(AppSettingsNotifier.new);

class AppSettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() => ref.read(settingsRepositoryProvider).load();

  Future<void> persist(AppSettings settings) async {
    state = settings;
    await ref.read(settingsRepositoryProvider).save(settings);
    ref.read(vehicleRepositoryProvider.notifier).rebind(settings);
  }
}

final mockBackendProvider = Provider<MockOverdriveBackend>((ref) {
  return MockOverdriveBackend();
});

final vehicleRepositoryProvider =
    NotifierProvider<VehicleRepositoryNotifier, VehicleRepository>(
  VehicleRepositoryNotifier.new,
);

class VehicleRepositoryNotifier extends Notifier<VehicleRepository> {
  @override
  VehicleRepository build() {
    final settings = ref.watch(appSettingsProvider);
    final mock = ref.watch(mockBackendProvider);
    return VehicleRepository(settings: settings, mockBackend: mock);
  }

  void rebind(AppSettings settings) {
    state.updateSettings(settings);
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
    _schedulePoll();
    return _refresh();
  }

  void _schedulePoll() {
    _timer?.cancel();
    final seconds = ref.read(appSettingsProvider).pollIntervalSeconds;
    _timer = Timer.periodic(Duration(seconds: seconds), (_) => refresh());
  }

  Future<void> refresh() async {
    state = const AsyncLoading<VehicleSnapshot?>();
    state = AsyncData(await _refresh());
  }

  Future<VehicleSnapshot?> _refresh() async {
    final repo = ref.read(vehicleRepositoryProvider);
    return repo.fetchSnapshot();
  }
}

final commandInFlightProvider = StateProvider<bool>((ref) => false);
