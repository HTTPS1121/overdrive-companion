import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

import 'mock_overdrive_backend.dart';

/// Localhost HTTP server using Shelf + real `HttpClient` (not injected client mocks).
class LocalOverdriveHttpServer {
  LocalOverdriveHttpServer(this._backend);

  final MockOverdriveBackend _backend;
  HttpServer? _server;
  late String baseUrl;

  Future<void> start() async {
    _server = await shelf_io.serve(_handler, InternetAddress.loopbackIPv4, 0);
    final port = _server!.port;
    baseUrl = 'http://127.0.0.1:$port';
  }

  Future<void> stop() async {
    await _server?.close(force: true);
    _server = null;
  }

  Future<Response> _handler(Request request) async {
    var fullPath = '/${request.url.path}';
    if (request.url.hasQuery) {
      fullPath = '$fullPath?${request.url.query}';
    }
    final auth = request.headers['authorization'];
    String? bearer;
    if (auth != null && auth.toLowerCase().startsWith('bearer ')) {
      bearer = auth.substring(7);
    }

    if (fullPath == '/auth/status' && request.method == 'GET') {
      return _json(200, _backend.authStatus());
    }
    if (fullPath == '/auth/token' && request.method == 'POST') {
      final body = await request.readAsString();
      final map = jsonDecode(body) as Map<String, dynamic>;
      return _json(200, _backend.login(map['token'] as String? ?? ''));
    }

    if (!_backend.authorize(bearer) && _backend.authRequired) {
      return _json(401, {'success': false, 'error': 'auth required'});
    }

    if (request.method == 'GET') {
      final data = _backend.handleGet(fullPath.split('?').first);
      if (data['success'] == false && data.containsKey('error')) {
        return _json(404, data);
      }
      return _json(200, data);
    }
    if (request.method == 'POST') {
      final body = await request.readAsString();
      final map = body.isEmpty ? <String, dynamic>{} : jsonDecode(body) as Map<String, dynamic>;
      return _json(200, _backend.handlePost(fullPath, map));
    }
    if (request.method == 'DELETE') {
      if (fullPath == '/api/wireguard/config') {
        return _json(200, _backend.deleteWireGuardConfig());
      }
      return _json(405, {'success': false, 'error': 'delete not supported'});
    }
    return _json(405, {'success': false, 'error': 'method not allowed'});
  }

  Response _json(int status, Map<String, dynamic> body) => Response(
        status,
        body: jsonEncode(body),
        headers: {'Content-Type': 'application/json'},
      );
}
