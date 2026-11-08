import 'package:overdrive_companion/l10n/app_localizations.dart';

import '../../data/models/remote_feature_models.dart';

/// Local display for BOOKINGAIR list rows (epoch seconds → local wall clock).
String formatClimateBookingWhen(ClimateBooking b, {AppLocalizations? l10n}) {
  final t = b.bookingTime;
  if (t == null) return l10n?.scheduleUnknownTime ?? 'Unknown time';
  final dt = DateTime.fromMillisecondsSinceEpoch(t * 1000, isUtc: true).toLocal();
  final d = dt.day.toString().padLeft(2, '0');
  final m = dt.month.toString().padLeft(2, '0');
  final h = dt.hour.toString().padLeft(2, '0');
  final min = dt.minute.toString().padLeft(2, '0');
  return '$d.$m $h:$min';
}

String climateEditorTitle(
  AppLocalizations l10n, {
  required bool isNew,
  ClimateBooking? selected,
}) {
  if (isNew) return l10n.scheduleNewTitle;
  if (selected != null) {
    return '${l10n.scheduleEditTitle} · ${formatClimateBookingWhen(selected, l10n: l10n)}';
  }
  return l10n.scheduleEditTitle;
}

String celsiusLabel(AppLocalizations l10n, num temp) =>
    l10n.celsiusDegrees('${temp.round()}');
