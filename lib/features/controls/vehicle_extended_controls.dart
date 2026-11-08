import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/command_result_l10n.dart';
import '../../core/l10n/l10n_x.dart';
import '../../core/widgets/confirm_risky_action.dart';
import '../../data/repositories/vehicle_repository.dart';
import '../../providers/app_providers.dart';
import 'control_widgets.dart';

/// Power on/off, battery heat, head-unit/cluster screenshot — handler-verified bodies only.
class VehicleExtendedControls extends ConsumerStatefulWidget {
  const VehicleExtendedControls({
    super.key,
    required this.snap,
    required this.staleBlocked,
    required this.busy,
    required this.onBusyChanged,
    required this.onFeedback,
  });

  final VehicleSnapshot snap;
  final bool staleBlocked;
  final bool busy;
  final ValueChanged<bool> onBusyChanged;
  final ValueChanged<String?> onFeedback;

  @override
  ConsumerState<VehicleExtendedControls> createState() => _VehicleExtendedControlsState();
}

class _VehicleExtendedControlsState extends ConsumerState<VehicleExtendedControls> {
  bool get _driving =>
      widget.snap.gps?.isDriving == true ||
      (widget.snap.gps?.canSpeedKmh != null && widget.snap.gps!.canSpeedKmh! > 1);

  bool get _canCommand => !widget.busy && !widget.staleBlocked;

  Future<void> _power(bool on) async {
    final l10n = context.l10n;
    final action = on ? l10n.extendedPowerOn : l10n.extendedPowerOff;
    final ok = await confirmRiskyAction(
      context,
      title: on ? l10n.extendedConfirmPowerOnTitle : l10n.extendedConfirmPowerOffTitle,
      body: on ? l10n.extendedConfirmPowerOnBody : l10n.extendedConfirmPowerOffBody,
      confirmLabel: l10n.controlSend,
    );
    if (!ok || !mounted) return;
    widget.onBusyChanged(true);
    final repo = ref.read(vehicleRepositoryProvider);
    final result = on ? await repo.vehiclePowerOn() : await repo.vehiclePowerOff();
    if (!mounted) return;
    widget.onBusyChanged(false);
    final msg = result.userMessage(l10n, actionLabel: action);
    widget.onFeedback(msg);
    _snack(msg);
    if (result.userConfirmed) {
      await ref.read(vehicleSnapshotProvider.notifier).refresh();
    }
  }

  Future<void> _batteryHeat(bool enabled) async {
    if (widget.snap.state.batteryHeat == null) return;
    final l10n = context.l10n;
    widget.onBusyChanged(true);
    final repo = ref.read(vehicleRepositoryProvider);
    final result = await repo.setBatteryHeat(enabled);
    if (!mounted) return;
    widget.onBusyChanged(false);
    final msg = result.userMessage(l10n, actionLabel: l10n.actionBatteryHeat);
    widget.onFeedback(msg);
    _snack(msg);
    if (result.success) {
      await ref.read(vehicleSnapshotProvider.notifier).refresh();
    }
  }

  Future<void> _screenshot(int display) async {
    final l10n = context.l10n;
    final label = display == 0 ? l10n.extendedScreenshotHu : l10n.extendedScreenshotCluster;
    final ok = await confirmRiskyAction(
      context,
      title: l10n.extendedConfirmScreenshotTitle(label),
      body: l10n.extendedConfirmScreenshotBody,
      confirmLabel: l10n.extendedConfirmCapture,
    );
    if (!ok || !mounted) return;
    widget.onBusyChanged(true);
    final result = await ref.read(vehicleRepositoryProvider).systemScreenshot(display: display);
    if (!mounted) return;
    widget.onBusyChanged(false);
    var msg = result.userMessage(l10n, actionLabel: label);
    if (result.success && result.message != null) {
      msg = result.message!;
    }
    widget.onFeedback(msg);
    _snack(msg);
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final heatKnown = widget.snap.state.batteryHeat;

    return Column(
      children: [
        ControlSection(
          title: l10n.extendedPowerSection,
          icon: Icons.power_settings_new,
          children: [
            if (_driving)
              Text(
                l10n.extendedPowerDrivingBlocked,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ControlActionTile(
              label: l10n.extendedPowerOn,
              icon: Icons.power,
              enabled: _canCommand && !_driving,
              onPressed: () => _power(true),
            ),
            ControlActionTile(
              label: l10n.extendedPowerOff,
              icon: Icons.power_off,
              enabled: _canCommand && !_driving,
              onPressed: () => _power(false),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ControlSection(
          title: l10n.extendedBatteryHeatSection,
          icon: Icons.battery_charging_full,
          children: [
            if (heatKnown == null)
              Text(l10n.extendedBatteryHeatUnknown)
            else
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.extendedBatteryPreheat),
                subtitle: Text(heatKnown ? l10n.extendedBatteryHeatOn : l10n.extendedBatteryHeatOff),
                value: heatKnown,
                onChanged: _canCommand ? _batteryHeat : null,
              ),
          ],
        ),
        const SizedBox(height: 12),
        ControlSection(
          title: l10n.extendedScreenshotsSection,
          icon: Icons.screenshot_monitor,
          children: [
            Text(
              l10n.extendedScreenshotsHint,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            ControlActionTile(
              label: l10n.extendedScreenshotHu,
              icon: Icons.tablet_android,
              enabled: _canCommand,
              onPressed: () => _screenshot(0),
            ),
            ControlActionTile(
              label: l10n.extendedScreenshotCluster,
              icon: Icons.speed,
              enabled: _canCommand,
              onPressed: () => _screenshot(1),
            ),
          ],
        ),
      ],
    );
  }
}
