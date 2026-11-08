import 'package:flutter/material.dart';

import '../../core/l10n/l10n_x.dart';
import '../../core/layout/screenshot_scope.dart';
import '../../data/models/camera_models.dart';
import 'overdrive_live_preview.dart';

/// Polished live stream controls — no wire-protocol or debug copy.
class CameraStreamPanel extends StatelessWidget {
  const CameraStreamPanel({
    super.key,
    required this.stream,
    required this.busy,
    required this.selectedView,
    required this.selectedQuality,
    required this.onEnable,
    required this.onDisable,
    required this.onView,
    required this.onQuality,
  });

  final StreamStatusState? stream;
  final bool busy;
  final int selectedView;
  final String selectedQuality;
  final VoidCallback onEnable;
  final VoidCallback onDisable;
  final ValueChanged<int> onView;
  final ValueChanged<String> onQuality;

  static const qualities = ['LOW', 'MEDIUM', 'HIGH'];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final live = stream?.connected == true;
    final enabled = stream?.enabled == true;
    final serverQuality = (stream?.quality ?? selectedQuality).toUpperCase();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.cameraLiveTitle, style: theme.textTheme.titleLarge),
        const SizedBox(height: 12),
        if (ScreenshotScope.of(context))
          _HarnessPreview(scheme: scheme)
        else
          const OverdriveLivePreview(),
        const SizedBox(height: 12),
        Row(
          children: [
            _StatusPill(
              label: live ? l10n.streamBadgeLive : l10n.streamBadgeOffline,
              color: live ? scheme.primary : scheme.outline,
              filled: live,
            ),
            const SizedBox(width: 8),
            _StatusPill(
              label: enabled ? l10n.streamBadgeEnabled : l10n.streamBadgeDisabled,
              color: scheme.tertiary,
              filled: enabled,
            ),
            const Spacer(),
            Text(
              l10n.streamQualityCurrent(serverQuality),
              style: theme.textTheme.labelLarge,
              textDirection: TextDirection.ltr,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(l10n.cameraViewPickerTitle, style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var i = 0; i < 5; i++)
              FilterChip(
                label: Text(_viewName(l10n, i)),
                selected: selectedView == i || stream?.viewMode == i,
                onSelected: busy ? null : (_) => onView(i),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(l10n.cameraQualityTitle, style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          segments: [
            for (final q in qualities)
              ButtonSegment(
                value: q,
                label: Text(_qualityLabel(l10n, q)),
              ),
          ],
          selected: {serverQuality},
          onSelectionChanged: busy ? null : (s) => onQuality(s.first),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: busy ? null : onEnable,
                icon: const Icon(Icons.play_circle_outline),
                label: Text(l10n.cameraEnableStream),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: busy ? null : onDisable,
                icon: const Icon(Icons.stop_circle_outlined),
                label: Text(l10n.cameraDisableStream),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _viewName(dynamic l10n, int mode) => switch (mode) {
        0 => l10n.cameraViewMosaic,
        1 => l10n.cameraViewFront,
        2 => l10n.cameraViewRight,
        3 => l10n.cameraViewRear,
        4 => l10n.cameraViewLeft,
        _ => '$mode',
      };

  String _qualityLabel(dynamic l10n, String q) => switch (q) {
        'LOW' => l10n.cameraQualityLow,
        'HIGH' => l10n.cameraQualityHigh,
        _ => l10n.cameraQualityMedium,
      };
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color, required this.filled});

  final String label;
  final Color color;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: filled ? color.withValues(alpha: 0.18) : Colors.transparent,
        border: Border.all(color: color.withValues(alpha: 0.6)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Text(label, style: Theme.of(context).textTheme.labelLarge),
      ),
    );
  }
}

/// Golden/screenshot placeholder — no decoder, no demo frames.
class _HarnessPreview extends StatelessWidget {
  const _HarnessPreview({required this.scheme});

  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [scheme.surfaceContainerHigh, scheme.primaryContainer],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Icon(Icons.videocam_outlined, size: 48, color: scheme.primary),
          ),
        ),
      ),
    );
  }
}
