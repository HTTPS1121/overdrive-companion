import 'package:flutter/material.dart';

import '../../core/format/seat_levels.dart';
import '../../core/l10n/l10n_x.dart';
import '../../data/models/vehicle_state.dart';

class SeatControlsPanel extends StatelessWidget {
  const SeatControlsPanel({
    super.key,
    required this.seats,
    required this.busy,
    required this.onHeatLevel,
    required this.onVentLevel,
    required this.onMemoryRecall,
    required this.onMemorySave,
  });

  final SeatInfo? seats;
  final bool busy;
  final void Function(int position, int level) onHeatLevel;
  final void Function(int position, int level) onVentLevel;
  final void Function(int position) onMemoryRecall;
  final void Function(int position) onMemorySave;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final ventOk = seats?.ventilatedSupported != false;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.seatHint,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        for (var pos = 1; pos <= 2; pos++) ...[
          Text(
            pos == 1 ? l10n.seatDriver : l10n.seatPassenger,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          _LevelRow(
            title: l10n.seatHeat,
            current: _levelAt(seats?.heat, pos),
            busy: busy,
            onPick: (l) => onHeatLevel(pos, l),
          ),
          const SizedBox(height: 8),
          _LevelRow(
            title: l10n.seatVent,
            current: _levelAt(seats?.cool, pos),
            busy: busy || !ventOk,
            disabledHint: ventOk ? null : l10n.seatVentUnsupported,
            onPick: (l) => onVentLevel(pos, l),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: busy ? null : () => onMemoryRecall(pos),
                  icon: const Icon(Icons.restore),
                  label: Text(l10n.seatRecallMemory),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: busy ? null : () => onMemorySave(pos),
                  icon: const Icon(Icons.save_outlined),
                  label: Text(l10n.seatSaveMemory),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ],
    );
  }

  int _levelAt(List<int>? levels, int position) {
    if (levels == null || levels.length < position) return 0;
    return levels[position - 1];
  }
}

class _LevelRow extends StatelessWidget {
  const _LevelRow({
    required this.title,
    required this.current,
    required this.busy,
    required this.onPick,
    this.disabledHint,
  });

  final String title;
  final int current;
  final bool busy;
  final void Function(int level) onPick;
  final String? disabledHint;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final labels = seatLevelLabels(l10n);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$title — ${seatLevelLabel(l10n, current)}'),
        if (disabledHint != null)
          Text(disabledHint!, style: Theme.of(context).textTheme.bodySmall)
        else
          Wrap(
            spacing: 8,
            children: [
              for (var level = 0; level < labels.length; level++)
                ChoiceChip(
                  label: Text(labels[level]),
                  selected: current == level,
                  onSelected: busy ? null : (_) => onPick(level),
                ),
            ],
          ),
      ],
    );
  }
}
