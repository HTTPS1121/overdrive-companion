import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:web_socket_channel/web_socket_channel.dart';

import 'communicate_protocol.dart';
import 'mic_capture.dart';

enum CommunicateTalkPhase { idle, connecting, starting, live, stopping, failed }

class CommunicateTalkEvent {
  CommunicateTalkEvent.phase(this.phase) : reason = null, pcmSentBytes = null;
  CommunicateTalkEvent.failed(this.reason) : phase = CommunicateTalkPhase.failed, pcmSentBytes = null;
  CommunicateTalkEvent.stopped(this.reason) : phase = CommunicateTalkPhase.idle, pcmSentBytes = null;
  CommunicateTalkEvent.meter(this.pcmSentBytes) : phase = CommunicateTalkPhase.live, reason = null;

  final CommunicateTalkPhase? phase;
  final String? reason;
  final int? pcmSentBytes;
}

/// Push-to-talk client matching upstream `communicate.js` + `RemoteCommunicationWebSocket`.
class CommunicatePttClient {
  CommunicatePttClient({
    required this.baseUrl,
    this.jwt,
    MicCapture? mic,
    this.fixtureMic = false,
  }) : _mic = mic;

  final String baseUrl;
  final String? jwt;
  final bool fixtureMic;
  MicCapture? _mic;

  WebSocketChannel? _channel;
  StreamSubscription<Object?>? _inbound;
  StreamSubscription<Uint8List>? _micSub;

  var _phase = CommunicateTalkPhase.idle;
  var _generation = 0;
  var _pressing = false;
  var _pcmSent = 0;
  final _events = StreamController<CommunicateTalkEvent>.broadcast();

  Stream<CommunicateTalkEvent> get events => _events.stream;
  CommunicateTalkPhase get phase => _phase;

  Uri talkUri() {
    final root = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final wsRoot = root.replaceFirst('https://', 'wss://').replaceFirst('http://', 'ws://');
    final q = jwt != null && jwt!.isNotEmpty ? '?token=${Uri.encodeQueryComponent(jwt!)}' : '';
    return Uri.parse('$wsRoot${CommunicateProtocol.pathCommunicate}$q');
  }

  /// Connect on press — sends `start` immediately after socket open (browser parity).
  Future<void> pressDown() async {
    if (_pressing) return;
    _pressing = true;
    final gen = ++_generation;
    _setPhase(CommunicateTalkPhase.connecting);
    await _disconnectSocket();
    try {
      _channel = WebSocketChannel.connect(talkUri());
      _inbound = _channel!.stream.listen((frame) => _onFrame(frame, gen));
      _channel!.sink.add(jsonEncode({
        'type': CommunicateJsonType.start,
        'format': CommunicateProtocol.pcmFormat,
        'sampleRate': CommunicateProtocol.pcmSampleRateHz,
      }));
      _setPhase(CommunicateTalkPhase.starting);
    } catch (e) {
      _fail('Could not open talk socket: $e');
    }
  }

  Future<void> pressUp({String reason = 'Released'}) async {
    if (!_pressing && _phase == CommunicateTalkPhase.idle) return;
    _pressing = false;
    _setPhase(CommunicateTalkPhase.stopping);
    try {
      final ch = _channel;
      if (ch != null) {
        ch.sink.add(jsonEncode({'type': CommunicateJsonType.stop, 'reason': reason}));
      }
    } catch (_) {}
    await _stopMic();
    await _disconnectSocket();
    _events.add(CommunicateTalkEvent.stopped(reason));
    _setPhase(CommunicateTalkPhase.idle);
  }

  Future<void> dispose() async {
    await pressUp(reason: 'Disposed');
    await _stopMic();
    await _mic?.dispose();
    _mic = null;
    if (!_events.isClosed) await _events.close();
  }

  void _onFrame(Object? frame, int gen) {
    if (gen != _generation) return;
    if (frame is! String) return;
    Map<String, dynamic> json;
    try {
      json = jsonDecode(frame) as Map<String, dynamic>;
    } catch (_) {
      return;
    }
    switch (json['type']?.toString()) {
      case CommunicateJsonType.live:
        if (!_pressing) {
          pressUp();
          return;
        }
        _setPhase(CommunicateTalkPhase.live);
        unawaited(_startMic(gen));
      case CommunicateJsonType.failed:
        _fail(json['reason']?.toString() ?? 'Talk failed');
      case CommunicateJsonType.stopped:
        _pressing = false;
        unawaited(pressUp(reason: json['reason']?.toString() ?? 'Stopped'));
    }
  }

  Future<void> _startMic(int gen) async {
    await _stopMic();
    _pcmSent = 0;
    _mic ??= await createMicCapture(fixtureMode: fixtureMic);
    await _mic!.start(sampleRate: CommunicateProtocol.pcmSampleRateHz);
    _micSub = _mic!.pcmFrames.listen((chunk) {
      if (gen != _generation || !_pressing || _phase != CommunicateTalkPhase.live) return;
      if (chunk.isEmpty || (chunk.length & 1) != 0) return;
      if (chunk.length > CommunicateProtocol.maxPcmFrameBytes) return;
      final ch = _channel;
      if (ch == null) {
        _fail('Talk socket lost');
        return;
      }
      try {
        ch.sink.add(chunk);
        _pcmSent += chunk.length;
        _events.add(CommunicateTalkEvent.meter(_pcmSent));
      } catch (e) {
        _fail('Could not send PCM: $e');
      }
    });
  }

  Future<void> _stopMic() async {
    await _micSub?.cancel();
    _micSub = null;
    await _mic?.stop();
  }

  Future<void> _disconnectSocket() async {
    await _inbound?.cancel();
    _inbound = null;
    try {
      await _channel?.sink.close();
    } catch (_) {}
    _channel = null;
  }

  void _fail(String reason) {
    _setPhase(CommunicateTalkPhase.failed);
    _events.add(CommunicateTalkEvent.failed(reason));
    unawaited(pressUp(reason: reason));
  }

  void _setPhase(CommunicateTalkPhase next) {
    _phase = next;
    _events.add(CommunicateTalkEvent.phase(next));
  }
}
