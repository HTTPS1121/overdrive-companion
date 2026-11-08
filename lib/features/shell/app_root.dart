import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/app_providers.dart';
import '../setup/connection_setup_screen.dart';
import 'app_shell.dart';

class AppRoot extends ConsumerWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configured = ref.watch(appSettingsProvider.select((s) => s.isConfigured));
    if (!configured) {
      return const ConnectionSetupScreen();
    }
    return const AppShell();
  }
}
