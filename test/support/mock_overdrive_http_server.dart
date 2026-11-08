import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

import 'mock_overdrive_backend.dart';

/// Standalone HTTP server mimicking core Overdrive vehicle endpoints.
class MockOverdriveHttpServer {
  MockOverdriveHttpServer(this.backend);

  final MockOverdriveBackend backend;
  HttpServer? _server;

  Future<int> start({int port = 18080}) async {
    final router = Router();

    router.get('/auth/status', (_) {
      return Response.ok(
        jsonEncode(backend.authStatus()),
        headers: _jsonHeaders,
      );
    });

    router.post('/auth/token', (Request request) async {
      final body = await _readJson(request);
      final token = body['token'] as String? ?? '';
      return Response.ok(jsonEncode(backend.login(token)), headers: _jsonHeaders);
    });

    router.get('/api/vehicle/state', (Request request) {
      if (!_authorized(request)) {
        return Response(401, body: '{"success":false,"error":"auth_required"}');
      }
      return Response.ok(jsonEncode(backend.vehicleState()), headers: _jsonHeaders);
    });

    router.get('/api/vehicle/cloud-status', (Request request) {
      if (!_authorized(request)) {
        return Response(401, body: '{"success":false,"error":"auth_required"}');
      }
      return Response.ok(
        jsonEncode(backend.cloudStatus().toJson()),
        headers: _jsonHeaders,
      );
    });

    router.get('/api/gps', (Request request) {
      if (!_authorized(request)) {
        return Response(401, body: '{"success":false,"error":"auth_required"}');
      }
      return Response.ok(
        jsonEncode(backend.gps().toJson()),
        headers: _jsonHeaders,
      );
    });

    for (final path in _postPaths) {
      router.post(path, (Request request) async {
        if (!_authorized(request)) {
          return Response(401, body: '{"success":false,"error":"auth_required"}');
        }
        final body = await _readJson(request);
        return Response.ok(
          jsonEncode(backend.handlePost(path, body)),
          headers: _jsonHeaders,
        );
      });
    }

    final handler = Pipeline()
        .addMiddleware(logRequests())
        .addHandler(router.call);

    _server = await shelf_io.serve(handler, InternetAddress.loopbackIPv4, port);
    return _server!.port;
  }

  Future<void> stop() async {
    await _server?.close(force: true);
    _server = null;
  }

  bool _authorized(Request request) {
    if (!backend.authRequired) return true;
    final auth = request.headers['authorization'] ?? '';
    if (auth.startsWith('Bearer ')) {
      return backend.authorize(auth.substring(7));
    }
    return false;
  }

  static Future<Map<String, dynamic>> _readJson(Request request) async {
    final raw = await request.readAsString();
    if (raw.isEmpty) return {};
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  static const _jsonHeaders = {'content-type': 'application/json; charset=utf-8'};

  static const _postPaths = [
    '/api/vehicle/lock',
    '/api/vehicle/unlock',
    '/api/vehicle/trunk',
    '/api/vehicle/window',
    '/api/vehicle/flash',
    '/api/vehicle/climate',
    '/api/vehicle/lights',
  ];
}
