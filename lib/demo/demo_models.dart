enum OdScreen { home, camera, record, trip, more }

enum RecordingType { sentry, proximity, normal, replay }

class DemoRecording {
  const DemoRecording({
    required this.id,
    required this.day,
    required this.type,
    required this.typeLabel,
    required this.time,
    required this.dur,
    required this.size,
    required this.storage,
    required this.storageLabel,
    required this.place,
    required this.shortPlace,
    required this.actor,
    required this.actorLabel,
    required this.sev,
    required this.sevLabel,
    required this.prox,
    required this.proxLabel,
    required this.trigger,
    required this.file,
  });

  final int id;
  final String day;
  final RecordingType type;
  final String typeLabel;
  final String time;
  final String dur;
  final String size;
  final String storage;
  final String storageLabel;
  final String place;
  final String shortPlace;
  final String actor;
  final String actorLabel;
  final String sev;
  final String sevLabel;
  final String prox;
  final String proxLabel;
  final String trigger;
  final String file;
}

class MoreGroupItem {
  const MoreGroupItem({required this.title, required this.subtitle});
  final String title;
  final String subtitle;
}

class MoreGroup {
  const MoreGroup(this.title, this.icon, this.items);
  final String title;
  final String icon;
  final List<MoreGroupItem> items;
}
