/// User-facing strings only — ASCII separators, no special Unicode that lacks glyphs.

const kTextSep = ' | ';

String formatTempC(num value, {int decimals = 0}) {
  final v = decimals == 0 ? value.round().toString() : value.toStringAsFixed(decimals);
  return '$v C';
}

String formatSocPercent(num? soc) {
  if (soc == null) return '--';
  return '${soc.round()}%';
}

String formatRangeKm(int? km) {
  if (km == null) return '--';
  return '$km km';
}

String formatWindowPct(int? v) {
  if (v == null || v < 0) return '--';
  return '$v%';
}

String formatTyreLine({int? kPa, int? tempC}) {
  if (kPa == null) return 'אין אות';
  final t = tempC != null ? ' ${formatTempC(tempC)}' : '';
  return '$kPa kPa$t';
}

/// Never show raw API source tokens like "mock" in the UI.
String lockSourceLabelHe(String? source) {
  switch (source) {
    case 'cloud':
      return 'ענן BYD';
    case 'sdk':
    case 'ota':
      return 'רכב';
    case 'mock':
    case 'local':
      return 'הדגמה';
    default:
      if (source == null || source.isEmpty) return 'לא ידוע';
      return 'הדגמה';
  }
}

String demoModeBannerHe(ConnectionModeLabel mode) {
  return switch (mode) {
    ConnectionModeLabel.embedded => 'מצב הדגמה מובנה - לא נתוני רכב אמיתיים',
    ConnectionModeLabel.localSim => 'סימולציה מקומית - לא נתוני רכב אמיתיים',
    ConnectionModeLabel.live => '',
  };
}

enum ConnectionModeLabel { embedded, localSim, live }
