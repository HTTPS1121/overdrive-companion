import 'package:flutter/material.dart';

import '../../data/models/cloud_status.dart';
import '../../data/repositories/vehicle_repository.dart';
import '../format/display_strings.dart';
import '../format/freshness.dart';
import '../theme/app_text.dart';
import '../theme/app_theme.dart';

class ConnectionStatusBar extends StatelessWidget {
  const ConnectionStatusBar({
    super.key,
    required this.snapshot,
    required this.freshness,
    required this.onRefresh,
    this.refreshing = false,
  });

  final VehicleSnapshot snapshot;
  final DataFreshness freshness;
  final VoidCallback onRefresh;
  final bool refreshing;

  @override
  Widget build(BuildContext context) {
    final colors = OverdriveColors.of(context);
    final offline = snapshot.offline || !snapshot.state.success;
    final cloud = snapshot.cloud;

    final statusColor = offline ? colors.danger : colors.accent;
    final statusText = offline ? 'מנותק' : 'מחובר לשרת';

    final Widget subtitle = _buildSubtitle(context, offline, cloud, freshness, colors);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: statusColor.withValues(alpha: 0.45),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    statusText,
                    style: hebrewTextStyle(Theme.of(context).textTheme.titleSmall),
                  ),
                  subtitle,
                ],
              ),
            ),
            IconButton.filledTonal(
              onPressed: refreshing ? null : onRefresh,
              icon: refreshing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.sync),
              tooltip: 'רענון',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubtitle(
    BuildContext context,
    bool offline,
    CloudStatus? cloud,
    DataFreshness freshness,
    OverdriveColors colors,
  ) {
    final base = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: freshness.isStale ? colors.warn : colors.muted,
        );
    final he = hebrewTextStyle(base);
    final num = numericTextStyle(base);

    if (offline) {
      return Text(
        snapshot.errorMessage ?? 'אין תקשורת',
        style: he,
      );
    }
    if (freshness.isStale) {
      return Text.rich(
        TextSpan(
          style: he,
          children: [
            TextSpan(text: 'נתונים ישנים${kTextSep}'),
            TextSpan(text: freshness.ageLabelHe(), style: num),
          ],
        ),
      );
    }
    if (cloud != null) {
      final state = cloud.configured && cloud.verified ? 'פעיל' : 'חלקי';
      return Text.rich(
        TextSpan(
          children: [
            TextSpan(text: 'BYD Cloud: ', style: num),
            TextSpan(text: state, style: he),
          ],
        ),
      );
    }
    return Text(freshness.ageLabelHe(), style: num);
  }
}
