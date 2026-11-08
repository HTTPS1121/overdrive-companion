import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/layout/scroll_insets.dart';
import '../../core/widgets/requires_connection.dart';
import '../../data/models/camera_models.dart';
import '../../providers/app_providers.dart';

/// Cameras: stream HTTP controls, recordings list, surveillance status.
/// Live H.264 uses `wss?://host/ws?token=<jwt>` (StreamingApiHandler + stream.js) — decode pending.
class CameraHubScreen extends ConsumerStatefulWidget {
  const CameraHubScreen({super.key});

  @override
  ConsumerState<CameraHubScreen> createState() => _CameraHubScreenState();
}

class _CameraHubScreenState extends ConsumerState<CameraHubScreen> {
  StreamStatusState? _stream;
  RecordingsListState? _recordings;
  SurveillanceStatusState? _surveillance;
  bool _loading = true;
  String? _error;
  bool _busy = false;

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return RequiresConnection(
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: scrollBottomPadding(context, extra: 96),
              children: [
                Text('שידור חי', style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(
                  'שליטה ב־/api/stream/*. תצוגת H.264 דורשת WebSocket ‎/ws?token=JWT‎ (כמו stream.js) — לא WebView.',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(_stream?.success == true ? 'מחובר: ${_stream?.connected}' : 'לא זמין'),
                        if (_stream?.viewMode != null)
                          Text('מצב תצוגה: ${_stream!.viewMode}', textDirection: TextDirection.ltr),
                        if (_stream?.quality != null)
                          Text('איכות: ${_stream!.quality}', textDirection: TextDirection.ltr),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            FilledButton.tonal(
                              onPressed: _busy
                                  ? null
                                  : () => _post(() => ref.read(vehicleRepositoryProvider).enableStream()),
                              child: const Text('הפעל שידור'),
                            ),
                            FilledButton.tonal(
                              onPressed: _busy
                                  ? null
                                  : () => _post(() => ref.read(vehicleRepositoryProvider).disableStream()),
                              child: const Text('כבה שידור'),
                            ),
                            FilledButton.tonal(
                              onPressed: _busy
                                  ? null
                                  : () => _post(
                                        () => ref.read(vehicleRepositoryProvider).setStreamViewMode(0),
                                      ),
                              child: const Text('מוזאיקה (0)'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text('מעקב / נהיגה', style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                Card(
                  child: ListTile(
                    title: Text(_surveillance?.enabled == true ? 'פעיל' : 'כבוי'),
                    subtitle: const Text('/api/surveillance/status'),
                  ),
                ),
                const SizedBox(height: 20),
                Text('הקלטות', style: theme.textTheme.titleLarge),
                if (_error != null) Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
                if (_recordings?.success != true)
                  const Text('לא ניתן לטעון רשימת הקלטות')
                else if (_recordings!.recordings.isEmpty)
                  const Text('אין הקלטות')
                else
                  ..._recordings!.recordings.take(30).map(
                        (r) => ListTile(
                          title: Text(r.filename, textDirection: TextDirection.ltr),
                          subtitle: Text([r.place, r.timestamp].whereType<String>().join(' · ')),
                          trailing: r.sizeBytes != null
                              ? Text('${(r.sizeBytes! / (1024 * 1024)).toStringAsFixed(1)} MB')
                              : null,
                        ),
                      ),
              ],
            ),
    );
  }
}
