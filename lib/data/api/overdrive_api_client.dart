import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/config/app_settings.dart';
import '../repositories/overdrive_endpoints.dart';

class OverdriveApiException implements Exception {
  OverdriveApiException(this.message, {this.statusCode, this.authRequired = false});

  final String message;
  final int? statusCode;
  final bool authRequired;

  @override
  String toString() => message;
}

class OverdriveApiClient {
  OverdriveApiClient({
    required this.baseUrl,
    this.jwt,
    http.Client? httpClient,
  }) : _http = httpClient ?? http.Client();

  String baseUrl;
  String? jwt;
  final http.Client _http;

  Uri _uri(String path) {
    final normalized = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    return Uri.parse('$normalized$path');
  }

  Map<String, String> _headers({bool jsonBody = false}) {
    return {
      if (jsonBody) 'Content-Type': 'application/json',
      if (jwt != null && jwt!.isNotEmpty) 'Authorization': 'Bearer $jwt',
    };
  }

  Future<Map<String, dynamic>> getJson(String path) async {
    final response = await _http.get(_uri(path), headers: _headers());
    return _decode(response);
  }

  Future<Map<String, dynamic>> postJson(
    String path, {
    Map<String, dynamic> body = const {},
  }) async {
    final response = await _http.post(
      _uri(path),
      headers: _headers(jsonBody: true),
      body: jsonEncode(body),
    );
    return _decode(response);
  }

  Map<String, dynamic> _decode(http.Response response) {
    Map<String, dynamic> json;
    try {
      json = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw OverdriveApiException(
        'תגובה לא תקינה מהשרת (${response.statusCode})',
        statusCode: response.statusCode,
      );
    }

    if (response.statusCode == 401) {
      throw OverdriveApiException(
        json['error'] as String? ?? 'נדרש אימות',
        statusCode: 401,
        authRequired: true,
      );
    }

    if (response.statusCode >= 400) {
      throw OverdriveApiException(
        json['error'] as String? ?? 'שגיאת שרת ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }

    return json;
  }

  Future<void> loginWithDeviceToken(String token) async {
    final result = await postJson(
      OverdriveEndpoints.authToken,
      body: {'token': token},
    );
    if (result['success'] != true) {
      throw OverdriveApiException(result['error'] as String? ?? 'אימות נכשל');
    }
    final session = result['token'] as String?;
    if (session == null || session.isEmpty) {
      throw OverdriveApiException('לא התקבל JWT');
    }
    jwt = session;
  }

  Future<Map<String, dynamic>> testConnection() async {
    return getJson(OverdriveEndpoints.authStatus);
  }
}

/// Normalize user-entered base URL (add scheme, strip trailing slash).
String normalizeBaseUrl(String input) {
  var url = input.trim();
  if (url.isEmpty) return url;
  if (!url.startsWith('http://') && !url.startsWith('https://')) {
    url = 'http://$url';
  }
  while (url.endsWith('/')) {
    url = url.substring(0, url.length - 1);
  }
  return url;
}

ConnectionMode connectionModeFromSettings(AppSettings s) => s.connectionMode;
