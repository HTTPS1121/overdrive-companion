import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/display_strings.dart';
import '../../core/theme/app_text.dart';
import '../../data/repositories/overdrive_endpoints.dart';
import '../../data/repositories/vehicle_repository.dart';
import '../../providers/app_providers.dart';

class DashboardQuickActions extends ConsumerStatefulWidget {
  const DashboardQuickActions({super.key, required this.snap});

  final VehicleSnapshot snap;

  @override
  ConsumerState<DashboardQuickActions> createState() => _DashboardQuickActionsState();
}

class _DashboardQuickActionsState extends ConsumerState<DashboardQuickActions> {
  bool _busy = false;
  String? _hint;

  Future<void> _run(ControlKind kind, String label) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _hint = null;
    });
    final body = kind == ControlKind.climateOn || kind == ControlKind.climateOff
        ? null
        : kStage1Controls.firstWhere((c) => c.kind == kind).defaultBody;

    final cap = kStage1Controls.firstWhere((c) => c.kind == kind);
    final result = await ref.read(vehicleRepositoryProvider).runControl(
          cap,
          body: body == null ? null : Map<String, dynamic>.from(body),
          verifyWithRefresh: kind == ControlKind.lock || kind == ControlKind.unlock,
        );
    if (!mounted) return;
    setState(() {
      _busy = false;
      _hint = result.userMessageHe(actionLabel: label);
    });
    if (result.userConfirmed) {
      await ref.read(vehicleSnapshotProvider.notifier).refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final locked = widget.snap.state.isLocked;
    final acOn = widget.snap.state.climate?.acOn == true;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: _QuickButton(
                icon: Icons.lock,
                label: 'נעילה',
                enabled: !_busy,
                onPressed: () => _run(ControlKind.lock, 'נעילה'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _QuickButton(
                icon: Icons.lock_open,
                label: 'פתיחה',
                enabled: !_busy,
                onPressed: () => _run(ControlKind.unlock, 'פתיחה'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _QuickButton(
                icon: Icons.ac_unit,
                label: acOn ? 'כיבוי מיזוג' : 'הפעלת מיזוג',
                enabled: !_busy,
                highlighted: acOn,
                onPressed: () => _run(
                  acOn ? ControlKind.climateOff : ControlKind.climateOn,
                  'מיזוג',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          locked == true
              ? 'סטטוס הרכב נעול'
              : locked == false
                  ? 'סטטוס הרכב פתוח'
                  : 'סטטוס נעילה לא ידוע',
          style: hebrewTextStyle(Theme.of(context).textTheme.bodySmall),
          textAlign: TextAlign.center,
        ),
        if (_hint != null) ...[
          const SizedBox(height: 6),
          Text(
            _hint!,
            style: hebrewTextStyle(
              Theme.of(context).textTheme.labelMedium,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

class _QuickButton extends StatelessWidget {
  const _QuickButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.enabled,
    this.highlighted = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool enabled;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonalIcon(
      onPressed: enabled ? onPressed : null,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        backgroundColor: highlighted
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.22)
            : null,
      ),
      icon: Icon(icon, size: 22),
      label: Text(
        label,
        style: hebrewTextStyle(Theme.of(context).textTheme.labelMedium),
        textAlign: TextAlign.center,
      ),
    );
  }
}
