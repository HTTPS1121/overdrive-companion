class CloudStatus {
  const CloudStatus({
    required this.success,
    required this.configured,
    required this.verified,
    required this.enabled,
    required this.localRemoteKey,
  });

  factory CloudStatus.fromJson(Map<String, dynamic> json) {
    return CloudStatus(
      success: json['success'] == true,
      configured: json['configured'] == true,
      verified: json['verified'] == true,
      enabled: json['enabled'] == true,
      localRemoteKey: json['localRemoteKey'] == true,
    );
  }

  final bool success;
  final bool configured;
  final bool verified;
  final bool enabled;
  final bool localRemoteKey;

  Map<String, dynamic> toJson() => {
        'success': success,
        'configured': configured,
        'verified': verified,
        'enabled': enabled,
        'localRemoteKey': localRemoteKey,
      };
}
