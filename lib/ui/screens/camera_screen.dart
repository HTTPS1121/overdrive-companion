import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design/od_design.dart';
import '../../icons/od_icon.dart';
import '../../illustrations/od_illustrations.dart';
import '../../state/demo_app_controller.dart';

class CameraScreen extends ConsumerWidget {
  const CameraScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctrl = ref.watch(demoAppControllerProvider);
    final label = ctrl.camModeAll ? 'כל המצלמות' : DemoAppController.cams[ctrl.camSel];
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              OdSceneView(label: label, height: double.infinity),
              Positioned(
                top: 12,
                left: 14,
                right: 14,
                child: Row(
                  children: [
                    _ConnDot(),
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
                      child: const Text('בינוני · דמו', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                    ),
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
                  child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 220,
          child: Row(
            children: [
              Expanded(
                flex: 58,
                child: _CameraSelector(ctrl: ctrl),
              ),
              Expanded(
                child: _LocationCard(ctrl: ctrl),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ConnDot extends StatefulWidget {
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

class _CameraSelector extends ConsumerWidget {
  const _CameraSelector({required this.ctrl});

  final DemoAppController ctrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 4, 4, 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
        border: Border.all(color: OdColors.cardBorder),
        boxShadow: const [OdShadows.card],
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(10, 9, 10, 6),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text('מצלמות', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ),
          Expanded(
            child: Center(
              child: const OdCarTopDown(),
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({required this.ctrl});

  final DemoAppController ctrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(4, 4, 8, 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
        border: Border.all(color: OdColors.cardBorder),
        boxShadow: const [OdShadows.card],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(10, 9, 10, 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('מיקום הרכב', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                SizedBox(height: 3),
                Row(
                  children: [
                    _FreshDot(),
                    SizedBox(width: 5),
                    Text('לפני 2 דק׳ · דמו', style: TextStyle(fontSize: 10, color: OdColors.muted)),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: const OdMapIllustration(height: double.infinity),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(7, 8, 7, 10),
            child: Material(
              color: OdColors.navActiveBg,
              borderRadius: BorderRadius.circular(99),
              child: InkWell(
                borderRadius: BorderRadius.circular(99),
                onTap: () {},
                child: const SizedBox(
                  height: 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OdIcon(OdIconName.pin, size: 15, color: OdColors.navActiveFg),
                      SizedBox(width: 6),
                      Text('הרחב מפה', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: OdColors.navActiveFg)),
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

class _FreshDot extends StatelessWidget {
  const _FreshDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: const BoxDecoration(color: Color(0xFF2D9F6F), shape: BoxShape.circle),
    );
  }
}
