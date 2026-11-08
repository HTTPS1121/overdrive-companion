import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_he.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('he'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Overdrive Companion'**
  String get appTitle;

  /// No description provided for @navStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get navStatus;

  /// No description provided for @navControls.
  ///
  /// In en, this message translates to:
  /// **'Controls'**
  String get navControls;

  /// No description provided for @navCameras.
  ///
  /// In en, this message translates to:
  /// **'Cameras'**
  String get navCameras;

  /// No description provided for @navLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get navLocation;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @connectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Tunnel connection'**
  String get connectionTitle;

  /// No description provided for @connectionIntro.
  ///
  /// In en, this message translates to:
  /// **'Same flow as the car login page: tunnel URL, Device ID from the server, then your access code.'**
  String get connectionIntro;

  /// No description provided for @connectionIntroLong.
  ///
  /// In en, this message translates to:
  /// **'In the browser: open the tunnel URL → login.html shows Device ID → enter your access code.'**
  String get connectionIntroLong;

  /// No description provided for @connectionScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Remote connection'**
  String get connectionScreenTitle;

  /// No description provided for @tunnelUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Tunnel URL (HTTPS)'**
  String get tunnelUrlLabel;

  /// No description provided for @tunnelUrlHint.
  ///
  /// In en, this message translates to:
  /// **'https://your-tunnel.example.com'**
  String get tunnelUrlHint;

  /// No description provided for @tunnelUrlHelper.
  ///
  /// In en, this message translates to:
  /// **'Must reach the Overdrive server on the car — not LAN-only unless you know what you\'re doing.'**
  String get tunnelUrlHelper;

  /// No description provided for @deviceIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Device ID'**
  String get deviceIdLabel;

  /// No description provided for @deviceIdLabelLong.
  ///
  /// In en, this message translates to:
  /// **'Device ID'**
  String get deviceIdLabelLong;

  /// No description provided for @deviceIdHint.
  ///
  /// In en, this message translates to:
  /// **'Tap refresh after entering the tunnel URL'**
  String get deviceIdHint;

  /// No description provided for @deviceIdHelper.
  ///
  /// In en, this message translates to:
  /// **'Loaded from GET /auth/status (same as car login.html)'**
  String get deviceIdHelper;

  /// No description provided for @deviceIdPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Refresh after entering the tunnel URL'**
  String get deviceIdPlaceholder;

  /// No description provided for @accessCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Access code'**
  String get accessCodeLabel;

  /// No description provided for @accessCodeHelper.
  ///
  /// In en, this message translates to:
  /// **'Code only — server receives deviceId-accessCode'**
  String get accessCodeHelper;

  /// No description provided for @connectSave.
  ///
  /// In en, this message translates to:
  /// **'Connect and save'**
  String get connectSave;

  /// No description provided for @refreshDeviceId.
  ///
  /// In en, this message translates to:
  /// **'Load Device ID from tunnel'**
  String get refreshDeviceId;

  /// No description provided for @localHttpWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Local HTTP only'**
  String get localHttpWarningTitle;

  /// No description provided for @localHttpWarningBody.
  ///
  /// In en, this message translates to:
  /// **'Remote tunnels require HTTPS.'**
  String get localHttpWarningBody;

  /// No description provided for @errorHtmlTunnel.
  ///
  /// In en, this message translates to:
  /// **'Server returned HTML instead of JSON. Check the tunnel URL.'**
  String get errorHtmlTunnel;

  /// No description provided for @errorAuthRejected.
  ///
  /// In en, this message translates to:
  /// **'Access code rejected. Refresh Device ID and try again.'**
  String get errorAuthRejected;

  /// No description provided for @errorSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Session expired — sign in again.'**
  String get errorSessionExpired;

  /// No description provided for @errorDeviceIdMissing.
  ///
  /// In en, this message translates to:
  /// **'Load Device ID from the tunnel before connecting.'**
  String get errorDeviceIdMissing;

  /// No description provided for @errorAccessCodeShort.
  ///
  /// In en, this message translates to:
  /// **'Access code must be at least 8 characters.'**
  String get errorAccessCodeShort;

  /// No description provided for @errorTunnelUrlRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a tunnel URL.'**
  String get errorTunnelUrlRequired;

  /// No description provided for @errorUnexpectedAuth.
  ///
  /// In en, this message translates to:
  /// **'Server did not respond as expected after sign-in.'**
  String get errorUnexpectedAuth;

  /// No description provided for @cameraLiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Live stream'**
  String get cameraLiveTitle;

  /// No description provided for @cameraLiveHelp.
  ///
  /// In en, this message translates to:
  /// **'Annex-B H.264 on wss://host/ws?token=JWT — native MediaCodec on Android.'**
  String get cameraLiveHelp;

  /// No description provided for @cameraEnableStream.
  ///
  /// In en, this message translates to:
  /// **'Enable stream'**
  String get cameraEnableStream;

  /// No description provided for @cameraDisableStream.
  ///
  /// In en, this message translates to:
  /// **'Disable stream'**
  String get cameraDisableStream;

  /// No description provided for @cameraSurveillanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Surveillance'**
  String get cameraSurveillanceTitle;

  /// No description provided for @cameraRecordingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Recordings'**
  String get cameraRecordingsTitle;

  /// No description provided for @cameraViewMosaic.
  ///
  /// In en, this message translates to:
  /// **'Mosaic (0)'**
  String get cameraViewMosaic;

  /// No description provided for @cameraViewFront.
  ///
  /// In en, this message translates to:
  /// **'Front (1)'**
  String get cameraViewFront;

  /// No description provided for @cameraViewRight.
  ///
  /// In en, this message translates to:
  /// **'Right (2)'**
  String get cameraViewRight;

  /// No description provided for @cameraViewRear.
  ///
  /// In en, this message translates to:
  /// **'Rear (3)'**
  String get cameraViewRear;

  /// No description provided for @cameraViewLeft.
  ///
  /// In en, this message translates to:
  /// **'Left (4)'**
  String get cameraViewLeft;

  /// No description provided for @cameraViewQualityMedium.
  ///
  /// In en, this message translates to:
  /// **'Quality: MEDIUM'**
  String get cameraViewQualityMedium;

  /// No description provided for @streamConnectedLabel.
  ///
  /// In en, this message translates to:
  /// **'Stream: {connected}'**
  String streamConnectedLabel(String connected);

  /// No description provided for @streamViewModeLabel.
  ///
  /// In en, this message translates to:
  /// **'View mode: {mode}'**
  String streamViewModeLabel(int mode);

  /// No description provided for @streamPhaseIdle.
  ///
  /// In en, this message translates to:
  /// **'Idle'**
  String get streamPhaseIdle;

  /// No description provided for @streamPhaseConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting…'**
  String get streamPhaseConnecting;

  /// No description provided for @streamPhaseConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected — waiting for frames'**
  String get streamPhaseConnected;

  /// No description provided for @streamPhaseLive.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get streamPhaseLive;

  /// No description provided for @streamPhaseReconnecting.
  ///
  /// In en, this message translates to:
  /// **'Reconnecting (attempt {attempt})…'**
  String streamPhaseReconnecting(int attempt);

  /// No description provided for @streamPhaseError.
  ///
  /// In en, this message translates to:
  /// **'Stream error'**
  String get streamPhaseError;

  /// No description provided for @streamPhaseDecoderError.
  ///
  /// In en, this message translates to:
  /// **'Decoder unavailable'**
  String get streamPhaseDecoderError;

  /// No description provided for @recordingDownload.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get recordingDownload;

  /// No description provided for @recordingSavedTo.
  ///
  /// In en, this message translates to:
  /// **'Saved to {path}'**
  String recordingSavedTo(String path);

  /// No description provided for @recordingNone.
  ///
  /// In en, this message translates to:
  /// **'No recordings'**
  String get recordingNone;

  /// No description provided for @recordingLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load recordings'**
  String get recordingLoadFailed;

  /// No description provided for @surveillanceEnabled.
  ///
  /// In en, this message translates to:
  /// **'Surveillance enabled'**
  String get surveillanceEnabled;

  /// No description provided for @surveillanceDisabled.
  ///
  /// In en, this message translates to:
  /// **'Surveillance off'**
  String get surveillanceDisabled;

  /// No description provided for @surveillanceLoadConfig.
  ///
  /// In en, this message translates to:
  /// **'Load config'**
  String get surveillanceLoadConfig;

  /// No description provided for @surveillanceSaveConfig.
  ///
  /// In en, this message translates to:
  /// **'Save sensitivity'**
  String get surveillanceSaveConfig;

  /// No description provided for @surveillanceSnapshot.
  ///
  /// In en, this message translates to:
  /// **'Snapshot Q{q}'**
  String surveillanceSnapshot(int q);

  /// No description provided for @surveillanceEnable.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get surveillanceEnable;

  /// No description provided for @surveillanceDisable.
  ///
  /// In en, this message translates to:
  /// **'Disable'**
  String get surveillanceDisable;

  /// No description provided for @statusHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Overdrive vehicle'**
  String get statusHeroTitle;

  /// No description provided for @statusLocked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get statusLocked;

  /// No description provided for @statusUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Unlocked'**
  String get statusUnlocked;

  /// No description provided for @statusConnectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Connection'**
  String get statusConnectionTitle;

  /// No description provided for @statusConnectedToServer.
  ///
  /// In en, this message translates to:
  /// **'Connected to server'**
  String get statusConnectedToServer;

  /// No description provided for @statusDataStale.
  ///
  /// In en, this message translates to:
  /// **'Data is stale — refresh before commands'**
  String get statusDataStale;

  /// No description provided for @statusRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get statusRetry;

  /// No description provided for @statusNotConnected.
  ///
  /// In en, this message translates to:
  /// **'Not connected'**
  String get statusNotConnected;

  /// No description provided for @statusSetupInSettings.
  ///
  /// In en, this message translates to:
  /// **'Set up connection in Settings'**
  String get statusSetupInSettings;

  /// No description provided for @statusServerUnreachable.
  ///
  /// In en, this message translates to:
  /// **'Cannot reach server'**
  String get statusServerUnreachable;

  /// No description provided for @statusCheckTunnel.
  ///
  /// In en, this message translates to:
  /// **'Check tunnel and network'**
  String get statusCheckTunnel;

  /// No description provided for @statusErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get statusErrorTitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'he'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'he':
      return AppLocalizationsHe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
