import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    final label = on ? 'הדלקת רכב' : 'כיבוי רכב';
    final ok = await confirmRiskyAction(
      context,
      title: on ? 'להדליק את הרכב?' : 'לכבות את הרכב?',
      body: on
          ? 'פקודת power-on נשלחת לשרת. מותר רק כשהרכב חונה וללא תנועה (SDK guard בצד השרת).'
          : 'פקודת power-off תכבה את הרכב. וודא שאין נוסעים ברכב.',
      confirmLabel: 'שליחה',
    );
    if (!ok || !mounted) return;
    widget.onBusyChanged(true);
    final repo = ref.read(vehicleRepositoryProvider);
    final result = on ? await repo.vehiclePowerOn() : await repo.vehiclePowerOff();
    if (!mounted) return;
    widget.onBusyChanged(false);
    final msg = result.userMessageHe(actionLabel: label);
    widget.onFeedback(msg);
    _snack(msg);
    if (result.userConfirmed) {
      await ref.read(vehicleSnapshotProvider.notifier).refresh();
    }
  }

  Future<void> _batteryHeat(bool enabled) async {
    if (widget.snap.state.batteryHeat == null) return;
    widget.onBusyChanged(true);
    final repo = ref.read(vehicleRepositoryProvider);
    final result = await repo.setBatteryHeat(enabled);
    if (!mounted) return;
    widget.onBusyChanged(false);
    final msg = result.userMessageHe(actionLabel: 'חימום סוללה');
    widget.onFeedback(msg);
    _snack(msg);
    if (result.success) {
      await ref.read(vehicleSnapshotProvider.notifier).refresh();
    }
  }

  Future<void> _screenshot(int display) async {
    final label = display == 0 ? 'צילום מסך מולטימדיה' : 'צילום מסך לוח שעונים';
    final ok = await confirmRiskyAction(
      context,
      title: 'לאשר $label?',
      body: 'השרת יצלם במכשיר הרכב וישמור קובץ PNG במכשיר. אין הורדה אוטומטית לטלפון.',
      confirmLabel: 'צילום',
    );
    if (!ok || !mounted) return;
    widget.onBusyChanged(true);
    final result = await ref.read(vehicleRepositoryProvider).systemScreenshot(display: display);
    if (!mounted) return;
    widget.onBusyChanged(false);
    var msg = result.userMessageHe(actionLabel: label);
    if (result.success && result.message != null) {
      msg = '${result.message}';
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
    final heatKnown = widget.snap.state.batteryHeat;

    return Column(
      children: [
        ControlSection(
          title: 'הדלקה וכיבוי',
          icon: Icons.power_settings_new,
          children: [
            if (_driving)
              Text(
                'הרכב מדווח בנסיעה — power-on/off חסום עד עצירה (guard בשרת).',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ControlActionTile(
              label: 'הדלקת רכב (power-on)',
              icon: Icons.power,
              enabled: _canCommand && !_driving,
              onPressed: () => _power(true),
            ),
            ControlActionTile(
              label: 'כיבוי רכב (power-off)',
              icon: Icons.power_off,
              enabled: _canCommand && !_driving,
              onPressed: () => _power(false),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ControlSection(
          title: 'חימום סוללה',
          icon: Icons.battery_charging_full,
          children: [
            if (heatKnown == null)
              const Text('השרת לא דיווח מצב חימום סוללה — הפעלה לא זמינה.')
            else
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('חימום מקדים לסוללה'),
                subtitle: Text(heatKnown ? 'פעיל לפי השרת' : 'כבוי לפי השרת'),
                value: heatKnown,
                onChanged: _canCommand ? _batteryHeat : null,
              ),
          ],
        ),
        const SizedBox(height: 12),
        ControlSection(
          title: 'צילום מסכי הרכב',
          icon: Icons.screenshot_monitor,
          children: [
            Text(
              'צילום PNG נשמר במכשיר הרכב (מולטימדיה או לוח שעונים).',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            ControlActionTile(
              label: 'צילום מסך מולטימדיה',
              icon: Icons.tablet_android,
              enabled: _canCommand,
              onPressed: () => _screenshot(0),
            ),
            ControlActionTile(
              label: 'צילום מסך לוח שעונים',
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
