import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/io_client.dart';
import 'package:overdrive_companion/data/real_vehicle_repository.dart';
import 'package:overdrive_server/overdrive_server.dart';

import '../support/mock_overdrive_server.dart';

void main() {
  late IOClient ioClient;

  setUpAll(() {
    HttpOverrides.global = _LoopbackHttpOverrides();
    ioClient = IOClient(HttpClient());
  });

  setUp(() async {
    await MockOverdriveServer.start();
  });

  tearDown(() async {
    await MockOverdriveServer.stop();
  });

  test('mock serves mp4 bytes at /video/id with JWT headers', () async {
    final base = MockOverdriveServer.baseUri!.toString();
    final client = OverdriveApiClient(
      baseUrl: base,
      jwt: 'test-jwt',
      httpClient: ioClient,
    );
    final repo = RealVehicleRepository(client);
    await repo.refreshRecordings();
    expect(repo.recordings, isNotEmpty);
    final fileId = repo.recordings.first.file;

    final bytes = await client.getBytes(OverdriveEndpoints.videoById(fileId));
    expect(bytes.length, greaterThan(100));
    expect(String.fromCharCodes(bytes.sublist(4, 8)), 'ftyp');
  });
}

class _LoopbackHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context);
  }
}
