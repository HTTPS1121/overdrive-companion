import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/layout/scroll_insets.dart';
import '../../core/l10n/l10n_x.dart';
import '../../providers/app_providers.dart';
import 'gps_location_card.dart';

class GpsScreen extends ConsumerWidget {
  const GpsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final asyncSnap = ref.watch(vehicleSnapshotProvider);

    return asyncSnap.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('${l10n.statusErrorTitle}: $e')),
      data: (snap) {
        if (snap == null || snap.offline || !snap.state.success) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                snap?.errorMessage ?? l10n.gpsNoLocationServer,
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        final gps = snap.gps;
        if (gps == null || !gps.success) {
          return Center(child: Text(l10n.gpsServerNoGps));
        }
        final driving = snap.gps?.isDriving == true ? l10n.statusDriving : l10n.statusParked;
        return ListView(
          padding: scrollBottomPadding(context),
          children: [
            GpsLocationCard(gps: gps, drivingLabel: driving),
          ],
        );
      },
    );
  }
}
