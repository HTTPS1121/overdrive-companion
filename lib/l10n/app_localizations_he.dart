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
  String get accessCodeHelper => 'קוד בלבד — השרת מקבל deviceId-accessCode';

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
}
