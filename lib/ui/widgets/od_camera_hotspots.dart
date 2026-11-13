import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design/od_design.dart';
import '../../design/od_fonts.dart';
import '../../illustrations/od_illustrations.dart';
import '../../state/companion_app_controller.dart';

/// Car diagram + hotspots from `overdrive-chosen.html` (60×126 car, 32px hotspots).
class OdCameraSelectorDiagram extends ConsumerWidget {
  const OdCameraSelectorDiagram({super.key});

  static const _carW = 81.0;
  static const _carH = 152.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctrl = ref.watch(companionAppControllerProvider);
    return LayoutBuilder(
      builder: (context, constraints) {
        const scale = 1.0;
        final carW = _carW * scale;
        final carH = _carH * scale;
        final padX = 32 * scale;
        final boxW = carW + padX * 2;
        final boxH = carH + 12 * scale;
        final left = padX;

        return Center(
          child: SizedBox(
            width: boxW,
            height: boxH,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: left,
                  top: 6 * scale,
                  width: carW,
                  height: carH,
                  child: const OdCarTopDown(),
                ),
                _hotspot(
                  ref,
                  ctrl,
                  1,
                  'חזית',
                  left + carW / 2 - 16 * scale,
                  0,
                ),
                _hotspot(
                  ref,
                  ctrl,
                  3,
                  'אחור',
                  left + carW / 2 - 16 * scale,
                  6 * scale + carH - 10 * scale,
                ),
                _hotspot(
                  ref,
                  ctrl,
                  4,
                  'שמאל',
                  left - 16 * scale,
                  6 * scale + carH / 2 - 16 * scale,
                ),
                _hotspot(
                  ref,
                  ctrl,
                  2,
                  'ימין',
                  left + carW - 16 * scale,
                  6 * scale + carH / 2 - 16 * scale,
                ),
                _hotspot(
                  ref,
                  ctrl,
                  0,
                  'הכל',
                  left + carW / 2 - 16 * scale,
                  6 * scale + carH / 2 - 16 * scale,
                ),
                _hotspot(
                  ref,
                  ctrl,
                  6,
                  'DVR',
                  left + carW * 0.62 - 16 * scale,
                  6 * scale + 18 * scale,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _hotspot(
    WidgetRef ref,
    CompanionAppController ctrl,
    int id,
    String label,
    double x,
    double y,
  ) {
    final active = ctrl.odCamHotspotActive(id);
    return Positioned(
      left: x,
      top: y,
      child: _HotspotDot(
        label: label,
        active: active,
        onTap: () => ref.read(companionAppControllerProvider).selectOdCamHotspot(id),
      ),
    );
  }
}

class _HotspotDot extends StatelessWidget {
  const _HotspotDot({required this.label, required this.active, required this.onTap});

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isLatin = label.codeUnitAt(0) < 0x0590;
    final labelStyle = TextStyle(
      fontFamily: isLatin ? OdFonts.latin : OdFonts.hebrew,
      fontFamilyFallback: OdFonts.fallback,
      fontSize: 8,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.04,
      color: active ? Colors.white : OdColors.ink,
    );
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 32,
        height: 32,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Positioned(
              bottom: 26,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: active ? OdColors.blue : Colors.white,
                  border: Border.all(color: active ? OdColors.blue : OdColors.line),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(label, style: labelStyle),
              ),
            ),
            Container(
              width: 21,
              height: 21,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: active ? const Color(0xFFE8F0FC) : Colors.white,
                border: Border.all(color: active ? OdColors.blue : const Color(0xFFB8C8DC), width: 2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
