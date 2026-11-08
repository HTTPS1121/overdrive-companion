// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hebrew (`he`).
class AppLocalizationsHe extends AppLocalizations {
  AppLocalizationsHe([String locale = 'he']) : super(locale);

  @override
  String get appTitle => 'מלווה Overdrive';

  @override
  String get navStatus => 'מצב';

  @override
  String get navControls => 'שליטה';

  @override
  String get navCameras => 'מצלמות';

  @override
  String get navLocation => 'מיקום';

  @override
  String get navSettings => 'הגדרות';

  @override
  String get connectionTitle => 'חיבור למנהרה';

  @override
  String get connectionIntro =>
      'הזן כתובת מנהרה, טען מזהה מכשיר מהשרת ברכב, והזן את קוד הגישה כפי שמוצג במסך ההתחברות בדפדפן.';

  @override
  String get connectionIntroLong =>
      'פתח את כתובת המנהרה בדפדפן בצד הרכב כדי לראות את מזהה המכשיר, והזן את אותו הקוד כאן.';

  @override
  String get connectionScreenTitle => 'התחברות לרכב מרחוק';

  @override
  String get tunnelUrlLabel => 'כתובת מנהרה (HTTPS)';

  @override
  String get tunnelUrlHint => 'https://your-tunnel.example.com';

  @override
  String get tunnelUrlHelper => 'חייבת להגיע לשרת Overdrive ברכב';

  @override
  String get deviceIdLabel => 'מזהה מכשיר';

  @override
  String get deviceIdLabelLong => 'מזהה מכשיר (Device ID)';

  @override
  String get deviceIdHint => 'לחץ רענן לאחר הזנת כתובת המנהרה';

  @override
  String get deviceIdHelper =>
      'לחץ רענון לאחר שהמנהרה נכונה — טוען את המזהה מהשרת ברכב';

  @override
  String get errorTunnelFirst => 'הזן קודם כתובת מנהרה (HTTPS).';

  @override
  String get errorTunnelUnreachable =>
      'לא ניתן להגיע למנהרה. בדוק HTTPS, רשת ושהשרת ברכב פעיל.';

  @override
  String get errorDeviceIdFromServer =>
      'לא התקבל מזהה מכשיר מהשרת. בדוק מנהרה וחיבור רכב.';

  @override
  String get deviceIdPlaceholder => 'לחץ רענן לאחר הזנת כתובת המנהרה';

  @override
  String get accessCodeLabel => 'קוד גישה';

  @override
  String get accessCodeHelper =>
      'הזן את אותו קוד גישה כפי שמופיע במסך ההתחברות ברכב, לאחר מזהה המכשיר';

  @override
  String get connectSave => 'התחבר ושמור';

  @override
  String get refreshDeviceId => 'טען מזהה מהמנהרה';

  @override
  String get localHttpWarningTitle => 'HTTP מקומי בלבד';

  @override
  String get localHttpWarningBody => 'למנהרה מרחוק נדרש HTTPS.';

  @override
  String get errorHtmlTunnel =>
      'השרת החזיר HTML במקום JSON. בדוק את כתובת המנהרה.';

  @override
  String get errorAuthRejected =>
      'קוד הגישה לא התקבל. רענן מזהה מכשיר ונסה שוב.';

  @override
  String get errorSessionExpired => 'פג תוקף ההתחברות — התחבר שוב.';

  @override
  String get errorDeviceIdMissing => 'טען מזהה מכשיר מהמנהרה לפני ההתחברות.';

  @override
  String get errorAccessCodeShort => 'קוד הגישה קצר מדי (לפחות 8 תווים).';

  @override
  String get errorTunnelUrlRequired => 'נא למלא כתובת מנהרה.';

  @override
  String get errorUnexpectedAuth => 'השרת לא ענה כמצופה לאחר אימות.';

  @override
  String get cameraLiveTitle => 'שידור חי';

  @override
  String get cameraLiveHelp => 'תצוגה חיה ממצלמות הלוח כשהשידור פעיל.';

  @override
  String get streamBadgeLive => 'חי';

  @override
  String get streamBadgeOffline => 'לא מחובר';

  @override
  String get streamBadgeEnabled => 'שידור פעיל';

  @override
  String get streamBadgeDisabled => 'שידור כבוי';

  @override
  String streamQualityCurrent(String level) {
    return 'איכות · $level';
  }

  @override
  String get cameraViewPickerTitle => 'בחירת מצלמה';

  @override
  String get cameraQualityTitle => 'איכות וידאו';

  @override
  String get cameraQualityLow => 'נמוכה';

  @override
  String get cameraQualityMedium => 'בינונית';

  @override
  String get cameraQualityHigh => 'גבוהה';

  @override
  String get cameraEnableStream => 'הפעל שידור';

  @override
  String get cameraDisableStream => 'כבה שידור';

  @override
  String get cameraSurveillanceTitle => 'מעקב / נהיגה';

  @override
  String get cameraRecordingsTitle => 'הקלטות';

  @override
  String get cameraViewMosaic => 'כל המצלמות';

  @override
  String get cameraViewFront => 'קדמי';

  @override
  String get cameraViewRight => 'ימין';

  @override
  String get cameraViewRear => 'אחורי';

  @override
  String get cameraViewLeft => 'שמאל';

  @override
  String streamConnectedLabel(String connected) {
    return 'שידור: $connected';
  }

  @override
  String streamViewModeLabel(int mode) {
    return 'מצב תצוגה: $mode';
  }

  @override
  String get streamPhaseIdle => 'ממתין';

  @override
  String get streamPhaseConnecting => 'מתחבר…';

  @override
  String get streamPhaseConnected => 'מחובר — ממתין לפריימים';

  @override
  String get streamPhaseLive => 'שידור חי';

  @override
  String streamPhaseReconnecting(int attempt) {
    return 'מתחבר מחדש (ניסיון $attempt)…';
  }

  @override
  String get streamPhaseError => 'שגיאת שידור';

  @override
  String get streamPhaseDecoderError => 'מפענח לא זמין';

  @override
  String get recordingDownload => 'הורדה';

  @override
  String recordingSavedTo(String path) {
    return 'נשמר ב־$path';
  }

  @override
  String get recordingNone => 'אין הקלטות';

  @override
  String get recordingLoadFailed => 'לא ניתן לטעון הקלטות';

  @override
  String get surveillanceEnabled => 'מעקב פעיל';

  @override
  String get surveillanceDisabled => 'מעקב כבוי';

  @override
  String get surveillanceLoadConfig => 'טען הגדרות';

  @override
  String get surveillanceSaveConfig => 'שמור רגישות';

  @override
  String surveillanceSnapshot(int q) {
    return 'פינה $q';
  }

  @override
  String get surveillanceCornerFrontLeft => 'קדמי שמאל';

  @override
  String get surveillanceCornerFrontRight => 'קדמי ימין';

  @override
  String get surveillanceCornerRearLeft => 'אחורי שמאל';

  @override
  String get surveillanceCornerRearRight => 'אחורי ימין';

  @override
  String get surveillanceEnable => 'הפעל';

  @override
  String get surveillanceDisable => 'כבה';

  @override
  String get statusHeroTitle => 'רכב Overdrive';

  @override
  String get statusLocked => 'נעול';

  @override
  String get statusUnlocked => 'פתוח';

  @override
  String get statusConnectionTitle => 'חיבור';

  @override
  String get statusConnectedToServer => 'מחובר לשרת';

  @override
  String get statusDataStale => 'נתונים ישנים — רענן לפני פקודות';

  @override
  String get statusRetry => 'נסה שוב';

  @override
  String get statusNotConnected => 'לא מחובר';

  @override
  String get statusSetupInSettings => 'הגדר חיבור בהגדרות';

  @override
  String get statusServerUnreachable => 'אין קשר עם השרת';

  @override
  String get statusCheckTunnel => 'בדוק מנהרה ורשת';

  @override
  String get statusErrorTitle => 'שגיאה';

  @override
  String get statusDriving => 'בנסיעה';

  @override
  String get statusParked => 'חונה';

  @override
  String get statusRangeUnit => 'ק״מ';

  @override
  String get sectionClimate => 'מיזוג';

  @override
  String get sectionWindows => 'חלונות';

  @override
  String get sectionTyres => 'צמיגים';

  @override
  String get tyreFrontLeft => 'קדמי שמאל';

  @override
  String get tyreFrontRight => 'קדמי ימין';

  @override
  String get tyreRearLeft => 'אחורי שמאל';

  @override
  String get tyreRearRight => 'אחורי ימין';

  @override
  String get sectionCloud => 'ענן BYD';

  @override
  String get stateOn => 'פועל';

  @override
  String get stateOff => 'כבוי';

  @override
  String get cloudActive => 'מקושר ומאומת';

  @override
  String get cloudPartial => 'לא הושלם';

  @override
  String get freshnessNotYet => 'לא עודכן עדיין';

  @override
  String freshnessUpdated(String ago) {
    return 'עודכן $ago';
  }

  @override
  String get freshnessNow => 'עכשיו';

  @override
  String freshnessSecondsAgo(int n) {
    return 'לפני $n שניות';
  }

  @override
  String freshnessMinutesAgo(int n) {
    return 'לפני $n דקות';
  }

  @override
  String freshnessHoursAgo(int n) {
    return 'לפני $n שעות';
  }

  @override
  String freshnessDaysAgo(int n) {
    return 'לפני $n ימים';
  }

  @override
  String get controlSectionAccess => 'גישה לרכב';

  @override
  String get controlSectionWindows => 'חלונות';

  @override
  String get controlSectionClimate => 'מיזוג';

  @override
  String get controlStaleTitle => 'נתונים ישנים';

  @override
  String controlStaleBody(String ago) {
    return 'רענן את המצב לפני שליחת פקודה ($ago)';
  }

  @override
  String controlConfirmTitle(String action) {
    return 'לאשר $action?';
  }

  @override
  String get controlConfirmBody =>
      'הפעולה תישלח לרכב דרך המנהרה. ודא שהרכב במקום בטוח.';

  @override
  String get controlSend => 'שליחה';

  @override
  String get controlClimateOffAction => 'כיבוי מיזוג';

  @override
  String get controlClimateOnAction => 'הפעלת מיזוג';

  @override
  String get controlSteeringHeatOff => 'כיבוי חימום הגה';

  @override
  String get controlSteeringHeatOn => 'חימום הגה';

  @override
  String get controlTempDownShort => 'קריר יותר';

  @override
  String get controlTempUpShort => 'חם יותר';

  @override
  String get controlLock => 'נעילה';

  @override
  String get controlUnlock => 'פתיחה';

  @override
  String get controlTrunkOpen => 'פתיחת תא מטען';

  @override
  String get controlTrunkClose => 'סגירת תא מטען';

  @override
  String get controlWindowsOpen => 'פתיחת חלונות';

  @override
  String get controlWindowsClose => 'סגירת חלונות';

  @override
  String get controlWindowsVent => 'אוורור';

  @override
  String get controlFlash => 'הבהוב אורות';

  @override
  String get controlFindCar => 'מציאת רכב';

  @override
  String get controlClimateOn => 'הפעלת מיזוג';

  @override
  String get controlClimateOff => 'כיבוי מיזוג';

  @override
  String get controlTempUp => 'חם יותר';

  @override
  String get controlTempDown => 'קריר יותר';

  @override
  String get controlFanUp => 'מאוורר +';

  @override
  String get controlFanDown => 'מאוורר −';

  @override
  String get controlReadingLight => 'תאורת קריאה';

  @override
  String get controlSteeringHeat => 'חימום הגה';

  @override
  String get controlsErrorTitle => 'שגיאה';

  @override
  String get controlsNoConnection => 'אין חיבור לשרת — שליטה לא זמינה';

  @override
  String get actionCancel => 'ביטול';

  @override
  String get settingsSectionConnection => 'חיבור';

  @override
  String get settingsSectionAppearance => 'תצוגה';

  @override
  String get settingsSectionRemote => 'Remote services';

  @override
  String get settingsAppearanceHint =>
      'בהיר, כהה, או לפי המערכת. צבע דינמי דורש Android 12+.';

  @override
  String get settingsDynamicColorTitle => 'צבעים דינמיים (Material You)';

  @override
  String get settingsDynamicColorSubtitle => 'לפי ערכת הצבעים של המכשיר';

  @override
  String get settingsSaveConnect => 'שמירה והתחברות';

  @override
  String get settingsSaved => 'ההגדרות נשמרו';

  @override
  String get settingsThemeSystem => 'מערכת';

  @override
  String get settingsThemeLight => 'בהיר';

  @override
  String get settingsThemeDark => 'כהה';

  @override
  String get settingsOpenRemoteServices => 'Cabin audio, GenAI, WireGuard';

  @override
  String get settingsOpenCapabilityInventory =>
      'API coverage vs Overdrive server';

  @override
  String get controlsTabCommands => 'פקודות';

  @override
  String get controlsTabSchedules => 'תזמונים';

  @override
  String get controlsTabComfort => 'נוחות';

  @override
  String get controlsTabCharging => 'טעינה';

  @override
  String get scheduleTabClimate => 'Pre-climate';

  @override
  String get scheduleTabCharging => 'Smart charge';

  @override
  String get gpsNoLocationServer => 'אין מיקום — נדרש חיבור פעיל לשרת';

  @override
  String get gpsServerNoGps => 'השרת לא החזיר נתוני GPS';

  @override
  String get gpsNoCoordinates => 'אין קואורדינטות בתשובת השרת';

  @override
  String get gpsMapNeedsNetwork =>
      'תצוגת מפה דורשת רשת במכשיר.\nהקואורדינטות והניווט למטה תקפים מהשרת.';

  @override
  String get gpsMapLoadFailed => 'לא ניתן לטעון מפה — הקואורדינטות זמינות';

  @override
  String get gpsCoordinates => 'קואורדינטות';

  @override
  String get gpsSpeed => 'מהירות';

  @override
  String get gpsHeading => 'כיוון';

  @override
  String get gpsOpenNavigation => 'פתיחה בניווט';

  @override
  String get gpsNavigationUnavailable => 'לא ניתן לפתוח אפליקציית ניווט';

  @override
  String get chargeCapTitle => 'מגבלת טעינה';

  @override
  String get chargeCapLoadFailed => 'לא ניתן לטעון מגבלת טעינה מהשרת';

  @override
  String get chargeCapUnsupported =>
      'השרת דיווח שמגבלת טעינה אינה נתמכת במכונית זו';

  @override
  String get chargeCapDescription => 'הגבלת אחוז סוללה מקסימלי בטעינה.';

  @override
  String get chargeCapTarget => 'יעד טעינה';

  @override
  String get chargeCapEnableTitle => 'הפעלת מגבלה';

  @override
  String get chargeCapEnableSubtitle => 'כאשר פעיל, הטעינה תיעצר ביעד שנבחר';

  @override
  String get chargeCapSave => 'שמירה לשרת';

  @override
  String get acChargeTitle => 'זרם טעינה AC';

  @override
  String get acChargeLoadFailed => 'לא ניתן לקרוא זרם טעינה AC מהשרת';

  @override
  String get acChargeTrimUnsupported => 'הדגם לא תומך בהגבלת זרם טעינה AC.';

  @override
  String get acChargeUnavailable => 'נתוני זרם טעינה לא זמינים כעת מהרכב.';

  @override
  String get acChargeLevelsHint =>
      'חמש רמות בהתאם לרכב; השמירה מעדכנת את ההגדרה בשרת.';

  @override
  String acChargeLevelAmps(int amps) {
    return '$amps A';
  }

  @override
  String acChargeCurrentLabel(String label) {
    return 'רמה נוכחית: $label';
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
    return 'פקודת $action נכשלה';
  }

  @override
  String commandSentUnconfirmed(String action) {
    return 'פקודת $action נשלחה אך לא אושרה ברכב';
  }

  @override
  String commandSuccess(String action) {
    return 'פקודת $action בוצעה';
  }

  @override
  String get commandLockConfirmed => 'הרכב ננעל';

  @override
  String get commandUnlockConfirmed => 'הרכב נפתח';

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
}
