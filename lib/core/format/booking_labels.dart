import '../../data/models/remote_feature_models.dart';

/// Local display for BOOKINGAIR list rows (epoch seconds → local wall clock).
String formatClimateBookingWhen(ClimateBooking b) {
  final t = b.bookingTime;
  if (t == null) return 'שעה לא ידועה';
  final dt = DateTime.fromMillisecondsSinceEpoch(t * 1000, isUtc: true).toLocal();
  final d = dt.day.toString().padLeft(2, '0');
  final m = dt.month.toString().padLeft(2, '0');
  final h = dt.hour.toString().padLeft(2, '0');
  final min = dt.minute.toString().padLeft(2, '0');
  return '$d.$m $h:$min';
}

String climateEditorTitle({required bool isNew, ClimateBooking? selected}) {
  if (isNew) return 'תזמון חדש';
  if (selected != null) {
    return 'עריכת תזמון · ${formatClimateBookingWhen(selected)}';
  }
  return 'עריכת תזמון נבחר';
}
