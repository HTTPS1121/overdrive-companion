import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/freshness.dart';
import '../../core/layout/scroll_insets.dart';
import '../../core/l10n/control_l10n.dart';
import '../../core/l10n/l10n_x.dart';
import '../../core/widgets/confirm_risky_action.dart';
import '../../data/repositories/overdrive_endpoints.dart';
import '../../data/repositories/vehicle_repository.dart';
import '../../providers/app_providers.dart';
import 'control_widgets.dart';
import 'vehicle_extended_controls.dart';

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
    final l10n = context.l10n;
    final snapAsync = ref.watch(vehicleSnapshotProvider);

    return snapAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('${l10n.controlsErrorTitle}: $e')),
      data: (snap) {
        if (snap == null || snap.offline || !snap.state.success) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                snap?.errorMessage ?? l10n.controlsNoConnection,
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
        final ago = freshness.fetchedAgoLabelLocalized(l10n, snap.lastUpdated);

        return Stack(
          children: [
            ListView(
              padding: scrollBottomPadding(context),
              children: [
                if (staleBlocked)
                  Card(
                    color: Theme.of(context).colorScheme.tertiaryContainer,
                    child: ListTile(
                      leading: Icon(
                        Icons.schedule,
                        color: Theme.of(context).colorScheme.onTertiaryContainer,
                      ),
                      title: Text(l10n.controlStaleTitle),
                      subtitle: Text(l10n.controlStaleBody(ago)),
                    ),
                  ),
                ControlSection(
                  title: l10n.controlSectionAccess,
                  icon: Icons.vpn_key,
                  children: [
                    ControlActionGrid(
                      actions: [
                        ControlGridAction(
                          label: l10n.controlLock,
                          icon: Icons.lock,
                          enabled: !_busy && !staleBlocked,
                          onPressed: () => _runWithConfirm(ControlKind.lock),
                        ),
                        ControlGridAction(
                          label: l10n.controlUnlock,
                          icon: Icons.lock_open,
                          enabled: !_busy && !staleBlocked,
                          onPressed: () => _runWithConfirm(ControlKind.unlock),
                        ),
                        ControlGridAction(
                          label: l10n.controlTrunkOpen,
                          icon: Icons.luggage,
                          enabled: !_busy && !staleBlocked,
                          onPressed: () => _runWithConfirm(ControlKind.trunkOpen),
                        ),
                        ControlGridAction(
                          label: l10n.controlFindCar,
                          icon: Icons.my_location,
                          enabled: !_busy && !staleBlocked,
                          onPressed: () => _runWithConfirm(ControlKind.findCar),
                        ),
                        ControlGridAction(
                          label: l10n.controlFlash,
                          icon: Icons.lightbulb_outline,
                          enabled: !_busy && !staleBlocked,
                          onPressed: () => _run(ControlKind.flash),
                          fullWidth: true,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ControlSection(
                  title: l10n.controlSectionWindows,
                  icon: Icons.filter_drama_outlined,
                  children: [
                    ControlActionGrid(
                      actions: [
                        ControlGridAction(
                          label: l10n.controlWindowsOpen,
                          icon: Icons.vertical_align_top,
                          enabled: !_busy && !staleBlocked,
                          onPressed: () => _runWithConfirm(ControlKind.windowsOpen),
                        ),
                        ControlGridAction(
                          label: l10n.controlWindowsClose,
                          icon: Icons.vertical_align_bottom,
                          enabled: !_busy && !staleBlocked,
                          onPressed: () => _run(ControlKind.windowsClose),
                        ),
                        ControlGridAction(
                          label: l10n.controlWindowsVent,
                          icon: Icons.air,
                          enabled: !_busy && !staleBlocked,
                          onPressed: () => _run(ControlKind.windowsVent),
                          fullWidth: true,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ControlSection(
                  title: l10n.controlSectionClimate,
                  icon: Icons.ac_unit,
                  children: [
                    ControlActionGrid(
                      actions: [
                        ControlGridAction(
                          label: snap.state.climate?.acOn == true
                              ? l10n.controlClimateOffAction
                              : l10n.controlClimateOnAction,
                          icon: Icons.thermostat,
                          enabled: !_busy && !staleBlocked,
                          onPressed: () => _run(
                            snap.state.climate?.acOn == true
                                ? ControlKind.climateOff
                                : ControlKind.climateOn,
                          ),
                          fullWidth: true,
                        ),
                        ControlGridAction(
                          label: l10n.controlTempDownShort,
                          icon: Icons.remove,
                          enabled: !_busy && !staleBlocked,
                          onPressed: () => _climateTemp(-1, snap),
                        ),
                        ControlGridAction(
                          label: l10n.controlTempUpShort,
                          icon: Icons.add,
                          enabled: !_busy && !staleBlocked,
                          onPressed: () => _climateTemp(1, snap),
                        ),
                        ControlGridAction(
                          label: snap.state.seats?.steeringHeat == true
                              ? l10n.controlSteeringHeatOff
                              : l10n.controlSteeringHeatOn,
                          icon: Icons.touch_app,
                          enabled: !_busy && !staleBlocked,
                          onPressed: () => _run(ControlKind.steeringHeat),
                          fullWidth: true,
                        ),
                      ],
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

  Future<void> _runWithConfirm(ControlKind kind) async {
    final cap = _cap(kind);
    final l10n = context.l10n;
    final label = kind.label(l10n);
    if (cap.requiresConfirmation) {
      final ok = await confirmRiskyAction(
        context,
        title: l10n.controlConfirmTitle(label),
        body: l10n.controlConfirmBody,
        confirmLabel: l10n.controlSend,
      );
      if (!ok || !mounted) return;
    }
    await _run(kind);
  }

  Future<void> _run(ControlKind kind) async {
    final l10n = context.l10n;
    final label = kind.label(l10n);
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
    final l10n = context.l10n;
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
      _lastFeedback = result.userMessageHe(actionLabel: l10n.sectionClimate);
    });
    if (result.success) {
      await ref.read(vehicleSnapshotProvider.notifier).refresh();
    }
  }
}
