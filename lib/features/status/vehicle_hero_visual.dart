import 'package:flutter/material.dart';

import '../../core/l10n/l10n_x.dart';

/// Bundled BYD Atto 3 reference — see `assets/images/ATTRIBUTION.md`.
/// Rendered as a center hero (contain, soft ground) without a framed showroom card.
class VehicleHeroVisual extends StatelessWidget {
  const VehicleHeroVisual({super.key});

  static const assetPath = 'assets/images/byd-atto3-hero.png';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    final ground = Color.lerp(
      scheme.surface,
      scheme.primaryContainer,
      scheme.brightness == Brightness.dark ? 0.22 : 0.12,
    )!;

    return Semantics(
      label: l10n.statusHeroImageLabel,
      child: SizedBox(
        height: 188,
        width: double.infinity,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Positioned(
              bottom: 8,
              left: 24,
              right: 24,
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.1,
                    colors: [
                      scheme.primary.withValues(
                        alpha: scheme.brightness == Brightness.dark ? 0.22 : 0.12,
                      ),
                      ground.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 6),
                child: ShaderMask(
                  shaderCallback: (rect) => LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      scheme.surface,
                      scheme.surface,
                      Colors.transparent,
                    ],
                    stops: const [0, 0.12, 0.88, 1],
                  ).createShader(rect),
                  blendMode: BlendMode.dstIn,
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      scheme.surface.withValues(alpha: scheme.brightness == Brightness.dark ? 0.35 : 0.08),
                      BlendMode.darken,
                    ),
                    child: Image.asset(
                      assetPath,
                      height: 168,
                      fit: BoxFit.contain,
                      alignment: Alignment.bottomCenter,
                      filterQuality: FilterQuality.medium,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.directions_car_filled_rounded,
                        size: 96,
                        color: scheme.primary.withValues(alpha: 0.45),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
