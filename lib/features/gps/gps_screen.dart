import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/app_providers.dart';

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
        if (gps == null) {
          return const Center(child: Text('השרת לא החזיר נתוני GPS'));
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('מיקום', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(
                      gps.hasLocation ? 'מיקום זמין מהשרת' : 'אין קואורדינטות בגוף התשובה',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    Text(
                      gps.isDriving == true ? 'בנסיעה' : 'לא בנסיעה',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (gps.canSpeedKmh != null)
                      Text(
                        '${gps.canSpeedKmh!.toStringAsFixed(0)} km/h',
                        textDirection: TextDirection.ltr,
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
