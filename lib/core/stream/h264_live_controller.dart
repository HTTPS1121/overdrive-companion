import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../data/api/overdrive_api_client.dart';

enum LiveStreamPhase {
  idle,
  connecting,
  connected,
  live,
  reconnecting,
  error,
  decoderError,
}

/// Native Android MediaCodec preview — WebSocket handled in Kotlin (OkHttp).
class H264LiveController extends ChangeNotifier {
  H264LiveController({required this.baseUrl, this.jwt});

  final String baseUrl;
  final String? jwt;

  static const _method = MethodChannel('overdrive/h264');
  static const _events = EventChannel('overdrive/h264_events');

  int? textureId;
  LiveStreamPhase phase = LiveStreamPhase.idle;
  String? statusMessage;
  int? reconnectAttempt;
  StreamSubscription<dynamic>? _eventSub;
  bool _disposed = false;

  String buildWsUrl() {
    final base = Uri.parse(normalizeBaseUrl(baseUrl));
    final wsScheme = base.scheme == 'https' ? 'wss' : 'ws';
    final uri = Uri(
      scheme: wsScheme,
      host: base.host,
      port: base.hasPort ? base.port : null,
      path: '/ws',
      queryParameters: jwt != null && jwt!.isNotEmpty ? {'token': jwt} : null,
    );
    return uri.toString();
  }

  Future<void> start() async {
    if (_disposed) return;
    if (defaultTargetPlatform != TargetPlatform.android) {
      phase = LiveStreamPhase.decoderError;
      statusMessage = 'Live H.264 decode is Android-only in this build.';
      notifyListeners();
      return;
    }
    await stop();
    if (_disposed) return;
    phase = LiveStreamPhase.connecting;
    notifyListeners();
    _eventSub = _events.receiveBroadcastStream().listen(_onEvent, onError: _onError);
    try {
      final id = await _method.invokeMethod<int>('start', {'wsUrl': buildWsUrl()});
      textureId = id;
    } on PlatformException catch (e) {
      phase = LiveStreamPhase.error;
      statusMessage = e.message;
      notifyListeners();
    }
  }

  Future<void> stop() async {
    await _eventSub?.cancel();
    _eventSub = null;
    if (defaultTargetPlatform == TargetPlatform.android && !_disposed) {
      try {
        await _method.invokeMethod<void>('stop');
      } catch (_) {}
    }
    textureId = null;
    if (!_disposed) {
      phase = LiveStreamPhase.idle;
      notifyListeners();
    }
  }

  void _onEvent(dynamic event) {
    if (_disposed || event is! Map) return;
    final state = event['state']?.toString() ?? '';
    switch (state) {
      case 'connecting':
        phase = LiveStreamPhase.connecting;
      case 'connected':
        phase = LiveStreamPhase.connected;
      case 'frame':
        phase = LiveStreamPhase.live;
      case 'reconnecting':
        phase = LiveStreamPhase.reconnecting;
        reconnectAttempt = event['attempt'] as int?;
      case 'decoderError':
      case 'decodeError':
        phase = LiveStreamPhase.decoderError;
        statusMessage = event['message']?.toString();
      case 'error':
        phase = LiveStreamPhase.error;
        statusMessage = event['message']?.toString();
      default:
        break;
    }
    notifyListeners();
  }

  void _onError(Object error) {
    if (_disposed) return;
    phase = LiveStreamPhase.error;
    statusMessage = error.toString();
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(stop());
    super.dispose();
  }
}
