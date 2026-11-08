import 'package:flutter/material.dart';

enum CompanionThemeMode { system, light, dark }

class AppSettings {
  const AppSettings({
    this.baseUrl = '',
    this.deviceToken = '',
    this.pollIntervalSeconds = 15,
    this.themeMode = CompanionThemeMode.system,
    this.useDynamicColor = true,
  });

  factory AppSettings.defaults() => const AppSettings();

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    var baseUrl = (json['baseUrl'] as String? ?? '').trim();
    if (baseUrl.startsWith('mock://')) {
      baseUrl = '';
    }
    final legacyMode = json['connectionMode'] as String?;
    if (legacyMode == 'embeddedMock' && baseUrl.isEmpty) {
      baseUrl = '';
    }
    return AppSettings(
      baseUrl: baseUrl,
      deviceToken: json['deviceToken'] as String? ?? '',
      pollIntervalSeconds: (json['pollIntervalSeconds'] as num?)?.toInt() ?? 15,
      themeMode: CompanionThemeMode.values.byName(
        json['themeMode'] as String? ?? CompanionThemeMode.system.name,
      ),
      useDynamicColor: json['useDynamicColor'] != false,
    );
  }

  final String baseUrl;
  final String deviceToken;
  final int pollIntervalSeconds;
  final CompanionThemeMode themeMode;
  final bool useDynamicColor;

  bool get isConfigured =>
      baseUrl.trim().isNotEmpty && deviceToken.trim().isNotEmpty;

  ThemeMode get materialThemeMode => switch (themeMode) {
        CompanionThemeMode.light => ThemeMode.light,
        CompanionThemeMode.dark => ThemeMode.dark,
        CompanionThemeMode.system => ThemeMode.system,
      };

  AppSettings copyWith({
    String? baseUrl,
    String? deviceToken,
    int? pollIntervalSeconds,
    CompanionThemeMode? themeMode,
    bool? useDynamicColor,
  }) {
    return AppSettings(
      baseUrl: baseUrl ?? this.baseUrl,
      deviceToken: deviceToken ?? this.deviceToken,
      pollIntervalSeconds: pollIntervalSeconds ?? this.pollIntervalSeconds,
      themeMode: themeMode ?? this.themeMode,
      useDynamicColor: useDynamicColor ?? this.useDynamicColor,
    );
  }

  Map<String, dynamic> toJson() => {
        'baseUrl': baseUrl,
        'pollIntervalSeconds': pollIntervalSeconds,
        'themeMode': themeMode.name,
        'useDynamicColor': useDynamicColor,
      };
}
