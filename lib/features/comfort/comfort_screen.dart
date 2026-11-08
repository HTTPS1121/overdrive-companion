import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/requires_connection.dart';
import '../../data/models/remote_feature_models.dart';
import '../../data/models/vehicle_state.dart';
import '../../data/repositories/vehicle_repository.dart';
import '../../providers/app_providers.dart';

class ComfortScreen extends StatefulWidget {
  const ComfortScreen({super.key});

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
    return Column(
      children: [
        Material(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          child: TabBar(
            controller: _tabs,
            tabs: const [
              Tab(text: 'מושבים'),
              Tab(text: 'מדיה ובטיחות'),
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

  Future<void> _heatVent(int position, String kind) async {
    final snap = ref.read(vehicleSnapshotProvider).valueOrNull;
    if (snap == null) return;
    final seats = snap.state.seats;
    final heat = List<int>.from(seats?.heat ?? [0, 0]);
    final cool = List<int>.from(seats?.cool ?? [0, 0]);
    final idx = position - 1;
    if (kind == 'heating') {
      heat[idx] = (heat[idx] + 1) % 3;
      cool[idx] = 0;
    } else {
      cool[idx] = (cool[idx] + 1) % 3;
      heat[idx] = 0;
    }
    setState(() => _busy = true);
    final r = await ref.read(vehicleRepositoryProvider).postSeat(
          action: kind,
          position: position,
          level: kind == 'heating' ? heat[idx] : cool[idx],
          seatHeat: heat,
          seatCool: cool,
        );
    if (!mounted) return;
    setState(() => _busy = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(r.userMessageHe(actionLabel: 'מושב'))),
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
      SnackBar(content: Text(r.userMessageHe(actionLabel: save ? 'שמירת מושב' : 'קריאת מושב'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final seats = _seats;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('חימום / אוורור לפי PWA', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 12),
        for (var pos = 1; pos <= 2; pos++) ...[
          Text('מושב $pos', style: Theme.of(context).textTheme.titleSmall),
          Row(
            children: [
              Expanded(
                child: FilledButton.tonal(
                  onPressed: _busy ? null : () => _heatVent(pos, 'heating'),
                  child: Text('חימום (רמה ${(seats?.heat.length ?? 0) >= pos ? seats!.heat[pos - 1] : 0})'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.tonal(
                  onPressed: _busy ? null : () => _heatVent(pos, 'ventilation'),
                  child: Text('אוורור (רמה ${(seats?.cool.length ?? 0) >= pos ? seats!.cool[pos - 1] : 0})'),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _busy ? null : () => _memory(pos, false),
                  child: const Text('זכירון — קריאה'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: _busy ? null : () => _memory(pos, true),
                  child: const Text('זכירון — שמירה'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
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
      SnackBar(content: Text(r.userMessageHe(actionLabel: 'מדיה'))),
    );
  }

  Future<void> _adasToggle(String target, bool enable) async {
    final r = await ref.read(vehicleRepositoryProvider).postAdas(target: target, enable: enable);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(r.userMessageHe(actionLabel: 'ADAS'))),
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
      SnackBar(content: Text(r.userMessageHe(actionLabel: 'CPD'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('עוצמת מדיה ובהירות מסך', style: Theme.of(context).textTheme.titleMedium),
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
        Text('בטיחות', style: Theme.of(context).textTheme.titleMedium),
        if (_loading)
          const LinearProgressIndicator()
        else if (_adas != null) ...[
          ListTile(
            title: const Text('ESP'),
            subtitle: Text(_adas!.espOn == null ? 'לא זמין' : (_adas!.espOn! ? 'פעיל' : 'כבוי')),
            trailing: Switch(
              value: _adas!.espOn ?? false,
              onChanged: _adas!.espOn == null
                  ? null
                  : (v) => _adasToggle('esp', v),
            ),
          ),
        ],
        SwitchListTile(
          title: const Text('התרעת מהירות (SLW)'),
          value: false,
          onChanged: (v) => _adasToggle('speedLimitWarning', v),
        ),
        SwitchListTile(
          title: const Text('זיהוי ילד ברכב (CPD)'),
          value: false,
          onChanged: _cpd,
        ),
      ],
    );
  }
}
