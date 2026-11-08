import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/layout/screenshot_scope.dart';
import '../../core/l10n/l10n_x.dart';
import '../../core/stream/h264_live_controller.dart';
import '../../providers/app_providers.dart';

class OverdriveLivePreview extends ConsumerStatefulWidget {
  const OverdriveLivePreview({super.key});

  @override
  ConsumerState<OverdriveLivePreview> createState() => _OverdriveLivePreviewState();
}

class _OverdriveLivePreviewState extends ConsumerState<OverdriveLivePreview> {
  H264LiveController? _controller;
  bool _wired = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_wired) return;
    _wired = true;
    final settings = ref.read(appSettingsProvider);
    final jwt = ref.read(vehicleRepositoryProvider).sessionJwt;
    _controller = H264LiveController(baseUrl: settings.baseUrl, jwt: jwt)
      ..addListener(_onCtrl);
    if (!ScreenshotScope.of(context)) {
      Future.microtask(_controller!.start);
    }
  }

  void _onCtrl() => setState(() {});

  @override
  void dispose() {
    _controller?.removeListener(_onCtrl);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final c = _controller;
    final id = c?.textureId;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: ColoredBox(
              color: theme.colorScheme.surfaceContainerHighest,
              child: id != null && c != null
                  ? Texture(textureId: id)
                  : Center(
                      child: Text(
                        ScreenshotScope.of(context) ? l10n.streamPhaseIdle : _phaseLabel(l10n, c),
                      ),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(_phaseLabel(l10n, c), style: theme.textTheme.labelLarge),
      ],
    );
  }

  String _phaseLabel(dynamic l10n, H264LiveController? c) {
    final phase = c?.phase ?? LiveStreamPhase.idle;
    return switch (phase) {
      LiveStreamPhase.idle => l10n.streamPhaseIdle,
      LiveStreamPhase.connecting => l10n.streamPhaseConnecting,
      LiveStreamPhase.connected => l10n.streamPhaseConnected,
      LiveStreamPhase.live => l10n.streamPhaseLive,
      LiveStreamPhase.reconnecting => l10n.streamPhaseReconnecting(c?.reconnectAttempt ?? 0),
      LiveStreamPhase.error => l10n.streamPhaseError,
      LiveStreamPhase.decoderError => l10n.streamPhaseDecoderError,
    };
  }
}
