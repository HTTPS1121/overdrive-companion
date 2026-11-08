import '../../data/api/overdrive_api_client.dart';

enum ConnectionFailureKind {
  incompleteFields,
  tunnelUnreachable,
  notJson,
  htmlResponse,
  deviceIdMissing,
  authRejected,
  rateLimited,
  sessionExpired,
  unknown,
}

class ConnectionFailure implements Exception {
  ConnectionFailure(this.kind, this.messageHe, {this.cause});

  final ConnectionFailureKind kind;
  final String messageHe;
  final Object? cause;

  @override
  String toString() => messageHe;

  static ConnectionFailure fromApi(OverdriveApiException e) {
    final msg = e.message.toLowerCase();
    if (e.authRequired) {
      return ConnectionFailure(
        ConnectionFailureKind.sessionExpired,
        'פג תוקף ההתחברות — הזן שוב את קוד הגישה ולחץ התחבר.',
        cause: e,
      );
    }
    if (msg.contains('rate') || msg.contains('יותר מדי')) {
      return ConnectionFailure(
        ConnectionFailureKind.rateLimited,
        'יותר מדי ניסיונות התחברות. המתן דקה ונסה שוב.',
        cause: e,
      );
    }
    if (msg.contains('html') || msg.contains('<!doctype')) {
      return ConnectionFailure(
        ConnectionFailureKind.htmlResponse,
        'השרת החזיר דף HTML במקום JSON — בדוק שכתובת המנהרה מצביעה לשרת Overdrive ולא לדף שגיאה של ספק המנהרה.',
        cause: e,
      );
    }
    if (msg.contains('json') || msg.contains('תגובה לא תקינה')) {
      return ConnectionFailure(
        ConnectionFailureKind.notJson,
        e.message,
        cause: e,
      );
    }
    if (msg.contains('אימות') || msg.contains('invalid') || msg.contains('token')) {
      return ConnectionFailure(
        ConnectionFailureKind.authRejected,
        'קוד הגישה לא התקבל — ודא מזהה מכשיר מעודכן וקוד מלא כפי שמוצג במסך ההתחברות ברכב.',
        cause: e,
      );
    }
    return ConnectionFailure(ConnectionFailureKind.unknown, e.message, cause: e);
  }
}
