import 'package:flutter/material.dart';

import '../../data/repositories/vehicle_repository.dart';
import '../format/freshness.dart';
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

    String? sub;
    if (offline) {
      sub = snapshot.errorMessage ?? 'אין תקשורת';
    } else if (freshness.isStale) {
      sub = 'נתונים ישנים · ${freshness.ageLabelHe()}';
    } else if (cloud != null) {
      sub = 'BYD Cloud: ${cloud.configured && cloud.verified ? 'פעיל' : 'חלקי'}';
    } else {
      sub = freshness.ageLabelHe();
    }

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
                  Text(statusText, style: Theme.of(context).textTheme.titleSmall),
                  Text(
                      sub,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: freshness.isStale ? colors.warn : colors.muted,
                          ),
                    ),
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
}
