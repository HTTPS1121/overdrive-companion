import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

import '../../core/l10n/l10n_x.dart';
import '../../data/models/camera_models.dart';
import '../../providers/app_providers.dart';

class RecordingPlayerScreen extends ConsumerStatefulWidget {
  const RecordingPlayerScreen({super.key, required this.entry});

  final RecordingEntry entry;

  @override
  ConsumerState<RecordingPlayerScreen> createState() => _RecordingPlayerScreenState();
}

class _RecordingPlayerScreenState extends ConsumerState<RecordingPlayerScreen> {
  VideoPlayerController? _controller;
  String? _error;
  bool _downloading = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final repo = ref.read(vehicleRepositoryProvider);
    final jwt = repo.sessionJwt;
    if (jwt == null || jwt.isEmpty) {
      setState(() => _error = 'auth');
      return;
    }
    try {
      final url = repo.videoUrlForRecording(widget.entry);
      final c = VideoPlayerController.networkUrl(
        url,
        httpHeaders: {'Authorization': 'Bearer $jwt'},
      );
      await c.initialize();
      if (!mounted) return;
      setState(() => _controller = c..play());
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  Future<void> _download() async {
    setState(() => _downloading = true);
    try {
      final repo = ref.read(vehicleRepositoryProvider);
      final bytes = await repo.downloadRecordingBytes(widget.entry);
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/${widget.entry.filename}');
      await file.writeAsBytes(bytes, flush: true);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.recordingSavedTo(file.path))),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.entry.filename, textDirection: TextDirection.ltr),
        actions: [
          IconButton(
            onPressed: _downloading ? null : _download,
            icon: _downloading
                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.download),
            tooltip: l10n.recordingDownload,
          ),
        ],
      ),
      body: _error != null
          ? Center(child: Text(_error == 'auth' ? l10n.errorSessionExpired : _error!))
          : _controller == null || !_controller!.value.isInitialized
              ? const Center(child: CircularProgressIndicator())
              : Center(
                  child: AspectRatio(
                    aspectRatio: _controller!.value.aspectRatio,
                    child: VideoPlayer(_controller!),
                  ),
                ),
    );
  }
}
