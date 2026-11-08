import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/remote_feature_models.dart';
import '../../providers/app_providers.dart';

/// זרם טעינה AC — GET/POST `/api/vehicle/ac-charge-current-limit` (trim SDK).
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
    final cur = _state;
    if (cur == null || !cur.isOperational || cur.state == next) return;
    setState(() => _saving = true);
    final r = await ref.read(vehicleRepositoryProvider).setAcChargeCurrentLimit(next);
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(r.userMessageHe(actionLabel: 'זרם טעינה AC'))),
    );
    if (r.success) await _load();
  }

  @override
  Widget build(BuildContext context) {
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
      return const Padding(
        padding: EdgeInsets.only(top: 16),
        child: Text('לא ניתן לקרוא זרם טעינה AC מהשרת'),
      );
    }
    if (s.supported == false) {
      return const Padding(
        padding: EdgeInsets.only(top: 16),
        child: Text(
          'הדגם לא תומך בהגבלת זרם טעינה AC (trim).',
          textAlign: TextAlign.start,
        ),
      );
    }
    if (s.available != true) {
      return Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Text(
          s.error ?? 'נתוני זרם טעינה לא זמינים כעת מהרכב.',
        ),
      );
    }
    final selected = s.state ?? 3;
    final labels = <int, String>{
      for (var i = 1; i <= 5; i++) i: _labelForState(i, selected == i ? s.label : null),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        Text('זרם טעינה AC', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 6),
        Text(
          'רמות 1–5 לפי SDK הרכב (readback לאחר POST).',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        if (_saving)
          const LinearProgressIndicator(minHeight: 2),
        const SizedBox(height: 8),
        SegmentedButton<int>(
          segments: [
            for (var i = 1; i <= 5; i++)
              ButtonSegment<int>(
                value: i,
                label: Text(labels[i]!, style: const TextStyle(fontSize: 12)),
              ),
          ],
          selected: {selected},
          onSelectionChanged: _saving
              ? null
              : (set) {
                  if (set.isNotEmpty) _select(set.first);
                },
        ),
        if (s.label != null) ...[
          const SizedBox(height: 8),
          Text('מצב נוכחי: ${s.label}', style: Theme.of(context).textTheme.bodySmall),
        ],
      ],
    );
  }

  String _labelForState(int state, String? serverLabel) {
    if (serverLabel != null && serverLabel.isNotEmpty) return serverLabel;
    const fallbacks = {
      1: '6A',
      2: '8A',
      3: '10A',
      4: '13A',
      5: '16A',
    };
    return fallbacks[state] ?? '$state';
  }
}
