import 'package:flutter/material.dart';

import '../comfort/comfort_screen.dart';
import '../schedules/schedules_screen.dart';
import 'charge_cap_panel.dart';
import 'controls_commands_tab.dart';

/// שליטה — פקודות בסיס, תזמונים, נוחות ומגבלת טעינה תחת לשוניות.
class ControlsHubScreen extends StatelessWidget {
  const ControlsHubScreen({super.key});

  static const tabLabels = ['פקודות', 'תזמונים', 'נוחות', 'טעינה'];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabLabels.length,
      child: Column(
        children: [
          Material(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            child: TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              labelPadding: const EdgeInsets.symmetric(horizontal: 12),
              tabs: [for (final label in tabLabels) Tab(text: label)],
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
