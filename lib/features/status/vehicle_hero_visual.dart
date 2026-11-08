import 'package:flutter/material.dart';

/// Bundled BYD Atto 3 reference image — see `assets/images/ATTRIBUTION.md`.
class VehicleHeroVisual extends StatelessWidget {
  const VehicleHeroVisual({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: 'BYD Atto 3',
      child: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Center(
          child: Image.asset(
            'assets/images/byd-atto3-hero.png',
            height: 118,
            fit: BoxFit.contain,
            color: scheme.brightness == Brightness.dark
                ? scheme.onSurface.withValues(alpha: 0.92)
                : null,
            colorBlendMode: scheme.brightness == Brightness.dark ? BlendMode.modulate : null,
            filterQuality: FilterQuality.medium,
            errorBuilder: (_, __, ___) => Icon(
              Icons.directions_car_filled,
              size: 88,
              color: scheme.primary.withValues(alpha: 0.5),
            ),
          ),
        ),
      ),
    );
  }
}
