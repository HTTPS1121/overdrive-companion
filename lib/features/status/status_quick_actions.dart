import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/freshness.dart';
import '../../core/l10n/l10n_x.dart';
import '../../data/repositories/overdrive_endpoints.dart';
import '../../data/repositories/vehicle_repository.dart';
import '../../features/controls/run_vehicle_control.dart';

/// Primary vehicle actions surfaced on the home (status) screen.
class StatusQuickActions extends ConsumerStatefulWidget {
  const StatusQuickActions({
    super.key,
    required this.snap,
  });

  final VehicleSnapshot snap;

  @override
  ConsumerState<StatusQuickActions> createState() => _StatusQuickActionsState();
}

class _StatusQuickActionsState extends ConsumerState<StatusQuickActions> {
  bool _busy = false;

  Future<void> _run(ControlKind kind, {bool confirm = false}) async {
    if (_busy) return;
    setState(() => _busy = true);
    await runVehicleControl(context, ref, kind, forceConfirm: confirm);
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final locked = widget.snap.state.isLocked == true;
    final acOn = widget.snap.state.climate?.acOn == true;
    final freshness = DataFreshness(
      serverEpochSec: widget.snap.state.timestamp,
      fetchedAt: widget.snap.lastUpdated ?? DateTime.now(),
    );
    final stale = freshness.isStale;

    return Row(
      children: [
        Expanded(
          child: _QuickAction(
            icon: locked ? Icons.lock : Icons.lock_open,
            label: locked ? l10n.controlUnlock : l10n.controlLock,
            onPressed: stale || _busy
                ? null
                : () => _run(locked ? ControlKind.unlock : ControlKind.lock, confirm: true),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickAction(
            icon: Icons.ac_unit,
            label: acOn ? l10n.controlClimateOff : l10n.controlClimateOn,
            highlighted: acOn,
            onPressed: stale || _busy
                ? null
                : () => _run(acOn ? ControlKind.climateOff : ControlKind.climateOn),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickAction(
            icon: Icons.flare,
            label: l10n.controlFlash,
            onPressed: stale || _busy ? null : () => _run(ControlKind.flash),
          ),
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.highlighted = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Material(
      color: highlighted ? scheme.primaryContainer : scheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 22,
                color: highlighted ? scheme.onPrimaryContainer : scheme.primary,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  height: 1.15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
