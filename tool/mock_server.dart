import 'dart:io';

import '../test/support/mock_overdrive_backend.dart';
import '../test/support/mock_overdrive_http_server.dart';

/// Local mock Overdrive HTTP server for development.
///
/// Usage: dart run tool/mock_server.dart [--port 18080] [--auth]
Future<void> main(List<String> args) async {
  var port = 18080;
  var auth = false;
  for (var i = 0; i < args.length; i++) {
    if (args[i] == '--port' && i + 1 < args.length) {
      port = int.parse(args[i + 1]);
    }
    if (args[i] == '--auth') auth = true;
  }

  final backend = await MockOverdriveBackend.fromFixture();
  backend.authRequired = auth;
  final server = MockOverdriveHttpServer(backend);
  final bound = await server.start(port: port);
  // ignore: avoid_print
  print('Mock Overdrive listening on http://127.0.0.1:$bound');
  // ignore: avoid_print
  print('Try: curl http://127.0.0.1:$bound/auth/status');
  await ProcessSignal.sigint.watch().first;
  await server.stop();
}
