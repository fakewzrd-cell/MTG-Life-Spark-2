// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Life Spark';

  @override
  String get navProfile => 'Profil';

  @override
  String get navLobby => 'Salon';

  @override
  String get navDecks => 'Decks';

  @override
  String get navSettings => 'Réglages';

  @override
  String get settingsTitle => 'Réglages';

  @override
  String get settingsSectionGameplay => 'Jeu';

  @override
  String get settingsDefaultFormat => 'Format par défaut';

  @override
  String settingsDefaultFormatSubtitle(String format) {
    return '$format · utilisé quand vous hébergez';
  }

  @override
  String get settingsDefaultStartingLife => 'Points de vie de départ';

  @override
  String settingsDefaultStartingLifeSubtitle(int life) {
    return '$life PV · utilisés quand vous hébergez';
  }

  @override
  String get settingsSectionMisc => 'Divers';

  @override
  String get settingsKeepDisplayAwake => 'Garder l’écran allumé';

  @override
  String get settingsKeepDisplayAwakeSubtitle =>
      'Empêche la mise en veille pendant une partie';

  @override
  String get settingsHideSystemBars =>
      'Masquer les barres de navigation et d’état';

  @override
  String get settingsHideSystemBarsSubtitle => 'Plein écran pendant le jeu';

  @override
  String get settingsSectionAppearance => 'Apparence';

  @override
  String get settingsDarkAppearance => 'Apparence sombre';

  @override
  String get settingsDarkAppearanceSubtitle =>
      'Le mode clair utilise des fonds doux — essayez Fog ou Slate';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get settingsLanguageSystem => 'Langue du système';

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
  String get settingsSectionFeel => 'Sensation';

  @override
  String get settingsHapticFeedback => 'Retour haptique';

  @override
  String get settingsHapticFeedbackSubtitle =>
      'Vibrer lors des changements de vie et des montées de rang';

  @override
  String get settingsShakeToUndo => 'Secouer pour annuler';

  @override
  String get settingsShakeToUndoSubtitle =>
      'Secouez le téléphone pour annuler le dernier changement de vie';

  @override
  String get settingsSectionData => 'Données';

  @override
  String get settingsCacheCommanderImages =>
      'Mettre en cache les images de commandant';

  @override
  String get settingsCacheCommanderImagesSubtitle =>
      'Stocke les images Scryfall pour une utilisation hors ligne';

  @override
  String get settingsClearImageCache => 'Vider le cache d’images';

  @override
  String get settingsClearImageCacheSubtitle =>
      'Libère l’espace des images de cartes en cache';

  @override
  String get settingsSaveBackup => 'Enregistrer une sauvegarde';

  @override
  String get settingsSaveBackupSubtitle =>
      'Enregistre profil, decks, réglages, parties récentes et avis dans un fichier';

  @override
  String get settingsRestoreBackup => 'Restaurer une sauvegarde';

  @override
  String get settingsRestoreBackupSubtitle =>
      'Remplace toutes les données locales depuis un fichier .lifespark';

  @override
  String get settingsSectionHelp => 'Aide';

  @override
  String get settingsFeedback => 'Commentaires';

  @override
  String get settingsFeedbackSubtitle =>
      'Envoyez-nous vos idées et suggestions';

  @override
  String get settingsViewHubGuide => 'Voir le guide du hub';

  @override
  String get settingsViewHubGuideSubtitle =>
      'Comment Jouer, Pile, Recherche et Table fonctionnent en partie';

  @override
  String get settingsViewTutorialAgain => 'Revoir le tutoriel';

  @override
  String get settingsViewTutorialAgainSubtitle =>
      'Relancer le parcours d’accueil';

  @override
  String get settingsBeta => 'Bêta';

  @override
  String get commonCancel => 'Annuler';

  @override
  String get commonSave => 'Enregistrer';

  @override
  String get commonAdd => 'Ajouter';

  @override
  String get commonRemove => 'Retirer';

  @override
  String get commonClose => 'Fermer';

  @override
  String get commonTryAgain => 'Réessayer';

  @override
  String get backupSaved => 'Sauvegarde enregistrée.';

  @override
  String get backupSaveFailed => 'Impossible d’enregistrer la sauvegarde.';

  @override
  String backupRestoreTitle(String username) {
    return 'Restaurer $username ?';
  }

  @override
  String get backupRestoreMessage =>
      'Cela remplace votre profil, decks, réglages, parties récentes, sparks et comportement sur cet appareil par la sauvegarde sélectionnée.';

  @override
  String get backupRestoreConfirm => 'Restaurer';

  @override
  String backupRestored(String username) {
    return 'Sauvegarde restaurée pour $username.';
  }

  @override
  String get backupRestoreFailed =>
      'Impossible de restaurer la sauvegarde. Vérifiez le fichier et réessayez.';

  @override
  String get cacheCleared => 'Cache d’images vidé.';

  @override
  String get cacheClearFailed => 'Impossible de vider le cache d’images.';

  @override
  String get decksTitle => 'Decks';

  @override
  String get decksAddDeck => 'Ajouter un deck';

  @override
  String get profileTitle => 'Profil';

  @override
  String get profileRecentGames => 'Parties récentes';

  @override
  String get profileDeckPerformance => 'Performance des decks';

  @override
  String get lobbyTitle => 'Salon';

  @override
  String get lobbyHostGame => 'Héberger une partie';

  @override
  String get lobbyHostGameSubtitle =>
      'Créez une session — les autres vous rejoignent';

  @override
  String get lobbyJoinGame => 'Rejoindre';

  @override
  String get lobbyJoinGameSubtitle => 'Scannez un hôte à proximité';

  @override
  String get hostLobbyTitle => 'Salon de l’hôte';

  @override
  String get hostLeaveLobbyTooltip => 'Quitter le salon';

  @override
  String hostPlayersScanQr(int count, int max) {
    return 'Joueurs : $count / $max  •  Scannez le QR pour rejoindre';
  }

  @override
  String get hostNeedWifiRetry =>
      'Connectez cet appareil au Wi‑Fi (même réseau que les invités), puis appuyez sur Réessayer.';

  @override
  String get hostNeedsMobileApp =>
      'Héberger nécessite l’app mobile (iOS ou Android) sur le même Wi‑Fi. Le navigateur peut rejoindre en scannant un QR, mais ne peut pas héberger.';

  @override
  String get hostNeedsMobileOrDev =>
      'Héberger nécessite l’app mobile ou un build local de développement.';

  @override
  String get hostCreateProfileFirst =>
      'Créez d’abord votre profil (Accueil → définir le nom), puis appuyez sur Réessayer.';

  @override
  String get hostCouldNotStartServer =>
      'Impossible de démarrer le serveur sur cet appareil. Appuyez sur Réessayer.';

  @override
  String get hostSessionDidNotStart =>
      'La session hôte n’a pas démarré. Appuyez sur Réessayer.';

  @override
  String get hostCouldNotShowQr =>
      'Impossible d’afficher le QR pour rejoindre.';

  @override
  String get hostRetry => 'Réessayer';

  @override
  String get hostNeedOnePlayer => 'Il faut au moins 1 joueur';

  @override
  String get hostEveryoneMustBeReady => 'Tout le monde doit être prêt';

  @override
  String get hostStartGame => 'Lancer la partie';

  @override
  String hostOpenSlots(int count) {
    return '$count place(s) libre(s) — partagez l’appareil pour que vos amis rejoignent';
  }

  @override
  String get hostMatchLabel => 'Libellé';

  @override
  String get hostMatchLabelHelp =>
      'Facultatif. Aide à retrouver cette partie dans les Récentes.';

  @override
  String get hostMatchLabelHint => 'ex. EDH du vendredi';

  @override
  String get hostGameSettings => 'Paramètres de partie';

  @override
  String get hostFormat => 'Format';

  @override
  String get hostStartingLife => 'Points de vie de départ';

  @override
  String get hostCustomStartingLifeTitle => 'Vie de départ personnalisée';

  @override
  String get hostCustomStartingLifeHint => 'Entrez le total de vie (1–999)';

  @override
  String get hostCustomEllipsis => 'Personnalisé…';

  @override
  String get hostGameplay => 'Jeu';

  @override
  String get hostToggleTeams => 'Équipes';

  @override
  String get hostToggleTeamsSubtitle =>
      'Attribuez les couleurs d’équipe à table';

  @override
  String get hostTogglePlanechaseSubtitle =>
      'Internet requis pour le deck planar';

  @override
  String get hostToggleArchenemySubtitle =>
      'Internet requis pour le deck de schemes';

  @override
  String get hostToggleBountySubtitle => 'Internet requis pour le deck Bounty';

  @override
  String get hostToggleAutoKo => 'Auto-KO';

  @override
  String get hostToggleAutoKoSubtitle =>
      'Par vie, poison ou dégâts de commander';

  @override
  String get hostToggleCommanderDmgLife =>
      'Dégâts de commander réduisent la vie';

  @override
  String get hostToggleCommanderDmgLifeSubtitle =>
      'Les dégâts de commander réduisent aussi la vie';

  @override
  String get hostTogglePhaseTracker => 'Suivi des phases';

  @override
  String get hostTogglePhaseTrackerSubtitle =>
      'Affiche les phases avec Retour et Suivant';

  @override
  String get hostToggleTurnTimer => 'Minuteur de tour';

  @override
  String get hostToggleTurnTimerSubtitle =>
      'Affiche le temps écoulé à chaque tour';

  @override
  String get hostTurnLimit => 'Limite de tour';

  @override
  String get hostTurnLimitOff => 'Désactivé';

  @override
  String hostTurnLimitSeconds(int seconds) {
    return '$seconds secondes';
  }

  @override
  String get hostNoCommanderSelected => 'Aucun commander sélectionné';

  @override
  String get hostNoDeckSelected => 'Aucun deck sélectionné';

  @override
  String hostTrackingDeck(String name) {
    return 'Suivi : $name';
  }

  @override
  String get hostDeckListChanged => 'Deck (liste enregistrée modifiée)';

  @override
  String get hostSelectDeck => 'Deck';

  @override
  String get hostSelectCommander => 'Commander';

  @override
  String get hostMarkReady => 'Marquer prêt';

  @override
  String get hostMarkNotReady => 'Marquer pas prêt';

  @override
  String get lobbyReady => 'Prêt';

  @override
  String get lobbyWaiting => 'En attente';

  @override
  String get deckPickerTitle => 'Deck pour cette partie';

  @override
  String get deckPickerManualOnly => 'Commander manuel uniquement';

  @override
  String get deckPickerManualOnlySubtitle =>
      'Gardez les commanders tels quels ; ne les associez pas à un deck enregistré';

  @override
  String deckPickerEmptyForFormat(String format) {
    return 'Aucun deck $format enregistré. Créez-en un dans l’onglet Decks.';
  }

  @override
  String get deckPickerOpenDecks => 'Ouvrir Decks';

  @override
  String get joinTitle => 'Rejoindre une partie';

  @override
  String get joinLeaveTooltip => 'Quitter';

  @override
  String get joinPointCamera => 'Pointez la caméra vers le QR de l’hôte';

  @override
  String get joinCameraRequiredSnack =>
      'L’autorisation caméra est requise pour scanner le QR de l’hôte.';

  @override
  String get joinCameraDeniedBody =>
      'L’accès à la caméra est nécessaire pour scanner le QR de l’hôte.\\nSi vous l’avez déjà autorisé dans Réglages, appuyez sur Réessayer.';

  @override
  String get joinOpenSettings => 'Ouvrir Réglages';

  @override
  String get joinInvalidQr => 'Ce n’est pas un QR Life Spark valide.';

  @override
  String get joinMissingToken =>
      'Ce QR n’a pas de jeton d’accès. Demandez à l’hôte de rafraîchir son QR.';

  @override
  String get joinCouldNotStartSession =>
      'Impossible de démarrer la session. Terminez le profil et réessayez.';

  @override
  String get joinConnectTimeout =>
      'Délai de connexion dépassé. Vérifiez que vous êtes sur le même Wi‑Fi et que le salon de l’hôte est encore ouvert, puis réessayez.';

  @override
  String get joinHostRejected =>
      'L’hôte a refusé la connexion (versions incompatibles).';

  @override
  String get joinDisconnected => 'Déconnecté de l’hôte.';

  @override
  String get joinConnectionError => 'Erreur de connexion.';

  @override
  String get joinHostEndedSession => 'L’hôte a terminé la session.';

  @override
  String get joinConnecting => 'Connexion à l’hôte…';

  @override
  String get joinWaitingForHost => 'En attente du démarrage par l’hôte…';

  @override
  String get joinSelectDeck => 'Choisir un deck';

  @override
  String get joinSelectCommander => 'Choisir un commander';

  @override
  String get joinReady => 'Prêt';

  @override
  String get joinMarkReady => 'Marquer prêt';

  @override
  String get welcomeTagline => 'Votre compagnon MTG.';

  @override
  String get welcomeReadyToPlay => 'Prêt à jouer';

  @override
  String get welcomeSkip => 'Passer';

  @override
  String get onboardingSlide1Title => 'Bienvenue sur Life Spark';

  @override
  String get onboardingSlide1Body =>
      'Votre compagnon de table Commander — vie, marqueurs, politique et pile, synchronisés à table.';

  @override
  String get onboardingSlide2Title => 'Héberger ou rejoindre';

  @override
  String get onboardingSlide2Body =>
      'Un joueur héberge — les autres scannent un QR sur le même réseau Wi‑Fi. Pas de compte internet. Pour 4 à 6 joueurs à la même table.';

  @override
  String get onboardingSlide3Title => 'Suivez votre vie';

  @override
  String get onboardingSlide3Body =>
      'Appuyez sur +/- pour changer la vie de 1. Maintenez +/- pour ±5. Glissez à gauche ou à droite pour ajuster vite. Double-tapez le total pour un nombre exact. Annuler est dans la barre du bas (ou secouez, si activé).';

  @override
  String get onboardingSlide4Title => 'Phases et tours';

  @override
  String get onboardingSlide4Body =>
      'Utilisez la barre de phases pour avancer le tour, ou laissez le suivi désactivé dans le salon. La pause met toute la partie en pause.';

  @override
  String get onboardingSlide5Title => 'Commander et marqueurs';

  @override
  String get onboardingSlide5Body =>
      'Les dégâts de commander s’ouvrent en liste de menaces — combien chaque adversaire vous a infligé vers 21. Suivez poison (10), energy, experience et rad. Utilisez Proliferate pour ajouter 1 à tous d’un coup.';

  @override
  String get onboardingSlide6Title => 'Alliances et politique';

  @override
  String get onboardingSlide6Body =>
      'Proposez des alliances secrètes. Elles expirent seules ou se brisent si vous vous attaquez. Suivez Monarch et Initiative en un tap.';

  @override
  String get onboardingNext => 'Suivant';

  @override
  String get onboardingReadyToPlay => 'Prêt à jouer';

  @override
  String get onboardingSkip => 'Passer';

  @override
  String get profileSetupTitle => 'Créez votre profil';

  @override
  String get profileSetupSubtitle =>
      'Choisissez un nom et une photo que votre table reconnaîtra.';

  @override
  String get profileSetupUsername => 'Nom d’utilisateur';

  @override
  String get profileSetupUsernameRequired => 'Entrez un nom d’utilisateur';

  @override
  String get profileSetupUsernameTooShort => 'Au moins 2 caractères';

  @override
  String get profileSetupChoosePicture => 'Choisir une photo de profil';

  @override
  String get profileSetupChangePicture => 'Changer la photo';

  @override
  String get profileSetupContinue => 'Continuer';

  @override
  String get sessionLeaveTitle => 'Quitter la partie active ?';

  @override
  String get sessionLeaveMessage =>
      'Vous avez un salon ou une partie en cours. Quitter déconnectera les autres joueurs à table.';

  @override
  String get sessionLeaveConfirm => 'Quitter';

  @override
  String get sessionLeaveStay => 'Rester';

  @override
  String get gameLeaveTitle => 'Quitter la partie ?';

  @override
  String get gameLeaveMessageActive =>
      'Vous quitterez la partie et rentrerez à l’accueil. Les statistiques ne se sauvent que lorsque la table termine la partie.';

  @override
  String get gameLeaveMessageAfterConcede =>
      'Vous quitterez la partie en direct et rentrerez à l’accueil. Votre résultat d’abandon sera enregistré avant la déconnexion.';

  @override
  String get gameTabPlay => 'Jouer';

  @override
  String get gameTabStack => 'Pile';

  @override
  String get gameTabLookupSemantics => 'Consulter les règles d’une carte';

  @override
  String get gameBarHome => 'Accueil';

  @override
  String get gameBarUndo => 'Annuler';

  @override
  String get gameBarTimeout => 'Pause';

  @override
  String get gameBarEnd => 'Fin';

  @override
  String get gameBarTable => 'Table';

  @override
  String get gameEndTurn => 'Fin du tour';

  @override
  String gameWaitingForPlayer(String name) {
    return 'En attente de $name…';
  }

  @override
  String get gamePhaseBack => 'Retour';

  @override
  String get gamePhaseNext => 'Suivant';

  @override
  String get gameChoosePhase => 'Choisir la phase';

  @override
  String get gameYourTurn => 'Votre tour';

  @override
  String get gameYourTurnTapContinue => 'Appuyez pour continuer';

  @override
  String get gameYourTurnSemantics => 'Votre tour. Double-tapez pour fermer.';

  @override
  String get gameNowPlaying => 'EN JEU';

  @override
  String get gameActiveTurn => 'TOUR ACTIF';

  @override
  String gamePlayersTurn(String name) {
    return 'Tour de $name';
  }

  @override
  String get gameCurrentTurn => 'Tour actuel';

  @override
  String get timeoutStartTitle => 'Démarrer la pause';

  @override
  String get timeout15Seconds => '15 secondes';

  @override
  String get timeout30Seconds => '30 secondes';

  @override
  String get timeout1Minute => '1 minute';

  @override
  String get timeoutBanner => 'PAUSE';

  @override
  String get timeoutPaused => 'Partie en pause — aucun changement de vie';

  @override
  String get timeoutEnd => 'Fin de la pause';

  @override
  String timeoutMinimized(String time) {
    return 'Pause — $time';
  }

  @override
  String get timeoutMinimizeTooltip => 'Réduire le minuteur';

  @override
  String get reconnectToTable => 'Reconnexion à la table…';

  @override
  String get reconnectStillTrying => 'Toujours en train de joindre la table…';

  @override
  String reconnectPeerOne(String name) {
    return '$name se reconnecte…';
  }

  @override
  String reconnectPeerMany(int count) {
    return '$count joueurs se reconnectent…';
  }

  @override
  String get forfeitTitle => 'Abandonner ?';

  @override
  String get forfeitBodyMulti =>
      'Vous quitterez la partie. Vous pouvez noter les adversaires avant de partir.';

  @override
  String get forfeitBodySolo =>
      'Votre partie d’entraînement se terminera. Vous pouvez noter comment ça s’est passé.';

  @override
  String get forfeitRateOpponents => 'Noter les adversaires';

  @override
  String get forfeitConfirm => 'Abandonner';

  @override
  String get forfeitYouForfeited => 'Vous avez abandonné';

  @override
  String get forfeitStaySpectateBody =>
      'Les autres peuvent continuer. Restez sur cet appareil pour regarder jusqu’à la fin. Retourner au profil maintenant enregistre votre abandon et vous déconnecte de la partie en direct.';

  @override
  String get forfeitStaySpectate => 'Rester et regarder';

  @override
  String get forfeitReturnToProfile => 'Retour au profil';

  @override
  String get gamePlayerLeftTitle => 'Joueur parti';

  @override
  String gamePlayerLeftMessage(String username) {
    return '$username a quitté la partie.';
  }

  @override
  String get gameSessionEndedTitle => 'Session terminée';

  @override
  String get gameSessionEndedMessage => 'L’hôte a terminé la partie.';

  @override
  String gamePeerOfflineTitle(String username) {
    return '$username toujours hors ligne';
  }

  @override
  String get gamePeerOfflineBody =>
      'Continuer d’attendre la reconnexion, ou le retirer de la table ?';

  @override
  String get gameKeepWaiting => 'Continuer d’attendre';

  @override
  String get gameRemoveFromTable => 'Retirer de la table';

  @override
  String get gameSlotLoadFailedTitle => 'Impossible de charger votre place';

  @override
  String get gameSlotLoadFailedBody =>
      'La partie peut être désynchronisée. Retournez au salon et rejoignez.';

  @override
  String get gameReturnToLobby => 'Retour au salon';

  @override
  String get profileSetupPrompt => 'Configurez votre profil pour continuer.';

  @override
  String get profileCreateCta => 'Créer un profil';

  @override
  String get profileNewPlayer => 'Nouveau joueur';

  @override
  String profilePlayingSince(String date) {
    return 'Joue depuis $date';
  }

  @override
  String get profileOptions => 'Options du profil';

  @override
  String get profileDoneEditing => 'Terminé';

  @override
  String get profileDone => 'Terminé';

  @override
  String get profileEditName => 'Modifier le nom';

  @override
  String get profileEditNameTooltip => 'Modifier le nom';

  @override
  String get profileChangePicture => 'Changer la photo de profil';

  @override
  String get profileStatRecord => 'Bilan';

  @override
  String get profileStatSparks => 'Sparks';

  @override
  String get profileStatGames => 'Parties';

  @override
  String get profileEmptyRecentGames =>
      'Jouez votre première partie pour débloquer les statistiques et l’historique.';

  @override
  String get profileEmptyDeckPerf =>
      'Ajoutez un deck pour suivre les perfs du commander ici.';

  @override
  String get profileFilterAllGames => 'Toutes';

  @override
  String get profileFilterRecent14 => 'Récentes (14 jours)';

  @override
  String get profileFilterThisWeek => 'Cette semaine';

  @override
  String get profileFilterThisMonth => 'Ce mois';

  @override
  String get profileNoMatchesFilter => 'Aucune partie pour ce filtre.';

  @override
  String get profileOpenLobbySemantics =>
      'Ouvrir le salon pour héberger ou rejoindre une partie';

  @override
  String get profileShowMore => 'Voir plus';

  @override
  String get profileStandings => 'Classement';

  @override
  String get profileNoPlayerDetails =>
      'Aucun détail de joueur enregistré pour cette partie.';

  @override
  String get profileResultConcede => 'Abandon';

  @override
  String get profileResultLoss => 'Défaite';

  @override
  String get decksEmptyTitle => 'Construisez votre bibliothèque de decks';

  @override
  String get decksEmptyBody =>
      'Enregistrez un deck avec nom, format et carte de couverture. En hébergeant ou rejoignant, choisissez la liste dans le salon.';

  @override
  String get decksSearchHint => 'Rechercher des decks…';

  @override
  String decksNoSearchMatches(String query) {
    return 'Aucun deck ne correspond à “$query”.';
  }

  @override
  String get decksStyleNotSet => 'Style non défini';

  @override
  String get decksNoCoverCard => 'Pas de carte de couverture';

  @override
  String get lookupTitle => 'Recherche de carte';

  @override
  String get lookupHint => 'Recherchez n’importe quelle carte MTG…';

  @override
  String get lookupHelp => 'Texte Oracle et rulings officiels via Scryfall.';

  @override
  String get lookupEmptyPrompt => 'Tapez un nom de carte pour voir les règles.';

  @override
  String lookupNoResults(String query) {
    return 'Aucune carte trouvée pour “$query”.';
  }

  @override
  String get lookupNetworkError =>
      'Impossible d’atteindre Scryfall. Vérifiez la connexion.';

  @override
  String get lookupSearch => 'Rechercher';

  @override
  String get lookupOracleText => 'Texte Oracle';

  @override
  String get lookupNoOracle => 'Pas de texte Oracle pour cette carte.';

  @override
  String get lookupRulings => 'Rulings';

  @override
  String get lookupNoRulings => 'Aucun ruling officiel pour cette carte.';

  @override
  String get endGameSavingResults => 'Enregistrement des résultats…';

  @override
  String get endGameSaveFailedTitle =>
      'Impossible d’enregistrer les résultats.';

  @override
  String get endGameSaveFailedBody =>
      'Vos stats n’ont peut‑être pas été mises à jour. Réessayez.';

  @override
  String get endGameRetry => 'Réessayer';

  @override
  String get endGameContinueWithoutSaving => 'Continuer sans enregistrer';

  @override
  String get endGameFinalStandings => 'Classement final';

  @override
  String get endGameOverNoWinner => 'Fin de partie — Pas de vainqueur';

  @override
  String get endGamePracticeEnded => 'Entraînement terminé';

  @override
  String get endGameYouWin => 'Vous gagnez !';

  @override
  String get endGameWinner => 'Vainqueur';

  @override
  String get endGameRankUp => 'MONTÉE DE RANG !';

  @override
  String endGameRankTransition(int oldLevel, int newLevel) {
    return 'Rang $oldLevel → $newLevel';
  }

  @override
  String endGameXpGained(int xp) {
    return '+$xp XP';
  }

  @override
  String get endGameWinBonusIncluded => 'Bonus de victoire inclus';

  @override
  String get endGameParticipationXp => 'XP de participation';

  @override
  String endGameRankLevel(int level) {
    return 'Rang $level';
  }

  @override
  String get endGameFeedbackThanks => 'Merci ! Votre avis a été enregistré.';

  @override
  String get endGameRateOpponents => 'Évaluez vos adversaires';

  @override
  String get endGameSubmitFeedback => 'Envoyer l’avis';

  @override
  String get endGameYouSuffix => '(vous)';

  @override
  String get endGameElimReasonLife => 'Vie épuisée';

  @override
  String get endGameElimReasonPoison => '10 poison';

  @override
  String get endGameElimReasonCommanderDmg => 'Dégâts Commander';

  @override
  String get endGameElimReasonConcede => 'Abandon';

  @override
  String get endGameElimReasonDisconnect => 'A quitté la partie';

  @override
  String get endGameElimReasonDefault => 'Éliminé';

  @override
  String get endGameBackToHome => 'Retour à l’accueil';

  @override
  String get feedbackTitle => 'Commentaires';

  @override
  String get feedbackHeadline => 'Aidez-nous à améliorer';

  @override
  String get feedbackBody => 'Un bug ? Une idée ? Nous lisons chaque message.';

  @override
  String get feedbackMessageLabel => 'Votre message';

  @override
  String get feedbackMessageHint => 'Dites-nous ce que vous en pensez...';

  @override
  String get feedbackSend => 'Envoyer le commentaire';

  @override
  String get feedbackOrDivider => 'ou';

  @override
  String get feedbackRatePlayStore => 'Noter sur le Play Store';

  @override
  String get feedbackMailSubject => 'Commentaires Life Spark';

  @override
  String get feedbackOpeningMail => 'Ouverture de votre messagerie…';

  @override
  String feedbackNoMailAppCopied(String email) {
    return 'Pas d’app mail — message copié. Collez-le dans un e-mail à $email';
  }

  @override
  String feedbackClipboardFallback(String email, String message) {
    return 'À : $email\\nObjet : Commentaires Life Spark\\n\\n$message';
  }

  @override
  String get stackSortOrderOnStack => 'Ordre sur la pile';

  @override
  String get stackSortByPlayer => 'Par joueur';

  @override
  String get stackAddSpellOrAbility => 'Ajouter sort ou capacité';

  @override
  String get stackHowItWorksTooltip => 'Comment fonctionne la pile';

  @override
  String get stackFilterResolvedCountered => 'Résolu / contré';

  @override
  String get stackApnapHint => 'Qui a ajouté quoi (joueur actif d’abord)';

  @override
  String get stackClearAll => 'Tout effacer';

  @override
  String get stackClearConfirmTitle => 'Vider la pile ?';

  @override
  String get stackClearConfirmBody =>
      'Retire tous les sorts et capacités de la pile. Irréversible.';

  @override
  String stackActivePlayerLabel(String username) {
    return '$username · Joueur actif';
  }

  @override
  String stackTurnOrderLabel(String username, int position) {
    return '$username · Ordre de tour : $position';
  }

  @override
  String get stackPutOnStack => 'Mettre sur la pile';

  @override
  String get stackInResponseToEllipsis => 'En réponse à…';

  @override
  String get stackEmptyTitle => 'Rien sur la pile';

  @override
  String get stackEmptyBullet1 =>
      'Placez ici sorts et capacités avant qu’ils ne se résolvent.';

  @override
  String get stackEmptyBullet2 => 'Le dernier ajouté se résout en premier.';

  @override
  String get stackAddSpell => 'Ajouter un sort';

  @override
  String get stackStatusResolved => 'Résolu';

  @override
  String get stackStatusCountered => 'Contré';

  @override
  String get stackStatusFizzled => 'Échoué';

  @override
  String get stackYouSuffix => '(vous)';

  @override
  String get stackUndoFizzle => 'Annuler l’échec';

  @override
  String get stackFizzle => 'Échouer';

  @override
  String get stackUndoFizzleSubtitle => 'Remet ce sort sur la pile comme actif';

  @override
  String get stackFizzleSubtitle =>
      'Cible illégale ou sort sorti de la pile (counter de règles)';

  @override
  String get stackMarkCountered => 'Marquer contré';

  @override
  String get stackRename => 'Renommer';

  @override
  String get stackOnStack => 'Sur la pile';

  @override
  String get stackResolvesNext => 'Se résout ensuite';

  @override
  String get stackResolvesAfterAbove => 'Se résout après ceux du dessus';

  @override
  String get stackTargetNoLongerOnStack => 'La cible n’est plus sur la pile';

  @override
  String get stackCardRulesTooltip => 'Règles de la carte';

  @override
  String stackInResponseToNamed(String name) {
    return 'En réponse à $name';
  }

  @override
  String get stackResolve => 'Résoudre';

  @override
  String get stackRespond => 'Répondre';

  @override
  String get stackFizzledButton => 'Échoué';

  @override
  String get stackHelpTitle => 'Comment fonctionne la pile';

  @override
  String get stackHelpBullet1 =>
      'Quand quelqu’un lance un sort ou utilise une capacité, cela va sur la pile — une file d’attente avant que ça arrive.';

  @override
  String get stackHelpBullet2 =>
      'La dernière chose ajoutée se résout en premier (comme une pile d’assiettes). C’est pourquoi l’entrée du haut dit Se résout ensuite.';

  @override
  String get stackHelpBullet3 =>
      'Pour ajouter un sort, cherchez sur Scryfall et choisissez la carte dans la liste afin de stocker le bon nom et le texte de règles.';

  @override
  String get stackHelpBullet4 =>
      'Pour répondre, touchez Répondre ou utilisez En réponse à… — votre sort va au-dessus et se résout avant celui en dessous.';

  @override
  String get stackHelpBullet5 =>
      'Quand un effet se termine, touchez Résoudre — la carte reste sur la pile et devient verte. Pour y répondre, touchez Répondre. Si un counter a fonctionné, Marquer contré (filtre Contré pour voir). Si un sort a perdu sa cible, touchez Échouer — il reste grisé ; touchez Échoué à nouveau pour annuler.';

  @override
  String get stackHelpBullet6 =>
      'À table vous dites encore « pass » à voix haute pour la priorité ; cet écran aide à se souvenir de ce qui attend et dans quel ordre.';

  @override
  String get stackHelpExample =>
      'Exemple : Vous lancez un sort de pump sur votre créature. Votre adversaire lance Lightning Bolt en réponse. Bolt se résout d’abord, puis votre pump (si sa cible est encore légale).';

  @override
  String get stackHelpReadMore => 'En savoir plus sur Magic.com';

  @override
  String get stackHelpCouldNotOpenLink => 'Impossible d’ouvrir le lien';

  @override
  String get stackPickerIntro =>
      'Cherchez sur Scryfall pour stocker le bon nom et le texte de règles.';

  @override
  String get stackPickerCardNameLabel => 'Nom de la carte';

  @override
  String get stackPickerCardNameHint => 'ex. Lightning Bolt';

  @override
  String get stackPickerClearSearch => 'Effacer la recherche';

  @override
  String get stackPickerAdd => 'Ajouter';

  @override
  String get stackPickerNoCards =>
      'Aucune carte trouvée. Essayez une autre orthographe.';

  @override
  String get stackPickerNetworkError =>
      'Impossible d’atteindre Scryfall. Vérifiez votre connexion.';

  @override
  String get stackPickerNeedSelection =>
      'Choisissez une carte dans la liste, ou tapez un nom reconnu par Scryfall.';

  @override
  String get stackPickerTypeToSearch => 'Tapez pour chercher des cartes';

  @override
  String get allianceAPlayer => 'Un joueur';

  @override
  String get allianceYourAllyFallback => 'votre allié';

  @override
  String get allianceOfferDeclined => 'Offre d’alliance secrète refusée';

  @override
  String get allianceEnded => 'Alliance secrète terminée';

  @override
  String get allianceProposeTitle => 'Alliance secrète';

  @override
  String allianceProposeSubtitle(String username) {
    return 'Invitez $username — lui seul le saura.';
  }

  @override
  String get allianceDurationSection => 'Durée';

  @override
  String get allianceDurationEndOfTurn => 'Jusqu’à la fin du tour';

  @override
  String get allianceDurationEndOfRound => 'Jusqu’à la fin de la manche';

  @override
  String get allianceDurationUntilBroken => 'Jusqu’à rupture';

  @override
  String get allianceWhenToDeliver => 'Quand livrer';

  @override
  String get allianceDeliverNow => 'Livrer maintenant';

  @override
  String allianceDeliverInSeconds(int seconds) {
    return 'Livrer dans ${seconds}s';
  }

  @override
  String get allianceDeliverEndOfYourTurn => 'Livrer à la fin de votre tour';

  @override
  String get allianceDeliverNextRound => 'Livrer à la prochaine manche';

  @override
  String allianceSecondsShort(int seconds) {
    return '${seconds}s';
  }

  @override
  String get allianceSend => 'Envoyer';

  @override
  String allianceWhisperSent(String username) {
    return 'Chuchotement envoyé à $username';
  }

  @override
  String allianceWhisperScheduled(String username) {
    return 'Chuchotement programmé pour $username';
  }

  @override
  String get allianceInviteTitle => 'Offre secrète';

  @override
  String allianceInviteBody(String username, String duration) {
    return '$username propose une alliance secrète.\\n\\nDurée : $duration\\n\\nVous seul pouvez voir ceci.';
  }

  @override
  String get allianceAccept => 'Accepter';

  @override
  String get allianceDecline => 'Refuser';

  @override
  String get allianceFormedTitle => 'Alliance formée';

  @override
  String allianceFormedBody(String username, String duration) {
    return 'Vous et $username êtes maintenant alliés en secret ($duration).\\n\\nLa table ne le sait pas — sauf si vous révélez ou trahissez.';
  }

  @override
  String allianceFormedBodyNoDuration(String username) {
    return 'Vous et $username êtes maintenant alliés en secret.\\n\\nLa table ne le sait pas — sauf si vous révélez ou trahissez.';
  }

  @override
  String get allianceUnderstood => 'Compris';

  @override
  String get allianceRevealedTitle => 'Alliance révélée';

  @override
  String allianceRevealedBody(String playerA, String playerB) {
    return '$playerA et $playerB ont révélé leur alliance secrète à la table.';
  }

  @override
  String get allianceOk => 'OK';

  @override
  String get allianceBetrayalTitle => 'Trahison !';

  @override
  String allianceBetrayalBody(String playerA, String playerB) {
    return 'L’alliance secrète entre $playerA et $playerB a été brisée par trahison.';
  }

  @override
  String get allianceBadgeAllied => 'Allié';

  @override
  String get allianceBadgeSecretAlly => 'Allié secret';

  @override
  String allianceWhisperPending(String username) {
    return 'Chuchotement en attente → $username';
  }

  @override
  String allianceAwaiting(String username) {
    return 'En attente de $username';
  }

  @override
  String get cmdDmgSheetTitle => 'Dégâts Commander';

  @override
  String get cmdDmgSheetSubtitle =>
      'Menaces envers vous d’abord. Ouvrez Infligés pour noter vos dégâts.';

  @override
  String cmdDmgBarA11y(String remaining, String ko, String taken) {
    return 'Dégâts Commander : $remaining sur $ko restants, $taken sur le pire track, toucher pour gérer';
  }

  @override
  String get cmdDmgLeft => 'restants';

  @override
  String get cmdDmgHideDealt => 'Masquer infligés';

  @override
  String cmdDmgDealtTotal(String total) {
    return 'Infligés $total';
  }

  @override
  String get cmdDmgDefaultCommander => 'Commander';

  @override
  String get cmdDmgDefaultPartner => 'Partner';

  @override
  String get cmdDmgDefaultPartnerCommander => 'Commander Partner';

  @override
  String cmdDmgYouDealtTitle(String name) {
    return 'Vous → $name';
  }

  @override
  String get cmdDmgYouDealtSubtitle => 'Dégâts que vous avez infligés';

  @override
  String get cmdDmgLethalTooltip => 'Dégâts Commander létaux !';

  @override
  String get cmdDmgIncreaseA11y => 'Augmenter les dégâts Commander';

  @override
  String get cmdDmgDecreaseA11y => 'Diminuer les dégâts Commander';

  @override
  String get cmdBarCastCommander => 'Lancer le Commander';

  @override
  String get cmdBarEliminated => 'Éliminé';

  @override
  String get cmdBarNoTaxYet => 'Pas encore de taxe';

  @override
  String get cmdBarRemoveLastCast =>
      'Retirer le dernier lancement de Commander';

  @override
  String get cmdBarCommanderTax => 'Taxe Commander';

  @override
  String get cmdBarTapToRemoveLastCast =>
      'Toucher pour retirer le dernier lancement';

  @override
  String cmdBarTaxPlus(int tax) {
    return 'Taxe +$tax';
  }

  @override
  String get counterResetConfirmTitle => 'Remettre à 0 ?';

  @override
  String get counterResetConfirmBody => 'Mettre ce compteur à zéro.';

  @override
  String get counterResetConfirmAction => 'Réinitialiser';

  @override
  String get counterResetToZero => 'Remettre à 0';

  @override
  String get counterDone => 'Terminé';

  @override
  String get firstPlayerRollTitle => 'Lancer pour le premier joueur';

  @override
  String get firstPlayerRollSubtitle =>
      'Le plus haut score commence. Touchez le dé pour lancer !';

  @override
  String get firstPlayerRollDieA11y => 'Lancer le dé';

  @override
  String get firstPlayerRollingA11y => 'Lancement';

  @override
  String firstPlayerRolledA11y(String value) {
    return 'A obtenu $value';
  }

  @override
  String get firstPlayerNotRolledA11y => 'Pas encore lancé';

  @override
  String firstPlayerYouRolled(String value) {
    return 'Vous avez obtenu $value !';
  }

  @override
  String firstPlayerYouRolledA11y(String value) {
    return 'Vous avez obtenu $value';
  }

  @override
  String get firstPlayerRolling => 'Lancement…';

  @override
  String get firstPlayerTapToRoll => 'Toucher pour lancer';

  @override
  String firstPlayerHostProgressA11y(String rolled, String total) {
    return '$rolled sur $total joueurs ont lancé';
  }

  @override
  String get firstPlayerWaitingOthersA11y => 'En attente des autres joueurs';

  @override
  String get firstPlayerRollToContinueA11y => 'Lancez le dé pour continuer';

  @override
  String firstPlayerHostProgress(String rolled, String total) {
    return '$rolled / $total joueurs ont lancé';
  }

  @override
  String get firstPlayerWaitingOthers => 'En attente des autres…';

  @override
  String get firstPlayerTapDieAbove => 'Touchez le dé ci-dessus pour lancer';

  @override
  String firstPlayerYouSuffix(String username) {
    return '$username (vous)';
  }

  @override
  String get firstPlayerTurnOrderTitle => 'Ordre des tours';

  @override
  String get firstPlayerTurnOrderSubtitle =>
      'Le plus haut score mène — le jeu suit cet ordre.';

  @override
  String get firstPlayerStartGame => 'Commencer la partie';

  @override
  String get firstPlayerOrdinal1 => '1er';

  @override
  String get firstPlayerOrdinal2 => '2e';

  @override
  String get firstPlayerOrdinal3 => '3e';

  @override
  String get firstPlayerOrdinal4 => '4e';

  @override
  String get firstPlayerOrdinal5 => '5e';

  @override
  String get firstPlayerOrdinal6 => '6e';

  @override
  String firstPlayerSlotA11y(String place, String name, String rollDetail) {
    return '$place, $name, $rollDetail';
  }

  @override
  String firstPlayerSlotYou(String username) {
    return '$username, vous';
  }

  @override
  String get firstPlayerRollUnavailable => 'lancer indisponible';

  @override
  String firstPlayerRolledDetail(String value) {
    return 'a obtenu $value';
  }

  @override
  String get firstPlayerGoesFirst => 'commence';

  @override
  String get historyTitle => 'Historique';

  @override
  String get historySubtitle => 'Vie, compteurs et autres actions de table.';

  @override
  String get historyEmptyTitle => 'Aucune action pour l’instant';

  @override
  String get historyEmptyBody =>
      'Les changements de vie, compteurs et autres actions apparaîtront ici au fil de la partie.';

  @override
  String historyTurn(String turn) {
    return 'Tour $turn';
  }

  @override
  String get overviewElimReasonLife => 'Perte de vie';

  @override
  String get overviewElimReasonPoison => 'Poison';

  @override
  String get overviewElimReasonCommanderDmg => 'Dégâts Commander';

  @override
  String get overviewElimReasonConcede => 'Abandon';

  @override
  String get overviewElimReasonDisconnect => 'Déconnecté';

  @override
  String overviewRound(int round) {
    return 'Manche $round';
  }

  @override
  String get overviewClose => 'Fermer l’aperçu';

  @override
  String get overviewTools => 'Outils';

  @override
  String get overviewHistory => 'Historique';

  @override
  String get overviewPlayers => 'Joueurs';

  @override
  String get overviewHoldDragReorder => 'Maintenir et glisser pour réordonner';

  @override
  String get overviewDecreaseLife => 'Baisser la vie';

  @override
  String get overviewIncreaseLife => 'Augmenter la vie';

  @override
  String overviewCommanderTaxPlus(int tax) {
    return 'Taxe Commander plus $tax';
  }

  @override
  String overviewTaxPlus(int tax) {
    return 'Taxe +$tax';
  }

  @override
  String get overviewMonarchA11y => 'Monarch';

  @override
  String get overviewInitiativeA11y => 'Initiative';

  @override
  String get overviewNowPlaying => 'EN JEU';

  @override
  String get overviewSendWhisper => 'Envoyer un chuchotement';

  @override
  String get overviewAssignTeamColor => 'Assigner une couleur d’équipe';

  @override
  String get overviewProposeSecretAlliance => 'Proposer une alliance secrète';

  @override
  String get overviewRevealAlliance => 'Révéler l’alliance à la table';

  @override
  String get overviewBreakAlliance => 'Rompre l’alliance secrète';

  @override
  String get overviewAssignTeamTitle => 'Assigner une équipe';

  @override
  String get overviewTeamNone => 'Aucune';

  @override
  String overviewTeamN(String index) {
    return 'Équipe $index';
  }

  @override
  String dialsStripLimitSnack(int max) {
    return 'Votre bande accepte jusqu’à $max compteurs. Retirez-en un pour en ajouter.';
  }

  @override
  String get dialsLabelPoison => 'Poison';

  @override
  String get dialsLabelEnergy => 'Énergie';

  @override
  String get dialsLabelExp => 'Exp';

  @override
  String get dialsLabelRad => 'Rad';

  @override
  String get dialsLabelBlood => 'Sang';

  @override
  String get dialsLabelClue => 'Indice';

  @override
  String get dialsLabelMap => 'Carte';

  @override
  String get dialsLabelTreasure => 'Trésor';

  @override
  String get dialsLabelDevotion => 'Dévotion';

  @override
  String get dialsLabelCreatures => 'Créatures';

  @override
  String get dialsLabelEnchant => 'Enchant.';

  @override
  String get dialsLabelArtifacts => 'Artefacts';

  @override
  String get dialsLabelGy => 'Cimetière';

  @override
  String get dialsLabelExile => 'Exil';

  @override
  String get dialsAddCounterTitle => 'Ajouter un compteur';

  @override
  String dialsAddCounterBody(int max) {
    return 'Choisissez des trackers pour votre bande (max $max). Touchez le X d’un compteur pour le retirer.';
  }

  @override
  String get dialsSectionCommon => 'Courants';

  @override
  String get dialsSectionTokensZones => 'Jetons et zones';

  @override
  String get dialsAllBuiltInsOnStrip =>
      'Tous les compteurs intégrés sont déjà sur votre bande. Retirez-en un pour libérer une place.';

  @override
  String get dialsAddCounterTooltip => 'Ajouter un compteur';

  @override
  String get dialsRemoveFromStrip => 'Retirer de la bande';

  @override
  String get hubGuideTitle => 'Visite rapide';

  @override
  String get hubGuideSkip => 'Passer';

  @override
  String get hubGuideNext => 'Suivant';

  @override
  String get hubGuideGotIt => 'Compris';

  @override
  String get hubGuideSlidePlayTitle => 'Jouer';

  @override
  String get hubGuideSlidePlayBody =>
      'Suivez vie et compteurs ici. Fin de tour est sous la barre de phases — ou désactivez le suivi de phases au lobby pour un grand bouton Fin de tour.';

  @override
  String get hubGuideSlideStackTitle => 'Pile et recherche';

  @override
  String get hubGuideSlideStackBody =>
      'La pile sert à Hold Priority et à résoudre les effets. La recherche ouvre Scryfall sans quitter votre place — texte d’oracle et rulings.';

  @override
  String get hubGuideSlideTableTitle => 'Aperçu de table';

  @override
  String get hubGuideSlideTableBody =>
      'Ouvrez Table pour tout le pod. Outils a dés et pièces que tout le monde voit ; Historique est dans l’en-tête. Fin de tour reste épinglé ; Abandon est en dessous.';

  @override
  String get hubGuideSlideCommanderTitle => 'Votre tour et Commander';

  @override
  String get hubGuideSlideCommanderBody =>
      'Quand le siège devient le vôtre, touchez l’invite Votre tour pour la fermer. Le cœur suit les dégâts Commander jusqu’à 21.';

  @override
  String lifeA11yEliminatedAt(String life) {
    return 'Éliminé à $life points de vie';
  }

  @override
  String lifeA11yLifeTotal(String life) {
    return '$life points de vie';
  }

  @override
  String get lifeA11yDecrease => 'Baisser la vie';

  @override
  String get lifeA11yIncrease => 'Augmenter la vie';

  @override
  String get lifeSetTotalTitle => 'Définir le total de vie';

  @override
  String get glanceOpenTableA11y => 'Ouvrir l’aperçu de table, ordre des tours';

  @override
  String get glanceYou => 'Vous';

  @override
  String get phasePickerTitle => 'Sélectionner la phase';

  @override
  String get phasePickerSubtitle =>
      'Faites défiler et touchez une phase, ou utilisez Définir la phase pour l’étape surlignée.';

  @override
  String phasePickerSetPhase(String phase) {
    return 'Définir $phase';
  }

  @override
  String get whisperPresetTeamUp => 'On s’allie ?';

  @override
  String get whisperPresetDontAttack => 'Ne m’attaque pas';

  @override
  String get whisperPresetHaveRemoval => 'J’ai du removal';

  @override
  String get whisperPresetAllGood => 'Tout va bien';

  @override
  String whisperSentSnack(String username) {
    return 'Chuchotement envoyé à $username';
  }

  @override
  String get whisperSendFailed =>
      'Envoi impossible — patientez ou vérifiez la connexion.';

  @override
  String whisperSheetTitle(String username) {
    return 'Chuchotement à $username';
  }

  @override
  String get whisperSheetSubtitle =>
      'Lui seul le voit — ça s’efface. Non enregistré dans l’historique.';

  @override
  String get whisperCustomLabel => 'Message personnalisé';

  @override
  String get whisperCustomHint => 'Note courte…';

  @override
  String get whisperSend => 'Envoyer le chuchotement';

  @override
  String whisperOverlayA11y(String username, String text) {
    return 'Chuchotement de $username : $text';
  }

  @override
  String whisperOverlayHeader(String username) {
    return 'Chuchotement de $username';
  }

  @override
  String get politicsTapToAssignA11y =>
      'Politique de table. Toucher pour assigner.';

  @override
  String get politicsStatusEmpty => 'Pas de Monarch · Pas d’Initiative · —';

  @override
  String get politicsDay => 'Jour';

  @override
  String get politicsNight => 'Nuit';

  @override
  String get politicsAssignSheetTitle => 'Assigner la politique de table';

  @override
  String get politicsMonarch => 'Monarch';

  @override
  String get politicsInitiative => 'Initiative';

  @override
  String get politicsAssignMonarch => 'Assigner Monarch';

  @override
  String get politicsAssignInitiative => 'Assigner Initiative';

  @override
  String get politicsNone => 'Aucun';

  @override
  String get politicsDayNight => 'Jour/Nuit';

  @override
  String get tableToolsTitle => 'Outils';

  @override
  String get tableToolsSubtitle => 'Toute la table voit le résultat.';

  @override
  String get tableToolsD6 => 'd6';

  @override
  String get tableToolsD20 => 'd20';

  @override
  String get tableToolsCoin => 'Pièce';

  @override
  String get tableToolsResultHint =>
      'Le résultat s’affiche pour toute la table';

  @override
  String get tableToolsRollD6 => 'Lancer d6';

  @override
  String get tableToolsRollD20 => 'Lancer d20';

  @override
  String get tableToolsFlipCoin => 'Lancer la pièce';

  @override
  String get tableToolHeads => 'Face';

  @override
  String get tableToolTails => 'Pile';

  @override
  String tableToolRolledHeadline(String username, String result) {
    return '$username a obtenu un $result';
  }

  @override
  String tableToolFlippedHeadline(String username, String result) {
    return '$username a obtenu $result';
  }

  @override
  String get tableToolTapToDismiss => 'Toucher pour fermer';

  @override
  String tableToolDismissA11y(String headline) {
    return '$headline. Toucher pour fermer.';
  }

  @override
  String get tableToolPlayerFallback => 'Joueur';

  @override
  String get variantDeckSingular => 'Deck de variante';

  @override
  String get variantDeckPlural => 'Decks de variante';

  @override
  String variantDeckA11y(String label) {
    return '$label, toucher pour voir';
  }

  @override
  String get variantDecksSheetTitle => 'Decks de variante';

  @override
  String get variantLoading => 'Chargement des decks de variante…';

  @override
  String get variantLoadFailed =>
      'Impossible de charger les decks (internet requis)';

  @override
  String get variantPlanechase => 'Planechase';

  @override
  String get variantArchenemy => 'Archenemy';

  @override
  String get variantBounty => 'Bounty';

  @override
  String get variantNextCard => 'Carte suivante';

  @override
  String commanderSelectNoCommanders(String query) {
    return 'Aucun commander pour « $query »';
  }

  @override
  String commanderSelectNoCards(String query) {
    return 'Aucune carte pour « $query »';
  }

  @override
  String get commanderSelectSearchFailed =>
      'Recherche impossible. Vérifiez votre connexion et réessayez.';

  @override
  String get commanderSelectEditCommanders => 'Modifier les commanders';

  @override
  String get commanderSelectEditCover => 'Modifier la carte de couverture';

  @override
  String get commanderSelectStep2Commander => 'Étape 2 sur 2 — commander';

  @override
  String get commanderSelectStep2Cover => 'Étape 2 sur 2 — carte de couverture';

  @override
  String get commanderSelectPartnerTitle => 'Sélectionner Partner';

  @override
  String get commanderSelectCommanderTitle => 'Sélectionner Commander';

  @override
  String get commanderSelectCoverHint =>
      'Choisissez n’importe quelle carte pour l’illustration — pas votre liste complète.';

  @override
  String get commanderSelectSearchPartnerHint =>
      'Chercher un commander Partner…';

  @override
  String get commanderSelectSearchCommanderHint => 'Chercher un commander…';

  @override
  String get commanderSelectSearchCardHint => 'Chercher une carte…';

  @override
  String get commanderSelectConfirm => 'Confirmer';

  @override
  String get commanderSelectScryfallCommanderHelp =>
      'Tapez un nom de commander pour chercher dans Scryfall.';

  @override
  String get commanderSelectScryfallCardHelp =>
      'Tapez un nom de carte pour chercher dans Scryfall.';

  @override
  String get commanderSelectLabelCommander => 'Commander';

  @override
  String get commanderSelectLabelPartner => 'Partner';

  @override
  String get commanderSelectOptional => 'facultatif';

  @override
  String get deckOptionsDeleteTitle => 'Supprimer le deck ?';

  @override
  String deckOptionsDeleteBody(String name) {
    return 'Retirer « $name » de votre bibliothèque ? L’historique reste, mais ce deck n’apparaîtra plus dans le sélecteur du lobby.';
  }

  @override
  String get deckOptionsDeleteConfirm => 'Supprimer';

  @override
  String get deckOptionsStyleNotSet => 'Style non défini';

  @override
  String get deckOptionsEditCommanders => 'Modifier les commanders';

  @override
  String get deckOptionsEditCover => 'Modifier la carte de couverture';

  @override
  String get deckOptionsNoGamesYet => 'Pas encore de parties';

  @override
  String deckOptionsWinRate(String rate) {
    return '$rate % de victoires';
  }

  @override
  String get deckOptionsUnpin => 'Désépingler';

  @override
  String get deckOptionsPin => 'Épingler en haut';

  @override
  String get deckOptionsChangeFormat => 'Changer de format';

  @override
  String get deckOptionsChangeStyle => 'Changer de style';

  @override
  String get deckOptionsStyleRequired => 'Obligatoire — non défini';

  @override
  String get deckOptionsRename => 'Renommer';

  @override
  String get deckOptionsDuplicate => 'Dupliquer';

  @override
  String get deckOptionsDelete => 'Supprimer le deck';

  @override
  String get deckOptionsRenameTitle => 'Renommer le deck';

  @override
  String get deckOptionsNameLabel => 'Nom du deck';

  @override
  String get deckOptionsNameHint => 'ex. Raffine Tempo';

  @override
  String get newDeckChooseStyleError =>
      'Choisissez un style de deck pour continuer';

  @override
  String get newDeckTitle => 'Nouveau deck';

  @override
  String get newDeckSubtitle => 'Étape 1 sur 2 — détails';

  @override
  String get newDeckIntro =>
      'Nommez votre deck, choisissez format et style. Ensuite vous choisirez votre commander ou carte de couverture.';

  @override
  String get newDeckNameLabel => 'Nom du deck';

  @override
  String get newDeckNameHint => 'ex. Raffine Tempo';

  @override
  String get newDeckNext => 'Suivant';

  @override
  String get formatPickerTitle => 'Format';

  @override
  String get formatPickerSearchHint => 'Chercher des formats…';

  @override
  String get formatPickerFieldLabel => 'Format';

  @override
  String formatPickerMultiplayerLife(String life) {
    return 'Multijoueur · $life points de vie de départ';
  }

  @override
  String formatPickerConstructedLife(String life) {
    return 'Constructed · $life points de vie de départ';
  }

  @override
  String get stylePickerTitle => 'Style de deck';

  @override
  String get stylePickerSearchHint => 'Chercher des styles…';

  @override
  String get stylePickerChoose => 'Choisir un style de deck';

  @override
  String get stylePickerFieldLabel => 'Style de deck';

  @override
  String get deckStyleBattlecruiser => 'Battlecruiser';

  @override
  String get deckStyleBattlecruiserDesc =>
      'Grosses créatures et dégâts au visage ; peu d’interaction, tables de débutants.';

  @override
  String get deckStyleStax => 'Stax';

  @override
  String get deckStyleStaxDesc =>
      'Ralentit ou bloque les adversaires, puis gagne pendant qu’ils ne peuvent pas répondre.';

  @override
  String get deckStyleSpellslinger => 'Spellslinger';

  @override
  String get deckStyleSpellslingerDesc =>
      'Surtout des éphémères et des rituels ; copies style storm pour des bursts.';

  @override
  String get deckStyleControl => 'Contrôle';

  @override
  String get deckStyleControlDesc =>
      'Réponses et gestion du plateau jusqu’à maîtriser complètement la partie.';

  @override
  String get deckStylePillowfort => 'Pillowfort';

  @override
  String get deckStylePillowfortDesc =>
      'Taxes et dissuasions qui rendent l’attaque coûteuse ; conditions de victoire alternatives.';

  @override
  String get deckStyleVoltron => 'Voltron';

  @override
  String get deckStyleVoltronDesc =>
      'Empile équipements et auras sur un commandant protégé.';

  @override
  String get deckStyleGroupHug => 'Group Hug';

  @override
  String get deckStyleGroupHugDesc =>
      'Petits bonus pour toute la table qui préparent une ligne de victoire cachée.';

  @override
  String get deckStyleGroupSlug => 'Group Slug';

  @override
  String get deckStyleGroupSlugDesc =>
      'Perte de points de vie ou défausse égale pour tous jusqu’à vider la table.';

  @override
  String get deckStyleReanimator => 'Réanimateur';

  @override
  String get deckStyleReanimatorDesc =>
      'Remplit le cimetière puis ramène d’énormes créatures à bas coût.';

  @override
  String get deckStyleMill => 'Mill';

  @override
  String get deckStyleMillDesc =>
      'Vide les bibliothèques en exil ou cimetière pour gagner par pioche impossible.';

  @override
  String get deckStyleStealTheft => 'Vol';

  @override
  String get deckStyleStealTheftDesc =>
      'Prend les permanents adverses et exploite la plus forte menace de la table.';

  @override
  String get deckStyleTribal => 'Tribal';

  @override
  String get deckStyleTribalDesc =>
      'Synergie de type de créature avec seigneurs et récompenses tribales.';

  @override
  String get deckStyleSliver => 'Slivoïde';

  @override
  String get deckStyleSliverDesc =>
      'Ruche de Slivoïdes qui renforce chaque autre Slivoïde sur le plateau.';

  @override
  String get deckStyleTokens => 'Jetons';

  @override
  String get deckStyleTokensDesc =>
      'Génération massive de jetons plus hymnes pour des kills de combat soudains.';

  @override
  String get deckStyleAristocrats => 'Aristocrates';

  @override
  String get deckStyleAristocratsDesc =>
      'Boucles de sacrifice avec déclencheurs de mort et d’arrivée, plus récursion.';

  @override
  String get deckStyleWeenie => 'Weenie';

  @override
  String get deckStyleWeenieDesc =>
      'Beaucoup de petites créatures qui se buffent pour des attaques larges.';

  @override
  String get deckStyleLands => 'Terrains';

  @override
  String get deckStyleLandsDesc =>
      'Moteurs landfall et centrés sur les terrains ; difficiles à interagir.';

  @override
  String get deckStyleSuperfriends => 'Superfriends';

  @override
  String get deckStyleSuperfriendsDesc =>
      'Chaînes de planeswalkers avec loyauté extra et plus d’activations.';

  @override
  String get deckStyleArtifact => 'Artefact';

  @override
  String get deckStyleArtifactDesc =>
      'Synergies d’artefacts et machines, souvent avec du bleu.';

  @override
  String get deckStyleInfect => 'Infect';

  @override
  String get deckStyleInfectDesc =>
      'Marqueurs poison au lieu de points de vie ; fort en petits pods.';

  @override
  String get deckStyleCounters => 'Marqueurs';

  @override
  String get deckStyleCountersDesc =>
      'Récompenses de marqueurs +1/+1 et capacités liées aux marqueurs.';

  @override
  String get deckStyleChaos => 'Chaos';

  @override
  String get deckStyleChaosDesc =>
      'Effets aléatoires ou disruptifs qui faussent les plans de jeu.';

  @override
  String get deckStylePolitical => 'Politique';

  @override
  String get deckStylePoliticalDesc =>
      'Votes, deals et politique de table pour orienter le résultat.';

  @override
  String get profileOptionsTitle => 'Profil';

  @override
  String get profileOptionsEdit => 'Modifier le profil';

  @override
  String get profileOptionsEditSubtitle => 'Changez votre nom ou avatar';

  @override
  String get profileOptionsBackup => 'Sauvegarder le profil';

  @override
  String get profileOptionsBackupSubtitle =>
      'Enregistrer profil, decks, parties et avis sur ce téléphone';

  @override
  String get profilePicTitle => 'Photo de profil';

  @override
  String profilePicNoCards(String query) {
    return 'Aucune carte pour « $query »';
  }

  @override
  String get profilePicSearchFailed =>
      'Recherche impossible. Vérifiez votre connexion et réessayez.';

  @override
  String get profilePicPhotoFailed =>
      'Impossible d’utiliser cette photo. Essayez une autre image.';

  @override
  String get profilePicCommander => 'Commander';

  @override
  String get profilePicDefault => 'Par défaut';

  @override
  String get profilePicRemove => 'Retirer';

  @override
  String get profilePicUpload => 'Importer une photo';

  @override
  String get profilePicTake => 'Prendre une photo';

  @override
  String get profilePicOrSearch => 'Ou chercher une illustration MTG';

  @override
  String get profilePicSearchHint =>
      'Chercher des cartes MTG pour la photo de profil…';

  @override
  String get profilePicHelp =>
      'Importez une photo, prenez-en une, ou cherchez une carte—son art devient votre photo de profil.';

  @override
  String get ranksInfoTitle => 'Rangs et niveaux';

  @override
  String get ranksInfoBody =>
      'Le niveau est votre progression exacte. Le rang est le titre de votre tranche de niveau. Les paliers métalliques regroupent ces rangs.';

  @override
  String ranksInfoLevelRange(int min, int max) {
    return 'Niv. $min–$max';
  }

  @override
  String get statsPlayerBehaviour => 'Comportement';

  @override
  String get statsMostPlayed => 'Plus joué';

  @override
  String get statsNoDeckStatsYet => 'Pas encore de stats de decks.';

  @override
  String get statsToughRecord => 'Bilan difficile';

  @override
  String get statsNoLossesOnDeck =>
      'Pas encore de défaites sur un deck enregistré.';

  @override
  String get statsPlayerStats => 'Stats du joueur';

  @override
  String get statsSingularUnit => 'stat';

  @override
  String get statsPluralUnit => 'stats';

  @override
  String get statsLeaningGood => 'plutôt bon';

  @override
  String get statsLeaningSalty => 'plutôt salty';

  @override
  String get statsLeaningNeutral => 'neutre';

  @override
  String statsBehaviourA11y(String leaning) {
    return 'Spectre de comportement, $leaning';
  }

  @override
  String get statsRecord => 'Bilan';

  @override
  String get statsWinRate => 'Taux de victoire';

  @override
  String statsRecordFooter(int wins, int losses, int games) {
    return '${wins}V–${losses}D  ·  $games parties';
  }

  @override
  String get statsWinStreak => 'Série de victoires';

  @override
  String get statsWinToStartStreak => 'Gagnez pour démarrer une série';

  @override
  String get statsPersonalBest => 'Record personnel';

  @override
  String statsBestStreak(int best) {
    return 'Meilleur : $best';
  }

  @override
  String get statsNoActiveStreak => 'Pas de série active';

  @override
  String get statsCurrent => 'Actuel';

  @override
  String statsLevelShort(int level) {
    return 'Niv. $level';
  }

  @override
  String get statsLevelProgress => 'Progression de niveau';

  @override
  String get statsLevelProgressA11y =>
      'Progression de niveau. Voir tous les rangs.';

  @override
  String get statsGood => 'Bon';

  @override
  String get statsNeutral => 'Neutre';

  @override
  String get statsSalty => 'Salty';

  @override
  String get profileBackupSaveFailed =>
      'Impossible d’enregistrer la sauvegarde.';

  @override
  String get profileUsernameLabel => 'Nom d’utilisateur';

  @override
  String get profileUsernameHint => 'ex. The Archduke';

  @override
  String get profileUsernameRequired => 'Entrez un nom d’utilisateur';

  @override
  String get profileUsernameTooShort => 'Au moins 2 caractères';

  @override
  String get profileSetupUsernameHint => 'ex. The Archduke';

  @override
  String carouselFilterTooltip(String label) {
    return 'Filtre : $label';
  }

  @override
  String carouselRecentMatchA11y(String result, String format) {
    return 'Partie récente, $result, $format';
  }

  @override
  String get carouselCloseReturnsSummary => 'Le bouton Fermer ramène au résumé';

  @override
  String get carouselShowMoreDetails =>
      'Afficher plus pour le détail complet, ou touchez la carte';

  @override
  String get decksClearSearchTooltip => 'Effacer';

  @override
  String get settingsDefaultFormatSheetTitle => 'Format par défaut';

  @override
  String get settingsDefaultStartingLifeSheetTitle =>
      'Vie de départ par défaut';

  @override
  String settingsAboutVersionBeta(String version) {
    return 'Life Spark v$version · Bêta';
  }

  @override
  String get settingsAboutByAuthor => 'par Federick Vidot';

  @override
  String get settingsAboutCardDataPoweredBy => 'Données de cartes fournies par';

  @override
  String get settingsAboutScryfall => 'Scryfall';

  @override
  String get settingsAboutDisclaimer =>
      'Life Spark est un Fan Content non officiel autorisé par la Fan Content Policy. Non approuvé/endossé par Wizards. Une partie des matériaux appartient à Wizards of the Coast. ©Wizards of the Coast LLC.';

  @override
  String get feedbackLike => 'J’aime';

  @override
  String get feedbackClearLike => 'Retirer J’aime';

  @override
  String get feedbackDislike => 'Je n’aime pas';

  @override
  String get feedbackClearDislike => 'Retirer Je n’aime pas';

  @override
  String get feedbackSparkOfTheGame => 'Étincelle de la partie';

  @override
  String get feedbackSparkHint => 'Facultatif — choisissez un joueur';

  @override
  String get feedbackNoneOption => '— Aucun —';

  @override
  String tierBadgeLabel(String rank, int level) {
    return '$rank · Niv. $level';
  }

  @override
  String tierBadgeA11y(String label) {
    return 'Rang $label. Voir tous les rangs.';
  }

  @override
  String get tierBronze => 'Bronze';

  @override
  String get tierSilver => 'Argent';

  @override
  String get tierGold => 'Or';

  @override
  String get tierPlatinum => 'Platine';

  @override
  String get tierDiamond => 'Diamant';

  @override
  String get rankApprentice => 'Apprenti';

  @override
  String get rankNeophyte => 'Néophyte';

  @override
  String get rankAdept => 'Adepte';

  @override
  String get rankEvoker => 'Évocateur';

  @override
  String get rankThaumaturge => 'Thaumaturge';

  @override
  String get rankEnchanter => 'Enchanteur';

  @override
  String get rankSummoner => 'Invocateur';

  @override
  String get rankArcanist => 'Arcaniste';

  @override
  String get rankMagus => 'Magus';

  @override
  String get rankWarWizard => 'Mage de guerre';

  @override
  String get rankHighMagus => 'Haut Magus';

  @override
  String get rankSpellbinder => 'Lieur de sorts';

  @override
  String get rankArchmage => 'Archimage';

  @override
  String get rankHighArchmage => 'Haut Archimage';

  @override
  String get rankPlanewright => 'Planewright';

  @override
  String get rankGrandArchmage => 'Grand Archimage';

  @override
  String get rankVoidcaller => 'Voidcaller';

  @override
  String get rankArchwizard => 'Archwizard';

  @override
  String get rankSpireLegend => 'Légende de la Spire';

  @override
  String get rankAscendantArchon => 'Arconte Ascendant';

  @override
  String get deckTileWinRateAbbr => 'WR';

  @override
  String get deckTileWinsAbbr => 'V';

  @override
  String get deckTileLossesAbbr => 'D';

  @override
  String get deckTileGamesAbbr => 'PJ';

  @override
  String get brandLifeSpark => 'Life Spark';

  @override
  String get hostTogglePlanechase => 'Planechase';

  @override
  String get hostToggleArchenemy => 'Archenemy';

  @override
  String get hostToggleBounty => 'Bounty';

  @override
  String get lookupClearTooltip => 'Effacer';

  @override
  String phaseNavCurrentA11y(String phase) {
    return 'Phase actuelle, $phase';
  }

  @override
  String cmdDmgThreatHelp(int ko) {
    return 'Dégâts que chaque commandant vous a infligés — $ko élimine.';
  }

  @override
  String get cmdDmgEmptyPod =>
      'Les adversaires apparaîtront ici quand d’autres rejoindront la table.';

  @override
  String get statusOut => 'HORS JEU';

  @override
  String infoBarAlly(String name) {
    return 'Allié · $name';
  }

  @override
  String get infoBarAllySecret => 'secret';

  @override
  String get gamePlayerDataUnavailable => 'Données du joueur indisponibles';

  @override
  String get startupErrorTitle => 'Erreur au démarrage';

  @override
  String get startupStackTrace => 'Trace de pile :';

  @override
  String get paletteViolet => 'Violet';

  @override
  String get paletteCrimson => 'Cramoisi';

  @override
  String get paletteSlate => 'Ardoise';

  @override
  String get paletteForest => 'Forêt';

  @override
  String get paletteObsidian => 'Obsidienne';

  @override
  String get paletteFog => 'Brouillard';

  @override
  String networkCannotReachHost(String error) {
    return 'Impossible de joindre l’hôte : $error';
  }

  @override
  String get backupFileTypeLabel => 'Sauvegarde Life Spark';

  @override
  String get backupNotValidFile =>
      'Ce n’est pas un fichier de sauvegarde Life Spark.';

  @override
  String get backupNotValidJson =>
      'Le fichier de sauvegarde n’est pas un JSON valide.';

  @override
  String get backupCouldNotRead =>
      'Impossible de lire le fichier de sauvegarde sélectionné.';

  @override
  String logLifeChange(String name, String delta) {
    return '$name : Vie $delta';
  }

  @override
  String logCounterChange(
    String name,
    String counter,
    String delta,
    String value,
  ) {
    return '$name : $counter $delta (→ $value)';
  }

  @override
  String logCounterChangeSimple(String name, String counter, String delta) {
    return '$name : $counter $delta';
  }

  @override
  String logLifeChangedYours(String name, String delta) {
    return '$name a modifié votre vie $delta';
  }

  @override
  String logCounterChangedYours(String name, String counter, String delta) {
    return '$name a modifié votre $counter $delta';
  }

  @override
  String logEndsTurn(String name) {
    return '$name termine le tour';
  }

  @override
  String logCmdDmgDealtYou(String name, String delta) {
    return '$name vous a infligé $delta dégâts de commandant';
  }

  @override
  String logCmdDmgYouDealt(String name, String delta) {
    return 'Vous avez infligé $delta dégâts de commandant à $name';
  }

  @override
  String logCmdDmgOther(String from, String to, String delta) {
    return '$from → $to : Dégâts de commandant $delta';
  }

  @override
  String get logTurnOrderUpdated => 'Ordre des tours mis à jour par l’hôte';

  @override
  String get logProliferate => 'Proliférer : tous les joueurs';

  @override
  String logAllianceRevealed(String a, String b) {
    return 'Alliance révélée : $a et $b';
  }

  @override
  String logAllianceBetrayal(String a, String b) {
    return 'Alliance rompue — trahison : $a et $b';
  }

  @override
  String get logAllianceBroken => 'Alliance rompue';

  @override
  String logAllianceFormed(String a, String b, String duration) {
    return 'Alliance secrète formée : $a et $b ($duration)';
  }

  @override
  String logPlayerLeft(String name) {
    return '$name a quitté la partie';
  }

  @override
  String logRolled(String name, String result) {
    return '$name a obtenu $result';
  }

  @override
  String logFlipped(String name, String result) {
    return '$name a tiré $result';
  }

  @override
  String logStackAdded(String name, String item) {
    return '$name a ajouté « $item »';
  }

  @override
  String logStackAddedResponse(String name, String item) {
    return '$name a ajouté « $item » (réponse)';
  }

  @override
  String logStackRenamed(String name, String item) {
    return '$name a renommé un élément de la pile en « $item »';
  }

  @override
  String logStackStatus(String name, String item, String status) {
    return '« $item » de $name $status';
  }

  @override
  String get logClearedStack => 'Pile vidée';

  @override
  String get logCounterPoison => 'Poison';

  @override
  String get logCounterEnergy => 'Énergie';

  @override
  String get logCounterExperience => 'Expérience';

  @override
  String get logCounterRad => 'Rad';

  @override
  String get logCounterBlood => 'Sang';

  @override
  String get logCounterClue => 'Indice';

  @override
  String get logCounterMap => 'Carte';

  @override
  String get logCounterTreasure => 'Trésor';

  @override
  String get logCounterDevotion => 'Dévotion';

  @override
  String get logCounterCreatures => 'Créatures';

  @override
  String get logCounterEnchantments => 'Enchantements';

  @override
  String get logCounterArtifacts => 'Artefacts';

  @override
  String get logCounterGyCreatures => 'Créatures du cimetière';

  @override
  String get logCounterExile => 'Exil';

  @override
  String get logStackStatusFizzled => 'a fizzle';

  @override
  String get logStackStatusCountered => 'contré';

  @override
  String get logStackStatusResolved => 'résolu';

  @override
  String get logStackStatusReactivated => 'réactivé';

  @override
  String get logDurationEndOfTurn => 'Jusqu’à la fin du tour';

  @override
  String get logDurationEndOfRound => 'Jusqu’à la fin du round';

  @override
  String get logDurationUntilBroken => 'Jusqu’à rupture';

  @override
  String get logHeads => 'Face';

  @override
  String get logTails => 'Pile';
}
