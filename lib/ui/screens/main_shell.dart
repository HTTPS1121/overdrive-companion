import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../demo/demo_models.dart';
import '../../design/od_design.dart';
import '../../state/demo_app_controller.dart';
import '../widgets/od_widgets.dart';
import 'camera_screen.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'more_screen.dart';
import 'recordings_screen.dart';
import 'trip_screen.dart';

class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctrl = ref.watch(demoAppControllerProvider);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: RepaintBoundary(
        key: const ValueKey('screenshot_root'),
        child: Stack(
        children: [
          ColoredBox(
            color: OdColors.pageChrome,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: ColoredBox(
                  color: OdColors.bg,
                  child: ctrl.loginVisible
                      ? const LoginScreen()
                      : _AppBody(screen: ctrl.screen),
                ),
              ),
            ),
          ),
          if (!ctrl.loginVisible) const OdSheetOverlay(),
        ],
        ),
      ),
    );
  }
}

class _AppBody extends StatelessWidget {
  const _AppBody({required this.screen});

  final OdScreen screen;

  @override
  Widget build(BuildContext context) {
    final bottomPad = 112 + MediaQuery.paddingOf(context).bottom;
    final showDemoOnCamera = screen != OdScreen.camera && screen != OdScreen.record;
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, bottomPad),
          child: Column(
            children: [
              const OdTopBar(),
              if (showDemoOnCamera) const OdDemoBanner(),
              Expanded(child: _ScreenBody(screen: screen)),
            ],
          ),
        ),
        const OdBottomNav(),
      ],
    );
  }
}

class _ScreenBody extends StatelessWidget {
  const _ScreenBody({required this.screen});

  final OdScreen screen;

  @override
  Widget build(BuildContext context) {
    return switch (screen) {
      OdScreen.home => const HomeScreen(),
      OdScreen.camera => const CameraScreen(),
      OdScreen.record => const RecordingsScreen(),
      OdScreen.trip => const TripScreen(),
      OdScreen.more => const MoreScreen(),
    };
  }
}
