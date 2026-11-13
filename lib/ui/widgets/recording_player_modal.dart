import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design/od_design.dart';
import '../../illustrations/od_illustrations.dart';
import '../../state/companion_app_controller.dart';

class RecordingPlayerModal extends ConsumerWidget {
  const RecordingPlayerModal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctrl = ref.watch(companionAppControllerProvider);
    final id = ctrl.recPlayId;
    if (id == null) return const SizedBox.shrink();
    final r = ref.read(vehicleRepoProvider).recordings.firstWhere((x) => x.id == id);
    final cam = CompanionAppController.cams[ctrl.recPlayQuad];
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
                        child: OdSceneView(
                          label: cam,
                          height: 200,
                          backdrop: const Color(0xFF123D5A),
                          overlay: OdSceneOverlay.standardTopEnd,
                        ),
                      ),
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
                              for (var i = 0; i < CompanionAppController.cams.length; i++)
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
                                          CompanionAppController.cams[i].split(' ').last,
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
                          'תחילת אירוע (7 שנ׳ לפני) · תנועה אדם · ${r.trigger}',
                          style: const TextStyle(color: Color(0xFFB8C8DC), fontSize: 9),
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: const LinearProgressIndicator(value: 0.18, minHeight: 8, color: OdColors.blue, backgroundColor: Color(0xFF2A4568)),
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
                                onTap: () {},
                                child: const SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: Icon(Icons.play_arrow, color: Colors.white, size: 22),
                                ),
                              ),
                            ),
                            OdLtrText(
                              '${odFormatClockSeconds(ctrl.recPlaySeconds)} / ${r.dur}',
                              style: const TextStyle(color: Color(0xFFDCE7F5), fontSize: 12),
                            ),
                            const OdLtrText('1.0×', style: TextStyle(color: Color(0xFFDCE7F5), fontSize: 12)),
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
                          onPressed: () {},
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
}
