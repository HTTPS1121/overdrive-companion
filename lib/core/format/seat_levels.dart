import 'package:overdrive_companion/l10n/app_localizations.dart';

String seatLevelLabel(AppLocalizations l10n, int level) {
  return switch (level.clamp(0, 2)) {
    0 => l10n.seatLevelOff,
    1 => l10n.seatLevelLow,
    _ => l10n.seatLevelHigh,
  };
}

List<String> seatLevelLabels(AppLocalizations l10n) => [
      l10n.seatLevelOff,
      l10n.seatLevelLow,
      l10n.seatLevelHigh,
    ];
