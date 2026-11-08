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
import 'status_quick_actions.dart';
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
            body: _localizedSnapshotError(l10n, snap.errorMessage),
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
            padding: scrollBottomPadding(context, horizontal: 20, extra: 72),
            children: [
              VehicleHeroPanel(
                soc: snap.state.battery?.soc,
                rangeKm: snap.state.battery?.displayRangeKm,
                locked: snap.state.isLocked,
                driving: driving,
                freshnessLabel: freshnessLabel,
                quickActions: StatusQuickActions(snap: snap),
              ),
              if (freshness.isStale) ...[
                const SizedBox(height: 16),
                _InlineNotice(
                  icon: Icons.schedule,
                  text: l10n.statusDataStale,
                  color: Theme.of(context).colorScheme.tertiaryContainer,
                ),
              ],
              const SizedBox(height: 24),
              _QuietSecondaryRow(
                climate: snap.state.climate,
                windows: snap.state.windows,
              ),
              if (snap.state.tyres?.available == true) ...[
                const SizedBox(height: 12),
                _CompactTyreRow(tyres: snap.state.tyres!, l10n: l10n),
              ],
              if (snap.gps != null) ...[
                const SizedBox(height: 12),
                GpsLocationCard(gps: snap.gps!, compact: true),
              ],
              if (snap.cloud != null) ...[
                const SizedBox(height: 12),
                _CloudInline(cloud: snap.cloud!),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _QuietSecondaryRow extends StatelessWidget {
  const _QuietSecondaryRow({this.climate, this.windows});

  final ClimateInfo? climate;
  final WindowPercents? windows;

  String _win(int? v) => v == null || v < 0 ? '—' : '$v%';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 3,
            child: _SecondaryTile(
              icon: Icons.ac_unit_outlined,
              label: l10n.sectionClimate,
              value: climate?.acOn == true ? l10n.stateOn : l10n.stateOff,
              detail: climate?.insideTempC != null
                  ? '${climate!.insideTempC!.toStringAsFixed(1)}°'
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: _SecondaryTile(
              icon: Icons.filter_drama_outlined,
              label: l10n.sectionWindows,
              value: _win(windows?.lf),
              detail: _win(windows?.lr),
            ),
          ),
        ],
      ),
    );
  }
}

class _SecondaryTile extends StatelessWidget {
  const _SecondaryTile({
    required this.icon,
    required this.label,
    required this.value,
    this.detail,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Material(
      color: scheme.surfaceContainer,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: scheme.onSurfaceVariant),
            const SizedBox(height: 10),
            Text(label, style: theme.textTheme.labelLarge),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              textDirection: TextDirection.ltr,
            ),
            if (detail != null)
              Text(detail!, style: theme.textTheme.bodySmall, textDirection: TextDirection.ltr),
          ],
        ),
      ),
    );
  }
}

class _CompactTyreRow extends StatelessWidget {
  const _CompactTyreRow({required this.tyres, required this.l10n});

  final TyreBlock tyres;
  final dynamic l10n;

  String _kpa(TyreCorner? c) => c?.kPa != null ? '${c!.kPa}' : '—';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Material(
      color: scheme.surfaceContainer,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(Icons.tire_repair_outlined, color: scheme.onSurfaceVariant),
            const SizedBox(width: 12),
            Expanded(
              child: Text(l10n.sectionTyres, style: theme.textTheme.labelLarge),
            ),
            _TyreMini(label: 'FL', value: _kpa(tyres.fl)),
            const SizedBox(width: 8),
            _TyreMini(label: 'FR', value: _kpa(tyres.fr)),
            const SizedBox(width: 8),
            _TyreMini(label: 'RL', value: _kpa(tyres.rl)),
            const SizedBox(width: 8),
            _TyreMini(label: 'RR', value: _kpa(tyres.rr)),
          ],
        ),
      ),
    );
  }
}

class _TyreMini extends StatelessWidget {
  const _TyreMini({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        Text(value, style: Theme.of(context).textTheme.bodyMedium, textDirection: TextDirection.ltr),
      ],
    );
  }
}

class _CloudInline extends StatelessWidget {
  const _CloudInline({required this.cloud});

  final CloudStatus cloud;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final ok = cloud.configured && cloud.verified;
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(Icons.cloud_outlined, color: scheme.onSurfaceVariant),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                ok ? l10n.cloudActive : l10n.cloudPartial,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineNotice extends StatelessWidget {
  const _InlineNotice({required this.icon, required this.text, required this.color});

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(16),
      child: ListTile(
        dense: true,
        leading: Icon(icon),
        title: Text(text),
      ),
    );
  }
}

String _localizedSnapshotError(dynamic l10n, String? code) {
  switch (code) {
    case 'connection_not_configured':
    case 'connection not configured':
      return l10n.errorConnectionNotConfigured;
    default:
      return code ?? l10n.statusCheckTunnel;
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
