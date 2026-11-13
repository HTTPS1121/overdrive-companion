import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../demo/demo_models.dart';
import '../../design/od_design.dart';
import '../../icons/od_icon.dart';
import '../../illustrations/od_illustrations.dart';
import '../../state/demo_app_controller.dart';

class RecordingsScreen extends ConsumerWidget {
  const RecordingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctrl = ref.watch(demoAppControllerProvider);
    final list = ctrl.filteredRecordings();
    return ListView(
      padding: const EdgeInsets.only(bottom: 8),
      children: [
        _EventsTopBar(ctrl: ctrl),
        const SizedBox(height: 12),
        _FilterRows(ctrl: ctrl),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Text(_title(ctrl.recFilters.type), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(width: 8),
              Text('${list.length} סרטונים', style: odMuted(12)),
            ],
          ),
        ),
        if (list.isEmpty)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'אין הקלטות שעונות לסינון הנוכחי · נתוני דמו.',
              textAlign: TextAlign.center,
              style: odMuted(13),
            ),
          )
        else
          ..._recordingSections(list),
        Padding(
          padding: const EdgeInsets.all(4),
          child: Text(
            'סינון, מיקום וסיווג — נתוני המחשה. הורדה ונגינה אמיתית לא מחוברות.',
            style: odMuted(12).copyWith(height: 1.7),
          ),
        ),
      ],
    );
  }

  List<Widget> _recordingSections(List<DemoRecording> list) {
    final out = <Widget>[];
    String? day;
    for (final r in list) {
      if (r.day != day) {
        day = r.day;
        out.add(
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 6, 4, 2),
            child: Text(r.day, style: odMuted(12).copyWith(fontWeight: FontWeight.w700)),
          ),
        );
      }
      out.add(_RecordingCard(recording: r));
    }
    return out;
  }

  String _title(String type) => switch (type) {
        'all' => 'הקלטות הכל',
        'sentry' => 'אבטחה',
        'normal' => 'רגיל',
        'proximity' => 'קרבה',
        'replay' => 'הילוכים חוזרים',
        _ => 'הקלטות',
      };
}

class _EventsTopBar extends StatelessWidget {
  const _EventsTopBar({required this.ctrl});

  final DemoAppController ctrl;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _PillButton(
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              OdIcon(OdIconName.trip, size: 17, color: OdColors.blue),
              SizedBox(width: 8),
              Text('בחר תאריך', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        _TypeTabs(ctrl: ctrl),
        _PillButton(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('31.2 GB', style: odNum(11, weight: FontWeight.w600)),
              const SizedBox(width: 8),
              SizedBox(
                width: 48,
                height: 5,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: const LinearProgressIndicator(value: 0.24, backgroundColor: Color(0xFFD5DFEC)),
                ),
              ),
            ],
          ),
        ),
        _PillButton(
          child: const Text('מצלמת הדרך של היצרן', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: OdColors.blue)),
        ),
      ],
    );
  }
}

class _TypeTabs extends ConsumerWidget {
  const _TypeTabs({required this.ctrl});

  final DemoAppController ctrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const tabs = [
      ('all', 'הכל'),
      ('sentry', 'אבטחה'),
      ('normal', 'רגיל'),
      ('proximity', 'קרבה'),
      ('replay', 'הילוכים חוזרים'),
    ];
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFDFE6F0),
        borderRadius: BorderRadius.circular(99),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
        children: [
          for (final t in tabs)
            GestureDetector(
              onTap: () => ref.read(demoAppControllerProvider).setRecFilter('type', t.$1),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: ctrl.recFilters.type == t.$1 ? OdColors.navActiveBg : Colors.transparent,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  t.$2,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: ctrl.recFilters.type == t.$1 ? OdColors.navActiveFg : OdColors.muted,
                  ),
                ),
              ),
            ),
        ],
        ),
      ),
    );
  }
}

class _FilterRows extends StatelessWidget {
  const _FilterRows({required this.ctrl});

  final DemoAppController ctrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: OdColors.cardBorder),
        boxShadow: const [OdShadows.card],
      ),
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: const Text(
        'מסנני זיהוי · חומרה · מרחק · אחסון · מקום (דמו)',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 11, color: OdColors.muted),
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EDF4),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: OdColors.line),
      ),
      child: child,
    );
  }
}

class _RecordingCard extends StatelessWidget {
  const _RecordingCard({required this.recording});

  final DemoRecording recording;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: OdColors.cardBorder),
        boxShadow: const [OdShadows.card],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                const OdSceneView(label: 'תצוגה מדומה'),
                Center(
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0x8C000000),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white54, width: 2),
                    ),
                    child: const Icon(Icons.play_arrow, color: Colors.white, size: 22),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9),
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0x9E000000),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(recording.typeLabel, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xA8000000),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('${recording.dur} · ${recording.size}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: const Color(0x1F78808A),
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(recording.time, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8EDF4),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(recording.storageLabel, style: odMuted(10).copyWith(fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(recording.place, style: odMuted(12)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  children: [
                    _pill(recording.actorLabel),
                    _pill(recording.trigger),
                    _pill(recording.sevLabel, alert: true),
                    _pill(recording.proxLabel),
                  ],
                ),
                const SizedBox(height: 8),
                const Divider(height: 1, color: OdColors.line),
                const SizedBox(height: 8),
                Text(
                  recording.file,
                  textAlign: TextAlign.end,
                  textDirection: TextDirection.ltr,
                  style: odMuted(11),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill(String label, {bool alert = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: alert ? const Color(0xFFFFF4E6) : const Color(0xFFE6EDF8),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: alert ? const Color(0xFFB36A00) : OdColors.blue,
        ),
      ),
    );
  }
}
