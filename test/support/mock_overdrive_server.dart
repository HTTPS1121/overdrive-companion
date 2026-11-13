import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;

/// Minimal Overdrive HTTP mock for widget tests only — not shipped.
class MockOverdriveServer {
  MockOverdriveServer._();

  static HttpServer? _server;
  static Uri? baseUri;
  static String mode = 'ok';

  static Future<Uri> start() async {
    if (baseUri != null) return baseUri!;
    final stateJson = await rootBundle.loadString('fixtures/vehicle_state_sample.json');
    final authStatus = await rootBundle.loadString('fixtures/auth_status.json');
    final tokenOk = await rootBundle.loadString('fixtures/auth_token_success.json');
    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final port = _server!.port;
    baseUri = Uri.parse('http://127.0.0.1:$port');
    _server!.listen((request) async {
      final path = request.uri.path;
      if (path == '/auth/status') {
        await _json(request, authStatus, 200);
        return;
      }
      if (path == '/auth/token') {
        if (mode == 'auth_fail') {
          await _json(request, '{"success":false,"error":"invalid token"}', 401);
          return;
        }
        await _json(request, tokenOk, 200);
        return;
      }
      if (path == '/api/vehicle/state') {
        if (mode == 'timeout') {
          await Future<void>.delayed(const Duration(seconds: 60));
          return;
        }
        if (mode == 'offline') {
          request.response.close();
          return;
        }
        await _json(request, stateJson, mode == 'not_json' ? 200 : 200);
        if (mode == 'not_json') {
          request.response.write('<html>error</html>');
        }
        return;
      }
      if (path.startsWith('/api/vehicle/')) {
        if (mode == 'unsupported') {
          await _json(request, '{"error":"unsupported"}', 404);
          return;
        }
        if (mode == 'fail') {
          await _json(
            request,
            '{"success":false,"commandSuccess":false,"error":"הרכב דחה את הבקשה"}',
            200,
          );
          return;
        }
        await _json(request, await rootBundle.loadString('fixtures/command_lock_confirmed.json'), 200);
        return;
      }
      if (path == '/api/recordings') {
        await _json(request, '{"recordings":[]}', 200);
        return;
      }
      if (path == '/api/stream/status') {
        await _json(request, '{"active":false}', 200);
        return;
      }
      await _json(request, '{"error":"not found"}', 404);
    });
    return baseUri!;
  }

  static Future<void> stop() async {
    await _server?.close(force: true);
    _server = null;
    baseUri = null;
  }

  static Future<void> _json(HttpRequest request, String body, int status) async {
    request.response.statusCode = status;
    request.response.headers.contentType = ContentType.json;
    request.response.write(body);
    await request.response.close();
  }
}
