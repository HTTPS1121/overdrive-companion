import 'dart:convert';

import 'package:http/http.dart' as http;

import '../auth/tunnel_credentials.dart';
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

  Uri uri(String path) {
    final normalized = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    return Uri.parse('$normalized$path');
  }

  Uri _uri(String path) => uri(path);

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

  Future<List<int>> getBytes(
    String path, {
    Map<String, String>? extraHeaders,
    int? offset,
    int? length,
  }) async {
    final headers = {..._headers(), ...?extraHeaders};
    if (offset != null || length != null) {
      final end = length != null && offset != null ? offset + length - 1 : null;
      headers['Range'] = 'bytes=$offset-${end ?? ''}';
    }
    final response = await _http.get(_uri(path), headers: headers);
    if (response.statusCode == 401) {
      throw OverdriveApiException('auth required', statusCode: 401, authRequired: true);
    }
    if (response.statusCode >= 400) {
      throw OverdriveApiException('server error ${response.statusCode}', statusCode: response.statusCode);
    }
    return response.bodyBytes;
  }

  Future<Map<String, dynamic>> deleteJson(String path) async {
    final response = await _http.delete(_uri(path), headers: _headers());
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
    final credentialCheck = path == OverdriveEndpoints.authToken;
    return _decode(response, credentialFailure: credentialCheck);
  }

  Future<Map<String, dynamic>> putJson(
    String path, {
    Map<String, dynamic> body = const {},
  }) async {
    final response = await _http.put(
      _uri(path),
      headers: _headers(jsonBody: true),
      body: jsonEncode(body),
    );
    return _decode(response);
  }

  Map<String, dynamic> _decode(
    http.Response response, {
    bool credentialFailure = false,
  }) {
    final body = response.body;
    final trimmed = body.trimLeft();
    if (trimmed.startsWith('<!') || trimmed.startsWith('<html')) {
      throw OverdriveApiException(
        'server returned HTML (${response.statusCode}) — check tunnel URL',
        statusCode: response.statusCode,
      );
    }

    Map<String, dynamic> json;
    try {
      final parsed = jsonDecode(body);
      if (parsed is! Map<String, dynamic>) {
        throw const FormatException('not an object');
      }
      json = parsed;
    } catch (_) {
      throw OverdriveApiException(
        'invalid JSON from server (${response.statusCode})',
        statusCode: response.statusCode,
      );
    }

    if (response.statusCode == 401) {
      throw OverdriveApiException(
        json['error'] as String? ?? 'auth required',
        statusCode: 401,
        authRequired: !credentialFailure,
      );
    }

    if (response.statusCode >= 400) {
      throw OverdriveApiException(
        json['error'] as String? ?? 'server error ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }

    return json;
  }

  /// Public endpoint — no JWT (AuthApiHandler PUBLIC_PATHS).
  Future<AuthStatusResult> fetchAuthStatus() async {
    final json = await getJson(OverdriveEndpoints.authStatus);
    return AuthStatusResult.fromJson(json);
  }

  Future<void> loginWithDeviceToken(String token) async {
    final result = await postJson(
      OverdriveEndpoints.authToken,
      body: {'token': token},
    );
    if (result['success'] != true) {
      throw OverdriveApiException(result['error'] as String? ?? 'auth failed');
    }
    final session = (result['jwt'] ?? result['token']) as String?;
    if (session == null || session.isEmpty) {
      throw OverdriveApiException('missing jwt in response');
    }
    jwt = session;
  }

  /// PWA flow: status.deviceId + access code → full token.
  Future<void> loginWithAccessCode({
    required String deviceId,
    required String accessCode,
  }) async {
    if (deviceId.trim().isEmpty) {
      throw OverdriveApiException('device id missing from tunnel');
    }
    if (!isPlausibleAccessCode(accessCode)) {
      throw OverdriveApiException('access code too short (min 8 chars)');
    }
    await loginWithDeviceToken(
      composeDeviceToken(deviceId: deviceId, accessCode: accessCode),
    );
  }

  Future<AuthStatusResult> testConnection() async {
    final json = await getJson(OverdriveEndpoints.authStatus);
    return AuthStatusResult.fromJson(json);
  }

  Uri recordingVideoUri(String recordingId) => _uri(OverdriveEndpoints.videoById(recordingId));

  Uri recordingThumbUri(String recordingId) => _uri(OverdriveEndpoints.thumbById(recordingId));

  Map<String, String> authHeaders() => _headers();
}

class AuthStatusResult {
  AuthStatusResult({
    required this.ok,
    this.deviceId,
    this.raw = const {},
  });

  factory AuthStatusResult.fromJson(Map<String, dynamic> json) {
    final ok = json['status'] == 'ok' || json['success'] == true;
    final id = json['deviceId']?.toString();
    return AuthStatusResult(
      ok: ok,
      deviceId: (id != null && id != 'unknown' && id.isNotEmpty) ? id : null,
      raw: json,
    );
  }

  final bool ok;
  final String? deviceId;
  final Map<String, dynamic> raw;
}

/// Normalize user-entered base URL (add scheme, strip trailing slash).
String normalizeBaseUrl(String input) {
  var url = input.trim();
  if (url.isEmpty) return url;
  if (!url.startsWith('http://') && !url.startsWith('https://')) {
    url = 'https://$url';
  }
  while (url.endsWith('/')) {
    url = url.substring(0, url.length - 1);
  }
  return url;
}

/// True for explicit `http://` to a non-TLS endpoint (local/LAN use only).
bool isLocalHttpUrl(String input) {
  final n = normalizeBaseUrl(input);
  if (!n.startsWith('http://')) return false;
  final host = Uri.tryParse(n)?.host.toLowerCase() ?? '';
  if (host == 'localhost' || host == '127.0.0.1') return true;
  if (host.startsWith('192.168.') || host.startsWith('10.')) return true;
  if (host.startsWith('172.')) {
    final parts = host.split('.');
    if (parts.length >= 2) {
      final second = int.tryParse(parts[1]);
      if (second != null && second >= 16 && second <= 31) return true;
    }
  }
  return n.startsWith('http://');
}
