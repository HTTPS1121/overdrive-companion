import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/freshness.dart';
import '../../data/models/vehicle_state.dart';
import '../../providers/app_providers.dart';

class VehicleStatusScreen extends ConsumerWidget {
  const VehicleStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncSnap = ref.watch(vehicleSnapshotProvider);

    return asyncSnap.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _CenteredMessage(
        icon: Icons.error_outline,
        title: 'שגיאה',
        body: e.toString(),
      ),
      data: (snap) {
        if (snap == null) {
          return const _CenteredMessage(
            icon: Icons.link_off,
            title: 'לא מחובר',
            body: 'הגדר חיבור בהגדרות',
          );
        }
        if (snap.offline || !snap.state.success) {
          return _CenteredMessage(
            icon: Icons.cloud_off,
            title: 'אין קשר עם השרת',
            body: snap.errorMessage ?? 'בדוק מנהרה ורשת',
            action: FilledButton.tonalIcon(
              onPressed: () => ref.read(vehicleSnapshotProvider.notifier).refresh(),
              icon: const Icon(Icons.refresh),
              label: const Text('נסה שוב'),
            ),
          );
        }

        final freshness = DataFreshness(
          serverEpochSec: snap.state.timestamp,
          fetchedAt: snap.lastUpdated ?? DateTime.now(),
        );

        return RefreshIndicator(
          onRefresh: () => ref.read(vehicleSnapshotProvider.notifier).refresh(),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              _SectionCard(
                title: 'חיבור',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('מחובר לשרת', style: Theme.of(context).textTheme.titleMedium),
                    Text(
                      freshness.ageLabelHe(),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (freshness.isStale)
                      Text(
                        'נתונים ישנים — רענן לפני פקודות',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.tertiary,
                            ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _BatterySection(battery: snap.state.battery, locked: snap.state.isLocked),
              const SizedBox(height: 12),
              _ClimateSection(climate: snap.state.climate),
              const SizedBox(height: 12),
              _WindowsSection(windows: snap.state.windows),
              if (snap.state.tyres?.available == true) ...[
                const SizedBox(height: 12),
                _TyresSection(tyres: snap.state.tyres!),
              ],
              if (snap.cloud != null) ...[
                const SizedBox(height: 12),
                _SectionCard(
                  title: 'ענן BYD',
                  child: Text(
                    snap.cloud!.configured && snap.cloud!.verified
                        ? 'מוגדר ופעיל'
                        : 'חלקי או לא מוגדר',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _CenteredMessage extends StatelessWidget {
  const _CenteredMessage({
    required this.icon,
    required this.title,
    required this.body,
    this.action,
  });

  final IconData icon;
  final String title;
  final String body;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 56, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(body, textAlign: TextAlign.center),
            if (action != null) ...[const SizedBox(height: 20), action!],
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

class _BatterySection extends StatelessWidget {
  const _BatterySection({required this.battery, required this.locked});

  final BatteryInfo? battery;
  final bool? locked;

  @override
  Widget build(BuildContext context) {
    final soc = battery?.soc;
    final range = battery?.displayRangeKm;
    return _SectionCard(
      title: 'סוללה',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            soc != null ? '${soc.round()}%' : 'לא ידוע',
            style: Theme.of(context).textTheme.headlineMedium,
            textDirection: TextDirection.ltr,
          ),
          if (range != null)
            Text(
              '$range km',
              style: Theme.of(context).textTheme.bodyLarge,
              textDirection: TextDirection.ltr,
            ),
          if (locked != null)
            Text(locked! ? 'נעול' : 'פתוח', style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _ClimateSection extends StatelessWidget {
  const _ClimateSection({required this.climate});

  final ClimateInfo? climate;

  @override
  Widget build(BuildContext context) {
    final c = climate;
    return _SectionCard(
      title: 'מיזוג',
      child: Text(
        c?.acOn == true ? 'פעיל' : 'כבוי',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }
}

class _WindowsSection extends StatelessWidget {
  const _WindowsSection({required this.windows});

  final WindowPercents? windows;

  @override
  Widget build(BuildContext context) {
    String p(int? v) => v == null || v < 0 ? '--' : '$v%';
    return _SectionCard(
      title: 'חלונות',
      child: Text(
        'קדמי ${p(windows?.lf)} | אחורי ${p(windows?.lr)}',
        style: Theme.of(context).textTheme.bodyLarge,
        textDirection: TextDirection.rtl,
      ),
    );
  }
}

class _TyresSection extends StatelessWidget {
  const _TyresSection({required this.tyres});

  final TyreBlock tyres;

  @override
  Widget build(BuildContext context) {
    String line(TyreCorner? t) =>
        t?.kPa != null ? '${t!.kPa} kPa' : 'אין נתון';
    return _SectionCard(
      title: 'צמיגים',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('קדמי שמאל: ${line(tyres.fl)}'),
          Text('קדמי ימין: ${line(tyres.fr)}'),
        ],
      ),
    );
  }
}
