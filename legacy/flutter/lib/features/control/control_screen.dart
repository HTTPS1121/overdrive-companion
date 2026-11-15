import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/overdrive_endpoints.dart';
import '../../data/repositories/vehicle_repository.dart';
import '../../providers/app_providers.dart';

class ControlScreen extends ConsumerWidget {
  const ControlScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapAsync = ref.watch(vehicleSnapshotProvider);
    final inFlight = ref.watch(commandInFlightProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: snapAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('שגיאה: $e')),
        data: (snap) {
          if (snap == null || snap.offline || !snap.state.success) {
            return Center(
              child: Text(snap?.errorMessage ?? 'לא ניתן לשלוט — אין חיבור'),
            );
          }
          final repo = ref.read(vehicleRepositoryProvider);
          final caps = repo.availableControls(snap);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'פקודות נתמכות (API אמיתי של Overdrive)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final cap in caps)
                    FilledButton.tonal(
                      onPressed: inFlight
                          ? null
                          : () => _run(context, ref, cap, snap),
                      child: Text(cap.labelHe),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              if (snap.state.climate != null) ...[
                Text('מיזוג מהיר', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: inFlight
                            ? null
                            : () => _runClimateTemp(context, ref, snap, delta: -1),
                        child: const Text('טמפ׳ -'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: inFlight
                            ? null
                            : () => _runClimateTemp(context, ref, snap, delta: 1),
                        child: const Text('טמפ׳ +'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Future<void> _run(
    BuildContext context,
    WidgetRef ref,
    ControlCapability cap,
    VehicleSnapshot snap,
  ) async {
    ref.read(commandInFlightProvider.notifier).state = true;
    final repo = ref.read(vehicleRepositoryProvider);
    Map<String, dynamic>? body = cap.defaultBody == null
        ? null
        : Map<String, dynamic>.from(cap.defaultBody!);

    if (cap.kind == ControlKind.readingLight) {
      final on = snap.state.lights?.readingLight != true;
      body = {'target': 'readingLight', 'enable': on};
    }
    if (cap.kind == ControlKind.steeringHeat) {
      final on = snap.state.seats?.steeringHeat != true;
      body = {
        'action': on ? 'steering_heat_on' : 'steering_heat_off',
      };
    }

    final result = await repo.runControl(cap, body: body);
    ref.read(commandInFlightProvider.notifier).state = false;
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.success
              ? (result.message ?? 'בוצע (${result.path ?? cap.path})')
              : (result.error ?? 'נכשל'),
        ),
      ),
    );
    if (result.success) {
      await ref.read(vehicleSnapshotProvider.notifier).refresh();
    }
  }

  Future<void> _runClimateTemp(
    BuildContext context,
    WidgetRef ref,
    VehicleSnapshot snap,
    {required int delta,
  }) async {
    final current = snap.state.climate?.setpointDriver ?? 22;
    final next = (current + delta).clamp(15, 33).toDouble();
    final cap = kStage1Controls.firstWhere((c) => c.kind == ControlKind.tempUp);
    ref.read(commandInFlightProvider.notifier).state = true;
    final result = await ref.read(vehicleRepositoryProvider).runControl(
          cap,
          body: {'action': 'set_temp', 'zone': 0, 'temp': next},
        );
    ref.read(commandInFlightProvider.notifier).state = false;
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result.success ? 'טמפ׳ $next°C' : result.error ?? 'שגיאה')),
    );
    if (result.success) {
      await ref.read(vehicleSnapshotProvider.notifier).refresh();
    }
  }
}
