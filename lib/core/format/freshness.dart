/// How old vehicle telemetry may be before we warn the user.
class DataFreshness {
  const DataFreshness({
    required this.serverEpochSec,
    required this.fetchedAt,
    this.staleAfter = const Duration(seconds: 45),
  });

  final int? serverEpochSec;
  final DateTime fetchedAt;
  final Duration staleAfter;

  DateTime? get serverTime {
    if (serverEpochSec == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(serverEpochSec! * 1000, isUtc: true)
        .toLocal();
  }

  Duration? get age {
    final t = serverTime;
    if (t == null) return null;
    return fetchedAt.difference(t);
  }

  bool get isStale {
    final a = age;
    if (a == null) return false;
    return a > staleAfter || a.isNegative;
  }

  String ageLabelHe() {
    final a = age;
    if (a == null) return 'מקור זמן לא ידוע';
    if (a.isNegative) return 'שעון רכב מקדים';
    if (a.inSeconds < 90) return 'לפני ${a.inSeconds} שנ׳';
    if (a.inMinutes < 60) return 'לפני ${a.inMinutes} דק׳';
    return 'לפני ${a.inHours} שע׳';
  }
}
