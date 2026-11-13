import '../auth/tunnel_credentials.dart';

enum CompanionThemeMode { system, light, dark }

class AppSettings {
  const AppSettings({
    this.baseUrl = '',
    this.deviceToken = '',
    this.deviceId = '',
    this.accessCode = '',
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
      deviceId: json['deviceId'] as String? ?? '',
      pollIntervalSeconds: (json['pollIntervalSeconds'] as num?)?.toInt() ?? 15,
      themeMode: CompanionThemeMode.values.byName(
        json['themeMode'] as String? ?? CompanionThemeMode.system.name,
      ),
      useDynamicColor: json['useDynamicColor'] != false,
    );
  }

  final String baseUrl;
  /// Full `{deviceId}-{accessCode}` sent to `POST /auth/token`.
  final String deviceToken;
  /// From public `GET /auth/status` (login.html "Device ID").
  final String deviceId;
  /// User-entered access code only (login.html token field).
  final String accessCode;
  final int pollIntervalSeconds;
  final CompanionThemeMode themeMode;
  final bool useDynamicColor;

  bool get isConfigured {
    if (baseUrl.trim().isEmpty) return false;
    if (resolvedDeviceToken().isNotEmpty) return true;
    return false;
  }

  String resolvedDeviceToken() {
    final direct = deviceToken.trim();
    if (direct.isNotEmpty) return direct;
    return composeDeviceToken(deviceId: deviceId, accessCode: accessCode);
  }

  AppSettings copyWith({
    String? baseUrl,
    String? deviceToken,
    String? deviceId,
    String? accessCode,
    int? pollIntervalSeconds,
    CompanionThemeMode? themeMode,
    bool? useDynamicColor,
  }) {
    return AppSettings(
      baseUrl: baseUrl ?? this.baseUrl,
      deviceToken: deviceToken ?? this.deviceToken,
      deviceId: deviceId ?? this.deviceId,
      accessCode: accessCode ?? this.accessCode,
      pollIntervalSeconds: pollIntervalSeconds ?? this.pollIntervalSeconds,
      themeMode: themeMode ?? this.themeMode,
      useDynamicColor: useDynamicColor ?? this.useDynamicColor,
    );
  }

  Map<String, dynamic> toJson() => {
        'baseUrl': baseUrl,
        'deviceId': deviceId,
        'pollIntervalSeconds': pollIntervalSeconds,
        'themeMode': themeMode.name,
        'useDynamicColor': useDynamicColor,
      };
}
