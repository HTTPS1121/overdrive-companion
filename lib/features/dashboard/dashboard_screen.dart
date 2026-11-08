import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/freshness.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/battery_hero.dart';
import '../../core/widgets/connection_status_bar.dart';
import '../../core/widgets/demo_banner.dart';
import '../../data/models/vehicle_state.dart';
import '../../providers/app_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final asyncSnap = ref.watch(vehicleSnapshotProvider);
    final colors = OverdriveColors.of(context);

    return Column(
      children: [
        DemoDataBanner(mode: settings.connectionMode),
        Expanded(
          child: asyncSnap.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => _ErrorState(message: e.toString()),
            data: (snap) {
              if (snap == null) {
                return const _ErrorState(message: 'אין נתונים');
              }
              if (snap.offline || !snap.state.success) {
                return _ErrorState(message: snap.errorMessage ?? 'לא מחובר');
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
                    ConnectionStatusBar(
                      snapshot: snap,
                      freshness: freshness,
                      refreshing: asyncSnap.isLoading,
                      onRefresh: () =>
                          ref.read(vehicleSnapshotProvider.notifier).refresh(),
                    ),
                    const SizedBox(height: 14),
                    BatteryHero(
                      battery: snap.state.battery,
                      locked: snap.state.isLocked,
                      drivingLabel: snap.drivingLabelHe,
                    ),
                    const SizedBox(height: 14),
                    _SectionTitle(title: 'מיזוג ובטיחות'),
                    const SizedBox(height: 8),
                    _ClimateCard(climate: snap.state.climate),
                    const SizedBox(height: 14),
                    _SectionTitle(title: 'חלונות ודלתות'),
                    const SizedBox(height: 8),
                    _WindowsCard(windows: snap.state.windows, doors: snap.state.doors),
                    if (snap.state.tyres?.available == true) ...[
                      const SizedBox(height: 14),
                      _SectionTitle(title: 'צמיגים (TPMS)'),
                      const SizedBox(height: 8),
                      _TyresGrid(tyres: snap.state.tyres!),
                    ],
                    if (freshness.isStale) ...[
                      const SizedBox(height: 16),
                      Text(
                        'שים לב: נתוני הרכב לא עודכנו לאחרונה. רענן לפני שליחת פקודות.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.warn),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title, style: Theme.of(context).textTheme.titleMedium);
  }
}

class _ClimateCard extends StatelessWidget {
  const _ClimateCard({required this.climate});

  final ClimateInfo? climate;

  @override
  Widget build(BuildContext context) {
    final c = climate;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              c?.acOn == true ? Icons.ac_unit : Icons.ac_unit_outlined,
              size: 36,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c?.acOn == true ? 'מיזוג פעיל' : 'מיזוג כבוי'),
                  Text(
                    [
                      if (c?.setpointDriver != null)
                        'יעד: ${c!.setpointDriver!.toStringAsFixed(0)}°C',
                      if (c?.insideTempC != null)
                        'בתוך הרכב: ${c!.insideTempC!.toStringAsFixed(1)}°C',
                      if (c?.fanLevel != null) 'מאוורר: ${c!.fanLevel}',
                    ].join(' · '),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WindowsCard extends StatelessWidget {
  const _WindowsCard({required this.windows, required this.doors});

  final WindowPercents? windows;
  final DoorLocks? doors;

  @override
  Widget build(BuildContext context) {
    String pct(int? v) => v == null || v < 0 ? '—' : '$v%';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                _MiniMetric(label: 'קד׳ שמ׳', value: pct(windows?.lf)),
                _MiniMetric(label: 'קד׳ ימ׳', value: pct(windows?.rf)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _MiniMetric(label: 'אח׳ שמ׳', value: pct(windows?.lr)),
                _MiniMetric(label: 'אח׳ ימ׳', value: pct(windows?.rr)),
              ],
            ),
            if (doors?.source != null) ...[
              const SizedBox(height: 12),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  'מקור נעילה: ${doors!.source}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  const _MiniMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            Text(value, style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
      ),
    );
  }
}

class _TyresGrid extends StatelessWidget {
  const _TyresGrid({required this.tyres});

  final TyreBlock tyres;

  Widget _corner(String label, TyreCorner? t) {
    final v = t;
    final text = v != null && v.available == true && v.kPa != null
        ? '${v.kPa} kPa · ${v.temperatureC}°C'
        : 'אין אות';
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      subtitle: Text(text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            _corner('קדמי שמאל', tyres.fl),
            _corner('קדמי ימין', tyres.fr),
            _corner('אחורי שמאל', tyres.rl),
            _corner('אחורי ימין', tyres.rr),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = OverdriveColors.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off, size: 72, color: colors.danger),
            const SizedBox(height: 16),
            Text('לא מחובר לרכב', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
