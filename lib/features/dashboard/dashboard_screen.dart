import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/freshness.dart';
import '../../core/theme/app_text.dart';
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
                return _OfflineDashboard(message: snap.errorMessage ?? 'לא מחובר');
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
                      const _SectionTitle(title: 'צמיגים · TPMS'),
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
    final parts = title.split(' · ');
    if (parts.length == 1) {
      return Text(title, style: hebrewTextStyle(Theme.of(context).textTheme.titleMedium));
    }
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '${parts[0]} · ',
            style: hebrewTextStyle(Theme.of(context).textTheme.titleMedium),
          ),
          TextSpan(
            text: parts[1],
            style: numericTextStyle(Theme.of(context).textTheme.titleMedium),
          ),
        ],
      ),
    );
  }
}

class _ClimateDetailLine extends StatelessWidget {
  const _ClimateDetailLine({required this.climate});

  final ClimateInfo? climate;

  @override
  Widget build(BuildContext context) {
    final c = climate;
    final he = Theme.of(context).textTheme.bodySmall;
    final numStyle = numericTextStyle(he);
    return Text.rich(
      TextSpan(
        style: hebrewTextStyle(he),
        children: [
          if (c?.setpointDriver != null) ...[
            const TextSpan(text: 'יעד: '),
            TextSpan(
              text: '${c!.setpointDriver!.toStringAsFixed(0)}°C',
              style: numStyle,
            ),
          ],
          if (c?.insideTempC != null) ...[
            if (c?.setpointDriver != null) const TextSpan(text: ' · '),
            const TextSpan(text: 'בתוך הרכב: '),
            TextSpan(
              text: '${c!.insideTempC!.toStringAsFixed(1)}°C',
              style: numStyle,
            ),
          ],
          if (c?.fanLevel != null) ...[
            const TextSpan(text: ' · מאוורר: '),
            TextSpan(text: '${c!.fanLevel}', style: numStyle),
          ],
        ],
      ),
    );
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
                  _ClimateDetailLine(climate: c),
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
                child: Text.rich(
                  TextSpan(
                    style: hebrewTextStyle(Theme.of(context).textTheme.bodySmall),
                    children: [
                      const TextSpan(text: 'מקור נעילה: '),
                      TextSpan(
                        text: doors!.source,
                        style: numericTextStyle(Theme.of(context).textTheme.bodySmall),
                      ),
                    ],
                  ),
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
            Text(
              value,
              style: numericTextStyle(Theme.of(context).textTheme.titleLarge),
            ),
          ],
        ),
      ),
    );
  }
}

class _TyresGrid extends StatelessWidget {
  const _TyresGrid({required this.tyres});

  final TyreBlock tyres;

  Widget _corner(BuildContext context, String label, TyreCorner? t) {
    final v = t;
    final text = v != null && v.available == true && v.kPa != null
        ? '${v.kPa} kPa · ${v.temperatureC}°C'
        : 'אין אות';
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: hebrewTextStyle(Theme.of(context).textTheme.titleSmall)),
      subtitle: Text(text, style: numericTextStyle(Theme.of(context).textTheme.bodySmall)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            _corner(context, 'קדמי שמאל', tyres.fl),
            _corner(context, 'קדמי ימין', tyres.fr),
            _corner(context, 'אחורי שמאל', tyres.rl),
            _corner(context, 'אחורי ימין', tyres.rr),
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

/// Full-area offline panel (distinct from live dashboard in screenshots).
class _OfflineDashboard extends StatelessWidget {
  const _OfflineDashboard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = OverdriveColors.of(context);
    return ColoredBox(
      color: const Color(0xFF0B0F14),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off, size: 88, color: colors.danger),
              const SizedBox(height: 20),
              Text(
                'אין חיבור לרכב',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Text(
                'בדוק מנהרה או רשת בית ורענן בהגדרות',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.muted),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
