import 'package:overdrive_companion/l10n/app_localizations.dart';

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

  /// Hebrew age of server timestamp relative to local fetch time.
  String ageLabelHe() {
    final a = age;
    if (a == null) return 'מקור זמן לא ידוע';
    if (a.isNegative) return 'שעון הרכב מקדים את המכשיר';
    return _relativeHe(a);
  }

  /// How long ago we finished the last successful poll (always meaningful in UI).
  String fetchedAgoLabelHe(DateTime? lastFetch) {
    if (lastFetch == null) return 'לא עודכן עדיין';
    return 'עודכן ${_relativeHe(DateTime.now().difference(lastFetch))}';
  }

  String fetchedAgoLabelLocalized(AppLocalizations l10n, DateTime? lastFetch) {
    if (lastFetch == null) return l10n.freshnessNotYet;
    return l10n.freshnessUpdated(_relativeLocalized(l10n, DateTime.now().difference(lastFetch)));
  }

  static String _relativeLocalized(AppLocalizations l10n, Duration d) {
    if (d.inSeconds < 5) return l10n.freshnessNow;
    if (d.inSeconds < 60) return l10n.freshnessSecondsAgo(d.inSeconds);
    if (d.inMinutes < 60) return l10n.freshnessMinutesAgo(d.inMinutes);
    if (d.inHours < 24) return l10n.freshnessHoursAgo(d.inHours);
    return l10n.freshnessDaysAgo(d.inDays);
  }

  static String _relativeHe(Duration d) {
    if (d.inSeconds < 5) return 'עכשיו';
    if (d.inSeconds < 60) return 'לפני ${d.inSeconds} שניות';
    if (d.inMinutes < 60) {
      final m = d.inMinutes;
      return m == 1 ? 'לפני דקה' : 'לפני $m דקות';
    }
    final h = d.inHours;
    if (h < 24) return h == 1 ? 'לפני שעה' : 'לפני $h שעות';
    final days = d.inDays;
    return days == 1 ? 'לפני יום' : 'לפני $days ימים';
  }
}
