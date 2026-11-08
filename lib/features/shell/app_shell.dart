import 'package:flutter/material.dart';

import '../comfort/comfort_screen.dart';
import '../controls/controls_screen.dart';
import '../gps/gps_screen.dart';
import '../schedules/schedules_screen.dart';
import '../settings/settings_screen.dart';
import '../status/vehicle_status_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  static const _destinations = [
    NavigationDestination(
      icon: Icon(Icons.directions_car_outlined),
      selectedIcon: Icon(Icons.directions_car),
      label: 'מצב',
    ),
    NavigationDestination(
      icon: Icon(Icons.touch_app_outlined),
      selectedIcon: Icon(Icons.touch_app),
      label: 'שליטה',
    ),
    NavigationDestination(
      icon: Icon(Icons.schedule_outlined),
      selectedIcon: Icon(Icons.schedule),
      label: 'תזמונים',
    ),
    NavigationDestination(
      icon: Icon(Icons.chair_outlined),
      selectedIcon: Icon(Icons.chair),
      label: 'נוחות',
    ),
    NavigationDestination(
      icon: Icon(Icons.location_on_outlined),
      selectedIcon: Icon(Icons.location_on),
      label: 'מיקום',
    ),
    NavigationDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings),
      label: 'הגדרות',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final pages = const [
      VehicleStatusScreen(),
      ControlsScreen(),
      SchedulesScreen(),
      ComfortScreen(),
      GpsScreen(),
      SettingsScreen(),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('מלווה Overdrive')),
      body: SafeArea(
        child: IndexedStack(index: _index, children: pages),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: _destinations,
      ),
    );
  }
}
