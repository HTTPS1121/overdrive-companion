import 'package:flutter/material.dart';

import '../../core/l10n/l10n_x.dart';
import '../comfort/comfort_screen.dart';
import '../schedules/schedules_screen.dart';
import 'charge_cap_panel.dart';
import 'controls_commands_tab.dart';

class ControlsHubScreen extends StatelessWidget {
  const ControlsHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tabs = [
      l10n.controlsTabCommands,
      l10n.controlsTabSchedules,
      l10n.controlsTabComfort,
      l10n.controlsTabCharging,
    ];
    return DefaultTabController(
      length: tabs.length,
      child: Column(
        children: [
          Material(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            child: TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              labelPadding: const EdgeInsets.symmetric(horizontal: 12),
              tabs: [for (final label in tabs) Tab(text: label)],
            ),
          ),
          const Expanded(
            child: TabBarView(
              children: [
                ControlsCommandsTab(),
                SchedulesScreen(embedded: true),
                ComfortScreen(embedded: true),
                ChargeCapPanel(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
