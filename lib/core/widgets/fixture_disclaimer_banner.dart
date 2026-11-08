import 'package:flutter/material.dart';

import '../layout/screenshot_scope.dart';
import '../l10n/l10n_x.dart';

/// Shown in screenshot harness and optional debug — never implies live car verification.
class FixtureDisclaimerBanner extends StatelessWidget {
  const FixtureDisclaimerBanner({super.key});

  @override
  Widget build(BuildContext context) {
    if (!ScreenshotScope.of(context)) return const SizedBox.shrink();
    final l10n = context.l10n;
    return Material(
      color: Theme.of(context).colorScheme.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Text(
          l10n.screenshotFixtureDisclaimer,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelMedium,
        ),
      ),
    );
  }
}
