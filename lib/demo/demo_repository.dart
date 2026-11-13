import 'demo_models.dart';

abstract class VehicleRepository {
  String get carName;
  String get carTrim;
  int get rangeKm;
  int get batteryPercent;
  bool get locked;
  bool get powered;
  bool get trunkOpen;
  String get refreshLabel;

  Future<void> setLocked(bool value);
  Future<void> setPowered(bool value);
  Future<void> setTrunkOpen(bool value);

  List<DemoRecording> get recordings;
  List<String> get placeFilters;
}

/// In-memory demo — mirrors `overdrive-chosen.html` data.
class DemoVehicleRepository implements VehicleRepository {
  DemoVehicleRepository() {
    _recordings = _seedRecordings;
  }

  @override
  String carName = 'BYD Atto 3';
  @override
  String carTrim = 'Comfort';
  @override
  int rangeKm = 342;
  @override
  int batteryPercent = 78;
  @override
  bool locked = true;
  @override
  bool powered = false;
  @override
  bool trunkOpen = false;
  @override
  String refreshLabel = 'נתוני דוגמה · כעת';

  late List<DemoRecording> _recordings;

  @override
  List<DemoRecording> get recordings => List.unmodifiable(_recordings);

  @override
  List<String> get placeFilters => const [
        'קרית יערים',
        'פרדס כץ',
        'נוה שמיר',
        'מודיעין עילית',
        'נוה אילן',
        'רמב"ם',
        'תל ארזה',
        'רמת בית שמש ד\'',
      ];

  @override
  Future<void> setLocked(bool value) async => locked = value;

  @override
  Future<void> setPowered(bool value) async => powered = value;

  @override
  Future<void> setTrunkOpen(bool value) async => trunkOpen = value;

  static const _seedRecordings = [
    DemoRecording(
      id: 0,
      day: '13 בנוב׳ 2026',
      type: RecordingType.sentry,
      typeLabel: 'אבטחה',
      time: '12:31',
      dur: '00:46',
      size: '43.0 MB',
      storage: 'INTERNAL',
      storageLabel: 'זיכרון פנימי',
      place: 'קרית יערים, מחוז ירושלים',
      shortPlace: 'קרית יערים',
      actor: 'person',
      actorLabel: 'אדם',
      sev: 'ALERT',
      sevLabel: 'התרעה',
      prox: 'CLOSE',
      proxLabel: 'קרוב',
      trigger: 'הרתעת מסך',
      file: 'event_20261113_123110.mp4',
    ),
    DemoRecording(
      id: 1,
      day: '13 בנוב׳ 2026',
      type: RecordingType.sentry,
      typeLabel: 'אבטחה',
      time: '12:12',
      dur: '00:46',
      size: '57.7 MB',
      storage: 'INTERNAL',
      storageLabel: 'זיכרון פנימי',
      place: 'קרית יערים, מחוז ירושלים',
      shortPlace: 'קרית יערים',
      actor: 'person',
      actorLabel: 'אדם',
      sev: 'ALERT',
      sevLabel: 'התרעה',
      prox: 'VERY_CLOSE',
      proxLabel: 'קרוב מאוד',
      trigger: 'הרתעת מסך',
      file: 'event_20261113_121217.mp4',
    ),
    DemoRecording(
      id: 2,
      day: '13 בנוב׳ 2026',
      type: RecordingType.proximity,
      typeLabel: 'קרבה',
      time: '17:15',
      dur: '00:18',
      size: '28.1 MB',
      storage: 'INTERNAL',
      storageLabel: 'זיכרון פנימי',
      place: 'פרדס כץ, תל אביב',
      shortPlace: 'פרדס כץ',
      actor: 'vehicle',
      actorLabel: 'רכב',
      sev: 'NOTICE',
      sevLabel: 'לידיעה',
      prox: 'MID',
      proxLabel: 'מרחק בינוני',
      trigger: 'חיישן קרבה',
      file: 'event_20261113_171502.mp4',
    ),
    DemoRecording(
      id: 3,
      day: '12 בנוב׳ 2026',
      type: RecordingType.normal,
      typeLabel: 'רגיל',
      time: '08:40',
      dur: '02:00',
      size: '210.4 MB',
      storage: 'USB',
      storageLabel: 'USB',
      place: 'נוה שמיר, השרון',
      shortPlace: 'נוה שמיר',
      actor: 'vehicle',
      actorLabel: 'רכב',
      sev: 'NOTICE',
      sevLabel: 'לידיעה',
      prox: 'FAR',
      proxLabel: 'רחוק',
      trigger: 'הקלטת נסיעה',
      file: 'drive_20261112_084012.mp4',
    ),
    DemoRecording(
      id: 4,
      day: '12 בנוב׳ 2026',
      type: RecordingType.replay,
      typeLabel: 'הילוכים חוזרים',
      time: '16:02',
      dur: '00:32',
      size: '19.8 MB',
      storage: 'SD_CARD',
      storageLabel: 'כרטיס SD',
      place: 'מודיעין עילית',
      shortPlace: 'מודיעין עילית',
      actor: 'bike',
      actorLabel: 'אופניים',
      sev: 'NOTICE',
      sevLabel: 'לידיעה',
      prox: 'CLOSE',
      proxLabel: 'קרוב',
      trigger: 'סימון ידני',
      file: 'replay_20261112_160244.mp4',
    ),
  ];
}
