import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/layout/scroll_insets.dart';
import '../../providers/app_providers.dart';
import 'gps_location_card.dart';

class GpsScreen extends ConsumerWidget {
  const GpsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncSnap = ref.watch(vehicleSnapshotProvider);

    return asyncSnap.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('שגיאה: $e')),
      data: (snap) {
        if (snap == null || snap.offline || !snap.state.success) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                snap?.errorMessage ?? 'אין מיקום — נדרש חיבור פעיל לשרת',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        final gps = snap.gps;
        if (gps == null || !gps.success) {
          return const Center(child: Text('השרת לא החזיר נתוני GPS'));
        }
        return ListView(
          padding: scrollBottomPadding(context),
          children: [
            GpsLocationCard(gps: gps, drivingLabel: snap.drivingLabelHe),
          ],
        );
      },
    );
  }
}
