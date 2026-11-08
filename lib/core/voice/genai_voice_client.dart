import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:web_socket_channel/web_socket_channel.dart';

import 'communicate_protocol.dart';
import 'mic_capture.dart';
import 'pcm_playback_channel.dart';
import 'pcm_util.dart';

enum GenAiVoicePhase { idle, connecting, live, stopping, failed }

class GenAiVoiceEvent {
  GenAiVoiceEvent.phase(this.phase) : reason = null, transcript = null;
  GenAiVoiceEvent.failed(this.reason) : phase = GenAiVoicePhase.failed, transcript = null;
  GenAiVoiceEvent.transcript(this.transcript) : phase = GenAiVoicePhase.live, reason = null;

  final GenAiVoicePhase? phase;
  final String? reason;
  final String? transcript;
}

/// Realtime voice bridge matching upstream `genai.js` + `GenAiVoiceWebSocket`.
class GenAiVoiceClient {
  GenAiVoiceClient({
    required this.baseUrl,
    this.jwt,
    this.language = 'en',
    MicCapture? mic,
    this.fixtureMic = false,
    this.useTestPlayback = false,
  }) : _mic = mic;

  final String baseUrl;
  final String? jwt;
  final String language;
  final bool fixtureMic;
  final bool useTestPlayback;

  MicCapture? _mic;
  WebSocketChannel? _channel;
  StreamSubscription<Object?>? _inbound;
  StreamSubscription<Uint8List>? _micSub;

  var _phase = GenAiVoicePhase.idle;
  var _generation = 0;
  var _inputRate = 24000;
  var _outputRate = 24000;
  var _voiceItemId = '';
  var _voiceItemContentIndex = 0;
  final _events = StreamController<GenAiVoiceEvent>.broadcast();
  final TestPcmPlaybackSink _playbackSink = TestPcmPlaybackSink();

  Stream<GenAiVoiceEvent> get events => _events.stream;
  GenAiVoicePhase get phase => _phase;
  TestPcmPlaybackSink get playbackSink => _playbackSink;

  Uri voiceUri() {
    final root = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final wsRoot = root.replaceFirst('https://', 'wss://').replaceFirst('http://', 'ws://');
    final parts = <String>['lang=${Uri.encodeQueryComponent(language)}'];
    if (jwt != null && jwt!.isNotEmpty) {
      parts.add('token=${Uri.encodeQueryComponent(jwt!)}');
    }
    return Uri.parse('$wsRoot${GenAiVoiceProtocol.path}?${parts.join('&')}');
  }

  Future<void> start() async {
    if (_phase == GenAiVoicePhase.live || _phase == GenAiVoicePhase.connecting) return;
    final gen = ++_generation;
    _setPhase(GenAiVoicePhase.connecting);
    await _disconnect();
    try {
      _channel = WebSocketChannel.connect(voiceUri());
      _inbound = _channel!.stream.listen((frame) => _onFrame(frame, gen));
    } catch (e) {
      _fail(e.toString());
    }
  }

  Future<void> stop({String reason = 'Stopped'}) async {
    _setPhase(GenAiVoicePhase.stopping);
    try {
      final ch = _channel;
      if (ch != null) {
        ch.sink.add(jsonEncode({'type': GenAiVoiceJsonType.stop, 'reason': reason}));
      }
    } catch (_) {}
    await _stopMic();
    await _stopPlayback();
    await _disconnect();
    _setPhase(GenAiVoicePhase.idle);
  }

  Future<void> dispose() async {
    await stop(reason: 'Disposed');
    await _events.close();
  }

  Future<void> truncatePlayback({int audioEndMs = 0}) async {
    if (_voiceItemId.isEmpty) return;
    _channel?.sink.add(jsonEncode({
      'type': GenAiVoiceJsonType.truncate,
      'itemId': _voiceItemId,
      'contentIndex': _voiceItemContentIndex,
      'audioEndMs': audioEndMs,
    }));
    await _stopPlayback();
  }

  void _onFrame(Object? frame, int gen) {
    if (gen != _generation) return;
    if (frame is String) {
      _onControl(frame);
      return;
    }
    if (frame is List<int> || frame is Uint8List) {
      if (_phase != GenAiVoicePhase.live) return;
      final bytes = frame is Uint8List
          ? frame
          : Uint8List.fromList(frame is List<int> ? frame : List<int>.from(frame as List));
      unawaited(_playPcm(bytes));
    }
  }

  void _onControl(String raw) {
    Map<String, dynamic> json;
    try {
      json = jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return;
    }
    switch (json['type']?.toString()) {
      case GenAiVoiceJsonType.connected:
        _inputRate = (json['inputSampleRate'] as num?)?.toInt() ?? _inputRate;
        _outputRate = (json['outputSampleRate'] as num?)?.toInt() ?? _outputRate;
      case GenAiVoiceJsonType.live:
        _inputRate = (json['inputSampleRate'] as num?)?.toInt() ?? _inputRate;
        _outputRate = (json['outputSampleRate'] as num?)?.toInt() ?? _outputRate;
        _setPhase(GenAiVoicePhase.live);
        unawaited(_startMic(_generation));
        unawaited(_startPlayback(_outputRate));
      case GenAiVoiceJsonType.state:
        break;
      case GenAiVoiceJsonType.audioItem:
        _voiceItemId = json['itemId']?.toString() ?? '';
        _voiceItemContentIndex = (json['contentIndex'] as num?)?.toInt() ?? 0;
      case GenAiVoiceJsonType.clear:
        unawaited(_stopPlayback());
      case GenAiVoiceJsonType.transcriptDelta:
        _events.add(GenAiVoiceEvent.transcript(json['text']?.toString()));
      case GenAiVoiceJsonType.failed:
        _fail(json['reason']?.toString() ?? 'Voice failed');
      case GenAiVoiceJsonType.stopped:
        unawaited(stop(reason: json['reason']?.toString() ?? 'Stopped'));
    }
  }

  Future<void> _startMic(int gen) async {
    await _stopMic();
    _mic ??= await createMicCapture(fixtureMode: fixtureMic);
    await _mic!.start(sampleRate: _inputRate);
    _micSub = _mic!.pcmFrames.listen((chunk) {
      if (gen != _generation || _phase != GenAiVoicePhase.live) return;
      if (chunk.isEmpty) return;
      _channel?.sink.add(chunk);
    });
  }

  Future<void> _stopMic() async {
    await _micSub?.cancel();
    _micSub = null;
    await _mic?.stop();
  }

  Future<void> _playPcm(Uint8List bytes) async {
    if (useTestPlayback) {
      await _playbackSink.write(bytes);
    } else {
      await PcmPlaybackChannel.write(bytes);
    }
  }

  Future<void> _startPlayback(int rate) async {
    if (useTestPlayback) {
      await _playbackSink.start(sampleRate: rate, label: 'genai');
    } else {
      await PcmPlaybackChannel.start(sampleRate: rate, label: 'genai');
    }
  }

  Future<void> _stopPlayback() async {
    if (useTestPlayback) {
      await _playbackSink.stop();
    } else {
      await PcmPlaybackChannel.stop();
    }
  }

  Future<void> _disconnect() async {
    await _inbound?.cancel();
    _inbound = null;
    try {
      await _channel?.sink.close();
    } catch (_) {}
    _channel = null;
  }

  void _fail(String reason) {
    _setPhase(GenAiVoicePhase.failed);
    _events.add(GenAiVoiceEvent.failed(reason));
    unawaited(stop(reason: reason));
  }

  void _setPhase(GenAiVoicePhase phase) {
    _phase = phase;
    _events.add(GenAiVoiceEvent.phase(phase));
  }
}
