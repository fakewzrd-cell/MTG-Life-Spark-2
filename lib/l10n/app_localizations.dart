import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_pt.dart';

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
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('ja'),
    Locale('pt'),
    Locale('pt', 'BR'),
  ];

  /// App display name
  ///
  /// In en, this message translates to:
  /// **'Life Spark'**
  String get appTitle;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @navLobby.
  ///
  /// In en, this message translates to:
  /// **'Lobby'**
  String get navLobby;

  /// No description provided for @navDecks.
  ///
  /// In en, this message translates to:
  /// **'Decks'**
  String get navDecks;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsSectionGameplay.
  ///
  /// In en, this message translates to:
  /// **'Gameplay'**
  String get settingsSectionGameplay;

  /// No description provided for @settingsDefaultFormat.
  ///
  /// In en, this message translates to:
  /// **'Default Format'**
  String get settingsDefaultFormat;

  /// No description provided for @settingsDefaultFormatSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{format} · used when you host'**
  String settingsDefaultFormatSubtitle(String format);

  /// No description provided for @settingsDefaultStartingLife.
  ///
  /// In en, this message translates to:
  /// **'Default Starting Life'**
  String get settingsDefaultStartingLife;

  /// No description provided for @settingsDefaultStartingLifeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{life} life · used when you host'**
  String settingsDefaultStartingLifeSubtitle(int life);

  /// No description provided for @settingsSectionMisc.
  ///
  /// In en, this message translates to:
  /// **'Misc'**
  String get settingsSectionMisc;

  /// No description provided for @settingsKeepDisplayAwake.
  ///
  /// In en, this message translates to:
  /// **'Keep display awake'**
  String get settingsKeepDisplayAwake;

  /// No description provided for @settingsKeepDisplayAwakeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Prevent screen from sleeping during a game'**
  String get settingsKeepDisplayAwakeSubtitle;

  /// No description provided for @settingsHideSystemBars.
  ///
  /// In en, this message translates to:
  /// **'Hide navigation and status bars'**
  String get settingsHideSystemBars;

  /// No description provided for @settingsHideSystemBarsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fullscreen mode during gameplay'**
  String get settingsHideSystemBarsSubtitle;

  /// No description provided for @settingsSectionAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsSectionAppearance;

  /// No description provided for @settingsDarkAppearance.
  ///
  /// In en, this message translates to:
  /// **'Dark appearance'**
  String get settingsDarkAppearance;

  /// No description provided for @settingsDarkAppearanceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Light mode uses soft backgrounds — try Fog or Slate'**
  String get settingsDarkAppearanceSubtitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get settingsLanguageSystem;

  /// No description provided for @settingsLanguageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{language}'**
  String settingsLanguageSubtitle(String language);

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get languageSpanish;

  /// No description provided for @languagePortugueseBrazil.
  ///
  /// In en, this message translates to:
  /// **'Português (Brasil)'**
  String get languagePortugueseBrazil;

  /// No description provided for @languageFrench.
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get languageFrench;

  /// No description provided for @languageGerman.
  ///
  /// In en, this message translates to:
  /// **'Deutsch'**
  String get languageGerman;

  /// No description provided for @languageJapanese.
  ///
  /// In en, this message translates to:
  /// **'日本語'**
  String get languageJapanese;

  /// No description provided for @settingsSectionFeel.
  ///
  /// In en, this message translates to:
  /// **'Feel'**
  String get settingsSectionFeel;

  /// No description provided for @settingsHapticFeedback.
  ///
  /// In en, this message translates to:
  /// **'Haptic Feedback'**
  String get settingsHapticFeedback;

  /// No description provided for @settingsHapticFeedbackSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Vibrate on life changes and rank ups'**
  String get settingsHapticFeedbackSubtitle;

  /// No description provided for @settingsShakeToUndo.
  ///
  /// In en, this message translates to:
  /// **'Shake to Undo'**
  String get settingsShakeToUndo;

  /// No description provided for @settingsShakeToUndoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Shake phone to undo last life change'**
  String get settingsShakeToUndoSubtitle;

  /// No description provided for @settingsSectionData.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get settingsSectionData;

  /// No description provided for @settingsCacheCommanderImages.
  ///
  /// In en, this message translates to:
  /// **'Cache Commander Images'**
  String get settingsCacheCommanderImages;

  /// No description provided for @settingsCacheCommanderImagesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Store Scryfall images locally for offline use'**
  String get settingsCacheCommanderImagesSubtitle;

  /// No description provided for @settingsClearImageCache.
  ///
  /// In en, this message translates to:
  /// **'Clear Image Cache'**
  String get settingsClearImageCache;

  /// No description provided for @settingsClearImageCacheSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Free up storage from cached card images'**
  String get settingsClearImageCacheSubtitle;

  /// No description provided for @settingsSaveBackup.
  ///
  /// In en, this message translates to:
  /// **'Save backup'**
  String get settingsSaveBackup;

  /// No description provided for @settingsSaveBackupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Write profile, decks, settings, recent games, and feedback to a file'**
  String get settingsSaveBackupSubtitle;

  /// No description provided for @settingsRestoreBackup.
  ///
  /// In en, this message translates to:
  /// **'Restore backup'**
  String get settingsRestoreBackup;

  /// No description provided for @settingsRestoreBackupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Replace all local data from a .lifespark file'**
  String get settingsRestoreBackupSubtitle;

  /// No description provided for @settingsSectionHelp.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get settingsSectionHelp;

  /// No description provided for @settingsFeedback.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get settingsFeedback;

  /// No description provided for @settingsFeedbackSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Send us your thoughts and suggestions'**
  String get settingsFeedbackSubtitle;

  /// No description provided for @settingsViewHubGuide.
  ///
  /// In en, this message translates to:
  /// **'View hub guide'**
  String get settingsViewHubGuide;

  /// No description provided for @settingsViewHubGuideSubtitle.
  ///
  /// In en, this message translates to:
  /// **'How Play, Stack, Lookup, and Table work in a match'**
  String get settingsViewHubGuideSubtitle;

  /// No description provided for @settingsViewTutorialAgain.
  ///
  /// In en, this message translates to:
  /// **'View Tutorial Again'**
  String get settingsViewTutorialAgain;

  /// No description provided for @settingsViewTutorialAgainSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Re-launch the onboarding walkthrough'**
  String get settingsViewTutorialAgainSubtitle;

  /// No description provided for @settingsBeta.
  ///
  /// In en, this message translates to:
  /// **'Beta'**
  String get settingsBeta;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get commonAdd;

  /// No description provided for @commonRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get commonRemove;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get commonTryAgain;

  /// No description provided for @backupSaved.
  ///
  /// In en, this message translates to:
  /// **'Backup saved.'**
  String get backupSaved;

  /// No description provided for @backupSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save backup.'**
  String get backupSaveFailed;

  /// No description provided for @backupRestoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore {username}?'**
  String backupRestoreTitle(String username);

  /// No description provided for @backupRestoreMessage.
  ///
  /// In en, this message translates to:
  /// **'This replaces your profile, decks, settings, recent games, sparks, and behaviour on this device with the selected backup.'**
  String get backupRestoreMessage;

  /// No description provided for @backupRestoreConfirm.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get backupRestoreConfirm;

  /// No description provided for @backupRestored.
  ///
  /// In en, this message translates to:
  /// **'Restored backup for {username}.'**
  String backupRestored(String username);

  /// No description provided for @backupRestoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not restore backup. Check the file and try again.'**
  String get backupRestoreFailed;

  /// No description provided for @cacheCleared.
  ///
  /// In en, this message translates to:
  /// **'Image cache cleared.'**
  String get cacheCleared;

  /// No description provided for @cacheClearFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not clear image cache.'**
  String get cacheClearFailed;

  /// No description provided for @decksTitle.
  ///
  /// In en, this message translates to:
  /// **'Decks'**
  String get decksTitle;

  /// No description provided for @decksAddDeck.
  ///
  /// In en, this message translates to:
  /// **'Add deck'**
  String get decksAddDeck;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileRecentGames.
  ///
  /// In en, this message translates to:
  /// **'Recent games'**
  String get profileRecentGames;

  /// No description provided for @profileDeckPerformance.
  ///
  /// In en, this message translates to:
  /// **'Deck performance'**
  String get profileDeckPerformance;

  /// No description provided for @lobbyTitle.
  ///
  /// In en, this message translates to:
  /// **'Lobby'**
  String get lobbyTitle;

  /// No description provided for @lobbyHostGame.
  ///
  /// In en, this message translates to:
  /// **'Host Game'**
  String get lobbyHostGame;

  /// No description provided for @lobbyHostGameSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create a session — others join you'**
  String get lobbyHostGameSubtitle;

  /// No description provided for @lobbyJoinGame.
  ///
  /// In en, this message translates to:
  /// **'Join Game'**
  String get lobbyJoinGame;

  /// No description provided for @lobbyJoinGameSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Scan for a nearby host'**
  String get lobbyJoinGameSubtitle;

  /// No description provided for @hostLobbyTitle.
  ///
  /// In en, this message translates to:
  /// **'Host Lobby'**
  String get hostLobbyTitle;

  /// No description provided for @hostLeaveLobbyTooltip.
  ///
  /// In en, this message translates to:
  /// **'Leave lobby'**
  String get hostLeaveLobbyTooltip;

  /// No description provided for @hostPlayersScanQr.
  ///
  /// In en, this message translates to:
  /// **'Players: {count} / {max}  •  Scan QR to join'**
  String hostPlayersScanQr(int count, int max);

  /// No description provided for @hostNeedWifiRetry.
  ///
  /// In en, this message translates to:
  /// **'Connect this device to Wi‑Fi (same network as guests), then tap Retry.'**
  String get hostNeedWifiRetry;

  /// No description provided for @hostNeedsMobileApp.
  ///
  /// In en, this message translates to:
  /// **'Hosting needs the mobile app (iOS or Android) on the same Wi‑Fi. The browser can join games by scanning a QR code, but cannot host.'**
  String get hostNeedsMobileApp;

  /// No description provided for @hostNeedsMobileOrDev.
  ///
  /// In en, this message translates to:
  /// **'Hosting needs the mobile app or a local dev build on your machine.'**
  String get hostNeedsMobileOrDev;

  /// No description provided for @hostCreateProfileFirst.
  ///
  /// In en, this message translates to:
  /// **'Create your profile first (Home → set username), then tap Retry.'**
  String get hostCreateProfileFirst;

  /// No description provided for @hostCouldNotStartServer.
  ///
  /// In en, this message translates to:
  /// **'Could not start the host server on this device. Tap Retry.'**
  String get hostCouldNotStartServer;

  /// No description provided for @hostSessionDidNotStart.
  ///
  /// In en, this message translates to:
  /// **'Host session did not start. Tap Retry.'**
  String get hostSessionDidNotStart;

  /// No description provided for @hostCouldNotShowQr.
  ///
  /// In en, this message translates to:
  /// **'Could not show join QR code.'**
  String get hostCouldNotShowQr;

  /// No description provided for @hostRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get hostRetry;

  /// No description provided for @hostNeedOnePlayer.
  ///
  /// In en, this message translates to:
  /// **'Need at least 1 player'**
  String get hostNeedOnePlayer;

  /// No description provided for @hostEveryoneMustBeReady.
  ///
  /// In en, this message translates to:
  /// **'Everyone must be ready'**
  String get hostEveryoneMustBeReady;

  /// No description provided for @hostStartGame.
  ///
  /// In en, this message translates to:
  /// **'Start Game'**
  String get hostStartGame;

  /// No description provided for @hostOpenSlots.
  ///
  /// In en, this message translates to:
  /// **'{count} open slot(s) — share your device to let friends join'**
  String hostOpenSlots(int count);

  /// No description provided for @hostMatchLabel.
  ///
  /// In en, this message translates to:
  /// **'Label'**
  String get hostMatchLabel;

  /// No description provided for @hostMatchLabelHelp.
  ///
  /// In en, this message translates to:
  /// **'Optional. Helps you find this game in Recent games.'**
  String get hostMatchLabelHelp;

  /// No description provided for @hostMatchLabelHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Friday EDH'**
  String get hostMatchLabelHint;

  /// No description provided for @hostGameSettings.
  ///
  /// In en, this message translates to:
  /// **'Game Settings'**
  String get hostGameSettings;

  /// No description provided for @hostFormat.
  ///
  /// In en, this message translates to:
  /// **'Format'**
  String get hostFormat;

  /// No description provided for @hostStartingLife.
  ///
  /// In en, this message translates to:
  /// **'Starting Life'**
  String get hostStartingLife;

  /// No description provided for @hostCustomStartingLifeTitle.
  ///
  /// In en, this message translates to:
  /// **'Custom starting life'**
  String get hostCustomStartingLifeTitle;

  /// No description provided for @hostCustomStartingLifeHint.
  ///
  /// In en, this message translates to:
  /// **'Enter life total (1–999)'**
  String get hostCustomStartingLifeHint;

  /// No description provided for @hostCustomEllipsis.
  ///
  /// In en, this message translates to:
  /// **'Custom…'**
  String get hostCustomEllipsis;

  /// No description provided for @hostGameplay.
  ///
  /// In en, this message translates to:
  /// **'Gameplay'**
  String get hostGameplay;

  /// No description provided for @hostToggleTeams.
  ///
  /// In en, this message translates to:
  /// **'Teams'**
  String get hostToggleTeams;

  /// No description provided for @hostToggleTeamsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Assign team colors on the table'**
  String get hostToggleTeamsSubtitle;

  /// No description provided for @hostTogglePlanechaseSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Internet required for planar deck'**
  String get hostTogglePlanechaseSubtitle;

  /// No description provided for @hostToggleArchenemySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Internet required for scheme deck'**
  String get hostToggleArchenemySubtitle;

  /// No description provided for @hostToggleBountySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Internet required for bounty deck'**
  String get hostToggleBountySubtitle;

  /// No description provided for @hostToggleAutoKo.
  ///
  /// In en, this message translates to:
  /// **'Auto-KO'**
  String get hostToggleAutoKo;

  /// No description provided for @hostToggleAutoKoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'From life, poison, or commander damage'**
  String get hostToggleAutoKoSubtitle;

  /// No description provided for @hostToggleCommanderDmgLife.
  ///
  /// In en, this message translates to:
  /// **'Commander damage life loss'**
  String get hostToggleCommanderDmgLife;

  /// No description provided for @hostToggleCommanderDmgLifeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Commander damage also reduces life'**
  String get hostToggleCommanderDmgLifeSubtitle;

  /// No description provided for @hostTogglePhaseTracker.
  ///
  /// In en, this message translates to:
  /// **'Phase tracker'**
  String get hostTogglePhaseTracker;

  /// No description provided for @hostTogglePhaseTrackerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Show turn phases with Back and Next'**
  String get hostTogglePhaseTrackerSubtitle;

  /// No description provided for @hostToggleTurnTimer.
  ///
  /// In en, this message translates to:
  /// **'Turn timer'**
  String get hostToggleTurnTimer;

  /// No description provided for @hostToggleTurnTimerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Show elapsed time each turn'**
  String get hostToggleTurnTimerSubtitle;

  /// No description provided for @hostTurnLimit.
  ///
  /// In en, this message translates to:
  /// **'Turn limit'**
  String get hostTurnLimit;

  /// No description provided for @hostTurnLimitOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get hostTurnLimitOff;

  /// No description provided for @hostTurnLimitSeconds.
  ///
  /// In en, this message translates to:
  /// **'{seconds} seconds'**
  String hostTurnLimitSeconds(int seconds);

  /// No description provided for @hostNoCommanderSelected.
  ///
  /// In en, this message translates to:
  /// **'No commander selected'**
  String get hostNoCommanderSelected;

  /// No description provided for @hostNoDeckSelected.
  ///
  /// In en, this message translates to:
  /// **'No deck selected'**
  String get hostNoDeckSelected;

  /// No description provided for @hostTrackingDeck.
  ///
  /// In en, this message translates to:
  /// **'Tracking: {name}'**
  String hostTrackingDeck(String name);

  /// No description provided for @hostDeckListChanged.
  ///
  /// In en, this message translates to:
  /// **'Deck (saved list changed)'**
  String get hostDeckListChanged;

  /// No description provided for @hostSelectDeck.
  ///
  /// In en, this message translates to:
  /// **'Deck'**
  String get hostSelectDeck;

  /// No description provided for @hostSelectCommander.
  ///
  /// In en, this message translates to:
  /// **'Commander'**
  String get hostSelectCommander;

  /// No description provided for @hostMarkReady.
  ///
  /// In en, this message translates to:
  /// **'Mark ready'**
  String get hostMarkReady;

  /// No description provided for @hostMarkNotReady.
  ///
  /// In en, this message translates to:
  /// **'Mark not ready'**
  String get hostMarkNotReady;

  /// No description provided for @lobbyReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get lobbyReady;

  /// No description provided for @lobbyWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get lobbyWaiting;

  /// No description provided for @deckPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Deck for this match'**
  String get deckPickerTitle;

  /// No description provided for @deckPickerManualOnly.
  ///
  /// In en, this message translates to:
  /// **'Manual commander only'**
  String get deckPickerManualOnly;

  /// No description provided for @deckPickerManualOnlySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Keep commanders as-is; do not attribute to a saved deck'**
  String get deckPickerManualOnlySubtitle;

  /// No description provided for @deckPickerEmptyForFormat.
  ///
  /// In en, this message translates to:
  /// **'No {format} decks saved yet. Create one from the Decks tab.'**
  String deckPickerEmptyForFormat(String format);

  /// No description provided for @deckPickerOpenDecks.
  ///
  /// In en, this message translates to:
  /// **'Open Decks'**
  String get deckPickerOpenDecks;

  /// No description provided for @joinTitle.
  ///
  /// In en, this message translates to:
  /// **'Join a Game'**
  String get joinTitle;

  /// No description provided for @joinLeaveTooltip.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get joinLeaveTooltip;

  /// No description provided for @joinPointCamera.
  ///
  /// In en, this message translates to:
  /// **'Point the camera at the host\'s QR code'**
  String get joinPointCamera;

  /// No description provided for @joinCameraRequiredSnack.
  ///
  /// In en, this message translates to:
  /// **'Camera permission is required to scan the host QR code.'**
  String get joinCameraRequiredSnack;

  /// No description provided for @joinCameraDeniedBody.
  ///
  /// In en, this message translates to:
  /// **'Camera access is needed to scan the host QR code.\\nIf you already allowed it in Settings, tap Try again.'**
  String get joinCameraDeniedBody;

  /// No description provided for @joinOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get joinOpenSettings;

  /// No description provided for @joinInvalidQr.
  ///
  /// In en, this message translates to:
  /// **'Not a valid Life Spark QR code.'**
  String get joinInvalidQr;

  /// No description provided for @joinMissingToken.
  ///
  /// In en, this message translates to:
  /// **'This QR code is missing a join token. Ask the host to refresh their QR.'**
  String get joinMissingToken;

  /// No description provided for @joinCouldNotStartSession.
  ///
  /// In en, this message translates to:
  /// **'Could not start join session. Finish profile setup and try again.'**
  String get joinCouldNotStartSession;

  /// No description provided for @joinConnectTimeout.
  ///
  /// In en, this message translates to:
  /// **'Timed out connecting to the host. Make sure you are on the same Wi‑Fi and the host lobby is still open, then try again.'**
  String get joinConnectTimeout;

  /// No description provided for @joinHostRejected.
  ///
  /// In en, this message translates to:
  /// **'Host rejected connection (version mismatch).'**
  String get joinHostRejected;

  /// No description provided for @joinDisconnected.
  ///
  /// In en, this message translates to:
  /// **'Disconnected from host.'**
  String get joinDisconnected;

  /// No description provided for @joinConnectionError.
  ///
  /// In en, this message translates to:
  /// **'Connection error.'**
  String get joinConnectionError;

  /// No description provided for @joinHostEndedSession.
  ///
  /// In en, this message translates to:
  /// **'The host ended the session.'**
  String get joinHostEndedSession;

  /// No description provided for @joinConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting to host…'**
  String get joinConnecting;

  /// No description provided for @joinWaitingForHost.
  ///
  /// In en, this message translates to:
  /// **'Waiting for host to start…'**
  String get joinWaitingForHost;

  /// No description provided for @joinSelectDeck.
  ///
  /// In en, this message translates to:
  /// **'Select deck'**
  String get joinSelectDeck;

  /// No description provided for @joinSelectCommander.
  ///
  /// In en, this message translates to:
  /// **'Select commander'**
  String get joinSelectCommander;

  /// No description provided for @joinReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get joinReady;

  /// No description provided for @joinMarkReady.
  ///
  /// In en, this message translates to:
  /// **'Mark ready'**
  String get joinMarkReady;

  /// No description provided for @welcomeTagline.
  ///
  /// In en, this message translates to:
  /// **'Your MTG companion.'**
  String get welcomeTagline;

  /// No description provided for @welcomeReadyToPlay.
  ///
  /// In en, this message translates to:
  /// **'Ready to play'**
  String get welcomeReadyToPlay;

  /// No description provided for @welcomeSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get welcomeSkip;

  /// No description provided for @onboardingSlide1Title.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Life Spark'**
  String get onboardingSlide1Title;

  /// No description provided for @onboardingSlide1Body.
  ///
  /// In en, this message translates to:
  /// **'Your Commander battlefield companion — life, counters, politics, and the stack, synced at the table.'**
  String get onboardingSlide1Body;

  /// No description provided for @onboardingSlide2Title.
  ///
  /// In en, this message translates to:
  /// **'Host or Join'**
  String get onboardingSlide2Title;

  /// No description provided for @onboardingSlide2Body.
  ///
  /// In en, this message translates to:
  /// **'One player hosts a game — others scan a QR code on the same Wi‑Fi network. No internet account needed. Works for 4 to 6 players at the same table.'**
  String get onboardingSlide2Body;

  /// No description provided for @onboardingSlide3Title.
  ///
  /// In en, this message translates to:
  /// **'Track Your Life'**
  String get onboardingSlide3Title;

  /// No description provided for @onboardingSlide3Body.
  ///
  /// In en, this message translates to:
  /// **'Tap +/- to change life by 1. Hold +/- for ±5. Drag left or right to adjust quickly. Double-tap the life total to set an exact number. Undo is on the bottom bar (or shake, if enabled).'**
  String get onboardingSlide3Body;

  /// No description provided for @onboardingSlide4Title.
  ///
  /// In en, this message translates to:
  /// **'Phase Bar & Turns'**
  String get onboardingSlide4Title;

  /// No description provided for @onboardingSlide4Body.
  ///
  /// In en, this message translates to:
  /// **'Use the phase bar to step through the turn, or leave Phase tracker off in the lobby. Timeout pauses the whole game.'**
  String get onboardingSlide4Body;

  /// No description provided for @onboardingSlide5Title.
  ///
  /// In en, this message translates to:
  /// **'Commander & Counters'**
  String get onboardingSlide5Title;

  /// No description provided for @onboardingSlide5Body.
  ///
  /// In en, this message translates to:
  /// **'Commander damage opens as a threat list — how much each opponent has dealt you toward 21. Track poison (10), energy, experience, and rad. Use Proliferate to add 1 to all at once.'**
  String get onboardingSlide5Body;

  /// No description provided for @onboardingSlide6Title.
  ///
  /// In en, this message translates to:
  /// **'Alliances & Politics'**
  String get onboardingSlide6Title;

  /// No description provided for @onboardingSlide6Body.
  ///
  /// In en, this message translates to:
  /// **'Propose secret alliances with other players. They expire automatically or break when you attack each other. Track the Monarch and Initiative with a single tap.'**
  String get onboardingSlide6Body;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingReadyToPlay.
  ///
  /// In en, this message translates to:
  /// **'Ready to play'**
  String get onboardingReadyToPlay;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @profileSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your profile'**
  String get profileSetupTitle;

  /// No description provided for @profileSetupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a name and picture your table will recognize.'**
  String get profileSetupSubtitle;

  /// No description provided for @profileSetupUsername.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get profileSetupUsername;

  /// No description provided for @profileSetupUsernameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a username'**
  String get profileSetupUsernameRequired;

  /// No description provided for @profileSetupUsernameTooShort.
  ///
  /// In en, this message translates to:
  /// **'Must be at least 2 characters'**
  String get profileSetupUsernameTooShort;

  /// No description provided for @profileSetupChoosePicture.
  ///
  /// In en, this message translates to:
  /// **'Choose profile picture'**
  String get profileSetupChoosePicture;

  /// No description provided for @profileSetupChangePicture.
  ///
  /// In en, this message translates to:
  /// **'Change picture'**
  String get profileSetupChangePicture;

  /// No description provided for @profileSetupContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get profileSetupContinue;

  /// No description provided for @sessionLeaveTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave active game?'**
  String get sessionLeaveTitle;

  /// No description provided for @sessionLeaveMessage.
  ///
  /// In en, this message translates to:
  /// **'You have a lobby or game session running. Leaving will disconnect other players at the table.'**
  String get sessionLeaveMessage;

  /// No description provided for @sessionLeaveConfirm.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get sessionLeaveConfirm;

  /// No description provided for @sessionLeaveStay.
  ///
  /// In en, this message translates to:
  /// **'Stay'**
  String get sessionLeaveStay;

  /// No description provided for @gameLeaveTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave game?'**
  String get gameLeaveTitle;

  /// No description provided for @gameLeaveMessageActive.
  ///
  /// In en, this message translates to:
  /// **'You will leave the game and return home. Match stats only save when the table finishes the game.'**
  String get gameLeaveMessageActive;

  /// No description provided for @gameLeaveMessageAfterConcede.
  ///
  /// In en, this message translates to:
  /// **'You will leave the live game and return home. Your concede result will be saved before disconnecting.'**
  String get gameLeaveMessageAfterConcede;

  /// No description provided for @gameTabPlay.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get gameTabPlay;

  /// No description provided for @gameTabStack.
  ///
  /// In en, this message translates to:
  /// **'Stack'**
  String get gameTabStack;

  /// No description provided for @gameTabLookupSemantics.
  ///
  /// In en, this message translates to:
  /// **'Look up card rules'**
  String get gameTabLookupSemantics;

  /// No description provided for @gameBarHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get gameBarHome;

  /// No description provided for @gameBarUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get gameBarUndo;

  /// No description provided for @gameBarTimeout.
  ///
  /// In en, this message translates to:
  /// **'Timeout'**
  String get gameBarTimeout;

  /// No description provided for @gameBarEnd.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get gameBarEnd;

  /// No description provided for @gameBarTable.
  ///
  /// In en, this message translates to:
  /// **'Table'**
  String get gameBarTable;

  /// No description provided for @gameEndTurn.
  ///
  /// In en, this message translates to:
  /// **'End turn'**
  String get gameEndTurn;

  /// No description provided for @gameWaitingForPlayer.
  ///
  /// In en, this message translates to:
  /// **'Waiting for {name}…'**
  String gameWaitingForPlayer(String name);

  /// No description provided for @gamePhaseBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get gamePhaseBack;

  /// No description provided for @gamePhaseNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get gamePhaseNext;

  /// No description provided for @gameChoosePhase.
  ///
  /// In en, this message translates to:
  /// **'Choose phase'**
  String get gameChoosePhase;

  /// No description provided for @gameYourTurn.
  ///
  /// In en, this message translates to:
  /// **'Your turn'**
  String get gameYourTurn;

  /// No description provided for @gameYourTurnTapContinue.
  ///
  /// In en, this message translates to:
  /// **'Tap to continue'**
  String get gameYourTurnTapContinue;

  /// No description provided for @gameYourTurnSemantics.
  ///
  /// In en, this message translates to:
  /// **'Your turn. Double tap to dismiss.'**
  String get gameYourTurnSemantics;

  /// No description provided for @gameNowPlaying.
  ///
  /// In en, this message translates to:
  /// **'NOW PLAYING'**
  String get gameNowPlaying;

  /// No description provided for @gameActiveTurn.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE TURN'**
  String get gameActiveTurn;

  /// No description provided for @gamePlayersTurn.
  ///
  /// In en, this message translates to:
  /// **'{name}\'s turn'**
  String gamePlayersTurn(String name);

  /// No description provided for @gameCurrentTurn.
  ///
  /// In en, this message translates to:
  /// **'Current turn'**
  String get gameCurrentTurn;

  /// No description provided for @timeoutStartTitle.
  ///
  /// In en, this message translates to:
  /// **'Start Timeout'**
  String get timeoutStartTitle;

  /// No description provided for @timeout15Seconds.
  ///
  /// In en, this message translates to:
  /// **'15 seconds'**
  String get timeout15Seconds;

  /// No description provided for @timeout30Seconds.
  ///
  /// In en, this message translates to:
  /// **'30 seconds'**
  String get timeout30Seconds;

  /// No description provided for @timeout1Minute.
  ///
  /// In en, this message translates to:
  /// **'1 minute'**
  String get timeout1Minute;

  /// No description provided for @timeoutBanner.
  ///
  /// In en, this message translates to:
  /// **'TIMEOUT'**
  String get timeoutBanner;

  /// No description provided for @timeoutPaused.
  ///
  /// In en, this message translates to:
  /// **'Game paused — no life changes'**
  String get timeoutPaused;

  /// No description provided for @timeoutEnd.
  ///
  /// In en, this message translates to:
  /// **'End timeout'**
  String get timeoutEnd;

  /// No description provided for @timeoutMinimized.
  ///
  /// In en, this message translates to:
  /// **'Timeout — {time}'**
  String timeoutMinimized(String time);

  /// No description provided for @timeoutMinimizeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Minimize timer'**
  String get timeoutMinimizeTooltip;

  /// No description provided for @reconnectToTable.
  ///
  /// In en, this message translates to:
  /// **'Reconnecting to table…'**
  String get reconnectToTable;

  /// No description provided for @reconnectStillTrying.
  ///
  /// In en, this message translates to:
  /// **'Still trying to reach the table…'**
  String get reconnectStillTrying;

  /// No description provided for @reconnectPeerOne.
  ///
  /// In en, this message translates to:
  /// **'{name} is reconnecting…'**
  String reconnectPeerOne(String name);

  /// No description provided for @reconnectPeerMany.
  ///
  /// In en, this message translates to:
  /// **'{count} players reconnecting…'**
  String reconnectPeerMany(int count);

  /// No description provided for @forfeitTitle.
  ///
  /// In en, this message translates to:
  /// **'Forfeit?'**
  String get forfeitTitle;

  /// No description provided for @forfeitBodyMulti.
  ///
  /// In en, this message translates to:
  /// **'You will leave the game. Optionally rate opponents before you go.'**
  String get forfeitBodyMulti;

  /// No description provided for @forfeitBodySolo.
  ///
  /// In en, this message translates to:
  /// **'Your practice game will end. Optionally note how it went.'**
  String get forfeitBodySolo;

  /// No description provided for @forfeitRateOpponents.
  ///
  /// In en, this message translates to:
  /// **'Rate opponents'**
  String get forfeitRateOpponents;

  /// No description provided for @forfeitConfirm.
  ///
  /// In en, this message translates to:
  /// **'Forfeit'**
  String get forfeitConfirm;

  /// No description provided for @forfeitYouForfeited.
  ///
  /// In en, this message translates to:
  /// **'You forfeited'**
  String get forfeitYouForfeited;

  /// No description provided for @forfeitStaySpectateBody.
  ///
  /// In en, this message translates to:
  /// **'Other players can keep playing. Stay on this device to spectate until the table finishes. Returning to your profile hub now saves your concede result and disconnects from the live game.'**
  String get forfeitStaySpectateBody;

  /// No description provided for @forfeitStaySpectate.
  ///
  /// In en, this message translates to:
  /// **'Stay & spectate'**
  String get forfeitStaySpectate;

  /// No description provided for @forfeitReturnToProfile.
  ///
  /// In en, this message translates to:
  /// **'Return to profile'**
  String get forfeitReturnToProfile;

  /// No description provided for @gamePlayerLeftTitle.
  ///
  /// In en, this message translates to:
  /// **'Player left'**
  String get gamePlayerLeftTitle;

  /// No description provided for @gamePlayerLeftMessage.
  ///
  /// In en, this message translates to:
  /// **'{username} left the game.'**
  String gamePlayerLeftMessage(String username);

  /// No description provided for @gameSessionEndedTitle.
  ///
  /// In en, this message translates to:
  /// **'Session ended'**
  String get gameSessionEndedTitle;

  /// No description provided for @gameSessionEndedMessage.
  ///
  /// In en, this message translates to:
  /// **'The host ended the game.'**
  String get gameSessionEndedMessage;

  /// No description provided for @gamePeerOfflineTitle.
  ///
  /// In en, this message translates to:
  /// **'{username} still offline'**
  String gamePeerOfflineTitle(String username);

  /// No description provided for @gamePeerOfflineBody.
  ///
  /// In en, this message translates to:
  /// **'Keep waiting for them to reconnect, or remove them from the table?'**
  String get gamePeerOfflineBody;

  /// No description provided for @gameKeepWaiting.
  ///
  /// In en, this message translates to:
  /// **'Keep waiting'**
  String get gameKeepWaiting;

  /// No description provided for @gameRemoveFromTable.
  ///
  /// In en, this message translates to:
  /// **'Remove from table'**
  String get gameRemoveFromTable;

  /// No description provided for @gameSlotLoadFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not load your player slot'**
  String get gameSlotLoadFailedTitle;

  /// No description provided for @gameSlotLoadFailedBody.
  ///
  /// In en, this message translates to:
  /// **'The game may be out of sync. Return to the lobby and rejoin.'**
  String get gameSlotLoadFailedBody;

  /// No description provided for @gameReturnToLobby.
  ///
  /// In en, this message translates to:
  /// **'Return to lobby'**
  String get gameReturnToLobby;

  /// No description provided for @profileSetupPrompt.
  ///
  /// In en, this message translates to:
  /// **'Set up your profile to continue.'**
  String get profileSetupPrompt;

  /// No description provided for @profileCreateCta.
  ///
  /// In en, this message translates to:
  /// **'Create profile'**
  String get profileCreateCta;

  /// No description provided for @profileNewPlayer.
  ///
  /// In en, this message translates to:
  /// **'New player'**
  String get profileNewPlayer;

  /// No description provided for @profilePlayingSince.
  ///
  /// In en, this message translates to:
  /// **'Playing since {date}'**
  String profilePlayingSince(String date);

  /// No description provided for @profileOptions.
  ///
  /// In en, this message translates to:
  /// **'Profile options'**
  String get profileOptions;

  /// No description provided for @profileDoneEditing.
  ///
  /// In en, this message translates to:
  /// **'Done editing'**
  String get profileDoneEditing;

  /// No description provided for @profileDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get profileDone;

  /// No description provided for @profileEditName.
  ///
  /// In en, this message translates to:
  /// **'Edit name'**
  String get profileEditName;

  /// No description provided for @profileEditNameTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit name'**
  String get profileEditNameTooltip;

  /// No description provided for @profileChangePicture.
  ///
  /// In en, this message translates to:
  /// **'Change profile picture'**
  String get profileChangePicture;

  /// No description provided for @profileStatRecord.
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get profileStatRecord;

  /// No description provided for @profileStatSparks.
  ///
  /// In en, this message translates to:
  /// **'Sparks'**
  String get profileStatSparks;

  /// No description provided for @profileStatGames.
  ///
  /// In en, this message translates to:
  /// **'Games'**
  String get profileStatGames;

  /// No description provided for @profileEmptyRecentGames.
  ///
  /// In en, this message translates to:
  /// **'Play your first game to unlock stats and history.'**
  String get profileEmptyRecentGames;

  /// No description provided for @profileEmptyDeckPerf.
  ///
  /// In en, this message translates to:
  /// **'Add a deck to track commander performance here.'**
  String get profileEmptyDeckPerf;

  /// No description provided for @profileFilterAllGames.
  ///
  /// In en, this message translates to:
  /// **'All games'**
  String get profileFilterAllGames;

  /// No description provided for @profileFilterRecent14.
  ///
  /// In en, this message translates to:
  /// **'Recent (14 days)'**
  String get profileFilterRecent14;

  /// No description provided for @profileFilterThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get profileFilterThisWeek;

  /// No description provided for @profileFilterThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get profileFilterThisMonth;

  /// No description provided for @profileNoMatchesFilter.
  ///
  /// In en, this message translates to:
  /// **'No matches for this filter.'**
  String get profileNoMatchesFilter;

  /// No description provided for @profileOpenLobbySemantics.
  ///
  /// In en, this message translates to:
  /// **'Open lobby to host or join a game'**
  String get profileOpenLobbySemantics;

  /// No description provided for @profileShowMore.
  ///
  /// In en, this message translates to:
  /// **'Show more'**
  String get profileShowMore;

  /// No description provided for @profileStandings.
  ///
  /// In en, this message translates to:
  /// **'Standings'**
  String get profileStandings;

  /// No description provided for @profileNoPlayerDetails.
  ///
  /// In en, this message translates to:
  /// **'No player details saved for this match.'**
  String get profileNoPlayerDetails;

  /// No description provided for @profileResultConcede.
  ///
  /// In en, this message translates to:
  /// **'Concede'**
  String get profileResultConcede;

  /// No description provided for @profileResultLoss.
  ///
  /// In en, this message translates to:
  /// **'Loss'**
  String get profileResultLoss;

  /// No description provided for @decksEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Build your deck library'**
  String get decksEmptyTitle;

  /// No description provided for @decksEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Save a deck with a name, format, and cover card. When you host or join a game, pick the right list in the lobby.'**
  String get decksEmptyBody;

  /// No description provided for @decksSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search decks…'**
  String get decksSearchHint;

  /// No description provided for @decksNoSearchMatches.
  ///
  /// In en, this message translates to:
  /// **'No decks match “{query}”.'**
  String decksNoSearchMatches(String query);

  /// No description provided for @decksStyleNotSet.
  ///
  /// In en, this message translates to:
  /// **'Style not set'**
  String get decksStyleNotSet;

  /// No description provided for @decksNoCoverCard.
  ///
  /// In en, this message translates to:
  /// **'No cover card'**
  String get decksNoCoverCard;

  /// No description provided for @lookupTitle.
  ///
  /// In en, this message translates to:
  /// **'Card lookup'**
  String get lookupTitle;

  /// No description provided for @lookupHint.
  ///
  /// In en, this message translates to:
  /// **'Search any MTG card…'**
  String get lookupHint;

  /// No description provided for @lookupHelp.
  ///
  /// In en, this message translates to:
  /// **'Oracle text and official rulings from Scryfall.'**
  String get lookupHelp;

  /// No description provided for @lookupEmptyPrompt.
  ///
  /// In en, this message translates to:
  /// **'Type a card name to look up rules.'**
  String get lookupEmptyPrompt;

  /// No description provided for @lookupNoResults.
  ///
  /// In en, this message translates to:
  /// **'No cards found for “{query}”.'**
  String lookupNoResults(String query);

  /// No description provided for @lookupNetworkError.
  ///
  /// In en, this message translates to:
  /// **'Could not reach Scryfall. Check your connection.'**
  String get lookupNetworkError;

  /// No description provided for @lookupSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get lookupSearch;

  /// No description provided for @lookupOracleText.
  ///
  /// In en, this message translates to:
  /// **'Oracle text'**
  String get lookupOracleText;

  /// No description provided for @lookupNoOracle.
  ///
  /// In en, this message translates to:
  /// **'No oracle text available for this card.'**
  String get lookupNoOracle;

  /// No description provided for @lookupRulings.
  ///
  /// In en, this message translates to:
  /// **'Rulings'**
  String get lookupRulings;

  /// No description provided for @lookupNoRulings.
  ///
  /// In en, this message translates to:
  /// **'No official rulings listed for this card.'**
  String get lookupNoRulings;

  /// No description provided for @endGameSavingResults.
  ///
  /// In en, this message translates to:
  /// **'Saving match results…'**
  String get endGameSavingResults;

  /// No description provided for @endGameSaveFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not save match results.'**
  String get endGameSaveFailedTitle;

  /// No description provided for @endGameSaveFailedBody.
  ///
  /// In en, this message translates to:
  /// **'Your stats may not have updated. Try again.'**
  String get endGameSaveFailedBody;

  /// No description provided for @endGameRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get endGameRetry;

  /// No description provided for @endGameContinueWithoutSaving.
  ///
  /// In en, this message translates to:
  /// **'Continue without saving'**
  String get endGameContinueWithoutSaving;

  /// No description provided for @endGameFinalStandings.
  ///
  /// In en, this message translates to:
  /// **'Final Standings'**
  String get endGameFinalStandings;

  /// No description provided for @endGameOverNoWinner.
  ///
  /// In en, this message translates to:
  /// **'Game Over — No Winner'**
  String get endGameOverNoWinner;

  /// No description provided for @endGamePracticeEnded.
  ///
  /// In en, this message translates to:
  /// **'Practice ended'**
  String get endGamePracticeEnded;

  /// No description provided for @endGameYouWin.
  ///
  /// In en, this message translates to:
  /// **'You Win!'**
  String get endGameYouWin;

  /// No description provided for @endGameWinner.
  ///
  /// In en, this message translates to:
  /// **'Winner'**
  String get endGameWinner;

  /// No description provided for @endGameRankUp.
  ///
  /// In en, this message translates to:
  /// **'RANK UP!'**
  String get endGameRankUp;

  /// No description provided for @endGameRankTransition.
  ///
  /// In en, this message translates to:
  /// **'Rank {oldLevel} → {newLevel}'**
  String endGameRankTransition(int oldLevel, int newLevel);

  /// No description provided for @endGameXpGained.
  ///
  /// In en, this message translates to:
  /// **'+{xp} XP'**
  String endGameXpGained(int xp);

  /// No description provided for @endGameWinBonusIncluded.
  ///
  /// In en, this message translates to:
  /// **'Win bonus included'**
  String get endGameWinBonusIncluded;

  /// No description provided for @endGameParticipationXp.
  ///
  /// In en, this message translates to:
  /// **'Participation XP'**
  String get endGameParticipationXp;

  /// No description provided for @endGameRankLevel.
  ///
  /// In en, this message translates to:
  /// **'Rank {level}'**
  String endGameRankLevel(int level);

  /// No description provided for @endGameFeedbackThanks.
  ///
  /// In en, this message translates to:
  /// **'Thanks! Your feedback has been recorded.'**
  String get endGameFeedbackThanks;

  /// No description provided for @endGameRateOpponents.
  ///
  /// In en, this message translates to:
  /// **'Rate Your Opponents'**
  String get endGameRateOpponents;

  /// No description provided for @endGameSubmitFeedback.
  ///
  /// In en, this message translates to:
  /// **'Submit Feedback'**
  String get endGameSubmitFeedback;

  /// No description provided for @endGameYouSuffix.
  ///
  /// In en, this message translates to:
  /// **'(you)'**
  String get endGameYouSuffix;

  /// No description provided for @endGameElimReasonLife.
  ///
  /// In en, this message translates to:
  /// **'Life depleted'**
  String get endGameElimReasonLife;

  /// No description provided for @endGameElimReasonPoison.
  ///
  /// In en, this message translates to:
  /// **'10 poison'**
  String get endGameElimReasonPoison;

  /// No description provided for @endGameElimReasonCommanderDmg.
  ///
  /// In en, this message translates to:
  /// **'Commander dmg'**
  String get endGameElimReasonCommanderDmg;

  /// No description provided for @endGameElimReasonConcede.
  ///
  /// In en, this message translates to:
  /// **'Conceded'**
  String get endGameElimReasonConcede;

  /// No description provided for @endGameElimReasonDisconnect.
  ///
  /// In en, this message translates to:
  /// **'Left game'**
  String get endGameElimReasonDisconnect;

  /// No description provided for @endGameElimReasonDefault.
  ///
  /// In en, this message translates to:
  /// **'Eliminated'**
  String get endGameElimReasonDefault;

  /// No description provided for @endGameBackToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get endGameBackToHome;

  /// No description provided for @feedbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedbackTitle;

  /// No description provided for @feedbackHeadline.
  ///
  /// In en, this message translates to:
  /// **'Help us improve'**
  String get feedbackHeadline;

  /// No description provided for @feedbackBody.
  ///
  /// In en, this message translates to:
  /// **'Found a bug? Have a feature idea? We read every message.'**
  String get feedbackBody;

  /// No description provided for @feedbackMessageLabel.
  ///
  /// In en, this message translates to:
  /// **'Your message'**
  String get feedbackMessageLabel;

  /// No description provided for @feedbackMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Tell us what you think...'**
  String get feedbackMessageHint;

  /// No description provided for @feedbackSend.
  ///
  /// In en, this message translates to:
  /// **'Send Feedback'**
  String get feedbackSend;

  /// No description provided for @feedbackOrDivider.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get feedbackOrDivider;

  /// No description provided for @feedbackRatePlayStore.
  ///
  /// In en, this message translates to:
  /// **'Rate on Play Store'**
  String get feedbackRatePlayStore;

  /// No description provided for @feedbackMailSubject.
  ///
  /// In en, this message translates to:
  /// **'Life Spark Feedback'**
  String get feedbackMailSubject;

  /// No description provided for @feedbackOpeningMail.
  ///
  /// In en, this message translates to:
  /// **'Opening your mail app…'**
  String get feedbackOpeningMail;

  /// No description provided for @feedbackNoMailAppCopied.
  ///
  /// In en, this message translates to:
  /// **'No mail app — message copied. Paste into an email to {email}'**
  String feedbackNoMailAppCopied(String email);

  /// No description provided for @feedbackClipboardFallback.
  ///
  /// In en, this message translates to:
  /// **'To: {email}\\nSubject: Life Spark Feedback\\n\\n{message}'**
  String feedbackClipboardFallback(String email, String message);

  /// No description provided for @stackSortOrderOnStack.
  ///
  /// In en, this message translates to:
  /// **'Order on stack'**
  String get stackSortOrderOnStack;

  /// No description provided for @stackSortByPlayer.
  ///
  /// In en, this message translates to:
  /// **'By player'**
  String get stackSortByPlayer;

  /// No description provided for @stackAddSpellOrAbility.
  ///
  /// In en, this message translates to:
  /// **'Add spell or ability'**
  String get stackAddSpellOrAbility;

  /// No description provided for @stackHowItWorksTooltip.
  ///
  /// In en, this message translates to:
  /// **'How the stack works'**
  String get stackHowItWorksTooltip;

  /// No description provided for @stackFilterResolvedCountered.
  ///
  /// In en, this message translates to:
  /// **'Resolved / countered'**
  String get stackFilterResolvedCountered;

  /// No description provided for @stackApnapHint.
  ///
  /// In en, this message translates to:
  /// **'Who added what (active player first)'**
  String get stackApnapHint;

  /// No description provided for @stackClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get stackClearAll;

  /// No description provided for @stackClearConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear stack?'**
  String get stackClearConfirmTitle;

  /// No description provided for @stackClearConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Remove every spell and ability on the stack. This cannot be undone.'**
  String get stackClearConfirmBody;

  /// No description provided for @stackActivePlayerLabel.
  ///
  /// In en, this message translates to:
  /// **'{username} · Active player'**
  String stackActivePlayerLabel(String username);

  /// No description provided for @stackTurnOrderLabel.
  ///
  /// In en, this message translates to:
  /// **'{username} · Turn order: {position}'**
  String stackTurnOrderLabel(String username, int position);

  /// No description provided for @stackPutOnStack.
  ///
  /// In en, this message translates to:
  /// **'Put on stack'**
  String get stackPutOnStack;

  /// No description provided for @stackInResponseToEllipsis.
  ///
  /// In en, this message translates to:
  /// **'In response to…'**
  String get stackInResponseToEllipsis;

  /// No description provided for @stackEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing on the stack'**
  String get stackEmptyTitle;

  /// No description provided for @stackEmptyBullet1.
  ///
  /// In en, this message translates to:
  /// **'Put spells and abilities here before they resolve.'**
  String get stackEmptyBullet1;

  /// No description provided for @stackEmptyBullet2.
  ///
  /// In en, this message translates to:
  /// **'The last one added resolves first.'**
  String get stackEmptyBullet2;

  /// No description provided for @stackAddSpell.
  ///
  /// In en, this message translates to:
  /// **'Add spell'**
  String get stackAddSpell;

  /// No description provided for @stackStatusResolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get stackStatusResolved;

  /// No description provided for @stackStatusCountered.
  ///
  /// In en, this message translates to:
  /// **'Countered'**
  String get stackStatusCountered;

  /// No description provided for @stackStatusFizzled.
  ///
  /// In en, this message translates to:
  /// **'Fizzled'**
  String get stackStatusFizzled;

  /// No description provided for @stackYouSuffix.
  ///
  /// In en, this message translates to:
  /// **'(you)'**
  String get stackYouSuffix;

  /// No description provided for @stackUndoFizzle.
  ///
  /// In en, this message translates to:
  /// **'Undo fizzle'**
  String get stackUndoFizzle;

  /// No description provided for @stackFizzle.
  ///
  /// In en, this message translates to:
  /// **'Fizzle'**
  String get stackFizzle;

  /// No description provided for @stackUndoFizzleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Put this spell back on the stack as active'**
  String get stackUndoFizzleSubtitle;

  /// No description provided for @stackFizzleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Target illegal or spell left the stack (rules counter)'**
  String get stackFizzleSubtitle;

  /// No description provided for @stackMarkCountered.
  ///
  /// In en, this message translates to:
  /// **'Mark countered'**
  String get stackMarkCountered;

  /// No description provided for @stackRename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get stackRename;

  /// No description provided for @stackOnStack.
  ///
  /// In en, this message translates to:
  /// **'On stack'**
  String get stackOnStack;

  /// No description provided for @stackResolvesNext.
  ///
  /// In en, this message translates to:
  /// **'Resolves next'**
  String get stackResolvesNext;

  /// No description provided for @stackResolvesAfterAbove.
  ///
  /// In en, this message translates to:
  /// **'Resolves after items above'**
  String get stackResolvesAfterAbove;

  /// No description provided for @stackTargetNoLongerOnStack.
  ///
  /// In en, this message translates to:
  /// **'Target is no longer on the stack'**
  String get stackTargetNoLongerOnStack;

  /// No description provided for @stackCardRulesTooltip.
  ///
  /// In en, this message translates to:
  /// **'Card rules'**
  String get stackCardRulesTooltip;

  /// No description provided for @stackInResponseToNamed.
  ///
  /// In en, this message translates to:
  /// **'In response to {name}'**
  String stackInResponseToNamed(String name);

  /// No description provided for @stackResolve.
  ///
  /// In en, this message translates to:
  /// **'Resolve'**
  String get stackResolve;

  /// No description provided for @stackRespond.
  ///
  /// In en, this message translates to:
  /// **'Respond'**
  String get stackRespond;

  /// No description provided for @stackFizzledButton.
  ///
  /// In en, this message translates to:
  /// **'Fizzled'**
  String get stackFizzledButton;

  /// No description provided for @stackHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'How the stack works'**
  String get stackHelpTitle;

  /// No description provided for @stackHelpBullet1.
  ///
  /// In en, this message translates to:
  /// **'When someone casts a spell or uses an ability, it goes on the stack — a waiting line before it happens.'**
  String get stackHelpBullet1;

  /// No description provided for @stackHelpBullet2.
  ///
  /// In en, this message translates to:
  /// **'The last thing added resolves first (like a stack of plates). That is why the top entry says Resolves next.'**
  String get stackHelpBullet2;

  /// No description provided for @stackHelpBullet3.
  ///
  /// In en, this message translates to:
  /// **'When you add a spell, search Scryfall and pick the card from the list so we store the correct name and rules text.'**
  String get stackHelpBullet3;

  /// No description provided for @stackHelpBullet4.
  ///
  /// In en, this message translates to:
  /// **'To answer something, tap Respond or use In response to… — your spell goes on top and resolves before the one under it.'**
  String get stackHelpBullet4;

  /// No description provided for @stackHelpBullet5.
  ///
  /// In en, this message translates to:
  /// **'When an effect finishes, tap Resolve — the card stays on the stack and turns green. To answer it, tap Respond. If a counterspell worked, Mark countered (use the Countered filter to view). If a spell lost its target, tap Fizzle — it stays greyed; tap Fizzled again to undo.'**
  String get stackHelpBullet5;

  /// No description provided for @stackHelpBullet6.
  ///
  /// In en, this message translates to:
  /// **'At the table you still say “pass” out loud for priority; this screen helps everyone remember what is waiting and in what order.'**
  String get stackHelpBullet6;

  /// No description provided for @stackHelpExample.
  ///
  /// In en, this message translates to:
  /// **'Example: You cast a pump spell on your creature. Your opponent casts Lightning Bolt in response. Bolt resolves first, then your pump spell (if its target is still legal).'**
  String get stackHelpExample;

  /// No description provided for @stackHelpReadMore.
  ///
  /// In en, this message translates to:
  /// **'Read more on Magic.com'**
  String get stackHelpReadMore;

  /// No description provided for @stackHelpCouldNotOpenLink.
  ///
  /// In en, this message translates to:
  /// **'Could not open link'**
  String get stackHelpCouldNotOpenLink;

  /// No description provided for @stackPickerIntro.
  ///
  /// In en, this message translates to:
  /// **'Search Scryfall so we store the correct card name and rules text.'**
  String get stackPickerIntro;

  /// No description provided for @stackPickerCardNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Card name'**
  String get stackPickerCardNameLabel;

  /// No description provided for @stackPickerCardNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Lightning Bolt'**
  String get stackPickerCardNameHint;

  /// No description provided for @stackPickerClearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get stackPickerClearSearch;

  /// No description provided for @stackPickerAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get stackPickerAdd;

  /// No description provided for @stackPickerNoCards.
  ///
  /// In en, this message translates to:
  /// **'No cards found. Try a different spelling.'**
  String get stackPickerNoCards;

  /// No description provided for @stackPickerNetworkError.
  ///
  /// In en, this message translates to:
  /// **'Could not reach Scryfall. Check your internet connection.'**
  String get stackPickerNetworkError;

  /// No description provided for @stackPickerNeedSelection.
  ///
  /// In en, this message translates to:
  /// **'Pick a card from the list, or type a name Scryfall recognizes.'**
  String get stackPickerNeedSelection;

  /// No description provided for @stackPickerTypeToSearch.
  ///
  /// In en, this message translates to:
  /// **'Type to search cards'**
  String get stackPickerTypeToSearch;

  /// No description provided for @allianceAPlayer.
  ///
  /// In en, this message translates to:
  /// **'A player'**
  String get allianceAPlayer;

  /// No description provided for @allianceYourAllyFallback.
  ///
  /// In en, this message translates to:
  /// **'your ally'**
  String get allianceYourAllyFallback;

  /// No description provided for @allianceOfferDeclined.
  ///
  /// In en, this message translates to:
  /// **'Secret alliance offer declined'**
  String get allianceOfferDeclined;

  /// No description provided for @allianceEnded.
  ///
  /// In en, this message translates to:
  /// **'Secret alliance ended'**
  String get allianceEnded;

  /// No description provided for @allianceProposeTitle.
  ///
  /// In en, this message translates to:
  /// **'Secret alliance'**
  String get allianceProposeTitle;

  /// No description provided for @allianceProposeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Invite {username} — only they will know.'**
  String allianceProposeSubtitle(String username);

  /// No description provided for @allianceDurationSection.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get allianceDurationSection;

  /// No description provided for @allianceDurationEndOfTurn.
  ///
  /// In en, this message translates to:
  /// **'Until end of turn'**
  String get allianceDurationEndOfTurn;

  /// No description provided for @allianceDurationEndOfRound.
  ///
  /// In en, this message translates to:
  /// **'Until end of round'**
  String get allianceDurationEndOfRound;

  /// No description provided for @allianceDurationUntilBroken.
  ///
  /// In en, this message translates to:
  /// **'Until broken'**
  String get allianceDurationUntilBroken;

  /// No description provided for @allianceWhenToDeliver.
  ///
  /// In en, this message translates to:
  /// **'When to deliver'**
  String get allianceWhenToDeliver;

  /// No description provided for @allianceDeliverNow.
  ///
  /// In en, this message translates to:
  /// **'Deliver now'**
  String get allianceDeliverNow;

  /// No description provided for @allianceDeliverInSeconds.
  ///
  /// In en, this message translates to:
  /// **'Deliver in {seconds}s'**
  String allianceDeliverInSeconds(int seconds);

  /// No description provided for @allianceDeliverEndOfYourTurn.
  ///
  /// In en, this message translates to:
  /// **'Deliver at end of your turn'**
  String get allianceDeliverEndOfYourTurn;

  /// No description provided for @allianceDeliverNextRound.
  ///
  /// In en, this message translates to:
  /// **'Deliver next round'**
  String get allianceDeliverNextRound;

  /// No description provided for @allianceSecondsShort.
  ///
  /// In en, this message translates to:
  /// **'{seconds}s'**
  String allianceSecondsShort(int seconds);

  /// No description provided for @allianceSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get allianceSend;

  /// No description provided for @allianceWhisperSent.
  ///
  /// In en, this message translates to:
  /// **'Whisper sent to {username}'**
  String allianceWhisperSent(String username);

  /// No description provided for @allianceWhisperScheduled.
  ///
  /// In en, this message translates to:
  /// **'Whisper scheduled for {username}'**
  String allianceWhisperScheduled(String username);

  /// No description provided for @allianceInviteTitle.
  ///
  /// In en, this message translates to:
  /// **'Secret offer'**
  String get allianceInviteTitle;

  /// No description provided for @allianceInviteBody.
  ///
  /// In en, this message translates to:
  /// **'{username} proposes a secret alliance.\\n\\nDuration: {duration}\\n\\nOnly you can see this.'**
  String allianceInviteBody(String username, String duration);

  /// No description provided for @allianceAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get allianceAccept;

  /// No description provided for @allianceDecline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get allianceDecline;

  /// No description provided for @allianceFormedTitle.
  ///
  /// In en, this message translates to:
  /// **'Alliance formed'**
  String get allianceFormedTitle;

  /// No description provided for @allianceFormedBody.
  ///
  /// In en, this message translates to:
  /// **'You and {username} are now secretly allied ({duration}).\\n\\nThe table does not know — unless you reveal or betray.'**
  String allianceFormedBody(String username, String duration);

  /// No description provided for @allianceFormedBodyNoDuration.
  ///
  /// In en, this message translates to:
  /// **'You and {username} are now secretly allied.\\n\\nThe table does not know — unless you reveal or betray.'**
  String allianceFormedBodyNoDuration(String username);

  /// No description provided for @allianceUnderstood.
  ///
  /// In en, this message translates to:
  /// **'Understood'**
  String get allianceUnderstood;

  /// No description provided for @allianceRevealedTitle.
  ///
  /// In en, this message translates to:
  /// **'Alliance revealed'**
  String get allianceRevealedTitle;

  /// No description provided for @allianceRevealedBody.
  ///
  /// In en, this message translates to:
  /// **'{playerA} and {playerB} have revealed their secret alliance to the table.'**
  String allianceRevealedBody(String playerA, String playerB);

  /// No description provided for @allianceOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get allianceOk;

  /// No description provided for @allianceBetrayalTitle.
  ///
  /// In en, this message translates to:
  /// **'Betrayal!'**
  String get allianceBetrayalTitle;

  /// No description provided for @allianceBetrayalBody.
  ///
  /// In en, this message translates to:
  /// **'The secret alliance between {playerA} and {playerB} has been broken by betrayal.'**
  String allianceBetrayalBody(String playerA, String playerB);

  /// No description provided for @allianceBadgeAllied.
  ///
  /// In en, this message translates to:
  /// **'Allied'**
  String get allianceBadgeAllied;

  /// No description provided for @allianceBadgeSecretAlly.
  ///
  /// In en, this message translates to:
  /// **'Secret ally'**
  String get allianceBadgeSecretAlly;

  /// No description provided for @allianceWhisperPending.
  ///
  /// In en, this message translates to:
  /// **'Whisper pending → {username}'**
  String allianceWhisperPending(String username);

  /// No description provided for @allianceAwaiting.
  ///
  /// In en, this message translates to:
  /// **'Awaiting {username}'**
  String allianceAwaiting(String username);

  /// No description provided for @cmdDmgSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Commander damage'**
  String get cmdDmgSheetTitle;

  /// No description provided for @cmdDmgSheetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Threats to you first. Open Dealt to log damage you dealt.'**
  String get cmdDmgSheetSubtitle;

  /// No description provided for @cmdDmgBarA11y.
  ///
  /// In en, this message translates to:
  /// **'Commander damage life {remaining} of {ko} remaining, {taken} taken on worst track, tap to manage'**
  String cmdDmgBarA11y(String remaining, String ko, String taken);

  /// No description provided for @cmdDmgLeft.
  ///
  /// In en, this message translates to:
  /// **'left'**
  String get cmdDmgLeft;

  /// No description provided for @cmdDmgHideDealt.
  ///
  /// In en, this message translates to:
  /// **'Hide dealt'**
  String get cmdDmgHideDealt;

  /// No description provided for @cmdDmgDealtTotal.
  ///
  /// In en, this message translates to:
  /// **'Dealt {total}'**
  String cmdDmgDealtTotal(String total);

  /// No description provided for @cmdDmgDefaultCommander.
  ///
  /// In en, this message translates to:
  /// **'Commander'**
  String get cmdDmgDefaultCommander;

  /// No description provided for @cmdDmgDefaultPartner.
  ///
  /// In en, this message translates to:
  /// **'Partner'**
  String get cmdDmgDefaultPartner;

  /// No description provided for @cmdDmgDefaultPartnerCommander.
  ///
  /// In en, this message translates to:
  /// **'Partner commander'**
  String get cmdDmgDefaultPartnerCommander;

  /// No description provided for @cmdDmgYouDealtTitle.
  ///
  /// In en, this message translates to:
  /// **'You → {name}'**
  String cmdDmgYouDealtTitle(String name);

  /// No description provided for @cmdDmgYouDealtSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Damage you dealt'**
  String get cmdDmgYouDealtSubtitle;

  /// No description provided for @cmdDmgLethalTooltip.
  ///
  /// In en, this message translates to:
  /// **'Lethal commander damage!'**
  String get cmdDmgLethalTooltip;

  /// No description provided for @cmdDmgIncreaseA11y.
  ///
  /// In en, this message translates to:
  /// **'Increase commander damage'**
  String get cmdDmgIncreaseA11y;

  /// No description provided for @cmdDmgDecreaseA11y.
  ///
  /// In en, this message translates to:
  /// **'Decrease commander damage'**
  String get cmdDmgDecreaseA11y;

  /// No description provided for @cmdBarCastCommander.
  ///
  /// In en, this message translates to:
  /// **'Cast commander'**
  String get cmdBarCastCommander;

  /// No description provided for @cmdBarEliminated.
  ///
  /// In en, this message translates to:
  /// **'Eliminated'**
  String get cmdBarEliminated;

  /// No description provided for @cmdBarNoTaxYet.
  ///
  /// In en, this message translates to:
  /// **'No tax yet'**
  String get cmdBarNoTaxYet;

  /// No description provided for @cmdBarRemoveLastCast.
  ///
  /// In en, this message translates to:
  /// **'Remove last commander cast'**
  String get cmdBarRemoveLastCast;

  /// No description provided for @cmdBarCommanderTax.
  ///
  /// In en, this message translates to:
  /// **'Commander tax'**
  String get cmdBarCommanderTax;

  /// No description provided for @cmdBarTapToRemoveLastCast.
  ///
  /// In en, this message translates to:
  /// **'Tap to remove last cast'**
  String get cmdBarTapToRemoveLastCast;

  /// No description provided for @cmdBarTaxPlus.
  ///
  /// In en, this message translates to:
  /// **'Tax +{tax}'**
  String cmdBarTaxPlus(int tax);

  /// No description provided for @counterResetConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset to 0?'**
  String get counterResetConfirmTitle;

  /// No description provided for @counterResetConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Set this counter to zero.'**
  String get counterResetConfirmBody;

  /// No description provided for @counterResetConfirmAction.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get counterResetConfirmAction;

  /// No description provided for @counterResetToZero.
  ///
  /// In en, this message translates to:
  /// **'Reset to 0'**
  String get counterResetToZero;

  /// No description provided for @counterDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get counterDone;

  /// No description provided for @firstPlayerRollTitle.
  ///
  /// In en, this message translates to:
  /// **'Roll for First Player'**
  String get firstPlayerRollTitle;

  /// No description provided for @firstPlayerRollSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Highest roll goes first. Tap the die to roll!'**
  String get firstPlayerRollSubtitle;

  /// No description provided for @firstPlayerRollDieA11y.
  ///
  /// In en, this message translates to:
  /// **'Roll die'**
  String get firstPlayerRollDieA11y;

  /// No description provided for @firstPlayerRollingA11y.
  ///
  /// In en, this message translates to:
  /// **'Rolling'**
  String get firstPlayerRollingA11y;

  /// No description provided for @firstPlayerRolledA11y.
  ///
  /// In en, this message translates to:
  /// **'Rolled {value}'**
  String firstPlayerRolledA11y(String value);

  /// No description provided for @firstPlayerNotRolledA11y.
  ///
  /// In en, this message translates to:
  /// **'Not rolled'**
  String get firstPlayerNotRolledA11y;

  /// No description provided for @firstPlayerYouRolled.
  ///
  /// In en, this message translates to:
  /// **'You rolled {value}!'**
  String firstPlayerYouRolled(String value);

  /// No description provided for @firstPlayerYouRolledA11y.
  ///
  /// In en, this message translates to:
  /// **'You rolled {value}'**
  String firstPlayerYouRolledA11y(String value);

  /// No description provided for @firstPlayerRolling.
  ///
  /// In en, this message translates to:
  /// **'Rolling…'**
  String get firstPlayerRolling;

  /// No description provided for @firstPlayerTapToRoll.
  ///
  /// In en, this message translates to:
  /// **'Tap to roll'**
  String get firstPlayerTapToRoll;

  /// No description provided for @firstPlayerHostProgressA11y.
  ///
  /// In en, this message translates to:
  /// **'{rolled} of {total} players have rolled'**
  String firstPlayerHostProgressA11y(String rolled, String total);

  /// No description provided for @firstPlayerWaitingOthersA11y.
  ///
  /// In en, this message translates to:
  /// **'Waiting for other players to roll'**
  String get firstPlayerWaitingOthersA11y;

  /// No description provided for @firstPlayerRollToContinueA11y.
  ///
  /// In en, this message translates to:
  /// **'Roll die to continue'**
  String get firstPlayerRollToContinueA11y;

  /// No description provided for @firstPlayerHostProgress.
  ///
  /// In en, this message translates to:
  /// **'{rolled} / {total} players have rolled'**
  String firstPlayerHostProgress(String rolled, String total);

  /// No description provided for @firstPlayerWaitingOthers.
  ///
  /// In en, this message translates to:
  /// **'Waiting for others to roll…'**
  String get firstPlayerWaitingOthers;

  /// No description provided for @firstPlayerTapDieAbove.
  ///
  /// In en, this message translates to:
  /// **'Tap the die above to roll'**
  String get firstPlayerTapDieAbove;

  /// No description provided for @firstPlayerYouSuffix.
  ///
  /// In en, this message translates to:
  /// **'{username} (you)'**
  String firstPlayerYouSuffix(String username);

  /// No description provided for @firstPlayerTurnOrderTitle.
  ///
  /// In en, this message translates to:
  /// **'Turn Order'**
  String get firstPlayerTurnOrderTitle;

  /// No description provided for @firstPlayerTurnOrderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Highest roll leads — play proceeds in this order.'**
  String get firstPlayerTurnOrderSubtitle;

  /// No description provided for @firstPlayerStartGame.
  ///
  /// In en, this message translates to:
  /// **'Start game'**
  String get firstPlayerStartGame;

  /// No description provided for @firstPlayerOrdinal1.
  ///
  /// In en, this message translates to:
  /// **'1st'**
  String get firstPlayerOrdinal1;

  /// No description provided for @firstPlayerOrdinal2.
  ///
  /// In en, this message translates to:
  /// **'2nd'**
  String get firstPlayerOrdinal2;

  /// No description provided for @firstPlayerOrdinal3.
  ///
  /// In en, this message translates to:
  /// **'3rd'**
  String get firstPlayerOrdinal3;

  /// No description provided for @firstPlayerOrdinal4.
  ///
  /// In en, this message translates to:
  /// **'4th'**
  String get firstPlayerOrdinal4;

  /// No description provided for @firstPlayerOrdinal5.
  ///
  /// In en, this message translates to:
  /// **'5th'**
  String get firstPlayerOrdinal5;

  /// No description provided for @firstPlayerOrdinal6.
  ///
  /// In en, this message translates to:
  /// **'6th'**
  String get firstPlayerOrdinal6;

  /// No description provided for @firstPlayerSlotA11y.
  ///
  /// In en, this message translates to:
  /// **'{place}, {name}, {rollDetail}'**
  String firstPlayerSlotA11y(String place, String name, String rollDetail);

  /// No description provided for @firstPlayerSlotYou.
  ///
  /// In en, this message translates to:
  /// **'{username}, you'**
  String firstPlayerSlotYou(String username);

  /// No description provided for @firstPlayerRollUnavailable.
  ///
  /// In en, this message translates to:
  /// **'roll unavailable'**
  String get firstPlayerRollUnavailable;

  /// No description provided for @firstPlayerRolledDetail.
  ///
  /// In en, this message translates to:
  /// **'rolled {value}'**
  String firstPlayerRolledDetail(String value);

  /// No description provided for @firstPlayerGoesFirst.
  ///
  /// In en, this message translates to:
  /// **'goes first'**
  String get firstPlayerGoesFirst;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTitle;

  /// No description provided for @historySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Life, counters, and other table actions.'**
  String get historySubtitle;

  /// No description provided for @historyEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No actions yet'**
  String get historyEmptyTitle;

  /// No description provided for @historyEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Life changes, counters, and other table actions will show up here as the game goes on.'**
  String get historyEmptyBody;

  /// No description provided for @historyTurn.
  ///
  /// In en, this message translates to:
  /// **'Turn {turn}'**
  String historyTurn(String turn);

  /// No description provided for @overviewElimReasonLife.
  ///
  /// In en, this message translates to:
  /// **'Life loss'**
  String get overviewElimReasonLife;

  /// No description provided for @overviewElimReasonPoison.
  ///
  /// In en, this message translates to:
  /// **'Poison'**
  String get overviewElimReasonPoison;

  /// No description provided for @overviewElimReasonCommanderDmg.
  ///
  /// In en, this message translates to:
  /// **'Commander dmg'**
  String get overviewElimReasonCommanderDmg;

  /// No description provided for @overviewElimReasonConcede.
  ///
  /// In en, this message translates to:
  /// **'Conceded'**
  String get overviewElimReasonConcede;

  /// No description provided for @overviewElimReasonDisconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get overviewElimReasonDisconnect;

  /// No description provided for @overviewRound.
  ///
  /// In en, this message translates to:
  /// **'Round {round}'**
  String overviewRound(int round);

  /// No description provided for @overviewClose.
  ///
  /// In en, this message translates to:
  /// **'Close overview'**
  String get overviewClose;

  /// No description provided for @overviewTools.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get overviewTools;

  /// No description provided for @overviewHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get overviewHistory;

  /// No description provided for @overviewPlayers.
  ///
  /// In en, this message translates to:
  /// **'Players'**
  String get overviewPlayers;

  /// No description provided for @overviewHoldDragReorder.
  ///
  /// In en, this message translates to:
  /// **'Hold & drag to reorder turns'**
  String get overviewHoldDragReorder;

  /// No description provided for @overviewDecreaseLife.
  ///
  /// In en, this message translates to:
  /// **'Decrease life'**
  String get overviewDecreaseLife;

  /// No description provided for @overviewIncreaseLife.
  ///
  /// In en, this message translates to:
  /// **'Increase life'**
  String get overviewIncreaseLife;

  /// No description provided for @overviewCommanderTaxPlus.
  ///
  /// In en, this message translates to:
  /// **'Commander tax plus {tax}'**
  String overviewCommanderTaxPlus(int tax);

  /// No description provided for @overviewTaxPlus.
  ///
  /// In en, this message translates to:
  /// **'Tax +{tax}'**
  String overviewTaxPlus(int tax);

  /// No description provided for @overviewMonarchA11y.
  ///
  /// In en, this message translates to:
  /// **'Monarch'**
  String get overviewMonarchA11y;

  /// No description provided for @overviewInitiativeA11y.
  ///
  /// In en, this message translates to:
  /// **'Initiative'**
  String get overviewInitiativeA11y;

  /// No description provided for @overviewNowPlaying.
  ///
  /// In en, this message translates to:
  /// **'NOW PLAYING'**
  String get overviewNowPlaying;

  /// No description provided for @overviewSendWhisper.
  ///
  /// In en, this message translates to:
  /// **'Send whisper'**
  String get overviewSendWhisper;

  /// No description provided for @overviewAssignTeamColor.
  ///
  /// In en, this message translates to:
  /// **'Assign team color'**
  String get overviewAssignTeamColor;

  /// No description provided for @overviewProposeSecretAlliance.
  ///
  /// In en, this message translates to:
  /// **'Propose secret alliance'**
  String get overviewProposeSecretAlliance;

  /// No description provided for @overviewRevealAlliance.
  ///
  /// In en, this message translates to:
  /// **'Reveal alliance to table'**
  String get overviewRevealAlliance;

  /// No description provided for @overviewBreakAlliance.
  ///
  /// In en, this message translates to:
  /// **'Break secret alliance'**
  String get overviewBreakAlliance;

  /// No description provided for @overviewAssignTeamTitle.
  ///
  /// In en, this message translates to:
  /// **'Assign team'**
  String get overviewAssignTeamTitle;

  /// No description provided for @overviewTeamNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get overviewTeamNone;

  /// No description provided for @overviewTeamN.
  ///
  /// In en, this message translates to:
  /// **'Team {index}'**
  String overviewTeamN(String index);

  /// No description provided for @dialsStripLimitSnack.
  ///
  /// In en, this message translates to:
  /// **'Your strip holds up to {max} counters. Remove one to add another.'**
  String dialsStripLimitSnack(int max);

  /// No description provided for @dialsLabelPoison.
  ///
  /// In en, this message translates to:
  /// **'Poison'**
  String get dialsLabelPoison;

  /// No description provided for @dialsLabelEnergy.
  ///
  /// In en, this message translates to:
  /// **'Energy'**
  String get dialsLabelEnergy;

  /// No description provided for @dialsLabelExp.
  ///
  /// In en, this message translates to:
  /// **'Exp'**
  String get dialsLabelExp;

  /// No description provided for @dialsLabelRad.
  ///
  /// In en, this message translates to:
  /// **'Rad'**
  String get dialsLabelRad;

  /// No description provided for @dialsLabelBlood.
  ///
  /// In en, this message translates to:
  /// **'Blood'**
  String get dialsLabelBlood;

  /// No description provided for @dialsLabelClue.
  ///
  /// In en, this message translates to:
  /// **'Clue'**
  String get dialsLabelClue;

  /// No description provided for @dialsLabelMap.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get dialsLabelMap;

  /// No description provided for @dialsLabelTreasure.
  ///
  /// In en, this message translates to:
  /// **'Treasure'**
  String get dialsLabelTreasure;

  /// No description provided for @dialsLabelDevotion.
  ///
  /// In en, this message translates to:
  /// **'Devotion'**
  String get dialsLabelDevotion;

  /// No description provided for @dialsLabelCreatures.
  ///
  /// In en, this message translates to:
  /// **'Creatures'**
  String get dialsLabelCreatures;

  /// No description provided for @dialsLabelEnchant.
  ///
  /// In en, this message translates to:
  /// **'Enchant'**
  String get dialsLabelEnchant;

  /// No description provided for @dialsLabelArtifacts.
  ///
  /// In en, this message translates to:
  /// **'Artifacts'**
  String get dialsLabelArtifacts;

  /// No description provided for @dialsLabelGy.
  ///
  /// In en, this message translates to:
  /// **'GY'**
  String get dialsLabelGy;

  /// No description provided for @dialsLabelExile.
  ///
  /// In en, this message translates to:
  /// **'Exile'**
  String get dialsLabelExile;

  /// No description provided for @dialsAddCounterTitle.
  ///
  /// In en, this message translates to:
  /// **'Add counter'**
  String get dialsAddCounterTitle;

  /// No description provided for @dialsAddCounterBody.
  ///
  /// In en, this message translates to:
  /// **'Pick trackers for your strip (max {max}). Tap the X on a counter to remove it from the strip.'**
  String dialsAddCounterBody(int max);

  /// No description provided for @dialsSectionCommon.
  ///
  /// In en, this message translates to:
  /// **'Common'**
  String get dialsSectionCommon;

  /// No description provided for @dialsSectionTokensZones.
  ///
  /// In en, this message translates to:
  /// **'Tokens & zones'**
  String get dialsSectionTokensZones;

  /// No description provided for @dialsAllBuiltInsOnStrip.
  ///
  /// In en, this message translates to:
  /// **'Every built-in counter is already on your strip. Remove one to free a slot.'**
  String get dialsAllBuiltInsOnStrip;

  /// No description provided for @dialsAddCounterTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add counter'**
  String get dialsAddCounterTooltip;

  /// No description provided for @dialsRemoveFromStrip.
  ///
  /// In en, this message translates to:
  /// **'Remove from strip'**
  String get dialsRemoveFromStrip;

  /// No description provided for @hubGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick tour'**
  String get hubGuideTitle;

  /// No description provided for @hubGuideSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get hubGuideSkip;

  /// No description provided for @hubGuideNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get hubGuideNext;

  /// No description provided for @hubGuideGotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get hubGuideGotIt;

  /// No description provided for @hubGuideSlidePlayTitle.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get hubGuideSlidePlayTitle;

  /// No description provided for @hubGuideSlidePlayBody.
  ///
  /// In en, this message translates to:
  /// **'Track life and counters here. End turn sits under the phase bar — or leave Phase tracker off in the lobby for a large End turn control.'**
  String get hubGuideSlidePlayBody;

  /// No description provided for @hubGuideSlideStackTitle.
  ///
  /// In en, this message translates to:
  /// **'Stack & Lookup'**
  String get hubGuideSlideStackTitle;

  /// No description provided for @hubGuideSlideStackBody.
  ///
  /// In en, this message translates to:
  /// **'Stack is for Hold Priority and resolving effects. Lookup opens Scryfall without leaving your seat — oracle text and rulings.'**
  String get hubGuideSlideStackBody;

  /// No description provided for @hubGuideSlideTableTitle.
  ///
  /// In en, this message translates to:
  /// **'Table overview'**
  String get hubGuideSlideTableTitle;

  /// No description provided for @hubGuideSlideTableBody.
  ///
  /// In en, this message translates to:
  /// **'Open Table for the whole pod. Tools has dice and coin flips that everyone sees; History is in the header. End turn stays pinned; Forfeit sits below it.'**
  String get hubGuideSlideTableBody;

  /// No description provided for @hubGuideSlideCommanderTitle.
  ///
  /// In en, this message translates to:
  /// **'Your turn & commander'**
  String get hubGuideSlideCommanderTitle;

  /// No description provided for @hubGuideSlideCommanderBody.
  ///
  /// In en, this message translates to:
  /// **'When the seat becomes yours, tap the Your turn cue to dismiss it. The heart tracks commander damage toward 21.'**
  String get hubGuideSlideCommanderBody;

  /// No description provided for @lifeA11yEliminatedAt.
  ///
  /// In en, this message translates to:
  /// **'Eliminated at {life} life'**
  String lifeA11yEliminatedAt(String life);

  /// No description provided for @lifeA11yLifeTotal.
  ///
  /// In en, this message translates to:
  /// **'{life} life total'**
  String lifeA11yLifeTotal(String life);

  /// No description provided for @lifeA11yDecrease.
  ///
  /// In en, this message translates to:
  /// **'Decrease life'**
  String get lifeA11yDecrease;

  /// No description provided for @lifeA11yIncrease.
  ///
  /// In en, this message translates to:
  /// **'Increase life'**
  String get lifeA11yIncrease;

  /// No description provided for @lifeSetTotalTitle.
  ///
  /// In en, this message translates to:
  /// **'Set Life Total'**
  String get lifeSetTotalTitle;

  /// No description provided for @glanceOpenTableA11y.
  ///
  /// In en, this message translates to:
  /// **'Open table overview, turn order'**
  String get glanceOpenTableA11y;

  /// No description provided for @glanceYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get glanceYou;

  /// No description provided for @phasePickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Select phase'**
  String get phasePickerTitle;

  /// No description provided for @phasePickerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Scroll and tap a phase, or use Set phase for the highlighted step.'**
  String get phasePickerSubtitle;

  /// No description provided for @phasePickerSetPhase.
  ///
  /// In en, this message translates to:
  /// **'Set {phase}'**
  String phasePickerSetPhase(String phase);

  /// No description provided for @whisperPresetTeamUp.
  ///
  /// In en, this message translates to:
  /// **'Team up?'**
  String get whisperPresetTeamUp;

  /// No description provided for @whisperPresetDontAttack.
  ///
  /// In en, this message translates to:
  /// **'Don\'t attack me'**
  String get whisperPresetDontAttack;

  /// No description provided for @whisperPresetHaveRemoval.
  ///
  /// In en, this message translates to:
  /// **'I have removal'**
  String get whisperPresetHaveRemoval;

  /// No description provided for @whisperPresetAllGood.
  ///
  /// In en, this message translates to:
  /// **'All good'**
  String get whisperPresetAllGood;

  /// No description provided for @whisperSentSnack.
  ///
  /// In en, this message translates to:
  /// **'Whisper sent to {username}'**
  String whisperSentSnack(String username);

  /// No description provided for @whisperSendFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not send — wait a moment or check your connection.'**
  String get whisperSendFailed;

  /// No description provided for @whisperSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Whisper to {username}'**
  String whisperSheetTitle(String username);

  /// No description provided for @whisperSheetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Only they see this — it fades away. Not saved to match history.'**
  String get whisperSheetSubtitle;

  /// No description provided for @whisperCustomLabel.
  ///
  /// In en, this message translates to:
  /// **'Custom message'**
  String get whisperCustomLabel;

  /// No description provided for @whisperCustomHint.
  ///
  /// In en, this message translates to:
  /// **'Short note…'**
  String get whisperCustomHint;

  /// No description provided for @whisperSend.
  ///
  /// In en, this message translates to:
  /// **'Send whisper'**
  String get whisperSend;

  /// No description provided for @whisperOverlayA11y.
  ///
  /// In en, this message translates to:
  /// **'Whisper from {username}: {text}'**
  String whisperOverlayA11y(String username, String text);

  /// No description provided for @whisperOverlayHeader.
  ///
  /// In en, this message translates to:
  /// **'Whisper from {username}'**
  String whisperOverlayHeader(String username);

  /// No description provided for @politicsTapToAssignA11y.
  ///
  /// In en, this message translates to:
  /// **'Table politics. Tap to assign.'**
  String get politicsTapToAssignA11y;

  /// No description provided for @politicsStatusEmpty.
  ///
  /// In en, this message translates to:
  /// **'No monarch · No initiative · —'**
  String get politicsStatusEmpty;

  /// No description provided for @politicsDay.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get politicsDay;

  /// No description provided for @politicsNight.
  ///
  /// In en, this message translates to:
  /// **'Night'**
  String get politicsNight;

  /// No description provided for @politicsAssignSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Assign table politics'**
  String get politicsAssignSheetTitle;

  /// No description provided for @politicsMonarch.
  ///
  /// In en, this message translates to:
  /// **'Monarch'**
  String get politicsMonarch;

  /// No description provided for @politicsInitiative.
  ///
  /// In en, this message translates to:
  /// **'Initiative'**
  String get politicsInitiative;

  /// No description provided for @politicsAssignMonarch.
  ///
  /// In en, this message translates to:
  /// **'Assign Monarch'**
  String get politicsAssignMonarch;

  /// No description provided for @politicsAssignInitiative.
  ///
  /// In en, this message translates to:
  /// **'Assign Initiative'**
  String get politicsAssignInitiative;

  /// No description provided for @politicsNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get politicsNone;

  /// No description provided for @politicsDayNight.
  ///
  /// In en, this message translates to:
  /// **'Day/Night'**
  String get politicsDayNight;

  /// No description provided for @tableToolsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get tableToolsTitle;

  /// No description provided for @tableToolsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Everyone at the table sees the result.'**
  String get tableToolsSubtitle;

  /// No description provided for @tableToolsD6.
  ///
  /// In en, this message translates to:
  /// **'d6'**
  String get tableToolsD6;

  /// No description provided for @tableToolsD20.
  ///
  /// In en, this message translates to:
  /// **'d20'**
  String get tableToolsD20;

  /// No description provided for @tableToolsCoin.
  ///
  /// In en, this message translates to:
  /// **'Coin'**
  String get tableToolsCoin;

  /// No description provided for @tableToolsResultHint.
  ///
  /// In en, this message translates to:
  /// **'Result pops up for the whole table'**
  String get tableToolsResultHint;

  /// No description provided for @tableToolsRollD6.
  ///
  /// In en, this message translates to:
  /// **'Roll d6'**
  String get tableToolsRollD6;

  /// No description provided for @tableToolsRollD20.
  ///
  /// In en, this message translates to:
  /// **'Roll d20'**
  String get tableToolsRollD20;

  /// No description provided for @tableToolsFlipCoin.
  ///
  /// In en, this message translates to:
  /// **'Flip coin'**
  String get tableToolsFlipCoin;

  /// No description provided for @tableToolHeads.
  ///
  /// In en, this message translates to:
  /// **'Heads'**
  String get tableToolHeads;

  /// No description provided for @tableToolTails.
  ///
  /// In en, this message translates to:
  /// **'Tails'**
  String get tableToolTails;

  /// No description provided for @tableToolRolledHeadline.
  ///
  /// In en, this message translates to:
  /// **'{username} rolled a {result}'**
  String tableToolRolledHeadline(String username, String result);

  /// No description provided for @tableToolFlippedHeadline.
  ///
  /// In en, this message translates to:
  /// **'{username} flipped {result}'**
  String tableToolFlippedHeadline(String username, String result);

  /// No description provided for @tableToolTapToDismiss.
  ///
  /// In en, this message translates to:
  /// **'Tap to dismiss'**
  String get tableToolTapToDismiss;

  /// No description provided for @tableToolDismissA11y.
  ///
  /// In en, this message translates to:
  /// **'{headline}. Tap to dismiss.'**
  String tableToolDismissA11y(String headline);

  /// No description provided for @tableToolPlayerFallback.
  ///
  /// In en, this message translates to:
  /// **'Player'**
  String get tableToolPlayerFallback;

  /// No description provided for @variantDeckSingular.
  ///
  /// In en, this message translates to:
  /// **'Variant deck'**
  String get variantDeckSingular;

  /// No description provided for @variantDeckPlural.
  ///
  /// In en, this message translates to:
  /// **'Variant decks'**
  String get variantDeckPlural;

  /// No description provided for @variantDeckA11y.
  ///
  /// In en, this message translates to:
  /// **'{label}, tap to view'**
  String variantDeckA11y(String label);

  /// No description provided for @variantDecksSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Variant decks'**
  String get variantDecksSheetTitle;

  /// No description provided for @variantLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading variant decks…'**
  String get variantLoading;

  /// No description provided for @variantLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load decks (internet required)'**
  String get variantLoadFailed;

  /// No description provided for @variantPlanechase.
  ///
  /// In en, this message translates to:
  /// **'Planechase'**
  String get variantPlanechase;

  /// No description provided for @variantArchenemy.
  ///
  /// In en, this message translates to:
  /// **'Archenemy'**
  String get variantArchenemy;

  /// No description provided for @variantBounty.
  ///
  /// In en, this message translates to:
  /// **'Bounty'**
  String get variantBounty;

  /// No description provided for @variantNextCard.
  ///
  /// In en, this message translates to:
  /// **'Next card'**
  String get variantNextCard;

  /// No description provided for @commanderSelectNoCommanders.
  ///
  /// In en, this message translates to:
  /// **'No commanders found for \"{query}\"'**
  String commanderSelectNoCommanders(String query);

  /// No description provided for @commanderSelectNoCards.
  ///
  /// In en, this message translates to:
  /// **'No cards found for \"{query}\"'**
  String commanderSelectNoCards(String query);

  /// No description provided for @commanderSelectSearchFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to search. Check your internet connection and try again.'**
  String get commanderSelectSearchFailed;

  /// No description provided for @commanderSelectEditCommanders.
  ///
  /// In en, this message translates to:
  /// **'Edit commanders'**
  String get commanderSelectEditCommanders;

  /// No description provided for @commanderSelectEditCover.
  ///
  /// In en, this message translates to:
  /// **'Edit cover card'**
  String get commanderSelectEditCover;

  /// No description provided for @commanderSelectStep2Commander.
  ///
  /// In en, this message translates to:
  /// **'Step 2 of 2 — commander'**
  String get commanderSelectStep2Commander;

  /// No description provided for @commanderSelectStep2Cover.
  ///
  /// In en, this message translates to:
  /// **'Step 2 of 2 — cover card'**
  String get commanderSelectStep2Cover;

  /// No description provided for @commanderSelectPartnerTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Partner'**
  String get commanderSelectPartnerTitle;

  /// No description provided for @commanderSelectCommanderTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Commander'**
  String get commanderSelectCommanderTitle;

  /// No description provided for @commanderSelectCoverHint.
  ///
  /// In en, this message translates to:
  /// **'Pick any card for deck art — not your full deck list.'**
  String get commanderSelectCoverHint;

  /// No description provided for @commanderSelectSearchPartnerHint.
  ///
  /// In en, this message translates to:
  /// **'Search for partner commander…'**
  String get commanderSelectSearchPartnerHint;

  /// No description provided for @commanderSelectSearchCommanderHint.
  ///
  /// In en, this message translates to:
  /// **'Search for a commander…'**
  String get commanderSelectSearchCommanderHint;

  /// No description provided for @commanderSelectSearchCardHint.
  ///
  /// In en, this message translates to:
  /// **'Search for a card…'**
  String get commanderSelectSearchCardHint;

  /// No description provided for @commanderSelectConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get commanderSelectConfirm;

  /// No description provided for @commanderSelectScryfallCommanderHelp.
  ///
  /// In en, this message translates to:
  /// **'Type a commander name to search the Scryfall database.'**
  String get commanderSelectScryfallCommanderHelp;

  /// No description provided for @commanderSelectScryfallCardHelp.
  ///
  /// In en, this message translates to:
  /// **'Type a card name to search the Scryfall database.'**
  String get commanderSelectScryfallCardHelp;

  /// No description provided for @commanderSelectLabelCommander.
  ///
  /// In en, this message translates to:
  /// **'Commander'**
  String get commanderSelectLabelCommander;

  /// No description provided for @commanderSelectLabelPartner.
  ///
  /// In en, this message translates to:
  /// **'Partner'**
  String get commanderSelectLabelPartner;

  /// No description provided for @commanderSelectOptional.
  ///
  /// In en, this message translates to:
  /// **'optional'**
  String get commanderSelectOptional;

  /// No description provided for @deckOptionsDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete deck?'**
  String get deckOptionsDeleteTitle;

  /// No description provided for @deckOptionsDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'Remove “{name}” from your library? Match history stays, but this deck will no longer appear in the lobby picker.'**
  String deckOptionsDeleteBody(String name);

  /// No description provided for @deckOptionsDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deckOptionsDeleteConfirm;

  /// No description provided for @deckOptionsStyleNotSet.
  ///
  /// In en, this message translates to:
  /// **'Style not set'**
  String get deckOptionsStyleNotSet;

  /// No description provided for @deckOptionsEditCommanders.
  ///
  /// In en, this message translates to:
  /// **'Edit commanders'**
  String get deckOptionsEditCommanders;

  /// No description provided for @deckOptionsEditCover.
  ///
  /// In en, this message translates to:
  /// **'Edit cover card'**
  String get deckOptionsEditCover;

  /// No description provided for @deckOptionsNoGamesYet.
  ///
  /// In en, this message translates to:
  /// **'No games yet'**
  String get deckOptionsNoGamesYet;

  /// No description provided for @deckOptionsWinRate.
  ///
  /// In en, this message translates to:
  /// **'{rate}% win rate'**
  String deckOptionsWinRate(String rate);

  /// No description provided for @deckOptionsUnpin.
  ///
  /// In en, this message translates to:
  /// **'Unpin from top'**
  String get deckOptionsUnpin;

  /// No description provided for @deckOptionsPin.
  ///
  /// In en, this message translates to:
  /// **'Pin to top'**
  String get deckOptionsPin;

  /// No description provided for @deckOptionsChangeFormat.
  ///
  /// In en, this message translates to:
  /// **'Change format'**
  String get deckOptionsChangeFormat;

  /// No description provided for @deckOptionsChangeStyle.
  ///
  /// In en, this message translates to:
  /// **'Change style'**
  String get deckOptionsChangeStyle;

  /// No description provided for @deckOptionsStyleRequired.
  ///
  /// In en, this message translates to:
  /// **'Required — not set'**
  String get deckOptionsStyleRequired;

  /// No description provided for @deckOptionsRename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get deckOptionsRename;

  /// No description provided for @deckOptionsDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get deckOptionsDuplicate;

  /// No description provided for @deckOptionsDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete deck'**
  String get deckOptionsDelete;

  /// No description provided for @deckOptionsRenameTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename deck'**
  String get deckOptionsRenameTitle;

  /// No description provided for @deckOptionsNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Deck name'**
  String get deckOptionsNameLabel;

  /// No description provided for @deckOptionsNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Raffine Tempo'**
  String get deckOptionsNameHint;

  /// No description provided for @newDeckChooseStyleError.
  ///
  /// In en, this message translates to:
  /// **'Choose a deck style to continue'**
  String get newDeckChooseStyleError;

  /// No description provided for @newDeckTitle.
  ///
  /// In en, this message translates to:
  /// **'New deck'**
  String get newDeckTitle;

  /// No description provided for @newDeckSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Step 1 of 2 — details'**
  String get newDeckSubtitle;

  /// No description provided for @newDeckIntro.
  ///
  /// In en, this message translates to:
  /// **'Name your deck, pick a format and playstyle. Next you’ll choose your commander or cover card.'**
  String get newDeckIntro;

  /// No description provided for @newDeckNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Deck name'**
  String get newDeckNameLabel;

  /// No description provided for @newDeckNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Raffine Tempo'**
  String get newDeckNameHint;

  /// No description provided for @newDeckNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get newDeckNext;

  /// No description provided for @formatPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Format'**
  String get formatPickerTitle;

  /// No description provided for @formatPickerSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search formats…'**
  String get formatPickerSearchHint;

  /// No description provided for @formatPickerFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Format'**
  String get formatPickerFieldLabel;

  /// No description provided for @formatPickerMultiplayerLife.
  ///
  /// In en, this message translates to:
  /// **'Multiplayer · {life} starting life'**
  String formatPickerMultiplayerLife(String life);

  /// No description provided for @formatPickerConstructedLife.
  ///
  /// In en, this message translates to:
  /// **'Constructed · {life} starting life'**
  String formatPickerConstructedLife(String life);

  /// No description provided for @stylePickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Deck style'**
  String get stylePickerTitle;

  /// No description provided for @stylePickerSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search styles…'**
  String get stylePickerSearchHint;

  /// No description provided for @stylePickerChoose.
  ///
  /// In en, this message translates to:
  /// **'Choose deck style'**
  String get stylePickerChoose;

  /// No description provided for @stylePickerFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Deck style'**
  String get stylePickerFieldLabel;

  /// No description provided for @profileOptionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileOptionsTitle;

  /// No description provided for @profileOptionsEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get profileOptionsEdit;

  /// No description provided for @profileOptionsEditSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Change your name or avatar'**
  String get profileOptionsEditSubtitle;

  /// No description provided for @profileOptionsBackup.
  ///
  /// In en, this message translates to:
  /// **'Back up profile'**
  String get profileOptionsBackup;

  /// No description provided for @profileOptionsBackupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save profile, decks, games, and feedback on this phone'**
  String get profileOptionsBackupSubtitle;

  /// No description provided for @profilePicTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile picture'**
  String get profilePicTitle;

  /// No description provided for @profilePicNoCards.
  ///
  /// In en, this message translates to:
  /// **'No cards found for \"{query}\"'**
  String profilePicNoCards(String query);

  /// No description provided for @profilePicSearchFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to search. Check your internet connection and try again.'**
  String get profilePicSearchFailed;

  /// No description provided for @profilePicPhotoFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not use that photo. Try another image.'**
  String get profilePicPhotoFailed;

  /// No description provided for @profilePicCommander.
  ///
  /// In en, this message translates to:
  /// **'Commander'**
  String get profilePicCommander;

  /// No description provided for @profilePicDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get profilePicDefault;

  /// No description provided for @profilePicRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get profilePicRemove;

  /// No description provided for @profilePicUpload.
  ///
  /// In en, this message translates to:
  /// **'Upload photo'**
  String get profilePicUpload;

  /// No description provided for @profilePicTake.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get profilePicTake;

  /// No description provided for @profilePicOrSearch.
  ///
  /// In en, this message translates to:
  /// **'Or search MTG card art'**
  String get profilePicOrSearch;

  /// No description provided for @profilePicSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search MTG cards for profile picture…'**
  String get profilePicSearchHint;

  /// No description provided for @profilePicHelp.
  ///
  /// In en, this message translates to:
  /// **'Upload a photo, take one, or search for a card—its art becomes your profile picture.'**
  String get profilePicHelp;

  /// No description provided for @ranksInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Ranks & levels'**
  String get ranksInfoTitle;

  /// No description provided for @ranksInfoBody.
  ///
  /// In en, this message translates to:
  /// **'Level is your exact progress. Rank is the title for your current level band. Metal tiers group those ranks.'**
  String get ranksInfoBody;

  /// No description provided for @ranksInfoLevelRange.
  ///
  /// In en, this message translates to:
  /// **'Lv {min}–{max}'**
  String ranksInfoLevelRange(int min, int max);

  /// No description provided for @statsPlayerBehaviour.
  ///
  /// In en, this message translates to:
  /// **'Player behaviour'**
  String get statsPlayerBehaviour;

  /// No description provided for @statsMostPlayed.
  ///
  /// In en, this message translates to:
  /// **'Most played'**
  String get statsMostPlayed;

  /// No description provided for @statsNoDeckStatsYet.
  ///
  /// In en, this message translates to:
  /// **'No deck stats yet.'**
  String get statsNoDeckStatsYet;

  /// No description provided for @statsToughRecord.
  ///
  /// In en, this message translates to:
  /// **'Tough record'**
  String get statsToughRecord;

  /// No description provided for @statsNoLossesOnDeck.
  ///
  /// In en, this message translates to:
  /// **'No losses on a saved deck yet.'**
  String get statsNoLossesOnDeck;

  /// No description provided for @statsPlayerStats.
  ///
  /// In en, this message translates to:
  /// **'Player stats'**
  String get statsPlayerStats;

  /// No description provided for @statsSingularUnit.
  ///
  /// In en, this message translates to:
  /// **'stat'**
  String get statsSingularUnit;

  /// No description provided for @statsPluralUnit.
  ///
  /// In en, this message translates to:
  /// **'stats'**
  String get statsPluralUnit;

  /// No description provided for @statsLeaningGood.
  ///
  /// In en, this message translates to:
  /// **'leaning good'**
  String get statsLeaningGood;

  /// No description provided for @statsLeaningSalty.
  ///
  /// In en, this message translates to:
  /// **'leaning salty'**
  String get statsLeaningSalty;

  /// No description provided for @statsLeaningNeutral.
  ///
  /// In en, this message translates to:
  /// **'neutral'**
  String get statsLeaningNeutral;

  /// No description provided for @statsBehaviourA11y.
  ///
  /// In en, this message translates to:
  /// **'Behaviour spectrum, {leaning}'**
  String statsBehaviourA11y(String leaning);

  /// No description provided for @statsRecord.
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get statsRecord;

  /// No description provided for @statsWinRate.
  ///
  /// In en, this message translates to:
  /// **'Win rate'**
  String get statsWinRate;

  /// No description provided for @statsRecordFooter.
  ///
  /// In en, this message translates to:
  /// **'{wins}W–{losses}L  ·  {games} games'**
  String statsRecordFooter(int wins, int losses, int games);

  /// No description provided for @statsWinStreak.
  ///
  /// In en, this message translates to:
  /// **'Win streak'**
  String get statsWinStreak;

  /// No description provided for @statsWinToStartStreak.
  ///
  /// In en, this message translates to:
  /// **'Win to start a streak'**
  String get statsWinToStartStreak;

  /// No description provided for @statsPersonalBest.
  ///
  /// In en, this message translates to:
  /// **'Personal best'**
  String get statsPersonalBest;

  /// No description provided for @statsBestStreak.
  ///
  /// In en, this message translates to:
  /// **'Best: {best}'**
  String statsBestStreak(int best);

  /// No description provided for @statsNoActiveStreak.
  ///
  /// In en, this message translates to:
  /// **'No active streak'**
  String get statsNoActiveStreak;

  /// No description provided for @statsCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get statsCurrent;

  /// No description provided for @statsLevelShort.
  ///
  /// In en, this message translates to:
  /// **'Lv {level}'**
  String statsLevelShort(int level);

  /// No description provided for @statsLevelProgress.
  ///
  /// In en, this message translates to:
  /// **'Level progress'**
  String get statsLevelProgress;

  /// No description provided for @statsLevelProgressA11y.
  ///
  /// In en, this message translates to:
  /// **'Level progress. View all ranks.'**
  String get statsLevelProgressA11y;

  /// No description provided for @statsGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get statsGood;

  /// No description provided for @statsNeutral.
  ///
  /// In en, this message translates to:
  /// **'Neutral'**
  String get statsNeutral;

  /// No description provided for @statsSalty.
  ///
  /// In en, this message translates to:
  /// **'Salty'**
  String get statsSalty;

  /// No description provided for @profileBackupSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save backup.'**
  String get profileBackupSaveFailed;

  /// No description provided for @profileUsernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get profileUsernameLabel;

  /// No description provided for @profileUsernameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. The Archduke'**
  String get profileUsernameHint;

  /// No description provided for @profileUsernameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a username'**
  String get profileUsernameRequired;

  /// No description provided for @profileUsernameTooShort.
  ///
  /// In en, this message translates to:
  /// **'Must be at least 2 characters'**
  String get profileUsernameTooShort;

  /// No description provided for @profileSetupUsernameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. The Archduke'**
  String get profileSetupUsernameHint;

  /// No description provided for @carouselFilterTooltip.
  ///
  /// In en, this message translates to:
  /// **'Filter: {label}'**
  String carouselFilterTooltip(String label);

  /// No description provided for @carouselRecentMatchA11y.
  ///
  /// In en, this message translates to:
  /// **'Recent match, {result}, {format}'**
  String carouselRecentMatchA11y(String result, String format);

  /// No description provided for @carouselCloseReturnsSummary.
  ///
  /// In en, this message translates to:
  /// **'Close button returns to summary'**
  String get carouselCloseReturnsSummary;

  /// No description provided for @carouselShowMoreDetails.
  ///
  /// In en, this message translates to:
  /// **'Show more for full match details, or tap the card'**
  String get carouselShowMoreDetails;

  /// No description provided for @decksClearSearchTooltip.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get decksClearSearchTooltip;

  /// No description provided for @settingsDefaultFormatSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Default format'**
  String get settingsDefaultFormatSheetTitle;

  /// No description provided for @settingsDefaultStartingLifeSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Default starting life'**
  String get settingsDefaultStartingLifeSheetTitle;

  /// No description provided for @settingsAboutVersionBeta.
  ///
  /// In en, this message translates to:
  /// **'Life Spark v{version} · Beta'**
  String settingsAboutVersionBeta(String version);

  /// No description provided for @settingsAboutByAuthor.
  ///
  /// In en, this message translates to:
  /// **'by Federick Vidot'**
  String get settingsAboutByAuthor;

  /// No description provided for @settingsAboutCardDataPoweredBy.
  ///
  /// In en, this message translates to:
  /// **'Card data powered by'**
  String get settingsAboutCardDataPoweredBy;

  /// No description provided for @settingsAboutScryfall.
  ///
  /// In en, this message translates to:
  /// **'Scryfall'**
  String get settingsAboutScryfall;

  /// No description provided for @settingsAboutDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Life Spark is unofficial Fan Content permitted under the Fan Content Policy. Not approved/endorsed by Wizards. Portions of the materials used are property of Wizards of the Coast. ©Wizards of the Coast LLC.'**
  String get settingsAboutDisclaimer;

  /// No description provided for @feedbackLike.
  ///
  /// In en, this message translates to:
  /// **'Like'**
  String get feedbackLike;

  /// No description provided for @feedbackClearLike.
  ///
  /// In en, this message translates to:
  /// **'Clear like'**
  String get feedbackClearLike;

  /// No description provided for @feedbackDislike.
  ///
  /// In en, this message translates to:
  /// **'Dislike'**
  String get feedbackDislike;

  /// No description provided for @feedbackClearDislike.
  ///
  /// In en, this message translates to:
  /// **'Clear dislike'**
  String get feedbackClearDislike;

  /// No description provided for @feedbackSparkOfTheGame.
  ///
  /// In en, this message translates to:
  /// **'Spark of the game'**
  String get feedbackSparkOfTheGame;

  /// No description provided for @feedbackSparkHint.
  ///
  /// In en, this message translates to:
  /// **'Optional — pick one player'**
  String get feedbackSparkHint;

  /// No description provided for @feedbackNoneOption.
  ///
  /// In en, this message translates to:
  /// **'— None —'**
  String get feedbackNoneOption;

  /// No description provided for @tierBadgeLabel.
  ///
  /// In en, this message translates to:
  /// **'{rank} · Lv {level}'**
  String tierBadgeLabel(String rank, int level);

  /// No description provided for @tierBadgeA11y.
  ///
  /// In en, this message translates to:
  /// **'Rank {label}. View all ranks.'**
  String tierBadgeA11y(String label);

  /// No description provided for @tierBronze.
  ///
  /// In en, this message translates to:
  /// **'Bronze'**
  String get tierBronze;

  /// No description provided for @tierSilver.
  ///
  /// In en, this message translates to:
  /// **'Silver'**
  String get tierSilver;

  /// No description provided for @tierGold.
  ///
  /// In en, this message translates to:
  /// **'Gold'**
  String get tierGold;

  /// No description provided for @tierPlatinum.
  ///
  /// In en, this message translates to:
  /// **'Platinum'**
  String get tierPlatinum;

  /// No description provided for @tierDiamond.
  ///
  /// In en, this message translates to:
  /// **'Diamond'**
  String get tierDiamond;

  /// No description provided for @rankApprentice.
  ///
  /// In en, this message translates to:
  /// **'Apprentice'**
  String get rankApprentice;

  /// No description provided for @rankNeophyte.
  ///
  /// In en, this message translates to:
  /// **'Neophyte'**
  String get rankNeophyte;

  /// No description provided for @rankAdept.
  ///
  /// In en, this message translates to:
  /// **'Adept'**
  String get rankAdept;

  /// No description provided for @rankEvoker.
  ///
  /// In en, this message translates to:
  /// **'Evoker'**
  String get rankEvoker;

  /// No description provided for @rankThaumaturge.
  ///
  /// In en, this message translates to:
  /// **'Thaumaturge'**
  String get rankThaumaturge;

  /// No description provided for @rankEnchanter.
  ///
  /// In en, this message translates to:
  /// **'Enchanter'**
  String get rankEnchanter;

  /// No description provided for @rankSummoner.
  ///
  /// In en, this message translates to:
  /// **'Summoner'**
  String get rankSummoner;

  /// No description provided for @rankArcanist.
  ///
  /// In en, this message translates to:
  /// **'Arcanist'**
  String get rankArcanist;

  /// No description provided for @rankMagus.
  ///
  /// In en, this message translates to:
  /// **'Magus'**
  String get rankMagus;

  /// No description provided for @rankWarWizard.
  ///
  /// In en, this message translates to:
  /// **'War Wizard'**
  String get rankWarWizard;

  /// No description provided for @rankHighMagus.
  ///
  /// In en, this message translates to:
  /// **'High Magus'**
  String get rankHighMagus;

  /// No description provided for @rankSpellbinder.
  ///
  /// In en, this message translates to:
  /// **'Spellbinder'**
  String get rankSpellbinder;

  /// No description provided for @rankArchmage.
  ///
  /// In en, this message translates to:
  /// **'Archmage'**
  String get rankArchmage;

  /// No description provided for @rankHighArchmage.
  ///
  /// In en, this message translates to:
  /// **'High Archmage'**
  String get rankHighArchmage;

  /// No description provided for @rankPlanewright.
  ///
  /// In en, this message translates to:
  /// **'Planewright'**
  String get rankPlanewright;

  /// No description provided for @rankGrandArchmage.
  ///
  /// In en, this message translates to:
  /// **'Grand Archmage'**
  String get rankGrandArchmage;

  /// No description provided for @rankVoidcaller.
  ///
  /// In en, this message translates to:
  /// **'Voidcaller'**
  String get rankVoidcaller;

  /// No description provided for @rankArchwizard.
  ///
  /// In en, this message translates to:
  /// **'Archwizard'**
  String get rankArchwizard;

  /// No description provided for @rankSpireLegend.
  ///
  /// In en, this message translates to:
  /// **'Spire Legend'**
  String get rankSpireLegend;

  /// No description provided for @rankAscendantArchon.
  ///
  /// In en, this message translates to:
  /// **'Ascendant Archon'**
  String get rankAscendantArchon;

  /// No description provided for @deckTileWinRateAbbr.
  ///
  /// In en, this message translates to:
  /// **'WR'**
  String get deckTileWinRateAbbr;

  /// No description provided for @deckTileWinsAbbr.
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get deckTileWinsAbbr;

  /// No description provided for @deckTileLossesAbbr.
  ///
  /// In en, this message translates to:
  /// **'L'**
  String get deckTileLossesAbbr;

  /// No description provided for @deckTileGamesAbbr.
  ///
  /// In en, this message translates to:
  /// **'GP'**
  String get deckTileGamesAbbr;

  /// No description provided for @brandLifeSpark.
  ///
  /// In en, this message translates to:
  /// **'Life Spark'**
  String get brandLifeSpark;

  /// No description provided for @hostTogglePlanechase.
  ///
  /// In en, this message translates to:
  /// **'Planechase'**
  String get hostTogglePlanechase;

  /// No description provided for @hostToggleArchenemy.
  ///
  /// In en, this message translates to:
  /// **'Archenemy'**
  String get hostToggleArchenemy;

  /// No description provided for @hostToggleBounty.
  ///
  /// In en, this message translates to:
  /// **'Bounty'**
  String get hostToggleBounty;

  /// No description provided for @lookupClearTooltip.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get lookupClearTooltip;

  /// No description provided for @phaseNavCurrentA11y.
  ///
  /// In en, this message translates to:
  /// **'Current phase, {phase}'**
  String phaseNavCurrentA11y(String phase);

  /// No description provided for @cmdDmgThreatHelp.
  ///
  /// In en, this message translates to:
  /// **'Damage each commander has dealt you — {ko} eliminates.'**
  String cmdDmgThreatHelp(int ko);

  /// No description provided for @cmdDmgEmptyPod.
  ///
  /// In en, this message translates to:
  /// **'Opponents will appear here when others join the pod.'**
  String get cmdDmgEmptyPod;

  /// No description provided for @statusOut.
  ///
  /// In en, this message translates to:
  /// **'OUT'**
  String get statusOut;

  /// No description provided for @infoBarAlly.
  ///
  /// In en, this message translates to:
  /// **'Ally · {name}'**
  String infoBarAlly(String name);

  /// No description provided for @infoBarAllySecret.
  ///
  /// In en, this message translates to:
  /// **'secret'**
  String get infoBarAllySecret;

  /// No description provided for @gamePlayerDataUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Player data unavailable'**
  String get gamePlayerDataUnavailable;

  /// No description provided for @startupErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Startup Error'**
  String get startupErrorTitle;

  /// No description provided for @startupStackTrace.
  ///
  /// In en, this message translates to:
  /// **'Stack trace:'**
  String get startupStackTrace;

  /// No description provided for @paletteViolet.
  ///
  /// In en, this message translates to:
  /// **'Violet'**
  String get paletteViolet;

  /// No description provided for @paletteCrimson.
  ///
  /// In en, this message translates to:
  /// **'Crimson'**
  String get paletteCrimson;

  /// No description provided for @paletteSlate.
  ///
  /// In en, this message translates to:
  /// **'Slate'**
  String get paletteSlate;

  /// No description provided for @paletteForest.
  ///
  /// In en, this message translates to:
  /// **'Forest'**
  String get paletteForest;

  /// No description provided for @paletteObsidian.
  ///
  /// In en, this message translates to:
  /// **'Obsidian'**
  String get paletteObsidian;

  /// No description provided for @paletteFog.
  ///
  /// In en, this message translates to:
  /// **'Fog'**
  String get paletteFog;

  /// No description provided for @networkCannotReachHost.
  ///
  /// In en, this message translates to:
  /// **'Cannot reach host: {error}'**
  String networkCannotReachHost(String error);

  /// No description provided for @backupFileTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Life Spark backup'**
  String get backupFileTypeLabel;

  /// No description provided for @backupNotValidFile.
  ///
  /// In en, this message translates to:
  /// **'Not a Life Spark backup file.'**
  String get backupNotValidFile;

  /// No description provided for @backupNotValidJson.
  ///
  /// In en, this message translates to:
  /// **'Backup file is not valid JSON.'**
  String get backupNotValidJson;

  /// No description provided for @backupCouldNotRead.
  ///
  /// In en, this message translates to:
  /// **'Could not read the selected backup file.'**
  String get backupCouldNotRead;

  /// No description provided for @logLifeChange.
  ///
  /// In en, this message translates to:
  /// **'{name}: Life {delta}'**
  String logLifeChange(String name, String delta);

  /// No description provided for @logCounterChange.
  ///
  /// In en, this message translates to:
  /// **'{name}: {counter} {delta} (→ {value})'**
  String logCounterChange(
    String name,
    String counter,
    String delta,
    String value,
  );

  /// No description provided for @logCounterChangeSimple.
  ///
  /// In en, this message translates to:
  /// **'{name}: {counter} {delta}'**
  String logCounterChangeSimple(String name, String counter, String delta);

  /// No description provided for @logLifeChangedYours.
  ///
  /// In en, this message translates to:
  /// **'{name} changed your life {delta}'**
  String logLifeChangedYours(String name, String delta);

  /// No description provided for @logCounterChangedYours.
  ///
  /// In en, this message translates to:
  /// **'{name} changed your {counter} {delta}'**
  String logCounterChangedYours(String name, String counter, String delta);

  /// No description provided for @logEndsTurn.
  ///
  /// In en, this message translates to:
  /// **'{name} ends turn'**
  String logEndsTurn(String name);

  /// No description provided for @logCmdDmgDealtYou.
  ///
  /// In en, this message translates to:
  /// **'{name} dealt you {delta} commander damage'**
  String logCmdDmgDealtYou(String name, String delta);

  /// No description provided for @logCmdDmgYouDealt.
  ///
  /// In en, this message translates to:
  /// **'You dealt {name} {delta} commander damage'**
  String logCmdDmgYouDealt(String name, String delta);

  /// No description provided for @logCmdDmgOther.
  ///
  /// In en, this message translates to:
  /// **'{from} → {to}: Commander damage {delta}'**
  String logCmdDmgOther(String from, String to, String delta);

  /// No description provided for @logTurnOrderUpdated.
  ///
  /// In en, this message translates to:
  /// **'Turn order updated by host'**
  String get logTurnOrderUpdated;

  /// No description provided for @logProliferate.
  ///
  /// In en, this message translates to:
  /// **'Proliferate: all players'**
  String get logProliferate;

  /// No description provided for @logAllianceRevealed.
  ///
  /// In en, this message translates to:
  /// **'Alliance revealed: {a} & {b}'**
  String logAllianceRevealed(String a, String b);

  /// No description provided for @logAllianceBetrayal.
  ///
  /// In en, this message translates to:
  /// **'Alliance broken — betrayal: {a} & {b}'**
  String logAllianceBetrayal(String a, String b);

  /// No description provided for @logAllianceBroken.
  ///
  /// In en, this message translates to:
  /// **'Alliance broken'**
  String get logAllianceBroken;

  /// No description provided for @logAllianceFormed.
  ///
  /// In en, this message translates to:
  /// **'Secret alliance formed: {a} & {b} ({duration})'**
  String logAllianceFormed(String a, String b, String duration);

  /// No description provided for @logPlayerLeft.
  ///
  /// In en, this message translates to:
  /// **'{name} left the game'**
  String logPlayerLeft(String name);

  /// No description provided for @logRolled.
  ///
  /// In en, this message translates to:
  /// **'{name} rolled a {result}'**
  String logRolled(String name, String result);

  /// No description provided for @logFlipped.
  ///
  /// In en, this message translates to:
  /// **'{name} flipped {result}'**
  String logFlipped(String name, String result);

  /// No description provided for @logStackAdded.
  ///
  /// In en, this message translates to:
  /// **'{name} added “{item}”'**
  String logStackAdded(String name, String item);

  /// No description provided for @logStackAddedResponse.
  ///
  /// In en, this message translates to:
  /// **'{name} added “{item}” (response)'**
  String logStackAddedResponse(String name, String item);

  /// No description provided for @logStackRenamed.
  ///
  /// In en, this message translates to:
  /// **'{name} renamed stack item to “{item}”'**
  String logStackRenamed(String name, String item);

  /// No description provided for @logStackStatus.
  ///
  /// In en, this message translates to:
  /// **'{name}’s “{item}” {status}'**
  String logStackStatus(String name, String item, String status);

  /// No description provided for @logClearedStack.
  ///
  /// In en, this message translates to:
  /// **'Cleared stack'**
  String get logClearedStack;

  /// No description provided for @logCounterPoison.
  ///
  /// In en, this message translates to:
  /// **'Poison'**
  String get logCounterPoison;

  /// No description provided for @logCounterEnergy.
  ///
  /// In en, this message translates to:
  /// **'Energy'**
  String get logCounterEnergy;

  /// No description provided for @logCounterExperience.
  ///
  /// In en, this message translates to:
  /// **'Experience'**
  String get logCounterExperience;

  /// No description provided for @logCounterRad.
  ///
  /// In en, this message translates to:
  /// **'Rad'**
  String get logCounterRad;

  /// No description provided for @logCounterBlood.
  ///
  /// In en, this message translates to:
  /// **'Blood'**
  String get logCounterBlood;

  /// No description provided for @logCounterClue.
  ///
  /// In en, this message translates to:
  /// **'Clue'**
  String get logCounterClue;

  /// No description provided for @logCounterMap.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get logCounterMap;

  /// No description provided for @logCounterTreasure.
  ///
  /// In en, this message translates to:
  /// **'Treasure'**
  String get logCounterTreasure;

  /// No description provided for @logCounterDevotion.
  ///
  /// In en, this message translates to:
  /// **'Devotion'**
  String get logCounterDevotion;

  /// No description provided for @logCounterCreatures.
  ///
  /// In en, this message translates to:
  /// **'Creatures'**
  String get logCounterCreatures;

  /// No description provided for @logCounterEnchantments.
  ///
  /// In en, this message translates to:
  /// **'Enchantments'**
  String get logCounterEnchantments;

  /// No description provided for @logCounterArtifacts.
  ///
  /// In en, this message translates to:
  /// **'Artifacts'**
  String get logCounterArtifacts;

  /// No description provided for @logCounterGyCreatures.
  ///
  /// In en, this message translates to:
  /// **'GY creatures'**
  String get logCounterGyCreatures;

  /// No description provided for @logCounterExile.
  ///
  /// In en, this message translates to:
  /// **'Exile'**
  String get logCounterExile;

  /// No description provided for @logStackStatusFizzled.
  ///
  /// In en, this message translates to:
  /// **'fizzled'**
  String get logStackStatusFizzled;

  /// No description provided for @logStackStatusCountered.
  ///
  /// In en, this message translates to:
  /// **'countered'**
  String get logStackStatusCountered;

  /// No description provided for @logStackStatusResolved.
  ///
  /// In en, this message translates to:
  /// **'resolved'**
  String get logStackStatusResolved;

  /// No description provided for @logStackStatusReactivated.
  ///
  /// In en, this message translates to:
  /// **'reactivated'**
  String get logStackStatusReactivated;

  /// No description provided for @logDurationEndOfTurn.
  ///
  /// In en, this message translates to:
  /// **'Until end of turn'**
  String get logDurationEndOfTurn;

  /// No description provided for @logDurationEndOfRound.
  ///
  /// In en, this message translates to:
  /// **'Until end of round'**
  String get logDurationEndOfRound;

  /// No description provided for @logDurationUntilBroken.
  ///
  /// In en, this message translates to:
  /// **'Until broken'**
  String get logDurationUntilBroken;

  /// No description provided for @logHeads.
  ///
  /// In en, this message translates to:
  /// **'Heads'**
  String get logHeads;

  /// No description provided for @logTails.
  ///
  /// In en, this message translates to:
  /// **'Tails'**
  String get logTails;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'ja',
    'pt',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'pt':
      {
        switch (locale.countryCode) {
          case 'BR':
            return AppLocalizationsPtBr();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'ja':
      return AppLocalizationsJa();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
