import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../design/od_design.dart';
import '../../models/companion_models.dart';
import '../../state/companion_app_controller.dart';

class RecordingThumb extends ConsumerWidget {
  const RecordingThumb({super.key, required this.recording});

  final Recording recording;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final client = ref.watch(apiClientProvider);
    final jwt = client.jwt;
    final cam = recording.cameraLabel ?? 'הקלטה';
    final uri = client.recordingThumbUri(recording.file);
    final headers = client.authHeaders();

    if (jwt == null || jwt.isEmpty) {
      return _placeholder(cam, recording.time);
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          uri.toString(),
          headers: headers,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholder(cam, recording.time),
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return _placeholder(cam, recording.time, loading: true);
          },
        ),
        Positioned(
          top: 10,
          right: 10,
          child: _badge('$cam · ${recording.time}'),
        ),
      ],
    );
  }

  Widget _placeholder(String cam, String time, {bool loading = false}) {
    return ColoredBox(
      color: const Color(0xFFDFE6F0),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: Icon(
              loading ? Icons.hourglass_empty : Icons.videocam_outlined,
              color: OdColors.muted,
              size: 36,
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: _badge('$cam · $time'),
          ),
        ],
      ),
    );
  }

  Widget _badge(String text) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xE80C2348),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
