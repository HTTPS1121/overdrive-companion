import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:overdrive_companion/core/voice/communicate_protocol.dart';
import 'package:overdrive_companion/core/voice/pcm_util.dart';

class VoiceWsMockHandle {
  VoiceWsMockHandle(this.uri, this._close);

  final Uri uri;
  final Future<void> Function() _close;
  int pcmFramesReceived = 0;
  int pcmBytesReceived = 0;

  Future<void> close() => _close();
}

/// Local `/ws/communicate` peer implementing upstream JSON + binary PCM rules.
Future<VoiceWsMockHandle> startCommunicateMockServer() async {
  var frames = 0;
  var bytes = 0;
  final handler = webSocketHandler((WebSocketChannel channel) {
    channel.sink.add(jsonEncode({
      'type': CommunicateJsonType.connected,
      'maxSeconds': 30,
    }));
    channel.stream.listen((message) {
      if (message is String) {
        Map<String, dynamic> json;
        try {
          json = jsonDecode(message) as Map<String, dynamic>;
        } catch (_) {
          return;
        }
        if (json['type'] == CommunicateJsonType.start) {
          final rate = json['sampleRate'];
          final fmt = json['format'];
          if (rate == CommunicateProtocol.pcmSampleRateHz && fmt == CommunicateProtocol.pcmFormat) {
            channel.sink.add(jsonEncode({
              'type': CommunicateJsonType.live,
              'sampleRate': CommunicateProtocol.pcmSampleRateHz,
              'maxSeconds': 30,
            }));
          } else {
            channel.sink.add(jsonEncode({
              'type': CommunicateJsonType.failed,
              'reason': 'Unsupported browser audio format',
            }));
          }
        } else if (json['type'] == CommunicateJsonType.stop) {
          channel.sink.add(jsonEncode({
            'type': CommunicateJsonType.stopped,
            'reason': json['reason'] ?? 'Released',
          }));
        }
      } else if (message is List<int>) {
        frames++;
        bytes += message.length;
        if (message.length > CommunicateProtocol.maxPcmFrameBytes || (message.length & 1) != 0) {
          channel.sink.add(jsonEncode({
            'type': CommunicateJsonType.failed,
            'reason': 'Invalid PCM WebSocket frame',
          }));
        }
      }
    });
  });

  final server = await shelf_io.serve(handler, InternetAddress.loopbackIPv4, 0);
  final uri = Uri.parse('ws://127.0.0.1:${server.port}/ws/communicate');
  return VoiceWsMockHandle(
    uri,
    () async {
      await server.close(force: true);
    },
  )..pcmFramesReceived = frames;
}

Future<VoiceWsMockHandle> startCabinAudioMockServer({bool talkPaused = false}) async {
  var bytesOut = 0;
  final handler = webSocketHandler((WebSocketChannel channel) {
    channel.sink.add(jsonEncode({
      'type': CabinAudioJsonType.starting,
      'sampleRate': 48000,
      'channels': 1,
      'format': CommunicateProtocol.pcmFormat,
    }));
    Timer.periodic(const Duration(milliseconds: 80), (timer) {
      if (talkPaused) return;
      final frame = silentPcmFrame(samples: 384);
      channel.sink.add(frame);
      bytesOut += frame.length;
    });
    Timer(const Duration(milliseconds: 120), () {
      channel.sink.add(jsonEncode({
        'type': CabinAudioJsonType.ready,
        'sampleRate': 48000,
      }));
    });
  });
  final server = await shelf_io.serve(handler, InternetAddress.loopbackIPv4, 0);
  final uri = Uri.parse('ws://127.0.0.1:${server.port}/ws/cabin-audio');
  return VoiceWsMockHandle(
    uri,
    () async => server.close(force: true),
  );
}

Future<VoiceWsMockHandle> startGenAiVoiceMockServer() async {
  var pcmIn = 0;
  final handler = webSocketHandler((WebSocketChannel channel) {
    channel.sink.add(jsonEncode({
      'type': GenAiVoiceJsonType.connected,
      'inputSampleRate': 24000,
      'outputSampleRate': 24000,
      'maxSeconds': 600,
    }));
    Timer(const Duration(milliseconds: 30), () {
      channel.sink.add(jsonEncode({
        'type': GenAiVoiceJsonType.live,
        'inputSampleRate': 24000,
        'outputSampleRate': 24000,
      }));
    });
    channel.stream.listen((message) {
      if (message is List<int>) {
        pcmIn += message.length;
        if (pcmIn > 0 && pcmIn % 4800 < message.length) {
          channel.sink.add(silentPcmFrame(samples: 480));
        }
      } else if (message is String) {
        final json = jsonDecode(message) as Map<String, dynamic>;
        if (json['type'] == GenAiVoiceJsonType.stop) {
          channel.sink.add(jsonEncode({
            'type': GenAiVoiceJsonType.stopped,
            'reason': json['reason'],
          }));
        }
      }
    });
  });
  final server = await shelf_io.serve(handler, InternetAddress.loopbackIPv4, 0);
  final uri = Uri.parse('ws://127.0.0.1:${server.port}/ws/genai?lang=en');
  return VoiceWsMockHandle(
    uri,
    () async => server.close(force: true),
  );
}
