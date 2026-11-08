import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/freshness.dart';
import '../../core/l10n/l10n_x.dart';
import '../../core/layout/scroll_insets.dart';
import '../../core/layout/screenshot_scope.dart';
import '../../data/models/cloud_status.dart';
import '../../data/models/vehicle_state.dart';
import '../../providers/app_providers.dart';
import '../gps/gps_location_card.dart';
import 'vehicle_hero_panel.dart';

class VehicleStatusScreen extends ConsumerWidget {
  const VehicleStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final asyncSnap = ref.watch(vehicleSnapshotProvider);

    return asyncSnap.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _CenteredMessage(
        icon: Icons.error_outline,
        title: l10n.statusErrorTitle,
        body: e.toString(),
      ),
      data: (snap) {
        if (snap == null) {
          return _CenteredMessage(
            icon: Icons.link_off,
            title: l10n.statusNotConnected,
            body: l10n.statusSetupInSettings,
          );
        }
        if (snap.offline || !snap.state.success) {
          return _CenteredMessage(
            icon: Icons.cloud_off,
            title: l10n.statusServerUnreachable,
            body: snap.errorMessage ?? l10n.statusCheckTunnel,
            action: FilledButton.tonalIcon(
              onPressed: () => ref.read(vehicleSnapshotProvider.notifier).refresh(),
              icon: const Icon(Icons.refresh),
              label: Text(l10n.statusRetry),
            ),
          );
        }

        final freshness = DataFreshness(
          serverEpochSec: snap.state.timestamp,
          fetchedAt: snap.lastUpdated ?? DateTime.now(),
        );
        final driving = snap.gps?.isDriving == true ? l10n.statusDriving : l10n.statusParked;
        final freshnessLabel = ScreenshotScope.of(context)
            ? l10n.freshnessUpdated(l10n.freshnessNow)
            : freshness.fetchedAgoLabelLocalized(l10n, snap.lastUpdated);

        return RefreshIndicator(
          onRefresh: () => ref.read(vehicleSnapshotProvider.notifier).refresh(),
          child: ListView(
            padding: scrollBottomPadding(context, extra: 88),
            children: [
              VehicleHeroPanel(
                soc: snap.state.battery?.soc,
                rangeKm: snap.state.battery?.displayRangeKm,
                locked: snap.state.isLocked,
                driving: driving,
                freshnessLabel: freshnessLabel,
              ),
              if (freshness.isStale) ...[
                const SizedBox(height: 12),
                Card(
                  color: Theme.of(context).colorScheme.tertiaryContainer,
                  child: ListTile(
                    leading: Icon(
                      Icons.schedule,
                      color: Theme.of(context).colorScheme.onTertiaryContainer,
                    ),
                    title: Text(l10n.statusDataStale),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              _MetricGrid(
                climate: snap.state.climate,
                windows: snap.state.windows,
                tyres: snap.state.tyres,
              ),
              if (snap.gps != null) ...[
                const SizedBox(height: 12),
                GpsLocationCard(gps: snap.gps!, compact: true),
              ],
              if (snap.cloud != null) ...[
                const SizedBox(height: 12),
                _CloudStrip(cloud: snap.cloud!),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({this.climate, this.windows, this.tyres});

  final ClimateInfo? climate;
  final WindowPercents? windows;
  final TyreBlock? tyres;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    String win(int? v) => v == null || v < 0 ? '—' : '$v%';
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: _MetricTile(
                icon: Icons.ac_unit,
                title: l10n.sectionClimate,
                value: climate?.acOn == true ? l10n.stateOn : l10n.stateOff,
                subtitle: climate?.insideTempC != null
                    ? '${climate!.insideTempC!.toStringAsFixed(1)}°'
                    : null,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: _MetricTile(
                icon: Icons.filter_drama_outlined,
                title: l10n.sectionWindows,
                value: win(windows?.lf),
                subtitle: win(windows?.lr),
              ),
            ),
          ],
        ),
        if (tyres?.available == true) ...[
          const SizedBox(height: 10),
          _TyreStrip(tyres: tyres!, l10n: l10n),
        ],
      ],
    );
  }
}

class _TyreStrip extends StatelessWidget {
  const _TyreStrip({required this.tyres, required this.l10n});

  final TyreBlock tyres;
  final dynamic l10n;

  String _kpa(TyreCorner? c) => c?.kPa != null ? '${c!.kPa} kPa' : '—';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.tire_repair, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(l10n.sectionTyres, style: theme.textTheme.titleSmall),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _TyreCorner(label: l10n.tyreFrontLeft, value: _kpa(tyres.fl))),
                const SizedBox(width: 8),
                Expanded(child: _TyreCorner(label: l10n.tyreFrontRight, value: _kpa(tyres.fr))),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _TyreCorner(label: l10n.tyreRearLeft, value: _kpa(tyres.rl))),
                const SizedBox(width: 8),
                Expanded(child: _TyreCorner(label: l10n.tyreRearRight, value: _kpa(tyres.rr))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TyreCorner extends StatelessWidget {
  const _TyreCorner({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelMedium),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            textDirection: TextDirection.ltr,
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.icon,
    required this.title,
    required this.value,
    this.subtitle,
    this.wide = false,
  });

  final IconData icon;
  final String title;
  final String value;
  final String? subtitle;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(height: 8),
            Text(title, style: theme.textTheme.labelLarge),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
              textDirection: TextDirection.ltr,
            ),
            if (subtitle != null)
              Text(subtitle!, style: theme.textTheme.bodySmall, textDirection: TextDirection.ltr),
          ],
        ),
      ),
    );
  }
}

class _CloudStrip extends StatelessWidget {
  const _CloudStrip({required this.cloud});

  final CloudStatus cloud;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final ok = cloud.configured && cloud.verified;
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      tileColor: Theme.of(context).colorScheme.surfaceContainerLow,
      leading: const Icon(Icons.cloud_outlined),
      title: Text(l10n.sectionCloud),
      subtitle: Text(ok ? l10n.cloudActive : l10n.cloudPartial),
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
