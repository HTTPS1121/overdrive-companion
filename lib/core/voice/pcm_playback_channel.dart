import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Native PCM playback via Android `AudioTrack` (48 kHz cabin / 24 kHz GenAI).
class PcmPlaybackChannel {
  static const _channel = MethodChannel('com.https1121.overdrive.companion/pcm_audio');

  static Future<void> start({required int sampleRate, String label = 'default'}) async {
    if (kIsWeb) return;
    await _channel.invokeMethod<void>('start', {
      'sampleRate': sampleRate,
      'label': label,
    });
  }

  static Future<void> write(Uint8List pcm) async {
    if (kIsWeb) return;
    await _channel.invokeMethod<void>('write', {'data': pcm});
  }

  static Future<void> stop() async {
    if (kIsWeb) return;
    await _channel.invokeMethod<void>('stop');
  }
}

/// Records bytes for unit/protocol tests (no speaker).
class TestPcmPlaybackSink {
  TestPcmPlaybackSink();

  int sampleRate = 48000;
  final List<Uint8List> chunks = [];
  var totalBytes = 0;

  Future<void> start({required int sampleRate, String label = 'test'}) async {
    this.sampleRate = sampleRate;
    chunks.clear();
    totalBytes = 0;
  }

  Future<void> write(Uint8List pcm) async {
    chunks.add(Uint8List.fromList(pcm));
    totalBytes += pcm.length;
  }

  Future<void> stop() async {}
}
