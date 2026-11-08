import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive_companion/core/stream/h264_annex_b.dart';
import 'package:overdrive_companion/core/stream/h264_live_controller.dart';
import 'package:overdrive_companion/data/models/camera_models.dart';

import '../support/fixture_api_client.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('ws url uses wss and token query like stream.js', () {
    final c = H264LiveController(baseUrl: 'https://car.example.com', jwt: 'jwt.test');
    final url = c.buildWsUrl();
    expect(url, 'wss://car.example.com/ws?token=jwt.test');
  });

  test('annex-b keyframe detection', () {
    final idr = Uint8List.fromList([0, 0, 0, 1, 0x65, 0x88]);
    expect(H264AnnexB.isKeyframe(idr), isTrue);
    expect(H264AnnexB.isConfig(Uint8List.fromList([0, 0, 0, 1, 0x67])), isTrue);
  });

  test('fixture recordings expose media id for /video/id/', () async {
    final client = await FixtureOverdriveApiClient.create();
    final json = await client.getJson('/api/recordings');
    final list = RecordingsListState.fromJson(json);
    expect(list.recordings.single.canonicalRecordingId, 'a1b2c3d4e5f6789012345678abcdef01');
    final bytes = await client.getBytes('/video/id/${list.recordings.single.canonicalRecordingId}');
    expect(bytes, isNotEmpty);
  });

  test('fixture surveillance config and snapshot bytes', () async {
    final client = await FixtureOverdriveApiClient.create();
    final cfg = await client.getJson('/api/surveillance/config');
    expect(cfg['sensitivity'], 3);
    final snap = await client.getBytes('/api/surveillance/snapshot/0');
    expect(snap.first, 0xFF);
    expect(snap[1], 0xD8);
  });
}
