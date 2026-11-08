// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Overdrive Companion';

  @override
  String get navStatus => 'Status';

  @override
  String get navControls => 'Controls';

  @override
  String get navCameras => 'Cameras';

  @override
  String get navLocation => 'Location';

  @override
  String get navSettings => 'Settings';

  @override
  String get connectionTitle => 'Tunnel connection';

  @override
  String get connectionIntro =>
      'Same flow as the car login page: tunnel URL, Device ID from the server, then your access code.';

  @override
  String get connectionIntroLong =>
      'In the browser: open the tunnel URL → login.html shows Device ID → enter your access code.';

  @override
  String get connectionScreenTitle => 'Remote connection';

  @override
  String get tunnelUrlLabel => 'Tunnel URL (HTTPS)';

  @override
  String get tunnelUrlHint => 'https://your-tunnel.example.com';

  @override
  String get tunnelUrlHelper =>
      'Must reach the Overdrive server on the car — not LAN-only unless you know what you\'re doing.';

  @override
  String get deviceIdLabel => 'Device ID';

  @override
  String get deviceIdLabelLong => 'Device ID';

  @override
  String get deviceIdHint => 'Tap refresh after entering the tunnel URL';

  @override
  String get deviceIdHelper =>
      'Loaded from GET /auth/status (same as car login.html)';

  @override
  String get deviceIdPlaceholder => 'Refresh after entering the tunnel URL';

  @override
  String get accessCodeLabel => 'Access code';

  @override
  String get accessCodeHelper =>
      'Code only — server receives deviceId-accessCode';

  @override
  String get connectSave => 'Connect and save';

  @override
  String get refreshDeviceId => 'Load Device ID from tunnel';

  @override
  String get localHttpWarningTitle => 'Local HTTP only';

  @override
  String get localHttpWarningBody => 'Remote tunnels require HTTPS.';

  @override
  String get errorHtmlTunnel =>
      'Server returned HTML instead of JSON. Check the tunnel URL.';

  @override
  String get errorAuthRejected =>
      'Access code rejected. Refresh Device ID and try again.';

  @override
  String get errorSessionExpired => 'Session expired — sign in again.';

  @override
  String get errorDeviceIdMissing =>
      'Load Device ID from the tunnel before connecting.';

  @override
  String get errorAccessCodeShort =>
      'Access code must be at least 8 characters.';

  @override
  String get errorTunnelUrlRequired => 'Enter a tunnel URL.';

  @override
  String get errorUnexpectedAuth =>
      'Server did not respond as expected after sign-in.';

  @override
  String get cameraLiveTitle => 'Live stream';

  @override
  String get cameraLiveHelp =>
      'Annex-B H.264 on wss://host/ws?token=JWT — native MediaCodec on Android.';

  @override
  String get cameraEnableStream => 'Enable stream';

  @override
  String get cameraDisableStream => 'Disable stream';

  @override
  String get cameraSurveillanceTitle => 'Surveillance';

  @override
  String get cameraRecordingsTitle => 'Recordings';

  @override
  String get cameraViewMosaic => 'Mosaic (0)';

  @override
  String get cameraViewFront => 'Front (1)';

  @override
  String get cameraViewRight => 'Right (2)';

  @override
  String get cameraViewRear => 'Rear (3)';

  @override
  String get cameraViewLeft => 'Left (4)';

  @override
  String get cameraViewQualityMedium => 'Quality: MEDIUM';

  @override
  String streamConnectedLabel(String connected) {
    return 'Stream: $connected';
  }

  @override
  String streamViewModeLabel(int mode) {
    return 'View mode: $mode';
  }

  @override
  String get streamPhaseIdle => 'Idle';

  @override
  String get streamPhaseConnecting => 'Connecting…';

  @override
  String get streamPhaseConnected => 'Connected — waiting for frames';

  @override
  String get streamPhaseLive => 'Live';

  @override
  String streamPhaseReconnecting(int attempt) {
    return 'Reconnecting (attempt $attempt)…';
  }

  @override
  String get streamPhaseError => 'Stream error';

  @override
  String get streamPhaseDecoderError => 'Decoder unavailable';

  @override
  String get recordingDownload => 'Download';

  @override
  String recordingSavedTo(String path) {
    return 'Saved to $path';
  }

  @override
  String get recordingNone => 'No recordings';

  @override
  String get recordingLoadFailed => 'Could not load recordings';

  @override
  String get surveillanceEnabled => 'Surveillance enabled';

  @override
  String get surveillanceDisabled => 'Surveillance off';

  @override
  String get surveillanceLoadConfig => 'Load config';

  @override
  String get surveillanceSaveConfig => 'Save sensitivity';

  @override
  String surveillanceSnapshot(int q) {
    return 'Snapshot Q$q';
  }

  @override
  String get surveillanceEnable => 'Enable';

  @override
  String get surveillanceDisable => 'Disable';

  @override
  String get statusHeroTitle => 'Overdrive vehicle';

  @override
  String get statusLocked => 'Locked';

  @override
  String get statusUnlocked => 'Unlocked';

  @override
  String get statusConnectionTitle => 'Connection';

  @override
  String get statusConnectedToServer => 'Connected to server';

  @override
  String get statusDataStale => 'Data is stale — refresh before commands';

  @override
  String get statusRetry => 'Retry';

  @override
  String get statusNotConnected => 'Not connected';

  @override
  String get statusSetupInSettings => 'Set up connection in Settings';

  @override
  String get statusServerUnreachable => 'Cannot reach server';

  @override
  String get statusCheckTunnel => 'Check tunnel and network';

  @override
  String get statusErrorTitle => 'Error';
}
