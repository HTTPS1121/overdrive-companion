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
  String get statusHeroImageLabel => 'תמונת ייחוס BYD Atto 3';

  @override
  String get statusHeroAttribution =>
      'צילום: Chanokchon / Wikimedia (CC BY-SA 4.0)';

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
  String get actionScheduleClimate => 'תזמון מיזוג';

  @override
  String get actionScheduleCharging => 'תזמון טעינה';

  @override
  String get actionStartCharging => 'התחלת טעינה';

  @override
  String get actionSeat => 'מושב';

  @override
  String get actionMedia => 'מדיה';

  @override
  String get actionAdas => 'ADAS';

  @override
  String get actionCpd => 'CPD';

  @override
  String get actionBatteryHeat => 'חימום סוללה';

  @override
  String get actionChargeCap => 'מגבלת טעינה';

  @override
  String get settingsSectionConnection => 'חיבור';

  @override
  String get settingsSectionAppearance => 'תצוגה';

  @override
  String get settingsSectionRemote => 'שירותים מרחוק';

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
  String get settingsOpenRemoteServices => 'שמע ברכב, GenAI, WireGuard';

  @override
  String get settingsOpenCapabilityInventory => 'מפת יכולות מול שרת Overdrive';

  @override
  String get controlsTabCommands => 'פקודות';

  @override
  String get controlsTabSchedules => 'תזמונים';

  @override
  String get controlsTabComfort => 'נוחות';

  @override
  String get controlsTabCharging => 'טעינה';

  @override
  String get scheduleTabClimate => 'מיזוג מראש';

  @override
  String get scheduleTabCharging => 'טעינה חכמה';

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
    return '$amps A';
  }

  @override
  String acChargeCurrentLabel(String label) {
    return 'רמה נוכחית: $label';
  }

  @override
  String get extendedPowerSection => 'הדלקה וכיבוי';

  @override
  String get extendedPowerDrivingBlocked =>
      'הרכב מדווח בנסיעה — הדלקה/כיבוי חסומים עד עצירה (שומר בשרת).';

  @override
  String get extendedPowerOn => 'הדלקת רכב';

  @override
  String get extendedPowerOff => 'כיבוי רכב';

  @override
  String get extendedBatteryHeatSection => 'חימום סוללה';

  @override
  String get extendedBatteryHeatUnknown =>
      'השרת לא דיווח מצב חימום סוללה — הפעלה לא זמינה.';

  @override
  String get extendedBatteryPreheat => 'חימום מקדים לסוללה';

  @override
  String get extendedBatteryHeatOn => 'פעיל לפי השרת';

  @override
  String get extendedBatteryHeatOff => 'כבוי לפי השרת';

  @override
  String get extendedScreenshotsSection => 'צילום מסכי הרכב';

  @override
  String get extendedScreenshotsHint =>
      'PNG נשמר במכשיר הרכב (מולטימדיה או לוח שעונים). לא מורד אוטומטית לטלפון.';

  @override
  String get extendedScreenshotHu => 'צילום מסך מולטימדיה';

  @override
  String get extendedScreenshotCluster => 'צילום מסך לוח שעונים';

  @override
  String get extendedConfirmPowerOnTitle => 'להדליק את הרכב?';

  @override
  String get extendedConfirmPowerOffTitle => 'לכבות את הרכב?';

  @override
  String get extendedConfirmPowerOnBody =>
      'נשלח רק כשהרכב חונה וללא תנועה (שומר SDK בשרת).';

  @override
  String get extendedConfirmPowerOffBody =>
      'הרכב ייכבה — ודא שאין נוסעים ברכב.';

  @override
  String extendedConfirmScreenshotTitle(String label) {
    return 'לאשר $label?';
  }

  @override
  String get extendedConfirmScreenshotBody =>
      'השרת יצלם במכשיר הרכב וישמור קובץ PNG.';

  @override
  String get extendedConfirmCapture => 'צילום';

  @override
  String get scheduleClimateTitle => 'תזמוני מיזוג מהשרת';

  @override
  String get scheduleClimateEmpty => 'אין תזמונים פעילים — צור תזמון חדש למטה.';

  @override
  String scheduleClimateUnsupported(String reason) {
    return 'לא נתמך: $reason';
  }

  @override
  String scheduleClimateListUnavailable(String reason) {
    return 'רשימת תזמונים לא זמינה כעת ($reason).\nלא מוצגת רשימה ריקה כהוכחה להיעדר תזמונים.';
  }

  @override
  String get scheduleInvalidResponse => 'תגובת שרת לא תקינה';

  @override
  String get scheduleDurationMinutes => 'משך פעולה (דקות)';

  @override
  String get scheduleCreate => 'יצירה';

  @override
  String get scheduleUpdate => 'עדכון';

  @override
  String get scheduleCancelEdit => 'ביטול עריכה';

  @override
  String get scheduleDeleteTooltip => 'מחיקה';

  @override
  String scheduleChargingUnsupported(Object reason) {
    return 'לא נתמך: $reason';
  }

  @override
  String get scheduleChargingStatus => 'סטטוס';

  @override
  String get scheduleChargingEnabled => 'טעינה מתוזמנת פעילה';

  @override
  String get scheduleChargingStart => 'התחלה (HH:mm)';

  @override
  String get scheduleChargingEnd => 'סיום (HH:mm או full)';

  @override
  String get scheduleChargingRepeat => 'סוג חזרה';

  @override
  String get scheduleRepeatDaily => 'חוזר בכל יום';

  @override
  String get scheduleRepeatOnce => 'חד־פעמי';

  @override
  String get scheduleChargingSaveWindow => 'שמירת חלון';

  @override
  String get scheduleChargingStartNow => 'התחל טעינה עכשיו';

  @override
  String get stateActive => 'פעיל';

  @override
  String get stateInactive => 'כבוי';

  @override
  String get comfortTabSeats => 'מושבים';

  @override
  String get comfortTabMediaSafety => 'מדיה ובטיחות';

  @override
  String get comfortMediaTitle => 'עוצמת מדיה ובהירות מסך';

  @override
  String get comfortSafetyTitle => 'בטיחות';

  @override
  String get comfortEsp => 'יציבות (ESP)';

  @override
  String get comfortItac => 'אחיזה (ITAC)';

  @override
  String get comfortUnavailable => 'לא זמין';

  @override
  String get comfortSlw => 'התרעת מהירות (SLW)';

  @override
  String get comfortCpd => 'זיהוי ילד ברכב (CPD)';

  @override
  String get seatHint => 'רמות חימום ואוורור כפי שדווחו מהרכב';

  @override
  String get seatDriver => 'מושב נהג';

  @override
  String get seatPassenger => 'מושב נוסע';

  @override
  String get seatHeat => 'חימום';

  @override
  String get seatVent => 'אוורור';

  @override
  String get seatVentUnsupported => 'אוורור לא נתמך ברכב זה';

  @override
  String get seatRecallMemory => 'קריאת זיכרון';

  @override
  String get seatSaveMemory => 'שמירת מושב';

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
  String get surveillanceHeatmapTitle => 'מפת חום חניה';

  @override
  String get surveillanceHeatmapLoad => 'טען מפת חום';

  @override
  String get surveillanceFilterLogTitle => 'יומן מסנן';

  @override
  String get surveillanceFilterLogLoad => 'טען יומן';

  @override
  String get surveillanceScreenDeterrentTitle => 'הרתעת מסך';

  @override
  String get surveillanceScreenDeterrentTest => 'בדיקה ברכב';

  @override
  String get surveillanceScreenDeterrentFetch => 'תצוגת תמונה';

  @override
  String get remoteCommunicateTitle => 'תקשורת לתא הנוסעים';

  @override
  String get remoteGenAiTitle => 'עוזר GenAI';

  @override
  String get remoteWireGuardTitle => 'מנהרת WireGuard';

  @override
  String get remoteCommunicateTab => 'תא';

  @override
  String get remoteGenAiTab => 'GenAI';

  @override
  String get remoteWireGuardTab => 'WireGuard';

  @override
  String get communicateCarStateOn => 'פועל';

  @override
  String get communicateCarStateOff => 'כבוי';

  @override
  String get communicateCarStateParked => 'בחנייה';

  @override
  String get stateEnabled => 'פעיל';

  @override
  String get stateDisabled => 'כבוי';

  @override
  String get communicateAudioReady => 'קול מוכן';

  @override
  String get communicateMessagesReady => 'הודעות מוכנות';

  @override
  String get communicateListenerReady => 'האזנה מוכנה';

  @override
  String get communicateSendMessage => 'שליחת הודעה';

  @override
  String get communicateMessageHint => 'טקסט שיוצג ברכב';

  @override
  String get communicateTestSpeaker => 'בדיקת רמקול';

  @override
  String get communicateEmergencyStop => 'עצירת חירום';

  @override
  String get communicateLoadStatus => 'רענון מצב';

  @override
  String get genAiLoadStatus => 'רענון מצב';

  @override
  String get genAiSendChat => 'שליחה';

  @override
  String get genAiChatHint => 'שאל את העוזר ברכב';

  @override
  String get genAiInsightsOpen => 'לוח תובנות';

  @override
  String get wireGuardLoadStatus => 'רענון מצב';

  @override
  String get wireGuardExposeOn => 'חשיפת לוח';

  @override
  String get wireGuardExposeOff => 'הסתרת לוח';

  @override
  String get inventoryTitle => 'מפת יכולות שרת';

  @override
  String get inventoryImplemented => 'באפליקציה';

  @override
  String get inventoryPartial => 'חלקי';

  @override
  String get inventoryNotInApp => 'HTTP בלבד / ללא מסך';

  @override
  String get errorFreshnessUnknown => 'מקור זמן לא ידוע';

  @override
  String get errorFreshnessClockSkew => 'שעון הרכב מקדים את המכשיר';

  @override
  String get errorConnectionNotConfigured => 'חיבור לשרת לא הוגדר';

  @override
  String get errorDeviceIdBeforeLogin => 'טען מזהה מכשיר מהמנהרה לפני ההתחברות';

  @override
  String get errorConfigureTunnel => 'הגדר כתובת מנהרה ואסימון מכשיר';

  @override
  String get remoteServicesTitle => 'שירותים מרחוק';

  @override
  String get drivingInMotion => 'בנסיעה';

  @override
  String get drivingParked => 'בחנייה';

  @override
  String heatmapQuadrantSummary(String name, String active) {
    return 'פינה $name: $active בלוקים פעילים';
  }

  @override
  String get filterLogEmpty => 'אין רשומות ביומן';

  @override
  String get genAiReplyTitle => 'תשובה';

  @override
  String get wireGuardConfigured => 'מוגדר';

  @override
  String get wireGuardRunning => 'פועל';

  @override
  String get wireGuardNotConfigured => 'לא מוגדר';

  @override
  String get communicateCarState => 'מצב רכב';

  @override
  String get seatLevelOff => 'כבוי';

  @override
  String get seatLevelLow => 'נמוך';

  @override
  String get seatLevelHigh => 'גבוה';

  @override
  String celsiusDegrees(String temp) {
    return '$temp מעלות צלזיוס';
  }

  @override
  String get scheduleUnknownTime => 'שעה לא ידועה';

  @override
  String get scheduleNewTitle => 'תזמון חדש';

  @override
  String get scheduleEditTitle => 'עריכת תזמון';

  @override
  String scheduleMinutesShort(String minutes) {
    return '$minutes דק׳';
  }

  @override
  String get rateLimitError => 'יותר מדי ניסיונות התחברות. המתן דקה ונסה שוב.';

  @override
  String get authHtmlRejected =>
      'השרת החזיר דף HTML במקום JSON — בדוק את כתובת המנהרה.';

  @override
  String get communicateSettingsTitle => 'שמע תא והודעות';

  @override
  String get communicateVoiceEnabled => 'קול מרחוק';

  @override
  String get communicateMessagesEnabled => 'הודעות על המסך';

  @override
  String get communicateListenerEnabled => 'האזנה לתא';

  @override
  String get communicateOutputLevel => 'עוצמת רמקול';

  @override
  String get communicateSaveSettings => 'שמירת הגדרות תקשורת';

  @override
  String get communicateMessageKind => 'סגנון הודעה';

  @override
  String get communicateKindToast => 'התראה קצרה';

  @override
  String get communicateKindDialog => 'חלון';

  @override
  String get communicateEmergencyStopTitle => 'עצירת חירום?';

  @override
  String get communicateEmergencyStopBody =>
      'עוצר שיחות קול והאזנה פעילות ברכב.';

  @override
  String get communicateWsNote =>
      'לחיצה לדיבור שולחת שמע לרכב. ההגדרות וההודעות נשלחות כרגיל.';

  @override
  String get genAiInsightsList => 'טעינת היסטוריית תובנות';

  @override
  String get genAiTest => 'בדיקת GenAI';

  @override
  String get genAiWsNote => 'שיחת קול בזמן אמת; צ׳אט ותובנות דרך בקשות רגילות.';

  @override
  String get wireGuardConfigTitle => 'הגדרות מנהרה';

  @override
  String get wireGuardConfigHint =>
      'הדבק טקסט wg-quick. מפתחות פרטיים נשארים בשרת הרכב.';

  @override
  String get wireGuardConfigPlaceholder => '[Interface]\\nPrivateKey = …';

  @override
  String get wireGuardConfigSave => 'העלאת הגדרה';

  @override
  String get wireGuardConfigDelete => 'הסרת הגדרה';

  @override
  String get wireGuardConfigConfirmTitle => 'להעלות הגדרת WireGuard?';

  @override
  String get wireGuardConfigConfirmBody =>
      'מחליף את הגדרת המנהרה השמורה בדמוון הרכב.';

  @override
  String get wireGuardConfigDeleteTitle => 'למחוק הגדרת WireGuard?';

  @override
  String get wireGuardConfigDeleteBody => 'מסיר את הגדרת המנהרה מהרכב.';

  @override
  String get commonSuccess => 'הצלחה';

  @override
  String get commonError => 'שגיאה';

  @override
  String get actionDelete => 'מחיקה';

  @override
  String get actionConfirm => 'אישור';

  @override
  String get settingsOpenIntegrations =>
      'אוטומציות, חניה, נסיעות, ספריית שמע, כלי GenAI, טלגרם ו־API';

  @override
  String get integrationsHubTitle => 'מרכז אינטגרציות';

  @override
  String get integrationsHubIntro =>
      'יכולות מרוחקות מהרכב — טפסים, אישורים ומשוב ברור מהשרת.';

  @override
  String get integrationsRefresh => 'רענון';

  @override
  String get integrationsSaved => 'נשמר בשרת';

  @override
  String get integrationsNameRequired => 'הזן שם';

  @override
  String get integrationsCreateAutomation => 'יצירת אוטומציה';

  @override
  String get integrationsAutomationNameLabel => 'שם אוטומציה';

  @override
  String get integrationsRunTest => 'הרצת בדיקה';

  @override
  String get integrationsDelete => 'מחיקה';

  @override
  String get integrationsTestQueued => 'הבדיקה נשלחה לרכב';

  @override
  String get integrationsAutomationModeAutomatic => 'אוטומטי';

  @override
  String get integrationsAutomationModeManual => 'ידני';

  @override
  String get integrationsDeleteAutomationTitle => 'למחוק אוטומציה?';

  @override
  String integrationsDeleteAutomationBody(String name) {
    return 'הסרת «$name» ממאגר האוטומציות.';
  }

  @override
  String get integrationsAutomationsTitle => 'אוטומציות';

  @override
  String get integrationsAutomationsSubtitle => 'רשימה, יצירה, בדיקה ומחיקה';

  @override
  String get integrationsParkingTitle => 'חניה';

  @override
  String get integrationsParkingSubtitle => 'מפגשים והגדרות עוזר חניה';

  @override
  String get integrationsParkingEnabled => 'עוזר חניה פעיל';

  @override
  String get integrationsDeleteSessionTitle => 'למחוק מפגש?';

  @override
  String get integrationsDeleteSessionBody => 'מוחק את רשומת המפגש בשרת.';

  @override
  String get integrationsTripsTitle => 'נסיעות';

  @override
  String get integrationsTripsSubtitle => 'היסטוריה וסיכום';

  @override
  String get integrationsTripSummary => 'סיכום';

  @override
  String integrationsTripTotalKm(String km) {
    return '$km ק״מ סה״כ';
  }

  @override
  String get integrationsDeleteTripTitle => 'למחוק נסיעה?';

  @override
  String get integrationsDeleteTripBody => 'מוחק את רשומת הנסיעה מההיסטוריה.';

  @override
  String get integrationsAudioTitle => 'ספריית שמע';

  @override
  String get integrationsAudioSubtitle => 'השמעת קבצים מהרכב';

  @override
  String get integrationsAudioStopAll => 'עצירת השמעה';

  @override
  String get integrationsAudioStopped => 'נשלחה פקודת עצירה';

  @override
  String integrationsAudioPlayQueued(String name) {
    return 'השמעה בתור: $name';
  }

  @override
  String get integrationsGenAiToolsTitle => 'כלי GenAI';

  @override
  String get integrationsGenAiToolsSubtitle => 'שגרות, אירועים וביצוע פעולות';

  @override
  String get integrationsGenAiRoutines => 'למידת שגרות';

  @override
  String get integrationsGenAiActionExecute => 'פעולת רכב';

  @override
  String get integrationsGenAiActionExecuteHint => 'מריץ פעולת רכב מאומתת בשרת';

  @override
  String get integrationsExecute => 'ביצוע';

  @override
  String get integrationsActionQueued => 'הפעולה נשלחה';

  @override
  String get integrationsTelegramTitle => 'טלגרם';

  @override
  String get integrationsTelegramSubtitle => 'סטטוס והעדפות';

  @override
  String get integrationsTelegramBot => 'בוט';

  @override
  String get integrationsNotConfigured => 'לא מוגדר';

  @override
  String get integrationsTelegramVideoUploads => 'העלאת וידאו ממצלמה';

  @override
  String get integrationsTelegramClearPairing => 'ניקוי צימוד';

  @override
  String get integrationsTelegramClearHint => 'מנקה צימוד בעלים בדמוון הרכב';

  @override
  String get integrationsTelegramClearTitle => 'לנקות צימוד טלגרם?';

  @override
  String get integrationsTelegramClearBody => 'יהיה צורך לצמד מחדש ברכב.';

  @override
  String get integrationsPlatformTitle => 'מחברי פלטפורמה';

  @override
  String get integrationsPlatformSubtitle =>
      'ABRP, MQTT, Launcher, RoadSense, BYD cloud, קהילה';

  @override
  String get integrationsLauncherTitle => 'סיכום Launcher';

  @override
  String get integrationsBydCloudTitle => 'BYD cloud';

  @override
  String get integrationsCommunityTitle => 'אוטומציות קהילה';

  @override
  String get integrationsHeadUnitNote =>
      'Android Auto / שיקוף למסך רכב אינו מיושם באפליקציה; ה־API של Launcher נשאר ברכב.';

  @override
  String get voicePttTitle => 'לחץ לדבר';

  @override
  String get voicePttHint => 'החזק את הכפתור בזמן דיבור; השמע נשלח לרכב.';

  @override
  String get voicePttHold => 'החזק לדיבור';

  @override
  String get voicePttConnecting => 'מתחבר…';

  @override
  String get voicePttLive => 'שידור חי';

  @override
  String get voicePttStopping => 'עוצר…';

  @override
  String get voicePttFailed => 'השיחה נכשלה';

  @override
  String get voiceCabinListenTitle => 'מיקרופון תא';

  @override
  String get voiceCabinIdle => 'כבוי';

  @override
  String get voiceCabinConnecting => 'מתחבר…';

  @override
  String get voiceCabinLive => 'מאזין';

  @override
  String get voiceCabinPaused => 'מושהה בזמן דיבור';

  @override
  String get voiceCabinError => 'שגיאת מאזין';

  @override
  String voiceCabinBytes(String bytes) {
    return 'התקבלו $bytes בתים';
  }

  @override
  String get voiceMicDenied => 'הרשאת מיקרופון נדחתה';

  @override
  String get voiceMicOpenSettings => 'פתח הגדרות לאישור מיקרופון';

  @override
  String get genAiVoiceTitle => 'קול בזמן אמת';

  @override
  String get genAiVoiceHint => 'פותח שיחת קול חיה דו־כיוונית עם העוזר.';

  @override
  String get genAiVoiceStart => 'התחלת שיחת קול';

  @override
  String get genAiVoiceStop => 'עצירת שיחת קול';

  @override
  String get genAiVoiceTruncate => 'קיטוע השמעה';

  @override
  String get platformAbrpTitle => 'ABRP';

  @override
  String get platformMqttTitle => 'MQTT';

  @override
  String get platformMqttAdd => 'הוספת חיבור';

  @override
  String get platformCommunityImport => 'ייבוא אוטומציה';

  @override
  String get platformSave => 'שמירה לרכב';

  @override
  String get platformDeleteToken => 'מחיקת אסימון ABRP';

  @override
  String get platformDestructiveWarning =>
      'פעולה זו משנה הגדרות ברכב — אשר לפני שליחה.';

  @override
  String get screenshotFixtureDisclaimer => 'צילום fixture — לא אימות רכב חי';

  @override
  String get settingsOpenDiagnostics =>
      'דיבוג מושב, יומנים, מאפייני רכב, ADAS, תאורה, RoadSense';

  @override
  String get integrationsDiagnosticsTitle => 'אבחון ו־RoadSense';

  @override
  String get integrationsDiagnosticsSubtitle =>
      'קריאות דיבוג, העלאת יומן ופעולות תחזוקת RoadSense';

  @override
  String get integrationsAdvancedDiagnosticsTitle => 'אבחון מתקדם';

  @override
  String get integrationsAdvancedDiagnosticsSubtitle =>
      'למתקדמים בלבד — פעולות הרסניות וקריאות דיבוג';

  @override
  String get diagnosticsAdvancedTitle => 'אבחון מתקדם';

  @override
  String get diagnosticsAdvancedWarning =>
      'כלים אלה משנים מצב ברכב או מעלים יומנים. השתמשו רק אם אתם מבינים את ההשלכות.';

  @override
  String get integrationsLoadingData => 'טוען מהרכב…';

  @override
  String get integrationsEmptyList => 'אין נתונים להצגה';

  @override
  String get integrationsEmptyParkingSessions => 'אין מפגשי חניה';

  @override
  String get integrationsEmptyTrips => 'אין נסיעות בהיסטוריה';

  @override
  String get integrationsRoadSenseTitle => 'RoadSense';

  @override
  String get diagnosticsHubTitle => 'אבחון';

  @override
  String get diagnosticsSeatTitle => 'דיבוג מושב';

  @override
  String get diagnosticsLogsTitle => 'יומני דמוון';

  @override
  String get diagnosticsLogsUnavailable => 'העלאת יומן לא זמינה בשרת';

  @override
  String get diagnosticsLogsUploadTitle => 'להעלות יומן דמוון?';

  @override
  String get diagnosticsLogsUpload => 'העלאה';

  @override
  String get diagnosticsCarPropertyTitle => 'דיבוג מאפייני רכב';

  @override
  String get diagnosticsPropertyKeyLabel => 'מפתח מאפיין (hex)';

  @override
  String get diagnosticsAdasTitle => 'דיבוג ADAS';

  @override
  String get diagnosticsLightTitle => 'דיבוג תאורת פנים';

  @override
  String get diagnosticsLightReadOnly =>
      'קריאה בלבד — כתיבה דורשת אישור בשרת הרכב.';

  @override
  String get diagnosticsRemoteKeyTitle => 'דיבוג מפתח מרחוק';

  @override
  String get diagnosticsAutoServiceTitle => 'דיבוג Auto service';

  @override
  String get roadSenseMapOnline => 'מפת OpenStreetMap (רשת)';

  @override
  String get roadSenseMapOfflineGrid =>
      'מפת רקע לא זמינה — מיקום מכשולים על רשת lat/lon';

  @override
  String roadSenseMapMarkersSummary(int count) {
    return '$count סימונים על המפה';
  }

  @override
  String get automationLabelSchemaVersion => 'גרסת סכימה';

  @override
  String get automationLabelSignals => 'אותות';

  @override
  String get automationLabelEngineState => 'מצב מנוע';

  @override
  String get automationLabelGlobalEnabled => 'פעיל גלובלית';

  @override
  String get roadSenseHazardCount => 'מכשולים פעילים';

  @override
  String get roadSenseSeverity => 'חומרת צליל';

  @override
  String get roadSenseChannel => 'ערוץ שמע';

  @override
  String get roadSenseVolumePercent => 'עוצמה %';

  @override
  String get roadSenseTestChime => 'בדיקת צליל';

  @override
  String get roadSenseDeleteLocalTitle => 'למחוק נתוני RoadSense מקומיים?';

  @override
  String get roadSenseDeleteLocalBody =>
      'מוחק אריחי מכשולים במטמון הרכב (הרסני).';

  @override
  String get roadSenseDeleteLocal => 'מחיקת נתונים מקומיים';

  @override
  String get roadSenseDeleteCloudTitle => 'למחוק נתוני RoadSense בענן?';

  @override
  String get roadSenseDeleteCloudBody => 'מבקש מחיקה בענן עבור הרכב (הרסני).';

  @override
  String get roadSenseDeleteCloud => 'מחיקת נתונים בענן';

  @override
  String get voiceFixtureUnsupported => 'הקול כבוי בהגדרות הרכב';

  @override
  String formatBytesBytes(int bytes) {
    return '$bytes ב׳';
  }

  @override
  String formatBytesKib(String size) {
    return '$size ק״ב';
  }

  @override
  String formatBytesMib(String size) {
    return '$size מ״ב';
  }

  @override
  String get releaseSigningDebugNote =>
      'בניית שחרור חתומה במפתח debug ל־CI/תצוגה בלבד — להפצה השתמשו בחתימת שחרור משלכם.';

  @override
  String get automationSettingsTitle => 'הגדרות אוטומציה';

  @override
  String get automationSchemaTitle => 'סכימה';

  @override
  String get automationGlobalEnabled => 'אוטומציות פעילות';

  @override
  String get automationStateTitle => 'מצב מנוע';

  @override
  String get automationEditTitle => 'עריכת אוטומציה';

  @override
  String get automationEnabledLabel => 'פעיל';

  @override
  String get automationModeLabel => 'מצב';

  @override
  String get automationRulesSection => 'כללים';

  @override
  String get automationActionsSection => 'פעולות';

  @override
  String get automationAddRule => 'הוספת כלל';

  @override
  String get automationAddAction => 'הוספת פעולה';

  @override
  String get automationSignalLabel => 'אות';

  @override
  String get automationOpLabel => 'אופרטור';

  @override
  String get automationValueLabel => 'ערך';

  @override
  String get parkingSignageTitle => 'שלט חניה';

  @override
  String get parkingSignageMessageLabel => 'טקסט שלט';

  @override
  String get parkingSignageEnabled => 'שלט פעיל';

  @override
  String get tripConfigTitle => 'מקליט נסיעות';

  @override
  String get tripConfigEnabled => 'הקלטת נסיעות';

  @override
  String get tripHistoryDaysLabel => 'חלון היסטוריה (ימים)';

  @override
  String get tripBootstrapTitle => 'אתחול מאגר נסיעות';

  @override
  String get tripBootstrapBody => 'בונה מחדש מטא־נתוני נסיעות ברכב.';

  @override
  String get tripDetailTitle => 'פרטי נסיעה';

  @override
  String get tripStartedLabel => 'התחלה';

  @override
  String get genAiRoutineAccept => 'אישור';

  @override
  String get genAiRoutineReject => 'דחייה';

  @override
  String get genAiActionTypeLabel => 'סוג פעולה';

  @override
  String get genAiActionTargetLabel => 'יעד (אופציונלי)';

  @override
  String get genAiActionValueLabel => 'ערך (אופציונלי)';

  @override
  String get genAiCreateIncidentTitle => 'יצירת חבילת אירוע';

  @override
  String get genAiCreateIncidentBody => 'אורזת ראיות ממצלמה לבדיקת GenAI ברכב.';

  @override
  String get genAiRecordingIdLabel => 'מזהה הקלטה';

  @override
  String get genAiRecordingIdRequired => 'הזן מזהה הקלטה';

  @override
  String get telegramPinTitle => 'צימוד עם PIN';

  @override
  String get telegramPinLabel => 'PIN לצימוד';

  @override
  String get telegramPinSubmit => 'שליחת PIN';

  @override
  String get launcherAppearanceTitle => 'מראה Launcher';

  @override
  String get bydCloudLoggedIn => 'מחובר';

  @override
  String get bydCloudConfigured => 'מוגדר — לא מחובר';

  @override
  String get mqttTelemetryTitle => 'טלמטריית MQTT';

  @override
  String get audioAvasTitle => 'השמעת AVAS';

  @override
  String get audioAvasPlaying => 'מנגן';

  @override
  String get audioAvasIdle => 'מושבת';

  @override
  String get huRemoteTitle => 'שליטה מרחוק במסך ראשי';

  @override
  String get huRemoteIntro =>
      'מקשי מעטפת, דמוון קול ושיקוף לוח — ההשפעה על מסכי הרכב.';

  @override
  String get huRemoteOpen => 'בקרות מסך ראשי';

  @override
  String get huShellSection => 'מעטפת מסך ראשי';

  @override
  String get huShellHint => 'שולח מקשי ניווט למסך הרכב (השפעה מרחוק).';

  @override
  String get huShellConfirmBody => 'מנווט את מסך הרכב — אשר רק אם מורשה.';

  @override
  String get huHome => 'בית';

  @override
  String get huBack => 'אחורה';

  @override
  String get huRecents => 'אחרונים';

  @override
  String get huDisplayId => 'מסך';

  @override
  String get huMoveX => 'היסט X';

  @override
  String get huMoveY => 'היסט Y';

  @override
  String get huMoveDisplayTitle => 'הזזת מסך';

  @override
  String get huVoiceSection => 'קול במסך ראשי';

  @override
  String get huVoiceConfirmBody => 'שמע או דיבור יופעלו ברמקולי הרכב.';

  @override
  String get huAudioFileLabel => 'שם קובץ שמע';

  @override
  String get huAudioFileHint => 'נתיב או שם מהספרייה ברכב';

  @override
  String get huPlayAudio => 'השמעה ברכב';

  @override
  String get huStopAudio => 'עצירת שמע ברכב';

  @override
  String get huSpeakText => 'טקסט לדיבור';

  @override
  String get huSpeak => 'דיבור';

  @override
  String get huMessageText => 'הודעה על המסך';

  @override
  String get huMessage => 'הצגת הודעה';

  @override
  String get huClusterSection => 'שיקוף לוח מחוונים';

  @override
  String get huClusterHint => 'מתחיל/עוצר שיקוף בלוח — התצוגה עדיין על חומרה.';

  @override
  String get huClusterAppPackage => 'חבילת אפליקציה (אופציונלי)';

  @override
  String get huClusterCastStart => 'התחלת שיקוף';

  @override
  String get huClusterCastStop => 'עצירת שיקוף';

  @override
  String get debugWriteSection => 'כתיבה (דורש אסימון אישור)';

  @override
  String get debugWriteTitle => 'לבצע כתיבת דיבוג?';

  @override
  String get debugWriteBody =>
      'כותב לרגיסטרים ברמה נמוכה — ערכים שגויים עלולים לפגוע בבטיחות.';

  @override
  String get debugWriteSubmit => 'החלת כתיבה';

  @override
  String get debugConfirmTokenLabel => 'אסימון אישור';

  @override
  String get debugConfirmTokenHint => 'נדרש טקסט מדויק בשרת (למשל YES)';

  @override
  String get debugRegisterLabel => 'רגיסטר';

  @override
  String get debugLightZoneLabel => 'אזור תאורה';

  @override
  String get debugLightLevelLabel => 'רמה (0–100)';
}
