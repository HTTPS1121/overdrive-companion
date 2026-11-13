import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design/od_design.dart';
import '../../state/companion_app_controller.dart';

/// Root [ScaffoldMessenger] for floating snackbars above the bottom nav.
final odRootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

/// Visible in-app toast + optional scaffold snackbar (never silent).
void showOdFeedback(WidgetRef ref, String message) {
  ref.read(companionAppControllerProvider).showFeedback(message);
  odRootScaffoldMessengerKey.currentState
    ?..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        content: Text(message, textAlign: TextAlign.center),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 108),
        backgroundColor: const Color(0xFF102A4A),
        duration: const Duration(seconds: 4),
      ),
    );
}

/// Same as [showOdFeedback] when only [BuildContext] is available — uses controller + root messenger key.
void showOdFeedbackWithContext(BuildContext context, String message) {
  final container = ProviderScope.containerOf(context, listen: false);
  container.read(companionAppControllerProvider).showFeedback(message);
  odRootScaffoldMessengerKey.currentState
    ?..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        content: Text(message, textAlign: TextAlign.center),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 108),
        backgroundColor: const Color(0xFF102A4A),
        duration: const Duration(seconds: 4),
      ),
    );
}

class OdFeedbackToast extends ConsumerWidget {
  const OdFeedbackToast({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final message = ref.watch(companionAppControllerProvider.select((c) => c.feedbackToastHebrew));
    if (message == null || message.isEmpty) return const SizedBox.shrink();

    final bottom = MediaQuery.paddingOf(context).bottom + 88;
    return Positioned(
      left: 20,
      right: 20,
      bottom: bottom,
      child: IgnorePointer(
        child: Material(
          color: const Color(0xF0102A4A),
          elevation: 12,
          shadowColor: Colors.black38,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    message,
                    style: odBody(13, FontWeight.w600, Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
