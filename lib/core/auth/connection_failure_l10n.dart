import 'package:overdrive_companion/l10n/app_localizations.dart';

import 'connection_errors.dart';

extension ConnectionFailureL10n on ConnectionFailure {
  String localizedMessage(AppLocalizations l10n) => switch (kind) {
        ConnectionFailureKind.incompleteFields => l10n.errorTunnelUrlRequired,
        ConnectionFailureKind.tunnelUnreachable => l10n.errorTunnelUnreachable,
        ConnectionFailureKind.htmlResponse => l10n.errorHtmlTunnel,
        ConnectionFailureKind.deviceIdMissing => l10n.errorDeviceIdMissing,
        ConnectionFailureKind.authRejected => l10n.errorAuthRejected,
        ConnectionFailureKind.sessionExpired => l10n.errorSessionExpired,
        ConnectionFailureKind.notJson => detail ?? l10n.errorTunnelUnreachable,
        ConnectionFailureKind.rateLimited => l10n.rateLimitError,
        ConnectionFailureKind.unknown => detail ?? l10n.errorTunnelUnreachable,
      };
}
