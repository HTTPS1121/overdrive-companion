enum ConnectionMode {
  live,
  embeddedMock,
  localMockServer,
}

class AppSettings {
  const AppSettings({
    required this.baseUrl,
    this.deviceToken = '',
    this.connectionMode = ConnectionMode.embeddedMock,
    this.mockRequireAuth = false,
    this.mockServerPort = 18080,
    this.pollIntervalSeconds = 5,
  });

  factory AppSettings.defaults() => const AppSettings(
        baseUrl: 'http://127.0.0.1:18080',
        connectionMode: ConnectionMode.embeddedMock,
      );

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      baseUrl: json['baseUrl'] as String? ?? '',
      deviceToken: json['deviceToken'] as String? ?? '',
      connectionMode: ConnectionMode.values.byName(
        json['connectionMode'] as String? ?? ConnectionMode.embeddedMock.name,
      ),
      mockRequireAuth: json['mockRequireAuth'] == true,
      mockServerPort: (json['mockServerPort'] as num?)?.toInt() ?? 18080,
      pollIntervalSeconds: (json['pollIntervalSeconds'] as num?)?.toInt() ?? 5,
    );
  }

  final String baseUrl;
  final String deviceToken;
  final ConnectionMode connectionMode;
  final bool mockRequireAuth;
  final int mockServerPort;
  final int pollIntervalSeconds;

  bool get isConfigured =>
      connectionMode == ConnectionMode.embeddedMock ||
      baseUrl.trim().isNotEmpty;

  AppSettings copyWith({
    String? baseUrl,
    String? deviceToken,
    ConnectionMode? connectionMode,
    bool? mockRequireAuth,
    int? mockServerPort,
    int? pollIntervalSeconds,
  }) {
    return AppSettings(
      baseUrl: baseUrl ?? this.baseUrl,
      deviceToken: deviceToken ?? this.deviceToken,
      connectionMode: connectionMode ?? this.connectionMode,
      mockRequireAuth: mockRequireAuth ?? this.mockRequireAuth,
      mockServerPort: mockServerPort ?? this.mockServerPort,
      pollIntervalSeconds: pollIntervalSeconds ?? this.pollIntervalSeconds,
    );
  }

  Map<String, dynamic> toJson() => {
        'baseUrl': baseUrl,
        'deviceToken': deviceToken,
        'connectionMode': connectionMode.name,
        'mockRequireAuth': mockRequireAuth,
        'mockServerPort': mockServerPort,
        'pollIntervalSeconds': pollIntervalSeconds,
      };
}
