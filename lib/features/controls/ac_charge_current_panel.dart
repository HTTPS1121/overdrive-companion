import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/command_result_l10n.dart';
import '../../core/l10n/l10n_x.dart';
import '../../data/models/remote_feature_models.dart';
import '../../providers/app_providers.dart';

class AcChargeCurrentPanel extends ConsumerStatefulWidget {
  const AcChargeCurrentPanel({super.key});

  @override
  ConsumerState<AcChargeCurrentPanel> createState() => _AcChargeCurrentPanelState();
}

class _AcChargeCurrentPanelState extends ConsumerState<AcChargeCurrentPanel> {
  AcChargeCurrentLimitState? _state;
  bool _loading = true;
  String? _error;
  bool _saving = false;

  static const _amps = [6, 8, 10, 13, 16];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final s = await ref.read(vehicleRepositoryProvider).fetchAcChargeCurrentLimit();
      if (!mounted) return;
      setState(() {
        _state = s;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _select(int next) async {
    final l10n = context.l10n;
    final cur = _state;
    if (cur == null || !cur.isOperational || cur.state == next) return;
    setState(() => _saving = true);
    final r = await ref.read(vehicleRepositoryProvider).setAcChargeCurrentLimit(next);
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(r.userMessage(l10n, actionLabel: l10n.acChargeTitle))),
    );
    if (r.success) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.only(top: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Text(_error!),
      );
    }
    final s = _state;
    if (s == null || !s.success) {
      return Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Text(l10n.acChargeLoadFailed),
      );
    }
    if (s.supported == false) {
      return Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Text(l10n.acChargeTrimUnsupported),
      );
    }
    if (s.available != true) {
      return Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Text(s.error ?? l10n.acChargeUnavailable),
      );
    }
    final selected = s.state ?? 3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        Text(l10n.acChargeTitle, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 6),
        Text(l10n.acChargeLevelsHint, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 12),
        if (_saving) const LinearProgressIndicator(minHeight: 2),
        const SizedBox(height: 8),
        Directionality(
          textDirection: TextDirection.ltr,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              for (var i = 1; i <= 5; i++)
                ChoiceChip(
                  label: Text(
                    l10n.acChargeLevelAmps(_amps[i - 1]),
                    style: const TextStyle(fontSize: 13),
                  ),
                  selected: selected == i,
                  onSelected: _saving
                      ? null
                      : (_) {
                          if (i != selected) _select(i);
                        },
                ),
            ],
          ),
        ),
        if (s.label != null) ...[
          const SizedBox(height: 8),
          Text(
            l10n.acChargeCurrentLabel(s.label!),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}
