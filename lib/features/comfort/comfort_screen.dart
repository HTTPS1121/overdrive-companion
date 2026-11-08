import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/command_result_l10n.dart';
import '../../core/l10n/l10n_x.dart';
import '../../core/layout/scroll_insets.dart';
import '../../core/widgets/requires_connection.dart';
import 'seat_controls.dart';
import '../../data/models/remote_feature_models.dart';
import '../../data/models/vehicle_state.dart';
import '../../data/repositories/vehicle_repository.dart';
import '../../providers/app_providers.dart';

class ComfortScreen extends StatefulWidget {
  const ComfortScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<ComfortScreen> createState() => _ComfortScreenState();
}

class _ComfortScreenState extends State<ComfortScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      children: [
        Material(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          child: TabBar(
            controller: _tabs,
            tabs: [
              Tab(text: l10n.comfortTabSeats),
              Tab(text: l10n.comfortTabMediaSafety),
            ],
          ),
        ),
        Expanded(
          child: RequiresConnection(
            child: TabBarView(
              controller: _tabs,
              children: const [
                _SeatsTab(),
                _MediaSafetyTab(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SeatsTab extends ConsumerStatefulWidget {
  const _SeatsTab();

  @override
  ConsumerState<_SeatsTab> createState() => _SeatsTabState();
}

class _SeatsTabState extends ConsumerState<_SeatsTab> {
  bool _busy = false;

  SeatInfo? get _seats => ref.watch(vehicleSnapshotProvider).valueOrNull?.state.seats;

  Future<void> _setLevel(int position, String kind, int level) async {
    final snap = ref.read(vehicleSnapshotProvider).valueOrNull;
    if (snap == null) return;
    final seats = snap.state.seats;
    final heat = List<int>.from(seats?.heat ?? [0, 0]);
    final cool = List<int>.from(seats?.cool ?? [0, 0]);
    final idx = position - 1;
    if (kind == 'heating') {
      heat[idx] = level;
      if (level > 0) cool[idx] = 0;
    } else {
      cool[idx] = level;
      if (level > 0) heat[idx] = 0;
    }
    setState(() => _busy = true);
    final r = await ref.read(vehicleRepositoryProvider).postSeat(
          action: kind,
          position: position,
          level: level,
          seatHeat: heat,
          seatCool: cool,
        );
    if (!mounted) return;
    setState(() => _busy = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(r.userMessage(context.l10n, actionLabel: context.l10n.actionSeat))),
    );
    if (r.success) await ref.read(vehicleSnapshotProvider.notifier).refresh();
  }

  Future<void> _memory(int position, bool save) async {
    setState(() => _busy = true);
    final r = await ref.read(vehicleRepositoryProvider).postSeat(
          action: save ? 'save' : 'position',
          position: position,
        );
    if (!mounted) return;
    setState(() => _busy = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          r.userMessage(
            context.l10n,
            actionLabel: save ? context.l10n.seatSaveMemory : context.l10n.seatRecallMemory,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final seats = _seats;
    return ListView(
      padding: scrollBottomPadding(context),
      children: [
        SeatControlsPanel(
          seats: seats,
          busy: _busy,
          onHeatLevel: (pos, level) => _setLevel(pos, 'heating', level),
          onVentLevel: (pos, level) => _setLevel(pos, 'ventilation', level),
          onMemoryRecall: (pos) => _memory(pos, false),
          onMemorySave: (pos) => _memory(pos, true),
        ),
      ],
    );
  }
}

class _MediaSafetyTab extends ConsumerStatefulWidget {
  const _MediaSafetyTab();

  @override
  ConsumerState<_MediaSafetyTab> createState() => _MediaSafetyTabState();
}

class _MediaSafetyTabState extends ConsumerState<_MediaSafetyTab> {
  AdasState? _adas;
  bool _loading = true;
  int _brightness = 50;

  @override
  void initState() {
    super.initState();
    _loadAdas();
  }

  Future<void> _loadAdas() async {
    try {
      final a = await ref.read(vehicleRepositoryProvider).fetchAdasState();
      if (mounted) {
        setState(() {
          _adas = a;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _media(String target, {int? value}) async {
    final r = await ref.read(vehicleRepositoryProvider).postMedia(target: target, value: value);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(r.userMessage(context.l10n, actionLabel: context.l10n.actionMedia))),
    );
  }

  Future<void> _adasToggle(String target, bool enable) async {
    final r = await ref.read(vehicleRepositoryProvider).postAdas(target: target, enable: enable);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(r.userMessage(context.l10n, actionLabel: context.l10n.actionAdas))),
    );
    if (r.success) await _loadAdas();
  }

  Future<void> _cpd(bool enable) async {
    final r = await ref.read(vehicleRepositoryProvider).postVehicleSetting(
          target: 'childPresenceDetection',
          value: enable ? 1 : 2,
        );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(r.userMessage(context.l10n, actionLabel: context.l10n.actionCpd))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListView(
      padding: scrollBottomPadding(context),
      children: [
        Text(l10n.comfortMediaTitle, style: Theme.of(context).textTheme.titleMedium),
        Slider(
          value: _brightness.toDouble(),
          min: 0,
          max: 100,
          divisions: 20,
          label: '$_brightness',
          onChanged: (v) => setState(() => _brightness = v.round()),
          onChangeEnd: (v) => _media('brightness', value: v.round()),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton.filledTonal(
              onPressed: () => _media('volume_step', value: -1),
              icon: const Icon(Icons.volume_down),
            ),
            const SizedBox(width: 24),
            IconButton.filledTonal(
              onPressed: () => _media('volume_step', value: 1),
              icon: const Icon(Icons.volume_up),
            ),
          ],
        ),
        const Divider(height: 32),
        Text(l10n.comfortSafetyTitle, style: Theme.of(context).textTheme.titleMedium),
        if (_loading)
          const LinearProgressIndicator()
        else if (_adas != null) ...[
          ListTile(
            title: const Text('ESP'),
            subtitle: Text(
              _adas!.espOn == null
                  ? l10n.comfortUnavailable
                  : (_adas!.espOn! ? l10n.stateActive : l10n.stateInactive),
            ),
            trailing: Switch(
              value: _adas!.espOn ?? false,
              onChanged: _adas!.espOn == null
                  ? null
                  : (v) => _adasToggle('esp', v),
            ),
          ),
        ],
        SwitchListTile(
          title: Text(l10n.comfortSlw),
          value: false,
          onChanged: (v) => _adasToggle('speedLimitWarning', v),
        ),
        SwitchListTile(
          title: Text(l10n.comfortCpd),
          value: false,
          onChanged: _cpd,
        ),
      ],
    );
  }
}
