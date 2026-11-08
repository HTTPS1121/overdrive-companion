import 'package:flutter/material.dart';

import '../../core/l10n/l10n_x.dart';
import '../../core/widgets/ltr_metric.dart';
import 'vehicle_hero_visual.dart';

class VehicleHeroPanel extends StatelessWidget {
  const VehicleHeroPanel({
    super.key,
    required this.soc,
    required this.rangeKm,
    required this.locked,
    this.driving,
    this.freshnessLabel,
    this.quickActions,
  });

  final double? soc;
  final int? rangeKm;
  final bool? locked;
  final String? driving;
  final String? freshnessLabel;
  final Widget? quickActions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = context.l10n;
    final pct = (soc ?? 0).clamp(0, 100).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.statusHeroTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (driving != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      driving!,
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ],
              ),
            ),
            if (freshnessLabel != null)
              _QuietBadge(
                icon: Icons.cloud_done_outlined,
                label: freshnessLabel!,
              ),
            if (locked != null) ...[
              const SizedBox(width: 8),
              _QuietBadge(
                icon: locked! ? Icons.lock : Icons.lock_open,
                label: locked! ? l10n.statusLocked : l10n.statusUnlocked,
              ),
            ],
          ],
        ),
        const SizedBox(height: 20),
        Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.statusBatteryLabel,
                      style: theme.textTheme.labelLarge?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          soc != null ? '${soc!.round()}' : '—',
                          style: theme.textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            height: 1,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text('%', style: theme.textTheme.titleLarge),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: soc != null ? pct / 100 : null,
                        minHeight: 8,
                        backgroundColor: scheme.surfaceContainerHighest,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 28),
              if (rangeKm != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      l10n.statusRangeLabel,
                      style: theme.textTheme.labelLarge?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 6),
                    LtrMetricText(
                      '$rangeKm',
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1,
                      ),
                    ),
                    Text(
                      l10n.statusRangeUnit,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        const VehicleHeroVisual(),
        if (quickActions != null) ...[
          const SizedBox(height: 8),
          quickActions!,
        ],
      ],
    );
  }
}

class _QuietBadge extends StatelessWidget {
  const _QuietBadge({required this.icon, required this.label});

  final IconData icon;
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
          Icon(icon, size: 16, color: scheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}
