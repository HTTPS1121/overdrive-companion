import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/command_result_l10n.dart';
import '../../core/l10n/control_l10n.dart';
import '../../core/l10n/l10n_x.dart';
import '../../core/widgets/confirm_risky_action.dart';
import '../../data/repositories/overdrive_endpoints.dart';
import '../../data/repositories/vehicle_repository.dart';
import '../../providers/app_providers.dart';

ControlCapability companionControl(ControlKind kind) =>
    kCompanionControls.firstWhere((c) => c.kind == kind);

/// Runs a vehicle control with optional confirmation — same behavior as controls tab.
Future<void> runVehicleControl(
  BuildContext context,
  WidgetRef ref,
  ControlKind kind, {
  bool forceConfirm = false,
}) async {
  final cap = companionControl(kind);
  final l10n = context.l10n;
  final label = kind.label(l10n);
  if (forceConfirm || cap.requiresConfirmation) {
    final ok = await confirmRiskyAction(
      context,
      title: l10n.controlConfirmTitle(label),
      body: l10n.controlConfirmBody,
      confirmLabel: l10n.controlSend,
    );
    if (!ok || !context.mounted) return;
  }

  final snap = ref.read(vehicleSnapshotProvider).valueOrNull;
  var body = cap.defaultBody == null ? null : Map<String, dynamic>.from(cap.defaultBody!);
  if (kind == ControlKind.steeringHeat) {
    final on = snap?.state.seats?.steeringHeat != true;
    body = {'action': on ? 'steering_heat_on' : 'steering_heat_off'};
  }

  final result = await ref.read(vehicleRepositoryProvider).runControl(
        cap,
        body: body,
        verifyWithRefresh: kind == ControlKind.lock || kind == ControlKind.unlock,
      );
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(result.userMessage(l10n, actionLabel: label))),
  );
  if (result.userConfirmed || result.success) {
    await ref.read(vehicleSnapshotProvider.notifier).refresh();
  }
}
