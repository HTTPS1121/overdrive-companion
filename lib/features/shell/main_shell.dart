import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_settings.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/bilingual_text.dart';
import '../../providers/app_providers.dart';
import '../controls/controls_screen.dart';
import '../dashboard/dashboard_screen.dart';
import '../settings/settings_screen.dart';

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
    final needsSetup =
        !settings.isConfigured ||
        (settings.connectionMode == ConnectionMode.live && settings.baseUrl.trim().isEmpty);

    if (needsSetup) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: SettingsScreen(
            onComplete: () => setState(() => _index = 0),
          ),
        ),
      );
    }

    final pages = [
      const DashboardScreen(),
      const ControlsScreen(),
      SettingsScreen(onComplete: () => setState(() {})),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: HebrewLatinTitle(
            hebrew: 'מלווה',
            latin: 'Overdrive',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          actions: [
            if (settings.connectionMode != ConnectionMode.live)
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 4),
                child: Chip(
                  label: Text(
                    'דמו',
                    style: hebrewTextStyle(Theme.of(context).textTheme.labelSmall),
                  ),
                  visualDensity: VisualDensity.compact,
                ),
              ),
          ],
        ),
        body: pages[_index],
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.speed), label: 'לוח מחוונים'),
            NavigationDestination(icon: Icon(Icons.touch_app), label: 'שליטה'),
            NavigationDestination(icon: Icon(Icons.settings), label: 'הגדרות'),
          ],
        ),
      ),
    );
  }
}
