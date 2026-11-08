import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/auth/tunnel_credentials.dart';
import '../core/config/app_settings.dart';

class SettingsRepository {
  SettingsRepository(this._prefs, this._secure);

  static const _prefsKey = 'overdrive_app_settings_v2';
  static const _jwtKey = 'overdrive_session_jwt';
  static const _tokenKey = 'overdrive_device_token';
  static const _accessCodeKey = 'overdrive_access_code';

  final SharedPreferences _prefs;
  final FlutterSecureStorage _secure;

  static Future<SettingsRepository> create() async {
    final prefs = await SharedPreferences.getInstance();
    const secure = FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    );
    return SettingsRepository(prefs, secure);
  }

  AppSettings load() {
    final raw = _prefs.getString(_prefsKey);
    if (raw == null || raw.isEmpty) {
      return AppSettings.defaults();
    }
    final json = jsonDecode(raw) as Map<String, dynamic>;
    // Token is stored securely; strip any legacy inline token from JSON.
    json.remove('deviceToken');
    return AppSettings.fromJson(json);
  }

  Future<void> save(AppSettings settings) async {
    final json = settings.toJson()..remove('deviceToken');
    await _prefs.setString(_prefsKey, jsonEncode(json));
  }

  Future<String> loadDeviceToken() async {
    return await _secure.read(key: _tokenKey) ?? '';
  }

  Future<String> loadAccessCode() async {
    return await _secure.read(key: _accessCodeKey) ?? '';
  }

  Future<void> saveAccessCode(String code) async {
    if (code.isEmpty) {
      await _secure.delete(key: _accessCodeKey);
      return;
    }
    await _secure.write(key: _accessCodeKey, value: code);
  }

  Future<void> saveDeviceToken(String token) async {
    if (token.isEmpty) {
      await _secure.delete(key: _tokenKey);
      return;
    }
    await _secure.write(key: _tokenKey, value: token);
  }

  Future<String?> loadJwt() => _secure.read(key: _jwtKey);

  Future<void> saveJwt(String? jwt) async {
    if (jwt == null || jwt.isEmpty) {
      await _secure.delete(key: _jwtKey);
      return;
    }
    await _secure.write(key: _jwtKey, value: jwt);
  }

  Future<AppSettings> loadFull() async {
    final base = load();
    var token = await loadDeviceToken();
    var accessCode = await loadAccessCode();
    var deviceId = base.deviceId;
    if (accessCode.isEmpty && token.contains('-')) {
      final parsed = parseDeviceToken(token);
      if (parsed != null) {
        accessCode = parsed.accessCode;
        if (deviceId.isEmpty) deviceId = parsed.deviceId;
      }
    }
    return base.copyWith(
      deviceToken: token,
      accessCode: accessCode,
      deviceId: deviceId,
    );
  }

  Future<void> saveFull(AppSettings settings, {String? jwt}) async {
    await save(settings);
    final resolved = settings.resolvedDeviceToken();
    await saveDeviceToken(resolved);
    await saveAccessCode(settings.accessCode);
    if (jwt != null) await saveJwt(jwt);
  }
}
