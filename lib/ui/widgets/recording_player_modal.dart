import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../../data/hebrew_errors.dart';
import '../../design/od_design.dart';
import '../feedback/od_feedback.dart';
import '../../state/companion_app_controller.dart';

class RecordingPlayerModal extends ConsumerStatefulWidget {
  const RecordingPlayerModal({super.key});

  @override
  ConsumerState<RecordingPlayerModal> createState() => _RecordingPlayerModalState();
}

class _RecordingPlayerModalState extends ConsumerState<RecordingPlayerModal> {
  VideoPlayerController? _controller;
  String? _errorHebrew;
  bool _initializing = true;

  int? _boundPlayId;

  void _onVideoTick() {
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(covariant RecordingPlayerModal oldWidget) {
    super.didUpdateWidget(oldWidget);
    final id = ref.read(companionAppControllerProvider).recPlayId;
    if (id != _boundPlayId) {
      _boundPlayId = id;
      WidgetsBinding.instance.addPostFrameCallback((_) => _bindRecording());
    }
  }

  Future<void> _bindRecording() async {
    final ctrl = ref.read(companionAppControllerProvider);
    final id = ctrl.recPlayId;
    if (id == null) return;
    final r = ref.read(vehicleRepoProvider).recordings.firstWhere((x) => x.id == id);
    final client = ref.read(apiClientProvider);
    _controller?.removeListener(_onVideoTick);
    await _controller?.dispose();
    setState(() {
      _initializing = true;
      _errorHebrew = null;
    });
    try {
      final video = VideoPlayerController.networkUrl(
        client.recordingVideoUri(r.file),
        httpHeaders: client.authHeaders(),
      );
      await video.initialize();
      if (!mounted) {
        await video.dispose();
        return;
      }
      video.addListener(_onVideoTick);
      setState(() {
        _controller = video;
        _initializing = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorHebrew = 'לא ניתן להפעיל את ההקלטה מהשרת.';
        _initializing = false;
      });
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_onVideoTick);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = ref.watch(companionAppControllerProvider);
    final id = ctrl.recPlayId;
    if (id == null) return const SizedBox.shrink();
    if (_boundPlayId != id) {
      _boundPlayId = id;
      WidgetsBinding.instance.addPostFrameCallback((_) => _bindRecording());
    }
    final r = ref.watch(vehicleRepoProvider).recordings.firstWhere((x) => x.id == id);
    final angles = r.cameraAngles;
    final multiCam = angles.length > 1;
    final cam = multiCam
        ? (ctrl.recPlayQuad < angles.length ? angles[ctrl.recPlayQuad] : angles.first)
        : (r.cameraLabel ?? 'מצלמה');
    final video = _controller;

    return Positioned.fill(
      child: Material(
        color: const Color(0xC70C254A),
        child: SafeArea(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 460, maxHeight: 820),
              decoration: const BoxDecoration(
                color: Color(0xFF0E2238),
                borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            r.file,
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                            textDirection: TextDirection.ltr,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          onPressed: () => ref.read(companionAppControllerProvider).closeRecordingPlayer(),
                          icon: const Icon(Icons.close, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  Stack(
                    children: [
                      SizedBox(
                        height: 200,
                        width: double.infinity,
                        child: ColoredBox(
                          color: const Color(0xFF123D5A),
                          child: _initializing
                              ? const Center(child: CircularProgressIndicator(color: Colors.white))
                              : _errorHebrew != null
                                  ? Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Text(
                                          _errorHebrew!,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(color: Colors.white, fontSize: 13),
                                        ),
                                      ),
                                    )
                                  : video != null && video.value.isInitialized
                                      ? Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            FittedBox(
                                              fit: BoxFit.cover,
                                              child: SizedBox(
                                                width: video.value.size.width,
                                                height: video.value.size.height,
                                                child: VideoPlayer(video),
                                              ),
                                            ),
                                            Positioned(
                                              top: 10,
                                              right: 10,
                                              child: _camBadge('$cam · ${r.time}'),
                                            ),
                                          ],
                                        )
                                      : const SizedBox.shrink(),
                        ),
                      ),
                      if (multiCam)
                        Positioned(
                          bottom: 10,
                          left: 10,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xBF0C2348),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                for (var i = 0; i < angles.length; i++)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 2),
                                    child: Material(
                                      color: ctrl.recPlayQuad == i ? OdColors.blue : const Color(0x1FFFFFFF),
                                      borderRadius: BorderRadius.circular(8),
                                      child: InkWell(
                                        onTap: () => ref.read(companionAppControllerProvider).setRecPlayQuad(i),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                          child: Text(
                                            angles[i],
                                            style: const TextStyle(color: Colors.white, fontSize: 10),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  Container(
                    color: const Color(0xFF142F50),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'תחילת אירוע · ${r.trigger}',
                          style: const TextStyle(color: Color(0xFFB8C8DC), fontSize: 9),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Material(
                              color: const Color(0x1AFFFFFF),
                              shape: const CircleBorder(),
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: video == null
                                    ? null
                                    : () {
                                        if (video.value.isPlaying) {
                                          video.pause();
                                        } else {
                                          video.play();
                                        }
                                        setState(() {});
                                      },
                                child: SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: Icon(
                                    video?.value.isPlaying == true ? Icons.pause : Icons.play_arrow,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ),
                            OdLtrText(
                              _clock(video) + ' / ${r.dur}',
                              style: const TextStyle(color: Color(0xFFDCE7F5), fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Row(
                      children: [
                        Expanded(child: OdLtrText('${r.day} · ${r.time} · ${r.size}', style: odMuted(12))),
                        TextButton(
                          onPressed: () => showOdFeedback(ref, hebrewFeatureNotOnServer()),
                          style: TextButton.styleFrom(backgroundColor: OdColors.navActiveBg),
                          child: const Text('הורדה', style: TextStyle(color: OdColors.navActiveFg)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _clock(VideoPlayerController? video) {
    if (video == null || !video.value.isInitialized) return '0:00';
    final sec = video.value.position.inSeconds;
    final m = sec ~/ 60;
    final s = sec % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  Widget _camBadge(String text) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xE80C2348),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
