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
  String get tunnelUrlLabel => 'כתובת מנהרה (HTTPS)';

  @override
  String get deviceIdLabel => 'מזהה מכשיר';

  @override
  String get deviceIdHint => 'לחץ רענן לאחר הזנת כתובת המנהרה';

  @override
  String get accessCodeLabel => 'קוד גישה';

  @override
  String get accessCodeHelper =>
      'קוד בלבד — האפליקציה שולחת deviceId-accessCode ל־/auth/token';

  @override
  String get connectSave => 'התחבר ושמור';

  @override
  String get errorHtmlTunnel =>
      'השרת החזיר HTML במקום JSON. בדוק את כתובת המנהרה.';

  @override
  String get errorAuthRejected =>
      'קוד הגישה לא התקבל. רענן מזהה מכשיר ונסה שוב.';
}
