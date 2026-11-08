import 'package:flutter/material.dart';
import 'package:overdrive_companion/l10n/app_localizations.dart';

import '../../core/widgets/floating_navigation_bar.dart';
import '../camera/camera_hub_screen.dart';
import '../controls/controls_hub_screen.dart';
import '../gps/gps_screen.dart';
import '../settings/settings_screen.dart';
import '../status/vehicle_status_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final destinations = [
      NavigationDestination(
        icon: const Icon(Icons.directions_car_outlined),
        selectedIcon: const Icon(Icons.directions_car),
        label: l10n.navStatus,
      ),
      NavigationDestination(
        icon: const Icon(Icons.touch_app_outlined),
        selectedIcon: const Icon(Icons.touch_app),
        label: l10n.navControls,
      ),
      NavigationDestination(
        icon: const Icon(Icons.videocam_outlined),
        selectedIcon: const Icon(Icons.videocam),
        label: l10n.navCameras,
      ),
      NavigationDestination(
        icon: const Icon(Icons.location_on_outlined),
        selectedIcon: const Icon(Icons.location_on),
        label: l10n.navLocation,
      ),
      NavigationDestination(
        icon: const Icon(Icons.settings_outlined),
        selectedIcon: const Icon(Icons.settings),
        label: l10n.navSettings,
      ),
    ];

    const pages = [
      VehicleStatusScreen(),
      ControlsHubScreen(),
      CameraHubScreen(),
      GpsScreen(),
      SettingsScreen(),
    ];

    return Scaffold(
      extendBody: true,
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: SafeArea(
        bottom: false,
        child: IndexedStack(index: _index, children: pages),
      ),
      bottomNavigationBar: FloatingNavigationBar(
        selectedIndex: _index,
        onSelected: (i) => setState(() => _index = i),
        destinations: destinations,
      ),
    );
  }
}
