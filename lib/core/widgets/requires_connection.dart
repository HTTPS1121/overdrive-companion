import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/app_providers.dart';

/// Standard offline / misconfiguration message for feature screens.
class RequiresConnection extends ConsumerWidget {
  const RequiresConnection({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snap = ref.watch(vehicleSnapshotProvider).valueOrNull;
    if (snap == null || snap.offline || !snap.state.success) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off, size: 48, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 12),
              Text(
                snap?.errorMessage ?? 'נדרש חיבור פעיל לשרת הרכב',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      );
    }
    return child ?? const SizedBox.shrink();
  }
}
