import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:overdrive_server/overdrive_server.dart';

import 'hebrew_errors.dart';

/// Maps any transport/parsing failure to user-facing Hebrew (repository boundary).
String hebrewFromAnyError(Object error) {
  if (error is TimeoutException) return hebrewForTimeout();
  if (error is OverdriveApiException) return hebrewApiException(error);
  if (error is SocketException || error is http.ClientException) {
    return hebrewForOffline();
  }
  if (error is HandshakeException || error is TlsException) {
    return 'שגיאת אבטחת חיבור (TLS). בדוק את כתובת השרת.';
  }
  if (error is FormatException) {
    return 'תשובה לא תקינה מהשרת.';
  }
  return hebrewForOffline();
}

bool isTransportFailure(Object error) {
  return error is TimeoutException ||
      error is SocketException ||
      error is http.ClientException ||
      error is HandshakeException ||
      error is TlsException ||
      error is FormatException;
}
