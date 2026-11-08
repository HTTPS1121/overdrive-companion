import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../../data/repositories/extended_endpoints.dart';

/// Push-to-talk client for `wss://…/ws/communicate` (binary PCM frames).
///
/// Runtime microphone capture and vehicle speaker playback require device
/// permissions; CI uses mocks only. See `GenAiVoiceWebSocket` / `RemoteCommunicationWebSocket`
/// in upstream Overdrive-release for framing details.
class CommunicatePttClient {
  CommunicatePttClient({required this.baseUrl, this.jwt});

  final String baseUrl;
  final String? jwt;

  WebSocketChannel? _channel;
  StreamSubscription<Object?>? _inbound;

  bool get connected => _channel != null;

  Uri _wsUri() {
    final root = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final http = root.replaceFirst('https://', 'wss://').replaceFirst('http://', 'ws://');
    final q = jwt != null && jwt!.isNotEmpty ? '?token=${Uri.encodeQueryComponent(jwt!)}' : '';
    return Uri.parse('$http${ExtendedEndpoints.wsCommunicate}$q');
  }

  Future<void> connect({void Function(Object? frame)? onFrame}) async {
    await disconnect();
    final channel = WebSocketChannel.connect(_wsUri());
    _channel = channel;
    _inbound = channel.stream.listen(onFrame);
  }

  void sendPcm(List<int> bytes) {
    _channel?.sink.add(bytes);
  }

  void sendJson(Map<String, dynamic> payload) {
    _channel?.sink.add(jsonEncode(payload));
  }

  Future<void> disconnect() async {
    await _inbound?.cancel();
    _inbound = null;
    await _channel?.sink.close();
    _channel = null;
  }
}
