import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:web_socket_channel/web_socket_channel.dart';

import 'communicate_protocol.dart';
import 'pcm_playback_channel.dart';

enum CabinListenerPhase { idle, connecting, live, paused, error }

class CabinListenerState {
  const CabinListenerState(this.phase, {this.reason, this.sampleRate = 48000});

  final CabinListenerPhase phase;
  final String? reason;
  final int sampleRate;
}

typedef CabinPcmSink = Future<void> Function(Uint8List pcm);

/// Matches `cabin-audio.js` + `/ws/cabin-audio`.
class CabinAudioClient {
  CabinAudioClient({
    required this.baseUrl,
    this.jwt,
    this.useTestSink = false,
  });

  final String baseUrl;
  final String? jwt;
  final bool useTestSink;

  WebSocketChannel? _channel;
  StreamSubscription<Object?>? _inbound;
  final _states = StreamController<CabinListenerState>.broadcast();
  final TestPcmPlaybackSink _testSink = TestPcmPlaybackSink();

  var _phase = CabinListenerPhase.idle;
  var _serverPaused = false;
  var _localPaused = false;
  var _generation = 0;
  var playbackBytes = 0;

  Stream<CabinListenerState> get states => _states.stream;
  CabinListenerPhase get phase => _phase;
  TestPcmPlaybackSink get testSink => _testSink;

  Uri listenerUri() {
    final root = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final wsRoot = root.replaceFirst('https://', 'wss://').replaceFirst('http://', 'ws://');
    final q = jwt != null && jwt!.isNotEmpty ? '?token=${Uri.encodeQueryComponent(jwt!)}' : '';
    return Uri.parse('$wsRoot${CommunicateProtocol.pathCabinAudio}$q');
  }

  Future<void> connect() async {
    if (_phase == CabinListenerPhase.connecting || _phase == CabinListenerPhase.live) return;
    final gen = ++_generation;
    _emit(CabinListenerPhase.connecting);
    await disconnect(silent: true);
    try {
      _channel = WebSocketChannel.connect(listenerUri());
      _inbound = _channel!.stream.listen((frame) => _onFrame(frame, gen));
    } catch (e) {
      _emit(CabinListenerPhase.error, reason: e.toString());
    }
  }

  Future<void> disconnect({bool silent = false}) async {
    await _inbound?.cancel();
    _inbound = null;
    try {
      await _channel?.sink.close();
    } catch (_) {}
    _channel = null;
    await _stopPlayback();
    if (!silent) _emit(CabinListenerPhase.idle);
  }

  Future<void> setLocalPaused(bool paused) async {
    _localPaused = paused;
    _refreshPhase();
    if (paused) await _stopPlayback();
  }

  Future<void> dispose() async {
    await disconnect();
    await _states.close();
  }

  void _onFrame(Object? frame, int gen) {
    if (gen != _generation) return;
    if (frame is String) {
      Map<String, dynamic> json;
      try {
        json = jsonDecode(frame) as Map<String, dynamic>;
      } catch (_) {
        return;
      }
      switch (json['type']?.toString()) {
        case CabinAudioJsonType.starting:
          final rate = (json['sampleRate'] as num?)?.toInt() ?? 48000;
          _startPlayback(rate);
        case CabinAudioJsonType.ready:
          final rate = (json['sampleRate'] as num?)?.toInt() ?? 48000;
          _startPlayback(rate);
          _serverPaused = false;
          _refreshPhase(sampleRate: rate);
        case CabinAudioJsonType.paused:
          _serverPaused = true;
          _refreshPhase(reason: json['reason']?.toString());
          unawaited(_stopPlayback());
        case CabinAudioJsonType.resumed:
          _serverPaused = false;
          _refreshPhase();
        case CabinAudioJsonType.failed:
          _emit(CabinListenerPhase.error, reason: json['reason']?.toString());
          disconnect(silent: true);
        case CabinAudioJsonType.stopped:
          _emit(CabinListenerPhase.idle, reason: json['reason']?.toString());
          disconnect(silent: true);
      }
      return;
    }
    if (frame is List<int> || frame is Uint8List) {
      if (_serverPaused || _localPaused) return;
      final bytes = frame is Uint8List
          ? frame
          : Uint8List.fromList(frame is List<int> ? frame : List<int>.from(frame as List));
      if (bytes.isEmpty) return;
      unawaited(_play(bytes));
    }
  }

  Future<void> _play(Uint8List pcm) async {
    playbackBytes += pcm.length;
    if (useTestSink) {
      await _testSink.write(pcm);
    } else {
      await PcmPlaybackChannel.write(pcm);
    }
  }

  Future<void> _startPlayback(int sampleRate) async {
    if (useTestSink) {
      await _testSink.start(sampleRate: sampleRate, label: 'cabin');
    } else {
      await PcmPlaybackChannel.start(sampleRate: sampleRate, label: 'cabin');
    }
  }

  Future<void> _stopPlayback() async {
    if (useTestSink) {
      await _testSink.stop();
    } else {
      await PcmPlaybackChannel.stop();
    }
  }

  void _refreshPhase({int? sampleRate, String? reason}) {
    if (_phase == CabinListenerPhase.error) return;
    if (_serverPaused || _localPaused) {
      _emit(CabinListenerPhase.paused, reason: reason, sampleRate: sampleRate ?? 48000);
    } else {
      _emit(CabinListenerPhase.live, sampleRate: sampleRate ?? 48000);
    }
  }

  void _emit(CabinListenerPhase phase, {String? reason, int sampleRate = 48000}) {
    _phase = phase;
    _states.add(CabinListenerState(phase, reason: reason, sampleRate: sampleRate));
  }
}
