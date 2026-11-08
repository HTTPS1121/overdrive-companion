import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive_companion/core/voice/cabin_audio_client.dart';
import 'package:overdrive_companion/core/voice/communicate_ptt_client.dart';
import 'package:overdrive_companion/core/voice/genai_voice_client.dart';

import '../support/voice_ws_mock_servers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('communicate PTT start/live/stop with fixture PCM', () async {
    final server = await startCommunicateMockServer();
    addTearDown(server.close);
    final client = CommunicatePttClient(
      baseUrl: 'http://127.0.0.1:${server.uri.port}',
      fixtureMic: true,
    );
    addTearDown(client.dispose);
    final phases = <String>[];
    client.events.listen((e) {
      if (e.phase != null) phases.add(e.phase!.name);
    });

    await client.pressDown();
    await Future<void>.delayed(const Duration(milliseconds: 250));
    expect(client.phase, CommunicateTalkPhase.live);
    await Future<void>.delayed(const Duration(milliseconds: 300));
    await client.pressUp();
    expect(phases, contains('live'));
  });

  test('cabin listener receives ready + PCM with test sink', () async {
    final server = await startCabinAudioMockServer();
    addTearDown(server.close);
    final client = CabinAudioClient(
      baseUrl: 'http://127.0.0.1:${server.uri.port}',
      useTestSink: true,
    );
    addTearDown(client.dispose);
    final states = <CabinListenerPhase>[];
    client.states.listen((s) => states.add(s.phase));
    await client.connect();
    await Future<void>.delayed(const Duration(milliseconds: 450));
    expect(states, contains(CabinListenerPhase.live));
    expect(client.testSink.totalBytes, greaterThan(0));
    await client.disconnect();
  });

  test('GenAI voice connected/live/stop with fixture mic and playback sink', () async {
    final server = await startGenAiVoiceMockServer();
    addTearDown(server.close);
    final client = GenAiVoiceClient(
      baseUrl: 'http://127.0.0.1:${server.uri.port}',
      fixtureMic: true,
      useTestPlayback: true,
    );
    addTearDown(client.dispose);
    await client.start();
    await Future<void>.delayed(const Duration(milliseconds: 400));
    expect(client.phase, GenAiVoicePhase.live);
    expect(client.playbackSink.totalBytes, greaterThanOrEqualTo(0));
    await client.stop();
    expect(client.phase, GenAiVoicePhase.idle);
  });
}
