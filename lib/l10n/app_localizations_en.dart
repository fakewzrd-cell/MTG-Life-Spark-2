// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Life Spark';

  @override
  String get navProfile => 'Profile';

  @override
  String get navLobby => 'Lobby';

  @override
  String get navDecks => 'Decks';

  @override
  String get navSettings => 'Settings';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSectionGameplay => 'Gameplay';

  @override
  String get settingsDefaultFormat => 'Default Format';

  @override
  String settingsDefaultFormatSubtitle(String format) {
    return '$format · used when you host';
  }

  @override
  String get settingsDefaultStartingLife => 'Default Starting Life';

  @override
  String settingsDefaultStartingLifeSubtitle(int life) {
    return '$life life · used when you host';
  }

  @override
  String get settingsSectionMisc => 'Misc';

  @override
  String get settingsKeepDisplayAwake => 'Keep display awake';

  @override
  String get settingsKeepDisplayAwakeSubtitle =>
      'Prevent screen from sleeping during a game';

  @override
  String get settingsHideSystemBars => 'Hide navigation and status bars';

  @override
  String get settingsHideSystemBarsSubtitle =>
      'Fullscreen mode during gameplay';

  @override
  String get settingsSectionAppearance => 'Appearance';

  @override
  String get settingsDarkAppearance => 'Dark appearance';

  @override
  String get settingsDarkAppearanceSubtitle =>
      'Light mode uses soft backgrounds — try Fog or Slate';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageSystem => 'System default';

  @override
  String settingsLanguageSubtitle(String language) {
    return '$language';
  }

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languagePortugueseBrazil => 'Português (Brasil)';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get languageJapanese => '日本語';

  @override
  String get settingsSectionFeel => 'Feel';

  @override
  String get settingsHapticFeedback => 'Haptic Feedback';

  @override
  String get settingsHapticFeedbackSubtitle =>
      'Vibrate on life changes and rank ups';

  @override
  String get settingsShakeToUndo => 'Shake to Undo';

  @override
  String get settingsShakeToUndoSubtitle =>
      'Shake phone to undo last life change';

  @override
  String get settingsSectionData => 'Data';

  @override
  String get settingsCacheCommanderImages => 'Cache Commander Images';

  @override
  String get settingsCacheCommanderImagesSubtitle =>
      'Store Scryfall images locally for offline use';

  @override
  String get settingsClearImageCache => 'Clear Image Cache';

  @override
  String get settingsClearImageCacheSubtitle =>
      'Free up storage from cached card images';

  @override
  String get settingsSaveBackup => 'Save backup';

  @override
  String get settingsSaveBackupSubtitle =>
      'Write profile, decks, settings, recent games, and feedback to a file';

  @override
  String get settingsRestoreBackup => 'Restore backup';

  @override
  String get settingsRestoreBackupSubtitle =>
      'Replace all local data from a .lifespark file';

  @override
  String get settingsSectionHelp => 'Help';

  @override
  String get settingsFeedback => 'Feedback';

  @override
  String get settingsFeedbackSubtitle =>
      'Send us your thoughts and suggestions';

  @override
  String get settingsViewHubGuide => 'View hub guide';

  @override
  String get settingsViewHubGuideSubtitle =>
      'How Play, Stack, Lookup, and Table work in a match';

  @override
  String get settingsViewTutorialAgain => 'View Tutorial Again';

  @override
  String get settingsViewTutorialAgainSubtitle =>
      'Re-launch the onboarding walkthrough';

  @override
  String get settingsBeta => 'Beta';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get commonAdd => 'Add';

  @override
  String get commonRemove => 'Remove';

  @override
  String get commonClose => 'Close';

  @override
  String get commonTryAgain => 'Try again';

  @override
  String get backupSaved => 'Backup saved.';

  @override
  String get backupSaveFailed => 'Could not save backup.';

  @override
  String backupRestoreTitle(String username) {
    return 'Restore $username?';
  }

  @override
  String get backupRestoreMessage =>
      'This replaces your profile, decks, settings, recent games, sparks, and behaviour on this device with the selected backup.';

  @override
  String get backupRestoreConfirm => 'Restore';

  @override
  String backupRestored(String username) {
    return 'Restored backup for $username.';
  }

  @override
  String get backupRestoreFailed =>
      'Could not restore backup. Check the file and try again.';

  @override
  String get cacheCleared => 'Image cache cleared.';

  @override
  String get cacheClearFailed => 'Could not clear image cache.';

  @override
  String get decksTitle => 'Decks';

  @override
  String get decksAddDeck => 'Add deck';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileRecentGames => 'Recent games';

  @override
  String get profileDeckPerformance => 'Deck performance';

  @override
  String get lobbyTitle => 'Lobby';

  @override
  String get lobbyHostGame => 'Host Game';

  @override
  String get lobbyHostGameSubtitle => 'Create a session — others join you';

  @override
  String get lobbyJoinGame => 'Join Game';

  @override
  String get lobbyJoinGameSubtitle => 'Scan for a nearby host';

  @override
  String get hostLobbyTitle => 'Host Lobby';

  @override
  String get hostLeaveLobbyTooltip => 'Leave lobby';

  @override
  String hostPlayersScanQr(int count, int max) {
    return 'Players: $count / $max  •  Scan QR to join';
  }

  @override
  String get hostNeedWifiRetry =>
      'Connect this device to Wi‑Fi (same network as guests), then tap Retry.';

  @override
  String get hostNeedsMobileApp =>
      'Hosting needs the mobile app (iOS or Android) on the same Wi‑Fi. The browser can join games by scanning a QR code, but cannot host.';

  @override
  String get hostNeedsMobileOrDev =>
      'Hosting needs the mobile app or a local dev build on your machine.';

  @override
  String get hostCreateProfileFirst =>
      'Create your profile first (Home → set username), then tap Retry.';

  @override
  String get hostCouldNotStartServer =>
      'Could not start the host server on this device. Tap Retry.';

  @override
  String get hostSessionDidNotStart => 'Host session did not start. Tap Retry.';

  @override
  String get hostCouldNotShowQr => 'Could not show join QR code.';

  @override
  String get hostRetry => 'Retry';

  @override
  String get hostNeedOnePlayer => 'Need at least 1 player';

  @override
  String get hostEveryoneMustBeReady => 'Everyone must be ready';

  @override
  String get hostStartGame => 'Start Game';

  @override
  String hostOpenSlots(int count) {
    return '$count open slot(s) — share your device to let friends join';
  }

  @override
  String get hostMatchLabel => 'Label';

  @override
  String get hostMatchLabelHelp =>
      'Optional. Helps you find this game in Recent games.';

  @override
  String get hostMatchLabelHint => 'e.g. Friday EDH';

  @override
  String get hostGameSettings => 'Game Settings';

  @override
  String get hostFormat => 'Format';

  @override
  String get hostStartingLife => 'Starting Life';

  @override
  String get hostCustomStartingLifeTitle => 'Custom starting life';

  @override
  String get hostCustomStartingLifeHint => 'Enter life total (1–999)';

  @override
  String get hostCustomEllipsis => 'Custom…';

  @override
  String get hostGameplay => 'Gameplay';

  @override
  String get hostToggleTeams => 'Teams';

  @override
  String get hostToggleTeamsSubtitle => 'Assign team colors on the table';

  @override
  String get hostTogglePlanechaseSubtitle =>
      'Internet required for planar deck';

  @override
  String get hostToggleArchenemySubtitle => 'Internet required for scheme deck';

  @override
  String get hostToggleBountySubtitle => 'Internet required for bounty deck';

  @override
  String get hostToggleAutoKo => 'Auto-KO';

  @override
  String get hostToggleAutoKoSubtitle =>
      'From life, poison, or commander damage';

  @override
  String get hostToggleCommanderDmgLife => 'Commander damage life loss';

  @override
  String get hostToggleCommanderDmgLifeSubtitle =>
      'Commander damage also reduces life';

  @override
  String get hostTogglePhaseTracker => 'Phase tracker';

  @override
  String get hostTogglePhaseTrackerSubtitle =>
      'Show turn phases with Back and Next';

  @override
  String get hostToggleTurnTimer => 'Turn timer';

  @override
  String get hostToggleTurnTimerSubtitle => 'Show elapsed time each turn';

  @override
  String get hostTurnLimit => 'Turn limit';

  @override
  String get hostTurnLimitOff => 'Off';

  @override
  String hostTurnLimitSeconds(int seconds) {
    return '$seconds seconds';
  }

  @override
  String get hostNoCommanderSelected => 'No commander selected';

  @override
  String get hostNoDeckSelected => 'No deck selected';

  @override
  String hostTrackingDeck(String name) {
    return 'Tracking: $name';
  }

  @override
  String get hostDeckListChanged => 'Deck (saved list changed)';

  @override
  String get hostSelectDeck => 'Deck';

  @override
  String get hostSelectCommander => 'Commander';

  @override
  String get hostMarkReady => 'Mark ready';

  @override
  String get hostMarkNotReady => 'Mark not ready';

  @override
  String get lobbyReady => 'Ready';

  @override
  String get lobbyWaiting => 'Waiting';

  @override
  String get deckPickerTitle => 'Deck for this match';

  @override
  String get deckPickerManualOnly => 'Manual commander only';

  @override
  String get deckPickerManualOnlySubtitle =>
      'Keep commanders as-is; do not attribute to a saved deck';

  @override
  String deckPickerEmptyForFormat(String format) {
    return 'No $format decks saved yet. Create one from the Decks tab.';
  }

  @override
  String get deckPickerOpenDecks => 'Open Decks';

  @override
  String get joinTitle => 'Join a Game';

  @override
  String get joinLeaveTooltip => 'Leave';

  @override
  String get joinPointCamera => 'Point the camera at the host\'s QR code';

  @override
  String get joinCameraRequiredSnack =>
      'Camera permission is required to scan the host QR code.';

  @override
  String get joinCameraDeniedBody =>
      'Camera access is needed to scan the host QR code.\\nIf you already allowed it in Settings, tap Try again.';

  @override
  String get joinOpenSettings => 'Open Settings';

  @override
  String get joinInvalidQr => 'Not a valid Life Spark QR code.';

  @override
  String get joinMissingToken =>
      'This QR code is missing a join token. Ask the host to refresh their QR.';

  @override
  String get joinCouldNotStartSession =>
      'Could not start join session. Finish profile setup and try again.';

  @override
  String get joinConnectTimeout =>
      'Timed out connecting to the host. Make sure you are on the same Wi‑Fi and the host lobby is still open, then try again.';

  @override
  String get joinHostRejected => 'Host rejected connection (version mismatch).';

  @override
  String get joinDisconnected => 'Disconnected from host.';

  @override
  String get joinConnectionError => 'Connection error.';

  @override
  String get joinHostEndedSession => 'The host ended the session.';

  @override
  String get joinConnecting => 'Connecting to host…';

  @override
  String get joinWaitingForHost => 'Waiting for host to start…';

  @override
  String get joinSelectDeck => 'Select deck';

  @override
  String get joinSelectCommander => 'Select commander';

  @override
  String get joinReady => 'Ready';

  @override
  String get joinMarkReady => 'Mark ready';

  @override
  String get welcomeTagline => 'Your MTG companion.';

  @override
  String get welcomeReadyToPlay => 'Ready to play';

  @override
  String get welcomeSkip => 'Skip';

  @override
  String get onboardingSlide1Title => 'Welcome to Life Spark';

  @override
  String get onboardingSlide1Body =>
      'Your Commander battlefield companion — life, counters, politics, and the stack, synced at the table.';

  @override
  String get onboardingSlide2Title => 'Host or Join';

  @override
  String get onboardingSlide2Body =>
      'One player hosts a game — others scan a QR code on the same Wi‑Fi network. No internet account needed. Works for 4 to 6 players at the same table.';

  @override
  String get onboardingSlide3Title => 'Track Your Life';

  @override
  String get onboardingSlide3Body =>
      'Tap +/- to change life by 1. Hold +/- for ±5. Drag left or right to adjust quickly. Double-tap the life total to set an exact number. Undo is on the bottom bar (or shake, if enabled).';

  @override
  String get onboardingSlide4Title => 'Phase Bar & Turns';

  @override
  String get onboardingSlide4Body =>
      'Use the phase bar to step through the turn, or leave Phase tracker off in the lobby. Timeout pauses the whole game.';

  @override
  String get onboardingSlide5Title => 'Commander & Counters';

  @override
  String get onboardingSlide5Body =>
      'Commander damage opens as a threat list — how much each opponent has dealt you toward 21. Track poison (10), energy, experience, and rad. Use Proliferate to add 1 to all at once.';

  @override
  String get onboardingSlide6Title => 'Alliances & Politics';

  @override
  String get onboardingSlide6Body =>
      'Propose secret alliances with other players. They expire automatically or break when you attack each other. Track the Monarch and Initiative with a single tap.';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingReadyToPlay => 'Ready to play';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get profileSetupTitle => 'Create your profile';

  @override
  String get profileSetupSubtitle =>
      'Choose a name and picture your table will recognize.';

  @override
  String get profileSetupUsername => 'Username';

  @override
  String get profileSetupUsernameRequired => 'Enter a username';

  @override
  String get profileSetupUsernameTooShort => 'Must be at least 2 characters';

  @override
  String get profileSetupChoosePicture => 'Choose profile picture';

  @override
  String get profileSetupChangePicture => 'Change picture';

  @override
  String get profileSetupContinue => 'Continue';

  @override
  String get sessionLeaveTitle => 'Leave active game?';

  @override
  String get sessionLeaveMessage =>
      'You have a lobby or game session running. Leaving will disconnect other players at the table.';

  @override
  String get sessionLeaveConfirm => 'Leave';

  @override
  String get sessionLeaveStay => 'Stay';

  @override
  String get gameLeaveTitle => 'Leave game?';

  @override
  String get gameLeaveMessageActive =>
      'You will leave the game and return home. Match stats only save when the table finishes the game.';

  @override
  String get gameLeaveMessageAfterConcede =>
      'You will leave the live game and return home. Your concede result will be saved before disconnecting.';

  @override
  String get gameTabPlay => 'Play';

  @override
  String get gameTabStack => 'Stack';

  @override
  String get gameTabLookupSemantics => 'Look up card rules';

  @override
  String get gameBarHome => 'Home';

  @override
  String get gameBarUndo => 'Undo';

  @override
  String get gameBarTimeout => 'Timeout';

  @override
  String get gameBarEnd => 'End';

  @override
  String get gameBarTable => 'Table';

  @override
  String get gameEndTurn => 'End turn';

  @override
  String gameWaitingForPlayer(String name) {
    return 'Waiting for $name…';
  }

  @override
  String get gamePhaseBack => 'Back';

  @override
  String get gamePhaseNext => 'Next';

  @override
  String get gameChoosePhase => 'Choose phase';

  @override
  String get gameYourTurn => 'Your turn';

  @override
  String get gameYourTurnTapContinue => 'Tap to continue';

  @override
  String get gameYourTurnSemantics => 'Your turn. Double tap to dismiss.';

  @override
  String get gameNowPlaying => 'NOW PLAYING';

  @override
  String get gameActiveTurn => 'ACTIVE TURN';

  @override
  String gamePlayersTurn(String name) {
    return '$name\'s turn';
  }

  @override
  String get gameCurrentTurn => 'Current turn';

  @override
  String get timeoutStartTitle => 'Start Timeout';

  @override
  String get timeout15Seconds => '15 seconds';

  @override
  String get timeout30Seconds => '30 seconds';

  @override
  String get timeout1Minute => '1 minute';

  @override
  String get timeoutBanner => 'TIMEOUT';

  @override
  String get timeoutPaused => 'Game paused — no life changes';

  @override
  String get timeoutEnd => 'End timeout';

  @override
  String timeoutMinimized(String time) {
    return 'Timeout — $time';
  }

  @override
  String get timeoutMinimizeTooltip => 'Minimize timer';

  @override
  String get reconnectToTable => 'Reconnecting to table…';

  @override
  String get reconnectStillTrying => 'Still trying to reach the table…';

  @override
  String reconnectPeerOne(String name) {
    return '$name is reconnecting…';
  }

  @override
  String reconnectPeerMany(int count) {
    return '$count players reconnecting…';
  }

  @override
  String get forfeitTitle => 'Forfeit?';

  @override
  String get forfeitBodyMulti =>
      'You will leave the game. Optionally rate opponents before you go.';

  @override
  String get forfeitBodySolo =>
      'Your practice game will end. Optionally note how it went.';

  @override
  String get forfeitRateOpponents => 'Rate opponents';

  @override
  String get forfeitConfirm => 'Forfeit';

  @override
  String get forfeitYouForfeited => 'You forfeited';

  @override
  String get forfeitStaySpectateBody =>
      'Other players can keep playing. Stay on this device to spectate until the table finishes. Returning to your profile hub now saves your concede result and disconnects from the live game.';

  @override
  String get forfeitStaySpectate => 'Stay & spectate';

  @override
  String get forfeitReturnToProfile => 'Return to profile';

  @override
  String get gamePlayerLeftTitle => 'Player left';

  @override
  String gamePlayerLeftMessage(String username) {
    return '$username left the game.';
  }

  @override
  String get gameSessionEndedTitle => 'Session ended';

  @override
  String get gameSessionEndedMessage => 'The host ended the game.';

  @override
  String gamePeerOfflineTitle(String username) {
    return '$username still offline';
  }

  @override
  String get gamePeerOfflineBody =>
      'Keep waiting for them to reconnect, or remove them from the table?';

  @override
  String get gameKeepWaiting => 'Keep waiting';

  @override
  String get gameRemoveFromTable => 'Remove from table';

  @override
  String get gameSlotLoadFailedTitle => 'Could not load your player slot';

  @override
  String get gameSlotLoadFailedBody =>
      'The game may be out of sync. Return to the lobby and rejoin.';

  @override
  String get gameReturnToLobby => 'Return to lobby';

  @override
  String get profileSetupPrompt => 'Set up your profile to continue.';

  @override
  String get profileCreateCta => 'Create profile';

  @override
  String get profileNewPlayer => 'New player';

  @override
  String profilePlayingSince(String date) {
    return 'Playing since $date';
  }

  @override
  String get profileOptions => 'Profile options';

  @override
  String get profileDoneEditing => 'Done editing';

  @override
  String get profileDone => 'Done';

  @override
  String get profileEditName => 'Edit name';

  @override
  String get profileEditNameTooltip => 'Edit name';

  @override
  String get profileChangePicture => 'Change profile picture';

  @override
  String get profileStatRecord => 'Record';

  @override
  String get profileStatSparks => 'Sparks';

  @override
  String get profileStatGames => 'Games';

  @override
  String get profileEmptyRecentGames =>
      'Play your first game to unlock stats and history.';

  @override
  String get profileEmptyDeckPerf =>
      'Add a deck to track commander performance here.';

  @override
  String get profileFilterAllGames => 'All games';

  @override
  String get profileFilterRecent14 => 'Recent (14 days)';

  @override
  String get profileFilterThisWeek => 'This week';

  @override
  String get profileFilterThisMonth => 'This month';

  @override
  String get profileNoMatchesFilter => 'No matches for this filter.';

  @override
  String get profileOpenLobbySemantics => 'Open lobby to host or join a game';

  @override
  String get profileShowMore => 'Show more';

  @override
  String get profileStandings => 'Standings';

  @override
  String get profileNoPlayerDetails =>
      'No player details saved for this match.';

  @override
  String get profileResultConcede => 'Concede';

  @override
  String get profileResultLoss => 'Loss';

  @override
  String get decksEmptyTitle => 'Build your deck library';

  @override
  String get decksEmptyBody =>
      'Save a deck with a name, format, and cover card. When you host or join a game, pick the right list in the lobby.';

  @override
  String get decksSearchHint => 'Search decks…';

  @override
  String decksNoSearchMatches(String query) {
    return 'No decks match “$query”.';
  }

  @override
  String get decksStyleNotSet => 'Style not set';

  @override
  String get decksNoCoverCard => 'No cover card';

  @override
  String get lookupTitle => 'Card lookup';

  @override
  String get lookupHint => 'Search any MTG card…';

  @override
  String get lookupHelp => 'Oracle text and official rulings from Scryfall.';

  @override
  String get lookupEmptyPrompt => 'Type a card name to look up rules.';

  @override
  String lookupNoResults(String query) {
    return 'No cards found for “$query”.';
  }

  @override
  String get lookupNetworkError =>
      'Could not reach Scryfall. Check your connection.';

  @override
  String get lookupSearch => 'Search';

  @override
  String get lookupOracleText => 'Oracle text';

  @override
  String get lookupNoOracle => 'No oracle text available for this card.';

  @override
  String get lookupRulings => 'Rulings';

  @override
  String get lookupNoRulings => 'No official rulings listed for this card.';

  @override
  String get endGameSavingResults => 'Saving match results…';

  @override
  String get endGameSaveFailedTitle => 'Could not save match results.';

  @override
  String get endGameSaveFailedBody =>
      'Your stats may not have updated. Try again.';

  @override
  String get endGameRetry => 'Retry';

  @override
  String get endGameContinueWithoutSaving => 'Continue without saving';

  @override
  String get endGameFinalStandings => 'Final Standings';

  @override
  String get endGameOverNoWinner => 'Game Over — No Winner';

  @override
  String get endGamePracticeEnded => 'Practice ended';

  @override
  String get endGameYouWin => 'You Win!';

  @override
  String get endGameWinner => 'Winner';

  @override
  String get endGameRankUp => 'RANK UP!';

  @override
  String endGameRankTransition(int oldLevel, int newLevel) {
    return 'Rank $oldLevel → $newLevel';
  }

  @override
  String endGameXpGained(int xp) {
    return '+$xp XP';
  }

  @override
  String get endGameWinBonusIncluded => 'Win bonus included';

  @override
  String get endGameParticipationXp => 'Participation XP';

  @override
  String endGameRankLevel(int level) {
    return 'Rank $level';
  }

  @override
  String get endGameFeedbackThanks =>
      'Thanks! Your feedback has been recorded.';

  @override
  String get endGameRateOpponents => 'Rate Your Opponents';

  @override
  String get endGameSubmitFeedback => 'Submit Feedback';

  @override
  String get endGameYouSuffix => '(you)';

  @override
  String get endGameElimReasonLife => 'Life depleted';

  @override
  String get endGameElimReasonPoison => '10 poison';

  @override
  String get endGameElimReasonCommanderDmg => 'Commander dmg';

  @override
  String get endGameElimReasonConcede => 'Conceded';

  @override
  String get endGameElimReasonDisconnect => 'Left game';

  @override
  String get endGameElimReasonDefault => 'Eliminated';

  @override
  String get endGameBackToHome => 'Back to Home';

  @override
  String get feedbackTitle => 'Feedback';

  @override
  String get feedbackHeadline => 'Help us improve';

  @override
  String get feedbackBody =>
      'Found a bug? Have a feature idea? We read every message.';

  @override
  String get feedbackMessageLabel => 'Your message';

  @override
  String get feedbackMessageHint => 'Tell us what you think...';

  @override
  String get feedbackSend => 'Send Feedback';

  @override
  String get feedbackOrDivider => 'or';

  @override
  String get feedbackRatePlayStore => 'Rate on Play Store';

  @override
  String get feedbackMailSubject => 'Life Spark Feedback';

  @override
  String get feedbackOpeningMail => 'Opening your mail app…';

  @override
  String feedbackNoMailAppCopied(String email) {
    return 'No mail app — message copied. Paste into an email to $email';
  }

  @override
  String feedbackClipboardFallback(String email, String message) {
    return 'To: $email\\nSubject: Life Spark Feedback\\n\\n$message';
  }

  @override
  String get stackSortOrderOnStack => 'Order on stack';

  @override
  String get stackSortByPlayer => 'By player';

  @override
  String get stackAddSpellOrAbility => 'Add spell or ability';

  @override
  String get stackHowItWorksTooltip => 'How the stack works';

  @override
  String get stackFilterResolvedCountered => 'Resolved / countered';

  @override
  String get stackApnapHint => 'Who added what (active player first)';

  @override
  String get stackClearAll => 'Clear all';

  @override
  String get stackClearConfirmTitle => 'Clear stack?';

  @override
  String get stackClearConfirmBody =>
      'Remove every spell and ability on the stack. This cannot be undone.';

  @override
  String stackActivePlayerLabel(String username) {
    return '$username · Active player';
  }

  @override
  String stackTurnOrderLabel(String username, int position) {
    return '$username · Turn order: $position';
  }

  @override
  String get stackPutOnStack => 'Put on stack';

  @override
  String get stackInResponseToEllipsis => 'In response to…';

  @override
  String get stackEmptyTitle => 'Nothing on the stack';

  @override
  String get stackEmptyBullet1 =>
      'Put spells and abilities here before they resolve.';

  @override
  String get stackEmptyBullet2 => 'The last one added resolves first.';

  @override
  String get stackAddSpell => 'Add spell';

  @override
  String get stackStatusResolved => 'Resolved';

  @override
  String get stackStatusCountered => 'Countered';

  @override
  String get stackStatusFizzled => 'Fizzled';

  @override
  String get stackYouSuffix => '(you)';

  @override
  String get stackUndoFizzle => 'Undo fizzle';

  @override
  String get stackFizzle => 'Fizzle';

  @override
  String get stackUndoFizzleSubtitle =>
      'Put this spell back on the stack as active';

  @override
  String get stackFizzleSubtitle =>
      'Target illegal or spell left the stack (rules counter)';

  @override
  String get stackMarkCountered => 'Mark countered';

  @override
  String get stackRename => 'Rename';

  @override
  String get stackOnStack => 'On stack';

  @override
  String get stackResolvesNext => 'Resolves next';

  @override
  String get stackResolvesAfterAbove => 'Resolves after items above';

  @override
  String get stackTargetNoLongerOnStack => 'Target is no longer on the stack';

  @override
  String get stackCardRulesTooltip => 'Card rules';

  @override
  String stackInResponseToNamed(String name) {
    return 'In response to $name';
  }

  @override
  String get stackResolve => 'Resolve';

  @override
  String get stackRespond => 'Respond';

  @override
  String get stackFizzledButton => 'Fizzled';

  @override
  String get stackHelpTitle => 'How the stack works';

  @override
  String get stackHelpBullet1 =>
      'When someone casts a spell or uses an ability, it goes on the stack — a waiting line before it happens.';

  @override
  String get stackHelpBullet2 =>
      'The last thing added resolves first (like a stack of plates). That is why the top entry says Resolves next.';

  @override
  String get stackHelpBullet3 =>
      'When you add a spell, search Scryfall and pick the card from the list so we store the correct name and rules text.';

  @override
  String get stackHelpBullet4 =>
      'To answer something, tap Respond or use In response to… — your spell goes on top and resolves before the one under it.';

  @override
  String get stackHelpBullet5 =>
      'When an effect finishes, tap Resolve — the card stays on the stack and turns green. To answer it, tap Respond. If a counterspell worked, Mark countered (use the Countered filter to view). If a spell lost its target, tap Fizzle — it stays greyed; tap Fizzled again to undo.';

  @override
  String get stackHelpBullet6 =>
      'At the table you still say “pass” out loud for priority; this screen helps everyone remember what is waiting and in what order.';

  @override
  String get stackHelpExample =>
      'Example: You cast a pump spell on your creature. Your opponent casts Lightning Bolt in response. Bolt resolves first, then your pump spell (if its target is still legal).';

  @override
  String get stackHelpReadMore => 'Read more on Magic.com';

  @override
  String get stackHelpCouldNotOpenLink => 'Could not open link';

  @override
  String get stackPickerIntro =>
      'Search Scryfall so we store the correct card name and rules text.';

  @override
  String get stackPickerCardNameLabel => 'Card name';

  @override
  String get stackPickerCardNameHint => 'e.g. Lightning Bolt';

  @override
  String get stackPickerClearSearch => 'Clear search';

  @override
  String get stackPickerAdd => 'Add';

  @override
  String get stackPickerNoCards => 'No cards found. Try a different spelling.';

  @override
  String get stackPickerNetworkError =>
      'Could not reach Scryfall. Check your internet connection.';

  @override
  String get stackPickerNeedSelection =>
      'Pick a card from the list, or type a name Scryfall recognizes.';

  @override
  String get stackPickerTypeToSearch => 'Type to search cards';

  @override
  String get allianceAPlayer => 'A player';

  @override
  String get allianceYourAllyFallback => 'your ally';

  @override
  String get allianceOfferDeclined => 'Secret alliance offer declined';

  @override
  String get allianceEnded => 'Secret alliance ended';

  @override
  String get allianceProposeTitle => 'Secret alliance';

  @override
  String allianceProposeSubtitle(String username) {
    return 'Invite $username — only they will know.';
  }

  @override
  String get allianceDurationSection => 'Duration';

  @override
  String get allianceDurationEndOfTurn => 'Until end of turn';

  @override
  String get allianceDurationEndOfRound => 'Until end of round';

  @override
  String get allianceDurationUntilBroken => 'Until broken';

  @override
  String get allianceWhenToDeliver => 'When to deliver';

  @override
  String get allianceDeliverNow => 'Deliver now';

  @override
  String allianceDeliverInSeconds(int seconds) {
    return 'Deliver in ${seconds}s';
  }

  @override
  String get allianceDeliverEndOfYourTurn => 'Deliver at end of your turn';

  @override
  String get allianceDeliverNextRound => 'Deliver next round';

  @override
  String allianceSecondsShort(int seconds) {
    return '${seconds}s';
  }

  @override
  String get allianceSend => 'Send';

  @override
  String allianceWhisperSent(String username) {
    return 'Whisper sent to $username';
  }

  @override
  String allianceWhisperScheduled(String username) {
    return 'Whisper scheduled for $username';
  }

  @override
  String get allianceInviteTitle => 'Secret offer';

  @override
  String allianceInviteBody(String username, String duration) {
    return '$username proposes a secret alliance.\\n\\nDuration: $duration\\n\\nOnly you can see this.';
  }

  @override
  String get allianceAccept => 'Accept';

  @override
  String get allianceDecline => 'Decline';

  @override
  String get allianceFormedTitle => 'Alliance formed';

  @override
  String allianceFormedBody(String username, String duration) {
    return 'You and $username are now secretly allied ($duration).\\n\\nThe table does not know — unless you reveal or betray.';
  }

  @override
  String allianceFormedBodyNoDuration(String username) {
    return 'You and $username are now secretly allied.\\n\\nThe table does not know — unless you reveal or betray.';
  }

  @override
  String get allianceUnderstood => 'Understood';

  @override
  String get allianceRevealedTitle => 'Alliance revealed';

  @override
  String allianceRevealedBody(String playerA, String playerB) {
    return '$playerA and $playerB have revealed their secret alliance to the table.';
  }

  @override
  String get allianceOk => 'OK';

  @override
  String get allianceBetrayalTitle => 'Betrayal!';

  @override
  String allianceBetrayalBody(String playerA, String playerB) {
    return 'The secret alliance between $playerA and $playerB has been broken by betrayal.';
  }

  @override
  String get allianceBadgeAllied => 'Allied';

  @override
  String get allianceBadgeSecretAlly => 'Secret ally';

  @override
  String allianceWhisperPending(String username) {
    return 'Whisper pending → $username';
  }

  @override
  String allianceAwaiting(String username) {
    return 'Awaiting $username';
  }

  @override
  String get cmdDmgSheetTitle => 'Commander damage';

  @override
  String get cmdDmgSheetSubtitle =>
      'Threats to you first. Open Dealt to log damage you dealt.';

  @override
  String cmdDmgBarA11y(String remaining, String ko, String taken) {
    return 'Commander damage life $remaining of $ko remaining, $taken taken on worst track, tap to manage';
  }

  @override
  String get cmdDmgLeft => 'left';

  @override
  String get cmdDmgHideDealt => 'Hide dealt';

  @override
  String cmdDmgDealtTotal(String total) {
    return 'Dealt $total';
  }

  @override
  String get cmdDmgDefaultCommander => 'Commander';

  @override
  String get cmdDmgDefaultPartner => 'Partner';

  @override
  String get cmdDmgDefaultPartnerCommander => 'Partner commander';

  @override
  String cmdDmgYouDealtTitle(String name) {
    return 'You → $name';
  }

  @override
  String get cmdDmgYouDealtSubtitle => 'Damage you dealt';

  @override
  String get cmdDmgLethalTooltip => 'Lethal commander damage!';

  @override
  String get cmdDmgIncreaseA11y => 'Increase commander damage';

  @override
  String get cmdDmgDecreaseA11y => 'Decrease commander damage';

  @override
  String get cmdBarCastCommander => 'Cast commander';

  @override
  String get cmdBarEliminated => 'Eliminated';

  @override
  String get cmdBarNoTaxYet => 'No tax yet';

  @override
  String get cmdBarRemoveLastCast => 'Remove last commander cast';

  @override
  String get cmdBarCommanderTax => 'Commander tax';

  @override
  String get cmdBarTapToRemoveLastCast => 'Tap to remove last cast';

  @override
  String cmdBarTaxPlus(int tax) {
    return 'Tax +$tax';
  }

  @override
  String get counterResetConfirmTitle => 'Reset to 0?';

  @override
  String get counterResetConfirmBody => 'Set this counter to zero.';

  @override
  String get counterResetConfirmAction => 'Reset';

  @override
  String get counterResetToZero => 'Reset to 0';

  @override
  String get counterDone => 'Done';

  @override
  String get firstPlayerRollTitle => 'Roll for First Player';

  @override
  String get firstPlayerRollSubtitle =>
      'Highest roll goes first. Tap the die to roll!';

  @override
  String get firstPlayerRollDieA11y => 'Roll die';

  @override
  String get firstPlayerRollingA11y => 'Rolling';

  @override
  String firstPlayerRolledA11y(String value) {
    return 'Rolled $value';
  }

  @override
  String get firstPlayerNotRolledA11y => 'Not rolled';

  @override
  String firstPlayerYouRolled(String value) {
    return 'You rolled $value!';
  }

  @override
  String firstPlayerYouRolledA11y(String value) {
    return 'You rolled $value';
  }

  @override
  String get firstPlayerRolling => 'Rolling…';

  @override
  String get firstPlayerTapToRoll => 'Tap to roll';

  @override
  String firstPlayerHostProgressA11y(String rolled, String total) {
    return '$rolled of $total players have rolled';
  }

  @override
  String get firstPlayerWaitingOthersA11y =>
      'Waiting for other players to roll';

  @override
  String get firstPlayerRollToContinueA11y => 'Roll die to continue';

  @override
  String firstPlayerHostProgress(String rolled, String total) {
    return '$rolled / $total players have rolled';
  }

  @override
  String get firstPlayerWaitingOthers => 'Waiting for others to roll…';

  @override
  String get firstPlayerTapDieAbove => 'Tap the die above to roll';

  @override
  String firstPlayerYouSuffix(String username) {
    return '$username (you)';
  }

  @override
  String get firstPlayerTurnOrderTitle => 'Turn Order';

  @override
  String get firstPlayerTurnOrderSubtitle =>
      'Highest roll leads — play proceeds in this order.';

  @override
  String get firstPlayerStartGame => 'Start game';

  @override
  String get firstPlayerOrdinal1 => '1st';

  @override
  String get firstPlayerOrdinal2 => '2nd';

  @override
  String get firstPlayerOrdinal3 => '3rd';

  @override
  String get firstPlayerOrdinal4 => '4th';

  @override
  String get firstPlayerOrdinal5 => '5th';

  @override
  String get firstPlayerOrdinal6 => '6th';

  @override
  String firstPlayerSlotA11y(String place, String name, String rollDetail) {
    return '$place, $name, $rollDetail';
  }

  @override
  String firstPlayerSlotYou(String username) {
    return '$username, you';
  }

  @override
  String get firstPlayerRollUnavailable => 'roll unavailable';

  @override
  String firstPlayerRolledDetail(String value) {
    return 'rolled $value';
  }

  @override
  String get firstPlayerGoesFirst => 'goes first';

  @override
  String get historyTitle => 'History';

  @override
  String get historySubtitle => 'Life, counters, and other table actions.';

  @override
  String get historyEmptyTitle => 'No actions yet';

  @override
  String get historyEmptyBody =>
      'Life changes, counters, and other table actions will show up here as the game goes on.';

  @override
  String historyTurn(String turn) {
    return 'Turn $turn';
  }

  @override
  String get overviewElimReasonLife => 'Life loss';

  @override
  String get overviewElimReasonPoison => 'Poison';

  @override
  String get overviewElimReasonCommanderDmg => 'Commander dmg';

  @override
  String get overviewElimReasonConcede => 'Conceded';

  @override
  String get overviewElimReasonDisconnect => 'Disconnected';

  @override
  String overviewRound(int round) {
    return 'Round $round';
  }

  @override
  String get overviewClose => 'Close overview';

  @override
  String get overviewTools => 'Tools';

  @override
  String get overviewHistory => 'History';

  @override
  String get overviewPlayers => 'Players';

  @override
  String get overviewHoldDragReorder => 'Hold & drag to reorder turns';

  @override
  String get overviewDecreaseLife => 'Decrease life';

  @override
  String get overviewIncreaseLife => 'Increase life';

  @override
  String overviewCommanderTaxPlus(int tax) {
    return 'Commander tax plus $tax';
  }

  @override
  String overviewTaxPlus(int tax) {
    return 'Tax +$tax';
  }

  @override
  String get overviewMonarchA11y => 'Monarch';

  @override
  String get overviewInitiativeA11y => 'Initiative';

  @override
  String get overviewNowPlaying => 'NOW PLAYING';

  @override
  String get overviewSendWhisper => 'Send whisper';

  @override
  String get overviewAssignTeamColor => 'Assign team color';

  @override
  String get overviewProposeSecretAlliance => 'Propose secret alliance';

  @override
  String get overviewRevealAlliance => 'Reveal alliance to table';

  @override
  String get overviewBreakAlliance => 'Break secret alliance';

  @override
  String get overviewAssignTeamTitle => 'Assign team';

  @override
  String get overviewTeamNone => 'None';

  @override
  String overviewTeamN(String index) {
    return 'Team $index';
  }

  @override
  String dialsStripLimitSnack(int max) {
    return 'Your strip holds up to $max counters. Remove one to add another.';
  }

  @override
  String get dialsLabelPoison => 'Poison';

  @override
  String get dialsLabelEnergy => 'Energy';

  @override
  String get dialsLabelExp => 'Exp';

  @override
  String get dialsLabelRad => 'Rad';

  @override
  String get dialsLabelBlood => 'Blood';

  @override
  String get dialsLabelClue => 'Clue';

  @override
  String get dialsLabelMap => 'Map';

  @override
  String get dialsLabelTreasure => 'Treasure';

  @override
  String get dialsLabelDevotion => 'Devotion';

  @override
  String get dialsLabelCreatures => 'Creatures';

  @override
  String get dialsLabelEnchant => 'Enchant';

  @override
  String get dialsLabelArtifacts => 'Artifacts';

  @override
  String get dialsLabelGy => 'GY';

  @override
  String get dialsLabelExile => 'Exile';

  @override
  String get dialsAddCounterTitle => 'Add counter';

  @override
  String dialsAddCounterBody(int max) {
    return 'Pick trackers for your strip (max $max). Tap the X on a counter to remove it from the strip.';
  }

  @override
  String get dialsSectionCommon => 'Common';

  @override
  String get dialsSectionTokensZones => 'Tokens & zones';

  @override
  String get dialsAllBuiltInsOnStrip =>
      'Every built-in counter is already on your strip. Remove one to free a slot.';

  @override
  String get dialsAddCounterTooltip => 'Add counter';

  @override
  String get dialsRemoveFromStrip => 'Remove from strip';

  @override
  String get hubGuideTitle => 'Quick tour';

  @override
  String get hubGuideSkip => 'Skip';

  @override
  String get hubGuideNext => 'Next';

  @override
  String get hubGuideGotIt => 'Got it';

  @override
  String get hubGuideSlidePlayTitle => 'Play';

  @override
  String get hubGuideSlidePlayBody =>
      'Track life and counters here. End turn sits under the phase bar — or leave Phase tracker off in the lobby for a large End turn control.';

  @override
  String get hubGuideSlideStackTitle => 'Stack & Lookup';

  @override
  String get hubGuideSlideStackBody =>
      'Stack is for Hold Priority and resolving effects. Lookup opens Scryfall without leaving your seat — oracle text and rulings.';

  @override
  String get hubGuideSlideTableTitle => 'Table overview';

  @override
  String get hubGuideSlideTableBody =>
      'Open Table for the whole pod. Tools has dice and coin flips that everyone sees; History is in the header. End turn stays pinned; Forfeit sits below it.';

  @override
  String get hubGuideSlideCommanderTitle => 'Your turn & commander';

  @override
  String get hubGuideSlideCommanderBody =>
      'When the seat becomes yours, tap the Your turn cue to dismiss it. The heart tracks commander damage toward 21.';

  @override
  String lifeA11yEliminatedAt(String life) {
    return 'Eliminated at $life life';
  }

  @override
  String lifeA11yLifeTotal(String life) {
    return '$life life total';
  }

  @override
  String get lifeA11yDecrease => 'Decrease life';

  @override
  String get lifeA11yIncrease => 'Increase life';

  @override
  String get lifeSetTotalTitle => 'Set Life Total';

  @override
  String get glanceOpenTableA11y => 'Open table overview, turn order';

  @override
  String get glanceYou => 'You';

  @override
  String get phasePickerTitle => 'Select phase';

  @override
  String get phasePickerSubtitle =>
      'Scroll and tap a phase, or use Set phase for the highlighted step.';

  @override
  String phasePickerSetPhase(String phase) {
    return 'Set $phase';
  }

  @override
  String get whisperPresetTeamUp => 'Team up?';

  @override
  String get whisperPresetDontAttack => 'Don\'t attack me';

  @override
  String get whisperPresetHaveRemoval => 'I have removal';

  @override
  String get whisperPresetAllGood => 'All good';

  @override
  String whisperSentSnack(String username) {
    return 'Whisper sent to $username';
  }

  @override
  String get whisperSendFailed =>
      'Could not send — wait a moment or check your connection.';

  @override
  String whisperSheetTitle(String username) {
    return 'Whisper to $username';
  }

  @override
  String get whisperSheetSubtitle =>
      'Only they see this — it fades away. Not saved to match history.';

  @override
  String get whisperCustomLabel => 'Custom message';

  @override
  String get whisperCustomHint => 'Short note…';

  @override
  String get whisperSend => 'Send whisper';

  @override
  String whisperOverlayA11y(String username, String text) {
    return 'Whisper from $username: $text';
  }

  @override
  String whisperOverlayHeader(String username) {
    return 'Whisper from $username';
  }

  @override
  String get politicsTapToAssignA11y => 'Table politics. Tap to assign.';

  @override
  String get politicsStatusEmpty => 'No monarch · No initiative · —';

  @override
  String get politicsDay => 'Day';

  @override
  String get politicsNight => 'Night';

  @override
  String get politicsAssignSheetTitle => 'Assign table politics';

  @override
  String get politicsMonarch => 'Monarch';

  @override
  String get politicsInitiative => 'Initiative';

  @override
  String get politicsAssignMonarch => 'Assign Monarch';

  @override
  String get politicsAssignInitiative => 'Assign Initiative';

  @override
  String get politicsNone => 'None';

  @override
  String get politicsDayNight => 'Day/Night';

  @override
  String get tableToolsTitle => 'Tools';

  @override
  String get tableToolsSubtitle => 'Everyone at the table sees the result.';

  @override
  String get tableToolsD6 => 'd6';

  @override
  String get tableToolsD20 => 'd20';

  @override
  String get tableToolsCoin => 'Coin';

  @override
  String get tableToolsResultHint => 'Result pops up for the whole table';

  @override
  String get tableToolsRollD6 => 'Roll d6';

  @override
  String get tableToolsRollD20 => 'Roll d20';

  @override
  String get tableToolsFlipCoin => 'Flip coin';

  @override
  String get tableToolHeads => 'Heads';

  @override
  String get tableToolTails => 'Tails';

  @override
  String tableToolRolledHeadline(String username, String result) {
    return '$username rolled a $result';
  }

  @override
  String tableToolFlippedHeadline(String username, String result) {
    return '$username flipped $result';
  }

  @override
  String get tableToolTapToDismiss => 'Tap to dismiss';

  @override
  String tableToolDismissA11y(String headline) {
    return '$headline. Tap to dismiss.';
  }

  @override
  String get tableToolPlayerFallback => 'Player';

  @override
  String get variantDeckSingular => 'Variant deck';

  @override
  String get variantDeckPlural => 'Variant decks';

  @override
  String variantDeckA11y(String label) {
    return '$label, tap to view';
  }

  @override
  String get variantDecksSheetTitle => 'Variant decks';

  @override
  String get variantLoading => 'Loading variant decks…';

  @override
  String get variantLoadFailed => 'Could not load decks (internet required)';

  @override
  String get variantPlanechase => 'Planechase';

  @override
  String get variantArchenemy => 'Archenemy';

  @override
  String get variantBounty => 'Bounty';

  @override
  String get variantNextCard => 'Next card';

  @override
  String commanderSelectNoCommanders(String query) {
    return 'No commanders found for \"$query\"';
  }

  @override
  String commanderSelectNoCards(String query) {
    return 'No cards found for \"$query\"';
  }

  @override
  String get commanderSelectSearchFailed =>
      'Unable to search. Check your internet connection and try again.';

  @override
  String get commanderSelectEditCommanders => 'Edit commanders';

  @override
  String get commanderSelectEditCover => 'Edit cover card';

  @override
  String get commanderSelectStep2Commander => 'Step 2 of 2 — commander';

  @override
  String get commanderSelectStep2Cover => 'Step 2 of 2 — cover card';

  @override
  String get commanderSelectPartnerTitle => 'Select Partner';

  @override
  String get commanderSelectCommanderTitle => 'Select Commander';

  @override
  String get commanderSelectCoverHint =>
      'Pick any card for deck art — not your full deck list.';

  @override
  String get commanderSelectSearchPartnerHint =>
      'Search for partner commander…';

  @override
  String get commanderSelectSearchCommanderHint => 'Search for a commander…';

  @override
  String get commanderSelectSearchCardHint => 'Search for a card…';

  @override
  String get commanderSelectConfirm => 'Confirm';

  @override
  String get commanderSelectScryfallCommanderHelp =>
      'Type a commander name to search the Scryfall database.';

  @override
  String get commanderSelectScryfallCardHelp =>
      'Type a card name to search the Scryfall database.';

  @override
  String get commanderSelectLabelCommander => 'Commander';

  @override
  String get commanderSelectLabelPartner => 'Partner';

  @override
  String get commanderSelectOptional => 'optional';

  @override
  String get deckOptionsDeleteTitle => 'Delete deck?';

  @override
  String deckOptionsDeleteBody(String name) {
    return 'Remove “$name” from your library? Match history stays, but this deck will no longer appear in the lobby picker.';
  }

  @override
  String get deckOptionsDeleteConfirm => 'Delete';

  @override
  String get deckOptionsStyleNotSet => 'Style not set';

  @override
  String get deckOptionsEditCommanders => 'Edit commanders';

  @override
  String get deckOptionsEditCover => 'Edit cover card';

  @override
  String get deckOptionsNoGamesYet => 'No games yet';

  @override
  String deckOptionsWinRate(String rate) {
    return '$rate% win rate';
  }

  @override
  String get deckOptionsUnpin => 'Unpin from top';

  @override
  String get deckOptionsPin => 'Pin to top';

  @override
  String get deckOptionsChangeFormat => 'Change format';

  @override
  String get deckOptionsChangeStyle => 'Change style';

  @override
  String get deckOptionsStyleRequired => 'Required — not set';

  @override
  String get deckOptionsRename => 'Rename';

  @override
  String get deckOptionsDuplicate => 'Duplicate';

  @override
  String get deckOptionsDelete => 'Delete deck';

  @override
  String get deckOptionsRenameTitle => 'Rename deck';

  @override
  String get deckOptionsNameLabel => 'Deck name';

  @override
  String get deckOptionsNameHint => 'e.g. Raffine Tempo';

  @override
  String get newDeckChooseStyleError => 'Choose a deck style to continue';

  @override
  String get newDeckTitle => 'New deck';

  @override
  String get newDeckSubtitle => 'Step 1 of 2 — details';

  @override
  String get newDeckIntro =>
      'Name your deck, pick a format and playstyle. Next you’ll choose your commander or cover card.';

  @override
  String get newDeckNameLabel => 'Deck name';

  @override
  String get newDeckNameHint => 'e.g. Raffine Tempo';

  @override
  String get newDeckNext => 'Next';

  @override
  String get formatPickerTitle => 'Format';

  @override
  String get formatPickerSearchHint => 'Search formats…';

  @override
  String get formatPickerFieldLabel => 'Format';

  @override
  String formatPickerMultiplayerLife(String life) {
    return 'Multiplayer · $life starting life';
  }

  @override
  String formatPickerConstructedLife(String life) {
    return 'Constructed · $life starting life';
  }

  @override
  String get stylePickerTitle => 'Deck style';

  @override
  String get stylePickerSearchHint => 'Search styles…';

  @override
  String get stylePickerChoose => 'Choose deck style';

  @override
  String get stylePickerFieldLabel => 'Deck style';

  @override
  String get deckStyleBattlecruiser => 'Battlecruiser';

  @override
  String get deckStyleBattlecruiserDesc =>
      'Large creatures and face damage; light interaction, often newer-player tables.';

  @override
  String get deckStyleStax => 'Stax';

  @override
  String get deckStyleStaxDesc =>
      'Slows or stops opponents, then wins while others cannot respond.';

  @override
  String get deckStyleSpellslinger => 'Spellslinger';

  @override
  String get deckStyleSpellslingerDesc =>
      'Mostly instants and sorceries; storm-style copy effects for burst wins.';

  @override
  String get deckStyleControl => 'Control';

  @override
  String get deckStyleControlDesc =>
      'Answers and board management until the game is fully under control.';

  @override
  String get deckStylePillowfort => 'Pillowfort';

  @override
  String get deckStylePillowfortDesc =>
      'Taxes and deterrents that make attacking you costly; alt win conditions.';

  @override
  String get deckStyleVoltron => 'Voltron';

  @override
  String get deckStyleVoltronDesc =>
      'Stacks equipment and auras on one protected commander threat.';

  @override
  String get deckStyleGroupHug => 'Group Hug';

  @override
  String get deckStyleGroupHugDesc =>
      'Table-wide small bonuses that still set up a hidden win line.';

  @override
  String get deckStyleGroupSlug => 'Group Slug';

  @override
  String get deckStyleGroupSlugDesc =>
      'Equal life loss or discard for everyone until the table is drained.';

  @override
  String get deckStyleReanimator => 'Reanimator';

  @override
  String get deckStyleReanimatorDesc =>
      'Fills the graveyard, then cheats huge creatures back cheaply.';

  @override
  String get deckStyleMill => 'Mill';

  @override
  String get deckStyleMillDesc =>
      'Empties libraries into exile or graveyard for the draw-loss win.';

  @override
  String get deckStyleStealTheft => 'Steal / Theft';

  @override
  String get deckStyleStealTheftDesc =>
      'Takes opponents\' permanents and rides the strongest thing at the table.';

  @override
  String get deckStyleTribal => 'Tribal';

  @override
  String get deckStyleTribalDesc =>
      'Creature type synergy with lords and shared tribal payoffs.';

  @override
  String get deckStyleSliver => 'Sliver';

  @override
  String get deckStyleSliverDesc =>
      'Sliver hive that buffs every other sliver on the board.';

  @override
  String get deckStyleTokens => 'Tokens';

  @override
  String get deckStyleTokensDesc =>
      'Mass token generation plus anthems for sudden combat kills.';

  @override
  String get deckStyleAristocrats => 'Aristocrats';

  @override
  String get deckStyleAristocratsDesc =>
      'Sacrifice loops with death and ETB triggers plus recursion.';

  @override
  String get deckStyleWeenie => 'Weenie';

  @override
  String get deckStyleWeenieDesc =>
      'Many small creatures that buff each other for wide attacks.';

  @override
  String get deckStyleLands => 'Lands';

  @override
  String get deckStyleLandsDesc =>
      'Landfall and land-centric engines; hard to interact with.';

  @override
  String get deckStyleSuperfriends => 'Superfriends';

  @override
  String get deckStyleSuperfriendsDesc =>
      'Planeswalker chains with extra loyalty and activations.';

  @override
  String get deckStyleArtifact => 'Artifact';

  @override
  String get deckStyleArtifactDesc =>
      'Artifact synergies and machines, often with blue support.';

  @override
  String get deckStyleInfect => 'Infect';

  @override
  String get deckStyleInfectDesc =>
      'Poison counters instead of life; strong in small pods.';

  @override
  String get deckStyleCounters => 'Counters';

  @override
  String get deckStyleCountersDesc =>
      '+1/+1 counter payoffs and counter-matters abilities.';

  @override
  String get deckStyleChaos => 'Chaos';

  @override
  String get deckStyleChaosDesc =>
      'Random or disruptive effects that warp normal game plans.';

  @override
  String get deckStylePolitical => 'Political';

  @override
  String get deckStylePoliticalDesc =>
      'Votes, deals, and table politics to steer outcomes.';

  @override
  String get profileOptionsTitle => 'Profile';

  @override
  String get profileOptionsEdit => 'Edit profile';

  @override
  String get profileOptionsEditSubtitle => 'Change your name or avatar';

  @override
  String get profileOptionsBackup => 'Back up profile';

  @override
  String get profileOptionsBackupSubtitle =>
      'Save profile, decks, games, and feedback on this phone';

  @override
  String get profilePicTitle => 'Profile picture';

  @override
  String profilePicNoCards(String query) {
    return 'No cards found for \"$query\"';
  }

  @override
  String get profilePicSearchFailed =>
      'Unable to search. Check your internet connection and try again.';

  @override
  String get profilePicPhotoFailed =>
      'Could not use that photo. Try another image.';

  @override
  String get profilePicCommander => 'Commander';

  @override
  String get profilePicDefault => 'Default';

  @override
  String get profilePicRemove => 'Remove';

  @override
  String get profilePicUpload => 'Upload photo';

  @override
  String get profilePicTake => 'Take photo';

  @override
  String get profilePicOrSearch => 'Or search MTG card art';

  @override
  String get profilePicSearchHint => 'Search MTG cards for profile picture…';

  @override
  String get profilePicHelp =>
      'Upload a photo, take one, or search for a card—its art becomes your profile picture.';

  @override
  String get ranksInfoTitle => 'Ranks & levels';

  @override
  String get ranksInfoBody =>
      'Level is your exact progress. Rank is the title for your current level band. Metal tiers group those ranks.';

  @override
  String ranksInfoLevelRange(int min, int max) {
    return 'Lv $min–$max';
  }

  @override
  String get statsPlayerBehaviour => 'Player behaviour';

  @override
  String get statsMostPlayed => 'Most played';

  @override
  String get statsNoDeckStatsYet => 'No deck stats yet.';

  @override
  String get statsToughRecord => 'Tough record';

  @override
  String get statsNoLossesOnDeck => 'No losses on a saved deck yet.';

  @override
  String get statsPlayerStats => 'Player stats';

  @override
  String get statsSingularUnit => 'stat';

  @override
  String get statsPluralUnit => 'stats';

  @override
  String get statsLeaningGood => 'leaning good';

  @override
  String get statsLeaningSalty => 'leaning salty';

  @override
  String get statsLeaningNeutral => 'neutral';

  @override
  String statsBehaviourA11y(String leaning) {
    return 'Behaviour spectrum, $leaning';
  }

  @override
  String get statsRecord => 'Record';

  @override
  String get statsWinRate => 'Win rate';

  @override
  String statsRecordFooter(int wins, int losses, int games) {
    return '${wins}W–${losses}L  ·  $games games';
  }

  @override
  String get statsWinStreak => 'Win streak';

  @override
  String get statsWinToStartStreak => 'Win to start a streak';

  @override
  String get statsPersonalBest => 'Personal best';

  @override
  String statsBestStreak(int best) {
    return 'Best: $best';
  }

  @override
  String get statsNoActiveStreak => 'No active streak';

  @override
  String get statsCurrent => 'Current';

  @override
  String statsLevelShort(int level) {
    return 'Lv $level';
  }

  @override
  String get statsLevelProgress => 'Level progress';

  @override
  String get statsLevelProgressA11y => 'Level progress. View all ranks.';

  @override
  String get statsGood => 'Good';

  @override
  String get statsNeutral => 'Neutral';

  @override
  String get statsSalty => 'Salty';

  @override
  String get profileBackupSaveFailed => 'Could not save backup.';

  @override
  String get profileUsernameLabel => 'Username';

  @override
  String get profileUsernameHint => 'e.g. The Archduke';

  @override
  String get profileUsernameRequired => 'Enter a username';

  @override
  String get profileUsernameTooShort => 'Must be at least 2 characters';

  @override
  String get profileSetupUsernameHint => 'e.g. The Archduke';

  @override
  String carouselFilterTooltip(String label) {
    return 'Filter: $label';
  }

  @override
  String carouselRecentMatchA11y(String result, String format) {
    return 'Recent match, $result, $format';
  }

  @override
  String get carouselCloseReturnsSummary => 'Close button returns to summary';

  @override
  String get carouselShowMoreDetails =>
      'Show more for full match details, or tap the card';

  @override
  String get decksClearSearchTooltip => 'Clear';

  @override
  String get settingsDefaultFormatSheetTitle => 'Default format';

  @override
  String get settingsDefaultStartingLifeSheetTitle => 'Default starting life';

  @override
  String settingsAboutVersionBeta(String version) {
    return 'Life Spark v$version · Beta';
  }

  @override
  String get settingsAboutByAuthor => 'by Federick Vidot';

  @override
  String get settingsAboutCardDataPoweredBy => 'Card data powered by';

  @override
  String get settingsAboutScryfall => 'Scryfall';

  @override
  String get settingsAboutDisclaimer =>
      'Life Spark is unofficial Fan Content permitted under the Fan Content Policy. Not approved/endorsed by Wizards. Portions of the materials used are property of Wizards of the Coast. ©Wizards of the Coast LLC.';

  @override
  String get feedbackLike => 'Like';

  @override
  String get feedbackClearLike => 'Clear like';

  @override
  String get feedbackDislike => 'Dislike';

  @override
  String get feedbackClearDislike => 'Clear dislike';

  @override
  String get feedbackSparkOfTheGame => 'Spark of the game';

  @override
  String get feedbackSparkHint => 'Optional — pick one player';

  @override
  String get feedbackNoneOption => '— None —';

  @override
  String tierBadgeLabel(String rank, int level) {
    return '$rank · Lv $level';
  }

  @override
  String tierBadgeA11y(String label) {
    return 'Rank $label. View all ranks.';
  }

  @override
  String get tierBronze => 'Bronze';

  @override
  String get tierSilver => 'Silver';

  @override
  String get tierGold => 'Gold';

  @override
  String get tierPlatinum => 'Platinum';

  @override
  String get tierDiamond => 'Diamond';

  @override
  String get rankApprentice => 'Apprentice';

  @override
  String get rankNeophyte => 'Neophyte';

  @override
  String get rankAdept => 'Adept';

  @override
  String get rankEvoker => 'Evoker';

  @override
  String get rankThaumaturge => 'Thaumaturge';

  @override
  String get rankEnchanter => 'Enchanter';

  @override
  String get rankSummoner => 'Summoner';

  @override
  String get rankArcanist => 'Arcanist';

  @override
  String get rankMagus => 'Magus';

  @override
  String get rankWarWizard => 'War Wizard';

  @override
  String get rankHighMagus => 'High Magus';

  @override
  String get rankSpellbinder => 'Spellbinder';

  @override
  String get rankArchmage => 'Archmage';

  @override
  String get rankHighArchmage => 'High Archmage';

  @override
  String get rankPlanewright => 'Planewright';

  @override
  String get rankGrandArchmage => 'Grand Archmage';

  @override
  String get rankVoidcaller => 'Voidcaller';

  @override
  String get rankArchwizard => 'Archwizard';

  @override
  String get rankSpireLegend => 'Spire Legend';

  @override
  String get rankAscendantArchon => 'Ascendant Archon';

  @override
  String get deckTileWinRateAbbr => 'WR';

  @override
  String get deckTileWinsAbbr => 'W';

  @override
  String get deckTileLossesAbbr => 'L';

  @override
  String get deckTileGamesAbbr => 'GP';

  @override
  String get brandLifeSpark => 'Life Spark';

  @override
  String get hostTogglePlanechase => 'Planechase';

  @override
  String get hostToggleArchenemy => 'Archenemy';

  @override
  String get hostToggleBounty => 'Bounty';

  @override
  String get lookupClearTooltip => 'Clear';

  @override
  String phaseNavCurrentA11y(String phase) {
    return 'Current phase, $phase';
  }

  @override
  String cmdDmgThreatHelp(int ko) {
    return 'Damage each commander has dealt you — $ko eliminates.';
  }

  @override
  String get cmdDmgEmptyPod =>
      'Opponents will appear here when others join the pod.';

  @override
  String get statusOut => 'OUT';

  @override
  String infoBarAlly(String name) {
    return 'Ally · $name';
  }

  @override
  String get infoBarAllySecret => 'secret';

  @override
  String get gamePlayerDataUnavailable => 'Player data unavailable';

  @override
  String get startupErrorTitle => 'Startup Error';

  @override
  String get startupStackTrace => 'Stack trace:';

  @override
  String get paletteViolet => 'Violet';

  @override
  String get paletteCrimson => 'Crimson';

  @override
  String get paletteSlate => 'Slate';

  @override
  String get paletteForest => 'Forest';

  @override
  String get paletteObsidian => 'Obsidian';

  @override
  String get paletteFog => 'Fog';

  @override
  String networkCannotReachHost(String error) {
    return 'Cannot reach host: $error';
  }

  @override
  String get backupFileTypeLabel => 'Life Spark backup';

  @override
  String get backupNotValidFile => 'Not a Life Spark backup file.';

  @override
  String get backupNotValidJson => 'Backup file is not valid JSON.';

  @override
  String get backupCouldNotRead => 'Could not read the selected backup file.';

  @override
  String logLifeChange(String name, String delta) {
    return '$name: Life $delta';
  }

  @override
  String logCounterChange(
    String name,
    String counter,
    String delta,
    String value,
  ) {
    return '$name: $counter $delta (→ $value)';
  }

  @override
  String logCounterChangeSimple(String name, String counter, String delta) {
    return '$name: $counter $delta';
  }

  @override
  String logLifeChangedYours(String name, String delta) {
    return '$name changed your life $delta';
  }

  @override
  String logCounterChangedYours(String name, String counter, String delta) {
    return '$name changed your $counter $delta';
  }

  @override
  String logEndsTurn(String name) {
    return '$name ends turn';
  }

  @override
  String logCmdDmgDealtYou(String name, String delta) {
    return '$name dealt you $delta commander damage';
  }

  @override
  String logCmdDmgYouDealt(String name, String delta) {
    return 'You dealt $name $delta commander damage';
  }

  @override
  String logCmdDmgOther(String from, String to, String delta) {
    return '$from → $to: Commander damage $delta';
  }

  @override
  String get logTurnOrderUpdated => 'Turn order updated by host';

  @override
  String get logProliferate => 'Proliferate: all players';

  @override
  String logAllianceRevealed(String a, String b) {
    return 'Alliance revealed: $a & $b';
  }

  @override
  String logAllianceBetrayal(String a, String b) {
    return 'Alliance broken — betrayal: $a & $b';
  }

  @override
  String get logAllianceBroken => 'Alliance broken';

  @override
  String logAllianceFormed(String a, String b, String duration) {
    return 'Secret alliance formed: $a & $b ($duration)';
  }

  @override
  String logPlayerLeft(String name) {
    return '$name left the game';
  }

  @override
  String logRolled(String name, String result) {
    return '$name rolled a $result';
  }

  @override
  String logFlipped(String name, String result) {
    return '$name flipped $result';
  }

  @override
  String logStackAdded(String name, String item) {
    return '$name added “$item”';
  }

  @override
  String logStackAddedResponse(String name, String item) {
    return '$name added “$item” (response)';
  }

  @override
  String logStackRenamed(String name, String item) {
    return '$name renamed stack item to “$item”';
  }

  @override
  String logStackStatus(String name, String item, String status) {
    return '$name’s “$item” $status';
  }

  @override
  String get logClearedStack => 'Cleared stack';

  @override
  String get logCounterPoison => 'Poison';

  @override
  String get logCounterEnergy => 'Energy';

  @override
  String get logCounterExperience => 'Experience';

  @override
  String get logCounterRad => 'Rad';

  @override
  String get logCounterBlood => 'Blood';

  @override
  String get logCounterClue => 'Clue';

  @override
  String get logCounterMap => 'Map';

  @override
  String get logCounterTreasure => 'Treasure';

  @override
  String get logCounterDevotion => 'Devotion';

  @override
  String get logCounterCreatures => 'Creatures';

  @override
  String get logCounterEnchantments => 'Enchantments';

  @override
  String get logCounterArtifacts => 'Artifacts';

  @override
  String get logCounterGyCreatures => 'GY creatures';

  @override
  String get logCounterExile => 'Exile';

  @override
  String get logStackStatusFizzled => 'fizzled';

  @override
  String get logStackStatusCountered => 'countered';

  @override
  String get logStackStatusResolved => 'resolved';

  @override
  String get logStackStatusReactivated => 'reactivated';

  @override
  String get logDurationEndOfTurn => 'Until end of turn';

  @override
  String get logDurationEndOfRound => 'Until end of round';

  @override
  String get logDurationUntilBroken => 'Until broken';

  @override
  String get logHeads => 'Heads';

  @override
  String get logTails => 'Tails';
}
