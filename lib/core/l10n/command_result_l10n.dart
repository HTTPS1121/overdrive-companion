import 'package:overdrive_companion/l10n/app_localizations.dart';

import '../../data/repositories/vehicle_repository.dart';

extension CommandResultL10n on CommandResult {
  String userMessage(AppLocalizations l10n, {required String actionLabel}) {
    if (userConfirmed == true) {
      if (actionLabel == l10n.controlLock) return l10n.commandLockConfirmed;
      if (actionLabel == l10n.controlUnlock) return l10n.commandUnlockConfirmed;
    }
    if (!success) {
      return error ?? message ?? l10n.commandFailed(actionLabel);
    }
    if (userConfirmed == false) {
      return message ?? l10n.commandSentUnconfirmed(actionLabel);
    }
    return message ?? l10n.commandSuccess(actionLabel);
  }
}
