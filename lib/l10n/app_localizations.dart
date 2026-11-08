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
  /// **'Enter your tunnel address, load the Device ID from the car server, then enter the access code shown in the car browser login.'**
  String get connectionIntro;

  /// No description provided for @connectionIntroLong.
  ///
  /// In en, this message translates to:
  /// **'Open the tunnel URL in a browser on the car side to see the Device ID, then use that code here.'**
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
  /// **'Tap refresh after the tunnel URL is correct — loads the ID from your car server'**
  String get deviceIdHelper;

  /// No description provided for @errorTunnelFirst.
  ///
  /// In en, this message translates to:
  /// **'Enter the tunnel URL before loading Device ID.'**
  String get errorTunnelFirst;

  /// No description provided for @errorTunnelUnreachable.
  ///
  /// In en, this message translates to:
  /// **'Cannot reach the tunnel. Check HTTPS, network, and that the car server is online.'**
  String get errorTunnelUnreachable;

  /// No description provided for @errorDeviceIdFromServer.
  ///
  /// In en, this message translates to:
  /// **'No Device ID from the server. Check the tunnel and car connection.'**
  String get errorDeviceIdFromServer;

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
  /// **'Live view from your dash cameras when the stream is enabled.'**
  String get cameraLiveHelp;

  /// No description provided for @streamBadgeLive.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get streamBadgeLive;

  /// No description provided for @streamBadgeOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get streamBadgeOffline;

  /// No description provided for @streamBadgeEnabled.
  ///
  /// In en, this message translates to:
  /// **'Stream on'**
  String get streamBadgeEnabled;

  /// No description provided for @streamBadgeDisabled.
  ///
  /// In en, this message translates to:
  /// **'Stream off'**
  String get streamBadgeDisabled;

  /// No description provided for @streamQualityCurrent.
  ///
  /// In en, this message translates to:
  /// **'Quality · {level}'**
  String streamQualityCurrent(String level);

  /// No description provided for @cameraViewPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Camera view'**
  String get cameraViewPickerTitle;

  /// No description provided for @cameraQualityTitle.
  ///
  /// In en, this message translates to:
  /// **'Video quality'**
  String get cameraQualityTitle;

  /// No description provided for @cameraQualityLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get cameraQualityLow;

  /// No description provided for @cameraQualityMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get cameraQualityMedium;

  /// No description provided for @cameraQualityHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get cameraQualityHigh;

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
  /// **'All cameras'**
  String get cameraViewMosaic;

  /// No description provided for @cameraViewFront.
  ///
  /// In en, this message translates to:
  /// **'Front'**
  String get cameraViewFront;

  /// No description provided for @cameraViewRight.
  ///
  /// In en, this message translates to:
  /// **'Right'**
  String get cameraViewRight;

  /// No description provided for @cameraViewRear.
  ///
  /// In en, this message translates to:
  /// **'Rear'**
  String get cameraViewRear;

  /// No description provided for @cameraViewLeft.
  ///
  /// In en, this message translates to:
  /// **'Left'**
  String get cameraViewLeft;

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
  /// **'Corner {q}'**
  String surveillanceSnapshot(int q);

  /// No description provided for @surveillanceCornerFrontLeft.
  ///
  /// In en, this message translates to:
  /// **'Front left'**
  String get surveillanceCornerFrontLeft;

  /// No description provided for @surveillanceCornerFrontRight.
  ///
  /// In en, this message translates to:
  /// **'Front right'**
  String get surveillanceCornerFrontRight;

  /// No description provided for @surveillanceCornerRearLeft.
  ///
  /// In en, this message translates to:
  /// **'Rear left'**
  String get surveillanceCornerRearLeft;

  /// No description provided for @surveillanceCornerRearRight.
  ///
  /// In en, this message translates to:
  /// **'Rear right'**
  String get surveillanceCornerRearRight;

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

  /// No description provided for @statusDriving.
  ///
  /// In en, this message translates to:
  /// **'Driving'**
  String get statusDriving;

  /// No description provided for @statusParked.
  ///
  /// In en, this message translates to:
  /// **'Parked'**
  String get statusParked;

  /// No description provided for @statusRangeUnit.
  ///
  /// In en, this message translates to:
  /// **'km'**
  String get statusRangeUnit;

  /// No description provided for @sectionClimate.
  ///
  /// In en, this message translates to:
  /// **'Climate'**
  String get sectionClimate;

  /// No description provided for @sectionWindows.
  ///
  /// In en, this message translates to:
  /// **'Windows'**
  String get sectionWindows;

  /// No description provided for @sectionTyres.
  ///
  /// In en, this message translates to:
  /// **'Tires'**
  String get sectionTyres;

  /// No description provided for @sectionCloud.
  ///
  /// In en, this message translates to:
  /// **'BYD cloud'**
  String get sectionCloud;

  /// No description provided for @stateOn.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get stateOn;

  /// No description provided for @stateOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get stateOff;

  /// No description provided for @cloudActive.
  ///
  /// In en, this message translates to:
  /// **'Linked and verified'**
  String get cloudActive;

  /// No description provided for @cloudPartial.
  ///
  /// In en, this message translates to:
  /// **'Incomplete'**
  String get cloudPartial;

  /// No description provided for @freshnessNotYet.
  ///
  /// In en, this message translates to:
  /// **'Not updated yet'**
  String get freshnessNotYet;

  /// No description provided for @freshnessUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated {ago}'**
  String freshnessUpdated(String ago);

  /// No description provided for @freshnessNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get freshnessNow;

  /// No description provided for @freshnessSecondsAgo.
  ///
  /// In en, this message translates to:
  /// **'{n} sec ago'**
  String freshnessSecondsAgo(int n);

  /// No description provided for @freshnessMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{n} min ago'**
  String freshnessMinutesAgo(int n);

  /// No description provided for @freshnessHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{n} h ago'**
  String freshnessHoursAgo(int n);

  /// No description provided for @freshnessDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{n} d ago'**
  String freshnessDaysAgo(int n);

  /// No description provided for @controlSectionAccess.
  ///
  /// In en, this message translates to:
  /// **'Vehicle access'**
  String get controlSectionAccess;

  /// No description provided for @controlSectionWindows.
  ///
  /// In en, this message translates to:
  /// **'Windows'**
  String get controlSectionWindows;

  /// No description provided for @controlSectionClimate.
  ///
  /// In en, this message translates to:
  /// **'Climate'**
  String get controlSectionClimate;

  /// No description provided for @controlStaleTitle.
  ///
  /// In en, this message translates to:
  /// **'Stale data'**
  String get controlStaleTitle;

  /// No description provided for @controlStaleBody.
  ///
  /// In en, this message translates to:
  /// **'Refresh status before sending commands ({ago})'**
  String controlStaleBody(String ago);

  /// No description provided for @controlConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm {action}?'**
  String controlConfirmTitle(String action);

  /// No description provided for @controlConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This command is sent to the car over the tunnel. Make sure the vehicle is in a safe place.'**
  String get controlConfirmBody;

  /// No description provided for @controlSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get controlSend;

  /// No description provided for @controlClimateOffAction.
  ///
  /// In en, this message translates to:
  /// **'Turn climate off'**
  String get controlClimateOffAction;

  /// No description provided for @controlClimateOnAction.
  ///
  /// In en, this message translates to:
  /// **'Turn climate on'**
  String get controlClimateOnAction;

  /// No description provided for @controlSteeringHeatOff.
  ///
  /// In en, this message translates to:
  /// **'Steering heat off'**
  String get controlSteeringHeatOff;

  /// No description provided for @controlSteeringHeatOn.
  ///
  /// In en, this message translates to:
  /// **'Steering heat on'**
  String get controlSteeringHeatOn;

  /// No description provided for @controlTempDownShort.
  ///
  /// In en, this message translates to:
  /// **'Cooler'**
  String get controlTempDownShort;

  /// No description provided for @controlTempUpShort.
  ///
  /// In en, this message translates to:
  /// **'Warmer'**
  String get controlTempUpShort;

  /// No description provided for @controlLock.
  ///
  /// In en, this message translates to:
  /// **'Lock'**
  String get controlLock;

  /// No description provided for @controlUnlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get controlUnlock;

  /// No description provided for @controlTrunkOpen.
  ///
  /// In en, this message translates to:
  /// **'Open trunk'**
  String get controlTrunkOpen;

  /// No description provided for @controlTrunkClose.
  ///
  /// In en, this message translates to:
  /// **'Close trunk'**
  String get controlTrunkClose;

  /// No description provided for @controlWindowsOpen.
  ///
  /// In en, this message translates to:
  /// **'Open windows'**
  String get controlWindowsOpen;

  /// No description provided for @controlWindowsClose.
  ///
  /// In en, this message translates to:
  /// **'Close windows'**
  String get controlWindowsClose;

  /// No description provided for @controlWindowsVent.
  ///
  /// In en, this message translates to:
  /// **'Ventilate'**
  String get controlWindowsVent;

  /// No description provided for @controlFlash.
  ///
  /// In en, this message translates to:
  /// **'Flash lights'**
  String get controlFlash;

  /// No description provided for @controlFindCar.
  ///
  /// In en, this message translates to:
  /// **'Find car'**
  String get controlFindCar;

  /// No description provided for @controlClimateOn.
  ///
  /// In en, this message translates to:
  /// **'Climate on'**
  String get controlClimateOn;

  /// No description provided for @controlClimateOff.
  ///
  /// In en, this message translates to:
  /// **'Climate off'**
  String get controlClimateOff;

  /// No description provided for @controlTempUp.
  ///
  /// In en, this message translates to:
  /// **'Warmer'**
  String get controlTempUp;

  /// No description provided for @controlTempDown.
  ///
  /// In en, this message translates to:
  /// **'Cooler'**
  String get controlTempDown;

  /// No description provided for @controlFanUp.
  ///
  /// In en, this message translates to:
  /// **'Fan up'**
  String get controlFanUp;

  /// No description provided for @controlFanDown.
  ///
  /// In en, this message translates to:
  /// **'Fan down'**
  String get controlFanDown;

  /// No description provided for @controlReadingLight.
  ///
  /// In en, this message translates to:
  /// **'Reading light'**
  String get controlReadingLight;

  /// No description provided for @controlSteeringHeat.
  ///
  /// In en, this message translates to:
  /// **'Steering heat'**
  String get controlSteeringHeat;

  /// No description provided for @controlsErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get controlsErrorTitle;

  /// No description provided for @controlsNoConnection.
  ///
  /// In en, this message translates to:
  /// **'No server connection — controls unavailable'**
  String get controlsNoConnection;
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
