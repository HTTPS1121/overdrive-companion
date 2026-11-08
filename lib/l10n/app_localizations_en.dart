// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Overdrive Companion';

  @override
  String get navStatus => 'Status';

  @override
  String get navControls => 'Controls';

  @override
  String get navCameras => 'Cameras';

  @override
  String get navLocation => 'Location';

  @override
  String get navSettings => 'Settings';

  @override
  String get connectionTitle => 'Tunnel connection';

  @override
  String get connectionIntro =>
      'Same flow as the car login page: tunnel URL, Device ID from the server, then your access code.';

  @override
  String get tunnelUrlLabel => 'Tunnel URL (HTTPS)';

  @override
  String get deviceIdLabel => 'Device ID';

  @override
  String get deviceIdHint => 'Tap refresh after entering the tunnel URL';

  @override
  String get accessCodeLabel => 'Access code';

  @override
  String get accessCodeHelper =>
      'Access code only — the app sends deviceId-accessCode to /auth/token';

  @override
  String get connectSave => 'Connect and save';

  @override
  String get errorHtmlTunnel =>
      'Server returned HTML instead of JSON. Check the tunnel URL.';

  @override
  String get errorAuthRejected =>
      'Access code rejected. Refresh Device ID and try again.';
}
