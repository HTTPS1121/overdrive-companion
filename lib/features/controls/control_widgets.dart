import 'package:flutter/material.dart';

class ControlSection extends StatelessWidget {
  const ControlSection({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

/// Two-column action grid for premium control layout.
class ControlActionGrid extends StatelessWidget {
  const ControlActionGrid({
    super.key,
    required this.actions,
  });

  final List<ControlGridAction> actions;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 8.0;
        final cellW = (constraints.maxWidth - spacing) / 2;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final a in actions)
              SizedBox(
                width: a.fullWidth ? constraints.maxWidth : cellW,
                height: 52,
                child: FilledButton.tonalIcon(
                  onPressed: a.enabled ? a.onPressed : null,
                  icon: Icon(a.icon, size: 20),
                  label: Text(a.label, maxLines: 2, overflow: TextOverflow.ellipsis),
                ),
              ),
          ],
        );
      },
    );
  }
}

class ControlGridAction {
  const ControlGridAction({
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.enabled,
    this.fullWidth = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool enabled;
  final bool fullWidth;
}

class ControlActionTile extends StatelessWidget {
  const ControlActionTile({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.enabled,
    this.compact = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool enabled;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: compact ? 0 : 8),
      child: SizedBox(
        width: double.infinity,
        height: compact ? 48 : 52,
        child: FilledButton.tonalIcon(
          onPressed: enabled ? onPressed : null,
          icon: Icon(icon, size: 20),
          label: Text(label),
        ),
      ),
    );
  }
}
