import 'package:flutter/material.dart';

import '../../core/l10n/l10n_x.dart';
import '../../core/widgets/ltr_metric.dart';
import '../../data/models/vehicle_state.dart';

class StatusHomeHeader extends StatelessWidget {
  const StatusHomeHeader({
    super.key,
    required this.connected,
    this.freshnessLabel,
    this.onOpenSettings,
  });

  final bool connected;
  final String? freshnessLabel;
  final VoidCallback? onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: scheme.primaryContainer,
          child: Icon(Icons.electric_car_outlined, color: scheme.onPrimaryContainer, size: 22),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.statusIdentityLabel, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
              Text(
                l10n.statusIdentityCaption,
                style: theme.textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
        _ConnectedPill(connected: connected, label: freshnessLabel ?? l10n.statusConnected),
        if (onOpenSettings != null) ...[
          const SizedBox(width: 6),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: onOpenSettings,
            icon: const Icon(Icons.menu_rounded),
          ),
        ],
      ],
    );
  }
}

class _ConnectedPill extends StatelessWidget {
  const _ConnectedPill({required this.connected, required this.label});

  final bool connected;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: connected ? scheme.primary : scheme.outline,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class StatusModelHeading extends StatelessWidget {
  const StatusModelHeading({super.key, this.locationLine});

  final String? locationLine;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final subtitle = locationLine;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.statusModelName,
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.place_outlined, size: 16, color: scheme.onSurfaceVariant),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class StatusSecuredPill extends StatelessWidget {
  const StatusSecuredPill({super.key, required this.locked});

  final bool? locked;

  @override
  Widget build(BuildContext context) {
    if (locked == null) return const SizedBox.shrink();
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final secured = locked!;
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: scheme.inverseSurface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              secured ? Icons.lock : Icons.lock_open,
              size: 16,
              color: scheme.onInverseSurface,
            ),
            const SizedBox(width: 8),
            Text(
              secured ? l10n.statusSecuredLocked : l10n.statusSecuredUnlocked,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: scheme.onInverseSurface,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class StatusBatteryRangeRow extends StatelessWidget {
  const StatusBatteryRangeRow({super.key, required this.soc, required this.rangeKm});

  final double? soc;
  final int? rangeKm;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final pct = (soc ?? 0).clamp(0, 100).toDouble();

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _MetricCard(
              icon: Icons.battery_charging_full_outlined,
              label: l10n.statusBatteryLabel,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      soc != null ? '${soc!.round()}%' : '—',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: soc != null ? pct / 100 : null,
                      minHeight: 6,
                      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _MetricCard(
              icon: Icons.route_outlined,
              label: l10n.statusRangeLabel,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LtrMetricText(
                    rangeKm != null ? '$rangeKm' : '—',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    l10n.statusRangeUnit,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.statusRangeHint,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.icon, required this.label, required this.child});

  final IconData icon;
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Material(
      color: scheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: scheme.primary),
                const SizedBox(width: 8),
                Text(
                  label.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    letterSpacing: 0.6,
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class StatusTyreStrip extends StatelessWidget {
  const StatusTyreStrip({super.key, required this.tyres, required this.l10n});

  final TyreBlock tyres;
  final dynamic l10n;

  String _kpa(TyreCorner? c) => c?.kPa != null ? '${c!.kPa}' : '—';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Material(
      color: scheme.primaryContainer,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: scheme.onPrimaryContainer.withValues(alpha: 0.12),
              child: Icon(Icons.tire_repair_outlined, color: scheme.onPrimaryContainer),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.sectionTyres.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.onPrimaryContainer.withValues(alpha: 0.8),
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    l10n.statusTyresOk,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: scheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            _TyreReadout(label: 'FL', value: _kpa(tyres.fl), scheme: scheme),
            const SizedBox(width: 10),
            _TyreReadout(label: 'FR', value: _kpa(tyres.fr), scheme: scheme),
            const SizedBox(width: 10),
            _TyreReadout(label: 'RL', value: _kpa(tyres.rl), scheme: scheme),
            const SizedBox(width: 10),
            _TyreReadout(label: 'RR', value: _kpa(tyres.rr), scheme: scheme),
          ],
        ),
      ),
    );
  }
}

class _TyreReadout extends StatelessWidget {
  const _TyreReadout({required this.label, required this.value, required this.scheme});

  final String label;
  final String value;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: scheme.onPrimaryContainer)),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: scheme.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
          textDirection: TextDirection.ltr,
        ),
      ],
    );
  }
}

class StatusSecondaryPair extends StatelessWidget {
  const StatusSecondaryPair({super.key, this.climate, this.windows});

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
            child: _SmallCard(
              label: l10n.sectionClimate,
              value: climate?.acOn == true ? l10n.stateOn : l10n.stateOff,
              detail: climate?.insideTempC != null
                  ? '${climate!.insideTempC!.toStringAsFixed(0)}°'
                  : null,
              trailing: climate?.acOn == true
                  ? Icon(Icons.ac_unit, color: Theme.of(context).colorScheme.primary, size: 22)
                  : Icon(Icons.ac_unit_outlined, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 22),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _SmallCard(
              label: l10n.sectionWindows,
              value: _win(windows?.lf),
              detail: _win(windows?.lr),
              trailing: Icon(Icons.filter_drama_outlined, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallCard extends StatelessWidget {
  const _SmallCard({
    required this.label,
    required this.value,
    this.detail,
    this.trailing,
  });

  final String label;
  final String value;
  final String? detail;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Material(
      color: scheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                color: scheme.onSurfaceVariant,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        value,
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
                        textDirection: TextDirection.ltr,
                      ),
                      if (detail != null)
                        Text(detail!, style: theme.textTheme.bodySmall, textDirection: TextDirection.ltr),
                    ],
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class StatusGpsFootnote extends StatelessWidget {
  const StatusGpsFootnote({super.key, required this.coordinates});

  final String coordinates;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: LtrMetricRow(label: l10n.gpsCoordinates, value: coordinates),
      ),
    );
  }
}
