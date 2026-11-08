import 'package:flutter/material.dart';

import '../../core/l10n/l10n_x.dart';
import '../../core/layout/scroll_insets.dart';
import 'diagnostics_screens.dart';
import 'family_screens.dart';

class IntegrationsHubScreen extends StatelessWidget {
  const IntegrationsHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    final items = <_HubRoute>[
      _HubRoute(
        icon: Icons.smart_toy_outlined,
        title: l10n.integrationsAutomationsTitle,
        subtitle: l10n.integrationsAutomationsSubtitle,
        builder: (_) => const AutomationsFamilyScreen(),
      ),
      _HubRoute(
        icon: Icons.local_parking_outlined,
        title: l10n.integrationsParkingTitle,
        subtitle: l10n.integrationsParkingSubtitle,
        builder: (_) => const ParkingFamilyScreen(),
      ),
      _HubRoute(
        icon: Icons.route_outlined,
        title: l10n.integrationsTripsTitle,
        subtitle: l10n.integrationsTripsSubtitle,
        builder: (_) => const TripsFamilyScreen(),
      ),
      _HubRoute(
        icon: Icons.library_music_outlined,
        title: l10n.integrationsAudioTitle,
        subtitle: l10n.integrationsAudioSubtitle,
        builder: (_) => const AudioLibraryFamilyScreen(),
      ),
      _HubRoute(
        icon: Icons.psychology_outlined,
        title: l10n.integrationsGenAiToolsTitle,
        subtitle: l10n.integrationsGenAiToolsSubtitle,
        builder: (_) => const GenAiToolsFamilyScreen(),
      ),
      _HubRoute(
        icon: Icons.telegram,
        title: l10n.integrationsTelegramTitle,
        subtitle: l10n.integrationsTelegramSubtitle,
        builder: (_) => const TelegramFamilyScreen(),
      ),
      _HubRoute(
        icon: Icons.hub_outlined,
        title: l10n.integrationsPlatformTitle,
        subtitle: l10n.integrationsPlatformSubtitle,
        builder: (_) => const PlatformConnectorsScreen(),
      ),
      _HubRoute(
        icon: Icons.bug_report_outlined,
        title: l10n.integrationsDiagnosticsTitle,
        subtitle: l10n.integrationsDiagnosticsSubtitle,
        builder: (_) => const DiagnosticsHubScreen(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.integrationsHubTitle)),
      body: ListView(
        padding: scrollBottomPadding(context),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(l10n.integrationsHubIntro, style: theme.textTheme.bodyMedium),
          ),
          for (final item in items)
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: ListTile(
                leading: Icon(item.icon),
                title: Text(item.title),
                subtitle: Text(item.subtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: item.builder),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _HubRoute {
  const _HubRoute({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.builder,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget Function(BuildContext) builder;
}
