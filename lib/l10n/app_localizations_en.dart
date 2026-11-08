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
  String get statusHeroImageLabel => 'BYD Atto 3 reference photo';

  @override
  String get statusHeroAttribution =>
      'Photo: Chanokchon / Wikimedia (CC BY-SA 4.0)';

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
  String get remoteCommunicateTab => 'Cabin';

  @override
  String get remoteGenAiTab => 'GenAI';

  @override
  String get remoteWireGuardTab => 'WireGuard';

  @override
  String get communicateCarStateOn => 'On';

  @override
  String get communicateCarStateOff => 'Off';

  @override
  String get communicateCarStateParked => 'Parked';

  @override
  String get stateEnabled => 'Enabled';

  @override
  String get stateDisabled => 'Disabled';

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

  @override
  String get communicateSettingsTitle => 'Cabin audio & messages';

  @override
  String get communicateVoiceEnabled => 'Remote voice';

  @override
  String get communicateMessagesEnabled => 'On-screen messages';

  @override
  String get communicateListenerEnabled => 'Cabin listener';

  @override
  String get communicateOutputLevel => 'Speaker output level';

  @override
  String get communicateSaveSettings => 'Save communication settings';

  @override
  String get communicateMessageKind => 'Message style';

  @override
  String get communicateKindToast => 'Toast';

  @override
  String get communicateKindDialog => 'Dialog';

  @override
  String get communicateEmergencyStopTitle => 'Emergency stop?';

  @override
  String get communicateEmergencyStopBody =>
      'Stops active remote voice/listening sessions on the vehicle.';

  @override
  String get communicateWsNote =>
      'Hold-to-talk streams audio to the vehicle. Settings and messages use the usual remote API.';

  @override
  String get genAiInsightsList => 'Load insight history';

  @override
  String get genAiTest => 'Run GenAI self-test';

  @override
  String get genAiWsNote =>
      'Realtime voice uses a live session; chat and insights use standard requests.';

  @override
  String get wireGuardConfigTitle => 'Tunnel configuration';

  @override
  String get wireGuardConfigHint =>
      'Paste wg-quick text. Private keys never leave the vehicle server.';

  @override
  String get wireGuardConfigPlaceholder => '[Interface]\\nPrivateKey = …';

  @override
  String get wireGuardConfigSave => 'Upload config';

  @override
  String get wireGuardConfigDelete => 'Remove config';

  @override
  String get wireGuardConfigConfirmTitle => 'Upload WireGuard config?';

  @override
  String get wireGuardConfigConfirmBody =>
      'Replaces the stored tunnel config on the vehicle daemon.';

  @override
  String get wireGuardConfigDeleteTitle => 'Delete WireGuard config?';

  @override
  String get wireGuardConfigDeleteBody =>
      'Removes stored tunnel configuration from the vehicle.';

  @override
  String get commonSuccess => 'Success';

  @override
  String get commonError => 'Error';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionConfirm => 'Confirm';

  @override
  String get settingsOpenIntegrations =>
      'Automations, parking, trips, audio, GenAI tools, Telegram, platform APIs';

  @override
  String get integrationsHubTitle => 'Integrations hub';

  @override
  String get integrationsHubIntro =>
      'Remote vehicle features — forms, confirmations, and clear server feedback.';

  @override
  String get integrationsRefresh => 'Refresh';

  @override
  String get integrationsSaved => 'Saved on server';

  @override
  String get integrationsNameRequired => 'Enter a name';

  @override
  String get integrationsCreateAutomation => 'Create automation';

  @override
  String get integrationsAutomationNameLabel => 'Automation name';

  @override
  String get integrationsRunTest => 'Run test';

  @override
  String get integrationsDelete => 'Delete';

  @override
  String get integrationsTestQueued => 'Test sent to the vehicle';

  @override
  String get integrationsAutomationModeAutomatic => 'Automatic';

  @override
  String get integrationsAutomationModeManual => 'Manual';

  @override
  String get integrationsDeleteAutomationTitle => 'Delete automation?';

  @override
  String integrationsDeleteAutomationBody(String name) {
    return 'Remove “$name” from the vehicle automation store.';
  }

  @override
  String get integrationsAutomationsTitle => 'Automations';

  @override
  String get integrationsAutomationsSubtitle =>
      'List, create, test, and delete rules';

  @override
  String get integrationsParkingTitle => 'Parking';

  @override
  String get integrationsParkingSubtitle =>
      'Sessions and parking assistant config';

  @override
  String get integrationsParkingEnabled => 'Parking assistant enabled';

  @override
  String get integrationsDeleteSessionTitle => 'Delete session?';

  @override
  String get integrationsDeleteSessionBody =>
      'Removes the parking session record on the server.';

  @override
  String get integrationsTripsTitle => 'Trips';

  @override
  String get integrationsTripsSubtitle => 'Trip history and summary';

  @override
  String get integrationsTripSummary => 'Summary';

  @override
  String integrationsTripTotalKm(String km) {
    return '$km km total';
  }

  @override
  String get integrationsDeleteTripTitle => 'Delete trip?';

  @override
  String get integrationsDeleteTripBody =>
      'Removes the trip record from history.';

  @override
  String get integrationsAudioTitle => 'Audio library';

  @override
  String get integrationsAudioSubtitle => 'Play clips stored on the vehicle';

  @override
  String get integrationsAudioStopAll => 'Stop playback';

  @override
  String get integrationsAudioStopped => 'Playback stop sent';

  @override
  String integrationsAudioPlayQueued(String name) {
    return 'Play queued: $name';
  }

  @override
  String get integrationsGenAiToolsTitle => 'GenAI tools';

  @override
  String get integrationsGenAiToolsSubtitle =>
      'Routines, incidents, action execute';

  @override
  String get integrationsGenAiRoutines => 'Routine learning';

  @override
  String get integrationsGenAiActionExecute => 'Vehicle action';

  @override
  String get integrationsGenAiActionExecuteHint =>
      'Runs a validated vehicle action from the server';

  @override
  String get integrationsExecute => 'Execute';

  @override
  String get integrationsActionQueued => 'Action submitted';

  @override
  String get integrationsTelegramTitle => 'Telegram';

  @override
  String get integrationsTelegramSubtitle => 'Pairing status and preferences';

  @override
  String get integrationsTelegramBot => 'Bot';

  @override
  String get integrationsNotConfigured => 'Not configured';

  @override
  String get integrationsTelegramVideoUploads => 'Upload dashcam video';

  @override
  String get integrationsTelegramClearPairing => 'Clear pairing';

  @override
  String get integrationsTelegramClearHint =>
      'Clears owner pairing on the vehicle daemon';

  @override
  String get integrationsTelegramClearTitle => 'Clear Telegram pairing?';

  @override
  String get integrationsTelegramClearBody =>
      'You will need to pair again on the vehicle.';

  @override
  String get integrationsPlatformTitle => 'Platform connectors';

  @override
  String get integrationsPlatformSubtitle =>
      'ABRP, MQTT, launcher, RoadSense, BYD cloud, community';

  @override
  String get integrationsLauncherTitle => 'Launcher summary';

  @override
  String get integrationsBydCloudTitle => 'BYD cloud';

  @override
  String get integrationsCommunityTitle => 'Community automations';

  @override
  String get integrationsHeadUnitNote =>
      'Android Auto / head-unit projection is not implemented in the companion; local launcher APIs remain on the vehicle.';

  @override
  String get voicePttTitle => 'Push-to-talk';

  @override
  String get voicePttHint =>
      'Hold the button while speaking; audio is sent to the vehicle.';

  @override
  String get voicePttHold => 'Hold to talk';

  @override
  String get voicePttConnecting => 'Connecting…';

  @override
  String get voicePttLive => 'Live';

  @override
  String get voicePttStopping => 'Stopping…';

  @override
  String get voicePttFailed => 'Talk failed';

  @override
  String get voiceCabinListenTitle => 'Cabin microphone';

  @override
  String get voiceCabinIdle => 'Off';

  @override
  String get voiceCabinConnecting => 'Connecting…';

  @override
  String get voiceCabinLive => 'Listening';

  @override
  String get voiceCabinPaused => 'Paused during talk';

  @override
  String get voiceCabinError => 'Listener error';

  @override
  String voiceCabinBytes(String bytes) {
    return '$bytes bytes received';
  }

  @override
  String get voiceMicDenied => 'Microphone permission denied';

  @override
  String get voiceMicOpenSettings => 'Open settings to allow microphone';

  @override
  String get genAiVoiceTitle => 'Realtime voice';

  @override
  String get genAiVoiceHint =>
      'Starts a live two-way voice session with the assistant.';

  @override
  String get genAiVoiceStart => 'Start voice session';

  @override
  String get genAiVoiceStop => 'Stop voice session';

  @override
  String get genAiVoiceTruncate => 'Truncate playback';

  @override
  String get platformAbrpTitle => 'ABRP';

  @override
  String get platformMqttTitle => 'MQTT';

  @override
  String get platformMqttAdd => 'Add connection';

  @override
  String get platformCommunityImport => 'Import automation';

  @override
  String get platformSave => 'Save to vehicle';

  @override
  String get platformDeleteToken => 'Delete ABRP token';

  @override
  String get platformDestructiveWarning =>
      'This changes vehicle-side configuration. Confirm before sending.';

  @override
  String get screenshotFixtureDisclaimer =>
      'Fixture capture — not live vehicle verification';

  @override
  String get settingsOpenDiagnostics =>
      'Seat debug, logs, car property, ADAS, lights, RoadSense tools';

  @override
  String get integrationsDiagnosticsTitle => 'Diagnostics & RoadSense';

  @override
  String get integrationsDiagnosticsSubtitle =>
      'Debug reads, log upload, and RoadSense maintenance POSTs';

  @override
  String get integrationsAdvancedDiagnosticsTitle => 'Advanced diagnostics';

  @override
  String get integrationsAdvancedDiagnosticsSubtitle =>
      'Vehicle engineers only — destructive actions and debug reads';

  @override
  String get diagnosticsAdvancedTitle => 'Advanced diagnostics';

  @override
  String get diagnosticsAdvancedWarning =>
      'These tools change vehicle-side state or upload logs. Use only when you understand the impact.';

  @override
  String get integrationsLoadingData => 'Loading from vehicle…';

  @override
  String get integrationsEmptyList => 'Nothing to show yet';

  @override
  String get integrationsEmptyParkingSessions => 'No parking sessions recorded';

  @override
  String get integrationsEmptyTrips => 'No trips in history';

  @override
  String get integrationsRoadSenseTitle => 'RoadSense';

  @override
  String get diagnosticsHubTitle => 'Diagnostics';

  @override
  String get diagnosticsSeatTitle => 'Seat debug';

  @override
  String get diagnosticsLogsTitle => 'Daemon logs';

  @override
  String get diagnosticsLogsUnavailable => 'Log upload not available on server';

  @override
  String get diagnosticsLogsUploadTitle => 'Upload daemon log?';

  @override
  String get diagnosticsLogsUpload => 'Upload';

  @override
  String get diagnosticsCarPropertyTitle => 'Car property debug';

  @override
  String get diagnosticsPropertyKeyLabel => 'Property key (hex)';

  @override
  String get diagnosticsAdasTitle => 'ADAS debug';

  @override
  String get diagnosticsLightTitle => 'Interior light debug';

  @override
  String get diagnosticsLightReadOnly =>
      'Read-only resolve registers (writes need vehicle confirm upstream).';

  @override
  String get diagnosticsRemoteKeyTitle => 'Remote key debug';

  @override
  String get diagnosticsAutoServiceTitle => 'Auto service debug';

  @override
  String get roadSenseMapOnline => 'OpenStreetMap basemap (network)';

  @override
  String get roadSenseMapOfflineGrid =>
      'Basemap unavailable — hazard positions on lat/lon grid';

  @override
  String roadSenseMapMarkersSummary(int count) {
    return '$count markers on map';
  }

  @override
  String get automationLabelSchemaVersion => 'Schema version';

  @override
  String get automationLabelSignals => 'Signals';

  @override
  String get automationLabelEngineState => 'Engine state';

  @override
  String get automationLabelActiveAutomations => 'Active automations';

  @override
  String get automationLabelGlobalEnabled => 'Global enabled';

  @override
  String get roadSenseHazardCount => 'Active hazards';

  @override
  String get roadSenseSeverity => 'Chime severity';

  @override
  String get roadSenseChannel => 'Audio channel';

  @override
  String get roadSenseVolumePercent => 'Volume %';

  @override
  String get roadSenseTestChime => 'Test chime';

  @override
  String get roadSenseDeleteLocalTitle => 'Delete local RoadSense data?';

  @override
  String get roadSenseDeleteLocalBody =>
      'Removes cached hazard tiles on the vehicle (destructive).';

  @override
  String get roadSenseDeleteLocal => 'Delete local data';

  @override
  String get roadSenseDeleteCloudTitle => 'Delete cloud RoadSense data?';

  @override
  String get roadSenseDeleteCloudBody =>
      'Requests cloud purge for this vehicle (destructive).';

  @override
  String get roadSenseDeleteCloud => 'Delete cloud data';

  @override
  String get voiceFixtureUnsupported =>
      'Voice is turned off in vehicle settings';

  @override
  String formatBytesBytes(int bytes) {
    return '$bytes B';
  }

  @override
  String formatBytesKib(String size) {
    return '$size KB';
  }

  @override
  String formatBytesMib(String size) {
    return '$size MB';
  }

  @override
  String get releaseSigningDebugNote =>
      'Release builds are signed with the debug key for CI/preview only — use your own release keystore for production distribution.';

  @override
  String get automationSettingsTitle => 'Automation settings';

  @override
  String get automationSchemaTitle => 'Schema';

  @override
  String get automationGlobalEnabled => 'Automations enabled globally';

  @override
  String get automationStateTitle => 'Engine state';

  @override
  String get automationEditTitle => 'Edit automation';

  @override
  String get automationEnabledLabel => 'Enabled';

  @override
  String get automationModeLabel => 'Mode';

  @override
  String get automationRulesSection => 'Rules';

  @override
  String get automationActionsSection => 'Actions';

  @override
  String get automationAddRule => 'Add rule';

  @override
  String get automationAddAction => 'Add action';

  @override
  String get automationSignalLabel => 'Signal';

  @override
  String get automationOpLabel => 'Operator';

  @override
  String get automationValueLabel => 'Value';

  @override
  String get parkingSignageTitle => 'Session signage';

  @override
  String get parkingSignageMessageLabel => 'Sign message';

  @override
  String get parkingSignageEnabled => 'Signage enabled';

  @override
  String get tripConfigTitle => 'Trip recorder';

  @override
  String get tripConfigEnabled => 'Record trips';

  @override
  String get tripHistoryDaysLabel => 'History window (days)';

  @override
  String get tripBootstrapTitle => 'Bootstrap trip store';

  @override
  String get tripBootstrapBody =>
      'Rebuilds trip metadata on the vehicle (server operation).';

  @override
  String get tripDetailTitle => 'Trip detail';

  @override
  String get tripStartedLabel => 'Started';

  @override
  String get genAiRoutineAccept => 'Accept';

  @override
  String get genAiRoutineReject => 'Reject';

  @override
  String get genAiActionTypeLabel => 'Action type';

  @override
  String get genAiActionTargetLabel => 'Target (optional)';

  @override
  String get genAiActionValueLabel => 'Value (optional)';

  @override
  String get genAiCreateIncidentTitle => 'Create incident pack';

  @override
  String get genAiCreateIncidentBody =>
      'Packages dashcam evidence for GenAI review on the vehicle.';

  @override
  String get genAiRecordingIdLabel => 'Recording ID';

  @override
  String get genAiRecordingIdRequired => 'Enter a recording ID';

  @override
  String get telegramPinTitle => 'Pair with PIN';

  @override
  String get telegramPinLabel => 'Pairing PIN';

  @override
  String get telegramPinSubmit => 'Submit PIN';

  @override
  String get launcherAppearanceTitle => 'Launcher appearance';

  @override
  String get bydCloudLoggedIn => 'Logged in';

  @override
  String get bydCloudConfigured => 'Configured — not logged in';

  @override
  String get mqttTelemetryTitle => 'MQTT telemetry';

  @override
  String get audioAvasTitle => 'AVAS playback';

  @override
  String get audioAvasPlaying => 'Playing';

  @override
  String get audioAvasIdle => 'Idle';

  @override
  String get huRemoteTitle => 'Head-unit remote';

  @override
  String get huRemoteIntro =>
      'Shell keys, voice daemon, and cluster cast API — effects occur on the vehicle displays.';

  @override
  String get huRemoteOpen => 'Open head-unit controls';

  @override
  String get huShellSection => 'Head-unit shell';

  @override
  String get huShellHint =>
      'Sends Android navigation keys to the vehicle display (remote effect on HU).';

  @override
  String get huShellConfirmBody =>
      'This navigates the vehicle head unit. Confirm only if you are authorized.';

  @override
  String get huHome => 'Home';

  @override
  String get huBack => 'Back';

  @override
  String get huRecents => 'Recents';

  @override
  String get huDisplayId => 'Display';

  @override
  String get huMoveX => 'X offset';

  @override
  String get huMoveY => 'Y offset';

  @override
  String get huMoveDisplayTitle => 'Move display';

  @override
  String get huVoiceSection => 'Head-unit voice';

  @override
  String get huVoiceConfirmBody =>
      'Audio or speech plays on the vehicle speakers.';

  @override
  String get huAudioFileLabel => 'Audio file name';

  @override
  String get huAudioFileHint => 'Vehicle-side clip path or library name';

  @override
  String get huPlayAudio => 'Play on HU';

  @override
  String get huStopAudio => 'Stop HU audio';

  @override
  String get huSpeakText => 'Text to speak';

  @override
  String get huSpeak => 'Speak';

  @override
  String get huMessageText => 'On-screen message';

  @override
  String get huMessage => 'Show message';

  @override
  String get huClusterSection => 'Cluster cast API';

  @override
  String get huClusterHint =>
      'Starts/stops cluster mirroring on the vehicle. Mirrored UI still renders on hardware.';

  @override
  String get huClusterAppPackage => 'App package (optional)';

  @override
  String get huClusterCastStart => 'Start cluster cast';

  @override
  String get huClusterCastStop => 'Stop cluster cast';

  @override
  String get debugWriteSection => 'Write (requires confirm token)';

  @override
  String get debugWriteTitle => 'Apply debug write?';

  @override
  String get debugWriteBody =>
      'Writes low-level vehicle registers. Incorrect values can affect safety systems.';

  @override
  String get debugWriteSubmit => 'Apply write';

  @override
  String get debugConfirmTokenLabel => 'Confirm token';

  @override
  String get debugConfirmTokenHint =>
      'Upstream requires exact confirm text (e.g. YES)';

  @override
  String get debugRegisterLabel => 'Register';

  @override
  String get debugLightZoneLabel => 'Light zone';

  @override
  String get debugLightLevelLabel => 'Level (0–100)';
}
