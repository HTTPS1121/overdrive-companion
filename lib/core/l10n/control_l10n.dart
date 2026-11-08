import 'package:overdrive_companion/l10n/app_localizations.dart';

import '../../data/repositories/overdrive_endpoints.dart';

extension ControlKindL10n on ControlKind {
  String label(AppLocalizations l10n) => switch (this) {
        ControlKind.lock => l10n.controlLock,
        ControlKind.unlock => l10n.controlUnlock,
        ControlKind.trunkOpen => l10n.controlTrunkOpen,
        ControlKind.trunkClose => l10n.controlTrunkClose,
        ControlKind.windowsOpen => l10n.controlWindowsOpen,
        ControlKind.windowsClose => l10n.controlWindowsClose,
        ControlKind.windowsVent => l10n.controlWindowsVent,
        ControlKind.flash => l10n.controlFlash,
        ControlKind.findCar => l10n.controlFindCar,
        ControlKind.climateOn => l10n.controlClimateOn,
        ControlKind.climateOff => l10n.controlClimateOff,
        ControlKind.tempUp => l10n.controlTempUp,
        ControlKind.tempDown => l10n.controlTempDown,
        ControlKind.fanUp => l10n.controlFanUp,
        ControlKind.fanDown => l10n.controlFanDown,
        ControlKind.readingLight => l10n.controlReadingLight,
        ControlKind.steeringHeat => l10n.controlSteeringHeat,
      };
}

extension ControlCapabilityL10n on ControlCapability {
  String localizedLabel(AppLocalizations l10n) => kind.label(l10n);
}
