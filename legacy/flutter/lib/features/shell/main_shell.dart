import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../control/control_screen.dart';
import '../onboarding/setup_screen.dart';
import '../status/status_screen.dart';
import '../../providers/app_providers.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingsProvider);
    if (!settings.isConfigured) {
      return SetupScreen(onComplete: () => setState(() {}));
    }

    final pages = [
      const StatusScreen(),
      const ControlScreen(),
      SetupScreen(onComplete: () => setState(() {})),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Overdrive Companion'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () =>
                  ref.read(vehicleSnapshotProvider.notifier).refresh(),
            ),
          ],
        ),
        body: pages[_index],
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard),
              label: 'סטטוס',
            ),
            NavigationDestination(
              icon: Icon(Icons.tune),
              label: 'שליטה',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings),
              label: 'הגדרות',
            ),
          ],
        ),
      ),
    );
  }
}
