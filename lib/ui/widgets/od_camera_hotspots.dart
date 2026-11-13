import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design/od_design.dart';
import '../../design/od_fonts.dart';
import '../../illustrations/od_illustrations.dart';
import '../../state/demo_app_controller.dart';

/// Car-diagram camera hotspots from `overdrive-chosen.html`.
class OdCameraSelectorDiagram extends ConsumerWidget {
  const OdCameraSelectorDiagram({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctrl = ref.watch(demoAppControllerProvider);
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: SizedBox(
        width: 108,
        height: 142,
        child: Stack(
          clipBehavior: Clip.hardEdge,
          alignment: Alignment.center,
          children: [
            const Positioned(
              top: 16,
              left: 22,
              right: 22,
              bottom: 16,
              child: OdCarTopDown(),
            ),
            _spot(ref, ctrl, 1, 'חזית', const Alignment(0, -1.02)),
            _spot(ref, ctrl, 3, 'אחור', const Alignment(0, 1.02)),
            _spot(ref, ctrl, 4, 'שמאל', const Alignment(-1.05, 0)),
            _spot(ref, ctrl, 2, 'ימין', const Alignment(1.05, 0)),
            _spot(ref, ctrl, 0, 'הכל', const Alignment(0, 0.28)),
            _spot(ref, ctrl, 6, 'DVR', const Alignment(0.38, -0.42)),
          ],
        ),
      ),
    );
  }

  Widget _spot(WidgetRef ref, DemoAppController ctrl, int id, String label, Alignment align) {
    final active = ctrl.odCamHotspotActive(id);
    return Align(
      alignment: align,
      child: _HotspotDot(
        label: label,
        active: active,
        onTap: () => ref.read(demoAppControllerProvider).selectOdCamHotspot(id),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: active ? OdColors.blue : Colors.white,
              border: Border.all(color: active ? OdColors.blue : OdColors.line),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(label, style: labelStyle),
          ),
          const SizedBox(height: 1),
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
    );
  }
}
