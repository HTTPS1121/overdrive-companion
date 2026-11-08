import 'package:flutter/material.dart';

import '../../core/l10n/l10n_x.dart';

/// Visible on Advanced diagnostics routes — not a screenshot-only banner.
class AdvancedDiagnosticsWarning extends StatelessWidget {
  const AdvancedDiagnosticsWarning({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      color: theme.colorScheme.errorContainer.withValues(alpha: 0.35),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.diagnosticsAdvancedTitle, style: theme.textTheme.titleSmall),
                  const SizedBox(height: 6),
                  Text(l10n.diagnosticsAdvancedWarning, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
