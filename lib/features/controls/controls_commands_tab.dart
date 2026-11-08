import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/freshness.dart';
import '../../core/layout/scroll_insets.dart';
import '../../core/widgets/confirm_risky_action.dart';
import '../../data/models/vehicle_state.dart';
import '../../data/repositories/overdrive_endpoints.dart';
import '../../data/repositories/vehicle_repository.dart';
import '../../providers/app_providers.dart';
import 'control_widgets.dart';
import 'vehicle_extended_controls.dart';

/// פקודות שליטה ישירות (נעילה, חלונות, מיזוג).
class ControlsCommandsTab extends ConsumerStatefulWidget {
  const ControlsCommandsTab({super.key});

  @override
  ConsumerState<ControlsCommandsTab> createState() => _ControlsCommandsTabState();
}

class _ControlsCommandsTabState extends ConsumerState<ControlsCommandsTab> {
  String? _lastFeedback;
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final snapAsync = ref.watch(vehicleSnapshotProvider);

    return snapAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('שגיאה: $e')),
      data: (snap) {
        if (snap == null || snap.offline || !snap.state.success) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                snap?.errorMessage ?? 'אין חיבור לשרת — שליטה לא זמינה',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final freshness = DataFreshness(
          serverEpochSec: snap.state.timestamp,
          fetchedAt: snap.lastUpdated ?? DateTime.now(),
        );
        final staleBlocked = freshness.isStale;

        return Stack(
          children: [
            ListView(
          padding: scrollBottomPadding(context),
          children: [
            if (staleBlocked)
              Card(
                color: Theme.of(context).colorScheme.tertiaryContainer,
                child: ListTile(
                  leading: Icon(Icons.schedule, color: Theme.of(context).colorScheme.onTertiaryContainer),
                  title: const Text('נתונים ישנים'),
                  subtitle: Text(
                    'רענן את המצב לפני שליחת פקודה (${freshness.fetchedAgoLabelHe(snap.lastUpdated)})',
                  ),
                ),
              ),
            ControlSection(
              title: 'גישה לרכב',
              icon: Icons.vpn_key,
              children: [
                ControlActionTile(
                  label: 'נעילה',
                  icon: Icons.lock,
                  enabled: !_busy && !staleBlocked,
                  onPressed: () => _runWithConfirm(ControlKind.lock, 'נעילה'),
                ),
                ControlActionTile(
                  label: 'פתיחה',
                  icon: Icons.lock_open,
                  enabled: !_busy && !staleBlocked,
                  onPressed: () => _runWithConfirm(ControlKind.unlock, 'פתיחה'),
                ),
                ControlActionTile(
                  label: 'פתיחת תא מטען',
                  icon: Icons.luggage,
                  enabled: !_busy && !staleBlocked,
                  onPressed: () => _runWithConfirm(ControlKind.trunkOpen, 'תא מטען'),
                ),
                ControlActionTile(
                  label: 'הבהוב אורות',
                  icon: Icons.lightbulb_outline,
                  enabled: !_busy && !staleBlocked,
                  onPressed: () => _run(ControlKind.flash, 'הבהוב'),
                ),
                ControlActionTile(
                  label: 'מציאת רכב',
                  icon: Icons.my_location,
                  enabled: !_busy && !staleBlocked,
                  onPressed: () => _runWithConfirm(ControlKind.findCar, 'מציאת רכב'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ControlSection(
              title: 'חלונות',
              icon: Icons.filter_drama_outlined,
              children: [
                ControlActionTile(
                  label: 'פתיחה מלאה',
                  icon: Icons.vertical_align_top,
                  enabled: !_busy && !staleBlocked,
                  onPressed: () => _runWithConfirm(ControlKind.windowsOpen, 'חלונות'),
                ),
                ControlActionTile(
                  label: 'סגירה',
                  icon: Icons.vertical_align_bottom,
                  enabled: !_busy && !staleBlocked,
                  onPressed: () => _run(ControlKind.windowsClose, 'חלונות'),
                ),
                ControlActionTile(
                  label: 'אוורור',
                  icon: Icons.air,
                  enabled: !_busy && !staleBlocked,
                  onPressed: () => _run(ControlKind.windowsVent, 'אוורור'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ControlSection(
              title: 'מיזוג',
              icon: Icons.ac_unit,
              children: [
                ControlActionTile(
                  label: snap.state.climate?.acOn == true ? 'כיבוי מיזוג' : 'הפעלת מיזוג',
                  icon: Icons.thermostat,
                  enabled: !_busy && !staleBlocked,
                  onPressed: () => _run(
                    snap.state.climate?.acOn == true
                        ? ControlKind.climateOff
                        : ControlKind.climateOn,
                    'מיזוג',
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: ControlActionTile(
                        label: 'טמפ׳ −',
                        icon: Icons.remove,
                        enabled: !_busy && !staleBlocked,
                        compact: true,
                        onPressed: () => _climateTemp(-1, snap),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ControlActionTile(
                        label: 'טמפ׳ +',
                        icon: Icons.add,
                        enabled: !_busy && !staleBlocked,
                        compact: true,
                        onPressed: () => _climateTemp(1, snap),
                      ),
                    ),
                  ],
                ),
                ControlActionTile(
                  label: snap.state.seats?.steeringHeat == true
                      ? 'כיבוי חימום הגה'
                      : 'חימום הגה',
                  icon: Icons.touch_app,
                  enabled: !_busy && !staleBlocked,
                  onPressed: () => _run(ControlKind.steeringHeat, 'הגה'),
                ),
              ],
            ),
            VehicleExtendedControls(
              snap: snap,
              staleBlocked: staleBlocked,
              busy: _busy,
              onBusyChanged: (v) => setState(() => _busy = v),
              onFeedback: (m) => setState(() => _lastFeedback = m),
            ),
            if (_lastFeedback != null) ...[
              const SizedBox(height: 16),
              Text(_lastFeedback!, textAlign: TextAlign.center),
            ],
          ],
            ),
            if (_busy)
              Positioned.fill(
                child: ColoredBox(
                  color: Colors.black.withValues(alpha: 0.12),
                  child: const Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        );
      },
    );
  }

  ControlCapability _cap(ControlKind kind) =>
      kCompanionControls.firstWhere((c) => c.kind == kind);

  Future<void> _runWithConfirm(ControlKind kind, String label) async {
    final cap = _cap(kind);
    if (cap.requiresConfirmation) {
      final ok = await confirmRiskyAction(
        context,
        title: 'לאשר $label?',
        body: 'הפעולה תישלח לרכב דרך השרת. וודא שהרכב במקום בטוח.',
        confirmLabel: 'שליחה',
      );
      if (!ok || !mounted) return;
    }
    await _run(kind, label);
  }

  Future<void> _run(ControlKind kind, String label) async {
    final snap = ref.read(vehicleSnapshotProvider).valueOrNull;
    setState(() {
      _busy = true;
      _lastFeedback = null;
    });
    final repo = ref.read(vehicleRepositoryProvider);
    var body = _cap(kind).defaultBody == null
        ? null
        : Map<String, dynamic>.from(_cap(kind).defaultBody!);

    if (kind == ControlKind.steeringHeat) {
      final on = snap?.state.seats?.steeringHeat != true;
      body = {'action': on ? 'steering_heat_on' : 'steering_heat_off'};
    }

    final result = await repo.runControl(
      _cap(kind),
      body: body,
      verifyWithRefresh: kind == ControlKind.lock || kind == ControlKind.unlock,
    );
    if (!mounted) return;
    setState(() {
      _busy = false;
      _lastFeedback = result.userMessageHe(actionLabel: label);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result.userMessageHe(actionLabel: label))),
    );
    if (result.userConfirmed) {
      await ref.read(vehicleSnapshotProvider.notifier).refresh();
    }
  }

  Future<void> _climateTemp(int delta, VehicleSnapshot snap) async {
    final current = snap.state.climate?.setpointDriver ?? 22;
    final next = (current + delta).clamp(15, 33).toDouble();
    setState(() => _busy = true);
    final result = await ref.read(vehicleRepositoryProvider).runControl(
          _cap(ControlKind.tempUp),
          body: {'action': 'set_temp', 'zone': 0, 'temp': next},
          verifyWithRefresh: false,
        );
    if (!mounted) return;
    setState(() {
      _busy = false;
      _lastFeedback = result.userMessageHe(actionLabel: 'טמפרטורה');
    });
    if (result.success) {
      await ref.read(vehicleSnapshotProvider.notifier).refresh();
    }
  }
}

