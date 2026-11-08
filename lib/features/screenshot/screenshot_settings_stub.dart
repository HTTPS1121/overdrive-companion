import 'package:flutter/material.dart';

import '../../core/l10n/l10n_x.dart';

/// Minimal settings shell used only under screenshot push stacks.
class ScreenshotSettingsStub extends StatelessWidget {
  const ScreenshotSettingsStub({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsSectionRemote)),
      body: ListView(
        children: [
          ListTile(
            title: Text(l10n.remoteServicesTitle),
            trailing: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}
