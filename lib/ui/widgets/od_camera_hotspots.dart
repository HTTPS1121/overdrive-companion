import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design/od_design.dart';
import '../../design/od_fonts.dart';
import '../../illustrations/od_illustrations.dart';
import '../../state/companion_app_controller.dart';

/// Car diagram + hotspots from `overdrive-chosen.html` (60×126 car, 32px hotspots).
class OdCameraSelectorDiagram extends ConsumerWidget {
  const OdCameraSelectorDiagram({super.key});

  static const _carW = 60.0;
  static const _carH = 126.0;
  static const _gutterTop = 14.0;
  static const _gutterBottom = 16.0;
  static const _dot = 32.0;
  /// Wider than the car so DVR label can sit to the right of the front arc (HTML overflow).
  static const _canvasW = 98.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctrl = ref.watch(companionAppControllerProvider);
    const carW = _carW;
    const carH = _carH;
    const boxH = carH + _gutterTop + _gutterBottom;
    final carLeft = (_canvasW - carW) / 2;

    return Center(
      child: SizedBox(
        width: _canvasW,
        height: boxH,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: carLeft,
              top: _gutterTop,
              width: carW,
              height: carH,
              child: const OdCarTopDown(),
            ),
            _hotspot(ref, ctrl, 1, 'חזית', left: carLeft + (carW - _dot) / 2, top: _gutterTop - 6),
            _hotspot(ref, ctrl, 3, 'אחור', left: carLeft + (carW - _dot) / 2, top: _gutterTop + carH - _dot + 6),
            _hotspot(ref, ctrl, 4, 'שמאל', left: carLeft - 16, top: _gutterTop + carH / 2 - _dot / 2),
            _hotspot(ref, ctrl, 2, 'ימין', left: carLeft + carW - _dot + 16, top: _gutterTop + carH / 2 - _dot / 2),
            _hotspot(
              ref,
              ctrl,
              0,
              'הכל',
              left: carLeft + (carW - _dot) / 2,
              top: _gutterTop + carH / 2 - _dot / 2,
              labelBelowCenter: true,
            ),
            _hotspot(
              ref,
              ctrl,
              6,
              'DVR',
              left: carLeft + carW * 0.62 - _dot / 2,
              top: _gutterTop + 18,
              dvrLabel: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _hotspot(
    WidgetRef ref,
    CompanionAppController ctrl,
    int id,
    String label, {
    required double left,
    required double top,
    bool labelBelowCenter = false,
    bool dvrLabel = false,
  }) {
    return Positioned(
      left: left,
      top: top,
      child: _HotspotDot(
        label: label,
        active: ctrl.odCamHotspotActive(id),
        labelBelow: id == 3,
        labelOnStart: id == 4,
        labelOnEnd: id == 2 || dvrLabel,
        labelBelowCenter: labelBelowCenter,
        onTap: () => ref.read(companionAppControllerProvider).selectOdCamHotspot(id),
      ),
    );
  }
}

class _HotspotDot extends StatelessWidget {
  const _HotspotDot({
    required this.label,
    required this.active,
    required this.onTap,
    this.labelBelow = false,
    this.labelOnStart = false,
    this.labelOnEnd = false,
    this.labelBelowCenter = false,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;
  final bool labelBelow;
  final bool labelOnStart;
  final bool labelOnEnd;
  final bool labelBelowCenter;

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
    Widget labelChip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: active ? OdColors.blue : Colors.white,
        border: Border.all(color: active ? OdColors.blue : OdColors.line),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(label, style: labelStyle),
    );

    if (labelOnEnd) {
      labelChip = Positioned(
        left: 35,
        top: 0,
        bottom: 0,
        child: Center(child: labelChip),
      );
    } else if (labelOnStart) {
      labelChip = Positioned(
        right: 35,
        top: 0,
        bottom: 0,
        child: Center(child: labelChip),
      );
    } else if (labelBelow) {
      labelChip = Positioned(top: 35, left: 0, right: 0, child: Center(child: labelChip));
    } else if (labelBelowCenter) {
      labelChip = Positioned(top: 45, left: 0, right: 0, child: Center(child: labelChip));
    } else {
      labelChip = Positioned(bottom: 26, left: 0, right: 0, child: Center(child: labelChip));
    }

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 32,
        height: 32,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            labelChip,
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
