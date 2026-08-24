// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Life Spark';

  @override
  String get navProfile => 'Profil';

  @override
  String get navLobby => 'Lobby';

  @override
  String get navDecks => 'Decks';

  @override
  String get navSettings => 'Einstellungen';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get settingsSectionGameplay => 'Spiel';

  @override
  String get settingsDefaultFormat => 'Standardformat';

  @override
  String settingsDefaultFormatSubtitle(String format) {
    return '$format · wird beim Hosten verwendet';
  }

  @override
  String get settingsDefaultStartingLife => 'Standard-Startleben';

  @override
  String settingsDefaultStartingLifeSubtitle(int life) {
    return '$life Leben · wird beim Hosten verwendet';
  }

  @override
  String get settingsSectionMisc => 'Sonstiges';

  @override
  String get settingsKeepDisplayAwake => 'Display wach halten';

  @override
  String get settingsKeepDisplayAwakeSubtitle =>
      'Verhindert den Ruhezustand während eines Spiels';

  @override
  String get settingsHideSystemBars =>
      'Navigations- und Statusleiste ausblenden';

  @override
  String get settingsHideSystemBarsSubtitle =>
      'Vollbildmodus während des Spiels';

  @override
  String get settingsSectionAppearance => 'Erscheinungsbild';

  @override
  String get settingsDarkAppearance => 'Dunkles Erscheinungsbild';

  @override
  String get settingsDarkAppearanceSubtitle =>
      'Der helle Modus nutzt weiche Hintergründe — probiere Fog oder Slate';

  @override
  String get settingsLanguage => 'Sprache';

  @override
  String get settingsLanguageSystem => 'Systemstandard';

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
  String get settingsSectionFeel => 'Haptik';

  @override
  String get settingsHapticFeedback => 'Haptisches Feedback';

  @override
  String get settingsHapticFeedbackSubtitle =>
      'Vibrieren bei Lebensänderungen und Rangaufstiegen';

  @override
  String get settingsShakeToUndo => 'Schütteln zum Rückgängigmachen';

  @override
  String get settingsShakeToUndoSubtitle =>
      'Telefon schütteln, um die letzte Lebensänderung rückgängig zu machen';

  @override
  String get settingsSectionData => 'Daten';

  @override
  String get settingsCacheCommanderImages => 'Commander-Bilder cachen';

  @override
  String get settingsCacheCommanderImagesSubtitle =>
      'Speichert Scryfall-Bilder für Offline-Nutzung';

  @override
  String get settingsClearImageCache => 'Bildcache leeren';

  @override
  String get settingsClearImageCacheSubtitle =>
      'Gibt Speicher von gecachten Kartenbildern frei';

  @override
  String get settingsSaveBackup => 'Backup speichern';

  @override
  String get settingsSaveBackupSubtitle =>
      'Schreibt Profil, Decks, Einstellungen, aktuelle Spiele und Feedback in eine Datei';

  @override
  String get settingsRestoreBackup => 'Backup wiederherstellen';

  @override
  String get settingsRestoreBackupSubtitle =>
      'Ersetzt alle lokalen Daten durch eine .lifespark-Datei';

  @override
  String get settingsSectionHelp => 'Hilfe';

  @override
  String get settingsFeedback => 'Feedback';

  @override
  String get settingsFeedbackSubtitle =>
      'Sende uns deine Gedanken und Vorschläge';

  @override
  String get settingsViewHubGuide => 'Hub-Guide anzeigen';

  @override
  String get settingsViewHubGuideSubtitle =>
      'Wie Spielen, Stack, Suche und Tisch in einem Match funktionieren';

  @override
  String get settingsViewTutorialAgain => 'Tutorial erneut anzeigen';

  @override
  String get settingsViewTutorialAgainSubtitle => 'Einführung erneut starten';

  @override
  String get settingsBeta => 'Beta';

  @override
  String get commonCancel => 'Abbrechen';

  @override
  String get commonSave => 'Speichern';

  @override
  String get commonAdd => 'Hinzufügen';

  @override
  String get commonRemove => 'Entfernen';

  @override
  String get commonClose => 'Schließen';

  @override
  String get commonTryAgain => 'Erneut versuchen';

  @override
  String get backupSaved => 'Backup gespeichert.';

  @override
  String get backupSaveFailed => 'Backup konnte nicht gespeichert werden.';

  @override
  String backupRestoreTitle(String username) {
    return '$username wiederherstellen?';
  }

  @override
  String get backupRestoreMessage =>
      'Dadurch werden Profil, Decks, Einstellungen, aktuelle Spiele, Sparks und Verhalten auf diesem Gerät durch das ausgewählte Backup ersetzt.';

  @override
  String get backupRestoreConfirm => 'Wiederherstellen';

  @override
  String backupRestored(String username) {
    return 'Backup für $username wiederhergestellt.';
  }

  @override
  String get backupRestoreFailed =>
      'Backup konnte nicht wiederhergestellt werden. Datei prüfen und erneut versuchen.';

  @override
  String get cacheCleared => 'Bildcache geleert.';

  @override
  String get cacheClearFailed => 'Bildcache konnte nicht geleert werden.';

  @override
  String get decksTitle => 'Decks';

  @override
  String get decksAddDeck => 'Deck hinzufügen';

  @override
  String get profileTitle => 'Profil';

  @override
  String get profileRecentGames => 'Letzte Spiele';

  @override
  String get profileDeckPerformance => 'Deck-Leistung';

  @override
  String get lobbyTitle => 'Lobby';

  @override
  String get lobbyHostGame => 'Spiel hosten';

  @override
  String get lobbyHostGameSubtitle => 'Session erstellen — andere treten bei';

  @override
  String get lobbyJoinGame => 'Beitreten';

  @override
  String get lobbyJoinGameSubtitle => 'Nach Host in der Nähe suchen';

  @override
  String get hostLobbyTitle => 'Host-Lobby';

  @override
  String get hostLeaveLobbyTooltip => 'Lobby verlassen';

  @override
  String hostPlayersScanQr(int count, int max) {
    return 'Spieler: $count / $max  •  QR scannen zum Beitreten';
  }

  @override
  String get hostNeedWifiRetry =>
      'Gerät mit Wi‑Fi verbinden (gleiches Netz wie Gäste), dann Erneut tippen.';

  @override
  String get hostNeedsMobileApp =>
      'Hosten braucht die Mobile-App (iOS/Android) im gleichen Wi‑Fi. Der Browser kann per QR beitreten, aber nicht hosten.';

  @override
  String get hostNeedsMobileOrDev =>
      'Hosten braucht die Mobile-App oder einen lokalen Dev-Build.';

  @override
  String get hostCreateProfileFirst =>
      'Zuerst Profil erstellen (Start → Benutzername), dann Erneut tippen.';

  @override
  String get hostCouldNotStartServer =>
      'Host-Server konnte nicht starten. Erneut tippen.';

  @override
  String get hostSessionDidNotStart =>
      'Host-Session startete nicht. Erneut tippen.';

  @override
  String get hostCouldNotShowQr =>
      'Beitritts-QR konnte nicht angezeigt werden.';

  @override
  String get hostRetry => 'Erneut';

  @override
  String get hostNeedOnePlayer => 'Mindestens 1 Spieler nötig';

  @override
  String get hostEveryoneMustBeReady => 'Alle müssen bereit sein';

  @override
  String get hostStartGame => 'Spiel starten';

  @override
  String hostOpenSlots(int count) {
    return '$count freie(r) Platz/Plätze — Gerät teilen zum Beitreten';
  }

  @override
  String get hostMatchLabel => 'Bezeichnung';

  @override
  String get hostMatchLabelHelp =>
      'Optional. Hilft, dieses Spiel unter Zuletzt zu finden.';

  @override
  String get hostMatchLabelHint => 'z. B. Freitag-EDH';

  @override
  String get hostGameSettings => 'Spieleinstellungen';

  @override
  String get hostFormat => 'Format';

  @override
  String get hostStartingLife => 'Startleben';

  @override
  String get hostCustomStartingLifeTitle => 'Eigenes Startleben';

  @override
  String get hostCustomStartingLifeHint => 'Leben eingeben (1–999)';

  @override
  String get hostCustomEllipsis => 'Eigene…';

  @override
  String get hostGameplay => 'Spielablauf';

  @override
  String get hostToggleTeams => 'Teamspiel';

  @override
  String get hostToggleTeamsSubtitle => 'Teamfarben am Tisch zuweisen';

  @override
  String get hostTogglePlanechaseSubtitle => 'Internet für Planar-Deck nötig';

  @override
  String get hostToggleArchenemySubtitle => 'Internet für Scheme-Deck nötig';

  @override
  String get hostToggleBountySubtitle => 'Internet für Bounty-Deck nötig';

  @override
  String get hostToggleAutoKo => 'Auto-KO';

  @override
  String get hostToggleAutoKoSubtitle =>
      'Durch Leben, Gift oder Commander-Schaden';

  @override
  String get hostToggleCommanderDmgLife => 'Commander-Schaden kostet Leben';

  @override
  String get hostToggleCommanderDmgLifeSubtitle =>
      'Commander-Schaden senkt auch das Leben';

  @override
  String get hostTogglePhaseTracker => 'Phasenanzeige';

  @override
  String get hostTogglePhaseTrackerSubtitle => 'Phasen mit Zurück und Weiter';

  @override
  String get hostToggleTurnTimer => 'Zugtimer';

  @override
  String get hostToggleTurnTimerSubtitle => 'Vergangene Zeit pro Zug anzeigen';

  @override
  String get hostTurnLimit => 'Zuglimit';

  @override
  String get hostTurnLimitOff => 'Aus';

  @override
  String hostTurnLimitSeconds(int seconds) {
    return '$seconds Sekunden';
  }

  @override
  String get hostNoCommanderSelected => 'Kein Commander gewählt';

  @override
  String get hostNoDeckSelected => 'Kein Deck gewählt';

  @override
  String hostTrackingDeck(String name) {
    return 'Erfasst: $name';
  }

  @override
  String get hostDeckListChanged => 'Deck (gespeicherte Liste geändert)';

  @override
  String get hostSelectDeck => 'Deck';

  @override
  String get hostSelectCommander => 'Commander';

  @override
  String get hostMarkReady => 'Bereit markieren';

  @override
  String get hostMarkNotReady => 'Nicht bereit';

  @override
  String get lobbyReady => 'Bereit';

  @override
  String get lobbyWaiting => 'Warten';

  @override
  String get deckPickerTitle => 'Deck für dieses Match';

  @override
  String get deckPickerManualOnly => 'Nur manueller Commander';

  @override
  String get deckPickerManualOnlySubtitle =>
      'Commander so lassen; keinem gespeicherten Deck zuordnen';

  @override
  String deckPickerEmptyForFormat(String format) {
    return 'Noch keine $format-Decks. Im Tab Decks erstellen.';
  }

  @override
  String get deckPickerOpenDecks => 'Decks öffnen';

  @override
  String get joinTitle => 'Spiel beitreten';

  @override
  String get joinLeaveTooltip => 'Verlassen';

  @override
  String get joinPointCamera => 'Kamera auf den Host-QR richten';

  @override
  String get joinCameraRequiredSnack =>
      'Kameraerlaubnis nötig, um den Host-QR zu scannen.';

  @override
  String get joinCameraDeniedBody =>
      'Kamerazugriff nötig, um den Host-QR zu scannen.\\nFalls schon in Einstellungen erlaubt: Erneut tippen.';

  @override
  String get joinOpenSettings => 'Einstellungen';

  @override
  String get joinInvalidQr => 'Kein gültiger Life-Spark-QR.';

  @override
  String get joinMissingToken =>
      'Diesem QR fehlt ein Join-Token. Host soll den QR aktualisieren.';

  @override
  String get joinCouldNotStartSession =>
      'Join-Session konnte nicht starten. Profil fertigstellen und erneut versuchen.';

  @override
  String get joinConnectTimeout =>
      'Verbindung zum Host abgelaufen. Gleiches Wi‑Fi und offene Host-Lobby prüfen, dann erneut.';

  @override
  String get joinHostRejected =>
      'Host hat Verbindung abgelehnt (Versionskonflikt).';

  @override
  String get joinDisconnected => 'Vom Host getrennt.';

  @override
  String get joinConnectionError => 'Verbindungsfehler.';

  @override
  String get joinHostEndedSession => 'Host hat die Session beendet.';

  @override
  String get joinConnecting => 'Verbinde mit Host…';

  @override
  String get joinWaitingForHost => 'Warte auf Host-Start…';

  @override
  String get joinSelectDeck => 'Deck wählen';

  @override
  String get joinSelectCommander => 'Commander wählen';

  @override
  String get joinReady => 'Bereit';

  @override
  String get joinMarkReady => 'Bereit markieren';

  @override
  String get welcomeTagline => 'Dein MTG-Begleiter.';

  @override
  String get welcomeReadyToPlay => 'Bereit zum Spielen';

  @override
  String get welcomeSkip => 'Überspringen';

  @override
  String get onboardingSlide1Title => 'Willkommen bei Life Spark';

  @override
  String get onboardingSlide1Body =>
      'Dein Commander-Tischbegleiter — Leben, Counter, Politik und Stack, synchron am Tisch.';

  @override
  String get onboardingSlide2Title => 'Hosten oder beitreten';

  @override
  String get onboardingSlide2Body =>
      'Ein Spieler hostet — andere scannen einen QR im gleichen Wi‑Fi. Kein Internet-Konto. Für 4 bis 6 Spieler am gleichen Tisch.';

  @override
  String get onboardingSlide3Title => 'Leben tracken';

  @override
  String get onboardingSlide3Body =>
      '+/- tippen: ±1 Leben. +/- halten: ±5. Links/rechts ziehen zum schnellen Anpassen. Doppeltippen für exakten Wert. Rückgängig unten (oder Schütteln, falls aktiv).';

  @override
  String get onboardingSlide4Title => 'Phasen & Züge';

  @override
  String get onboardingSlide4Body =>
      'Phasenleiste für den Zug nutzen oder Phasenanzeige in der Lobby aus. Eine Pause hält das ganze Spiel an.';

  @override
  String get onboardingSlide5Title => 'Commander & Counter';

  @override
  String get onboardingSlide5Body =>
      'Commander-Schaden als Bedrohungsliste — wie viel jeder Gegner Richtung 21. Gift (10), Energy, Experience und Rad tracken. Proliferate: +1 auf alle.';

  @override
  String get onboardingSlide6Title => 'Allianzen & Politik';

  @override
  String get onboardingSlide6Body =>
      'Geheime Allianzen vorschlagen. Sie laufen ab oder enden bei Angriffen. Monarch und Initiative mit einem Tippen.';

  @override
  String get onboardingNext => 'Weiter';

  @override
  String get onboardingReadyToPlay => 'Bereit zum Spielen';

  @override
  String get onboardingSkip => 'Überspringen';

  @override
  String get profileSetupTitle => 'Profil erstellen';

  @override
  String get profileSetupSubtitle => 'Name und Bild, die dein Tisch erkennt.';

  @override
  String get profileSetupUsername => 'Benutzername';

  @override
  String get profileSetupUsernameRequired => 'Benutzernamen eingeben';

  @override
  String get profileSetupUsernameTooShort => 'Mindestens 2 Zeichen';

  @override
  String get profileSetupChoosePicture => 'Profilbild wählen';

  @override
  String get profileSetupChangePicture => 'Bild ändern';

  @override
  String get profileSetupContinue => 'Weiter';

  @override
  String get sessionLeaveTitle => 'Aktives Spiel verlassen?';

  @override
  String get sessionLeaveMessage =>
      'Lobby oder Spiel läuft. Verlassen trennt andere Spieler am Tisch.';

  @override
  String get sessionLeaveConfirm => 'Verlassen';

  @override
  String get sessionLeaveStay => 'Bleiben';

  @override
  String get gameLeaveTitle => 'Spiel verlassen?';

  @override
  String get gameLeaveMessageActive =>
      'Du verlässt das Spiel und gehst nach Hause. Stats speichern nur, wenn der Tisch fertig ist.';

  @override
  String get gameLeaveMessageAfterConcede =>
      'Du verlässt das Live-Spiel und gehst nach Hause. Dein Concede wird vor dem Trennen gespeichert.';

  @override
  String get gameTabPlay => 'Spiel';

  @override
  String get gameTabStack => 'Stack';

  @override
  String get gameTabLookupSemantics => 'Kartenregeln nachschlagen';

  @override
  String get gameBarHome => 'Start';

  @override
  String get gameBarUndo => 'Rückgängig';

  @override
  String get gameBarTimeout => 'Pause';

  @override
  String get gameBarEnd => 'Ende';

  @override
  String get gameBarTable => 'Tisch';

  @override
  String get gameEndTurn => 'Zug beenden';

  @override
  String gameWaitingForPlayer(String name) {
    return 'Warte auf $name…';
  }

  @override
  String get gamePhaseBack => 'Zurück';

  @override
  String get gamePhaseNext => 'Weiter';

  @override
  String get gameChoosePhase => 'Phase wählen';

  @override
  String get gameYourTurn => 'Dein Zug';

  @override
  String get gameYourTurnTapContinue => 'Tippen zum Fortfahren';

  @override
  String get gameYourTurnSemantics => 'Dein Zug. Doppeltippen zum Schließen.';

  @override
  String get gameNowPlaying => 'JETZT AM ZUG';

  @override
  String get gameActiveTurn => 'AKTIVER ZUG';

  @override
  String gamePlayersTurn(String name) {
    return 'Zug von $name';
  }

  @override
  String get gameCurrentTurn => 'Aktueller Zug';

  @override
  String get timeoutStartTitle => 'Pause starten';

  @override
  String get timeout15Seconds => '15 Sekunden';

  @override
  String get timeout30Seconds => '30 Sekunden';

  @override
  String get timeout1Minute => '1 Minute';

  @override
  String get timeoutBanner => 'PAUSE';

  @override
  String get timeoutPaused => 'Spiel pausiert — keine Lebensänderungen';

  @override
  String get timeoutEnd => 'Pause beenden';

  @override
  String timeoutMinimized(String time) {
    return 'Pause — $time';
  }

  @override
  String get timeoutMinimizeTooltip => 'Timer minimieren';

  @override
  String get reconnectToTable => 'Verbinde erneut mit Tisch…';

  @override
  String get reconnectStillTrying => 'Versuche noch, den Tisch zu erreichen…';

  @override
  String reconnectPeerOne(String name) {
    return '$name verbindet erneut…';
  }

  @override
  String reconnectPeerMany(int count) {
    return '$count Spieler verbinden erneut…';
  }

  @override
  String get forfeitTitle => 'Aufgeben?';

  @override
  String get forfeitBodyMulti =>
      'Du verlässt das Spiel. Optional Gegner bewerten.';

  @override
  String get forfeitBodySolo =>
      'Dein Übungsspiel endet. Optional kurz notieren, wie es lief.';

  @override
  String get forfeitRateOpponents => 'Gegner bewerten';

  @override
  String get forfeitConfirm => 'Aufgeben';

  @override
  String get forfeitYouForfeited => 'Du hast aufgegeben';

  @override
  String get forfeitStaySpectateBody =>
      'Andere können weiterspielen. Bleib zum Zuschauen, bis der Tisch fertig ist. Wenn du jetzt zum Profil zurückkehrst, wird deine Aufgabe gespeichert und die Verbindung zum Live-Spiel getrennt.';

  @override
  String get forfeitStaySpectate => 'Bleiben & zuschauen';

  @override
  String get forfeitReturnToProfile => 'Zum Profil';

  @override
  String get gamePlayerLeftTitle => 'Spieler weg';

  @override
  String gamePlayerLeftMessage(String username) {
    return '$username hat das Spiel verlassen.';
  }

  @override
  String get gameSessionEndedTitle => 'Session beendet';

  @override
  String get gameSessionEndedMessage => 'Der Host hat das Spiel beendet.';

  @override
  String gamePeerOfflineTitle(String username) {
    return '$username noch offline';
  }

  @override
  String get gamePeerOfflineBody =>
      'Weiter warten auf Reconnect oder vom Tisch entfernen?';

  @override
  String get gameKeepWaiting => 'Weiter warten';

  @override
  String get gameRemoveFromTable => 'Vom Tisch entfernen';

  @override
  String get gameSlotLoadFailedTitle => 'Spielerplatz nicht ladbar';

  @override
  String get gameSlotLoadFailedBody =>
      'Spiel evtl. desync. Zur Lobby und erneut beitreten.';

  @override
  String get gameReturnToLobby => 'Zur Lobby';

  @override
  String get profileSetupPrompt => 'Profil einrichten, um fortzufahren.';

  @override
  String get profileCreateCta => 'Profil erstellen';

  @override
  String get profileNewPlayer => 'Neuer Spieler';

  @override
  String profilePlayingSince(String date) {
    return 'Spielt seit $date';
  }

  @override
  String get profileOptions => 'Profiloptionen';

  @override
  String get profileDoneEditing => 'Fertig';

  @override
  String get profileDone => 'Fertig';

  @override
  String get profileEditName => 'Name bearbeiten';

  @override
  String get profileEditNameTooltip => 'Name bearbeiten';

  @override
  String get profileChangePicture => 'Profilbild ändern';

  @override
  String get profileStatRecord => 'Bilanz';

  @override
  String get profileStatSparks => 'Sparks';

  @override
  String get profileStatGames => 'Spiele';

  @override
  String get profileEmptyRecentGames =>
      'Erstes Spiel spielen, um Statistiken und Verlauf freizuschalten.';

  @override
  String get profileEmptyDeckPerf =>
      'Deck hinzufügen, um Commander-Leistung zu tracken.';

  @override
  String get profileFilterAllGames => 'Alle';

  @override
  String get profileFilterRecent14 => 'Zuletzt (14 Tage)';

  @override
  String get profileFilterThisWeek => 'Diese Woche';

  @override
  String get profileFilterThisMonth => 'Dieser Monat';

  @override
  String get profileNoMatchesFilter => 'Keine Matches für diesen Filter.';

  @override
  String get profileOpenLobbySemantics =>
      'Lobby öffnen zum Hosten oder Beitreten';

  @override
  String get profileShowMore => 'Mehr anzeigen';

  @override
  String get profileStandings => 'Platzierung';

  @override
  String get profileNoPlayerDetails => 'Keine Spielerdetails für dieses Match.';

  @override
  String get profileResultConcede => 'Aufgabe';

  @override
  String get profileResultLoss => 'Niederlage';

  @override
  String get decksEmptyTitle => 'Deck-Bibliothek aufbauen';

  @override
  String get decksEmptyBody =>
      'Deck mit Name, Format und Cover speichern. Beim Hosten/Beitreten Liste in der Lobby wählen.';

  @override
  String get decksSearchHint => 'Decks suchen…';

  @override
  String decksNoSearchMatches(String query) {
    return 'Keine Decks für “$query”.';
  }

  @override
  String get decksStyleNotSet => 'Stil nicht gesetzt';

  @override
  String get decksNoCoverCard => 'Keine Cover-Karte';

  @override
  String get lookupTitle => 'Kartensuche';

  @override
  String get lookupHint => 'Beliebige MTG-Karte suchen…';

  @override
  String get lookupHelp => 'Oracle-Text und offizielle Rulings von Scryfall.';

  @override
  String get lookupEmptyPrompt => 'Kartennamen tippen, um Regeln zu sehen.';

  @override
  String lookupNoResults(String query) {
    return 'Keine Karten für “$query”.';
  }

  @override
  String get lookupNetworkError =>
      'Scryfall nicht erreichbar. Verbindung prüfen.';

  @override
  String get lookupSearch => 'Suchen';

  @override
  String get lookupOracleText => 'Oracle-Text';

  @override
  String get lookupNoOracle => 'Kein Oracle-Text für diese Karte.';

  @override
  String get lookupRulings => 'Rulings';

  @override
  String get lookupNoRulings => 'Keine offiziellen Rulings für diese Karte.';

  @override
  String get endGameSavingResults => 'Ergebnisse werden gespeichert…';

  @override
  String get endGameSaveFailedTitle =>
      'Ergebnisse konnten nicht gespeichert werden.';

  @override
  String get endGameSaveFailedBody =>
      'Deine Stats wurden evtl. nicht aktualisiert. Bitte erneut versuchen.';

  @override
  String get endGameRetry => 'Erneut';

  @override
  String get endGameContinueWithoutSaving => 'Ohne Speichern weiter';

  @override
  String get endGameFinalStandings => 'Endstand';

  @override
  String get endGameOverNoWinner => 'Spielende — Kein Sieger';

  @override
  String get endGamePracticeEnded => 'Übung beendet';

  @override
  String get endGameYouWin => 'Du gewinnst!';

  @override
  String get endGameWinner => 'Sieger';

  @override
  String get endGameRankUp => 'RANG AUFSTIEG!';

  @override
  String endGameRankTransition(int oldLevel, int newLevel) {
    return 'Rang $oldLevel → $newLevel';
  }

  @override
  String endGameXpGained(int xp) {
    return '+$xp XP';
  }

  @override
  String get endGameWinBonusIncluded => 'Siegbonus enthalten';

  @override
  String get endGameParticipationXp => 'Teilnahme-XP';

  @override
  String endGameRankLevel(int level) {
    return 'Rang $level';
  }

  @override
  String get endGameFeedbackThanks => 'Danke! Dein Feedback wurde erfasst.';

  @override
  String get endGameRateOpponents => 'Gegner bewerten';

  @override
  String get endGameSubmitFeedback => 'Feedback senden';

  @override
  String get endGameYouSuffix => '(du)';

  @override
  String get endGameElimReasonLife => 'Leben aufgebraucht';

  @override
  String get endGameElimReasonPoison => '10 Gift';

  @override
  String get endGameElimReasonCommanderDmg => 'Commander-Schaden';

  @override
  String get endGameElimReasonConcede => 'Aufgegeben';

  @override
  String get endGameElimReasonDisconnect => 'Spiel verlassen';

  @override
  String get endGameElimReasonDefault => 'Eliminiert';

  @override
  String get endGameBackToHome => 'Zurück zum Start';

  @override
  String get feedbackTitle => 'Feedback';

  @override
  String get feedbackHeadline => 'Hilf uns zu verbessern';

  @override
  String get feedbackBody => 'Bug gefunden? Idee? Wir lesen jede Nachricht.';

  @override
  String get feedbackMessageLabel => 'Deine Nachricht';

  @override
  String get feedbackMessageHint => 'Sag uns, was du denkst...';

  @override
  String get feedbackSend => 'Feedback senden';

  @override
  String get feedbackOrDivider => 'oder';

  @override
  String get feedbackRatePlayStore => 'Im Play Store bewerten';

  @override
  String get feedbackMailSubject => 'Life Spark Feedback';

  @override
  String get feedbackOpeningMail => 'Mail-App wird geöffnet…';

  @override
  String feedbackNoMailAppCopied(String email) {
    return 'Keine Mail-App — Nachricht kopiert. In E-Mail an $email einfügen';
  }

  @override
  String feedbackClipboardFallback(String email, String message) {
    return 'An: $email\\nBetreff: Life Spark Feedback\\n\\n$message';
  }

  @override
  String get stackSortOrderOnStack => 'Reihenfolge auf dem Stack';

  @override
  String get stackSortByPlayer => 'Nach Spieler';

  @override
  String get stackAddSpellOrAbility => 'Zauber oder Fähigkeit hinzufügen';

  @override
  String get stackHowItWorksTooltip => 'So funktioniert der Stack';

  @override
  String get stackFilterResolvedCountered => 'Verrechnet / gekontert';

  @override
  String get stackApnapHint =>
      'Wer was hinzugefügt hat (Aktiver Spieler zuerst)';

  @override
  String get stackClearAll => 'Alles löschen';

  @override
  String get stackClearConfirmTitle => 'Stack leeren?';

  @override
  String get stackClearConfirmBody =>
      'Entfernt alle Zauber und Fähigkeiten vom Stack. Nicht rückgängig.';

  @override
  String stackActivePlayerLabel(String username) {
    return '$username · Aktiver Spieler';
  }

  @override
  String stackTurnOrderLabel(String username, int position) {
    return '$username · Zugreihenfolge: $position';
  }

  @override
  String get stackPutOnStack => 'Auf den Stack legen';

  @override
  String get stackInResponseToEllipsis => 'Als Antwort auf…';

  @override
  String get stackEmptyTitle => 'Nichts auf dem Stack';

  @override
  String get stackEmptyBullet1 =>
      'Lege Zauber und Fähigkeiten hier ab, bevor sie verrechnet werden.';

  @override
  String get stackEmptyBullet2 => 'Zuletzt hinzugefügt wird zuerst verrechnet.';

  @override
  String get stackAddSpell => 'Zauber hinzufügen';

  @override
  String get stackStatusResolved => 'Verrechnet';

  @override
  String get stackStatusCountered => 'Gekontert';

  @override
  String get stackStatusFizzled => 'Gescheitert';

  @override
  String get stackYouSuffix => '(du)';

  @override
  String get stackUndoFizzle => 'Scheitern rückgängig';

  @override
  String get stackFizzle => 'Scheitern';

  @override
  String get stackUndoFizzleSubtitle =>
      'Zauber wieder aktiv auf den Stack legen';

  @override
  String get stackFizzleSubtitle =>
      'Illegales Ziel oder Zauber hat den Stack verlassen (Regel-Counter)';

  @override
  String get stackMarkCountered => 'Als gekontert markieren';

  @override
  String get stackRename => 'Umbenennen';

  @override
  String get stackOnStack => 'Auf dem Stack';

  @override
  String get stackResolvesNext => 'Wird als Nächstes verrechnet';

  @override
  String get stackResolvesAfterAbove => 'Wird nach den oberen verrechnet';

  @override
  String get stackTargetNoLongerOnStack => 'Ziel ist nicht mehr auf dem Stack';

  @override
  String get stackCardRulesTooltip => 'Kartenregeln';

  @override
  String stackInResponseToNamed(String name) {
    return 'Als Antwort auf $name';
  }

  @override
  String get stackResolve => 'Verrechnen';

  @override
  String get stackRespond => 'Antworten';

  @override
  String get stackFizzledButton => 'Gescheitert';

  @override
  String get stackHelpTitle => 'So funktioniert der Stack';

  @override
  String get stackHelpBullet1 =>
      'Wenn jemand einen Zauber wirkt oder eine Fähigkeit nutzt, geht er auf den Stack — eine Warteschlange, bevor es passiert.';

  @override
  String get stackHelpBullet2 =>
      'Zuletzt hinzugefügt wird zuerst verrechnet (wie ein Tellerstapel). Deshalb steht oben Wird als Nächstes verrechnet.';

  @override
  String get stackHelpBullet3 =>
      'Beim Hinzufügen auf Scryfall suchen und die Karte aus der Liste wählen, damit Name und Regeltext stimmen.';

  @override
  String get stackHelpBullet4 =>
      'Zum Antworten tippe Antworten oder nutze Als Antwort auf… — dein Zauber liegt oben und wird vor dem darunter verrechnet.';

  @override
  String get stackHelpBullet5 =>
      'Wenn ein Effekt fertig ist, tippe Verrechnen — die Karte bleibt auf dem Stack und wird grün. Zum Antworten tippe Antworten. Hat ein Counter gewirkt: Als gekontert markieren (Filter Gekontert). Hat ein Zauber sein Ziel verloren: Scheitern — bleibt grau; erneut Gescheitert tippen zum Rückgängigmachen.';

  @override
  String get stackHelpBullet6 =>
      'Am Tisch sagst du weiterhin „pass“ laut für Priority; dieser Screen hilft, was wartet und in welcher Reihenfolge.';

  @override
  String get stackHelpExample =>
      'Beispiel: Du wirkst einen Pump-Zauber auf deine Kreatur. Dein Gegner wirkt Lightning Bolt als Antwort. Bolt zuerst, dann dein Pump (falls Ziel noch legal).';

  @override
  String get stackHelpReadMore => 'Mehr auf Magic.com';

  @override
  String get stackHelpCouldNotOpenLink => 'Link konnte nicht geöffnet werden';

  @override
  String get stackPickerIntro =>
      'Auf Scryfall suchen, damit Name und Regeltext stimmen.';

  @override
  String get stackPickerCardNameLabel => 'Kartenname';

  @override
  String get stackPickerCardNameHint => 'z. B. Lightning Bolt';

  @override
  String get stackPickerClearSearch => 'Suche löschen';

  @override
  String get stackPickerAdd => 'Hinzufügen';

  @override
  String get stackPickerNoCards =>
      'Keine Karten gefunden. Andere Schreibweise versuchen.';

  @override
  String get stackPickerNetworkError =>
      'Scryfall nicht erreichbar. Internet prüfen.';

  @override
  String get stackPickerNeedSelection =>
      'Karte aus der Liste wählen oder einen von Scryfall erkannten Namen eingeben.';

  @override
  String get stackPickerTypeToSearch => 'Tippen zum Suchen';

  @override
  String get allianceAPlayer => 'Ein Spieler';

  @override
  String get allianceYourAllyFallback => 'dein Verbündeter';

  @override
  String get allianceOfferDeclined => 'Geheimes Allianzangebot abgelehnt';

  @override
  String get allianceEnded => 'Geheime Allianz beendet';

  @override
  String get allianceProposeTitle => 'Geheime Allianz';

  @override
  String allianceProposeSubtitle(String username) {
    return '$username einladen — nur er/sie erfährt es.';
  }

  @override
  String get allianceDurationSection => 'Dauer';

  @override
  String get allianceDurationEndOfTurn => 'Bis Zugende';

  @override
  String get allianceDurationEndOfRound => 'Bis Rundenende';

  @override
  String get allianceDurationUntilBroken => 'Bis gebrochen';

  @override
  String get allianceWhenToDeliver => 'Wann zustellen';

  @override
  String get allianceDeliverNow => 'Jetzt zustellen';

  @override
  String allianceDeliverInSeconds(int seconds) {
    return 'In ${seconds}s zustellen';
  }

  @override
  String get allianceDeliverEndOfYourTurn => 'Am Ende deines Zuges';

  @override
  String get allianceDeliverNextRound => 'Nächste Runde';

  @override
  String allianceSecondsShort(int seconds) {
    return '${seconds}s';
  }

  @override
  String get allianceSend => 'Senden';

  @override
  String allianceWhisperSent(String username) {
    return 'Flüstern an $username gesendet';
  }

  @override
  String allianceWhisperScheduled(String username) {
    return 'Flüstern für $username geplant';
  }

  @override
  String get allianceInviteTitle => 'Geheimes Angebot';

  @override
  String allianceInviteBody(String username, String duration) {
    return '$username schlägt eine geheime Allianz vor.\\n\\nDauer: $duration\\n\\nNur du siehst das.';
  }

  @override
  String get allianceAccept => 'Annehmen';

  @override
  String get allianceDecline => 'Ablehnen';

  @override
  String get allianceFormedTitle => 'Allianz gebildet';

  @override
  String allianceFormedBody(String username, String duration) {
    return 'Du und $username seid jetzt geheim verbündet ($duration).\\n\\nDer Tisch weiß es nicht — außer ihr enthüllt oder verratet.';
  }

  @override
  String allianceFormedBodyNoDuration(String username) {
    return 'Du und $username seid jetzt geheim verbündet.\\n\\nDer Tisch weiß es nicht — außer ihr enthüllt oder verratet.';
  }

  @override
  String get allianceUnderstood => 'Verstanden';

  @override
  String get allianceRevealedTitle => 'Allianz enthüllt';

  @override
  String allianceRevealedBody(String playerA, String playerB) {
    return '$playerA und $playerB haben ihre geheime Allianz dem Tisch enthüllt.';
  }

  @override
  String get allianceOk => 'OK';

  @override
  String get allianceBetrayalTitle => 'Verrat!';

  @override
  String allianceBetrayalBody(String playerA, String playerB) {
    return 'Die geheime Allianz zwischen $playerA und $playerB wurde durch Verrat gebrochen.';
  }

  @override
  String get allianceBadgeAllied => 'Verbündet';

  @override
  String get allianceBadgeSecretAlly => 'Geheimer Verbündeter';

  @override
  String allianceWhisperPending(String username) {
    return 'Flüstern ausstehend → $username';
  }

  @override
  String allianceAwaiting(String username) {
    return 'Warte auf $username';
  }

  @override
  String get cmdDmgSheetTitle => 'Commander-Schaden';

  @override
  String get cmdDmgSheetSubtitle =>
      'Bedrohungen gegen dich zuerst. Zugefügt öffnen, um deinen Schaden zu loggen.';

  @override
  String cmdDmgBarA11y(String remaining, String ko, String taken) {
    return 'Commander-Schaden $remaining von $ko übrig, $taken auf schlechtestem Track, tippen zum Verwalten';
  }

  @override
  String get cmdDmgLeft => 'übrig';

  @override
  String get cmdDmgHideDealt => 'Zugefügt ausblenden';

  @override
  String cmdDmgDealtTotal(String total) {
    return 'Zugefügt $total';
  }

  @override
  String get cmdDmgDefaultCommander => 'Commander';

  @override
  String get cmdDmgDefaultPartner => 'Partner';

  @override
  String get cmdDmgDefaultPartnerCommander => 'Partner-Commander';

  @override
  String cmdDmgYouDealtTitle(String name) {
    return 'Du → $name';
  }

  @override
  String get cmdDmgYouDealtSubtitle => 'Schaden, den du zugefügt hast';

  @override
  String get cmdDmgLethalTooltip => 'Tödlicher Commander-Schaden!';

  @override
  String get cmdDmgIncreaseA11y => 'Commander-Schaden erhöhen';

  @override
  String get cmdDmgDecreaseA11y => 'Commander-Schaden verringern';

  @override
  String get cmdBarCastCommander => 'Commander wirken';

  @override
  String get cmdBarEliminated => 'Eliminiert';

  @override
  String get cmdBarNoTaxYet => 'Noch keine Tax';

  @override
  String get cmdBarRemoveLastCast => 'Letzten Commander-Cast entfernen';

  @override
  String get cmdBarCommanderTax => 'Commander-Tax';

  @override
  String get cmdBarTapToRemoveLastCast => 'Tippen, letzten Cast entfernen';

  @override
  String cmdBarTaxPlus(int tax) {
    return 'Tax +$tax';
  }

  @override
  String get counterResetConfirmTitle => 'Auf 0 setzen?';

  @override
  String get counterResetConfirmBody => 'Diesen Zähler auf null setzen.';

  @override
  String get counterResetConfirmAction => 'Zurücksetzen';

  @override
  String get counterResetToZero => 'Auf 0 setzen';

  @override
  String get counterDone => 'Fertig';

  @override
  String get firstPlayerRollTitle => 'Würfeln um den ersten Spieler';

  @override
  String get firstPlayerRollSubtitle =>
      'Höchster Wurf beginnt. Tippe den Würfel!';

  @override
  String get firstPlayerRollDieA11y => 'Würfel würfeln';

  @override
  String get firstPlayerRollingA11y => 'Würfelt';

  @override
  String firstPlayerRolledA11y(String value) {
    return 'Gewürfelt: $value';
  }

  @override
  String get firstPlayerNotRolledA11y => 'Nicht gewürfelt';

  @override
  String firstPlayerYouRolled(String value) {
    return 'Du hast $value!';
  }

  @override
  String firstPlayerYouRolledA11y(String value) {
    return 'Du hast $value';
  }

  @override
  String get firstPlayerRolling => 'Würfelt…';

  @override
  String get firstPlayerTapToRoll => 'Tippen zum Würfeln';

  @override
  String firstPlayerHostProgressA11y(String rolled, String total) {
    return '$rolled von $total Spielern haben gewürfelt';
  }

  @override
  String get firstPlayerWaitingOthersA11y => 'Warte auf andere Spieler';

  @override
  String get firstPlayerRollToContinueA11y => 'Würfeln zum Fortfahren';

  @override
  String firstPlayerHostProgress(String rolled, String total) {
    return '$rolled / $total Spieler haben gewürfelt';
  }

  @override
  String get firstPlayerWaitingOthers => 'Warte auf andere…';

  @override
  String get firstPlayerTapDieAbove => 'Würfel oben tippen';

  @override
  String firstPlayerYouSuffix(String username) {
    return '$username (du)';
  }

  @override
  String get firstPlayerTurnOrderTitle => 'Zugreihenfolge';

  @override
  String get firstPlayerTurnOrderSubtitle =>
      'Höchster Wurf führt — Spiel läuft in dieser Reihenfolge.';

  @override
  String get firstPlayerStartGame => 'Spiel starten';

  @override
  String get firstPlayerOrdinal1 => '1.';

  @override
  String get firstPlayerOrdinal2 => '2.';

  @override
  String get firstPlayerOrdinal3 => '3.';

  @override
  String get firstPlayerOrdinal4 => '4.';

  @override
  String get firstPlayerOrdinal5 => '5.';

  @override
  String get firstPlayerOrdinal6 => '6.';

  @override
  String firstPlayerSlotA11y(String place, String name, String rollDetail) {
    return '$place, $name, $rollDetail';
  }

  @override
  String firstPlayerSlotYou(String username) {
    return '$username, du';
  }

  @override
  String get firstPlayerRollUnavailable => 'Wurf nicht verfügbar';

  @override
  String firstPlayerRolledDetail(String value) {
    return 'würfelte $value';
  }

  @override
  String get firstPlayerGoesFirst => 'beginnt';

  @override
  String get historyTitle => 'Verlauf';

  @override
  String get historySubtitle => 'Leben, Zähler und andere Tischaktionen.';

  @override
  String get historyEmptyTitle => 'Noch keine Aktionen';

  @override
  String get historyEmptyBody =>
      'Lebensänderungen, Zähler und andere Aktionen erscheinen hier im Spielverlauf.';

  @override
  String historyTurn(String turn) {
    return 'Zug $turn';
  }

  @override
  String get overviewElimReasonLife => 'Lebensverlust';

  @override
  String get overviewElimReasonPoison => 'Gift';

  @override
  String get overviewElimReasonCommanderDmg => 'Commander-Schaden';

  @override
  String get overviewElimReasonConcede => 'Aufgegeben';

  @override
  String get overviewElimReasonDisconnect => 'Getrennt';

  @override
  String overviewRound(int round) {
    return 'Runde $round';
  }

  @override
  String get overviewClose => 'Übersicht schließen';

  @override
  String get overviewTools => 'Werkzeuge';

  @override
  String get overviewHistory => 'Verlauf';

  @override
  String get overviewPlayers => 'Spieler';

  @override
  String get overviewHoldDragReorder => 'Halten & ziehen zum Umordnen';

  @override
  String get overviewDecreaseLife => 'Leben verringern';

  @override
  String get overviewIncreaseLife => 'Leben erhöhen';

  @override
  String overviewCommanderTaxPlus(int tax) {
    return 'Commander-Tax plus $tax';
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
  String get overviewNowPlaying => 'JETZT AM ZUG';

  @override
  String get overviewSendWhisper => 'Flüstern senden';

  @override
  String get overviewAssignTeamColor => 'Teamfarbe zuweisen';

  @override
  String get overviewProposeSecretAlliance => 'Geheime Allianz vorschlagen';

  @override
  String get overviewRevealAlliance => 'Allianz dem Tisch enthüllen';

  @override
  String get overviewBreakAlliance => 'Geheime Allianz brechen';

  @override
  String get overviewAssignTeamTitle => 'Team zuweisen';

  @override
  String get overviewTeamNone => 'Keins';

  @override
  String overviewTeamN(String index) {
    return 'Team $index';
  }

  @override
  String dialsStripLimitSnack(int max) {
    return 'Deine Leiste fasst bis $max Zähler. Einen entfernen, um einen hinzuzufügen.';
  }

  @override
  String get dialsLabelPoison => 'Gift';

  @override
  String get dialsLabelEnergy => 'Energie';

  @override
  String get dialsLabelExp => 'Exp';

  @override
  String get dialsLabelRad => 'Rad';

  @override
  String get dialsLabelBlood => 'Blut';

  @override
  String get dialsLabelClue => 'Hinweis';

  @override
  String get dialsLabelMap => 'Karte';

  @override
  String get dialsLabelTreasure => 'Schatz';

  @override
  String get dialsLabelDevotion => 'Hingabe';

  @override
  String get dialsLabelCreatures => 'Kreaturen';

  @override
  String get dialsLabelEnchant => 'Verzaub.';

  @override
  String get dialsLabelArtifacts => 'Artefakte';

  @override
  String get dialsLabelGy => 'Friedhof';

  @override
  String get dialsLabelExile => 'Exil';

  @override
  String get dialsAddCounterTitle => 'Zähler hinzufügen';

  @override
  String dialsAddCounterBody(int max) {
    return 'Tracker für deine Leiste wählen (max. $max). X tippen, um einen zu entfernen.';
  }

  @override
  String get dialsSectionCommon => 'Häufig';

  @override
  String get dialsSectionTokensZones => 'Token & Zonen';

  @override
  String get dialsAllBuiltInsOnStrip =>
      'Alle eingebauten Zähler sind schon auf der Leiste. Einen entfernen für einen Slot.';

  @override
  String get dialsAddCounterTooltip => 'Zähler hinzufügen';

  @override
  String get dialsRemoveFromStrip => 'Von Leiste entfernen';

  @override
  String get hubGuideTitle => 'Kurz-Tour';

  @override
  String get hubGuideSkip => 'Überspringen';

  @override
  String get hubGuideNext => 'Weiter';

  @override
  String get hubGuideGotIt => 'Verstanden';

  @override
  String get hubGuideSlidePlayTitle => 'Spielen';

  @override
  String get hubGuideSlidePlayBody =>
      'Leben und Zähler hier tracken. Zug beenden unter der Phasenleiste — oder Phasen-Tracker in der Lobby aus für großen Zug-beenden-Button.';

  @override
  String get hubGuideSlideStackTitle => 'Stack & Lookup';

  @override
  String get hubGuideSlideStackBody =>
      'Stack für Hold Priority und Verrechnen. Lookup öffnet Scryfall ohne deinen Platz zu verlassen — Orakeltext und Rulings.';

  @override
  String get hubGuideSlideTableTitle => 'Tischübersicht';

  @override
  String get hubGuideSlideTableBody =>
      'Tisch für den ganzen Pod. Werkzeuge hat Würfel und Münzen für alle; Verlauf in der Kopfzeile. Zug beenden bleibt; Aufgeben darunter.';

  @override
  String get hubGuideSlideCommanderTitle => 'Dein Zug & Commander';

  @override
  String get hubGuideSlideCommanderBody =>
      'Wenn der Sitz deiner ist, tippe Dein Zug zum Schließen. Das Herz trackt Commander-Schaden bis 21.';

  @override
  String lifeA11yEliminatedAt(String life) {
    return 'Eliminiert bei $life Leben';
  }

  @override
  String lifeA11yLifeTotal(String life) {
    return '$life Leben gesamt';
  }

  @override
  String get lifeA11yDecrease => 'Leben verringern';

  @override
  String get lifeA11yIncrease => 'Leben erhöhen';

  @override
  String get lifeSetTotalTitle => 'Leben setzen';

  @override
  String get glanceOpenTableA11y => 'Tischübersicht öffnen, Zugreihenfolge';

  @override
  String get glanceYou => 'Du';

  @override
  String get phasePickerTitle => 'Phase wählen';

  @override
  String get phasePickerSubtitle =>
      'Scrollen und Phase tippen, oder Phase setzen für den markierten Schritt.';

  @override
  String phasePickerSetPhase(String phase) {
    return '$phase setzen';
  }

  @override
  String get whisperPresetTeamUp => 'Zusammen?';

  @override
  String get whisperPresetDontAttack => 'Greif mich nicht an';

  @override
  String get whisperPresetHaveRemoval => 'Ich hab Removal';

  @override
  String get whisperPresetAllGood => 'Alles gut';

  @override
  String whisperSentSnack(String username) {
    return 'Flüstern an $username gesendet';
  }

  @override
  String get whisperSendFailed =>
      'Senden fehlgeschlagen — kurz warten oder Verbindung prüfen.';

  @override
  String whisperSheetTitle(String username) {
    return 'Flüstern an $username';
  }

  @override
  String get whisperSheetSubtitle =>
      'Nur er/sie sieht es — verblasst. Nicht im Match-Verlauf.';

  @override
  String get whisperCustomLabel => 'Eigene Nachricht';

  @override
  String get whisperCustomHint => 'Kurze Notiz…';

  @override
  String get whisperSend => 'Flüstern senden';

  @override
  String whisperOverlayA11y(String username, String text) {
    return 'Flüstern von $username: $text';
  }

  @override
  String whisperOverlayHeader(String username) {
    return 'Flüstern von $username';
  }

  @override
  String get politicsTapToAssignA11y => 'Tischpolitik. Tippen zum Zuweisen.';

  @override
  String get politicsStatusEmpty => 'Kein Monarch · Keine Initiative · —';

  @override
  String get politicsDay => 'Tag';

  @override
  String get politicsNight => 'Nacht';

  @override
  String get politicsAssignSheetTitle => 'Tischpolitik zuweisen';

  @override
  String get politicsMonarch => 'Monarch';

  @override
  String get politicsInitiative => 'Initiative';

  @override
  String get politicsAssignMonarch => 'Monarch zuweisen';

  @override
  String get politicsAssignInitiative => 'Initiative zuweisen';

  @override
  String get politicsNone => 'Keins';

  @override
  String get politicsDayNight => 'Tag/Nacht';

  @override
  String get tableToolsTitle => 'Werkzeuge';

  @override
  String get tableToolsSubtitle => 'Alle am Tisch sehen das Ergebnis.';

  @override
  String get tableToolsD6 => 'd6';

  @override
  String get tableToolsD20 => 'd20';

  @override
  String get tableToolsCoin => 'Münze';

  @override
  String get tableToolsResultHint => 'Ergebnis erscheint für den ganzen Tisch';

  @override
  String get tableToolsRollD6 => 'd6 würfeln';

  @override
  String get tableToolsRollD20 => 'd20 würfeln';

  @override
  String get tableToolsFlipCoin => 'Münze werfen';

  @override
  String get tableToolHeads => 'Kopf';

  @override
  String get tableToolTails => 'Zahl';

  @override
  String tableToolRolledHeadline(String username, String result) {
    return '$username würfelte eine $result';
  }

  @override
  String tableToolFlippedHeadline(String username, String result) {
    return '$username warf $result';
  }

  @override
  String get tableToolTapToDismiss => 'Tippen zum Schließen';

  @override
  String tableToolDismissA11y(String headline) {
    return '$headline. Tippen zum Schließen.';
  }

  @override
  String get tableToolPlayerFallback => 'Spieler';

  @override
  String get variantDeckSingular => 'Varianten-Deck';

  @override
  String get variantDeckPlural => 'Varianten-Decks';

  @override
  String variantDeckA11y(String label) {
    return '$label, tippen zum Ansehen';
  }

  @override
  String get variantDecksSheetTitle => 'Varianten-Decks';

  @override
  String get variantLoading => 'Varianten-Decks werden geladen…';

  @override
  String get variantLoadFailed =>
      'Decks konnten nicht geladen werden (Internet nötig)';

  @override
  String get variantPlanechase => 'Planechase';

  @override
  String get variantArchenemy => 'Archenemy';

  @override
  String get variantBounty => 'Bounty';

  @override
  String get variantNextCard => 'Nächste Karte';

  @override
  String commanderSelectNoCommanders(String query) {
    return 'Keine Commander für „$query“';
  }

  @override
  String commanderSelectNoCards(String query) {
    return 'Keine Karten für „$query“';
  }

  @override
  String get commanderSelectSearchFailed =>
      'Suche fehlgeschlagen. Internet prüfen und erneut versuchen.';

  @override
  String get commanderSelectEditCommanders => 'Commander bearbeiten';

  @override
  String get commanderSelectEditCover => 'Cover-Karte bearbeiten';

  @override
  String get commanderSelectStep2Commander => 'Schritt 2 von 2 — Commander';

  @override
  String get commanderSelectStep2Cover => 'Schritt 2 von 2 — Cover-Karte';

  @override
  String get commanderSelectPartnerTitle => 'Partner wählen';

  @override
  String get commanderSelectCommanderTitle => 'Commander wählen';

  @override
  String get commanderSelectCoverHint =>
      'Beliebige Karte für Deck-Art — nicht deine volle Liste.';

  @override
  String get commanderSelectSearchPartnerHint => 'Partner-Commander suchen…';

  @override
  String get commanderSelectSearchCommanderHint => 'Commander suchen…';

  @override
  String get commanderSelectSearchCardHint => 'Karte suchen…';

  @override
  String get commanderSelectConfirm => 'Bestätigen';

  @override
  String get commanderSelectScryfallCommanderHelp =>
      'Commander-Namen tippen, um in Scryfall zu suchen.';

  @override
  String get commanderSelectScryfallCardHelp =>
      'Kartennamen tippen, um in Scryfall zu suchen.';

  @override
  String get commanderSelectLabelCommander => 'Commander';

  @override
  String get commanderSelectLabelPartner => 'Partner';

  @override
  String get commanderSelectOptional => 'optional';

  @override
  String get deckOptionsDeleteTitle => 'Deck löschen?';

  @override
  String deckOptionsDeleteBody(String name) {
    return '„$name“ aus deiner Bibliothek entfernen? Match-Verlauf bleibt, aber das Deck erscheint nicht mehr im Lobby-Picker.';
  }

  @override
  String get deckOptionsDeleteConfirm => 'Löschen';

  @override
  String get deckOptionsStyleNotSet => 'Stil nicht gesetzt';

  @override
  String get deckOptionsEditCommanders => 'Commander bearbeiten';

  @override
  String get deckOptionsEditCover => 'Cover-Karte bearbeiten';

  @override
  String get deckOptionsNoGamesYet => 'Noch keine Spiele';

  @override
  String deckOptionsWinRate(String rate) {
    return '$rate % Siegrate';
  }

  @override
  String get deckOptionsUnpin => 'Oben lösen';

  @override
  String get deckOptionsPin => 'Oben anheften';

  @override
  String get deckOptionsChangeFormat => 'Format ändern';

  @override
  String get deckOptionsChangeStyle => 'Stil ändern';

  @override
  String get deckOptionsStyleRequired => 'Erforderlich — nicht gesetzt';

  @override
  String get deckOptionsRename => 'Umbenennen';

  @override
  String get deckOptionsDuplicate => 'Duplizieren';

  @override
  String get deckOptionsDelete => 'Deck löschen';

  @override
  String get deckOptionsRenameTitle => 'Deck umbenennen';

  @override
  String get deckOptionsNameLabel => 'Deckname';

  @override
  String get deckOptionsNameHint => 'z. B. Raffine Tempo';

  @override
  String get newDeckChooseStyleError => 'Deck-Stil wählen zum Fortfahren';

  @override
  String get newDeckTitle => 'Neues Deck';

  @override
  String get newDeckSubtitle => 'Schritt 1 von 2 — Details';

  @override
  String get newDeckIntro =>
      'Deck benennen, Format und Stil wählen. Danach Commander oder Cover-Karte.';

  @override
  String get newDeckNameLabel => 'Deckname';

  @override
  String get newDeckNameHint => 'z. B. Raffine Tempo';

  @override
  String get newDeckNext => 'Weiter';

  @override
  String get formatPickerTitle => 'Format';

  @override
  String get formatPickerSearchHint => 'Formate suchen…';

  @override
  String get formatPickerFieldLabel => 'Format';

  @override
  String formatPickerMultiplayerLife(String life) {
    return 'Mehrspieler · $life Startleben';
  }

  @override
  String formatPickerConstructedLife(String life) {
    return 'Constructed · $life Startleben';
  }

  @override
  String get stylePickerTitle => 'Deck-Stil';

  @override
  String get stylePickerSearchHint => 'Stile suchen…';

  @override
  String get stylePickerChoose => 'Deck-Stil wählen';

  @override
  String get stylePickerFieldLabel => 'Deck-Stil';

  @override
  String get profileOptionsTitle => 'Profil';

  @override
  String get profileOptionsEdit => 'Profil bearbeiten';

  @override
  String get profileOptionsEditSubtitle => 'Name oder Avatar ändern';

  @override
  String get profileOptionsBackup => 'Profil sichern';

  @override
  String get profileOptionsBackupSubtitle =>
      'Profil, Decks, Spiele und Feedback auf diesem Telefon speichern';

  @override
  String get profilePicTitle => 'Profilbild';

  @override
  String profilePicNoCards(String query) {
    return 'Keine Karten für „$query“';
  }

  @override
  String get profilePicSearchFailed =>
      'Suche fehlgeschlagen. Internet prüfen und erneut versuchen.';

  @override
  String get profilePicPhotoFailed =>
      'Foto nicht nutzbar. Anderes Bild versuchen.';

  @override
  String get profilePicCommander => 'Commander';

  @override
  String get profilePicDefault => 'Standard';

  @override
  String get profilePicRemove => 'Entfernen';

  @override
  String get profilePicUpload => 'Foto hochladen';

  @override
  String get profilePicTake => 'Foto aufnehmen';

  @override
  String get profilePicOrSearch => 'Oder MTG-Kartenkunst suchen';

  @override
  String get profilePicSearchHint => 'MTG-Karten für Profilbild suchen…';

  @override
  String get profilePicHelp =>
      'Foto hochladen, aufnehmen oder Karte suchen—deren Art wird dein Profilbild.';

  @override
  String get ranksInfoTitle => 'Ränge & Level';

  @override
  String get ranksInfoBody =>
      'Level ist dein genauer Fortschritt. Rang ist der Titel deiner Level-Bande. Metall-Tiers gruppieren diese Ränge.';

  @override
  String ranksInfoLevelRange(int min, int max) {
    return 'Lv $min–$max';
  }

  @override
  String get statsPlayerBehaviour => 'Verhalten';

  @override
  String get statsMostPlayed => 'Meistgespielt';

  @override
  String get statsNoDeckStatsYet => 'Noch keine Deck-Stats.';

  @override
  String get statsToughRecord => 'Schwierige Bilanz';

  @override
  String get statsNoLossesOnDeck =>
      'Noch keine Niederlagen mit gespeichertem Deck.';

  @override
  String get statsPlayerStats => 'Spieler-Stats';

  @override
  String get statsSingularUnit => 'Stat';

  @override
  String get statsPluralUnit => 'Stats';

  @override
  String get statsLeaningGood => 'eher gut';

  @override
  String get statsLeaningSalty => 'eher salty';

  @override
  String get statsLeaningNeutral => 'neutral';

  @override
  String statsBehaviourA11y(String leaning) {
    return 'Verhaltensspektrum, $leaning';
  }

  @override
  String get statsRecord => 'Bilanz';

  @override
  String get statsWinRate => 'Siegrate';

  @override
  String statsRecordFooter(int wins, int losses, int games) {
    return '${wins}S–${losses}N  ·  $games Spiele';
  }

  @override
  String get statsWinStreak => 'Siegesserie';

  @override
  String get statsWinToStartStreak => 'Siegen für eine Serie';

  @override
  String get statsPersonalBest => 'Persönliche Bestmarke';

  @override
  String statsBestStreak(int best) {
    return 'Beste: $best';
  }

  @override
  String get statsNoActiveStreak => 'Keine aktive Serie';

  @override
  String get statsCurrent => 'Aktuell';

  @override
  String statsLevelShort(int level) {
    return 'Lv $level';
  }

  @override
  String get statsLevelProgress => 'Level-Fortschritt';

  @override
  String get statsLevelProgressA11y =>
      'Level-Fortschritt. Alle Ränge anzeigen.';

  @override
  String get statsGood => 'Gut';

  @override
  String get statsNeutral => 'Neutral';

  @override
  String get statsSalty => 'Salty';

  @override
  String get profileBackupSaveFailed =>
      'Backup konnte nicht gespeichert werden.';

  @override
  String get profileUsernameLabel => 'Benutzername';

  @override
  String get profileUsernameHint => 'z. B. The Archduke';

  @override
  String get profileUsernameRequired => 'Benutzername eingeben';

  @override
  String get profileUsernameTooShort => 'Mindestens 2 Zeichen';

  @override
  String get profileSetupUsernameHint => 'z. B. The Archduke';

  @override
  String carouselFilterTooltip(String label) {
    return 'Filter: $label';
  }

  @override
  String carouselRecentMatchA11y(String result, String format) {
    return 'Letztes Match, $result, $format';
  }

  @override
  String get carouselCloseReturnsSummary =>
      'Schließen bringt zur Übersicht zurück';

  @override
  String get carouselShowMoreDetails =>
      'Mehr für volle Match-Details, oder Karte tippen';

  @override
  String get decksClearSearchTooltip => 'Löschen';

  @override
  String get settingsDefaultFormatSheetTitle => 'Standardformat';

  @override
  String get settingsDefaultStartingLifeSheetTitle => 'Standard-Startleben';

  @override
  String settingsAboutVersionBeta(String version) {
    return 'Life Spark v$version · Beta';
  }

  @override
  String get settingsAboutByAuthor => 'von Federick Vidot';

  @override
  String get settingsAboutCardDataPoweredBy => 'Kartendaten von';

  @override
  String get settingsAboutScryfall => 'Scryfall';

  @override
  String get settingsAboutDisclaimer =>
      'Life Spark ist inoffizieller Fan Content gemäß Fan Content Policy. Nicht von Wizards genehmigt/unterstützt. Teile des Materials gehören Wizards of the Coast. ©Wizards of the Coast LLC.';

  @override
  String get feedbackLike => 'Like';

  @override
  String get feedbackClearLike => 'Like entfernen';

  @override
  String get feedbackDislike => 'Dislike';

  @override
  String get feedbackClearDislike => 'Dislike entfernen';

  @override
  String get feedbackSparkOfTheGame => 'Funke der Partie';

  @override
  String get feedbackSparkHint => 'Optional — einen Spieler wählen';

  @override
  String get feedbackNoneOption => '— Keiner —';

  @override
  String tierBadgeLabel(String rank, int level) {
    return '$rank · Lv $level';
  }

  @override
  String tierBadgeA11y(String label) {
    return 'Rang $label. Alle Ränge anzeigen.';
  }

  @override
  String get tierBronze => 'Bronze';

  @override
  String get tierSilver => 'Silber';

  @override
  String get tierGold => 'Gold';

  @override
  String get tierPlatinum => 'Platin';

  @override
  String get tierDiamond => 'Diamant';

  @override
  String get rankApprentice => 'Lehrling';

  @override
  String get rankNeophyte => 'Neophyt';

  @override
  String get rankAdept => 'Adept';

  @override
  String get rankEvoker => 'Evoker';

  @override
  String get rankThaumaturge => 'Thaumaturg';

  @override
  String get rankEnchanter => 'Verzauberer';

  @override
  String get rankSummoner => 'Beschwörer';

  @override
  String get rankArcanist => 'Arkanist';

  @override
  String get rankMagus => 'Magus';

  @override
  String get rankWarWizard => 'Kriegsmagier';

  @override
  String get rankHighMagus => 'Hoher Magus';

  @override
  String get rankSpellbinder => 'Zauberbinder';

  @override
  String get rankArchmage => 'Erzmagier';

  @override
  String get rankHighArchmage => 'Hoher Erzmagier';

  @override
  String get rankPlanewright => 'Planewright';

  @override
  String get rankGrandArchmage => 'Groß-Erzmagier';

  @override
  String get rankVoidcaller => 'Voidcaller';

  @override
  String get rankArchwizard => 'Archwizard';

  @override
  String get rankSpireLegend => 'Spire-Legende';

  @override
  String get rankAscendantArchon => 'Aufgestiegener Archon';

  @override
  String get deckTileWinRateAbbr => 'WR';

  @override
  String get deckTileWinsAbbr => 'S';

  @override
  String get deckTileLossesAbbr => 'N';

  @override
  String get deckTileGamesAbbr => 'SP';

  @override
  String get brandLifeSpark => 'Life Spark';

  @override
  String get hostTogglePlanechase => 'Planechase';

  @override
  String get hostToggleArchenemy => 'Archenemy';

  @override
  String get hostToggleBounty => 'Bounty';

  @override
  String get lookupClearTooltip => 'Löschen';

  @override
  String phaseNavCurrentA11y(String phase) {
    return 'Aktuelle Phase, $phase';
  }

  @override
  String cmdDmgThreatHelp(int ko) {
    return 'Schaden, den jeder Commander dir zugefügt hat — $ko eliminiert.';
  }

  @override
  String get cmdDmgEmptyPod =>
      'Gegner erscheinen hier, wenn andere dem Tisch beitreten.';

  @override
  String get statusOut => 'RAUS';

  @override
  String infoBarAlly(String name) {
    return 'Verbündeter · $name';
  }

  @override
  String get infoBarAllySecret => 'geheim';

  @override
  String get gamePlayerDataUnavailable => 'Spielerdaten nicht verfügbar';

  @override
  String get startupErrorTitle => 'Startfehler';

  @override
  String get startupStackTrace => 'Stacktrace:';

  @override
  String get paletteViolet => 'Violett';

  @override
  String get paletteCrimson => 'Karmesin';

  @override
  String get paletteSlate => 'Schiefer';

  @override
  String get paletteForest => 'Wald';

  @override
  String get paletteObsidian => 'Obsidian';

  @override
  String get paletteFog => 'Nebel';

  @override
  String networkCannotReachHost(String error) {
    return 'Host nicht erreichbar: $error';
  }

  @override
  String get backupFileTypeLabel => 'Life-Spark-Backup';

  @override
  String get backupNotValidFile => 'Keine Life-Spark-Backup-Datei.';

  @override
  String get backupNotValidJson => 'Backup-Datei ist kein gültiges JSON.';

  @override
  String get backupCouldNotRead =>
      'Ausgewählte Backup-Datei konnte nicht gelesen werden.';

  @override
  String logLifeChange(String name, String delta) {
    return '$name: Leben $delta';
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
    return '$name hat dein Leben geändert $delta';
  }

  @override
  String logCounterChangedYours(String name, String counter, String delta) {
    return '$name hat dein $counter geändert $delta';
  }

  @override
  String logEndsTurn(String name) {
    return '$name beendet den Zug';
  }

  @override
  String logCmdDmgDealtYou(String name, String delta) {
    return '$name hat dir $delta Commanderschaden zugefügt';
  }

  @override
  String logCmdDmgYouDealt(String name, String delta) {
    return 'Du hast $name $delta Commanderschaden zugefügt';
  }

  @override
  String logCmdDmgOther(String from, String to, String delta) {
    return '$from → $to: Commanderschaden $delta';
  }

  @override
  String get logTurnOrderUpdated => 'Zugreihenfolge vom Host aktualisiert';

  @override
  String get logProliferate => 'Proliferate: alle Spieler';

  @override
  String logAllianceRevealed(String a, String b) {
    return 'Allianz enthüllt: $a & $b';
  }

  @override
  String logAllianceBetrayal(String a, String b) {
    return 'Allianz gebrochen — Verrat: $a & $b';
  }

  @override
  String get logAllianceBroken => 'Allianz gebrochen';

  @override
  String logAllianceFormed(String a, String b, String duration) {
    return 'Geheime Allianz geschlossen: $a & $b ($duration)';
  }

  @override
  String logPlayerLeft(String name) {
    return '$name hat das Spiel verlassen';
  }

  @override
  String logRolled(String name, String result) {
    return '$name hat eine $result gewürfelt';
  }

  @override
  String logFlipped(String name, String result) {
    return '$name hat $result geworfen';
  }

  @override
  String logStackAdded(String name, String item) {
    return '$name hat „$item“ hinzugefügt';
  }

  @override
  String logStackAddedResponse(String name, String item) {
    return '$name hat „$item“ hinzugefügt (Antwort)';
  }

  @override
  String logStackRenamed(String name, String item) {
    return '$name hat Stack-Eintrag in „$item“ umbenannt';
  }

  @override
  String logStackStatus(String name, String item, String status) {
    return '${name}s „$item“ $status';
  }

  @override
  String get logClearedStack => 'Stack geleert';

  @override
  String get logCounterPoison => 'Gift';

  @override
  String get logCounterEnergy => 'Energie';

  @override
  String get logCounterExperience => 'Erfahrung';

  @override
  String get logCounterRad => 'Rad';

  @override
  String get logCounterBlood => 'Blut';

  @override
  String get logCounterClue => 'Hinweis';

  @override
  String get logCounterMap => 'Karte';

  @override
  String get logCounterTreasure => 'Schatz';

  @override
  String get logCounterDevotion => 'Hingabe';

  @override
  String get logCounterCreatures => 'Kreaturen';

  @override
  String get logCounterEnchantments => 'Verzauberungen';

  @override
  String get logCounterArtifacts => 'Artefakte';

  @override
  String get logCounterGyCreatures => 'Friedhof-Kreaturen';

  @override
  String get logCounterExile => 'Exil';

  @override
  String get logStackStatusFizzled => 'fehlgeschlagen';

  @override
  String get logStackStatusCountered => 'neutralisiert';

  @override
  String get logStackStatusResolved => 'verrechnet';

  @override
  String get logStackStatusReactivated => 'reaktiviert';

  @override
  String get logDurationEndOfTurn => 'Bis zum Ende des Zuges';

  @override
  String get logDurationEndOfRound => 'Bis zum Ende der Runde';

  @override
  String get logDurationUntilBroken => 'Bis zum Bruch';

  @override
  String get logHeads => 'Kopf';

  @override
  String get logTails => 'Zahl';
}
