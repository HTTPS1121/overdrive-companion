import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/layout/screenshot_scope.dart';
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
    final uri = Uri.parse(gps.navigationUri);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('לא ניתן לפתוח אפליקציית ניווט')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!gps.hasLocation) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'אין קואורדינטות בתשובת השרת',
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
                        child: Text(
                          'תצוגת מפה דורשת רשת במכשיר.\nהקואורדינטות והניווט למטה תקפים מהשרת.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall,
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
                                'לא ניתן לטעון מפה — הקואורדינטות זמינות',
                                style: Theme.of(context).textTheme.bodySmall,
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
                LtrMetricRow(label: 'קואורדינטות', value: gps.coordinatesLabel),
                if (gps.canSpeedKmh != null)
                  LtrMetricRow(
                    label: 'מהירות',
                    value: '${gps.canSpeedKmh!.toStringAsFixed(0)} km/h',
                  ),
                if (gps.headingDeg != null)
                  LtrMetricRow(
                    label: 'כיוון',
                    value: '${gps.headingDeg!.toStringAsFixed(0)}°',
                  ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => _openNavigation(context),
                  icon: const Icon(Icons.navigation),
                  label: const Text('פתיחה בניווט'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
