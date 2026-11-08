import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/freshness.dart';
import '../../core/l10n/l10n_x.dart';
import '../../core/layout/scroll_insets.dart';
import '../../core/layout/screenshot_scope.dart';
import '../../providers/app_providers.dart';
import 'status_home_cards.dart';
import 'status_shell_scope.dart';
import 'vehicle_hero_visual.dart';

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
        final shell = StatusShellScope.maybeOf(context);
        final locationLine = snap.gps?.hasLocation == true ? snap.gps!.coordinatesLabel : null;

        return RefreshIndicator(
          onRefresh: () => ref.read(vehicleSnapshotProvider.notifier).refresh(),
          child: ListView(
            padding: scrollBottomPadding(context, extra: 40),
            children: [
              StatusHomeHeader(
                connected: !snap.offline,
                freshnessLabel: freshnessLabel,
                onOpenSettings: shell == null ? null : () => shell.selectTab(4),
              ),
              const SizedBox(height: 20),
              StatusModelHeading(locationLine: locationLine ?? driving),
              const SizedBox(height: 12),
              const VehicleHeroVisual(),
              const SizedBox(height: 12),
              StatusSecuredPill(locked: snap.state.isLocked),
              const SizedBox(height: 20),
              StatusBatteryRangeRow(
                soc: snap.state.battery?.soc,
                rangeKm: snap.state.battery?.displayRangeKm,
              ),
              if (freshness.isStale) ...[
                const SizedBox(height: 14),
                _StaleBanner(text: l10n.statusDataStale),
              ],
              if (snap.state.tyres?.available == true) ...[
                const SizedBox(height: 16),
                StatusTyreStrip(tyres: snap.state.tyres!, l10n: l10n),
              ],
              const SizedBox(height: 12),
              StatusSecondaryPair(climate: snap.state.climate, windows: snap.state.windows),
              if (snap.gps?.hasLocation == true) ...[
                const SizedBox(height: 12),
                StatusGpsFootnote(coordinates: snap.gps!.coordinatesLabel),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _StaleBanner extends StatelessWidget {
  const _StaleBanner({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.tertiaryContainer,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Icon(Icons.schedule, size: 18, color: scheme.onTertiaryContainer),
            const SizedBox(width: 10),
            Expanded(child: Text(text, style: TextStyle(color: scheme.onTertiaryContainer))),
          ],
        ),
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
