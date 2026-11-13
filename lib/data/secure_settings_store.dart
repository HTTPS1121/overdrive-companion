import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:overdrive_server/overdrive_server.dart';

/// Android Keystore-backed storage for server URL, credentials, and JWT.
class SecureSettingsStore {
  SecureSettingsStore(this._storage);

  final FlutterSecureStorage _storage;

  static const _kBaseUrl = 'od_base_url';
  static const _kConnectionMode = 'od_connection_mode';
  static const _kDeviceId = 'od_device_id';
  static const _kAccessCode = 'od_access_code';
  static const _kJwt = 'od_jwt';

  AppSettings settings = AppSettings.defaults();
  CompanionConnectionMode connectionMode = CompanionConnectionMode.tunnel;
  String? jwt;

  static Future<SecureSettingsStore> open() async {
    const storage = FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    );
    final store = SecureSettingsStore(storage);
    await store.hydrate();
    return store;
  }

  Future<void> hydrate() async {
    connectionMode = await loadConnectionMode();
    settings = await _loadSettings();
    jwt = await _loadJwt();
  }

  AppSettings get settingsSync => settings;

  Future<CompanionConnectionMode> loadConnectionMode() async {
    final raw = await _storage.read(key: _kConnectionMode);
    if (raw == 'local') return CompanionConnectionMode.local;
    return CompanionConnectionMode.tunnel;
  }

  Future<AppSettings> _loadSettings() async {
    final baseUrl = await _storage.read(key: _kBaseUrl) ?? '';
    final deviceId = await _storage.read(key: _kDeviceId) ?? '';
    final accessCode = await _storage.read(key: _kAccessCode) ?? '';
    return AppSettings(
      baseUrl: baseUrl,
      deviceId: deviceId,
      accessCode: accessCode,
    );
  }

  Future<String?> _loadJwt() async {
    final value = await _storage.read(key: _kJwt);
    if (value == null || value.isEmpty) return null;
    return value;
  }

  Future<void> saveConnectionDraft({
    required CompanionConnectionMode mode,
    required String baseUrl,
    required String deviceId,
    required String accessCode,
  }) async {
    await _storage.write(key: _kConnectionMode, value: mode.name);
    await _storage.write(key: _kBaseUrl, value: baseUrl);
    await _storage.write(key: _kDeviceId, value: deviceId);
    await _storage.write(key: _kAccessCode, value: accessCode);
    connectionMode = mode;
    settings = AppSettings(baseUrl: baseUrl, deviceId: deviceId, accessCode: accessCode);
  }

  Future<void> saveSession({
    required CompanionConnectionMode mode,
    required AppSettings sessionSettings,
    required String sessionJwt,
  }) async {
    await saveConnectionDraft(
      mode: mode,
      baseUrl: sessionSettings.baseUrl,
      deviceId: sessionSettings.deviceId,
      accessCode: sessionSettings.accessCode,
    );
    await _storage.write(key: _kJwt, value: sessionJwt);
    jwt = sessionJwt;
  }

  Future<void> clearSession() async {
    await _storage.delete(key: _kJwt);
    await _storage.delete(key: _kAccessCode);
    await _storage.delete(key: _kDeviceId);
    await _storage.delete(key: _kBaseUrl);
    await _storage.delete(key: _kConnectionMode);
    settings = AppSettings.defaults();
    connectionMode = CompanionConnectionMode.tunnel;
    jwt = null;
  }
}

enum CompanionConnectionMode {
  /// HTTPS tunnel (Cloudflare, Zrok, Tailscale public URL, …)
  tunnel,

  /// `http://` on LAN — typical `http://192.168.x.x:8080`.
  local,
}
