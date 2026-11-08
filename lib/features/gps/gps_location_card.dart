import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/layout/screenshot_scope.dart';
import '../../core/l10n/l10n_x.dart';
import '../../core/widgets/ltr_metric.dart';
import '../../data/models/gps_snapshot.dart';

class GpsLocationCard extends StatelessWidget {
  const GpsLocationCard({
    super.key,
    required this.gps,
    this.drivingLabel,
    this.compact = false,
  });

  final GpsSnapshot gps;
  final String? drivingLabel;
  final bool compact;

  Future<void> _openNavigation(BuildContext context) async {
    final l10n = context.l10n;
    final uri = Uri.parse(gps.navigationUri);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.gpsNavigationUnavailable)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (!gps.hasLocation) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            l10n.gpsNoCoordinates,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      );
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!compact) ...[
            AspectRatio(
              aspectRatio: 600 / 280,
              child: ScreenshotScope.of(context)
                  ? ColoredBox(
                      color: Theme.of(context).colorScheme.surfaceContainerHigh,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            l10n.gpsMapNeedsNetwork,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ),
                    )
                  : Image.network(
                      gps.staticMapUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => ColoredBox(
                        color: Theme.of(context).colorScheme.surfaceContainerHigh,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.map_outlined, size: 48),
                              const SizedBox(height: 8),
                              Text(
                                l10n.gpsMapLoadFailed,
                                style: Theme.of(context).textTheme.bodySmall,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                      loadingBuilder: (ctx, child, progress) {
                        if (progress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                    ),
            ),
          ],
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (drivingLabel != null) Text(drivingLabel!),
                LtrMetricRow(label: l10n.gpsCoordinates, value: gps.coordinatesLabel),
                if (gps.canSpeedKmh != null)
                  LtrMetricRow(
                    label: l10n.gpsSpeed,
                    value: '${gps.canSpeedKmh!.toStringAsFixed(0)} km/h',
                  ),
                if (gps.headingDeg != null)
                  LtrMetricRow(
                    label: l10n.gpsHeading,
                    value: '${gps.headingDeg!.toStringAsFixed(0)}°',
                  ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => _openNavigation(context),
                  icon: const Icon(Icons.navigation),
                  label: Text(l10n.gpsOpenNavigation),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
