import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:record/record.dart';

import 'pcm_util.dart';

abstract class MicCapture {
  Future<void> start({required int sampleRate});
  Stream<Uint8List> get pcmFrames;
  Future<void> stop();
  Future<void> dispose() async => stop();
}

/// Live device microphone — not used in CI fixture tests.
class RecordMicCapture implements MicCapture {
  RecordMicCapture(this._record);

  final AudioRecorder _record;
  StreamSubscription<Uint8List>? _sub;
  final _controller = StreamController<Uint8List>.broadcast();

  @override
  Stream<Uint8List> get pcmFrames => _controller.stream;

  @override
  Future<void> start({required int sampleRate}) async {
    await stop();
    final stream = await _record.startStream(
      RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: sampleRate,
        numChannels: 1,
        bitRate: sampleRate * 16,
      ),
    );
    _sub = stream.listen((chunk) {
      if (chunk.isNotEmpty) _controller.add(chunk);
    });
  }

  @override
  Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
    if (await _record.isRecording()) {
      await _record.stop();
    }
  }

  @override
  Future<void> dispose() async {
    await stop();
    await _record.dispose();
    await _controller.close();
  }
}

/// Feeds prerecorded PCM frames (tests / screenshot harness).
class FixtureMicCapture implements MicCapture {
  FixtureMicCapture({this.frames = const []});

  List<Uint8List> frames;
  Timer? _timer;
  final _controller = StreamController<Uint8List>.broadcast();
  var _index = 0;

  @override
  Stream<Uint8List> get pcmFrames => _controller.stream;

  @override
  Future<void> start({required int sampleRate}) async {
    await stop();
    _index = 0;
    if (frames.isEmpty) {
      frames = [silentPcmFrame(samples: sampleRate ~/ 10)];
    }
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (_index >= frames.length) _index = 0;
      _controller.add(frames[_index++]);
    });
  }

  @override
  Future<void> stop() async {
    _timer?.cancel();
    _timer = null;
  }

  @override
  Future<void> dispose() async {
    await stop();
    if (!_controller.isClosed) await _controller.close();
  }
}

Future<MicCapture> createMicCapture({required bool fixtureMode}) async {
  if (fixtureMode || kIsWeb) {
    return FixtureMicCapture();
  }
  final record = AudioRecorder();
  if (!await record.hasPermission()) {
    throw StateError('microphone permission not granted');
  }
  return RecordMicCapture(record);
}
