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
  ConnectionFailure(this.kind, {this.detail, this.cause});

  final ConnectionFailureKind kind;
  final String? detail;
  final Object? cause;

  @override
  String toString() => detail ?? kind.name;

  static ConnectionFailure fromApi(OverdriveApiException e) {
    final msg = e.message.toLowerCase();
    if (e.authRequired || msg.contains('auth required')) {
      return ConnectionFailure(
        ConnectionFailureKind.sessionExpired,
        detail: e.message,
        cause: e,
      );
    }
    if (msg.contains('rate') || msg.contains('too many')) {
      return ConnectionFailure(
        ConnectionFailureKind.rateLimited,
        detail: e.message,
        cause: e,
      );
    }
    if (msg.contains('html') || msg.contains('<!doctype')) {
      return ConnectionFailure(
        ConnectionFailureKind.htmlResponse,
        detail: e.message,
        cause: e,
      );
    }
    if (msg.contains('invalid json') || msg.contains('not json')) {
      return ConnectionFailure(
        ConnectionFailureKind.notJson,
        detail: e.message,
        cause: e,
      );
    }
    if (msg.contains('auth') || msg.contains('invalid') || msg.contains('token')) {
      return ConnectionFailure(
        ConnectionFailureKind.authRejected,
        detail: e.message,
        cause: e,
      );
    }
    if (msg.contains('device id')) {
      return ConnectionFailure(
        ConnectionFailureKind.deviceIdMissing,
        detail: e.message,
        cause: e,
      );
    }
    return ConnectionFailure(ConnectionFailureKind.unknown, detail: e.message, cause: e);
  }
}
