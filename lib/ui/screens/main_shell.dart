import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/companion_models.dart';
import '../../design/od_design.dart';
import '../../state/companion_app_controller.dart';
import '../feedback/od_feedback.dart';
import '../widgets/od_widgets.dart';
import '../widgets/recording_player_modal.dart';
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
    final ctrl = ref.watch(companionAppControllerProvider);
    return Scaffold(
      backgroundColor: OdColors.pageChrome,
      body: DefaultTextStyle.merge(
        style: const TextStyle(decoration: TextDecoration.none),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: RepaintBoundary(
            key: const ValueKey('screenshot_root'),
            child: Stack(
              children: [
                Center(
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
                if (!ctrl.loginVisible) const OdFeedbackToast(),
                if (!ctrl.loginVisible) const OdSheetOverlay(),
                if (!ctrl.loginVisible && ctrl.recPlayId != null) const RecordingPlayerModal(),
              ],
            ),
          ),
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
    final edgeToEdge = screen == OdScreen.camera;
    return Stack(
      children: [
        Positioned.fill(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: edgeToEdge ? 0 : 16),
            child: _ScreenBody(screen: screen),
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
