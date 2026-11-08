import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

enum MicPermissionOutcome { granted, denied, permanentlyDenied, restricted, unknown }

class MicPermission {
  static Future<MicPermissionOutcome> status() async {
    if (kIsWeb) return MicPermissionOutcome.granted;
    final s = await Permission.microphone.status;
    return _map(s);
  }

  static Future<MicPermissionOutcome> request() async {
    if (kIsWeb) return MicPermissionOutcome.granted;
    final s = await Permission.microphone.request();
    return _map(s);
  }

  static Future<bool> openSettings() => openAppSettings();

  static MicPermissionOutcome _map(PermissionStatus s) => switch (s) {
        PermissionStatus.granted || PermissionStatus.limited => MicPermissionOutcome.granted,
        PermissionStatus.denied => MicPermissionOutcome.denied,
        PermissionStatus.permanentlyDenied => MicPermissionOutcome.permanentlyDenied,
        PermissionStatus.restricted => MicPermissionOutcome.restricted,
        _ => MicPermissionOutcome.unknown,
      };
}
