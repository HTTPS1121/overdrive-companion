import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/command_result_l10n.dart';
import '../../core/l10n/l10n_x.dart';
import '../../data/models/remote_services_models.dart';
import '../../providers/app_providers.dart';

class SurveillanceDiagnosticsPanel extends ConsumerStatefulWidget {
  const SurveillanceDiagnosticsPanel({super.key});

  @override
  ConsumerState<SurveillanceDiagnosticsPanel> createState() => _SurveillanceDiagnosticsPanelState();
}

class _SurveillanceDiagnosticsPanelState extends ConsumerState<SurveillanceDiagnosticsPanel> {
  SurveillanceHeatmapState? _heatmap;
  SurveillanceFilterLogState? _filterLog;
  bool _busy = false;

  Future<void> _run(Future<void> Function() fn) async {
    setState(() => _busy = true);
    try {
      await fn();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _loadHeatmap() async {
    final data = await ref.read(vehicleRepositoryProvider).fetchSurveillanceHeatmap();
    if (!mounted) return;
    setState(() => _heatmap = data);
  }

  Future<void> _loadFilterLog() async {
    final data = await ref.read(vehicleRepositoryProvider).fetchSurveillanceFilterLog();
    if (!mounted) return;
    setState(() => _filterLog = data);
  }

  Future<void> _previewDeterrent() async {
    final bytes = await ref.read(vehicleRepositoryProvider).fetchScreenDeterrentImage();
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Image.memory(Uint8List.fromList(bytes), fit: BoxFit.contain),
      ),
    );
  }

  Future<void> _testDeterrent() async {
    final l10n = context.l10n;
    final result = await ref.read(vehicleRepositoryProvider).postScreenDeterrentTest();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.userMessage(l10n, actionLabel: l10n.surveillanceScreenDeterrentTest),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.surveillanceHeatmapTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.tonal(
                  onPressed: _busy ? null : () => _run(_loadHeatmap),
                  child: Text(l10n.surveillanceHeatmapLoad),
                ),
                FilledButton.tonal(
                  onPressed: _busy ? null : () => _run(_loadFilterLog),
                  child: Text(l10n.surveillanceFilterLogLoad),
                ),
              ],
            ),
            if (_heatmap != null) ...[
              const SizedBox(height: 8),
              Text(
                'viewMode=${_heatmap!.viewMode} · ${_heatmap!.gridCols}×${_heatmap!.gridRows}',
                style: theme.textTheme.bodySmall,
              ),
              ..._heatmap!.quadrants.map(
                (q) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    l10n.heatmapQuadrantSummary(
                      q.name ?? 'Q${q.id}',
                      '${q.activeBlocks ?? 0}',
                    ),
                  ),
                  trailing: Text('T${q.threatLevel ?? 0}'),
                ),
              ),
            ],
            if (_filterLog != null) ...[
              const SizedBox(height: 8),
              Text(l10n.surveillanceFilterLogTitle, style: theme.textTheme.titleSmall),
              if (_filterLog!.lines.isEmpty)
                Text(l10n.filterLogEmpty, style: theme.textTheme.bodySmall)
              else
                ..._filterLog!.lines.take(20).map(
                      (line) => Text(line, style: theme.textTheme.bodySmall),
                    ),
            ],
            const Divider(height: 24),
            Text(l10n.surveillanceScreenDeterrentTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                OutlinedButton(
                  onPressed: _busy ? null : () => _run(_previewDeterrent),
                  child: Text(l10n.surveillanceScreenDeterrentFetch),
                ),
                OutlinedButton(
                  onPressed: _busy ? null : () => _run(_testDeterrent),
                  child: Text(l10n.surveillanceScreenDeterrentTest),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
