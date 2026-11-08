import 'package:flutter/material.dart';

/// User-facing key/value rows (not a raw JSON dump).
class KeyValueReadoutCard extends StatelessWidget {
  const KeyValueReadoutCard({
    super.key,
    required this.title,
    required this.rows,
    this.error,
  });

  final String title;
  final List<MapEntry<String, String>> rows;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (error != null && error!.isNotEmpty) {
      return Card(
        child: ListTile(
          title: Text(title),
          subtitle: Text(error!, style: TextStyle(color: theme.colorScheme.error)),
        ),
      );
    }
    if (rows.isEmpty) {
      return Card(
        child: ListTile(title: Text(title), subtitle: Text('—')),
      );
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            for (final row in rows)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: Text(row.key, style: theme.textTheme.bodyMedium)),
                    Expanded(
                      flex: 3,
                      child: Text(
                        row.value,
                        textAlign: TextAlign.end,
                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
