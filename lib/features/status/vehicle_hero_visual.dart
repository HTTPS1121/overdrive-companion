import 'package:flutter/material.dart';

import '../../core/l10n/l10n_x.dart';

/// BYD Atto 3 cutout — source Wikimedia, background removed (see ATTRIBUTION.md).
class VehicleHeroVisual extends StatelessWidget {
  const VehicleHeroVisual({super.key});

  static const assetPath = 'assets/images/byd-atto3-hero-cutout.png';
  static const legacyAssetPath = 'assets/images/byd-atto3-hero.png';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    return Semantics(
      label: l10n.statusHeroImageLabel,
      child: SizedBox(
        height: 176,
        width: double.infinity,
        child: Stack(
          alignment: Alignment.bottomCenter,
          clipBehavior: Clip.none,
          children: [
            Positioned(
              bottom: 6,
              child: Container(
                width: 220,
                height: 18,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                      color: scheme.shadow.withValues(alpha: 0.22),
                      blurRadius: 18,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Image.asset(
                assetPath,
                height: 168,
                fit: BoxFit.contain,
                alignment: Alignment.bottomCenter,
                filterQuality: FilterQuality.medium,
                errorBuilder: (_, __, ___) => Image.asset(
                  legacyAssetPath,
                  height: 168,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
