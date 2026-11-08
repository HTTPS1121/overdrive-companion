import 'package:flutter/material.dart';

import '../../core/l10n/l10n_x.dart';

/// Bundled BYD Atto 3 reference image — see `assets/images/ATTRIBUTION.md`.
class VehicleHeroVisual extends StatelessWidget {
  const VehicleHeroVisual({super.key});

  static const assetPath = 'assets/images/byd-atto3-hero.png';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    return Semantics(
      label: l10n.statusHeroImageLabel,
      child: Column(
        children: [
          const SizedBox(height: 8),
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  scheme.surfaceContainerHighest.withValues(alpha: 0.35),
                  scheme.surfaceContainerLow,
                ],
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                child: Center(
                  child: Image.asset(
                    assetPath,
                    height: 108,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    filterQuality: FilterQuality.medium,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.directions_car_filled,
                      size: 88,
                      color: scheme.primary.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.statusHeroAttribution,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}
