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
      'Enter the same access code shown on the car login page after the Device ID';

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
  String get tyreFrontLeft => 'Front left';

  @override
  String get tyreFrontRight => 'Front right';

  @override
  String get tyreRearLeft => 'Rear left';

  @override
  String get tyreRearRight => 'Rear right';

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

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionScheduleClimate => 'Climate schedule';

  @override
  String get actionScheduleCharging => 'Charging schedule';

  @override
  String get actionStartCharging => 'Start charging';

  @override
  String get actionSeat => 'Seat';

  @override
  String get actionMedia => 'Media';

  @override
  String get actionAdas => 'ADAS';

  @override
  String get actionCpd => 'CPD';

  @override
  String get actionBatteryHeat => 'Battery heat';

  @override
  String get actionChargeCap => 'Charge cap';

  @override
  String get settingsSectionConnection => 'Connection';

  @override
  String get settingsSectionAppearance => 'Appearance';

  @override
  String get settingsSectionRemote => 'Remote services';

  @override
  String get settingsAppearanceHint =>
      'Light, dark, or follow system. Dynamic color requires Android 12+.';

  @override
  String get settingsDynamicColorTitle => 'Dynamic colors (Material You)';

  @override
  String get settingsDynamicColorSubtitle =>
      'From your device wallpaper palette';

  @override
  String get settingsSaveConnect => 'Save and connect';

  @override
  String get settingsSaved => 'Settings saved';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsOpenRemoteServices => 'Cabin audio, GenAI, WireGuard';

  @override
  String get settingsOpenCapabilityInventory =>
      'API coverage vs Overdrive server';

  @override
  String get controlsTabCommands => 'Commands';

  @override
  String get controlsTabSchedules => 'Schedules';

  @override
  String get controlsTabComfort => 'Comfort';

  @override
  String get controlsTabCharging => 'Charging';

  @override
  String get scheduleTabClimate => 'Pre-climate';

  @override
  String get scheduleTabCharging => 'Smart charge';

  @override
  String get gpsNoLocationServer =>
      'No location — active server connection required';

  @override
  String get gpsServerNoGps => 'Server returned no GPS data';

  @override
  String get gpsNoCoordinates => 'No coordinates in server response';

  @override
  String get gpsMapNeedsNetwork =>
      'Map preview needs network on this device.\nCoordinates and navigation below are still from the server.';

  @override
  String get gpsMapLoadFailed => 'Could not load map — coordinates are shown';

  @override
  String get gpsCoordinates => 'Coordinates';

  @override
  String get gpsSpeed => 'Speed';

  @override
  String get gpsHeading => 'Heading';

  @override
  String get gpsOpenNavigation => 'Open in maps';

  @override
  String get gpsNavigationUnavailable => 'Could not open a maps app';

  @override
  String get chargeCapTitle => 'Charge limit';

  @override
  String get chargeCapLoadFailed => 'Could not load charge limit from server';

  @override
  String get chargeCapUnsupported =>
      'Server reports charge limit not supported on this vehicle';

  @override
  String get chargeCapDescription =>
      'Cap the maximum state of charge while charging.';

  @override
  String get chargeCapTarget => 'Charge target';

  @override
  String get chargeCapEnableTitle => 'Enable limit';

  @override
  String get chargeCapEnableSubtitle =>
      'When on, charging stops at the selected target';

  @override
  String get chargeCapSave => 'Save to server';

  @override
  String get acChargeTitle => 'AC charge current';

  @override
  String get acChargeLoadFailed =>
      'Could not read AC charge current from server';

  @override
  String get acChargeTrimUnsupported =>
      'This trim does not support AC current limiting.';

  @override
  String get acChargeUnavailable =>
      'AC current data unavailable from vehicle right now.';

  @override
  String get acChargeLevelsHint =>
      'Five levels set on the vehicle; saving updates the server limit.';

  @override
  String acChargeLevelAmps(int amps) {
    return '$amps A';
  }

  @override
  String acChargeCurrentLabel(String label) {
    return 'Current level: $label';
  }

  @override
  String get extendedPowerSection => 'Power';

  @override
  String get extendedPowerDrivingBlocked =>
      'Vehicle reports driving — power on/off blocked until stopped (server guard).';

  @override
  String get extendedPowerOn => 'Power on';

  @override
  String get extendedPowerOff => 'Power off';

  @override
  String get extendedBatteryHeatSection => 'Battery heat';

  @override
  String get extendedBatteryHeatUnknown =>
      'Server did not report battery heat — toggle unavailable.';

  @override
  String get extendedBatteryPreheat => 'Battery preconditioning';

  @override
  String get extendedBatteryHeatOn => 'Active per server';

  @override
  String get extendedBatteryHeatOff => 'Off per server';

  @override
  String get extendedScreenshotsSection => 'In-vehicle displays';

  @override
  String get extendedScreenshotsHint =>
      'PNG capture is stored on the vehicle (HU or cluster). Not auto-downloaded to phone.';

  @override
  String get extendedScreenshotHu => 'Multimedia screenshot';

  @override
  String get extendedScreenshotCluster => 'Cluster screenshot';

  @override
  String get extendedConfirmPowerOnTitle => 'Power on vehicle?';

  @override
  String get extendedConfirmPowerOffTitle => 'Power off vehicle?';

  @override
  String get extendedConfirmPowerOnBody =>
      'Sent only when parked with no motion (server SDK guard).';

  @override
  String get extendedConfirmPowerOffBody =>
      'Vehicle will shut down — ensure occupants are clear.';

  @override
  String extendedConfirmScreenshotTitle(String label) {
    return 'Confirm $label?';
  }

  @override
  String get extendedConfirmScreenshotBody =>
      'Server captures on the vehicle and saves a PNG file.';

  @override
  String get extendedConfirmCapture => 'Capture';

  @override
  String get scheduleClimateTitle => 'Climate schedules from server';

  @override
  String get scheduleClimateEmpty => 'No active schedules — create one below.';

  @override
  String scheduleClimateUnsupported(String reason) {
    return 'Not supported: $reason';
  }

  @override
  String scheduleClimateListUnavailable(String reason) {
    return 'Schedule list unavailable ($reason).\nAn empty list is not shown as proof of no schedules.';
  }

  @override
  String get scheduleInvalidResponse => 'Invalid server response';

  @override
  String get scheduleDurationMinutes => 'Duration (minutes)';

  @override
  String get scheduleCreate => 'Create';

  @override
  String get scheduleUpdate => 'Update';

  @override
  String get scheduleCancelEdit => 'Cancel edit';

  @override
  String get scheduleDeleteTooltip => 'Delete';

  @override
  String scheduleChargingUnsupported(Object reason) {
    return 'Not supported: $reason';
  }

  @override
  String get scheduleChargingStatus => 'Status';

  @override
  String get scheduleChargingEnabled => 'Scheduled charging on';

  @override
  String get scheduleChargingStart => 'Start (HH:mm)';

  @override
  String get scheduleChargingEnd => 'End (HH:mm or full)';

  @override
  String get scheduleChargingRepeat => 'Repeat';

  @override
  String get scheduleRepeatDaily => 'Every day';

  @override
  String get scheduleRepeatOnce => 'One time';

  @override
  String get scheduleChargingSaveWindow => 'Save window';

  @override
  String get scheduleChargingStartNow => 'Start charging now';

  @override
  String get stateActive => 'Active';

  @override
  String get stateInactive => 'Off';

  @override
  String get comfortTabSeats => 'Seats';

  @override
  String get comfortTabMediaSafety => 'Media & safety';

  @override
  String get comfortMediaTitle => 'Media volume & screen brightness';

  @override
  String get comfortSafetyTitle => 'Safety';

  @override
  String get comfortEsp => 'Stability (ESP)';

  @override
  String get comfortItac => 'Traction (ITAC)';

  @override
  String get comfortUnavailable => 'Unavailable';

  @override
  String get comfortSlw => 'Speed limit warning (SLW)';

  @override
  String get comfortCpd => 'Child presence (CPD)';

  @override
  String get seatHint => 'Heat and vent levels as reported by the vehicle';

  @override
  String get seatDriver => 'Driver seat';

  @override
  String get seatPassenger => 'Passenger seat';

  @override
  String get seatHeat => 'Heat';

  @override
  String get seatVent => 'Vent';

  @override
  String get seatVentUnsupported => 'Vent not supported on this vehicle';

  @override
  String get seatRecallMemory => 'Recall memory';

  @override
  String get seatSaveMemory => 'Save seat';

  @override
  String commandFailed(String action) {
    return '$action failed';
  }

  @override
  String commandSentUnconfirmed(String action) {
    return '$action sent but not confirmed on vehicle';
  }

  @override
  String commandSuccess(String action) {
    return '$action completed';
  }

  @override
  String get commandLockConfirmed => 'Vehicle locked';

  @override
  String get commandUnlockConfirmed => 'Vehicle unlocked';

  @override
  String get surveillanceHeatmapTitle => 'Parking heatmap';

  @override
  String get surveillanceHeatmapLoad => 'Load heatmap';

  @override
  String get surveillanceFilterLogTitle => 'Filter log';

  @override
  String get surveillanceFilterLogLoad => 'Load log';

  @override
  String get surveillanceScreenDeterrentTitle => 'Screen deterrent';

  @override
  String get surveillanceScreenDeterrentTest => 'Test on vehicle';

  @override
  String get surveillanceScreenDeterrentFetch => 'Preview image';

  @override
  String get remoteCommunicateTitle => 'Cabin communication';

  @override
  String get remoteGenAiTitle => 'GenAI assistant';

  @override
  String get remoteWireGuardTitle => 'WireGuard tunnel';

  @override
  String get communicateAudioReady => 'Voice ready';

  @override
  String get communicateMessagesReady => 'Messages ready';

  @override
  String get communicateListenerReady => 'Listener ready';

  @override
  String get communicateSendMessage => 'Send message';

  @override
  String get communicateMessageHint => 'Text shown on vehicle';

  @override
  String get communicateTestSpeaker => 'Test speaker';

  @override
  String get communicateEmergencyStop => 'Emergency stop';

  @override
  String get communicateLoadStatus => 'Refresh status';

  @override
  String get genAiLoadStatus => 'Refresh status';

  @override
  String get genAiSendChat => 'Send';

  @override
  String get genAiChatHint => 'Ask the vehicle assistant';

  @override
  String get genAiInsightsOpen => 'Insights dashboard';

  @override
  String get wireGuardLoadStatus => 'Refresh status';

  @override
  String get wireGuardExposeOn => 'Expose dashboard';

  @override
  String get wireGuardExposeOff => 'Hide dashboard';

  @override
  String get inventoryTitle => 'Server capability map';

  @override
  String get inventoryImplemented => 'In app';

  @override
  String get inventoryPartial => 'Partial';

  @override
  String get inventoryNotInApp => 'HTTP only / not in UI';

  @override
  String get errorFreshnessUnknown => 'Unknown time source';

  @override
  String get errorFreshnessClockSkew => 'Vehicle clock ahead of device';

  @override
  String get errorConnectionNotConfigured => 'Server connection not configured';

  @override
  String get errorDeviceIdBeforeLogin =>
      'Load Device ID from tunnel before sign-in';

  @override
  String get errorConfigureTunnel => 'Set tunnel URL and device token';

  @override
  String get remoteServicesTitle => 'Remote services';

  @override
  String get drivingInMotion => 'Driving';

  @override
  String get drivingParked => 'Parked';

  @override
  String heatmapQuadrantSummary(String name, String active) {
    return '$name: $active active blocks';
  }

  @override
  String get filterLogEmpty => 'No filter log entries';

  @override
  String get genAiReplyTitle => 'Reply';

  @override
  String get wireGuardConfigured => 'Configured';

  @override
  String get wireGuardRunning => 'Running';

  @override
  String get wireGuardNotConfigured => 'Not configured';

  @override
  String get communicateCarState => 'Vehicle state';

  @override
  String get seatLevelOff => 'Off';

  @override
  String get seatLevelLow => 'Low';

  @override
  String get seatLevelHigh => 'High';

  @override
  String celsiusDegrees(String temp) {
    return '$temp °C';
  }

  @override
  String get scheduleUnknownTime => 'Unknown time';

  @override
  String get scheduleNewTitle => 'New schedule';

  @override
  String get scheduleEditTitle => 'Edit schedule';

  @override
  String scheduleMinutesShort(String minutes) {
    return '$minutes min';
  }

  @override
  String get rateLimitError =>
      'Too many login attempts. Wait a minute and try again.';

  @override
  String get authHtmlRejected =>
      'Server returned HTML instead of JSON — check the tunnel URL.';
}
