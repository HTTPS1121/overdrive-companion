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
      'Enter your tunnel address, load the Device ID from the car server, then enter the access code shown in the car browser login.';

  @override
  String get connectionIntroLong =>
      'Open the tunnel URL in a browser on the car side to see the Device ID, then use that code here.';

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
      'Tap refresh after the tunnel URL is correct — loads the ID from your car server';

  @override
  String get errorTunnelFirst =>
      'Enter the tunnel URL before loading Device ID.';

  @override
  String get errorTunnelUnreachable =>
      'Cannot reach the tunnel. Check HTTPS, network, and that the car server is online.';

  @override
  String get errorDeviceIdFromServer =>
      'No Device ID from the server. Check the tunnel and car connection.';

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
      'Live view from your dash cameras when the stream is enabled.';

  @override
  String get streamBadgeLive => 'Live';

  @override
  String get streamBadgeOffline => 'Offline';

  @override
  String get streamBadgeEnabled => 'Stream on';

  @override
  String get streamBadgeDisabled => 'Stream off';

  @override
  String streamQualityCurrent(String level) {
    return 'Quality · $level';
  }

  @override
  String get cameraViewPickerTitle => 'Camera view';

  @override
  String get cameraQualityTitle => 'Video quality';

  @override
  String get cameraQualityLow => 'Low';

  @override
  String get cameraQualityMedium => 'Medium';

  @override
  String get cameraQualityHigh => 'High';

  @override
  String get cameraEnableStream => 'Enable stream';

  @override
  String get cameraDisableStream => 'Disable stream';

  @override
  String get cameraSurveillanceTitle => 'Surveillance';

  @override
  String get cameraRecordingsTitle => 'Recordings';

  @override
  String get cameraViewMosaic => 'All cameras';

  @override
  String get cameraViewFront => 'Front';

  @override
  String get cameraViewRight => 'Right';

  @override
  String get cameraViewRear => 'Rear';

  @override
  String get cameraViewLeft => 'Left';

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
    return 'Corner $q';
  }

  @override
  String get surveillanceCornerFrontLeft => 'Front left';

  @override
  String get surveillanceCornerFrontRight => 'Front right';

  @override
  String get surveillanceCornerRearLeft => 'Rear left';

  @override
  String get surveillanceCornerRearRight => 'Rear right';

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

  @override
  String get statusDriving => 'Driving';

  @override
  String get statusParked => 'Parked';

  @override
  String get statusRangeUnit => 'km';

  @override
  String get sectionClimate => 'Climate';

  @override
  String get sectionWindows => 'Windows';

  @override
  String get sectionTyres => 'Tires';

  @override
  String get sectionCloud => 'BYD cloud';

  @override
  String get stateOn => 'On';

  @override
  String get stateOff => 'Off';

  @override
  String get cloudActive => 'Linked and verified';

  @override
  String get cloudPartial => 'Incomplete';

  @override
  String get freshnessNotYet => 'Not updated yet';

  @override
  String freshnessUpdated(String ago) {
    return 'Updated $ago';
  }

  @override
  String get freshnessNow => 'just now';

  @override
  String freshnessSecondsAgo(int n) {
    return '$n sec ago';
  }

  @override
  String freshnessMinutesAgo(int n) {
    return '$n min ago';
  }

  @override
  String freshnessHoursAgo(int n) {
    return '$n h ago';
  }

  @override
  String freshnessDaysAgo(int n) {
    return '$n d ago';
  }

  @override
  String get controlSectionAccess => 'Vehicle access';

  @override
  String get controlSectionWindows => 'Windows';

  @override
  String get controlSectionClimate => 'Climate';

  @override
  String get controlStaleTitle => 'Stale data';

  @override
  String controlStaleBody(String ago) {
    return 'Refresh status before sending commands ($ago)';
  }

  @override
  String controlConfirmTitle(String action) {
    return 'Confirm $action?';
  }

  @override
  String get controlConfirmBody =>
      'This command is sent to the car over the tunnel. Make sure the vehicle is in a safe place.';

  @override
  String get controlSend => 'Send';

  @override
  String get controlClimateOffAction => 'Turn climate off';

  @override
  String get controlClimateOnAction => 'Turn climate on';

  @override
  String get controlSteeringHeatOff => 'Steering heat off';

  @override
  String get controlSteeringHeatOn => 'Steering heat on';

  @override
  String get controlTempDownShort => 'Cooler';

  @override
  String get controlTempUpShort => 'Warmer';

  @override
  String get controlLock => 'Lock';

  @override
  String get controlUnlock => 'Unlock';

  @override
  String get controlTrunkOpen => 'Open trunk';

  @override
  String get controlTrunkClose => 'Close trunk';

  @override
  String get controlWindowsOpen => 'Open windows';

  @override
  String get controlWindowsClose => 'Close windows';

  @override
  String get controlWindowsVent => 'Ventilate';

  @override
  String get controlFlash => 'Flash lights';

  @override
  String get controlFindCar => 'Find car';

  @override
  String get controlClimateOn => 'Climate on';

  @override
  String get controlClimateOff => 'Climate off';

  @override
  String get controlTempUp => 'Warmer';

  @override
  String get controlTempDown => 'Cooler';

  @override
  String get controlFanUp => 'Fan up';

  @override
  String get controlFanDown => 'Fan down';

  @override
  String get controlReadingLight => 'Reading light';

  @override
  String get controlSteeringHeat => 'Steering heat';

  @override
  String get controlsErrorTitle => 'Error';

  @override
  String get controlsNoConnection =>
      'No server connection — controls unavailable';
}
