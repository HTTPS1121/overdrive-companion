import 'package:overdrive_server/overdrive_server.dart';

String hebrewConnectionFailure(ConnectionFailure f) {
  return switch (f.kind) {
    ConnectionFailureKind.incompleteFields => 'מלא את כתובת השרת ואת פרטי הגישה.',
    ConnectionFailureKind.tunnelUnreachable =>
      'לא ניתן להגיע לשרת. בדוק את כתובת המנהרה או את הרשת.',
    ConnectionFailureKind.notJson => 'השרת החזיר תשובה שאינה JSON תקין.',
    ConnectionFailureKind.htmlResponse =>
      'השרת החזיר דף HTML — בדוק שכתובת המנהרה נכונה.',
    ConnectionFailureKind.deviceIdMissing => 'חסר מזהה מכשיר מהשרת.',
    ConnectionFailureKind.authRejected => 'אימות נדחה. בדוק את קוד הגישה.',
    ConnectionFailureKind.rateLimited => 'יותר מדי ניסיונות. המתן ונסה שוב.',
    ConnectionFailureKind.sessionExpired => 'פג תוקף ההתחברות. התחבר מחדש.',
    ConnectionFailureKind.unknown => f.detail ?? 'שגיאת חיבור לא ידועה.',
  };
}

String hebrewAuthDenied() => 'אימות נדחה. בדוק את קוד הגישה.';

String hebrewStaleVehicleLabel(DateTime lastOk) {
  final age = DateTime.now().difference(lastOk);
  if (age.inMinutes < 2) return 'נתונים לא מעודכנים · עודכן זה עתה';
  if (age.inMinutes < 60) return 'נתונים לא מעודכנים · עודכן לפני ${age.inMinutes} דק׳';
  if (age.inHours < 24) return 'נתונים לא מעודכנים · עודכן לפני ${age.inHours} שע׳';
  return 'נתונים לא מעודכנים · עודכן לפני ${age.inDays} ימים';
}

String hebrewApiException(OverdriveApiException e) {
  final code = e.statusCode;
  if (code == 401) {
    return e.authRequired ? 'נדרש אימות מחדש מול השרת.' : hebrewAuthDenied();
  }
  if (e.authRequired) {
    return 'נדרש אימות מחדש מול השרת.';
  }
  if (code == 404) {
    return 'הפקודה אינה נתמכת בשרת זה.';
  }
  if (code != null && code >= 500) {
    return 'שגיאת שרת ($code). נסה שוב מאוחר יותר.';
  }
  final msg = e.message.toLowerCase();
  if (msg.contains('timeout') || msg.contains('timed out')) {
    return 'התקבלה פסקת זמן מהשרת. נסה שוב.';
  }
  return e.message.isNotEmpty ? e.message : 'בקשה לשרת נכשלה.';
}

String hebrewForTimeout() => 'התקבלה פסקת זמן מהשרת. נסה שוב.';

String hebrewForOffline() => 'אין חיבור לשרת הרכב. בדוק רשת או מנהרה.';

String hebrewServerUnsupported() =>
    'השרת לא זוהה כ-Overdrive (תשובת /auth/status לא תקינה).';

String hebrewRecordingsLoadError() => 'לא ניתן לטעון הקלטות מהשרת.';

String hebrewStreamUnavailable() => 'אין שידור חי מהמצלמות כרגע.';

String hebrewTripsEmpty() => 'אין נסיעות להצגה מהשרת.';

String hebrewTripsTodayEmpty() => 'אין נסיעות היום מהשרת.';

String hebrewParkingEventsEmpty() => 'אין אירועי חניה מהשרת.';

String hebrewFeatureNotOnServer() => 'לא נתמך עדיין בשרת';

String hebrewNoServerValue() => 'אין נתון מהשרת';

String hebrewCommandRejected(String? serverMessage) {
  if (serverMessage != null && serverMessage.trim().isNotEmpty) {
    return serverMessage.trim();
  }
  return 'הרכב לא אישר את הפקודה.';
}
