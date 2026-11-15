import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../core/config/app_settings.dart';

class SettingsRepository {
  SettingsRepository(this._prefs);

  static const _key = 'overdrive_app_settings_v1';

  final SharedPreferences _prefs;

  static Future<SettingsRepository> create() async {
    final prefs = await SharedPreferences.getInstance();
    return SettingsRepository(prefs);
  }

  AppSettings load() {
    final raw = _prefs.getString(_key);
    if (raw == null || raw.isEmpty) {
      return AppSettings.defaults();
    }
    return AppSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> save(AppSettings settings) async {
    await _prefs.setString(_key, jsonEncode(settings.toJson()));
  }
}
