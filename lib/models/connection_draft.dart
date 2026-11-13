import '../data/secure_settings_store.dart';

class ConnectionDraft {
  const ConnectionDraft({
    this.mode = CompanionConnectionMode.tunnel,
    this.address = '',
    this.deviceId = '',
    this.accessCode = '',
  });

  final CompanionConnectionMode mode;
  final String address;
  final String deviceId;
  final String accessCode;

  ConnectionDraft copyWith({
    CompanionConnectionMode? mode,
    String? address,
    String? deviceId,
    String? accessCode,
  }) {
    return ConnectionDraft(
      mode: mode ?? this.mode,
      address: address ?? this.address,
      deviceId: deviceId ?? this.deviceId,
      accessCode: accessCode ?? this.accessCode,
    );
  }
}
