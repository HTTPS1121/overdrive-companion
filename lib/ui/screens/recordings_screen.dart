import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/companion_models.dart';
import '../../design/od_design.dart';
import '../../icons/od_icon.dart';
import '../../state/companion_app_controller.dart';
import '../widgets/od_rtl_scroll_row.dart';
import '../widgets/od_widgets.dart';
import '../widgets/recording_thumb.dart';
import '../widgets/recordings_filters.dart';

class RecordingsScreen extends ConsumerWidget {
  const RecordingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctrl = ref.watch(companionAppControllerProvider);
    final list = ctrl.filteredRecordings();
    return OdTabScroll(
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
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: odIsolateLtr('${list.length} '), style: odNum(12)),
                    TextSpan(text: 'סרטונים', style: odMuted(12)),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (ctrl.recordingsState == DataLoadState.error)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              ctrl.recordingsErrorHebrew ?? 'לא ניתן לטעון הקלטות.',
              textAlign: TextAlign.center,
              style: odBody(13, FontWeight.w600, const Color(0xFF9B1C1C)),
            ),
          )
        else if (list.isEmpty)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              ctrl.recordingsState == DataLoadState.loading
                  ? 'טוען הקלטות מהשרת…'
                  : 'אין הקלטות שעונות לסינון הנוכחי.',
              textAlign: TextAlign.center,
              style: odMuted(13),
            ),
          )
        else
          ..._recordingSections(list),
      ],
    );
  }

  List<Widget> _recordingSections(List<Recording> list) {
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
      out.add(_RecordingCard(recording: r, key: ValueKey('rec_${r.id}')));
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

  final CompanionAppController ctrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _CalendarToggle(),
            const SizedBox(width: 8),
            Expanded(child: _TypeTabs(ctrl: ctrl)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Expanded(child: _StorageStats()),
            const SizedBox(width: 8),
            _OemDvrChip(),
          ],
        ),
      ],
    );
  }
}

class _CalendarToggle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFE8EDF4),
      shape: StadiumBorder(side: const BorderSide(color: OdColors.line)),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: () {},
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14),
          child: SizedBox(
            height: 42,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                OdIcon(OdIconName.trip, size: 17, color: OdColors.blue),
                SizedBox(width: 8),
                Text('בחר תאריך', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StorageStats extends StatelessWidget {
  const _StorageStats();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EDF4),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: OdColors.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          OdLtrText('31.2 GB', style: odNum(11, weight: FontWeight.w600, color: OdColors.muted)),
          const SizedBox(width: 8),
          SizedBox(
            width: 48,
            height: 5,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: const LinearProgressIndicator(
                value: 0.24,
                backgroundColor: Color(0xFFD5DFEC),
                valueColor: AlwaysStoppedAnimation(OdColors.blue),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OemDvrChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: StadiumBorder(side: const BorderSide(color: OdColors.line)),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: () {},
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: SizedBox(
            height: 40,
            child: Center(
              child: Text(
                'מצלמת הדרך של היצרן',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: OdColors.blue),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TypeTabs extends ConsumerWidget {
  const _TypeTabs({required this.ctrl});

  final CompanionAppController ctrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const tabs = [
      ('all', 'הכל'),
      ('sentry', 'אבטחה'),
      ('normal', 'רגיל'),
      ('proximity', 'קרבה'),
      ('replay', 'הילוכים חוזרים'),
    ];
    return ClipRRect(
      borderRadius: BorderRadius.circular(99),
      clipBehavior: Clip.none,
      child: DecoratedBox(
        decoration: const BoxDecoration(color: Color(0xFFDFE6F0)),
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: OdRtlScrollRow(
            padding: EdgeInsets.zero,
            clipBehavior: Clip.hardEdge,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final t in tabs)
                  OdRecordingTypeTab(
                    label: t.$2,
                    active: ctrl.recFilters.type == t.$1,
                    onTap: () => ref.read(companionAppControllerProvider).setRecFilter('type', t.$1),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterRows extends ConsumerWidget {
  const _FilterRows({required this.ctrl});

  final CompanionAppController ctrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final f = ctrl.recFilters;
    final places = ref.watch(vehicleRepoProvider).placeFilters;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: OdColors.cardBorder),
        boxShadow: const [OdShadows.card],
      ),
      padding: const EdgeInsets.fromLTRB(0, 6, 0, 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _chipRow(context, ref, 'מה זוהה:', 'cls', [
            ('', 'הכל'),
            ('person', 'אדם'),
            ('vehicle', 'רכב'),
            ('bike', 'אופניים/אופנוע'),
            ('animal', 'בעל חיים'),
          ], f.cls),
          const Divider(height: 1, color: OdColors.line),
          _chipRow(context, ref, 'רמת חומרה:', 'sev', [
            ('', 'הכל'),
            ('NOTICE', 'לידיעה'),
            ('ALERT', 'התרעה'),
            ('CRITICAL', 'קריטי'),
          ], f.sev),
          const Divider(height: 1, color: OdColors.line),
          _chipRow(context, ref, 'מרחק:', 'prox', [
            ('', 'הכל'),
            ('VERY_CLOSE', 'קרוב מאוד'),
            ('CLOSE', 'קרוב'),
            ('MID', 'מרחק בינוני'),
            ('FAR', 'רחוק'),
          ], f.prox),
          const Divider(height: 1, color: OdColors.line),
          _chipRow(context, ref, 'אחסון:', 'stor', [
            ('', 'הכל'),
            ('INTERNAL', 'זיכרון פנימי'),
            ('SD_CARD', 'כרטיס SD'),
            ('USB', 'USB'),
          ], f.stor),
          const Divider(height: 1, color: OdColors.line),
          _chipRow(
            context,
            ref,
            'מקום:',
            'place',
            [
              ('', 'הכל'),
              for (final p in places) (p, p),
            ],
            f.place,
          ),
        ],
      ),
    );
  }

  Widget _chipRow(
    BuildContext context,
    WidgetRef ref,
    String label,
    String key,
    List<(String, String)> options,
    String current,
  ) {
    return OdRtlScrollRow(
      padding: const EdgeInsetsDirectional.fromSTEB(10, 6, 10, 0),
      clipBehavior: Clip.none,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 10),
            child: Text(label, style: odMuted(11).copyWith(fontWeight: FontWeight.w600)),
          ),
          for (final o in options)
            OdRecordingFilterChip(
              label: o.$2,
              active: current == o.$1,
              severityTone: key == 'sev' && current == o.$1
                  ? (o.$1 == 'ALERT'
                      ? 'alert'
                      : o.$1 == 'CRITICAL'
                          ? 'critical'
                          : null)
                  : null,
              onTap: () => ref.read(companionAppControllerProvider).setRecFilter(key, o.$1),
            ),
        ],
      ),
    );
  }
}

class _RecordingCard extends ConsumerWidget {
  const _RecordingCard({super.key, required this.recording});

  final Recording recording;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => ref.read(companionAppControllerProvider).openRecordingPlayer(recording.id),
        borderRadius: BorderRadius.circular(18),
        child: Container(
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
                RecordingThumb(recording: recording),
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
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9),
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0x9E000000),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: OdClipTypeBadge(type: recording.type, label: recording.typeLabel),
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
                    child: OdLtrText(
                      '${recording.dur} · ${recording.size}',
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                    ),
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
                    OdLtrText(recording.time, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
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
        ),
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
