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
  /// **'Enter the same access code shown on the car login page after the Device ID'**
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

  /// No description provided for @statusHeroImageLabel.
  ///
  /// In en, this message translates to:
  /// **'BYD Atto 3 reference photo'**
  String get statusHeroImageLabel;

  /// No description provided for @statusHeroAttribution.
  ///
  /// In en, this message translates to:
  /// **'Photo: Chanokchon / Wikimedia (CC BY-SA 4.0)'**
  String get statusHeroAttribution;

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

  /// No description provided for @tyreFrontLeft.
  ///
  /// In en, this message translates to:
  /// **'Front left'**
  String get tyreFrontLeft;

  /// No description provided for @tyreFrontRight.
  ///
  /// In en, this message translates to:
  /// **'Front right'**
  String get tyreFrontRight;

  /// No description provided for @tyreRearLeft.
  ///
  /// In en, this message translates to:
  /// **'Rear left'**
  String get tyreRearLeft;

  /// No description provided for @tyreRearRight.
  ///
  /// In en, this message translates to:
  /// **'Rear right'**
  String get tyreRearRight;

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

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionScheduleClimate.
  ///
  /// In en, this message translates to:
  /// **'Climate schedule'**
  String get actionScheduleClimate;

  /// No description provided for @actionScheduleCharging.
  ///
  /// In en, this message translates to:
  /// **'Charging schedule'**
  String get actionScheduleCharging;

  /// No description provided for @actionStartCharging.
  ///
  /// In en, this message translates to:
  /// **'Start charging'**
  String get actionStartCharging;

  /// No description provided for @actionSeat.
  ///
  /// In en, this message translates to:
  /// **'Seat'**
  String get actionSeat;

  /// No description provided for @actionMedia.
  ///
  /// In en, this message translates to:
  /// **'Media'**
  String get actionMedia;

  /// No description provided for @actionAdas.
  ///
  /// In en, this message translates to:
  /// **'ADAS'**
  String get actionAdas;

  /// No description provided for @actionCpd.
  ///
  /// In en, this message translates to:
  /// **'CPD'**
  String get actionCpd;

  /// No description provided for @actionBatteryHeat.
  ///
  /// In en, this message translates to:
  /// **'Battery heat'**
  String get actionBatteryHeat;

  /// No description provided for @actionChargeCap.
  ///
  /// In en, this message translates to:
  /// **'Charge cap'**
  String get actionChargeCap;

  /// No description provided for @settingsSectionConnection.
  ///
  /// In en, this message translates to:
  /// **'Connection'**
  String get settingsSectionConnection;

  /// No description provided for @settingsSectionAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsSectionAppearance;

  /// No description provided for @settingsSectionRemote.
  ///
  /// In en, this message translates to:
  /// **'Remote services'**
  String get settingsSectionRemote;

  /// No description provided for @settingsAppearanceHint.
  ///
  /// In en, this message translates to:
  /// **'Light, dark, or follow system. Dynamic color requires Android 12+.'**
  String get settingsAppearanceHint;

  /// No description provided for @settingsDynamicColorTitle.
  ///
  /// In en, this message translates to:
  /// **'Dynamic colors (Material You)'**
  String get settingsDynamicColorTitle;

  /// No description provided for @settingsDynamicColorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'From your device wallpaper palette'**
  String get settingsDynamicColorSubtitle;

  /// No description provided for @settingsSaveConnect.
  ///
  /// In en, this message translates to:
  /// **'Save and connect'**
  String get settingsSaveConnect;

  /// No description provided for @settingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Settings saved'**
  String get settingsSaved;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsOpenRemoteServices.
  ///
  /// In en, this message translates to:
  /// **'Cabin audio, GenAI, WireGuard'**
  String get settingsOpenRemoteServices;

  /// No description provided for @settingsOpenCapabilityInventory.
  ///
  /// In en, this message translates to:
  /// **'API coverage vs Overdrive server'**
  String get settingsOpenCapabilityInventory;

  /// No description provided for @controlsTabCommands.
  ///
  /// In en, this message translates to:
  /// **'Commands'**
  String get controlsTabCommands;

  /// No description provided for @controlsTabSchedules.
  ///
  /// In en, this message translates to:
  /// **'Schedules'**
  String get controlsTabSchedules;

  /// No description provided for @controlsTabComfort.
  ///
  /// In en, this message translates to:
  /// **'Comfort'**
  String get controlsTabComfort;

  /// No description provided for @controlsTabCharging.
  ///
  /// In en, this message translates to:
  /// **'Charging'**
  String get controlsTabCharging;

  /// No description provided for @scheduleTabClimate.
  ///
  /// In en, this message translates to:
  /// **'Pre-climate'**
  String get scheduleTabClimate;

  /// No description provided for @scheduleTabCharging.
  ///
  /// In en, this message translates to:
  /// **'Smart charge'**
  String get scheduleTabCharging;

  /// No description provided for @gpsNoLocationServer.
  ///
  /// In en, this message translates to:
  /// **'No location — active server connection required'**
  String get gpsNoLocationServer;

  /// No description provided for @gpsServerNoGps.
  ///
  /// In en, this message translates to:
  /// **'Server returned no GPS data'**
  String get gpsServerNoGps;

  /// No description provided for @gpsNoCoordinates.
  ///
  /// In en, this message translates to:
  /// **'No coordinates in server response'**
  String get gpsNoCoordinates;

  /// No description provided for @gpsMapNeedsNetwork.
  ///
  /// In en, this message translates to:
  /// **'Map preview needs network on this device.\nCoordinates and navigation below are still from the server.'**
  String get gpsMapNeedsNetwork;

  /// No description provided for @gpsMapLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load map — coordinates are shown'**
  String get gpsMapLoadFailed;

  /// No description provided for @gpsCoordinates.
  ///
  /// In en, this message translates to:
  /// **'Coordinates'**
  String get gpsCoordinates;

  /// No description provided for @gpsSpeed.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get gpsSpeed;

  /// No description provided for @gpsHeading.
  ///
  /// In en, this message translates to:
  /// **'Heading'**
  String get gpsHeading;

  /// No description provided for @gpsOpenNavigation.
  ///
  /// In en, this message translates to:
  /// **'Open in maps'**
  String get gpsOpenNavigation;

  /// No description provided for @gpsNavigationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Could not open a maps app'**
  String get gpsNavigationUnavailable;

  /// No description provided for @chargeCapTitle.
  ///
  /// In en, this message translates to:
  /// **'Charge limit'**
  String get chargeCapTitle;

  /// No description provided for @chargeCapLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load charge limit from server'**
  String get chargeCapLoadFailed;

  /// No description provided for @chargeCapUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Server reports charge limit not supported on this vehicle'**
  String get chargeCapUnsupported;

  /// No description provided for @chargeCapDescription.
  ///
  /// In en, this message translates to:
  /// **'Cap the maximum state of charge while charging.'**
  String get chargeCapDescription;

  /// No description provided for @chargeCapTarget.
  ///
  /// In en, this message translates to:
  /// **'Charge target'**
  String get chargeCapTarget;

  /// No description provided for @chargeCapEnableTitle.
  ///
  /// In en, this message translates to:
  /// **'Enable limit'**
  String get chargeCapEnableTitle;

  /// No description provided for @chargeCapEnableSubtitle.
  ///
  /// In en, this message translates to:
  /// **'When on, charging stops at the selected target'**
  String get chargeCapEnableSubtitle;

  /// No description provided for @chargeCapSave.
  ///
  /// In en, this message translates to:
  /// **'Save to server'**
  String get chargeCapSave;

  /// No description provided for @acChargeTitle.
  ///
  /// In en, this message translates to:
  /// **'AC charge current'**
  String get acChargeTitle;

  /// No description provided for @acChargeLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not read AC charge current from server'**
  String get acChargeLoadFailed;

  /// No description provided for @acChargeTrimUnsupported.
  ///
  /// In en, this message translates to:
  /// **'This trim does not support AC current limiting.'**
  String get acChargeTrimUnsupported;

  /// No description provided for @acChargeUnavailable.
  ///
  /// In en, this message translates to:
  /// **'AC current data unavailable from vehicle right now.'**
  String get acChargeUnavailable;

  /// No description provided for @acChargeLevelsHint.
  ///
  /// In en, this message translates to:
  /// **'Five levels set on the vehicle; saving updates the server limit.'**
  String get acChargeLevelsHint;

  /// No description provided for @acChargeLevelAmps.
  ///
  /// In en, this message translates to:
  /// **'{amps} A'**
  String acChargeLevelAmps(int amps);

  /// No description provided for @acChargeCurrentLabel.
  ///
  /// In en, this message translates to:
  /// **'Current level: {label}'**
  String acChargeCurrentLabel(String label);

  /// No description provided for @extendedPowerSection.
  ///
  /// In en, this message translates to:
  /// **'Power'**
  String get extendedPowerSection;

  /// No description provided for @extendedPowerDrivingBlocked.
  ///
  /// In en, this message translates to:
  /// **'Vehicle reports driving — power on/off blocked until stopped (server guard).'**
  String get extendedPowerDrivingBlocked;

  /// No description provided for @extendedPowerOn.
  ///
  /// In en, this message translates to:
  /// **'Power on'**
  String get extendedPowerOn;

  /// No description provided for @extendedPowerOff.
  ///
  /// In en, this message translates to:
  /// **'Power off'**
  String get extendedPowerOff;

  /// No description provided for @extendedBatteryHeatSection.
  ///
  /// In en, this message translates to:
  /// **'Battery heat'**
  String get extendedBatteryHeatSection;

  /// No description provided for @extendedBatteryHeatUnknown.
  ///
  /// In en, this message translates to:
  /// **'Server did not report battery heat — toggle unavailable.'**
  String get extendedBatteryHeatUnknown;

  /// No description provided for @extendedBatteryPreheat.
  ///
  /// In en, this message translates to:
  /// **'Battery preconditioning'**
  String get extendedBatteryPreheat;

  /// No description provided for @extendedBatteryHeatOn.
  ///
  /// In en, this message translates to:
  /// **'Active per server'**
  String get extendedBatteryHeatOn;

  /// No description provided for @extendedBatteryHeatOff.
  ///
  /// In en, this message translates to:
  /// **'Off per server'**
  String get extendedBatteryHeatOff;

  /// No description provided for @extendedScreenshotsSection.
  ///
  /// In en, this message translates to:
  /// **'In-vehicle displays'**
  String get extendedScreenshotsSection;

  /// No description provided for @extendedScreenshotsHint.
  ///
  /// In en, this message translates to:
  /// **'PNG capture is stored on the vehicle (HU or cluster). Not auto-downloaded to phone.'**
  String get extendedScreenshotsHint;

  /// No description provided for @extendedScreenshotHu.
  ///
  /// In en, this message translates to:
  /// **'Multimedia screenshot'**
  String get extendedScreenshotHu;

  /// No description provided for @extendedScreenshotCluster.
  ///
  /// In en, this message translates to:
  /// **'Cluster screenshot'**
  String get extendedScreenshotCluster;

  /// No description provided for @extendedConfirmPowerOnTitle.
  ///
  /// In en, this message translates to:
  /// **'Power on vehicle?'**
  String get extendedConfirmPowerOnTitle;

  /// No description provided for @extendedConfirmPowerOffTitle.
  ///
  /// In en, this message translates to:
  /// **'Power off vehicle?'**
  String get extendedConfirmPowerOffTitle;

  /// No description provided for @extendedConfirmPowerOnBody.
  ///
  /// In en, this message translates to:
  /// **'Sent only when parked with no motion (server SDK guard).'**
  String get extendedConfirmPowerOnBody;

  /// No description provided for @extendedConfirmPowerOffBody.
  ///
  /// In en, this message translates to:
  /// **'Vehicle will shut down — ensure occupants are clear.'**
  String get extendedConfirmPowerOffBody;

  /// No description provided for @extendedConfirmScreenshotTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm {label}?'**
  String extendedConfirmScreenshotTitle(String label);

  /// No description provided for @extendedConfirmScreenshotBody.
  ///
  /// In en, this message translates to:
  /// **'Server captures on the vehicle and saves a PNG file.'**
  String get extendedConfirmScreenshotBody;

  /// No description provided for @extendedConfirmCapture.
  ///
  /// In en, this message translates to:
  /// **'Capture'**
  String get extendedConfirmCapture;

  /// No description provided for @scheduleClimateTitle.
  ///
  /// In en, this message translates to:
  /// **'Climate schedules from server'**
  String get scheduleClimateTitle;

  /// No description provided for @scheduleClimateEmpty.
  ///
  /// In en, this message translates to:
  /// **'No active schedules — create one below.'**
  String get scheduleClimateEmpty;

  /// No description provided for @scheduleClimateUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Not supported: {reason}'**
  String scheduleClimateUnsupported(String reason);

  /// No description provided for @scheduleClimateListUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Schedule list unavailable ({reason}).\nAn empty list is not shown as proof of no schedules.'**
  String scheduleClimateListUnavailable(String reason);

  /// No description provided for @scheduleInvalidResponse.
  ///
  /// In en, this message translates to:
  /// **'Invalid server response'**
  String get scheduleInvalidResponse;

  /// No description provided for @scheduleDurationMinutes.
  ///
  /// In en, this message translates to:
  /// **'Duration (minutes)'**
  String get scheduleDurationMinutes;

  /// No description provided for @scheduleCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get scheduleCreate;

  /// No description provided for @scheduleUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get scheduleUpdate;

  /// No description provided for @scheduleCancelEdit.
  ///
  /// In en, this message translates to:
  /// **'Cancel edit'**
  String get scheduleCancelEdit;

  /// No description provided for @scheduleDeleteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get scheduleDeleteTooltip;

  /// No description provided for @scheduleChargingUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Not supported: {reason}'**
  String scheduleChargingUnsupported(Object reason);

  /// No description provided for @scheduleChargingStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get scheduleChargingStatus;

  /// No description provided for @scheduleChargingEnabled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled charging on'**
  String get scheduleChargingEnabled;

  /// No description provided for @scheduleChargingStart.
  ///
  /// In en, this message translates to:
  /// **'Start (HH:mm)'**
  String get scheduleChargingStart;

  /// No description provided for @scheduleChargingEnd.
  ///
  /// In en, this message translates to:
  /// **'End (HH:mm or full)'**
  String get scheduleChargingEnd;

  /// No description provided for @scheduleChargingRepeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get scheduleChargingRepeat;

  /// No description provided for @scheduleRepeatDaily.
  ///
  /// In en, this message translates to:
  /// **'Every day'**
  String get scheduleRepeatDaily;

  /// No description provided for @scheduleRepeatOnce.
  ///
  /// In en, this message translates to:
  /// **'One time'**
  String get scheduleRepeatOnce;

  /// No description provided for @scheduleChargingSaveWindow.
  ///
  /// In en, this message translates to:
  /// **'Save window'**
  String get scheduleChargingSaveWindow;

  /// No description provided for @scheduleChargingStartNow.
  ///
  /// In en, this message translates to:
  /// **'Start charging now'**
  String get scheduleChargingStartNow;

  /// No description provided for @stateActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get stateActive;

  /// No description provided for @stateInactive.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get stateInactive;

  /// No description provided for @comfortTabSeats.
  ///
  /// In en, this message translates to:
  /// **'Seats'**
  String get comfortTabSeats;

  /// No description provided for @comfortTabMediaSafety.
  ///
  /// In en, this message translates to:
  /// **'Media & safety'**
  String get comfortTabMediaSafety;

  /// No description provided for @comfortMediaTitle.
  ///
  /// In en, this message translates to:
  /// **'Media volume & screen brightness'**
  String get comfortMediaTitle;

  /// No description provided for @comfortSafetyTitle.
  ///
  /// In en, this message translates to:
  /// **'Safety'**
  String get comfortSafetyTitle;

  /// No description provided for @comfortEsp.
  ///
  /// In en, this message translates to:
  /// **'Stability (ESP)'**
  String get comfortEsp;

  /// No description provided for @comfortItac.
  ///
  /// In en, this message translates to:
  /// **'Traction (ITAC)'**
  String get comfortItac;

  /// No description provided for @comfortUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get comfortUnavailable;

  /// No description provided for @comfortSlw.
  ///
  /// In en, this message translates to:
  /// **'Speed limit warning (SLW)'**
  String get comfortSlw;

  /// No description provided for @comfortCpd.
  ///
  /// In en, this message translates to:
  /// **'Child presence (CPD)'**
  String get comfortCpd;

  /// No description provided for @seatHint.
  ///
  /// In en, this message translates to:
  /// **'Heat and vent levels as reported by the vehicle'**
  String get seatHint;

  /// No description provided for @seatDriver.
  ///
  /// In en, this message translates to:
  /// **'Driver seat'**
  String get seatDriver;

  /// No description provided for @seatPassenger.
  ///
  /// In en, this message translates to:
  /// **'Passenger seat'**
  String get seatPassenger;

  /// No description provided for @seatHeat.
  ///
  /// In en, this message translates to:
  /// **'Heat'**
  String get seatHeat;

  /// No description provided for @seatVent.
  ///
  /// In en, this message translates to:
  /// **'Vent'**
  String get seatVent;

  /// No description provided for @seatVentUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Vent not supported on this vehicle'**
  String get seatVentUnsupported;

  /// No description provided for @seatRecallMemory.
  ///
  /// In en, this message translates to:
  /// **'Recall memory'**
  String get seatRecallMemory;

  /// No description provided for @seatSaveMemory.
  ///
  /// In en, this message translates to:
  /// **'Save seat'**
  String get seatSaveMemory;

  /// No description provided for @commandFailed.
  ///
  /// In en, this message translates to:
  /// **'{action} failed'**
  String commandFailed(String action);

  /// No description provided for @commandSentUnconfirmed.
  ///
  /// In en, this message translates to:
  /// **'{action} sent but not confirmed on vehicle'**
  String commandSentUnconfirmed(String action);

  /// No description provided for @commandSuccess.
  ///
  /// In en, this message translates to:
  /// **'{action} completed'**
  String commandSuccess(String action);

  /// No description provided for @commandLockConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Vehicle locked'**
  String get commandLockConfirmed;

  /// No description provided for @commandUnlockConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Vehicle unlocked'**
  String get commandUnlockConfirmed;

  /// No description provided for @surveillanceHeatmapTitle.
  ///
  /// In en, this message translates to:
  /// **'Parking heatmap'**
  String get surveillanceHeatmapTitle;

  /// No description provided for @surveillanceHeatmapLoad.
  ///
  /// In en, this message translates to:
  /// **'Load heatmap'**
  String get surveillanceHeatmapLoad;

  /// No description provided for @surveillanceFilterLogTitle.
  ///
  /// In en, this message translates to:
  /// **'Filter log'**
  String get surveillanceFilterLogTitle;

  /// No description provided for @surveillanceFilterLogLoad.
  ///
  /// In en, this message translates to:
  /// **'Load log'**
  String get surveillanceFilterLogLoad;

  /// No description provided for @surveillanceScreenDeterrentTitle.
  ///
  /// In en, this message translates to:
  /// **'Screen deterrent'**
  String get surveillanceScreenDeterrentTitle;

  /// No description provided for @surveillanceScreenDeterrentTest.
  ///
  /// In en, this message translates to:
  /// **'Test on vehicle'**
  String get surveillanceScreenDeterrentTest;

  /// No description provided for @surveillanceScreenDeterrentFetch.
  ///
  /// In en, this message translates to:
  /// **'Preview image'**
  String get surveillanceScreenDeterrentFetch;

  /// No description provided for @remoteCommunicateTitle.
  ///
  /// In en, this message translates to:
  /// **'Cabin communication'**
  String get remoteCommunicateTitle;

  /// No description provided for @remoteGenAiTitle.
  ///
  /// In en, this message translates to:
  /// **'GenAI assistant'**
  String get remoteGenAiTitle;

  /// No description provided for @remoteWireGuardTitle.
  ///
  /// In en, this message translates to:
  /// **'WireGuard tunnel'**
  String get remoteWireGuardTitle;

  /// No description provided for @remoteCommunicateTab.
  ///
  /// In en, this message translates to:
  /// **'Cabin'**
  String get remoteCommunicateTab;

  /// No description provided for @remoteGenAiTab.
  ///
  /// In en, this message translates to:
  /// **'GenAI'**
  String get remoteGenAiTab;

  /// No description provided for @remoteWireGuardTab.
  ///
  /// In en, this message translates to:
  /// **'WireGuard'**
  String get remoteWireGuardTab;

  /// No description provided for @communicateCarStateOn.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get communicateCarStateOn;

  /// No description provided for @communicateCarStateOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get communicateCarStateOff;

  /// No description provided for @communicateCarStateParked.
  ///
  /// In en, this message translates to:
  /// **'Parked'**
  String get communicateCarStateParked;

  /// No description provided for @stateEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get stateEnabled;

  /// No description provided for @stateDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get stateDisabled;

  /// No description provided for @communicateAudioReady.
  ///
  /// In en, this message translates to:
  /// **'Voice ready'**
  String get communicateAudioReady;

  /// No description provided for @communicateMessagesReady.
  ///
  /// In en, this message translates to:
  /// **'Messages ready'**
  String get communicateMessagesReady;

  /// No description provided for @communicateListenerReady.
  ///
  /// In en, this message translates to:
  /// **'Listener ready'**
  String get communicateListenerReady;

  /// No description provided for @communicateSendMessage.
  ///
  /// In en, this message translates to:
  /// **'Send message'**
  String get communicateSendMessage;

  /// No description provided for @communicateMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Text shown on vehicle'**
  String get communicateMessageHint;

  /// No description provided for @communicateTestSpeaker.
  ///
  /// In en, this message translates to:
  /// **'Test speaker'**
  String get communicateTestSpeaker;

  /// No description provided for @communicateEmergencyStop.
  ///
  /// In en, this message translates to:
  /// **'Emergency stop'**
  String get communicateEmergencyStop;

  /// No description provided for @communicateLoadStatus.
  ///
  /// In en, this message translates to:
  /// **'Refresh status'**
  String get communicateLoadStatus;

  /// No description provided for @genAiLoadStatus.
  ///
  /// In en, this message translates to:
  /// **'Refresh status'**
  String get genAiLoadStatus;

  /// No description provided for @genAiSendChat.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get genAiSendChat;

  /// No description provided for @genAiChatHint.
  ///
  /// In en, this message translates to:
  /// **'Ask the vehicle assistant'**
  String get genAiChatHint;

  /// No description provided for @genAiInsightsOpen.
  ///
  /// In en, this message translates to:
  /// **'Insights dashboard'**
  String get genAiInsightsOpen;

  /// No description provided for @wireGuardLoadStatus.
  ///
  /// In en, this message translates to:
  /// **'Refresh status'**
  String get wireGuardLoadStatus;

  /// No description provided for @wireGuardExposeOn.
  ///
  /// In en, this message translates to:
  /// **'Expose dashboard'**
  String get wireGuardExposeOn;

  /// No description provided for @wireGuardExposeOff.
  ///
  /// In en, this message translates to:
  /// **'Hide dashboard'**
  String get wireGuardExposeOff;

  /// No description provided for @inventoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Server capability map'**
  String get inventoryTitle;

  /// No description provided for @inventoryImplemented.
  ///
  /// In en, this message translates to:
  /// **'In app'**
  String get inventoryImplemented;

  /// No description provided for @inventoryPartial.
  ///
  /// In en, this message translates to:
  /// **'Partial'**
  String get inventoryPartial;

  /// No description provided for @inventoryNotInApp.
  ///
  /// In en, this message translates to:
  /// **'HTTP only / not in UI'**
  String get inventoryNotInApp;

  /// No description provided for @errorFreshnessUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown time source'**
  String get errorFreshnessUnknown;

  /// No description provided for @errorFreshnessClockSkew.
  ///
  /// In en, this message translates to:
  /// **'Vehicle clock ahead of device'**
  String get errorFreshnessClockSkew;

  /// No description provided for @errorConnectionNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Server connection not configured'**
  String get errorConnectionNotConfigured;

  /// No description provided for @errorDeviceIdBeforeLogin.
  ///
  /// In en, this message translates to:
  /// **'Load Device ID from tunnel before sign-in'**
  String get errorDeviceIdBeforeLogin;

  /// No description provided for @errorConfigureTunnel.
  ///
  /// In en, this message translates to:
  /// **'Set tunnel URL and device token'**
  String get errorConfigureTunnel;

  /// No description provided for @remoteServicesTitle.
  ///
  /// In en, this message translates to:
  /// **'Remote services'**
  String get remoteServicesTitle;

  /// No description provided for @drivingInMotion.
  ///
  /// In en, this message translates to:
  /// **'Driving'**
  String get drivingInMotion;

  /// No description provided for @drivingParked.
  ///
  /// In en, this message translates to:
  /// **'Parked'**
  String get drivingParked;

  /// No description provided for @heatmapQuadrantSummary.
  ///
  /// In en, this message translates to:
  /// **'{name}: {active} active blocks'**
  String heatmapQuadrantSummary(String name, String active);

  /// No description provided for @filterLogEmpty.
  ///
  /// In en, this message translates to:
  /// **'No filter log entries'**
  String get filterLogEmpty;

  /// No description provided for @genAiReplyTitle.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get genAiReplyTitle;

  /// No description provided for @wireGuardConfigured.
  ///
  /// In en, this message translates to:
  /// **'Configured'**
  String get wireGuardConfigured;

  /// No description provided for @wireGuardRunning.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get wireGuardRunning;

  /// No description provided for @wireGuardNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Not configured'**
  String get wireGuardNotConfigured;

  /// No description provided for @communicateCarState.
  ///
  /// In en, this message translates to:
  /// **'Vehicle state'**
  String get communicateCarState;

  /// No description provided for @seatLevelOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get seatLevelOff;

  /// No description provided for @seatLevelLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get seatLevelLow;

  /// No description provided for @seatLevelHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get seatLevelHigh;

  /// No description provided for @celsiusDegrees.
  ///
  /// In en, this message translates to:
  /// **'{temp} °C'**
  String celsiusDegrees(String temp);

  /// No description provided for @scheduleUnknownTime.
  ///
  /// In en, this message translates to:
  /// **'Unknown time'**
  String get scheduleUnknownTime;

  /// No description provided for @scheduleNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New schedule'**
  String get scheduleNewTitle;

  /// No description provided for @scheduleEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit schedule'**
  String get scheduleEditTitle;

  /// No description provided for @scheduleMinutesShort.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String scheduleMinutesShort(String minutes);

  /// No description provided for @rateLimitError.
  ///
  /// In en, this message translates to:
  /// **'Too many login attempts. Wait a minute and try again.'**
  String get rateLimitError;

  /// No description provided for @authHtmlRejected.
  ///
  /// In en, this message translates to:
  /// **'Server returned HTML instead of JSON — check the tunnel URL.'**
  String get authHtmlRejected;

  /// No description provided for @communicateSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Cabin audio & messages'**
  String get communicateSettingsTitle;

  /// No description provided for @communicateVoiceEnabled.
  ///
  /// In en, this message translates to:
  /// **'Remote voice'**
  String get communicateVoiceEnabled;

  /// No description provided for @communicateMessagesEnabled.
  ///
  /// In en, this message translates to:
  /// **'On-screen messages'**
  String get communicateMessagesEnabled;

  /// No description provided for @communicateListenerEnabled.
  ///
  /// In en, this message translates to:
  /// **'Cabin listener'**
  String get communicateListenerEnabled;

  /// No description provided for @communicateOutputLevel.
  ///
  /// In en, this message translates to:
  /// **'Speaker output level'**
  String get communicateOutputLevel;

  /// No description provided for @communicateSaveSettings.
  ///
  /// In en, this message translates to:
  /// **'Save communication settings'**
  String get communicateSaveSettings;

  /// No description provided for @communicateMessageKind.
  ///
  /// In en, this message translates to:
  /// **'Message style'**
  String get communicateMessageKind;

  /// No description provided for @communicateKindToast.
  ///
  /// In en, this message translates to:
  /// **'Toast'**
  String get communicateKindToast;

  /// No description provided for @communicateKindDialog.
  ///
  /// In en, this message translates to:
  /// **'Dialog'**
  String get communicateKindDialog;

  /// No description provided for @communicateEmergencyStopTitle.
  ///
  /// In en, this message translates to:
  /// **'Emergency stop?'**
  String get communicateEmergencyStopTitle;

  /// No description provided for @communicateEmergencyStopBody.
  ///
  /// In en, this message translates to:
  /// **'Stops active remote voice/listening sessions on the vehicle.'**
  String get communicateEmergencyStopBody;

  /// No description provided for @communicateWsNote.
  ///
  /// In en, this message translates to:
  /// **'Hold-to-talk streams audio to the vehicle. Settings and messages use the usual remote API.'**
  String get communicateWsNote;

  /// No description provided for @genAiInsightsList.
  ///
  /// In en, this message translates to:
  /// **'Load insight history'**
  String get genAiInsightsList;

  /// No description provided for @genAiTest.
  ///
  /// In en, this message translates to:
  /// **'Run GenAI self-test'**
  String get genAiTest;

  /// No description provided for @genAiWsNote.
  ///
  /// In en, this message translates to:
  /// **'Realtime voice uses a live session; chat and insights use standard requests.'**
  String get genAiWsNote;

  /// No description provided for @wireGuardConfigTitle.
  ///
  /// In en, this message translates to:
  /// **'Tunnel configuration'**
  String get wireGuardConfigTitle;

  /// No description provided for @wireGuardConfigHint.
  ///
  /// In en, this message translates to:
  /// **'Paste wg-quick text. Private keys never leave the vehicle server.'**
  String get wireGuardConfigHint;

  /// No description provided for @wireGuardConfigPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'[Interface]\\nPrivateKey = …'**
  String get wireGuardConfigPlaceholder;

  /// No description provided for @wireGuardConfigSave.
  ///
  /// In en, this message translates to:
  /// **'Upload config'**
  String get wireGuardConfigSave;

  /// No description provided for @wireGuardConfigDelete.
  ///
  /// In en, this message translates to:
  /// **'Remove config'**
  String get wireGuardConfigDelete;

  /// No description provided for @wireGuardConfigConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Upload WireGuard config?'**
  String get wireGuardConfigConfirmTitle;

  /// No description provided for @wireGuardConfigConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Replaces the stored tunnel config on the vehicle daemon.'**
  String get wireGuardConfigConfirmBody;

  /// No description provided for @wireGuardConfigDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete WireGuard config?'**
  String get wireGuardConfigDeleteTitle;

  /// No description provided for @wireGuardConfigDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'Removes stored tunnel configuration from the vehicle.'**
  String get wireGuardConfigDeleteBody;

  /// No description provided for @commonSuccess.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get commonSuccess;

  /// No description provided for @commonError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get commonError;

  /// No description provided for @actionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// No description provided for @actionConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get actionConfirm;

  /// No description provided for @settingsOpenIntegrations.
  ///
  /// In en, this message translates to:
  /// **'Automations, parking, trips, audio, GenAI tools, Telegram, platform APIs'**
  String get settingsOpenIntegrations;

  /// No description provided for @integrationsHubTitle.
  ///
  /// In en, this message translates to:
  /// **'Integrations hub'**
  String get integrationsHubTitle;

  /// No description provided for @integrationsHubIntro.
  ///
  /// In en, this message translates to:
  /// **'Remote vehicle features — forms, confirmations, and clear server feedback.'**
  String get integrationsHubIntro;

  /// No description provided for @integrationsRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get integrationsRefresh;

  /// No description provided for @integrationsSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved on server'**
  String get integrationsSaved;

  /// No description provided for @integrationsNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a name'**
  String get integrationsNameRequired;

  /// No description provided for @integrationsCreateAutomation.
  ///
  /// In en, this message translates to:
  /// **'Create automation'**
  String get integrationsCreateAutomation;

  /// No description provided for @integrationsAutomationNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Automation name'**
  String get integrationsAutomationNameLabel;

  /// No description provided for @integrationsRunTest.
  ///
  /// In en, this message translates to:
  /// **'Run test'**
  String get integrationsRunTest;

  /// No description provided for @integrationsDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get integrationsDelete;

  /// No description provided for @integrationsTestQueued.
  ///
  /// In en, this message translates to:
  /// **'Test sent to the vehicle'**
  String get integrationsTestQueued;

  /// No description provided for @integrationsAutomationModeAutomatic.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get integrationsAutomationModeAutomatic;

  /// No description provided for @integrationsAutomationModeManual.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get integrationsAutomationModeManual;

  /// No description provided for @integrationsDeleteAutomationTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete automation?'**
  String get integrationsDeleteAutomationTitle;

  /// No description provided for @integrationsDeleteAutomationBody.
  ///
  /// In en, this message translates to:
  /// **'Remove “{name}” from the vehicle automation store.'**
  String integrationsDeleteAutomationBody(String name);

  /// No description provided for @integrationsAutomationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Automations'**
  String get integrationsAutomationsTitle;

  /// No description provided for @integrationsAutomationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'List, create, test, and delete rules'**
  String get integrationsAutomationsSubtitle;

  /// No description provided for @integrationsParkingTitle.
  ///
  /// In en, this message translates to:
  /// **'Parking'**
  String get integrationsParkingTitle;

  /// No description provided for @integrationsParkingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sessions and parking assistant config'**
  String get integrationsParkingSubtitle;

  /// No description provided for @integrationsParkingEnabled.
  ///
  /// In en, this message translates to:
  /// **'Parking assistant enabled'**
  String get integrationsParkingEnabled;

  /// No description provided for @integrationsDeleteSessionTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete session?'**
  String get integrationsDeleteSessionTitle;

  /// No description provided for @integrationsDeleteSessionBody.
  ///
  /// In en, this message translates to:
  /// **'Removes the parking session record on the server.'**
  String get integrationsDeleteSessionBody;

  /// No description provided for @integrationsTripsTitle.
  ///
  /// In en, this message translates to:
  /// **'Trips'**
  String get integrationsTripsTitle;

  /// No description provided for @integrationsTripsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Trip history and summary'**
  String get integrationsTripsSubtitle;

  /// No description provided for @integrationsTripSummary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get integrationsTripSummary;

  /// No description provided for @integrationsTripTotalKm.
  ///
  /// In en, this message translates to:
  /// **'{km} km total'**
  String integrationsTripTotalKm(String km);

  /// No description provided for @integrationsDeleteTripTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete trip?'**
  String get integrationsDeleteTripTitle;

  /// No description provided for @integrationsDeleteTripBody.
  ///
  /// In en, this message translates to:
  /// **'Removes the trip record from history.'**
  String get integrationsDeleteTripBody;

  /// No description provided for @integrationsAudioTitle.
  ///
  /// In en, this message translates to:
  /// **'Audio library'**
  String get integrationsAudioTitle;

  /// No description provided for @integrationsAudioSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Play clips stored on the vehicle'**
  String get integrationsAudioSubtitle;

  /// No description provided for @integrationsAudioStopAll.
  ///
  /// In en, this message translates to:
  /// **'Stop playback'**
  String get integrationsAudioStopAll;

  /// No description provided for @integrationsAudioStopped.
  ///
  /// In en, this message translates to:
  /// **'Playback stop sent'**
  String get integrationsAudioStopped;

  /// No description provided for @integrationsAudioPlayQueued.
  ///
  /// In en, this message translates to:
  /// **'Play queued: {name}'**
  String integrationsAudioPlayQueued(String name);

  /// No description provided for @integrationsGenAiToolsTitle.
  ///
  /// In en, this message translates to:
  /// **'GenAI tools'**
  String get integrationsGenAiToolsTitle;

  /// No description provided for @integrationsGenAiToolsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Routines, incidents, action execute'**
  String get integrationsGenAiToolsSubtitle;

  /// No description provided for @integrationsGenAiRoutines.
  ///
  /// In en, this message translates to:
  /// **'Routine learning'**
  String get integrationsGenAiRoutines;

  /// No description provided for @integrationsGenAiActionExecute.
  ///
  /// In en, this message translates to:
  /// **'Vehicle action'**
  String get integrationsGenAiActionExecute;

  /// No description provided for @integrationsGenAiActionExecuteHint.
  ///
  /// In en, this message translates to:
  /// **'Runs a validated vehicle action from the server'**
  String get integrationsGenAiActionExecuteHint;

  /// No description provided for @integrationsExecute.
  ///
  /// In en, this message translates to:
  /// **'Execute'**
  String get integrationsExecute;

  /// No description provided for @integrationsActionQueued.
  ///
  /// In en, this message translates to:
  /// **'Action submitted'**
  String get integrationsActionQueued;

  /// No description provided for @integrationsTelegramTitle.
  ///
  /// In en, this message translates to:
  /// **'Telegram'**
  String get integrationsTelegramTitle;

  /// No description provided for @integrationsTelegramSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pairing status and preferences'**
  String get integrationsTelegramSubtitle;

  /// No description provided for @integrationsTelegramBot.
  ///
  /// In en, this message translates to:
  /// **'Bot'**
  String get integrationsTelegramBot;

  /// No description provided for @integrationsNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Not configured'**
  String get integrationsNotConfigured;

  /// No description provided for @integrationsTelegramVideoUploads.
  ///
  /// In en, this message translates to:
  /// **'Upload dashcam video'**
  String get integrationsTelegramVideoUploads;

  /// No description provided for @integrationsTelegramClearPairing.
  ///
  /// In en, this message translates to:
  /// **'Clear pairing'**
  String get integrationsTelegramClearPairing;

  /// No description provided for @integrationsTelegramClearHint.
  ///
  /// In en, this message translates to:
  /// **'Clears owner pairing on the vehicle daemon'**
  String get integrationsTelegramClearHint;

  /// No description provided for @integrationsTelegramClearTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear Telegram pairing?'**
  String get integrationsTelegramClearTitle;

  /// No description provided for @integrationsTelegramClearBody.
  ///
  /// In en, this message translates to:
  /// **'You will need to pair again on the vehicle.'**
  String get integrationsTelegramClearBody;

  /// No description provided for @integrationsPlatformTitle.
  ///
  /// In en, this message translates to:
  /// **'Platform connectors'**
  String get integrationsPlatformTitle;

  /// No description provided for @integrationsPlatformSubtitle.
  ///
  /// In en, this message translates to:
  /// **'ABRP, MQTT, launcher, RoadSense, BYD cloud, community'**
  String get integrationsPlatformSubtitle;

  /// No description provided for @integrationsLauncherTitle.
  ///
  /// In en, this message translates to:
  /// **'Launcher summary'**
  String get integrationsLauncherTitle;

  /// No description provided for @integrationsBydCloudTitle.
  ///
  /// In en, this message translates to:
  /// **'BYD cloud'**
  String get integrationsBydCloudTitle;

  /// No description provided for @integrationsCommunityTitle.
  ///
  /// In en, this message translates to:
  /// **'Community automations'**
  String get integrationsCommunityTitle;

  /// No description provided for @integrationsHeadUnitNote.
  ///
  /// In en, this message translates to:
  /// **'Android Auto / head-unit projection is not implemented in the companion; local launcher APIs remain on the vehicle.'**
  String get integrationsHeadUnitNote;

  /// No description provided for @voicePttTitle.
  ///
  /// In en, this message translates to:
  /// **'Push-to-talk'**
  String get voicePttTitle;

  /// No description provided for @voicePttHint.
  ///
  /// In en, this message translates to:
  /// **'Hold the button while speaking; audio is sent to the vehicle.'**
  String get voicePttHint;

  /// No description provided for @voicePttHold.
  ///
  /// In en, this message translates to:
  /// **'Hold to talk'**
  String get voicePttHold;

  /// No description provided for @voicePttConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting…'**
  String get voicePttConnecting;

  /// No description provided for @voicePttLive.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get voicePttLive;

  /// No description provided for @voicePttStopping.
  ///
  /// In en, this message translates to:
  /// **'Stopping…'**
  String get voicePttStopping;

  /// No description provided for @voicePttFailed.
  ///
  /// In en, this message translates to:
  /// **'Talk failed'**
  String get voicePttFailed;

  /// No description provided for @voiceCabinListenTitle.
  ///
  /// In en, this message translates to:
  /// **'Cabin microphone'**
  String get voiceCabinListenTitle;

  /// No description provided for @voiceCabinIdle.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get voiceCabinIdle;

  /// No description provided for @voiceCabinConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting…'**
  String get voiceCabinConnecting;

  /// No description provided for @voiceCabinLive.
  ///
  /// In en, this message translates to:
  /// **'Listening'**
  String get voiceCabinLive;

  /// No description provided for @voiceCabinPaused.
  ///
  /// In en, this message translates to:
  /// **'Paused during talk'**
  String get voiceCabinPaused;

  /// No description provided for @voiceCabinError.
  ///
  /// In en, this message translates to:
  /// **'Listener error'**
  String get voiceCabinError;

  /// No description provided for @voiceCabinBytes.
  ///
  /// In en, this message translates to:
  /// **'{bytes} bytes received'**
  String voiceCabinBytes(String bytes);

  /// No description provided for @voiceMicDenied.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission denied'**
  String get voiceMicDenied;

  /// No description provided for @voiceMicOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings to allow microphone'**
  String get voiceMicOpenSettings;

  /// No description provided for @genAiVoiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Realtime voice'**
  String get genAiVoiceTitle;

  /// No description provided for @genAiVoiceHint.
  ///
  /// In en, this message translates to:
  /// **'Starts a live two-way voice session with the assistant.'**
  String get genAiVoiceHint;

  /// No description provided for @genAiVoiceStart.
  ///
  /// In en, this message translates to:
  /// **'Start voice session'**
  String get genAiVoiceStart;

  /// No description provided for @genAiVoiceStop.
  ///
  /// In en, this message translates to:
  /// **'Stop voice session'**
  String get genAiVoiceStop;

  /// No description provided for @genAiVoiceTruncate.
  ///
  /// In en, this message translates to:
  /// **'Truncate playback'**
  String get genAiVoiceTruncate;

  /// No description provided for @platformAbrpTitle.
  ///
  /// In en, this message translates to:
  /// **'ABRP'**
  String get platformAbrpTitle;

  /// No description provided for @platformMqttTitle.
  ///
  /// In en, this message translates to:
  /// **'MQTT'**
  String get platformMqttTitle;

  /// No description provided for @platformMqttAdd.
  ///
  /// In en, this message translates to:
  /// **'Add connection'**
  String get platformMqttAdd;

  /// No description provided for @platformCommunityImport.
  ///
  /// In en, this message translates to:
  /// **'Import automation'**
  String get platformCommunityImport;

  /// No description provided for @platformSave.
  ///
  /// In en, this message translates to:
  /// **'Save to vehicle'**
  String get platformSave;

  /// No description provided for @platformDeleteToken.
  ///
  /// In en, this message translates to:
  /// **'Delete ABRP token'**
  String get platformDeleteToken;

  /// No description provided for @platformDestructiveWarning.
  ///
  /// In en, this message translates to:
  /// **'This changes vehicle-side configuration. Confirm before sending.'**
  String get platformDestructiveWarning;

  /// No description provided for @screenshotFixtureDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Fixture capture — not live vehicle verification'**
  String get screenshotFixtureDisclaimer;

  /// No description provided for @settingsOpenDiagnostics.
  ///
  /// In en, this message translates to:
  /// **'Seat debug, logs, car property, ADAS, lights, RoadSense tools'**
  String get settingsOpenDiagnostics;

  /// No description provided for @integrationsDiagnosticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Diagnostics & RoadSense'**
  String get integrationsDiagnosticsTitle;

  /// No description provided for @integrationsDiagnosticsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Debug reads, log upload, and RoadSense maintenance POSTs'**
  String get integrationsDiagnosticsSubtitle;

  /// No description provided for @integrationsAdvancedDiagnosticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Advanced diagnostics'**
  String get integrationsAdvancedDiagnosticsTitle;

  /// No description provided for @integrationsAdvancedDiagnosticsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle engineers only — destructive actions and debug reads'**
  String get integrationsAdvancedDiagnosticsSubtitle;

  /// No description provided for @diagnosticsAdvancedTitle.
  ///
  /// In en, this message translates to:
  /// **'Advanced diagnostics'**
  String get diagnosticsAdvancedTitle;

  /// No description provided for @diagnosticsAdvancedWarning.
  ///
  /// In en, this message translates to:
  /// **'These tools change vehicle-side state or upload logs. Use only when you understand the impact.'**
  String get diagnosticsAdvancedWarning;

  /// No description provided for @integrationsLoadingData.
  ///
  /// In en, this message translates to:
  /// **'Loading from vehicle…'**
  String get integrationsLoadingData;

  /// No description provided for @integrationsEmptyList.
  ///
  /// In en, this message translates to:
  /// **'Nothing to show yet'**
  String get integrationsEmptyList;

  /// No description provided for @integrationsEmptyParkingSessions.
  ///
  /// In en, this message translates to:
  /// **'No parking sessions recorded'**
  String get integrationsEmptyParkingSessions;

  /// No description provided for @integrationsEmptyTrips.
  ///
  /// In en, this message translates to:
  /// **'No trips in history'**
  String get integrationsEmptyTrips;

  /// No description provided for @integrationsRoadSenseTitle.
  ///
  /// In en, this message translates to:
  /// **'RoadSense'**
  String get integrationsRoadSenseTitle;

  /// No description provided for @diagnosticsHubTitle.
  ///
  /// In en, this message translates to:
  /// **'Diagnostics'**
  String get diagnosticsHubTitle;

  /// No description provided for @diagnosticsSeatTitle.
  ///
  /// In en, this message translates to:
  /// **'Seat debug'**
  String get diagnosticsSeatTitle;

  /// No description provided for @diagnosticsLogsTitle.
  ///
  /// In en, this message translates to:
  /// **'Daemon logs'**
  String get diagnosticsLogsTitle;

  /// No description provided for @diagnosticsLogsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Log upload not available on server'**
  String get diagnosticsLogsUnavailable;

  /// No description provided for @diagnosticsLogsUploadTitle.
  ///
  /// In en, this message translates to:
  /// **'Upload daemon log?'**
  String get diagnosticsLogsUploadTitle;

  /// No description provided for @diagnosticsLogsUpload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get diagnosticsLogsUpload;

  /// No description provided for @diagnosticsCarPropertyTitle.
  ///
  /// In en, this message translates to:
  /// **'Car property debug'**
  String get diagnosticsCarPropertyTitle;

  /// No description provided for @diagnosticsPropertyKeyLabel.
  ///
  /// In en, this message translates to:
  /// **'Property key (hex)'**
  String get diagnosticsPropertyKeyLabel;

  /// No description provided for @diagnosticsAdasTitle.
  ///
  /// In en, this message translates to:
  /// **'ADAS debug'**
  String get diagnosticsAdasTitle;

  /// No description provided for @diagnosticsLightTitle.
  ///
  /// In en, this message translates to:
  /// **'Interior light debug'**
  String get diagnosticsLightTitle;

  /// No description provided for @diagnosticsLightReadOnly.
  ///
  /// In en, this message translates to:
  /// **'Read-only resolve registers (writes need vehicle confirm upstream).'**
  String get diagnosticsLightReadOnly;

  /// No description provided for @diagnosticsRemoteKeyTitle.
  ///
  /// In en, this message translates to:
  /// **'Remote key debug'**
  String get diagnosticsRemoteKeyTitle;

  /// No description provided for @diagnosticsAutoServiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Auto service debug'**
  String get diagnosticsAutoServiceTitle;

  /// No description provided for @roadSenseMapOnline.
  ///
  /// In en, this message translates to:
  /// **'OpenStreetMap basemap (network)'**
  String get roadSenseMapOnline;

  /// No description provided for @roadSenseMapOfflineGrid.
  ///
  /// In en, this message translates to:
  /// **'Basemap unavailable — hazard positions on lat/lon grid'**
  String get roadSenseMapOfflineGrid;

  /// No description provided for @roadSenseMapCoordSummary.
  ///
  /// In en, this message translates to:
  /// **'{lat}°N, {lon}°E'**
  String roadSenseMapCoordSummary(String lat, String lon);

  /// No description provided for @roadSenseHazardCount.
  ///
  /// In en, this message translates to:
  /// **'Active hazards'**
  String get roadSenseHazardCount;

  /// No description provided for @roadSenseSeverity.
  ///
  /// In en, this message translates to:
  /// **'Chime severity'**
  String get roadSenseSeverity;

  /// No description provided for @roadSenseChannel.
  ///
  /// In en, this message translates to:
  /// **'Audio channel'**
  String get roadSenseChannel;

  /// No description provided for @roadSenseVolumePercent.
  ///
  /// In en, this message translates to:
  /// **'Volume %'**
  String get roadSenseVolumePercent;

  /// No description provided for @roadSenseTestChime.
  ///
  /// In en, this message translates to:
  /// **'Test chime'**
  String get roadSenseTestChime;

  /// No description provided for @roadSenseDeleteLocalTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete local RoadSense data?'**
  String get roadSenseDeleteLocalTitle;

  /// No description provided for @roadSenseDeleteLocalBody.
  ///
  /// In en, this message translates to:
  /// **'Removes cached hazard tiles on the vehicle (destructive).'**
  String get roadSenseDeleteLocalBody;

  /// No description provided for @roadSenseDeleteLocal.
  ///
  /// In en, this message translates to:
  /// **'Delete local data'**
  String get roadSenseDeleteLocal;

  /// No description provided for @roadSenseDeleteCloudTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete cloud RoadSense data?'**
  String get roadSenseDeleteCloudTitle;

  /// No description provided for @roadSenseDeleteCloudBody.
  ///
  /// In en, this message translates to:
  /// **'Requests cloud purge for this vehicle (destructive).'**
  String get roadSenseDeleteCloudBody;

  /// No description provided for @roadSenseDeleteCloud.
  ///
  /// In en, this message translates to:
  /// **'Delete cloud data'**
  String get roadSenseDeleteCloud;

  /// No description provided for @voiceFixtureUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Voice is turned off in vehicle settings'**
  String get voiceFixtureUnsupported;

  /// No description provided for @formatBytesBytes.
  ///
  /// In en, this message translates to:
  /// **'{bytes} B'**
  String formatBytesBytes(int bytes);

  /// No description provided for @formatBytesKib.
  ///
  /// In en, this message translates to:
  /// **'{size} KB'**
  String formatBytesKib(String size);

  /// No description provided for @formatBytesMib.
  ///
  /// In en, this message translates to:
  /// **'{size} MB'**
  String formatBytesMib(String size);

  /// No description provided for @releaseSigningDebugNote.
  ///
  /// In en, this message translates to:
  /// **'Release builds are signed with the debug key for CI/preview only — use your own release keystore for production distribution.'**
  String get releaseSigningDebugNote;

  /// No description provided for @automationSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Automation settings'**
  String get automationSettingsTitle;

  /// No description provided for @automationSchemaTitle.
  ///
  /// In en, this message translates to:
  /// **'Schema'**
  String get automationSchemaTitle;

  /// No description provided for @automationGlobalEnabled.
  ///
  /// In en, this message translates to:
  /// **'Automations enabled globally'**
  String get automationGlobalEnabled;

  /// No description provided for @automationStateTitle.
  ///
  /// In en, this message translates to:
  /// **'Engine state'**
  String get automationStateTitle;

  /// No description provided for @automationEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit automation'**
  String get automationEditTitle;

  /// No description provided for @automationEnabledLabel.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get automationEnabledLabel;

  /// No description provided for @automationModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Mode'**
  String get automationModeLabel;

  /// No description provided for @automationRulesSection.
  ///
  /// In en, this message translates to:
  /// **'Rules'**
  String get automationRulesSection;

  /// No description provided for @automationActionsSection.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get automationActionsSection;

  /// No description provided for @automationAddRule.
  ///
  /// In en, this message translates to:
  /// **'Add rule'**
  String get automationAddRule;

  /// No description provided for @automationAddAction.
  ///
  /// In en, this message translates to:
  /// **'Add action'**
  String get automationAddAction;

  /// No description provided for @automationSignalLabel.
  ///
  /// In en, this message translates to:
  /// **'Signal'**
  String get automationSignalLabel;

  /// No description provided for @automationOpLabel.
  ///
  /// In en, this message translates to:
  /// **'Operator'**
  String get automationOpLabel;

  /// No description provided for @automationValueLabel.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get automationValueLabel;

  /// No description provided for @parkingSignageTitle.
  ///
  /// In en, this message translates to:
  /// **'Session signage'**
  String get parkingSignageTitle;

  /// No description provided for @parkingSignageMessageLabel.
  ///
  /// In en, this message translates to:
  /// **'Sign message'**
  String get parkingSignageMessageLabel;

  /// No description provided for @parkingSignageEnabled.
  ///
  /// In en, this message translates to:
  /// **'Signage enabled'**
  String get parkingSignageEnabled;

  /// No description provided for @tripConfigTitle.
  ///
  /// In en, this message translates to:
  /// **'Trip recorder'**
  String get tripConfigTitle;

  /// No description provided for @tripConfigEnabled.
  ///
  /// In en, this message translates to:
  /// **'Record trips'**
  String get tripConfigEnabled;

  /// No description provided for @tripHistoryDaysLabel.
  ///
  /// In en, this message translates to:
  /// **'History window (days)'**
  String get tripHistoryDaysLabel;

  /// No description provided for @tripBootstrapTitle.
  ///
  /// In en, this message translates to:
  /// **'Bootstrap trip store'**
  String get tripBootstrapTitle;

  /// No description provided for @tripBootstrapBody.
  ///
  /// In en, this message translates to:
  /// **'Rebuilds trip metadata on the vehicle (server operation).'**
  String get tripBootstrapBody;

  /// No description provided for @tripDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Trip detail'**
  String get tripDetailTitle;

  /// No description provided for @tripStartedLabel.
  ///
  /// In en, this message translates to:
  /// **'Started'**
  String get tripStartedLabel;

  /// No description provided for @genAiRoutineAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get genAiRoutineAccept;

  /// No description provided for @genAiRoutineReject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get genAiRoutineReject;

  /// No description provided for @genAiActionTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Action type'**
  String get genAiActionTypeLabel;

  /// No description provided for @genAiActionTargetLabel.
  ///
  /// In en, this message translates to:
  /// **'Target (optional)'**
  String get genAiActionTargetLabel;

  /// No description provided for @genAiActionValueLabel.
  ///
  /// In en, this message translates to:
  /// **'Value (optional)'**
  String get genAiActionValueLabel;

  /// No description provided for @genAiCreateIncidentTitle.
  ///
  /// In en, this message translates to:
  /// **'Create incident pack'**
  String get genAiCreateIncidentTitle;

  /// No description provided for @genAiCreateIncidentBody.
  ///
  /// In en, this message translates to:
  /// **'Packages dashcam evidence for GenAI review on the vehicle.'**
  String get genAiCreateIncidentBody;

  /// No description provided for @genAiRecordingIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Recording ID'**
  String get genAiRecordingIdLabel;

  /// No description provided for @genAiRecordingIdRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a recording ID'**
  String get genAiRecordingIdRequired;

  /// No description provided for @telegramPinTitle.
  ///
  /// In en, this message translates to:
  /// **'Pair with PIN'**
  String get telegramPinTitle;

  /// No description provided for @telegramPinLabel.
  ///
  /// In en, this message translates to:
  /// **'Pairing PIN'**
  String get telegramPinLabel;

  /// No description provided for @telegramPinSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit PIN'**
  String get telegramPinSubmit;

  /// No description provided for @launcherAppearanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Launcher appearance'**
  String get launcherAppearanceTitle;

  /// No description provided for @bydCloudLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'Logged in'**
  String get bydCloudLoggedIn;

  /// No description provided for @bydCloudConfigured.
  ///
  /// In en, this message translates to:
  /// **'Configured — not logged in'**
  String get bydCloudConfigured;

  /// No description provided for @mqttTelemetryTitle.
  ///
  /// In en, this message translates to:
  /// **'MQTT telemetry'**
  String get mqttTelemetryTitle;

  /// No description provided for @audioAvasTitle.
  ///
  /// In en, this message translates to:
  /// **'AVAS playback'**
  String get audioAvasTitle;

  /// No description provided for @audioAvasPlaying.
  ///
  /// In en, this message translates to:
  /// **'Playing'**
  String get audioAvasPlaying;

  /// No description provided for @audioAvasIdle.
  ///
  /// In en, this message translates to:
  /// **'Idle'**
  String get audioAvasIdle;

  /// No description provided for @huRemoteTitle.
  ///
  /// In en, this message translates to:
  /// **'Head-unit remote'**
  String get huRemoteTitle;

  /// No description provided for @huRemoteIntro.
  ///
  /// In en, this message translates to:
  /// **'Shell keys, voice daemon, and cluster cast API — effects occur on the vehicle displays.'**
  String get huRemoteIntro;

  /// No description provided for @huRemoteOpen.
  ///
  /// In en, this message translates to:
  /// **'Open head-unit controls'**
  String get huRemoteOpen;

  /// No description provided for @huShellSection.
  ///
  /// In en, this message translates to:
  /// **'Head-unit shell'**
  String get huShellSection;

  /// No description provided for @huShellHint.
  ///
  /// In en, this message translates to:
  /// **'Sends Android navigation keys to the vehicle display (remote effect on HU).'**
  String get huShellHint;

  /// No description provided for @huShellConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This navigates the vehicle head unit. Confirm only if you are authorized.'**
  String get huShellConfirmBody;

  /// No description provided for @huHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get huHome;

  /// No description provided for @huBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get huBack;

  /// No description provided for @huRecents.
  ///
  /// In en, this message translates to:
  /// **'Recents'**
  String get huRecents;

  /// No description provided for @huDisplayId.
  ///
  /// In en, this message translates to:
  /// **'Display'**
  String get huDisplayId;

  /// No description provided for @huMoveX.
  ///
  /// In en, this message translates to:
  /// **'X offset'**
  String get huMoveX;

  /// No description provided for @huMoveY.
  ///
  /// In en, this message translates to:
  /// **'Y offset'**
  String get huMoveY;

  /// No description provided for @huMoveDisplayTitle.
  ///
  /// In en, this message translates to:
  /// **'Move display'**
  String get huMoveDisplayTitle;

  /// No description provided for @huVoiceSection.
  ///
  /// In en, this message translates to:
  /// **'Head-unit voice'**
  String get huVoiceSection;

  /// No description provided for @huVoiceConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Audio or speech plays on the vehicle speakers.'**
  String get huVoiceConfirmBody;

  /// No description provided for @huAudioFileLabel.
  ///
  /// In en, this message translates to:
  /// **'Audio file name'**
  String get huAudioFileLabel;

  /// No description provided for @huAudioFileHint.
  ///
  /// In en, this message translates to:
  /// **'Vehicle-side clip path or library name'**
  String get huAudioFileHint;

  /// No description provided for @huPlayAudio.
  ///
  /// In en, this message translates to:
  /// **'Play on HU'**
  String get huPlayAudio;

  /// No description provided for @huStopAudio.
  ///
  /// In en, this message translates to:
  /// **'Stop HU audio'**
  String get huStopAudio;

  /// No description provided for @huSpeakText.
  ///
  /// In en, this message translates to:
  /// **'Text to speak'**
  String get huSpeakText;

  /// No description provided for @huSpeak.
  ///
  /// In en, this message translates to:
  /// **'Speak'**
  String get huSpeak;

  /// No description provided for @huMessageText.
  ///
  /// In en, this message translates to:
  /// **'On-screen message'**
  String get huMessageText;

  /// No description provided for @huMessage.
  ///
  /// In en, this message translates to:
  /// **'Show message'**
  String get huMessage;

  /// No description provided for @huClusterSection.
  ///
  /// In en, this message translates to:
  /// **'Cluster cast API'**
  String get huClusterSection;

  /// No description provided for @huClusterHint.
  ///
  /// In en, this message translates to:
  /// **'Starts/stops cluster mirroring on the vehicle. Mirrored UI still renders on hardware.'**
  String get huClusterHint;

  /// No description provided for @huClusterAppPackage.
  ///
  /// In en, this message translates to:
  /// **'App package (optional)'**
  String get huClusterAppPackage;

  /// No description provided for @huClusterCastStart.
  ///
  /// In en, this message translates to:
  /// **'Start cluster cast'**
  String get huClusterCastStart;

  /// No description provided for @huClusterCastStop.
  ///
  /// In en, this message translates to:
  /// **'Stop cluster cast'**
  String get huClusterCastStop;

  /// No description provided for @debugWriteSection.
  ///
  /// In en, this message translates to:
  /// **'Write (requires confirm token)'**
  String get debugWriteSection;

  /// No description provided for @debugWriteTitle.
  ///
  /// In en, this message translates to:
  /// **'Apply debug write?'**
  String get debugWriteTitle;

  /// No description provided for @debugWriteBody.
  ///
  /// In en, this message translates to:
  /// **'Writes low-level vehicle registers. Incorrect values can affect safety systems.'**
  String get debugWriteBody;

  /// No description provided for @debugWriteSubmit.
  ///
  /// In en, this message translates to:
  /// **'Apply write'**
  String get debugWriteSubmit;

  /// No description provided for @debugConfirmTokenLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm token'**
  String get debugConfirmTokenLabel;

  /// No description provided for @debugConfirmTokenHint.
  ///
  /// In en, this message translates to:
  /// **'Upstream requires exact confirm text (e.g. YES)'**
  String get debugConfirmTokenHint;

  /// No description provided for @debugRegisterLabel.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get debugRegisterLabel;

  /// No description provided for @debugLightZoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Light zone'**
  String get debugLightZoneLabel;

  /// No description provided for @debugLightLevelLabel.
  ///
  /// In en, this message translates to:
  /// **'Level (0–100)'**
  String get debugLightLevelLabel;
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
