import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/freshness.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/demo_banner.dart';
import '../../data/repositories/overdrive_endpoints.dart';
import '../../data/repositories/vehicle_repository.dart';
import '../../providers/app_providers.dart';

class ControlsScreen extends ConsumerStatefulWidget {
  const ControlsScreen({super.key});

  @override
  ConsumerState<ControlsScreen> createState() => _ControlsScreenState();
}

class _ControlsScreenState extends ConsumerState<ControlsScreen> {
  String? _lastFeedback;
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingsProvider);
    final snapAsync = ref.watch(vehicleSnapshotProvider);
    final colors = OverdriveColors.of(context);

    return Column(
      children: [
        DemoDataBanner(mode: settings.connectionMode),
        Expanded(
          child: snapAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('שגיאה: $e')),
            data: (snap) {
              if (snap == null || snap.offline || !snap.state.success) {
                return Center(
                  child: Text(snap?.errorMessage ?? 'אין חיבור - לא ניתן לשלוט'),
                );
              }

              final freshness = DataFreshness(
                serverEpochSec: snap.state.timestamp,
                fetchedAt: snap.lastUpdated ?? DateTime.now(),
              );
              final staleBlocked = freshness.isStale;

              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                children: [
                  if (staleBlocked)
                    Card(
                      color: colors.demoBanner,
                      child: ListTile(
                        leading: Icon(Icons.warning_amber, color: colors.warn),
                        title: const Text('נתונים ישנים'),
                        subtitle: Text(
                          'רענן את המצב לפני שליחת פקודה (${freshness.ageLabelHe()})',
                        ),
                      ),
                    ),
                  _ControlSection(
                    title: 'גישה לרכב',
                    icon: Icons.vpn_key,
                    children: [
                      _ActionTile(
                        label: 'נעילה',
                        icon: Icons.lock,
                        enabled: !_busy && !staleBlocked,
                        onPressed: () => _run(ControlKind.lock, 'נעילה'),
                      ),
                      _ActionTile(
                        label: 'פתיחה',
                        icon: Icons.lock_open,
                        enabled: !_busy && !staleBlocked,
                        onPressed: () => _run(ControlKind.unlock, 'פתיחה'),
                      ),
                      _ActionTile(
                        label: 'פתיחת תא מטען',
                        icon: Icons.luggage,
                        enabled: !_busy && !staleBlocked,
                        onPressed: () => _run(ControlKind.trunkOpen, 'תא מטען'),
                      ),
                      _ActionTile(
                        label: 'מצא רכב (הבהוב)',
                        icon: Icons.lightbulb_outline,
                        enabled: !_busy && !staleBlocked,
                        onPressed: () => _run(ControlKind.flash, 'הבהוב'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _ControlSection(
                    title: 'חלונות',
                    icon: Icons.filter_drama_outlined,
                    children: [
                      _ActionTile(
                        label: 'פתיחה מלאה',
                        icon: Icons.vertical_align_top,
                        enabled: !_busy && !staleBlocked,
                        onPressed: () => _run(ControlKind.windowsOpen, 'חלונות'),
                      ),
                      _ActionTile(
                        label: 'סגירה',
                        icon: Icons.vertical_align_bottom,
                        enabled: !_busy && !staleBlocked,
                        onPressed: () => _run(ControlKind.windowsClose, 'חלונות'),
                      ),
                      _ActionTile(
                        label: 'אוורור',
                        icon: Icons.air,
                        enabled: !_busy && !staleBlocked,
                        onPressed: () => _run(ControlKind.windowsVent, 'אוורור'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _ControlSection(
                    title: 'מיזוג',
                    icon: Icons.ac_unit,
                    children: [
                      _ActionTile(
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
                            child: _ActionTile(
                              label: 'טמפ׳ −',
                              icon: Icons.remove,
                              enabled: !_busy && !staleBlocked,
                              compact: true,
                              onPressed: () => _climateTemp(-1, snap),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _ActionTile(
                              label: 'טמפ׳ +',
                              icon: Icons.add,
                              enabled: !_busy && !staleBlocked,
                              compact: true,
                              onPressed: () => _climateTemp(1, snap),
                            ),
                          ),
                        ],
                      ),
                      _ActionTile(
                        label: snap.state.seats?.steeringHeat == true
                            ? 'כיבוי חימום הגה'
                            : 'חימום הגה',
                        icon: Icons.touch_app,
                        enabled: !_busy && !staleBlocked,
                        onPressed: () => _run(ControlKind.steeringHeat, 'הגה'),
                      ),
                    ],
                  ),
                  if (_lastFeedback != null) ...[
                    const SizedBox(height: 16),
                    Text(_lastFeedback!, textAlign: TextAlign.center),
                  ],
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  ControlCapability _cap(ControlKind kind) =>
      kStage1Controls.firstWhere((c) => c.kind == kind);

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

    if (kind == ControlKind.readingLight) {
      final on = snap?.state.lights?.readingLight != true;
      body = {'target': 'readingLight', 'enable': on};
    }
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

class _ControlSection extends StatelessWidget {
  const _ControlSection({
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
                Text(title, style: Theme.of(context).textTheme.titleMedium),
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

class _ActionTile extends StatelessWidget {
  const _ActionTile({
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
