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
      'אותו תהליך כמו login.html: כתובת מנהרה, מזהה מכשיר מהשרת, וקוד גישה.';

  @override
  String get connectionIntroLong =>
      'בדפדפן: פתח את כתובת המנהרה → login.html מציג Device ID → הזן קוד גישה.';

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
  String get deviceIdHelper => 'נטען מ־GET /auth/status (כמו login.html ברכב)';

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
  String get cameraLiveHelp =>
      'H.264 Annex-B על wss://host/ws?token=JWT — MediaCodec מקומי ב־Android.';

  @override
  String get cameraEnableStream => 'הפעל שידור';

  @override
  String get cameraDisableStream => 'כבה שידור';

  @override
  String get cameraSurveillanceTitle => 'מעקב / נהיגה';

  @override
  String get cameraRecordingsTitle => 'הקלטות';

  @override
  String get cameraViewMosaic => 'מוזאיקה (0)';

  @override
  String get cameraViewFront => 'קדמי (1)';

  @override
  String get cameraViewRight => 'ימין (2)';

  @override
  String get cameraViewRear => 'אחורי (3)';

  @override
  String get cameraViewLeft => 'שמאל (4)';

  @override
  String get cameraViewQualityMedium => 'איכות: MEDIUM';

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
    return 'תצוגה Q$q';
  }

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
}
