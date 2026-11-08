import 'package:flutter/material.dart';

import '../../core/l10n/l10n_x.dart';
import '../../core/layout/scroll_insets.dart';
import '../../data/capabilities/companion_parity.dart';

class CapabilityInventoryScreen extends StatelessWidget {
  const CapabilityInventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    String coverageLabel(ParityCoverage c) => switch (c) {
          ParityCoverage.inApp => l10n.inventoryImplemented,
          ParityCoverage.partial => l10n.inventoryPartial,
          ParityCoverage.httpOnly => l10n.inventoryNotInApp,
          ParityCoverage.carOnly => l10n.inventoryNotInApp,
        };

    return Scaffold(
      appBar: AppBar(title: Text(l10n.inventoryTitle)),
      body: ListView.builder(
        padding: scrollBottomPadding(context, extra: 24),
        itemCount: companionParityMatrix.length,
        itemBuilder: (context, i) {
          final row = companionParityMatrix[i];
          final subtitle = [
            if (row.screen != null) 'UI: ${row.screen}',
            if (row.repoMethod != null) 'Repo: ${row.repoMethod}',
            if (row.contractTest != null) 'Test: ${row.contractTest}',
            if (row.noteEn != null) row.noteEn,
            if (row.carOnlyReason != null) row.carOnlyReason,
          ].whereType<String>().join('\n');

          return Card(
            child: ListTile(
              isThreeLine: subtitle.isNotEmpty,
              title: Text('${row.method} ${row.path}', textDirection: TextDirection.ltr),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(row.labelEn),
                  if (subtitle.isNotEmpty)
                    Text(subtitle, style: theme.textTheme.bodySmall),
                ],
              ),
              trailing: Chip(label: Text(coverageLabel(row.coverage))),
            ),
          );
        },
      ),
    );
  }
}
