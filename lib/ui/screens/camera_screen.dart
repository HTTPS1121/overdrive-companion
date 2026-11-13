import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design/od_design.dart';
import '../../icons/od_icon.dart';
import '../../illustrations/od_illustrations.dart';
import '../../state/demo_app_controller.dart';
import '../widgets/od_camera_hotspots.dart';

class CameraScreen extends ConsumerWidget {
  const CameraScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctrl = ref.watch(demoAppControllerProvider);
    final label = ctrl.camModeAll ? 'כל המצלמות' : DemoAppController.cams[ctrl.camSel];
    return ColoredBox(
      color: OdColors.bg,
      child: Column(
        children: [
          Expanded(
            flex: 58,
            child: _CameraStage(label: label, ctrl: ctrl),
          ),
          const Expanded(
            flex: 20,
            child: _LiveUtilityRail(),
          ),
        ],
      ),
    );
  }
}

class _CameraStage extends StatelessWidget {
  const _CameraStage({required this.label, required this.ctrl});

  final String label;
  final DemoAppController ctrl;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF0E2238),
      child: Stack(
        fit: StackFit.expand,
        children: [
          OdSceneView(label: label, height: double.infinity, dark: true),
          Positioned(
            top: 10,
            left: 14,
            right: 14,
            child: Row(
              children: [
                const _ConnDot(),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xD9FFFFFF),
                    border: Border.all(color: OdColors.line),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text('בינוני · דמו', style: odMuted(11).copyWith(fontWeight: FontWeight.w600, color: OdColors.ink)),
                ),
                const SizedBox(width: 6),
                _TopIconBtn(icon: OdIconName.settings, semantic: 'העדפות'),
                const SizedBox(width: 4),
                _TopIconBtn(icon: OdIconName.camera, semantic: 'מסך מלא'),
              ],
            ),
          ),
          Positioned(
            right: 12,
            bottom: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xDB0C2348),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(label, style: odBody(12, FontWeight.w600, Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopIconBtn extends StatelessWidget {
  const _TopIconBtn({required this.icon, required this.semantic});

  final OdIconName icon;
  final String semantic;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semantic,
      child: Material(
        color: const Color(0xD9FFFFFF),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () {},
          child: SizedBox(
            width: 36,
            height: 36,
            child: Center(child: OdIcon(icon, size: 17, color: OdColors.ink)),
          ),
        ),
      ),
    );
  }
}

class _LiveUtilityRail extends StatelessWidget {
  const _LiveUtilityRail();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: OdColors.bg,
        border: Border(top: BorderSide(color: OdColors.line)),
      ),
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 6),
      child: const Row(
        children: [
          Expanded(flex: 58, child: _CameraSelectorCard()),
          SizedBox(width: 8),
          Expanded(child: _LocationCard()),
        ],
      ),
    );
  }
}

class _CameraSelectorCard extends StatelessWidget {
  const _CameraSelectorCard();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
        border: Border.all(color: OdColors.cardBorder),
        boxShadow: const [OdShadows.card],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 9, 10, 4),
            child: Text('מצלמות', style: odBody(12, FontWeight.w600)),
          ),
          const Expanded(
            child: ClipRect(
              child: Center(
                child: OdCameraSelectorDiagram(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
        border: Border.all(color: OdColors.cardBorder),
        boxShadow: const [OdShadows.card],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 7, 10, 4),
            child: Row(
              children: [
                Text('מיקום הרכב', style: odBody(12, FontWeight.w600)),
                const Spacer(),
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(color: Color(0xFF2D9F6F), shape: BoxShape.circle),
                ),
                const SizedBox(width: 4),
                Text('2 דק׳', style: odMuted(10)),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7),
              child: LayoutBuilder(
                builder: (context, c) {
                  return DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: OdColors.line),
                      color: const Color(0xFFDAE5F0),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                      child: OdMapIllustration(height: c.maxHeight),
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(7, 4, 7, 6),
            child: Material(
              color: OdColors.navActiveBg,
              borderRadius: BorderRadius.circular(99),
              child: InkWell(
                borderRadius: BorderRadius.circular(99),
                onTap: () {},
                child: SizedBox(
                  height: 32,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const OdIcon(OdIconName.pin, size: 15, color: OdColors.navActiveFg),
                      const SizedBox(width: 6),
                      Text('הרחב מפה', style: odBody(11, FontWeight.w600, OdColors.navActiveFg)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConnDot extends StatefulWidget {
  const _ConnDot();

  @override
  State<_ConnDot> createState() => _ConnDotState();
}

class _ConnDotState extends State<_ConnDot> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 0.55, end: 1.0).animate(_c),
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: const Color(0xFF2D9F6F),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: OdColors.ink.withValues(alpha: 0.12), blurRadius: 0, spreadRadius: 3),
          ],
        ),
      ),
    );
  }
}
