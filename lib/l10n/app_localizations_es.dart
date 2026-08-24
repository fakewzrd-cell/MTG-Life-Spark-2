// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Life Spark';

  @override
  String get navProfile => 'Perfil';

  @override
  String get navLobby => 'Sala';

  @override
  String get navDecks => 'Mazos';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsSectionGameplay => 'Juego';

  @override
  String get settingsDefaultFormat => 'Formato predeterminado';

  @override
  String settingsDefaultFormatSubtitle(String format) {
    return '$format · se usa al ser anfitrión';
  }

  @override
  String get settingsDefaultStartingLife => 'Vida inicial predeterminada';

  @override
  String settingsDefaultStartingLifeSubtitle(int life) {
    return '$life de vida · se usa al ser anfitrión';
  }

  @override
  String get settingsSectionMisc => 'Varios';

  @override
  String get settingsKeepDisplayAwake => 'Mantener pantalla encendida';

  @override
  String get settingsKeepDisplayAwakeSubtitle =>
      'Evita que la pantalla se apague durante una partida';

  @override
  String get settingsHideSystemBars => 'Ocultar barras de navegación y estado';

  @override
  String get settingsHideSystemBarsSubtitle =>
      'Pantalla completa durante el juego';

  @override
  String get settingsSectionAppearance => 'Apariencia';

  @override
  String get settingsDarkAppearance => 'Apariencia oscura';

  @override
  String get settingsDarkAppearanceSubtitle =>
      'El modo claro usa fondos suaves — prueba Fog o Slate';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguageSystem => 'Predeterminado del sistema';

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
  String get settingsSectionFeel => 'Sensación';

  @override
  String get settingsHapticFeedback => 'Respuesta háptica';

  @override
  String get settingsHapticFeedbackSubtitle =>
      'Vibrar en cambios de vida y subidas de rango';

  @override
  String get settingsShakeToUndo => 'Agitar para deshacer';

  @override
  String get settingsShakeToUndoSubtitle =>
      'Agita el teléfono para deshacer el último cambio de vida';

  @override
  String get settingsSectionData => 'Datos';

  @override
  String get settingsCacheCommanderImages => 'Guardar imágenes de comandante';

  @override
  String get settingsCacheCommanderImagesSubtitle =>
      'Guarda imágenes de Scryfall para uso sin conexión';

  @override
  String get settingsClearImageCache => 'Borrar caché de imágenes';

  @override
  String get settingsClearImageCacheSubtitle =>
      'Libera espacio de imágenes de cartas en caché';

  @override
  String get settingsSaveBackup => 'Guardar copia de seguridad';

  @override
  String get settingsSaveBackupSubtitle =>
      'Guarda perfil, mazos, ajustes, partidas recientes y valoraciones en un archivo';

  @override
  String get settingsRestoreBackup => 'Restaurar copia de seguridad';

  @override
  String get settingsRestoreBackupSubtitle =>
      'Reemplaza todos los datos locales desde un archivo .lifespark';

  @override
  String get settingsSectionHelp => 'Ayuda';

  @override
  String get settingsFeedback => 'Comentarios';

  @override
  String get settingsFeedbackSubtitle => 'Envíanos tus ideas y sugerencias';

  @override
  String get settingsViewHubGuide => 'Ver guía del hub';

  @override
  String get settingsViewHubGuideSubtitle =>
      'Cómo funcionan Jugar, Pila, Buscar y Mesa en una partida';

  @override
  String get settingsViewTutorialAgain => 'Ver el tutorial otra vez';

  @override
  String get settingsViewTutorialAgainSubtitle =>
      'Vuelve a lanzar el recorrido inicial';

  @override
  String get settingsBeta => 'Beta';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonSave => 'Guardar';

  @override
  String get commonAdd => 'Añadir';

  @override
  String get commonRemove => 'Quitar';

  @override
  String get commonClose => 'Cerrar';

  @override
  String get commonTryAgain => 'Reintentar';

  @override
  String get backupSaved => 'Copia de seguridad guardada.';

  @override
  String get backupSaveFailed => 'No se pudo guardar la copia de seguridad.';

  @override
  String backupRestoreTitle(String username) {
    return '¿Restaurar $username?';
  }

  @override
  String get backupRestoreMessage =>
      'Esto reemplaza tu perfil, mazos, ajustes, partidas recientes, chispas y comportamiento en este dispositivo con la copia seleccionada.';

  @override
  String get backupRestoreConfirm => 'Restaurar';

  @override
  String backupRestored(String username) {
    return 'Copia restaurada para $username.';
  }

  @override
  String get backupRestoreFailed =>
      'No se pudo restaurar la copia. Revisa el archivo e inténtalo de nuevo.';

  @override
  String get cacheCleared => 'Caché de imágenes borrada.';

  @override
  String get cacheClearFailed => 'No se pudo borrar la caché de imágenes.';

  @override
  String get decksTitle => 'Mazos';

  @override
  String get decksAddDeck => 'Añadir mazo';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get profileRecentGames => 'Partidas recientes';

  @override
  String get profileDeckPerformance => 'Rendimiento de mazos';

  @override
  String get lobbyTitle => 'Sala';

  @override
  String get lobbyHostGame => 'Crear partida';

  @override
  String get lobbyHostGameSubtitle =>
      'Crea una sesión — los demás se unen a ti';

  @override
  String get lobbyJoinGame => 'Unirse';

  @override
  String get lobbyJoinGameSubtitle => 'Busca un anfitrión cercano';

  @override
  String get hostLobbyTitle => 'Sala del anfitrión';

  @override
  String get hostLeaveLobbyTooltip => 'Salir de la sala';

  @override
  String hostPlayersScanQr(int count, int max) {
    return 'Jugadores: $count / $max  •  Escanea el QR para unirte';
  }

  @override
  String get hostNeedWifiRetry =>
      'Conecta este dispositivo a Wi‑Fi (misma red que los invitados) y pulsa Reintentar.';

  @override
  String get hostNeedsMobileApp =>
      'Para alojar hace falta la app móvil (iOS o Android) en la misma Wi‑Fi. El navegador puede unirse escaneando un QR, pero no puede alojar.';

  @override
  String get hostNeedsMobileOrDev =>
      'Para alojar hace falta la app móvil o una build local de desarrollo.';

  @override
  String get hostCreateProfileFirst =>
      'Crea tu perfil primero (Inicio → elige nombre de usuario) y pulsa Reintentar.';

  @override
  String get hostCouldNotStartServer =>
      'No se pudo iniciar el servidor en este dispositivo. Pulsa Reintentar.';

  @override
  String get hostSessionDidNotStart =>
      'La sesión de anfitrión no arrancó. Pulsa Reintentar.';

  @override
  String get hostCouldNotShowQr => 'No se pudo mostrar el QR para unirse.';

  @override
  String get hostRetry => 'Reintentar';

  @override
  String get hostNeedOnePlayer => 'Hace falta al menos 1 jugador';

  @override
  String get hostEveryoneMustBeReady => 'Todos deben estar listos';

  @override
  String get hostStartGame => 'Empezar partida';

  @override
  String hostOpenSlots(int count) {
    return '$count plaza(s) libre(s) — comparte el dispositivo para que se unan';
  }

  @override
  String get hostMatchLabel => 'Etiqueta';

  @override
  String get hostMatchLabelHelp =>
      'Opcional. Te ayuda a encontrar esta partida en Recientes.';

  @override
  String get hostMatchLabelHint => 'p. ej. EDH del viernes';

  @override
  String get hostGameSettings => 'Ajustes de partida';

  @override
  String get hostFormat => 'Formato';

  @override
  String get hostStartingLife => 'Vida inicial';

  @override
  String get hostCustomStartingLifeTitle => 'Vida inicial personalizada';

  @override
  String get hostCustomStartingLifeHint => 'Introduce la vida (1–999)';

  @override
  String get hostCustomEllipsis => 'Personalizado…';

  @override
  String get hostGameplay => 'Juego';

  @override
  String get hostToggleTeams => 'Equipos';

  @override
  String get hostToggleTeamsSubtitle => 'Asigna colores de equipo en la mesa';

  @override
  String get hostTogglePlanechaseSubtitle =>
      'Internet necesario para el mazo planar';

  @override
  String get hostToggleArchenemySubtitle =>
      'Internet necesario para el mazo de schemes';

  @override
  String get hostToggleBountySubtitle =>
      'Internet necesario para el mazo de Bounty';

  @override
  String get hostToggleAutoKo => 'Auto-KO';

  @override
  String get hostToggleAutoKoSubtitle => 'Por vida, veneno o daño de commander';

  @override
  String get hostToggleCommanderDmgLife => 'Daño de commander resta vida';

  @override
  String get hostToggleCommanderDmgLifeSubtitle =>
      'El daño de commander también reduce la vida';

  @override
  String get hostTogglePhaseTracker => 'Seguimiento de fases';

  @override
  String get hostTogglePhaseTrackerSubtitle =>
      'Muestra las fases con Atrás y Siguiente';

  @override
  String get hostToggleTurnTimer => 'Temporizador de turno';

  @override
  String get hostToggleTurnTimerSubtitle =>
      'Muestra el tiempo transcurrido por turno';

  @override
  String get hostTurnLimit => 'Límite de turno';

  @override
  String get hostTurnLimitOff => 'Desactivado';

  @override
  String hostTurnLimitSeconds(int seconds) {
    return '$seconds segundos';
  }

  @override
  String get hostNoCommanderSelected => 'Sin commander seleccionado';

  @override
  String get hostNoDeckSelected => 'Sin mazo seleccionado';

  @override
  String hostTrackingDeck(String name) {
    return 'Seguimiento: $name';
  }

  @override
  String get hostDeckListChanged => 'Mazo (lista guardada cambiada)';

  @override
  String get hostSelectDeck => 'Mazo';

  @override
  String get hostSelectCommander => 'Commander';

  @override
  String get hostMarkReady => 'Marcar listo';

  @override
  String get hostMarkNotReady => 'Marcar no listo';

  @override
  String get lobbyReady => 'Listo';

  @override
  String get lobbyWaiting => 'Esperando';

  @override
  String get deckPickerTitle => 'Mazo para esta partida';

  @override
  String get deckPickerManualOnly => 'Solo commander manual';

  @override
  String get deckPickerManualOnlySubtitle =>
      'Deja los commanders como están; no los asocies a un mazo guardado';

  @override
  String deckPickerEmptyForFormat(String format) {
    return 'Aún no hay mazos $format guardados. Crea uno en la pestaña Mazos.';
  }

  @override
  String get deckPickerOpenDecks => 'Abrir Mazos';

  @override
  String get joinTitle => 'Unirse a una partida';

  @override
  String get joinLeaveTooltip => 'Salir';

  @override
  String get joinPointCamera => 'Apunta la cámara al QR del anfitrión';

  @override
  String get joinCameraRequiredSnack =>
      'Se necesita permiso de cámara para escanear el QR del anfitrión.';

  @override
  String get joinCameraDeniedBody =>
      'Se necesita acceso a la cámara para escanear el QR del anfitrión.\\nSi ya lo permitiste en Ajustes, pulsa Reintentar.';

  @override
  String get joinOpenSettings => 'Abrir Ajustes';

  @override
  String get joinInvalidQr => 'No es un QR válido de Life Spark.';

  @override
  String get joinMissingToken =>
      'A este QR le falta el token de unión. Pide al anfitrión que actualice el QR.';

  @override
  String get joinCouldNotStartSession =>
      'No se pudo iniciar la sesión. Termina el perfil e inténtalo de nuevo.';

  @override
  String get joinConnectTimeout =>
      'Tiempo de espera agotado al conectar. Asegúrate de estar en la misma Wi‑Fi y de que la sala siga abierta, e inténtalo de nuevo.';

  @override
  String get joinHostRejected =>
      'El anfitrión rechazó la conexión (versión distinta).';

  @override
  String get joinDisconnected => 'Desconectado del anfitrión.';

  @override
  String get joinConnectionError => 'Error de conexión.';

  @override
  String get joinHostEndedSession => 'El anfitrión terminó la sesión.';

  @override
  String get joinConnecting => 'Conectando al anfitrión…';

  @override
  String get joinWaitingForHost => 'Esperando a que el anfitrión empiece…';

  @override
  String get joinSelectDeck => 'Elegir mazo';

  @override
  String get joinSelectCommander => 'Elegir commander';

  @override
  String get joinReady => 'Listo';

  @override
  String get joinMarkReady => 'Marcar listo';

  @override
  String get welcomeTagline => 'Tu compañero de MTG.';

  @override
  String get welcomeReadyToPlay => 'Listo para jugar';

  @override
  String get welcomeSkip => 'Omitir';

  @override
  String get onboardingSlide1Title => 'Bienvenido a Life Spark';

  @override
  String get onboardingSlide1Body =>
      'Tu compañero de mesa Commander — vida, contadores, política y la pila, sincronizados en la mesa.';

  @override
  String get onboardingSlide2Title => 'Crear o unirse';

  @override
  String get onboardingSlide2Body =>
      'Un jugador aloja la partida — los demás escanean un QR en la misma red Wi‑Fi. Sin cuenta de internet. Para 4 a 6 jugadores en la misma mesa.';

  @override
  String get onboardingSlide3Title => 'Controla tu vida';

  @override
  String get onboardingSlide3Body =>
      'Toca +/- para cambiar la vida en 1. Mantén +/- para ±5. Arrastra izquierda o derecha para ajustar rápido. Doble toque en la vida para un número exacto. Deshacer está en la barra inferior (o agita, si está activado).';

  @override
  String get onboardingSlide4Title => 'Fases y turnos';

  @override
  String get onboardingSlide4Body =>
      'Usa la barra de fases para avanzar el turno, o deja el seguimiento de fases desactivado en la sala. La pausa detiene toda la partida.';

  @override
  String get onboardingSlide5Title => 'Commander y contadores';

  @override
  String get onboardingSlide5Body =>
      'El daño de commander se abre como lista de amenazas — cuánto te ha hecho cada oponente hacia 21. Controla veneno (10), energía, experiencia y rad. Usa Proliferate para sumar 1 a todos a la vez.';

  @override
  String get onboardingSlide6Title => 'Alianzas y política';

  @override
  String get onboardingSlide6Body =>
      'Propón alianzas secretas con otros jugadores. Caducan solas o se rompen al atacarse. Controla Monarch e Initiative con un toque.';

  @override
  String get onboardingNext => 'Siguiente';

  @override
  String get onboardingReadyToPlay => 'Listo para jugar';

  @override
  String get onboardingSkip => 'Omitir';

  @override
  String get profileSetupTitle => 'Crea tu perfil';

  @override
  String get profileSetupSubtitle =>
      'Elige un nombre e imagen que tu mesa reconozca.';

  @override
  String get profileSetupUsername => 'Nombre de usuario';

  @override
  String get profileSetupUsernameRequired => 'Introduce un nombre de usuario';

  @override
  String get profileSetupUsernameTooShort => 'Debe tener al menos 2 caracteres';

  @override
  String get profileSetupChoosePicture => 'Elegir foto de perfil';

  @override
  String get profileSetupChangePicture => 'Cambiar foto';

  @override
  String get profileSetupContinue => 'Continuar';

  @override
  String get sessionLeaveTitle => '¿Salir de la partida activa?';

  @override
  String get sessionLeaveMessage =>
      'Tienes una sala o partida en curso. Si sales, se desconectarán los demás en la mesa.';

  @override
  String get sessionLeaveConfirm => 'Salir';

  @override
  String get sessionLeaveStay => 'Quedarse';

  @override
  String get gameLeaveTitle => '¿Salir de la partida?';

  @override
  String get gameLeaveMessageActive =>
      'Saldrás de la partida y volverás al inicio. Las estadísticas solo se guardan cuando la mesa termina la partida.';

  @override
  String get gameLeaveMessageAfterConcede =>
      'Saldrás de la partida en vivo y volverás al inicio. Tu resultado de rendición se guardará antes de desconectar.';

  @override
  String get gameTabPlay => 'Jugar';

  @override
  String get gameTabStack => 'Pila';

  @override
  String get gameTabLookupSemantics => 'Consultar reglas de carta';

  @override
  String get gameBarHome => 'Inicio';

  @override
  String get gameBarUndo => 'Deshacer';

  @override
  String get gameBarTimeout => 'Pausa';

  @override
  String get gameBarEnd => 'Fin';

  @override
  String get gameBarTable => 'Mesa';

  @override
  String get gameEndTurn => 'Pasar turno';

  @override
  String gameWaitingForPlayer(String name) {
    return 'Esperando a $name…';
  }

  @override
  String get gamePhaseBack => 'Atrás';

  @override
  String get gamePhaseNext => 'Siguiente';

  @override
  String get gameChoosePhase => 'Elegir fase';

  @override
  String get gameYourTurn => 'Tu turno';

  @override
  String get gameYourTurnTapContinue => 'Toca para continuar';

  @override
  String get gameYourTurnSemantics => 'Tu turno. Doble toque para cerrar.';

  @override
  String get gameNowPlaying => 'JUGANDO AHORA';

  @override
  String get gameActiveTurn => 'TURNO ACTIVO';

  @override
  String gamePlayersTurn(String name) {
    return 'Turno de $name';
  }

  @override
  String get gameCurrentTurn => 'Turno actual';

  @override
  String get timeoutStartTitle => 'Iniciar pausa';

  @override
  String get timeout15Seconds => '15 segundos';

  @override
  String get timeout30Seconds => '30 segundos';

  @override
  String get timeout1Minute => '1 minuto';

  @override
  String get timeoutBanner => 'PAUSA';

  @override
  String get timeoutPaused => 'Partida en pausa — sin cambios de vida';

  @override
  String get timeoutEnd => 'Terminar pausa';

  @override
  String timeoutMinimized(String time) {
    return 'Pausa — $time';
  }

  @override
  String get timeoutMinimizeTooltip => 'Minimizar temporizador';

  @override
  String get reconnectToTable => 'Reconectando a la mesa…';

  @override
  String get reconnectStillTrying => 'Todavía intentando llegar a la mesa…';

  @override
  String reconnectPeerOne(String name) {
    return '$name se está reconectando…';
  }

  @override
  String reconnectPeerMany(int count) {
    return '$count jugadores reconectándose…';
  }

  @override
  String get forfeitTitle => '¿Rendirse?';

  @override
  String get forfeitBodyMulti =>
      'Saldrás de la partida. Opcionalmente valora a los oponentes antes de irte.';

  @override
  String get forfeitBodySolo =>
      'Tu partida de práctica terminará. Opcionalmente anota cómo fue.';

  @override
  String get forfeitRateOpponents => 'Valorar oponentes';

  @override
  String get forfeitConfirm => 'Rendirse';

  @override
  String get forfeitYouForfeited => 'Te has rendido';

  @override
  String get forfeitStaySpectateBody =>
      'Los demás pueden seguir jugando. Quédate en este dispositivo para ver hasta que termine la mesa. Volver al perfil ahora guarda tu rendición y te desconecta de la partida en vivo.';

  @override
  String get forfeitStaySpectate => 'Quedarse y ver';

  @override
  String get forfeitReturnToProfile => 'Volver al perfil';

  @override
  String get gamePlayerLeftTitle => 'Jugador se fue';

  @override
  String gamePlayerLeftMessage(String username) {
    return '$username dejó la partida.';
  }

  @override
  String get gameSessionEndedTitle => 'Sesión terminada';

  @override
  String get gameSessionEndedMessage => 'El anfitrión terminó la partida.';

  @override
  String gamePeerOfflineTitle(String username) {
    return '$username sigue sin conexión';
  }

  @override
  String get gamePeerOfflineBody =>
      '¿Seguir esperando a que se reconecte o quitarlo de la mesa?';

  @override
  String get gameKeepWaiting => 'Seguir esperando';

  @override
  String get gameRemoveFromTable => 'Quitar de la mesa';

  @override
  String get gameSlotLoadFailedTitle => 'No se pudo cargar tu plaza';

  @override
  String get gameSlotLoadFailedBody =>
      'La partida puede estar desincronizada. Vuelve a la sala y únete de nuevo.';

  @override
  String get gameReturnToLobby => 'Volver a la sala';

  @override
  String get profileSetupPrompt => 'Configura tu perfil para continuar.';

  @override
  String get profileCreateCta => 'Crear perfil';

  @override
  String get profileNewPlayer => 'Nuevo jugador';

  @override
  String profilePlayingSince(String date) {
    return 'Jugando desde $date';
  }

  @override
  String get profileOptions => 'Opciones de perfil';

  @override
  String get profileDoneEditing => 'Listo';

  @override
  String get profileDone => 'Listo';

  @override
  String get profileEditName => 'Editar nombre';

  @override
  String get profileEditNameTooltip => 'Editar nombre';

  @override
  String get profileChangePicture => 'Cambiar foto de perfil';

  @override
  String get profileStatRecord => 'Récord';

  @override
  String get profileStatSparks => 'Sparks';

  @override
  String get profileStatGames => 'Partidas';

  @override
  String get profileEmptyRecentGames =>
      'Juega tu primera partida para desbloquear estadísticas e historial.';

  @override
  String get profileEmptyDeckPerf =>
      'Añade un mazo para ver el rendimiento del commander aquí.';

  @override
  String get profileFilterAllGames => 'Todas';

  @override
  String get profileFilterRecent14 => 'Recientes (14 días)';

  @override
  String get profileFilterThisWeek => 'Esta semana';

  @override
  String get profileFilterThisMonth => 'Este mes';

  @override
  String get profileNoMatchesFilter => 'Ninguna partida con este filtro.';

  @override
  String get profileOpenLobbySemantics =>
      'Abrir sala para crear o unirse a una partida';

  @override
  String get profileShowMore => 'Ver más';

  @override
  String get profileStandings => 'Clasificación';

  @override
  String get profileNoPlayerDetails =>
      'No hay datos de jugadores guardados para esta partida.';

  @override
  String get profileResultConcede => 'Rendición';

  @override
  String get profileResultLoss => 'Derrota';

  @override
  String get decksEmptyTitle => 'Crea tu biblioteca de mazos';

  @override
  String get decksEmptyBody =>
      'Guarda un mazo con nombre, formato y carta de portada. Al crear o unirte a una partida, elige la lista en la sala.';

  @override
  String get decksSearchHint => 'Buscar mazos…';

  @override
  String decksNoSearchMatches(String query) {
    return 'Ningún mazo coincide con “$query”.';
  }

  @override
  String get decksStyleNotSet => 'Estilo no definido';

  @override
  String get decksNoCoverCard => 'Sin carta de portada';

  @override
  String get lookupTitle => 'Buscar carta';

  @override
  String get lookupHint => 'Busca cualquier carta de MTG…';

  @override
  String get lookupHelp => 'Texto Oracle y rulings oficiales de Scryfall.';

  @override
  String get lookupEmptyPrompt =>
      'Escribe el nombre de una carta para ver las reglas.';

  @override
  String lookupNoResults(String query) {
    return 'No se encontraron cartas para “$query”.';
  }

  @override
  String get lookupNetworkError =>
      'No se pudo conectar con Scryfall. Revisa tu conexión.';

  @override
  String get lookupSearch => 'Buscar';

  @override
  String get lookupOracleText => 'Texto Oracle';

  @override
  String get lookupNoOracle => 'No hay texto Oracle para esta carta.';

  @override
  String get lookupRulings => 'Rulings';

  @override
  String get lookupNoRulings => 'No hay rulings oficiales para esta carta.';

  @override
  String get endGameSavingResults => 'Guardando resultados…';

  @override
  String get endGameSaveFailedTitle => 'No se pudieron guardar los resultados.';

  @override
  String get endGameSaveFailedBody =>
      'Tus estadísticas pueden no haberse actualizado. Inténtalo de nuevo.';

  @override
  String get endGameRetry => 'Reintentar';

  @override
  String get endGameContinueWithoutSaving => 'Continuar sin guardar';

  @override
  String get endGameFinalStandings => 'Clasificación final';

  @override
  String get endGameOverNoWinner => 'Fin de la partida — Sin ganador';

  @override
  String get endGamePracticeEnded => 'Práctica terminada';

  @override
  String get endGameYouWin => '¡Ganaste!';

  @override
  String get endGameWinner => 'Ganador';

  @override
  String get endGameRankUp => '¡SUBES DE RANGO!';

  @override
  String endGameRankTransition(int oldLevel, int newLevel) {
    return 'Rango $oldLevel → $newLevel';
  }

  @override
  String endGameXpGained(int xp) {
    return '+$xp XP';
  }

  @override
  String get endGameWinBonusIncluded => 'Bonus por victoria incluido';

  @override
  String get endGameParticipationXp => 'XP de participación';

  @override
  String endGameRankLevel(int level) {
    return 'Rango $level';
  }

  @override
  String get endGameFeedbackThanks => '¡Gracias! Tu opinión se ha registrado.';

  @override
  String get endGameRateOpponents => 'Valora a tus oponentes';

  @override
  String get endGameSubmitFeedback => 'Enviar opinión';

  @override
  String get endGameYouSuffix => '(tú)';

  @override
  String get endGameElimReasonLife => 'Vida agotada';

  @override
  String get endGameElimReasonPoison => '10 de veneno';

  @override
  String get endGameElimReasonCommanderDmg => 'Daño de Commander';

  @override
  String get endGameElimReasonConcede => 'Se rindió';

  @override
  String get endGameElimReasonDisconnect => 'Salió de la partida';

  @override
  String get endGameElimReasonDefault => 'Eliminado';

  @override
  String get endGameBackToHome => 'Volver al inicio';

  @override
  String get feedbackTitle => 'Comentarios';

  @override
  String get feedbackHeadline => 'Ayúdanos a mejorar';

  @override
  String get feedbackBody =>
      '¿Encontraste un error? ¿Tienes una idea? Leemos cada mensaje.';

  @override
  String get feedbackMessageLabel => 'Tu mensaje';

  @override
  String get feedbackMessageHint => 'Cuéntanos qué piensas...';

  @override
  String get feedbackSend => 'Enviar comentarios';

  @override
  String get feedbackOrDivider => 'o';

  @override
  String get feedbackRatePlayStore => 'Valorar en Play Store';

  @override
  String get feedbackMailSubject => 'Comentarios de Life Spark';

  @override
  String get feedbackOpeningMail => 'Abriendo tu app de correo…';

  @override
  String feedbackNoMailAppCopied(String email) {
    return 'Sin app de correo — mensaje copiado. Pégalo en un email a $email';
  }

  @override
  String feedbackClipboardFallback(String email, String message) {
    return 'Para: $email\\nAsunto: Comentarios de Life Spark\\n\\n$message';
  }

  @override
  String get stackSortOrderOnStack => 'Orden en la pila';

  @override
  String get stackSortByPlayer => 'Por jugador';

  @override
  String get stackAddSpellOrAbility => 'Añadir hechizo o habilidad';

  @override
  String get stackHowItWorksTooltip => 'Cómo funciona la pila';

  @override
  String get stackFilterResolvedCountered => 'Resuelto / contrarrestado';

  @override
  String get stackApnapHint => 'Quién añadió qué (jugador activo primero)';

  @override
  String get stackClearAll => 'Borrar todo';

  @override
  String get stackClearConfirmTitle => '¿Vaciar la pila?';

  @override
  String get stackClearConfirmBody =>
      'Quita todos los hechizos y habilidades de la pila. No se puede deshacer.';

  @override
  String stackActivePlayerLabel(String username) {
    return '$username · Jugador activo';
  }

  @override
  String stackTurnOrderLabel(String username, int position) {
    return '$username · Orden de turno: $position';
  }

  @override
  String get stackPutOnStack => 'Poner en la pila';

  @override
  String get stackInResponseToEllipsis => 'En respuesta a…';

  @override
  String get stackEmptyTitle => 'Nada en la pila';

  @override
  String get stackEmptyBullet1 =>
      'Pon aquí hechizos y habilidades antes de que se resuelvan.';

  @override
  String get stackEmptyBullet2 => 'El último añadido se resuelve primero.';

  @override
  String get stackAddSpell => 'Añadir hechizo';

  @override
  String get stackStatusResolved => 'Resuelto';

  @override
  String get stackStatusCountered => 'Contrarrestado';

  @override
  String get stackStatusFizzled => 'Fallido';

  @override
  String get stackYouSuffix => '(tú)';

  @override
  String get stackUndoFizzle => 'Deshacer fallo';

  @override
  String get stackFizzle => 'Fallar';

  @override
  String get stackUndoFizzleSubtitle =>
      'Devuelve este hechizo a la pila como activo';

  @override
  String get stackFizzleSubtitle =>
      'Objetivo ilegal o el hechizo salió de la pila (counter de reglas)';

  @override
  String get stackMarkCountered => 'Marcar contrarrestado';

  @override
  String get stackRename => 'Renombrar';

  @override
  String get stackOnStack => 'En la pila';

  @override
  String get stackResolvesNext => 'Se resuelve a continuación';

  @override
  String get stackResolvesAfterAbove => 'Se resuelve después de los de arriba';

  @override
  String get stackTargetNoLongerOnStack => 'El objetivo ya no está en la pila';

  @override
  String get stackCardRulesTooltip => 'Reglas de la carta';

  @override
  String stackInResponseToNamed(String name) {
    return 'En respuesta a $name';
  }

  @override
  String get stackResolve => 'Resolver';

  @override
  String get stackRespond => 'Responder';

  @override
  String get stackFizzledButton => 'Fallido';

  @override
  String get stackHelpTitle => 'Cómo funciona la pila';

  @override
  String get stackHelpBullet1 =>
      'Cuando alguien lanza un hechizo o usa una habilidad, va a la pila — una cola de espera antes de que ocurra.';

  @override
  String get stackHelpBullet2 =>
      'Lo último añadido se resuelve primero (como una pila de platos). Por eso la entrada superior dice Se resuelve a continuación.';

  @override
  String get stackHelpBullet3 =>
      'Al añadir un hechizo, busca en Scryfall y elige la carta de la lista para guardar el nombre y el texto de reglas correctos.';

  @override
  String get stackHelpBullet4 =>
      'Para responder, toca Responder o usa En respuesta a… — tu hechizo queda encima y se resuelve antes que el de debajo.';

  @override
  String get stackHelpBullet5 =>
      'Cuando un efecto termina, toca Resolver — la carta sigue en la pila y se pone verde. Para responder, toca Responder. Si un counter funcionó, Marcar contrarrestado (usa el filtro Contrarrestado para verlo). Si un hechizo perdió su objetivo, toca Fallar — queda en gris; toca Fallido otra vez para deshacer.';

  @override
  String get stackHelpBullet6 =>
      'En la mesa sigues diciendo “paso” en voz alta para la prioridad; esta pantalla ayuda a recordar qué espera y en qué orden.';

  @override
  String get stackHelpExample =>
      'Ejemplo: Lanzas un hechizo de pump a tu criatura. Tu oponente lanza Lightning Bolt en respuesta. Bolt se resuelve primero, luego tu pump (si su objetivo sigue siendo legal).';

  @override
  String get stackHelpReadMore => 'Leer más en Magic.com';

  @override
  String get stackHelpCouldNotOpenLink => 'No se pudo abrir el enlace';

  @override
  String get stackPickerIntro =>
      'Busca en Scryfall para guardar el nombre y el texto de reglas correctos.';

  @override
  String get stackPickerCardNameLabel => 'Nombre de la carta';

  @override
  String get stackPickerCardNameHint => 'p. ej. Lightning Bolt';

  @override
  String get stackPickerClearSearch => 'Borrar búsqueda';

  @override
  String get stackPickerAdd => 'Añadir';

  @override
  String get stackPickerNoCards =>
      'No se encontraron cartas. Prueba otra ortografía.';

  @override
  String get stackPickerNetworkError =>
      'No se pudo conectar con Scryfall. Revisa tu conexión a internet.';

  @override
  String get stackPickerNeedSelection =>
      'Elige una carta de la lista, o escribe un nombre que Scryfall reconozca.';

  @override
  String get stackPickerTypeToSearch => 'Escribe para buscar cartas';

  @override
  String get allianceAPlayer => 'Un jugador';

  @override
  String get allianceYourAllyFallback => 'tu aliado';

  @override
  String get allianceOfferDeclined => 'Oferta de alianza secreta rechazada';

  @override
  String get allianceEnded => 'Alianza secreta terminada';

  @override
  String get allianceProposeTitle => 'Alianza secreta';

  @override
  String allianceProposeSubtitle(String username) {
    return 'Invita a $username — solo él/ella lo sabrá.';
  }

  @override
  String get allianceDurationSection => 'Duración';

  @override
  String get allianceDurationEndOfTurn => 'Hasta el final del turno';

  @override
  String get allianceDurationEndOfRound => 'Hasta el final de la ronda';

  @override
  String get allianceDurationUntilBroken => 'Hasta que se rompa';

  @override
  String get allianceWhenToDeliver => 'Cuándo entregar';

  @override
  String get allianceDeliverNow => 'Entregar ahora';

  @override
  String allianceDeliverInSeconds(int seconds) {
    return 'Entregar en ${seconds}s';
  }

  @override
  String get allianceDeliverEndOfYourTurn => 'Entregar al final de tu turno';

  @override
  String get allianceDeliverNextRound => 'Entregar la próxima ronda';

  @override
  String allianceSecondsShort(int seconds) {
    return '${seconds}s';
  }

  @override
  String get allianceSend => 'Enviar';

  @override
  String allianceWhisperSent(String username) {
    return 'Susurro enviado a $username';
  }

  @override
  String allianceWhisperScheduled(String username) {
    return 'Susurro programado para $username';
  }

  @override
  String get allianceInviteTitle => 'Oferta secreta';

  @override
  String allianceInviteBody(String username, String duration) {
    return '$username propone una alianza secreta.\\n\\nDuración: $duration\\n\\nSolo tú puedes ver esto.';
  }

  @override
  String get allianceAccept => 'Aceptar';

  @override
  String get allianceDecline => 'Rechazar';

  @override
  String get allianceFormedTitle => 'Alianza formada';

  @override
  String allianceFormedBody(String username, String duration) {
    return 'Tú y $username ahora están aliados en secreto ($duration).\\n\\nLa mesa no lo sabe — salvo que revelen o traicionen.';
  }

  @override
  String allianceFormedBodyNoDuration(String username) {
    return 'Tú y $username ahora están aliados en secreto.\\n\\nLa mesa no lo sabe — salvo que revelen o traicionen.';
  }

  @override
  String get allianceUnderstood => 'Entendido';

  @override
  String get allianceRevealedTitle => 'Alianza revelada';

  @override
  String allianceRevealedBody(String playerA, String playerB) {
    return '$playerA y $playerB han revelado su alianza secreta a la mesa.';
  }

  @override
  String get allianceOk => 'OK';

  @override
  String get allianceBetrayalTitle => '¡Traición!';

  @override
  String allianceBetrayalBody(String playerA, String playerB) {
    return 'La alianza secreta entre $playerA y $playerB se ha roto por traición.';
  }

  @override
  String get allianceBadgeAllied => 'Aliado';

  @override
  String get allianceBadgeSecretAlly => 'Aliado secreto';

  @override
  String allianceWhisperPending(String username) {
    return 'Susurro pendiente → $username';
  }

  @override
  String allianceAwaiting(String username) {
    return 'Esperando a $username';
  }

  @override
  String get cmdDmgSheetTitle => 'Daño de Commander';

  @override
  String get cmdDmgSheetSubtitle =>
      'Amenazas a ti primero. Abre Infligido para registrar el daño que hiciste.';

  @override
  String cmdDmgBarA11y(String remaining, String ko, String taken) {
    return 'Daño de Commander: $remaining de $ko restantes, $taken en el peor track, toca para gestionar';
  }

  @override
  String get cmdDmgLeft => 'restantes';

  @override
  String get cmdDmgHideDealt => 'Ocultar infligido';

  @override
  String cmdDmgDealtTotal(String total) {
    return 'Infligido $total';
  }

  @override
  String get cmdDmgDefaultCommander => 'Commander';

  @override
  String get cmdDmgDefaultPartner => 'Partner';

  @override
  String get cmdDmgDefaultPartnerCommander => 'Commander Partner';

  @override
  String cmdDmgYouDealtTitle(String name) {
    return 'Tú → $name';
  }

  @override
  String get cmdDmgYouDealtSubtitle => 'Daño que infligiste';

  @override
  String get cmdDmgLethalTooltip => '¡Daño letal de Commander!';

  @override
  String get cmdDmgIncreaseA11y => 'Aumentar daño de Commander';

  @override
  String get cmdDmgDecreaseA11y => 'Reducir daño de Commander';

  @override
  String get cmdBarCastCommander => 'Lanzar Commander';

  @override
  String get cmdBarEliminated => 'Eliminado';

  @override
  String get cmdBarNoTaxYet => 'Sin tasa aún';

  @override
  String get cmdBarRemoveLastCast => 'Quitar último lanzamiento de Commander';

  @override
  String get cmdBarCommanderTax => 'Tasa de Commander';

  @override
  String get cmdBarTapToRemoveLastCast =>
      'Toca para quitar el último lanzamiento';

  @override
  String cmdBarTaxPlus(int tax) {
    return 'Tasa +$tax';
  }

  @override
  String get counterResetConfirmTitle => '¿Reiniciar a 0?';

  @override
  String get counterResetConfirmBody => 'Poner este contador a cero.';

  @override
  String get counterResetConfirmAction => 'Reiniciar';

  @override
  String get counterResetToZero => 'Reiniciar a 0';

  @override
  String get counterDone => 'Listo';

  @override
  String get firstPlayerRollTitle => 'Tirar por el primer jugador';

  @override
  String get firstPlayerRollSubtitle =>
      'La tirada más alta empieza. ¡Toca el dado para tirar!';

  @override
  String get firstPlayerRollDieA11y => 'Tirar dado';

  @override
  String get firstPlayerRollingA11y => 'Tirando';

  @override
  String firstPlayerRolledA11y(String value) {
    return 'Sacó $value';
  }

  @override
  String get firstPlayerNotRolledA11y => 'Sin tirar';

  @override
  String firstPlayerYouRolled(String value) {
    return '¡Sacaste $value!';
  }

  @override
  String firstPlayerYouRolledA11y(String value) {
    return 'Sacaste $value';
  }

  @override
  String get firstPlayerRolling => 'Tirando…';

  @override
  String get firstPlayerTapToRoll => 'Toca para tirar';

  @override
  String firstPlayerHostProgressA11y(String rolled, String total) {
    return '$rolled de $total jugadores han tirado';
  }

  @override
  String get firstPlayerWaitingOthersA11y =>
      'Esperando a que otros jugadores tiren';

  @override
  String get firstPlayerRollToContinueA11y => 'Tira el dado para continuar';

  @override
  String firstPlayerHostProgress(String rolled, String total) {
    return '$rolled / $total jugadores han tirado';
  }

  @override
  String get firstPlayerWaitingOthers => 'Esperando a que otros tiren…';

  @override
  String get firstPlayerTapDieAbove => 'Toca el dado de arriba para tirar';

  @override
  String firstPlayerYouSuffix(String username) {
    return '$username (tú)';
  }

  @override
  String get firstPlayerTurnOrderTitle => 'Orden de turnos';

  @override
  String get firstPlayerTurnOrderSubtitle =>
      'La tirada más alta empieza — se juega en este orden.';

  @override
  String get firstPlayerStartGame => 'Empezar partida';

  @override
  String get firstPlayerOrdinal1 => '1.º';

  @override
  String get firstPlayerOrdinal2 => '2.º';

  @override
  String get firstPlayerOrdinal3 => '3.º';

  @override
  String get firstPlayerOrdinal4 => '4.º';

  @override
  String get firstPlayerOrdinal5 => '5.º';

  @override
  String get firstPlayerOrdinal6 => '6.º';

  @override
  String firstPlayerSlotA11y(String place, String name, String rollDetail) {
    return '$place, $name, $rollDetail';
  }

  @override
  String firstPlayerSlotYou(String username) {
    return '$username, tú';
  }

  @override
  String get firstPlayerRollUnavailable => 'tirada no disponible';

  @override
  String firstPlayerRolledDetail(String value) {
    return 'sacó $value';
  }

  @override
  String get firstPlayerGoesFirst => 'empieza';

  @override
  String get historyTitle => 'Historial';

  @override
  String get historySubtitle => 'Vida, contadores y otras acciones de la mesa.';

  @override
  String get historyEmptyTitle => 'Aún no hay acciones';

  @override
  String get historyEmptyBody =>
      'Los cambios de vida, contadores y otras acciones aparecerán aquí a lo largo de la partida.';

  @override
  String historyTurn(String turn) {
    return 'Turno $turn';
  }

  @override
  String get overviewElimReasonLife => 'Pérdida de vida';

  @override
  String get overviewElimReasonPoison => 'Veneno';

  @override
  String get overviewElimReasonCommanderDmg => 'Daño de Commander';

  @override
  String get overviewElimReasonConcede => 'Se rindió';

  @override
  String get overviewElimReasonDisconnect => 'Desconectado';

  @override
  String overviewRound(int round) {
    return 'Ronda $round';
  }

  @override
  String get overviewClose => 'Cerrar resumen';

  @override
  String get overviewTools => 'Herramientas';

  @override
  String get overviewHistory => 'Historial';

  @override
  String get overviewPlayers => 'Jugadores';

  @override
  String get overviewHoldDragReorder =>
      'Mantén y arrastra para reordenar turnos';

  @override
  String get overviewDecreaseLife => 'Bajar vida';

  @override
  String get overviewIncreaseLife => 'Subir vida';

  @override
  String overviewCommanderTaxPlus(int tax) {
    return 'Tasa de Commander más $tax';
  }

  @override
  String overviewTaxPlus(int tax) {
    return 'Tasa +$tax';
  }

  @override
  String get overviewMonarchA11y => 'Monarch';

  @override
  String get overviewInitiativeA11y => 'Initiative';

  @override
  String get overviewNowPlaying => 'JUGANDO AHORA';

  @override
  String get overviewSendWhisper => 'Enviar susurro';

  @override
  String get overviewAssignTeamColor => 'Asignar color de equipo';

  @override
  String get overviewProposeSecretAlliance => 'Proponer alianza secreta';

  @override
  String get overviewRevealAlliance => 'Revelar alianza a la mesa';

  @override
  String get overviewBreakAlliance => 'Romper alianza secreta';

  @override
  String get overviewAssignTeamTitle => 'Asignar equipo';

  @override
  String get overviewTeamNone => 'Ninguno';

  @override
  String overviewTeamN(String index) {
    return 'Equipo $index';
  }

  @override
  String dialsStripLimitSnack(int max) {
    return 'Tu franja admite hasta $max contadores. Quita uno para añadir otro.';
  }

  @override
  String get dialsLabelPoison => 'Veneno';

  @override
  String get dialsLabelEnergy => 'Energía';

  @override
  String get dialsLabelExp => 'Exp';

  @override
  String get dialsLabelRad => 'Rad';

  @override
  String get dialsLabelBlood => 'Sangre';

  @override
  String get dialsLabelClue => 'Pista';

  @override
  String get dialsLabelMap => 'Mapa';

  @override
  String get dialsLabelTreasure => 'Tesoro';

  @override
  String get dialsLabelDevotion => 'Devoción';

  @override
  String get dialsLabelCreatures => 'Criaturas';

  @override
  String get dialsLabelEnchant => 'Encant.';

  @override
  String get dialsLabelArtifacts => 'Artefactos';

  @override
  String get dialsLabelGy => 'Cementerio';

  @override
  String get dialsLabelExile => 'Exilio';

  @override
  String get dialsAddCounterTitle => 'Añadir contador';

  @override
  String dialsAddCounterBody(int max) {
    return 'Elige trackers para tu franja (máx. $max). Toca la X de un contador para quitarlo.';
  }

  @override
  String get dialsSectionCommon => 'Comunes';

  @override
  String get dialsSectionTokensZones => 'Fichas y zonas';

  @override
  String get dialsAllBuiltInsOnStrip =>
      'Todos los contadores integrados ya están en tu franja. Quita uno para liberar un hueco.';

  @override
  String get dialsAddCounterTooltip => 'Añadir contador';

  @override
  String get dialsRemoveFromStrip => 'Quitar de la franja';

  @override
  String get hubGuideTitle => 'Tour rápido';

  @override
  String get hubGuideSkip => 'Saltar';

  @override
  String get hubGuideNext => 'Siguiente';

  @override
  String get hubGuideGotIt => 'Entendido';

  @override
  String get hubGuideSlidePlayTitle => 'Jugar';

  @override
  String get hubGuideSlidePlayBody =>
      'Lleva la vida y los contadores aquí. Fin de turno está bajo la barra de fases — o desactiva el rastreador de fases en el lobby para un control grande de Fin de turno.';

  @override
  String get hubGuideSlideStackTitle => 'Pila y búsqueda';

  @override
  String get hubGuideSlideStackBody =>
      'La pila es para Hold Priority y resolver efectos. La búsqueda abre Scryfall sin dejar tu asiento — texto de oráculo y rulings.';

  @override
  String get hubGuideSlideTableTitle => 'Resumen de mesa';

  @override
  String get hubGuideSlideTableBody =>
      'Abre Mesa para todo el pod. Herramientas tiene dados y monedas que todos ven; Historial está en la cabecera. Fin de turno queda fijo; Rendirse está debajo.';

  @override
  String get hubGuideSlideCommanderTitle => 'Tu turno y Commander';

  @override
  String get hubGuideSlideCommanderBody =>
      'Cuando el asiento sea tuyo, toca el aviso de Tu turno para cerrarlo. El corazón lleva el daño de Commander hacia 21.';

  @override
  String lifeA11yEliminatedAt(String life) {
    return 'Eliminado a $life de vida';
  }

  @override
  String lifeA11yLifeTotal(String life) {
    return '$life de vida total';
  }

  @override
  String get lifeA11yDecrease => 'Bajar vida';

  @override
  String get lifeA11yIncrease => 'Subir vida';

  @override
  String get lifeSetTotalTitle => 'Fijar vida total';

  @override
  String get glanceOpenTableA11y => 'Abrir resumen de mesa, orden de turnos';

  @override
  String get glanceYou => 'Tú';

  @override
  String get phasePickerTitle => 'Seleccionar fase';

  @override
  String get phasePickerSubtitle =>
      'Desplaza y toca una fase, o usa Fijar fase para el paso resaltado.';

  @override
  String phasePickerSetPhase(String phase) {
    return 'Fijar $phase';
  }

  @override
  String get whisperPresetTeamUp => '¿Hacemos equipo?';

  @override
  String get whisperPresetDontAttack => 'No me ataques';

  @override
  String get whisperPresetHaveRemoval => 'Tengo remoción';

  @override
  String get whisperPresetAllGood => 'Todo bien';

  @override
  String whisperSentSnack(String username) {
    return 'Susurro enviado a $username';
  }

  @override
  String get whisperSendFailed =>
      'No se pudo enviar — espera un momento o revisa tu conexión.';

  @override
  String whisperSheetTitle(String username) {
    return 'Susurro a $username';
  }

  @override
  String get whisperSheetSubtitle =>
      'Solo ellos lo ven — se desvanece. No se guarda en el historial.';

  @override
  String get whisperCustomLabel => 'Mensaje personalizado';

  @override
  String get whisperCustomHint => 'Nota corta…';

  @override
  String get whisperSend => 'Enviar susurro';

  @override
  String whisperOverlayA11y(String username, String text) {
    return 'Susurro de $username: $text';
  }

  @override
  String whisperOverlayHeader(String username) {
    return 'Susurro de $username';
  }

  @override
  String get politicsTapToAssignA11y => 'Política de mesa. Toca para asignar.';

  @override
  String get politicsStatusEmpty => 'Sin Monarch · Sin Initiative · —';

  @override
  String get politicsDay => 'Día';

  @override
  String get politicsNight => 'Noche';

  @override
  String get politicsAssignSheetTitle => 'Asignar política de mesa';

  @override
  String get politicsMonarch => 'Monarch';

  @override
  String get politicsInitiative => 'Initiative';

  @override
  String get politicsAssignMonarch => 'Asignar Monarch';

  @override
  String get politicsAssignInitiative => 'Asignar Initiative';

  @override
  String get politicsNone => 'Ninguno';

  @override
  String get politicsDayNight => 'Día/Noche';

  @override
  String get tableToolsTitle => 'Herramientas';

  @override
  String get tableToolsSubtitle => 'Todos en la mesa ven el resultado.';

  @override
  String get tableToolsD6 => 'd6';

  @override
  String get tableToolsD20 => 'd20';

  @override
  String get tableToolsCoin => 'Moneda';

  @override
  String get tableToolsResultHint => 'El resultado aparece para toda la mesa';

  @override
  String get tableToolsRollD6 => 'Tirar d6';

  @override
  String get tableToolsRollD20 => 'Tirar d20';

  @override
  String get tableToolsFlipCoin => 'Lanzar moneda';

  @override
  String get tableToolHeads => 'Cara';

  @override
  String get tableToolTails => 'Cruz';

  @override
  String tableToolRolledHeadline(String username, String result) {
    return '$username sacó un $result';
  }

  @override
  String tableToolFlippedHeadline(String username, String result) {
    return '$username sacó $result';
  }

  @override
  String get tableToolTapToDismiss => 'Toca para cerrar';

  @override
  String tableToolDismissA11y(String headline) {
    return '$headline. Toca para cerrar.';
  }

  @override
  String get tableToolPlayerFallback => 'Jugador';

  @override
  String get variantDeckSingular => 'Mazo de variante';

  @override
  String get variantDeckPlural => 'Mazos de variante';

  @override
  String variantDeckA11y(String label) {
    return '$label, toca para ver';
  }

  @override
  String get variantDecksSheetTitle => 'Mazos de variante';

  @override
  String get variantLoading => 'Cargando mazos de variante…';

  @override
  String get variantLoadFailed =>
      'No se pudieron cargar los mazos (hace falta internet)';

  @override
  String get variantPlanechase => 'Planechase';

  @override
  String get variantArchenemy => 'Archenemy';

  @override
  String get variantBounty => 'Bounty';

  @override
  String get variantNextCard => 'Siguiente carta';

  @override
  String commanderSelectNoCommanders(String query) {
    return 'No hay commanders para \"$query\"';
  }

  @override
  String commanderSelectNoCards(String query) {
    return 'No hay cartas para \"$query\"';
  }

  @override
  String get commanderSelectSearchFailed =>
      'No se pudo buscar. Revisa tu conexión e inténtalo de nuevo.';

  @override
  String get commanderSelectEditCommanders => 'Editar commanders';

  @override
  String get commanderSelectEditCover => 'Editar carta de portada';

  @override
  String get commanderSelectStep2Commander => 'Paso 2 de 2 — commander';

  @override
  String get commanderSelectStep2Cover => 'Paso 2 de 2 — carta de portada';

  @override
  String get commanderSelectPartnerTitle => 'Seleccionar Partner';

  @override
  String get commanderSelectCommanderTitle => 'Seleccionar Commander';

  @override
  String get commanderSelectCoverHint =>
      'Elige cualquier carta para el arte del mazo — no es tu lista completa.';

  @override
  String get commanderSelectSearchPartnerHint => 'Buscar commander Partner…';

  @override
  String get commanderSelectSearchCommanderHint => 'Buscar un commander…';

  @override
  String get commanderSelectSearchCardHint => 'Buscar una carta…';

  @override
  String get commanderSelectConfirm => 'Confirmar';

  @override
  String get commanderSelectScryfallCommanderHelp =>
      'Escribe un nombre de commander para buscar en Scryfall.';

  @override
  String get commanderSelectScryfallCardHelp =>
      'Escribe un nombre de carta para buscar en Scryfall.';

  @override
  String get commanderSelectLabelCommander => 'Commander';

  @override
  String get commanderSelectLabelPartner => 'Partner';

  @override
  String get commanderSelectOptional => 'opcional';

  @override
  String get deckOptionsDeleteTitle => '¿Borrar mazo?';

  @override
  String deckOptionsDeleteBody(String name) {
    return '¿Quitar “$name” de tu biblioteca? El historial de partidas se mantiene, pero este mazo ya no aparecerá en el selector del lobby.';
  }

  @override
  String get deckOptionsDeleteConfirm => 'Borrar';

  @override
  String get deckOptionsStyleNotSet => 'Estilo no definido';

  @override
  String get deckOptionsEditCommanders => 'Editar commanders';

  @override
  String get deckOptionsEditCover => 'Editar carta de portada';

  @override
  String get deckOptionsNoGamesYet => 'Aún no hay partidas';

  @override
  String deckOptionsWinRate(String rate) {
    return '$rate% de victorias';
  }

  @override
  String get deckOptionsUnpin => 'Desfijar de arriba';

  @override
  String get deckOptionsPin => 'Fijar arriba';

  @override
  String get deckOptionsChangeFormat => 'Cambiar formato';

  @override
  String get deckOptionsChangeStyle => 'Cambiar estilo';

  @override
  String get deckOptionsStyleRequired => 'Obligatorio — no definido';

  @override
  String get deckOptionsRename => 'Renombrar';

  @override
  String get deckOptionsDuplicate => 'Duplicar';

  @override
  String get deckOptionsDelete => 'Borrar mazo';

  @override
  String get deckOptionsRenameTitle => 'Renombrar mazo';

  @override
  String get deckOptionsNameLabel => 'Nombre del mazo';

  @override
  String get deckOptionsNameHint => 'p. ej. Raffine Tempo';

  @override
  String get newDeckChooseStyleError =>
      'Elige un estilo de mazo para continuar';

  @override
  String get newDeckTitle => 'Mazo nuevo';

  @override
  String get newDeckSubtitle => 'Paso 1 de 2 — detalles';

  @override
  String get newDeckIntro =>
      'Nombra tu mazo, elige formato y estilo. Luego elegirás tu commander o carta de portada.';

  @override
  String get newDeckNameLabel => 'Nombre del mazo';

  @override
  String get newDeckNameHint => 'p. ej. Raffine Tempo';

  @override
  String get newDeckNext => 'Siguiente';

  @override
  String get formatPickerTitle => 'Formato';

  @override
  String get formatPickerSearchHint => 'Buscar formatos…';

  @override
  String get formatPickerFieldLabel => 'Formato';

  @override
  String formatPickerMultiplayerLife(String life) {
    return 'Multijugador · $life de vida inicial';
  }

  @override
  String formatPickerConstructedLife(String life) {
    return 'Constructed · $life de vida inicial';
  }

  @override
  String get stylePickerTitle => 'Estilo de mazo';

  @override
  String get stylePickerSearchHint => 'Buscar estilos…';

  @override
  String get stylePickerChoose => 'Elegir estilo de mazo';

  @override
  String get stylePickerFieldLabel => 'Estilo de mazo';

  @override
  String get profileOptionsTitle => 'Perfil';

  @override
  String get profileOptionsEdit => 'Editar perfil';

  @override
  String get profileOptionsEditSubtitle => 'Cambia tu nombre o avatar';

  @override
  String get profileOptionsBackup => 'Respaldar perfil';

  @override
  String get profileOptionsBackupSubtitle =>
      'Guarda perfil, mazos, partidas y comentarios en este teléfono';

  @override
  String get profilePicTitle => 'Foto de perfil';

  @override
  String profilePicNoCards(String query) {
    return 'No hay cartas para \"$query\"';
  }

  @override
  String get profilePicSearchFailed =>
      'No se pudo buscar. Revisa tu conexión e inténtalo de nuevo.';

  @override
  String get profilePicPhotoFailed =>
      'No se pudo usar esa foto. Prueba otra imagen.';

  @override
  String get profilePicCommander => 'Commander';

  @override
  String get profilePicDefault => 'Predeterminada';

  @override
  String get profilePicRemove => 'Quitar';

  @override
  String get profilePicUpload => 'Subir foto';

  @override
  String get profilePicTake => 'Tomar foto';

  @override
  String get profilePicOrSearch => 'O busca arte de carta de MTG';

  @override
  String get profilePicSearchHint =>
      'Buscar cartas de MTG para la foto de perfil…';

  @override
  String get profilePicHelp =>
      'Sube una foto, tómalo o busca una carta—su arte será tu foto de perfil.';

  @override
  String get ranksInfoTitle => 'Rangos y niveles';

  @override
  String get ranksInfoBody =>
      'El nivel es tu progreso exacto. El rango es el título de tu franja de nivel. Los tiers metálicos agrupan esos rangos.';

  @override
  String ranksInfoLevelRange(int min, int max) {
    return 'Nv $min–$max';
  }

  @override
  String get statsPlayerBehaviour => 'Comportamiento';

  @override
  String get statsMostPlayed => 'Más jugado';

  @override
  String get statsNoDeckStatsYet => 'Aún no hay estadísticas de mazos.';

  @override
  String get statsToughRecord => 'Récord duro';

  @override
  String get statsNoLossesOnDeck => 'Aún no hay derrotas en un mazo guardado.';

  @override
  String get statsPlayerStats => 'Estadísticas del jugador';

  @override
  String get statsSingularUnit => 'stat';

  @override
  String get statsPluralUnit => 'stats';

  @override
  String get statsLeaningGood => 'hacia bueno';

  @override
  String get statsLeaningSalty => 'hacia salty';

  @override
  String get statsLeaningNeutral => 'neutral';

  @override
  String statsBehaviourA11y(String leaning) {
    return 'Espectro de comportamiento, $leaning';
  }

  @override
  String get statsRecord => 'Récord';

  @override
  String get statsWinRate => 'Porcentaje de victorias';

  @override
  String statsRecordFooter(int wins, int losses, int games) {
    return '${wins}V–${losses}D  ·  $games partidas';
  }

  @override
  String get statsWinStreak => 'Racha de victorias';

  @override
  String get statsWinToStartStreak => 'Gana para empezar una racha';

  @override
  String get statsPersonalBest => 'Mejor personal';

  @override
  String statsBestStreak(int best) {
    return 'Mejor: $best';
  }

  @override
  String get statsNoActiveStreak => 'Sin racha activa';

  @override
  String get statsCurrent => 'Actual';

  @override
  String statsLevelShort(int level) {
    return 'Nv $level';
  }

  @override
  String get statsLevelProgress => 'Progreso de nivel';

  @override
  String get statsLevelProgressA11y =>
      'Progreso de nivel. Ver todos los rangos.';

  @override
  String get statsGood => 'Bueno';

  @override
  String get statsNeutral => 'Neutral';

  @override
  String get statsSalty => 'Salty';

  @override
  String get profileBackupSaveFailed => 'No se pudo guardar el respaldo.';

  @override
  String get profileUsernameLabel => 'Nombre de usuario';

  @override
  String get profileUsernameHint => 'p. ej. The Archduke';

  @override
  String get profileUsernameRequired => 'Introduce un nombre de usuario';

  @override
  String get profileUsernameTooShort => 'Debe tener al menos 2 caracteres';

  @override
  String get profileSetupUsernameHint => 'p. ej. The Archduke';

  @override
  String carouselFilterTooltip(String label) {
    return 'Filtro: $label';
  }

  @override
  String carouselRecentMatchA11y(String result, String format) {
    return 'Partida reciente, $result, $format';
  }

  @override
  String get carouselCloseReturnsSummary => 'El botón Cerrar vuelve al resumen';

  @override
  String get carouselShowMoreDetails =>
      'Mostrar más para el detalle completo, o toca la tarjeta';

  @override
  String get decksClearSearchTooltip => 'Borrar';

  @override
  String get settingsDefaultFormatSheetTitle => 'Formato predeterminado';

  @override
  String get settingsDefaultStartingLifeSheetTitle =>
      'Vida inicial predeterminada';

  @override
  String settingsAboutVersionBeta(String version) {
    return 'Life Spark v$version · Beta';
  }

  @override
  String get settingsAboutByAuthor => 'por Federick Vidot';

  @override
  String get settingsAboutCardDataPoweredBy => 'Datos de cartas gracias a';

  @override
  String get settingsAboutScryfall => 'Scryfall';

  @override
  String get settingsAboutDisclaimer =>
      'Life Spark es Fan Content no oficial permitido bajo la Fan Content Policy. No aprobado/respaldado por Wizards. Parte del material es propiedad de Wizards of the Coast. ©Wizards of the Coast LLC.';

  @override
  String get feedbackLike => 'Me gusta';

  @override
  String get feedbackClearLike => 'Quitar me gusta';

  @override
  String get feedbackDislike => 'No me gusta';

  @override
  String get feedbackClearDislike => 'Quitar no me gusta';

  @override
  String get feedbackSparkOfTheGame => 'Chispa de la partida';

  @override
  String get feedbackSparkHint => 'Opcional — elige un jugador';

  @override
  String get feedbackNoneOption => '— Ninguno —';

  @override
  String tierBadgeLabel(String rank, int level) {
    return '$rank · Nv $level';
  }

  @override
  String tierBadgeA11y(String label) {
    return 'Rango $label. Ver todos los rangos.';
  }

  @override
  String get tierBronze => 'Bronce';

  @override
  String get tierSilver => 'Plata';

  @override
  String get tierGold => 'Oro';

  @override
  String get tierPlatinum => 'Platino';

  @override
  String get tierDiamond => 'Diamante';

  @override
  String get rankApprentice => 'Aprendiz';

  @override
  String get rankNeophyte => 'Neófito';

  @override
  String get rankAdept => 'Adepto';

  @override
  String get rankEvoker => 'Evocador';

  @override
  String get rankThaumaturge => 'Taumaturgo';

  @override
  String get rankEnchanter => 'Encantador';

  @override
  String get rankSummoner => 'Invocador';

  @override
  String get rankArcanist => 'Arcanista';

  @override
  String get rankMagus => 'Magus';

  @override
  String get rankWarWizard => 'Mago de guerra';

  @override
  String get rankHighMagus => 'Alto Magus';

  @override
  String get rankSpellbinder => 'Vinculador';

  @override
  String get rankArchmage => 'Archimago';

  @override
  String get rankHighArchmage => 'Alto Archimago';

  @override
  String get rankPlanewright => 'Planewright';

  @override
  String get rankGrandArchmage => 'Gran Archimago';

  @override
  String get rankVoidcaller => 'Voidcaller';

  @override
  String get rankArchwizard => 'Archwizard';

  @override
  String get rankSpireLegend => 'Leyenda de la Spire';

  @override
  String get rankAscendantArchon => 'Arconte Ascendente';

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
  String get lookupClearTooltip => 'Borrar';

  @override
  String phaseNavCurrentA11y(String phase) {
    return 'Fase actual, $phase';
  }

  @override
  String cmdDmgThreatHelp(int ko) {
    return 'Daño que cada comandante te ha hecho — $ko elimina.';
  }

  @override
  String get cmdDmgEmptyPod =>
      'Los rivales aparecerán aquí cuando otros se unan a la mesa.';

  @override
  String get statusOut => 'FUERA';

  @override
  String infoBarAlly(String name) {
    return 'Aliado · $name';
  }

  @override
  String get infoBarAllySecret => 'secreto';

  @override
  String get gamePlayerDataUnavailable => 'Datos del jugador no disponibles';

  @override
  String get startupErrorTitle => 'Error de inicio';

  @override
  String get startupStackTrace => 'Rastreo de pila:';

  @override
  String get paletteViolet => 'Violeta';

  @override
  String get paletteCrimson => 'Carmesí';

  @override
  String get paletteSlate => 'Pizarra';

  @override
  String get paletteForest => 'Bosque';

  @override
  String get paletteObsidian => 'Obsidiana';

  @override
  String get paletteFog => 'Niebla';

  @override
  String networkCannotReachHost(String error) {
    return 'No se puede alcanzar al anfitrión: $error';
  }

  @override
  String get backupFileTypeLabel => 'Copia de Life Spark';

  @override
  String get backupNotValidFile => 'No es un archivo de copia de Life Spark.';

  @override
  String get backupNotValidJson => 'El archivo de copia no es JSON válido.';

  @override
  String get backupCouldNotRead =>
      'No se pudo leer el archivo de copia seleccionado.';

  @override
  String logLifeChange(String name, String delta) {
    return '$name: Vida $delta';
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
    return '$name cambió tu vida $delta';
  }

  @override
  String logCounterChangedYours(String name, String counter, String delta) {
    return '$name cambió tu $counter $delta';
  }

  @override
  String logEndsTurn(String name) {
    return '$name termina el turno';
  }

  @override
  String logCmdDmgDealtYou(String name, String delta) {
    return '$name te hizo $delta de daño de comandante';
  }

  @override
  String logCmdDmgYouDealt(String name, String delta) {
    return 'Le hiciste a $name $delta de daño de comandante';
  }

  @override
  String logCmdDmgOther(String from, String to, String delta) {
    return '$from → $to: Daño de comandante $delta';
  }

  @override
  String get logTurnOrderUpdated =>
      'Orden de turnos actualizado por el anfitrión';

  @override
  String get logProliferate => 'Proliferar: todos los jugadores';

  @override
  String logAllianceRevealed(String a, String b) {
    return 'Alianza revelada: $a y $b';
  }

  @override
  String logAllianceBetrayal(String a, String b) {
    return 'Alianza rota — traición: $a y $b';
  }

  @override
  String get logAllianceBroken => 'Alianza rota';

  @override
  String logAllianceFormed(String a, String b, String duration) {
    return 'Alianza secreta formada: $a y $b ($duration)';
  }

  @override
  String logPlayerLeft(String name) {
    return '$name dejó la partida';
  }

  @override
  String logRolled(String name, String result) {
    return '$name sacó un $result';
  }

  @override
  String logFlipped(String name, String result) {
    return '$name sacó $result';
  }

  @override
  String logStackAdded(String name, String item) {
    return '$name añadió “$item”';
  }

  @override
  String logStackAddedResponse(String name, String item) {
    return '$name añadió “$item” (respuesta)';
  }

  @override
  String logStackRenamed(String name, String item) {
    return '$name renombró un ítem de la pila a “$item”';
  }

  @override
  String logStackStatus(String name, String item, String status) {
    return '“$item” de $name $status';
  }

  @override
  String get logClearedStack => 'Pila vaciada';

  @override
  String get logCounterPoison => 'Veneno';

  @override
  String get logCounterEnergy => 'Energía';

  @override
  String get logCounterExperience => 'Experiencia';

  @override
  String get logCounterRad => 'Rad';

  @override
  String get logCounterBlood => 'Sangre';

  @override
  String get logCounterClue => 'Pista';

  @override
  String get logCounterMap => 'Mapa';

  @override
  String get logCounterTreasure => 'Tesoro';

  @override
  String get logCounterDevotion => 'Devoción';

  @override
  String get logCounterCreatures => 'Criaturas';

  @override
  String get logCounterEnchantments => 'Encantamientos';

  @override
  String get logCounterArtifacts => 'Artefactos';

  @override
  String get logCounterGyCreatures => 'Criaturas del cementerio';

  @override
  String get logCounterExile => 'Exilio';

  @override
  String get logStackStatusFizzled => 'falló';

  @override
  String get logStackStatusCountered => 'contrarrestado';

  @override
  String get logStackStatusResolved => 'resuelto';

  @override
  String get logStackStatusReactivated => 'reactivado';

  @override
  String get logDurationEndOfTurn => 'Hasta fin de turno';

  @override
  String get logDurationEndOfRound => 'Hasta fin de ronda';

  @override
  String get logDurationUntilBroken => 'Hasta romperla';

  @override
  String get logHeads => 'Cara';

  @override
  String get logTails => 'Cruz';
}
