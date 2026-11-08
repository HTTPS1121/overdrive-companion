import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/l10n_x.dart';
import '../../core/layout/scroll_insets.dart';
import '../../core/widgets/requires_connection.dart';
import '../../data/models/camera_models.dart';
import '../../providers/app_providers.dart';
import 'overdrive_live_preview.dart';
import 'recording_player_screen.dart';

class CameraHubScreen extends ConsumerStatefulWidget {
  const CameraHubScreen({super.key});

  @override
  ConsumerState<CameraHubScreen> createState() => _CameraHubScreenState();
}

class _CameraHubScreenState extends ConsumerState<CameraHubScreen> {
  StreamStatusState? _stream;
  RecordingsListState? _recordings;
  SurveillanceStatusState? _surveillance;
  SurveillanceConfigState? _config;
  bool _loading = true;
  String? _error;
  bool _busy = false;
  double _sensitivity = 3;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repo = ref.read(vehicleRepositoryProvider);
      final results = await Future.wait([
        repo.fetchStreamStatus(),
        repo.fetchRecordingsList(),
        repo.fetchSurveillanceStatus(),
      ]);
      if (!mounted) return;
      setState(() {
        _stream = results[0] as StreamStatusState;
        _recordings = results[1] as RecordingsListState;
        _surveillance = results[2] as SurveillanceStatusState;
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

  Future<void> _loadConfig() async {
    try {
      final cfg = await ref.read(vehicleRepositoryProvider).fetchSurveillanceConfig();
      if (!mounted) return;
      setState(() {
        _config = cfg;
        _sensitivity = (cfg.sensitivity ?? 3).toDouble();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _post(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
      await _reload();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _snapshot(int q) async {
    try {
      final bytes = await ref.read(vehicleRepositoryProvider).fetchSurveillanceSnapshot(q);
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          content: Image.memory(Uint8List.fromList(bytes), fit: BoxFit.contain),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return RequiresConnection(
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _reload,
              child: ListView(
                padding: scrollBottomPadding(context, extra: 96),
                children: [
                  Text(l10n.cameraLiveTitle, style: theme.textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(l10n.cameraLiveHelp, style: theme.textTheme.bodySmall),
                  const SizedBox(height: 12),
                  const OverdriveLivePreview(),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            l10n.streamConnectedLabel(
                              _stream?.success == true ? '${_stream?.connected}' : '—',
                            ),
                          ),
                          if (_stream?.viewMode != null)
                            Text(l10n.streamViewModeLabel(_stream!.viewMode!)),
                          if (_stream?.quality != null)
                            Text(_stream!.quality!, textDirection: TextDirection.ltr),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              FilledButton.tonal(
                                onPressed: _busy
                                    ? null
                                    : () => _post(() => ref.read(vehicleRepositoryProvider).enableStream()),
                                child: Text(l10n.cameraEnableStream),
                              ),
                              FilledButton.tonal(
                                onPressed: _busy
                                    ? null
                                    : () => _post(() => ref.read(vehicleRepositoryProvider).disableStream()),
                                child: Text(l10n.cameraDisableStream),
                              ),
                              for (final mode in [0, 1, 2, 3, 4])
                                FilledButton.tonal(
                                  onPressed: _busy
                                      ? null
                                      : () => _post(
                                            () => ref.read(vehicleRepositoryProvider).setStreamViewMode(mode),
                                          ),
                                  child: Text(_viewLabel(l10n, mode)),
                                ),
                              FilledButton.tonal(
                                onPressed: _busy
                                    ? null
                                    : () => _post(
                                          () => ref.read(vehicleRepositoryProvider).setStreamQuality('MEDIUM'),
                                        ),
                                child: Text(l10n.cameraViewQualityMedium),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(l10n.cameraSurveillanceTitle, style: theme.textTheme.titleLarge),
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          title: Text(
                            _surveillance?.enabled == true
                                ? l10n.surveillanceEnabled
                                : l10n.surveillanceDisabled,
                          ),
                        ),
                        Wrap(
                          spacing: 8,
                          children: [
                            TextButton(
                              onPressed: _busy
                                  ? null
                                  : () => _post(() => ref.read(vehicleRepositoryProvider).enableSurveillance()),
                              child: Text(l10n.surveillanceEnable),
                            ),
                            TextButton(
                              onPressed: _busy
                                  ? null
                                  : () => _post(() => ref.read(vehicleRepositoryProvider).disableSurveillance()),
                              child: Text(l10n.surveillanceDisable),
                            ),
                            TextButton(onPressed: _loadConfig, child: Text(l10n.surveillanceLoadConfig)),
                          ],
                        ),
                        if (_config != null)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Slider(
                                  value: _sensitivity,
                                  min: 1,
                                  max: 5,
                                  divisions: 4,
                                  label: _sensitivity.round().toString(),
                                  onChanged: (v) => setState(() => _sensitivity = v),
                                ),
                                FilledButton(
                                  onPressed: () => _post(
                                    () => ref.read(vehicleRepositoryProvider).postSurveillanceConfig({
                                      'sensitivity': _sensitivity.round(),
                                    }),
                                  ),
                                  child: Text(l10n.surveillanceSaveConfig),
                                ),
                              ],
                            ),
                          ),
                        Wrap(
                          spacing: 8,
                          children: List.generate(
                            4,
                            (q) => OutlinedButton(
                              onPressed: () => _snapshot(q),
                              child: Text(l10n.surveillanceSnapshot(q)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(l10n.cameraRecordingsTitle, style: theme.textTheme.titleLarge),
                  if (_error != null) Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
                  if (_recordings?.success != true)
                    Text(l10n.recordingLoadFailed)
                  else if (_recordings!.recordings.isEmpty)
                    Text(l10n.recordingNone)
                  else
                    ..._recordings!.recordings.take(40).map(
                          (r) => ListTile(
                            title: Text(r.filename, textDirection: TextDirection.ltr),
                            subtitle: Text([r.place, r.timestamp].whereType<String>().join(' · ')),
                            trailing: r.sizeBytes != null
                                ? Text('${(r.sizeBytes! / (1024 * 1024)).toStringAsFixed(1)} MB')
                                : null,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => RecordingPlayerScreen(entry: r),
                              ),
                            ),
                          ),
                        ),
                ],
              ),
            ),
    );
  }

  String _viewLabel(dynamic l10n, int mode) => switch (mode) {
        0 => l10n.cameraViewMosaic,
        1 => l10n.cameraViewFront,
        2 => l10n.cameraViewRight,
        3 => l10n.cameraViewRear,
        4 => l10n.cameraViewLeft,
        _ => '$mode',
      };
}
