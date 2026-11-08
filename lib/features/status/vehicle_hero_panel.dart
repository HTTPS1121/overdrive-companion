import 'package:flutter/material.dart';

import '../../core/l10n/l10n_x.dart';
import 'vehicle_silhouette.dart';

class VehicleHeroPanel extends StatelessWidget {
  const VehicleHeroPanel({
    super.key,
    required this.soc,
    required this.rangeKm,
    required this.locked,
    this.driving,
    this.freshnessLabel,
  });

  final double? soc;
  final int? rangeKm;
  final bool? locked;
  final String? driving;
  final String? freshnessLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = context.l10n;
    final pct = (soc ?? 0).clamp(0, 100).toDouble();

    return Material(
      color: scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(28),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: 4,
                  right: -8,
                  child: Opacity(
                    opacity: 0.85,
                    child: VehicleSilhouette(
                      height: 76,
                      color: scheme.primary.withValues(alpha: 0.22),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.statusHeroTitle,
                      style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    if (driving != null) ...[
                      const SizedBox(height: 6),
                      Text(driving!, style: theme.textTheme.bodyMedium),
                    ],
                    const SizedBox(height: 18),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 88,
                            height: 88,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox.expand(
                                  child: CircularProgressIndicator(
                                    value: soc != null ? pct / 100 : null,
                                    strokeWidth: 8,
                                    backgroundColor: scheme.surfaceContainerHighest,
                                  ),
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      soc != null ? '${soc!.round()}' : '—',
                                      style: theme.textTheme.headlineMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text('%', style: theme.textTheme.labelLarge),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          if (rangeKm != null)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$rangeKm',
                                  style: theme.textTheme.displaySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
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
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (locked != null)
                  _Chip(
                    icon: locked! ? Icons.lock : Icons.lock_open,
                    label: locked! ? l10n.statusLocked : l10n.statusUnlocked,
                  ),
                if (freshnessLabel != null)
                  _Chip(icon: Icons.cloud_done, label: freshnessLabel!),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: scheme.onSecondaryContainer),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.labelLarge),
        ],
      ),
    );
  }
}
