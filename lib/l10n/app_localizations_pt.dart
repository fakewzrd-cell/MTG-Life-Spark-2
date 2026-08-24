// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Life Spark';

  @override
  String get navProfile => 'Perfil';

  @override
  String get navLobby => 'Lobby';

  @override
  String get navDecks => 'Decks';

  @override
  String get navSettings => 'Configurações';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get settingsSectionGameplay => 'Jogabilidade';

  @override
  String get settingsDefaultFormat => 'Formato padrão';

  @override
  String settingsDefaultFormatSubtitle(String format) {
    return '$format · usado ao hospedar';
  }

  @override
  String get settingsDefaultStartingLife => 'Vida inicial padrão';

  @override
  String settingsDefaultStartingLifeSubtitle(int life) {
    return '$life de vida · usado ao hospedar';
  }

  @override
  String get settingsSectionMisc => 'Diversos';

  @override
  String get settingsKeepDisplayAwake => 'Manter tela ligada';

  @override
  String get settingsKeepDisplayAwakeSubtitle =>
      'Impede que a tela desligue durante uma partida';

  @override
  String get settingsHideSystemBars => 'Ocultar barras de navegação e status';

  @override
  String get settingsHideSystemBarsSubtitle => 'Modo tela cheia durante o jogo';

  @override
  String get settingsSectionAppearance => 'Aparência';

  @override
  String get settingsDarkAppearance => 'Aparência escura';

  @override
  String get settingsDarkAppearanceSubtitle =>
      'O modo claro usa fundos suaves — experimente Fog ou Slate';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguageSystem => 'Padrão do sistema';

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
  String get settingsSectionFeel => 'Sensação';

  @override
  String get settingsHapticFeedback => 'Feedback tátil';

  @override
  String get settingsHapticFeedbackSubtitle =>
      'Vibrar em mudanças de vida e subidas de rank';

  @override
  String get settingsShakeToUndo => 'Agitar para desfazer';

  @override
  String get settingsShakeToUndoSubtitle =>
      'Agite o telefone para desfazer a última mudança de vida';

  @override
  String get settingsSectionData => 'Dados';

  @override
  String get settingsCacheCommanderImages => 'Cachear imagens de comandante';

  @override
  String get settingsCacheCommanderImagesSubtitle =>
      'Armazena imagens do Scryfall para uso offline';

  @override
  String get settingsClearImageCache => 'Limpar cache de imagens';

  @override
  String get settingsClearImageCacheSubtitle =>
      'Libera espaço das imagens de cartas em cache';

  @override
  String get settingsSaveBackup => 'Salvar backup';

  @override
  String get settingsSaveBackupSubtitle =>
      'Salva perfil, decks, configurações, partidas recentes e feedback em um arquivo';

  @override
  String get settingsRestoreBackup => 'Restaurar backup';

  @override
  String get settingsRestoreBackupSubtitle =>
      'Substitui todos os dados locais por um arquivo .lifespark';

  @override
  String get settingsSectionHelp => 'Ajuda';

  @override
  String get settingsFeedback => 'Feedback';

  @override
  String get settingsFeedbackSubtitle => 'Envie suas ideias e sugestões';

  @override
  String get settingsViewHubGuide => 'Ver guia do hub';

  @override
  String get settingsViewHubGuideSubtitle =>
      'Como Jogar, Pilha, Busca e Mesa funcionam em uma partida';

  @override
  String get settingsViewTutorialAgain => 'Ver o tutorial novamente';

  @override
  String get settingsViewTutorialAgainSubtitle =>
      'Relança o passo a passo inicial';

  @override
  String get settingsBeta => 'Beta';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonSave => 'Salvar';

  @override
  String get commonAdd => 'Adicionar';

  @override
  String get commonRemove => 'Remover';

  @override
  String get commonClose => 'Fechar';

  @override
  String get commonTryAgain => 'Tentar de novo';

  @override
  String get backupSaved => 'Backup salvo.';

  @override
  String get backupSaveFailed => 'Não foi possível salvar o backup.';

  @override
  String backupRestoreTitle(String username) {
    return 'Restaurar $username?';
  }

  @override
  String get backupRestoreMessage =>
      'Isso substitui seu perfil, decks, configurações, partidas recentes, sparks e comportamento neste dispositivo pelo backup selecionado.';

  @override
  String get backupRestoreConfirm => 'Restaurar';

  @override
  String backupRestored(String username) {
    return 'Backup restaurado para $username.';
  }

  @override
  String get backupRestoreFailed =>
      'Não foi possível restaurar o backup. Verifique o arquivo e tente novamente.';

  @override
  String get cacheCleared => 'Cache de imagens limpo.';

  @override
  String get cacheClearFailed => 'Não foi possível limpar o cache de imagens.';

  @override
  String get decksTitle => 'Decks';

  @override
  String get decksAddDeck => 'Adicionar deck';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get profileRecentGames => 'Partidas recentes';

  @override
  String get profileDeckPerformance => 'Desempenho dos decks';

  @override
  String get lobbyTitle => 'Lobby';

  @override
  String get lobbyHostGame => 'Hospedar partida';

  @override
  String get lobbyHostGameSubtitle =>
      'Crie uma sessão — os outros entram com você';

  @override
  String get lobbyJoinGame => 'Entrar na partida';

  @override
  String get lobbyJoinGameSubtitle => 'Procure um host por perto';

  @override
  String get hostLobbyTitle => 'Lobby do host';

  @override
  String get hostLeaveLobbyTooltip => 'Sair do lobby';

  @override
  String hostPlayersScanQr(int count, int max) {
    return 'Jogadores: $count / $max  •  Escaneie o QR para entrar';
  }

  @override
  String get hostNeedWifiRetry =>
      'Conecte este dispositivo ao Wi‑Fi (mesma rede dos convidados) e toque em Tentar de novo.';

  @override
  String get hostNeedsMobileApp =>
      'Para hospedar é preciso o app móvel (iOS ou Android) no mesmo Wi‑Fi. O navegador pode entrar escaneando um QR, mas não pode hospedar.';

  @override
  String get hostNeedsMobileOrDev =>
      'Para hospedar é preciso o app móvel ou um build local de desenvolvimento.';

  @override
  String get hostCreateProfileFirst =>
      'Crie seu perfil primeiro (Início → defina o nome de usuário) e toque em Tentar de novo.';

  @override
  String get hostCouldNotStartServer =>
      'Não foi possível iniciar o servidor neste dispositivo. Toque em Tentar de novo.';

  @override
  String get hostSessionDidNotStart =>
      'A sessão de host não iniciou. Toque em Tentar de novo.';

  @override
  String get hostCouldNotShowQr => 'Não foi possível mostrar o QR de entrada.';

  @override
  String get hostRetry => 'Tentar de novo';

  @override
  String get hostNeedOnePlayer => 'É preciso pelo menos 1 jogador';

  @override
  String get hostEveryoneMustBeReady => 'Todos precisam estar prontos';

  @override
  String get hostStartGame => 'Iniciar partida';

  @override
  String hostOpenSlots(int count) {
    return '$count vaga(s) aberta(s) — compartilhe o dispositivo para amigos entrarem';
  }

  @override
  String get hostMatchLabel => 'Rótulo';

  @override
  String get hostMatchLabelHelp =>
      'Opcional. Ajuda a achar esta partida em Partidas recentes.';

  @override
  String get hostMatchLabelHint => 'ex.: EDH de sexta';

  @override
  String get hostGameSettings => 'Configurações da partida';

  @override
  String get hostFormat => 'Formato';

  @override
  String get hostStartingLife => 'Vida inicial';

  @override
  String get hostCustomStartingLifeTitle => 'Vida inicial personalizada';

  @override
  String get hostCustomStartingLifeHint => 'Digite a vida (1–999)';

  @override
  String get hostCustomEllipsis => 'Personalizado…';

  @override
  String get hostGameplay => 'Jogabilidade';

  @override
  String get hostToggleTeams => 'Times';

  @override
  String get hostToggleTeamsSubtitle => 'Defina cores de time na mesa';

  @override
  String get hostTogglePlanechaseSubtitle =>
      'Internet necessária para o deck planar';

  @override
  String get hostToggleArchenemySubtitle =>
      'Internet necessária para o deck de schemes';

  @override
  String get hostToggleBountySubtitle =>
      'Internet necessária para o deck de Bounty';

  @override
  String get hostToggleAutoKo => 'Auto-KO';

  @override
  String get hostToggleAutoKoSubtitle =>
      'Por vida, poison ou dano de commander';

  @override
  String get hostToggleCommanderDmgLife => 'Dano de commander reduz vida';

  @override
  String get hostToggleCommanderDmgLifeSubtitle =>
      'O dano de commander também reduz a vida';

  @override
  String get hostTogglePhaseTracker => 'Rastreador de fases';

  @override
  String get hostTogglePhaseTrackerSubtitle =>
      'Mostra as fases com Voltar e Próximo';

  @override
  String get hostToggleTurnTimer => 'Timer de turno';

  @override
  String get hostToggleTurnTimerSubtitle =>
      'Mostra o tempo decorrido a cada turno';

  @override
  String get hostTurnLimit => 'Limite de turno';

  @override
  String get hostTurnLimitOff => 'Desligado';

  @override
  String hostTurnLimitSeconds(int seconds) {
    return '$seconds segundos';
  }

  @override
  String get hostNoCommanderSelected => 'Nenhum commander selecionado';

  @override
  String get hostNoDeckSelected => 'Nenhum deck selecionado';

  @override
  String hostTrackingDeck(String name) {
    return 'Rastreando: $name';
  }

  @override
  String get hostDeckListChanged => 'Deck (lista salva alterada)';

  @override
  String get hostSelectDeck => 'Deck';

  @override
  String get hostSelectCommander => 'Commander';

  @override
  String get hostMarkReady => 'Marcar pronto';

  @override
  String get hostMarkNotReady => 'Marcar não pronto';

  @override
  String get lobbyReady => 'Pronto';

  @override
  String get lobbyWaiting => 'Aguardando';

  @override
  String get deckPickerTitle => 'Deck desta partida';

  @override
  String get deckPickerManualOnly => 'Só commander manual';

  @override
  String get deckPickerManualOnlySubtitle =>
      'Mantenha os commanders como estão; não associe a um deck salvo';

  @override
  String deckPickerEmptyForFormat(String format) {
    return 'Ainda não há decks $format salvos. Crie um na aba Decks.';
  }

  @override
  String get deckPickerOpenDecks => 'Abrir Decks';

  @override
  String get joinTitle => 'Entrar em uma partida';

  @override
  String get joinLeaveTooltip => 'Sair';

  @override
  String get joinPointCamera => 'Aponte a câmera para o QR do host';

  @override
  String get joinCameraRequiredSnack =>
      'É preciso permissão da câmera para escanear o QR do host.';

  @override
  String get joinCameraDeniedBody =>
      'É preciso acesso à câmera para escanear o QR do host.\\nSe você já permitiu em Ajustes, toque em Tentar de novo.';

  @override
  String get joinOpenSettings => 'Abrir Ajustes';

  @override
  String get joinInvalidQr => 'Não é um QR válido do Life Spark.';

  @override
  String get joinMissingToken =>
      'Este QR está sem o token de entrada. Peça ao host para atualizar o QR.';

  @override
  String get joinCouldNotStartSession =>
      'Não foi possível iniciar a sessão. Conclua o perfil e tente de novo.';

  @override
  String get joinConnectTimeout =>
      'Tempo esgotado ao conectar. Confirme que está no mesmo Wi‑Fi e que o lobby do host ainda está aberto, e tente de novo.';

  @override
  String get joinHostRejected =>
      'O host rejeitou a conexão (versão incompatível).';

  @override
  String get joinDisconnected => 'Desconectado do host.';

  @override
  String get joinConnectionError => 'Erro de conexão.';

  @override
  String get joinHostEndedSession => 'O host encerrou a sessão.';

  @override
  String get joinConnecting => 'Conectando ao host…';

  @override
  String get joinWaitingForHost => 'Aguardando o host iniciar…';

  @override
  String get joinSelectDeck => 'Selecionar deck';

  @override
  String get joinSelectCommander => 'Selecionar commander';

  @override
  String get joinReady => 'Pronto';

  @override
  String get joinMarkReady => 'Marcar pronto';

  @override
  String get welcomeTagline => 'Seu companheiro de MTG.';

  @override
  String get welcomeReadyToPlay => 'Pronto para jogar';

  @override
  String get welcomeSkip => 'Pular';

  @override
  String get onboardingSlide1Title => 'Bem-vindo ao Life Spark';

  @override
  String get onboardingSlide1Body =>
      'Seu companheiro de mesa Commander — vida, contadores, política e a pilha, sincronizados na mesa.';

  @override
  String get onboardingSlide2Title => 'Hospedar ou entrar';

  @override
  String get onboardingSlide2Body =>
      'Um jogador hospeda — os outros escaneiam um QR na mesma rede Wi‑Fi. Sem conta na internet. Funciona com 4 a 6 jogadores na mesma mesa.';

  @override
  String get onboardingSlide3Title => 'Acompanhe sua vida';

  @override
  String get onboardingSlide3Body =>
      'Toque em +/- para mudar a vida em 1. Segure +/- para ±5. Arraste para a esquerda ou direita para ajustar rápido. Toque duas vezes na vida para um número exato. Desfazer fica na barra inferior (ou agite, se ativado).';

  @override
  String get onboardingSlide4Title => 'Fases e turnos';

  @override
  String get onboardingSlide4Body =>
      'Use a barra de fases para avançar o turno, ou deixe o rastreador desligado no lobby. A pausa interrompe a partida inteira.';

  @override
  String get onboardingSlide5Title => 'Commander e contadores';

  @override
  String get onboardingSlide5Body =>
      'O dano de commander abre como lista de ameaças — quanto cada oponente já causou rumo a 21. Acompanhe poison (10), energy, experience e rad. Use Proliferate para somar 1 a todos de uma vez.';

  @override
  String get onboardingSlide6Title => 'Alianças e política';

  @override
  String get onboardingSlide6Body =>
      'Proponha alianças secretas com outros jogadores. Elas expiram sozinhas ou quebram quando vocês se atacam. Acompanhe Monarch e Initiative com um toque.';

  @override
  String get onboardingNext => 'Próximo';

  @override
  String get onboardingReadyToPlay => 'Pronto para jogar';

  @override
  String get onboardingSkip => 'Pular';

  @override
  String get profileSetupTitle => 'Crie seu perfil';

  @override
  String get profileSetupSubtitle =>
      'Escolha um nome e uma foto que a mesa reconheça.';

  @override
  String get profileSetupUsername => 'Nome de usuário';

  @override
  String get profileSetupUsernameRequired => 'Digite um nome de usuário';

  @override
  String get profileSetupUsernameTooShort => 'Deve ter pelo menos 2 caracteres';

  @override
  String get profileSetupChoosePicture => 'Escolher foto de perfil';

  @override
  String get profileSetupChangePicture => 'Trocar foto';

  @override
  String get profileSetupContinue => 'Continuar';

  @override
  String get sessionLeaveTitle => 'Sair da partida ativa?';

  @override
  String get sessionLeaveMessage =>
      'Você tem um lobby ou partida em andamento. Sair desconectará os outros jogadores na mesa.';

  @override
  String get sessionLeaveConfirm => 'Sair';

  @override
  String get sessionLeaveStay => 'Ficar';

  @override
  String get gameLeaveTitle => 'Sair da partida?';

  @override
  String get gameLeaveMessageActive =>
      'Você sairá da partida e voltará ao início. As estatísticas só salvam quando a mesa termina a partida.';

  @override
  String get gameLeaveMessageAfterConcede =>
      'Você sairá da partida ao vivo e voltará ao início. Seu resultado de desistência será salvo antes de desconectar.';

  @override
  String get gameTabPlay => 'Jogar';

  @override
  String get gameTabStack => 'Pilha';

  @override
  String get gameTabLookupSemantics => 'Consultar regras da carta';

  @override
  String get gameBarHome => 'Início';

  @override
  String get gameBarUndo => 'Desfazer';

  @override
  String get gameBarTimeout => 'Pausa';

  @override
  String get gameBarEnd => 'Fim';

  @override
  String get gameBarTable => 'Mesa';

  @override
  String get gameEndTurn => 'Passar turno';

  @override
  String gameWaitingForPlayer(String name) {
    return 'Aguardando $name…';
  }

  @override
  String get gamePhaseBack => 'Voltar';

  @override
  String get gamePhaseNext => 'Próximo';

  @override
  String get gameChoosePhase => 'Escolher fase';

  @override
  String get gameYourTurn => 'Seu turno';

  @override
  String get gameYourTurnTapContinue => 'Toque para continuar';

  @override
  String get gameYourTurnSemantics =>
      'Seu turno. Toque duas vezes para fechar.';

  @override
  String get gameNowPlaying => 'JOGANDO AGORA';

  @override
  String get gameActiveTurn => 'TURNO ATIVO';

  @override
  String gamePlayersTurn(String name) {
    return 'Turno de $name';
  }

  @override
  String get gameCurrentTurn => 'Turno atual';

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
  String get timeoutPaused => 'Partida pausada — sem mudanças de vida';

  @override
  String get timeoutEnd => 'Encerrar pausa';

  @override
  String timeoutMinimized(String time) {
    return 'Pausa — $time';
  }

  @override
  String get timeoutMinimizeTooltip => 'Minimizar temporizador';

  @override
  String get reconnectToTable => 'Reconectando à mesa…';

  @override
  String get reconnectStillTrying => 'Ainda tentando alcançar a mesa…';

  @override
  String reconnectPeerOne(String name) {
    return '$name está reconectando…';
  }

  @override
  String reconnectPeerMany(int count) {
    return '$count jogadores reconectando…';
  }

  @override
  String get forfeitTitle => 'Desistir?';

  @override
  String get forfeitBodyMulti =>
      'Você sairá da partida. Opcionalmente avalie os oponentes antes de ir.';

  @override
  String get forfeitBodySolo =>
      'Sua partida de prática terminará. Opcionalmente anote como foi.';

  @override
  String get forfeitRateOpponents => 'Avaliar oponentes';

  @override
  String get forfeitConfirm => 'Desistir';

  @override
  String get forfeitYouForfeited => 'Você desistiu';

  @override
  String get forfeitStaySpectateBody =>
      'Os outros podem continuar jogando. Fique neste dispositivo para assistir até a mesa terminar. Voltar ao perfil agora salva sua desistência e desconecta da partida ao vivo.';

  @override
  String get forfeitStaySpectate => 'Ficar e assistir';

  @override
  String get forfeitReturnToProfile => 'Voltar ao perfil';

  @override
  String get gamePlayerLeftTitle => 'Jogador saiu';

  @override
  String gamePlayerLeftMessage(String username) {
    return '$username saiu da partida.';
  }

  @override
  String get gameSessionEndedTitle => 'Sessão encerrada';

  @override
  String get gameSessionEndedMessage => 'O host encerrou a partida.';

  @override
  String gamePeerOfflineTitle(String username) {
    return '$username ainda offline';
  }

  @override
  String get gamePeerOfflineBody =>
      'Continuar esperando a reconexão ou remover da mesa?';

  @override
  String get gameKeepWaiting => 'Continuar esperando';

  @override
  String get gameRemoveFromTable => 'Remover da mesa';

  @override
  String get gameSlotLoadFailedTitle => 'Não foi possível carregar sua vaga';

  @override
  String get gameSlotLoadFailedBody =>
      'A partida pode estar dessincronizada. Volte ao lobby e entre de novo.';

  @override
  String get gameReturnToLobby => 'Voltar ao lobby';

  @override
  String get profileSetupPrompt => 'Configure seu perfil para continuar.';

  @override
  String get profileCreateCta => 'Criar perfil';

  @override
  String get profileNewPlayer => 'Novo jogador';

  @override
  String profilePlayingSince(String date) {
    return 'Jogando desde $date';
  }

  @override
  String get profileOptions => 'Opções do perfil';

  @override
  String get profileDoneEditing => 'Concluir edição';

  @override
  String get profileDone => 'Concluído';

  @override
  String get profileEditName => 'Editar nome';

  @override
  String get profileEditNameTooltip => 'Editar nome';

  @override
  String get profileChangePicture => 'Trocar foto de perfil';

  @override
  String get profileStatRecord => 'Recorde';

  @override
  String get profileStatSparks => 'Sparks';

  @override
  String get profileStatGames => 'Partidas';

  @override
  String get profileEmptyRecentGames =>
      'Jogue sua primeira partida para liberar estatísticas e histórico.';

  @override
  String get profileEmptyDeckPerf =>
      'Adicione um deck para acompanhar o desempenho do commander aqui.';

  @override
  String get profileFilterAllGames => 'Todas';

  @override
  String get profileFilterRecent14 => 'Recentes (14 dias)';

  @override
  String get profileFilterThisWeek => 'Esta semana';

  @override
  String get profileFilterThisMonth => 'Este mês';

  @override
  String get profileNoMatchesFilter => 'Nenhuma partida neste filtro.';

  @override
  String get profileOpenLobbySemantics =>
      'Abrir lobby para hospedar ou entrar em uma partida';

  @override
  String get profileShowMore => 'Mostrar mais';

  @override
  String get profileStandings => 'Classificação';

  @override
  String get profileNoPlayerDetails =>
      'Nenhum detalhe de jogador salvo para esta partida.';

  @override
  String get profileResultConcede => 'Desistência';

  @override
  String get profileResultLoss => 'Derrota';

  @override
  String get decksEmptyTitle => 'Monte sua biblioteca de decks';

  @override
  String get decksEmptyBody =>
      'Salve um deck com nome, formato e carta de capa. Ao hospedar ou entrar, escolha a lista no lobby.';

  @override
  String get decksSearchHint => 'Buscar decks…';

  @override
  String decksNoSearchMatches(String query) {
    return 'Nenhum deck corresponde a “$query”.';
  }

  @override
  String get decksStyleNotSet => 'Estilo não definido';

  @override
  String get decksNoCoverCard => 'Sem carta de capa';

  @override
  String get lookupTitle => 'Busca de cartas';

  @override
  String get lookupHint => 'Busque qualquer carta de MTG…';

  @override
  String get lookupHelp => 'Texto Oracle e rulings oficiais do Scryfall.';

  @override
  String get lookupEmptyPrompt =>
      'Digite o nome de uma carta para ver as regras.';

  @override
  String lookupNoResults(String query) {
    return 'Nenhuma carta encontrada para “$query”.';
  }

  @override
  String get lookupNetworkError =>
      'Não foi possível alcançar o Scryfall. Verifique a conexão.';

  @override
  String get lookupSearch => 'Buscar';

  @override
  String get lookupOracleText => 'Texto Oracle';

  @override
  String get lookupNoOracle => 'Não há texto Oracle para esta carta.';

  @override
  String get lookupRulings => 'Rulings';

  @override
  String get lookupNoRulings => 'Não há rulings oficiais para esta carta.';

  @override
  String get endGameSavingResults => 'Salvando resultados…';

  @override
  String get endGameSaveFailedTitle => 'Não foi possível salvar os resultados.';

  @override
  String get endGameSaveFailedBody =>
      'Suas estatísticas podem não ter atualizado. Tente de novo.';

  @override
  String get endGameRetry => 'Tentar de novo';

  @override
  String get endGameContinueWithoutSaving => 'Continuar sem salvar';

  @override
  String get endGameFinalStandings => 'Classificação final';

  @override
  String get endGameOverNoWinner => 'Fim de jogo — Sem vencedor';

  @override
  String get endGamePracticeEnded => 'Prática encerrada';

  @override
  String get endGameYouWin => 'Você venceu!';

  @override
  String get endGameWinner => 'Vencedor';

  @override
  String get endGameRankUp => 'SUBIU DE RANK!';

  @override
  String endGameRankTransition(int oldLevel, int newLevel) {
    return 'Rank $oldLevel → $newLevel';
  }

  @override
  String endGameXpGained(int xp) {
    return '+$xp XP';
  }

  @override
  String get endGameWinBonusIncluded => 'Bônus de vitória incluído';

  @override
  String get endGameParticipationXp => 'XP de participação';

  @override
  String endGameRankLevel(int level) {
    return 'Rank $level';
  }

  @override
  String get endGameFeedbackThanks => 'Obrigado! Seu feedback foi registrado.';

  @override
  String get endGameRateOpponents => 'Avalie seus oponentes';

  @override
  String get endGameSubmitFeedback => 'Enviar feedback';

  @override
  String get endGameYouSuffix => '(você)';

  @override
  String get endGameElimReasonLife => 'Vida esgotada';

  @override
  String get endGameElimReasonPoison => '10 de veneno';

  @override
  String get endGameElimReasonCommanderDmg => 'Dano de Commander';

  @override
  String get endGameElimReasonConcede => 'Desistiu';

  @override
  String get endGameElimReasonDisconnect => 'Saiu do jogo';

  @override
  String get endGameElimReasonDefault => 'Eliminado';

  @override
  String get endGameBackToHome => 'Voltar ao início';

  @override
  String get feedbackTitle => 'Feedback';

  @override
  String get feedbackHeadline => 'Ajude-nos a melhorar';

  @override
  String get feedbackBody =>
      'Achou um bug? Tem uma ideia? Lemos cada mensagem.';

  @override
  String get feedbackMessageLabel => 'Sua mensagem';

  @override
  String get feedbackMessageHint => 'Conte o que você acha...';

  @override
  String get feedbackSend => 'Enviar feedback';

  @override
  String get feedbackOrDivider => 'ou';

  @override
  String get feedbackRatePlayStore => 'Avaliar na Play Store';

  @override
  String get feedbackMailSubject => 'Feedback do Life Spark';

  @override
  String get feedbackOpeningMail => 'Abrindo seu app de e-mail…';

  @override
  String feedbackNoMailAppCopied(String email) {
    return 'Sem app de e-mail — mensagem copiada. Cole em um e-mail para $email';
  }

  @override
  String feedbackClipboardFallback(String email, String message) {
    return 'Para: $email\\nAssunto: Feedback do Life Spark\\n\\n$message';
  }

  @override
  String get stackSortOrderOnStack => 'Ordem na pilha';

  @override
  String get stackSortByPlayer => 'Por jogador';

  @override
  String get stackAddSpellOrAbility => 'Adicionar magia ou habilidade';

  @override
  String get stackHowItWorksTooltip => 'Como a pilha funciona';

  @override
  String get stackFilterResolvedCountered => 'Resolvido / anulado';

  @override
  String get stackApnapHint => 'Quem adicionou o quê (jogador ativo primeiro)';

  @override
  String get stackClearAll => 'Limpar tudo';

  @override
  String get stackClearConfirmTitle => 'Limpar a pilha?';

  @override
  String get stackClearConfirmBody =>
      'Remove todas as magias e habilidades da pilha. Não dá para desfazer.';

  @override
  String stackActivePlayerLabel(String username) {
    return '$username · Jogador ativo';
  }

  @override
  String stackTurnOrderLabel(String username, int position) {
    return '$username · Ordem de turno: $position';
  }

  @override
  String get stackPutOnStack => 'Colocar na pilha';

  @override
  String get stackInResponseToEllipsis => 'Em resposta a…';

  @override
  String get stackEmptyTitle => 'Nada na pilha';

  @override
  String get stackEmptyBullet1 =>
      'Coloque magias e habilidades aqui antes de resolverem.';

  @override
  String get stackEmptyBullet2 => 'A última adicionada resolve primeiro.';

  @override
  String get stackAddSpell => 'Adicionar magia';

  @override
  String get stackStatusResolved => 'Resolvido';

  @override
  String get stackStatusCountered => 'Anulado';

  @override
  String get stackStatusFizzled => 'Falhou';

  @override
  String get stackYouSuffix => '(você)';

  @override
  String get stackUndoFizzle => 'Desfazer falha';

  @override
  String get stackFizzle => 'Falhar';

  @override
  String get stackUndoFizzleSubtitle =>
      'Coloca esta magia de volta na pilha como ativa';

  @override
  String get stackFizzleSubtitle =>
      'Alvo ilegal ou a magia saiu da pilha (counter de regras)';

  @override
  String get stackMarkCountered => 'Marcar anulado';

  @override
  String get stackRename => 'Renomear';

  @override
  String get stackOnStack => 'Na pilha';

  @override
  String get stackResolvesNext => 'Resolve a seguir';

  @override
  String get stackResolvesAfterAbove => 'Resolve depois dos de cima';

  @override
  String get stackTargetNoLongerOnStack => 'O alvo não está mais na pilha';

  @override
  String get stackCardRulesTooltip => 'Regras da carta';

  @override
  String stackInResponseToNamed(String name) {
    return 'Em resposta a $name';
  }

  @override
  String get stackResolve => 'Resolver';

  @override
  String get stackRespond => 'Responder';

  @override
  String get stackFizzledButton => 'Falhou';

  @override
  String get stackHelpTitle => 'Como a pilha funciona';

  @override
  String get stackHelpBullet1 =>
      'Quando alguém joga uma magia ou usa uma habilidade, ela vai para a pilha — uma fila de espera antes de acontecer.';

  @override
  String get stackHelpBullet2 =>
      'A última coisa adicionada resolve primeiro (como uma pilha de pratos). Por isso a entrada do topo diz Resolve a seguir.';

  @override
  String get stackHelpBullet3 =>
      'Ao adicionar uma magia, busque no Scryfall e escolha a carta da lista para guardar o nome e o texto de regras corretos.';

  @override
  String get stackHelpBullet4 =>
      'Para responder, toque em Responder ou use Em resposta a… — sua magia fica no topo e resolve antes da de baixo.';

  @override
  String get stackHelpBullet5 =>
      'Quando um efeito termina, toque em Resolver — a carta fica na pilha e fica verde. Para responder, toque em Responder. Se um counter funcionou, Marcar anulado (use o filtro Anulado para ver). Se uma magia perdeu o alvo, toque em Falhar — fica acinzentada; toque em Falhou de novo para desfazer.';

  @override
  String get stackHelpBullet6 =>
      'Na mesa você ainda diz “passo” em voz alta para a prioridade; esta tela ajuda todos a lembrar o que está esperando e em que ordem.';

  @override
  String get stackHelpExample =>
      'Exemplo: Você joga uma magia de pump na sua criatura. Seu oponente joga Lightning Bolt em resposta. Bolt resolve primeiro, depois seu pump (se o alvo ainda for legal).';

  @override
  String get stackHelpReadMore => 'Leia mais em Magic.com';

  @override
  String get stackHelpCouldNotOpenLink => 'Não foi possível abrir o link';

  @override
  String get stackPickerIntro =>
      'Busque no Scryfall para guardar o nome e o texto de regras corretos.';

  @override
  String get stackPickerCardNameLabel => 'Nome da carta';

  @override
  String get stackPickerCardNameHint => 'ex.: Lightning Bolt';

  @override
  String get stackPickerClearSearch => 'Limpar busca';

  @override
  String get stackPickerAdd => 'Adicionar';

  @override
  String get stackPickerNoCards =>
      'Nenhuma carta encontrada. Tente outra grafia.';

  @override
  String get stackPickerNetworkError =>
      'Não foi possível alcançar o Scryfall. Verifique sua internet.';

  @override
  String get stackPickerNeedSelection =>
      'Escolha uma carta da lista, ou digite um nome que o Scryfall reconheça.';

  @override
  String get stackPickerTypeToSearch => 'Digite para buscar cartas';

  @override
  String get allianceAPlayer => 'Um jogador';

  @override
  String get allianceYourAllyFallback => 'seu aliado';

  @override
  String get allianceOfferDeclined => 'Oferta de aliança secreta recusada';

  @override
  String get allianceEnded => 'Aliança secreta encerrada';

  @override
  String get allianceProposeTitle => 'Aliança secreta';

  @override
  String allianceProposeSubtitle(String username) {
    return 'Convide $username — só ele/ela saberá.';
  }

  @override
  String get allianceDurationSection => 'Duração';

  @override
  String get allianceDurationEndOfTurn => 'Até o fim do turno';

  @override
  String get allianceDurationEndOfRound => 'Até o fim da rodada';

  @override
  String get allianceDurationUntilBroken => 'Até ser quebrada';

  @override
  String get allianceWhenToDeliver => 'Quando entregar';

  @override
  String get allianceDeliverNow => 'Entregar agora';

  @override
  String allianceDeliverInSeconds(int seconds) {
    return 'Entregar em ${seconds}s';
  }

  @override
  String get allianceDeliverEndOfYourTurn => 'Entregar no fim do seu turno';

  @override
  String get allianceDeliverNextRound => 'Entregar na próxima rodada';

  @override
  String allianceSecondsShort(int seconds) {
    return '${seconds}s';
  }

  @override
  String get allianceSend => 'Enviar';

  @override
  String allianceWhisperSent(String username) {
    return 'Sussurro enviado para $username';
  }

  @override
  String allianceWhisperScheduled(String username) {
    return 'Sussurro agendado para $username';
  }

  @override
  String get allianceInviteTitle => 'Oferta secreta';

  @override
  String allianceInviteBody(String username, String duration) {
    return '$username propõe uma aliança secreta.\\n\\nDuração: $duration\\n\\nSó você pode ver isto.';
  }

  @override
  String get allianceAccept => 'Aceitar';

  @override
  String get allianceDecline => 'Recusar';

  @override
  String get allianceFormedTitle => 'Aliança formada';

  @override
  String allianceFormedBody(String username, String duration) {
    return 'Você e $username agora estão secretamente aliados ($duration).\\n\\nA mesa não sabe — a menos que revelem ou traiam.';
  }

  @override
  String allianceFormedBodyNoDuration(String username) {
    return 'Você e $username agora estão secretamente aliados.\\n\\nA mesa não sabe — a menos que revelem ou traiam.';
  }

  @override
  String get allianceUnderstood => 'Entendi';

  @override
  String get allianceRevealedTitle => 'Aliança revelada';

  @override
  String allianceRevealedBody(String playerA, String playerB) {
    return '$playerA e $playerB revelaram a aliança secreta à mesa.';
  }

  @override
  String get allianceOk => 'OK';

  @override
  String get allianceBetrayalTitle => 'Traição!';

  @override
  String allianceBetrayalBody(String playerA, String playerB) {
    return 'A aliança secreta entre $playerA e $playerB foi quebrada por traição.';
  }

  @override
  String get allianceBadgeAllied => 'Aliado';

  @override
  String get allianceBadgeSecretAlly => 'Aliado secreto';

  @override
  String allianceWhisperPending(String username) {
    return 'Sussurro pendente → $username';
  }

  @override
  String allianceAwaiting(String username) {
    return 'Aguardando $username';
  }

  @override
  String get cmdDmgSheetTitle => 'Dano de Commander';

  @override
  String get cmdDmgSheetSubtitle =>
      'Ameaças a você primeiro. Abra Causado para registrar o dano que você causou.';

  @override
  String cmdDmgBarA11y(String remaining, String ko, String taken) {
    return 'Dano de Commander: $remaining de $ko restantes, $taken no pior track, toque para gerenciar';
  }

  @override
  String get cmdDmgLeft => 'restantes';

  @override
  String get cmdDmgHideDealt => 'Ocultar causado';

  @override
  String cmdDmgDealtTotal(String total) {
    return 'Causado $total';
  }

  @override
  String get cmdDmgDefaultCommander => 'Commander';

  @override
  String get cmdDmgDefaultPartner => 'Partner';

  @override
  String get cmdDmgDefaultPartnerCommander => 'Commander Partner';

  @override
  String cmdDmgYouDealtTitle(String name) {
    return 'Você → $name';
  }

  @override
  String get cmdDmgYouDealtSubtitle => 'Dano que você causou';

  @override
  String get cmdDmgLethalTooltip => 'Dano letal de Commander!';

  @override
  String get cmdDmgIncreaseA11y => 'Aumentar dano de Commander';

  @override
  String get cmdDmgDecreaseA11y => 'Diminuir dano de Commander';

  @override
  String get cmdBarCastCommander => 'Jogar Commander';

  @override
  String get cmdBarEliminated => 'Eliminado';

  @override
  String get cmdBarNoTaxYet => 'Sem taxa ainda';

  @override
  String get cmdBarRemoveLastCast => 'Remover último cast de Commander';

  @override
  String get cmdBarCommanderTax => 'Taxa de Commander';

  @override
  String get cmdBarTapToRemoveLastCast => 'Toque para remover o último cast';

  @override
  String cmdBarTaxPlus(int tax) {
    return 'Taxa +$tax';
  }

  @override
  String get counterResetConfirmTitle => 'Zerar?';

  @override
  String get counterResetConfirmBody => 'Definir este contador como zero.';

  @override
  String get counterResetConfirmAction => 'Zerar';

  @override
  String get counterResetToZero => 'Zerar';

  @override
  String get counterDone => 'Concluído';

  @override
  String get firstPlayerRollTitle => 'Rolar pelo primeiro jogador';

  @override
  String get firstPlayerRollSubtitle =>
      'O maior resultado começa. Toque no dado para rolar!';

  @override
  String get firstPlayerRollDieA11y => 'Rolar dado';

  @override
  String get firstPlayerRollingA11y => 'Rolando';

  @override
  String firstPlayerRolledA11y(String value) {
    return 'Rolou $value';
  }

  @override
  String get firstPlayerNotRolledA11y => 'Não rolou';

  @override
  String firstPlayerYouRolled(String value) {
    return 'Você rolou $value!';
  }

  @override
  String firstPlayerYouRolledA11y(String value) {
    return 'Você rolou $value';
  }

  @override
  String get firstPlayerRolling => 'Rolando…';

  @override
  String get firstPlayerTapToRoll => 'Toque para rolar';

  @override
  String firstPlayerHostProgressA11y(String rolled, String total) {
    return '$rolled de $total jogadores rolaram';
  }

  @override
  String get firstPlayerWaitingOthersA11y =>
      'Aguardando outros jogadores rolarem';

  @override
  String get firstPlayerRollToContinueA11y => 'Role o dado para continuar';

  @override
  String firstPlayerHostProgress(String rolled, String total) {
    return '$rolled / $total jogadores rolaram';
  }

  @override
  String get firstPlayerWaitingOthers => 'Aguardando outros rolarem…';

  @override
  String get firstPlayerTapDieAbove => 'Toque no dado acima para rolar';

  @override
  String firstPlayerYouSuffix(String username) {
    return '$username (você)';
  }

  @override
  String get firstPlayerTurnOrderTitle => 'Ordem de turnos';

  @override
  String get firstPlayerTurnOrderSubtitle =>
      'O maior resultado lidera — o jogo segue nesta ordem.';

  @override
  String get firstPlayerStartGame => 'Começar jogo';

  @override
  String get firstPlayerOrdinal1 => '1º';

  @override
  String get firstPlayerOrdinal2 => '2º';

  @override
  String get firstPlayerOrdinal3 => '3º';

  @override
  String get firstPlayerOrdinal4 => '4º';

  @override
  String get firstPlayerOrdinal5 => '5º';

  @override
  String get firstPlayerOrdinal6 => '6º';

  @override
  String firstPlayerSlotA11y(String place, String name, String rollDetail) {
    return '$place, $name, $rollDetail';
  }

  @override
  String firstPlayerSlotYou(String username) {
    return '$username, você';
  }

  @override
  String get firstPlayerRollUnavailable => 'rolagem indisponível';

  @override
  String firstPlayerRolledDetail(String value) {
    return 'rolou $value';
  }

  @override
  String get firstPlayerGoesFirst => 'começa';

  @override
  String get historyTitle => 'Histórico';

  @override
  String get historySubtitle => 'Vida, contadores e outras ações da mesa.';

  @override
  String get historyEmptyTitle => 'Nenhuma ação ainda';

  @override
  String get historyEmptyBody =>
      'Mudanças de vida, contadores e outras ações aparecerão aqui conforme o jogo avança.';

  @override
  String historyTurn(String turn) {
    return 'Turno $turn';
  }

  @override
  String get overviewElimReasonLife => 'Perda de vida';

  @override
  String get overviewElimReasonPoison => 'Veneno';

  @override
  String get overviewElimReasonCommanderDmg => 'Dano de Commander';

  @override
  String get overviewElimReasonConcede => 'Desistiu';

  @override
  String get overviewElimReasonDisconnect => 'Desconectado';

  @override
  String overviewRound(int round) {
    return 'Rodada $round';
  }

  @override
  String get overviewClose => 'Fechar visão geral';

  @override
  String get overviewTools => 'Ferramentas';

  @override
  String get overviewHistory => 'Histórico';

  @override
  String get overviewPlayers => 'Jogadores';

  @override
  String get overviewHoldDragReorder =>
      'Segure e arraste para reordenar turnos';

  @override
  String get overviewDecreaseLife => 'Diminuir vida';

  @override
  String get overviewIncreaseLife => 'Aumentar vida';

  @override
  String overviewCommanderTaxPlus(int tax) {
    return 'Taxa de Commander mais $tax';
  }

  @override
  String overviewTaxPlus(int tax) {
    return 'Taxa +$tax';
  }

  @override
  String get overviewMonarchA11y => 'Monarch';

  @override
  String get overviewInitiativeA11y => 'Initiative';

  @override
  String get overviewNowPlaying => 'JOGANDO AGORA';

  @override
  String get overviewSendWhisper => 'Enviar sussurro';

  @override
  String get overviewAssignTeamColor => 'Atribuir cor de time';

  @override
  String get overviewProposeSecretAlliance => 'Propor aliança secreta';

  @override
  String get overviewRevealAlliance => 'Revelar aliança à mesa';

  @override
  String get overviewBreakAlliance => 'Quebrar aliança secreta';

  @override
  String get overviewAssignTeamTitle => 'Atribuir time';

  @override
  String get overviewTeamNone => 'Nenhum';

  @override
  String overviewTeamN(String index) {
    return 'Time $index';
  }

  @override
  String dialsStripLimitSnack(int max) {
    return 'Sua faixa comporta até $max contadores. Remova um para adicionar outro.';
  }

  @override
  String get dialsLabelPoison => 'Veneno';

  @override
  String get dialsLabelEnergy => 'Energia';

  @override
  String get dialsLabelExp => 'Exp';

  @override
  String get dialsLabelRad => 'Rad';

  @override
  String get dialsLabelBlood => 'Sangue';

  @override
  String get dialsLabelClue => 'Pista';

  @override
  String get dialsLabelMap => 'Mapa';

  @override
  String get dialsLabelTreasure => 'Tesouro';

  @override
  String get dialsLabelDevotion => 'Devoção';

  @override
  String get dialsLabelCreatures => 'Criaturas';

  @override
  String get dialsLabelEnchant => 'Encant.';

  @override
  String get dialsLabelArtifacts => 'Artefatos';

  @override
  String get dialsLabelGy => 'Cemitério';

  @override
  String get dialsLabelExile => 'Exílio';

  @override
  String get dialsAddCounterTitle => 'Adicionar contador';

  @override
  String dialsAddCounterBody(int max) {
    return 'Escolha trackers para sua faixa (máx. $max). Toque no X de um contador para removê-lo.';
  }

  @override
  String get dialsSectionCommon => 'Comuns';

  @override
  String get dialsSectionTokensZones => 'Tokens e zonas';

  @override
  String get dialsAllBuiltInsOnStrip =>
      'Todos os contadores embutidos já estão na sua faixa. Remova um para liberar um espaço.';

  @override
  String get dialsAddCounterTooltip => 'Adicionar contador';

  @override
  String get dialsRemoveFromStrip => 'Remover da faixa';

  @override
  String get hubGuideTitle => 'Tour rápido';

  @override
  String get hubGuideSkip => 'Pular';

  @override
  String get hubGuideNext => 'Próximo';

  @override
  String get hubGuideGotIt => 'Entendi';

  @override
  String get hubGuideSlidePlayTitle => 'Jogar';

  @override
  String get hubGuideSlidePlayBody =>
      'Acompanhe vida e contadores aqui. Fim do turno fica sob a barra de fases — ou desative o rastreador de fases no lobby para um controle grande de Fim do turno.';

  @override
  String get hubGuideSlideStackTitle => 'Pilha e busca';

  @override
  String get hubGuideSlideStackBody =>
      'A pilha é para Hold Priority e resolver efeitos. A busca abre o Scryfall sem sair do seu lugar — texto do oráculo e rulings.';

  @override
  String get hubGuideSlideTableTitle => 'Visão da mesa';

  @override
  String get hubGuideSlideTableBody =>
      'Abra Mesa para todo o pod. Ferramentas tem dados e moedas que todos veem; Histórico fica no cabeçalho. Fim do turno fica fixo; Desistir fica abaixo.';

  @override
  String get hubGuideSlideCommanderTitle => 'Seu turno e Commander';

  @override
  String get hubGuideSlideCommanderBody =>
      'Quando o assento for seu, toque no aviso Seu turno para dispensá-lo. O coração rastreia dano de Commander até 21.';

  @override
  String lifeA11yEliminatedAt(String life) {
    return 'Eliminado com $life de vida';
  }

  @override
  String lifeA11yLifeTotal(String life) {
    return '$life de vida total';
  }

  @override
  String get lifeA11yDecrease => 'Diminuir vida';

  @override
  String get lifeA11yIncrease => 'Aumentar vida';

  @override
  String get lifeSetTotalTitle => 'Definir vida total';

  @override
  String get glanceOpenTableA11y => 'Abrir visão da mesa, ordem de turnos';

  @override
  String get glanceYou => 'Você';

  @override
  String get phasePickerTitle => 'Selecionar fase';

  @override
  String get phasePickerSubtitle =>
      'Role e toque em uma fase, ou use Definir fase para o passo destacado.';

  @override
  String phasePickerSetPhase(String phase) {
    return 'Definir $phase';
  }

  @override
  String get whisperPresetTeamUp => 'Time juntos?';

  @override
  String get whisperPresetDontAttack => 'Não me ataque';

  @override
  String get whisperPresetHaveRemoval => 'Tenho remoção';

  @override
  String get whisperPresetAllGood => 'Tudo bem';

  @override
  String whisperSentSnack(String username) {
    return 'Sussurro enviado para $username';
  }

  @override
  String get whisperSendFailed =>
      'Não foi possível enviar — aguarde um momento ou verifique a conexão.';

  @override
  String whisperSheetTitle(String username) {
    return 'Sussurro para $username';
  }

  @override
  String get whisperSheetSubtitle =>
      'Só eles veem — some depois. Não é salvo no histórico.';

  @override
  String get whisperCustomLabel => 'Mensagem personalizada';

  @override
  String get whisperCustomHint => 'Nota curta…';

  @override
  String get whisperSend => 'Enviar sussurro';

  @override
  String whisperOverlayA11y(String username, String text) {
    return 'Sussurro de $username: $text';
  }

  @override
  String whisperOverlayHeader(String username) {
    return 'Sussurro de $username';
  }

  @override
  String get politicsTapToAssignA11y =>
      'Política da mesa. Toque para atribuir.';

  @override
  String get politicsStatusEmpty => 'Sem Monarch · Sem Initiative · —';

  @override
  String get politicsDay => 'Dia';

  @override
  String get politicsNight => 'Noite';

  @override
  String get politicsAssignSheetTitle => 'Atribuir política da mesa';

  @override
  String get politicsMonarch => 'Monarch';

  @override
  String get politicsInitiative => 'Initiative';

  @override
  String get politicsAssignMonarch => 'Atribuir Monarch';

  @override
  String get politicsAssignInitiative => 'Atribuir Initiative';

  @override
  String get politicsNone => 'Nenhum';

  @override
  String get politicsDayNight => 'Dia/Noite';

  @override
  String get tableToolsTitle => 'Ferramentas';

  @override
  String get tableToolsSubtitle => 'Todos na mesa veem o resultado.';

  @override
  String get tableToolsD6 => 'd6';

  @override
  String get tableToolsD20 => 'd20';

  @override
  String get tableToolsCoin => 'Moeda';

  @override
  String get tableToolsResultHint => 'O resultado aparece para toda a mesa';

  @override
  String get tableToolsRollD6 => 'Rolar d6';

  @override
  String get tableToolsRollD20 => 'Rolar d20';

  @override
  String get tableToolsFlipCoin => 'Jogar moeda';

  @override
  String get tableToolHeads => 'Cara';

  @override
  String get tableToolTails => 'Coroa';

  @override
  String tableToolRolledHeadline(String username, String result) {
    return '$username rolou um $result';
  }

  @override
  String tableToolFlippedHeadline(String username, String result) {
    return '$username tirou $result';
  }

  @override
  String get tableToolTapToDismiss => 'Toque para fechar';

  @override
  String tableToolDismissA11y(String headline) {
    return '$headline. Toque para fechar.';
  }

  @override
  String get tableToolPlayerFallback => 'Jogador';

  @override
  String get variantDeckSingular => 'Deck de variante';

  @override
  String get variantDeckPlural => 'Decks de variante';

  @override
  String variantDeckA11y(String label) {
    return '$label, toque para ver';
  }

  @override
  String get variantDecksSheetTitle => 'Decks de variante';

  @override
  String get variantLoading => 'Carregando decks de variante…';

  @override
  String get variantLoadFailed =>
      'Não foi possível carregar os decks (internet necessária)';

  @override
  String get variantPlanechase => 'Planechase';

  @override
  String get variantArchenemy => 'Archenemy';

  @override
  String get variantBounty => 'Bounty';

  @override
  String get variantNextCard => 'Próxima carta';

  @override
  String commanderSelectNoCommanders(String query) {
    return 'Nenhum commander encontrado para \"$query\"';
  }

  @override
  String commanderSelectNoCards(String query) {
    return 'Nenhuma carta encontrada para \"$query\"';
  }

  @override
  String get commanderSelectSearchFailed =>
      'Não foi possível buscar. Verifique a internet e tente de novo.';

  @override
  String get commanderSelectEditCommanders => 'Editar commanders';

  @override
  String get commanderSelectEditCover => 'Editar carta de capa';

  @override
  String get commanderSelectStep2Commander => 'Passo 2 de 2 — commander';

  @override
  String get commanderSelectStep2Cover => 'Passo 2 de 2 — carta de capa';

  @override
  String get commanderSelectPartnerTitle => 'Selecionar Partner';

  @override
  String get commanderSelectCommanderTitle => 'Selecionar Commander';

  @override
  String get commanderSelectCoverHint =>
      'Escolha qualquer carta para a arte do deck — não é sua lista completa.';

  @override
  String get commanderSelectSearchPartnerHint => 'Buscar commander Partner…';

  @override
  String get commanderSelectSearchCommanderHint => 'Buscar um commander…';

  @override
  String get commanderSelectSearchCardHint => 'Buscar uma carta…';

  @override
  String get commanderSelectConfirm => 'Confirmar';

  @override
  String get commanderSelectScryfallCommanderHelp =>
      'Digite um nome de commander para buscar no Scryfall.';

  @override
  String get commanderSelectScryfallCardHelp =>
      'Digite um nome de carta para buscar no Scryfall.';

  @override
  String get commanderSelectLabelCommander => 'Commander';

  @override
  String get commanderSelectLabelPartner => 'Partner';

  @override
  String get commanderSelectOptional => 'opcional';

  @override
  String get deckOptionsDeleteTitle => 'Excluir deck?';

  @override
  String deckOptionsDeleteBody(String name) {
    return 'Remover “$name” da sua biblioteca? O histórico de partidas permanece, mas este deck não aparecerá mais no seletor do lobby.';
  }

  @override
  String get deckOptionsDeleteConfirm => 'Excluir';

  @override
  String get deckOptionsStyleNotSet => 'Estilo não definido';

  @override
  String get deckOptionsEditCommanders => 'Editar commanders';

  @override
  String get deckOptionsEditCover => 'Editar carta de capa';

  @override
  String get deckOptionsNoGamesYet => 'Nenhuma partida ainda';

  @override
  String deckOptionsWinRate(String rate) {
    return '$rate% de vitórias';
  }

  @override
  String get deckOptionsUnpin => 'Desafixar do topo';

  @override
  String get deckOptionsPin => 'Fixar no topo';

  @override
  String get deckOptionsChangeFormat => 'Mudar formato';

  @override
  String get deckOptionsChangeStyle => 'Mudar estilo';

  @override
  String get deckOptionsStyleRequired => 'Obrigatório — não definido';

  @override
  String get deckOptionsRename => 'Renomear';

  @override
  String get deckOptionsDuplicate => 'Duplicar';

  @override
  String get deckOptionsDelete => 'Excluir deck';

  @override
  String get deckOptionsRenameTitle => 'Renomear deck';

  @override
  String get deckOptionsNameLabel => 'Nome do deck';

  @override
  String get deckOptionsNameHint => 'ex.: Raffine Tempo';

  @override
  String get newDeckChooseStyleError =>
      'Escolha um estilo de deck para continuar';

  @override
  String get newDeckTitle => 'Novo deck';

  @override
  String get newDeckSubtitle => 'Passo 1 de 2 — detalhes';

  @override
  String get newDeckIntro =>
      'Nomeie seu deck, escolha formato e estilo. Em seguida você escolhe o commander ou a carta de capa.';

  @override
  String get newDeckNameLabel => 'Nome do deck';

  @override
  String get newDeckNameHint => 'ex.: Raffine Tempo';

  @override
  String get newDeckNext => 'Próximo';

  @override
  String get formatPickerTitle => 'Formato';

  @override
  String get formatPickerSearchHint => 'Buscar formatos…';

  @override
  String get formatPickerFieldLabel => 'Formato';

  @override
  String formatPickerMultiplayerLife(String life) {
    return 'Multijogador · $life de vida inicial';
  }

  @override
  String formatPickerConstructedLife(String life) {
    return 'Constructed · $life de vida inicial';
  }

  @override
  String get stylePickerTitle => 'Estilo de deck';

  @override
  String get stylePickerSearchHint => 'Buscar estilos…';

  @override
  String get stylePickerChoose => 'Escolher estilo de deck';

  @override
  String get stylePickerFieldLabel => 'Estilo de deck';

  @override
  String get profileOptionsTitle => 'Perfil';

  @override
  String get profileOptionsEdit => 'Editar perfil';

  @override
  String get profileOptionsEditSubtitle => 'Altere seu nome ou avatar';

  @override
  String get profileOptionsBackup => 'Fazer backup do perfil';

  @override
  String get profileOptionsBackupSubtitle =>
      'Salve perfil, decks, jogos e feedback neste celular';

  @override
  String get profilePicTitle => 'Foto de perfil';

  @override
  String profilePicNoCards(String query) {
    return 'Nenhuma carta encontrada para \"$query\"';
  }

  @override
  String get profilePicSearchFailed =>
      'Não foi possível buscar. Verifique a internet e tente de novo.';

  @override
  String get profilePicPhotoFailed =>
      'Não foi possível usar essa foto. Tente outra imagem.';

  @override
  String get profilePicCommander => 'Commander';

  @override
  String get profilePicDefault => 'Padrão';

  @override
  String get profilePicRemove => 'Remover';

  @override
  String get profilePicUpload => 'Enviar foto';

  @override
  String get profilePicTake => 'Tirar foto';

  @override
  String get profilePicOrSearch => 'Ou busque arte de carta de MTG';

  @override
  String get profilePicSearchHint =>
      'Buscar cartas de MTG para foto de perfil…';

  @override
  String get profilePicHelp =>
      'Envie uma foto, tire uma ou busque uma carta—a arte vira sua foto de perfil.';

  @override
  String get ranksInfoTitle => 'Ranks e níveis';

  @override
  String get ranksInfoBody =>
      'O nível é seu progresso exato. O rank é o título da sua faixa de nível. Os tiers metálicos agrupam esses ranks.';

  @override
  String ranksInfoLevelRange(int min, int max) {
    return 'Nv $min–$max';
  }

  @override
  String get statsPlayerBehaviour => 'Comportamento';

  @override
  String get statsMostPlayed => 'Mais jogado';

  @override
  String get statsNoDeckStatsYet => 'Ainda sem estatísticas de decks.';

  @override
  String get statsToughRecord => 'Recorde difícil';

  @override
  String get statsNoLossesOnDeck => 'Ainda sem derrotas em um deck salvo.';

  @override
  String get statsPlayerStats => 'Estatísticas do jogador';

  @override
  String get statsSingularUnit => 'stat';

  @override
  String get statsPluralUnit => 'stats';

  @override
  String get statsLeaningGood => 'para bom';

  @override
  String get statsLeaningSalty => 'para salty';

  @override
  String get statsLeaningNeutral => 'neutro';

  @override
  String statsBehaviourA11y(String leaning) {
    return 'Espectro de comportamento, $leaning';
  }

  @override
  String get statsRecord => 'Recorde';

  @override
  String get statsWinRate => 'Taxa de vitórias';

  @override
  String statsRecordFooter(int wins, int losses, int games) {
    return '${wins}V–${losses}D  ·  $games jogos';
  }

  @override
  String get statsWinStreak => 'Sequência de vitórias';

  @override
  String get statsWinToStartStreak => 'Vença para começar uma sequência';

  @override
  String get statsPersonalBest => 'Recorde pessoal';

  @override
  String statsBestStreak(int best) {
    return 'Melhor: $best';
  }

  @override
  String get statsNoActiveStreak => 'Sem sequência ativa';

  @override
  String get statsCurrent => 'Atual';

  @override
  String statsLevelShort(int level) {
    return 'Nv $level';
  }

  @override
  String get statsLevelProgress => 'Progresso de nível';

  @override
  String get statsLevelProgressA11y =>
      'Progresso de nível. Ver todos os ranks.';

  @override
  String get statsGood => 'Bom';

  @override
  String get statsNeutral => 'Neutro';

  @override
  String get statsSalty => 'Salty';

  @override
  String get profileBackupSaveFailed => 'Não foi possível salvar o backup.';

  @override
  String get profileUsernameLabel => 'Nome de usuário';

  @override
  String get profileUsernameHint => 'ex.: The Archduke';

  @override
  String get profileUsernameRequired => 'Digite um nome de usuário';

  @override
  String get profileUsernameTooShort => 'Deve ter pelo menos 2 caracteres';

  @override
  String get profileSetupUsernameHint => 'ex.: The Archduke';

  @override
  String carouselFilterTooltip(String label) {
    return 'Filtro: $label';
  }

  @override
  String carouselRecentMatchA11y(String result, String format) {
    return 'Partida recente, $result, $format';
  }

  @override
  String get carouselCloseReturnsSummary => 'O botão Fechar volta ao resumo';

  @override
  String get carouselShowMoreDetails =>
      'Mostrar mais para detalhes completos, ou toque no card';

  @override
  String get decksClearSearchTooltip => 'Limpar';

  @override
  String get settingsDefaultFormatSheetTitle => 'Formato padrão';

  @override
  String get settingsDefaultStartingLifeSheetTitle => 'Vida inicial padrão';

  @override
  String settingsAboutVersionBeta(String version) {
    return 'Life Spark v$version · Beta';
  }

  @override
  String get settingsAboutByAuthor => 'por Federick Vidot';

  @override
  String get settingsAboutCardDataPoweredBy => 'Dados de cartas por';

  @override
  String get settingsAboutScryfall => 'Scryfall';

  @override
  String get settingsAboutDisclaimer =>
      'Life Spark é Fan Content não oficial permitido pela Fan Content Policy. Não aprovado/endossado pela Wizards. Parte do material é propriedade da Wizards of the Coast. ©Wizards of the Coast LLC.';

  @override
  String get feedbackLike => 'Curtir';

  @override
  String get feedbackClearLike => 'Remover curtida';

  @override
  String get feedbackDislike => 'Não curtir';

  @override
  String get feedbackClearDislike => 'Remover não curtida';

  @override
  String get feedbackSparkOfTheGame => 'Faísca do jogo';

  @override
  String get feedbackSparkHint => 'Opcional — escolha um jogador';

  @override
  String get feedbackNoneOption => '— Nenhum —';

  @override
  String tierBadgeLabel(String rank, int level) {
    return '$rank · Nv $level';
  }

  @override
  String tierBadgeA11y(String label) {
    return 'Rank $label. Ver todos os ranks.';
  }

  @override
  String get tierBronze => 'Bronze';

  @override
  String get tierSilver => 'Prata';

  @override
  String get tierGold => 'Ouro';

  @override
  String get tierPlatinum => 'Platina';

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
  String get rankArchmage => 'Arquimago';

  @override
  String get rankHighArchmage => 'Alto Arquimago';

  @override
  String get rankPlanewright => 'Planewright';

  @override
  String get rankGrandArchmage => 'Grande Arquimago';

  @override
  String get rankVoidcaller => 'Voidcaller';

  @override
  String get rankArchwizard => 'Archwizard';

  @override
  String get rankSpireLegend => 'Lenda da Spire';

  @override
  String get rankAscendantArchon => 'Arconte Ascendente';

  @override
  String get deckTileWinRateAbbr => 'WR';

  @override
  String get deckTileWinsAbbr => 'V';

  @override
  String get deckTileLossesAbbr => 'D';

  @override
  String get deckTileGamesAbbr => 'JG';

  @override
  String get brandLifeSpark => 'Life Spark';

  @override
  String get hostTogglePlanechase => 'Planechase';

  @override
  String get hostToggleArchenemy => 'Archenemy';

  @override
  String get hostToggleBounty => 'Bounty';

  @override
  String get lookupClearTooltip => 'Limpar';

  @override
  String phaseNavCurrentA11y(String phase) {
    return 'Fase atual, $phase';
  }

  @override
  String cmdDmgThreatHelp(int ko) {
    return 'Dano que cada comandante causou a você — $ko elimina.';
  }

  @override
  String get cmdDmgEmptyPod =>
      'Os oponentes aparecerão aqui quando outros entrarem na mesa.';

  @override
  String get statusOut => 'FORA';

  @override
  String infoBarAlly(String name) {
    return 'Aliado · $name';
  }

  @override
  String get infoBarAllySecret => 'secreto';

  @override
  String get gamePlayerDataUnavailable => 'Dados do jogador indisponíveis';

  @override
  String get startupErrorTitle => 'Erro na inicialização';

  @override
  String get startupStackTrace => 'Rastreamento de pilha:';

  @override
  String get paletteViolet => 'Violeta';

  @override
  String get paletteCrimson => 'Carmesim';

  @override
  String get paletteSlate => 'Ardósia';

  @override
  String get paletteForest => 'Floresta';

  @override
  String get paletteObsidian => 'Obsidiana';

  @override
  String get paletteFog => 'Névoa';

  @override
  String networkCannotReachHost(String error) {
    return 'Não foi possível alcançar o host: $error';
  }

  @override
  String get backupFileTypeLabel => 'Backup do Life Spark';

  @override
  String get backupNotValidFile => 'Não é um arquivo de backup do Life Spark.';

  @override
  String get backupNotValidJson => 'O arquivo de backup não é um JSON válido.';

  @override
  String get backupCouldNotRead =>
      'Não foi possível ler o arquivo de backup selecionado.';

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
    return '$name alterou sua vida $delta';
  }

  @override
  String logCounterChangedYours(String name, String counter, String delta) {
    return '$name alterou seu $counter $delta';
  }

  @override
  String logEndsTurn(String name) {
    return '$name encerra o turno';
  }

  @override
  String logCmdDmgDealtYou(String name, String delta) {
    return '$name causou a você $delta de dano de comandante';
  }

  @override
  String logCmdDmgYouDealt(String name, String delta) {
    return 'Você causou a $name $delta de dano de comandante';
  }

  @override
  String logCmdDmgOther(String from, String to, String delta) {
    return '$from → $to: Dano de comandante $delta';
  }

  @override
  String get logTurnOrderUpdated => 'Ordem de turnos atualizada pelo host';

  @override
  String get logProliferate => 'Proliferar: todos os jogadores';

  @override
  String logAllianceRevealed(String a, String b) {
    return 'Aliança revelada: $a e $b';
  }

  @override
  String logAllianceBetrayal(String a, String b) {
    return 'Aliança quebrada — traição: $a e $b';
  }

  @override
  String get logAllianceBroken => 'Aliança quebrada';

  @override
  String logAllianceFormed(String a, String b, String duration) {
    return 'Aliança secreta formada: $a e $b ($duration)';
  }

  @override
  String logPlayerLeft(String name) {
    return '$name saiu da partida';
  }

  @override
  String logRolled(String name, String result) {
    return '$name rolou um $result';
  }

  @override
  String logFlipped(String name, String result) {
    return '$name tirou $result';
  }

  @override
  String logStackAdded(String name, String item) {
    return '$name adicionou “$item”';
  }

  @override
  String logStackAddedResponse(String name, String item) {
    return '$name adicionou “$item” (resposta)';
  }

  @override
  String logStackRenamed(String name, String item) {
    return '$name renomeou item da pilha para “$item”';
  }

  @override
  String logStackStatus(String name, String item, String status) {
    return '“$item” de $name $status';
  }

  @override
  String get logClearedStack => 'Pilha limpa';

  @override
  String get logCounterPoison => 'Veneno';

  @override
  String get logCounterEnergy => 'Energia';

  @override
  String get logCounterExperience => 'Experiência';

  @override
  String get logCounterRad => 'Rad';

  @override
  String get logCounterBlood => 'Sangue';

  @override
  String get logCounterClue => 'Pista';

  @override
  String get logCounterMap => 'Mapa';

  @override
  String get logCounterTreasure => 'Tesouro';

  @override
  String get logCounterDevotion => 'Devoção';

  @override
  String get logCounterCreatures => 'Criaturas';

  @override
  String get logCounterEnchantments => 'Encantamentos';

  @override
  String get logCounterArtifacts => 'Artefatos';

  @override
  String get logCounterGyCreatures => 'Criaturas do cemitério';

  @override
  String get logCounterExile => 'Exílio';

  @override
  String get logStackStatusFizzled => 'falhou';

  @override
  String get logStackStatusCountered => 'anulado';

  @override
  String get logStackStatusResolved => 'resolvido';

  @override
  String get logStackStatusReactivated => 'reativado';

  @override
  String get logDurationEndOfTurn => 'Até o fim do turno';

  @override
  String get logDurationEndOfRound => 'Até o fim da rodada';

  @override
  String get logDurationUntilBroken => 'Até ser quebrada';

  @override
  String get logHeads => 'Cara';

  @override
  String get logTails => 'Coroa';
}

/// The translations for Portuguese, as used in Brazil (`pt_BR`).
class AppLocalizationsPtBr extends AppLocalizationsPt {
  AppLocalizationsPtBr() : super('pt_BR');

  @override
  String get appTitle => 'Life Spark';

  @override
  String get navProfile => 'Perfil';

  @override
  String get navLobby => 'Lobby';

  @override
  String get navDecks => 'Decks';

  @override
  String get navSettings => 'Configurações';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get settingsSectionGameplay => 'Jogabilidade';

  @override
  String get settingsDefaultFormat => 'Formato padrão';

  @override
  String settingsDefaultFormatSubtitle(String format) {
    return '$format · usado ao hospedar';
  }

  @override
  String get settingsDefaultStartingLife => 'Vida inicial padrão';

  @override
  String settingsDefaultStartingLifeSubtitle(int life) {
    return '$life de vida · usado ao hospedar';
  }

  @override
  String get settingsSectionMisc => 'Diversos';

  @override
  String get settingsKeepDisplayAwake => 'Manter tela ligada';

  @override
  String get settingsKeepDisplayAwakeSubtitle =>
      'Impede que a tela desligue durante uma partida';

  @override
  String get settingsHideSystemBars => 'Ocultar barras de navegação e status';

  @override
  String get settingsHideSystemBarsSubtitle => 'Modo tela cheia durante o jogo';

  @override
  String get settingsSectionAppearance => 'Aparência';

  @override
  String get settingsDarkAppearance => 'Aparência escura';

  @override
  String get settingsDarkAppearanceSubtitle =>
      'O modo claro usa fundos suaves — experimente Fog ou Slate';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguageSystem => 'Padrão do sistema';

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
  String get settingsSectionFeel => 'Sensação';

  @override
  String get settingsHapticFeedback => 'Feedback tátil';

  @override
  String get settingsHapticFeedbackSubtitle =>
      'Vibrar em mudanças de vida e subidas de rank';

  @override
  String get settingsShakeToUndo => 'Agitar para desfazer';

  @override
  String get settingsShakeToUndoSubtitle =>
      'Agite o telefone para desfazer a última mudança de vida';

  @override
  String get settingsSectionData => 'Dados';

  @override
  String get settingsCacheCommanderImages => 'Cachear imagens de comandante';

  @override
  String get settingsCacheCommanderImagesSubtitle =>
      'Armazena imagens do Scryfall para uso offline';

  @override
  String get settingsClearImageCache => 'Limpar cache de imagens';

  @override
  String get settingsClearImageCacheSubtitle =>
      'Libera espaço das imagens de cartas em cache';

  @override
  String get settingsSaveBackup => 'Salvar backup';

  @override
  String get settingsSaveBackupSubtitle =>
      'Salva perfil, decks, configurações, partidas recentes e feedback em um arquivo';

  @override
  String get settingsRestoreBackup => 'Restaurar backup';

  @override
  String get settingsRestoreBackupSubtitle =>
      'Substitui todos os dados locais por um arquivo .lifespark';

  @override
  String get settingsSectionHelp => 'Ajuda';

  @override
  String get settingsFeedback => 'Feedback';

  @override
  String get settingsFeedbackSubtitle => 'Envie suas ideias e sugestões';

  @override
  String get settingsViewHubGuide => 'Ver guia do hub';

  @override
  String get settingsViewHubGuideSubtitle =>
      'Como Jogar, Pilha, Busca e Mesa funcionam em uma partida';

  @override
  String get settingsViewTutorialAgain => 'Ver o tutorial novamente';

  @override
  String get settingsViewTutorialAgainSubtitle =>
      'Relança o passo a passo inicial';

  @override
  String get settingsBeta => 'Beta';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonSave => 'Salvar';

  @override
  String get commonAdd => 'Adicionar';

  @override
  String get commonRemove => 'Remover';

  @override
  String get commonClose => 'Fechar';

  @override
  String get commonTryAgain => 'Tentar de novo';

  @override
  String get backupSaved => 'Backup salvo.';

  @override
  String get backupSaveFailed => 'Não foi possível salvar o backup.';

  @override
  String backupRestoreTitle(String username) {
    return 'Restaurar $username?';
  }

  @override
  String get backupRestoreMessage =>
      'Isso substitui seu perfil, decks, configurações, partidas recentes, sparks e comportamento neste dispositivo pelo backup selecionado.';

  @override
  String get backupRestoreConfirm => 'Restaurar';

  @override
  String backupRestored(String username) {
    return 'Backup restaurado para $username.';
  }

  @override
  String get backupRestoreFailed =>
      'Não foi possível restaurar o backup. Verifique o arquivo e tente novamente.';

  @override
  String get cacheCleared => 'Cache de imagens limpo.';

  @override
  String get cacheClearFailed => 'Não foi possível limpar o cache de imagens.';

  @override
  String get decksTitle => 'Decks';

  @override
  String get decksAddDeck => 'Adicionar deck';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get profileRecentGames => 'Partidas recentes';

  @override
  String get profileDeckPerformance => 'Desempenho dos decks';

  @override
  String get lobbyTitle => 'Lobby';

  @override
  String get lobbyHostGame => 'Hospedar partida';

  @override
  String get lobbyHostGameSubtitle =>
      'Crie uma sessão — os outros entram com você';

  @override
  String get lobbyJoinGame => 'Entrar na partida';

  @override
  String get lobbyJoinGameSubtitle => 'Procure um host por perto';

  @override
  String get hostLobbyTitle => 'Lobby do host';

  @override
  String get hostLeaveLobbyTooltip => 'Sair do lobby';

  @override
  String hostPlayersScanQr(int count, int max) {
    return 'Jogadores: $count / $max  •  Escaneie o QR para entrar';
  }

  @override
  String get hostNeedWifiRetry =>
      'Conecte este dispositivo ao Wi‑Fi (mesma rede dos convidados) e toque em Tentar de novo.';

  @override
  String get hostNeedsMobileApp =>
      'Para hospedar é preciso o app móvel (iOS ou Android) no mesmo Wi‑Fi. O navegador pode entrar escaneando um QR, mas não pode hospedar.';

  @override
  String get hostNeedsMobileOrDev =>
      'Para hospedar é preciso o app móvel ou um build local de desenvolvimento.';

  @override
  String get hostCreateProfileFirst =>
      'Crie seu perfil primeiro (Início → defina o nome de usuário) e toque em Tentar de novo.';

  @override
  String get hostCouldNotStartServer =>
      'Não foi possível iniciar o servidor neste dispositivo. Toque em Tentar de novo.';

  @override
  String get hostSessionDidNotStart =>
      'A sessão de host não iniciou. Toque em Tentar de novo.';

  @override
  String get hostCouldNotShowQr => 'Não foi possível mostrar o QR de entrada.';

  @override
  String get hostRetry => 'Tentar de novo';

  @override
  String get hostNeedOnePlayer => 'É preciso pelo menos 1 jogador';

  @override
  String get hostEveryoneMustBeReady => 'Todos precisam estar prontos';

  @override
  String get hostStartGame => 'Iniciar partida';

  @override
  String hostOpenSlots(int count) {
    return '$count vaga(s) aberta(s) — compartilhe o dispositivo para amigos entrarem';
  }

  @override
  String get hostMatchLabel => 'Rótulo';

  @override
  String get hostMatchLabelHelp =>
      'Opcional. Ajuda a achar esta partida em Partidas recentes.';

  @override
  String get hostMatchLabelHint => 'ex.: EDH de sexta';

  @override
  String get hostGameSettings => 'Configurações da partida';

  @override
  String get hostFormat => 'Formato';

  @override
  String get hostStartingLife => 'Vida inicial';

  @override
  String get hostCustomStartingLifeTitle => 'Vida inicial personalizada';

  @override
  String get hostCustomStartingLifeHint => 'Digite a vida (1–999)';

  @override
  String get hostCustomEllipsis => 'Personalizado…';

  @override
  String get hostGameplay => 'Jogabilidade';

  @override
  String get hostToggleTeams => 'Times';

  @override
  String get hostToggleTeamsSubtitle => 'Defina cores de time na mesa';

  @override
  String get hostTogglePlanechaseSubtitle =>
      'Internet necessária para o deck planar';

  @override
  String get hostToggleArchenemySubtitle =>
      'Internet necessária para o deck de schemes';

  @override
  String get hostToggleBountySubtitle =>
      'Internet necessária para o deck de Bounty';

  @override
  String get hostToggleAutoKo => 'Auto-KO';

  @override
  String get hostToggleAutoKoSubtitle =>
      'Por vida, poison ou dano de commander';

  @override
  String get hostToggleCommanderDmgLife => 'Dano de commander reduz vida';

  @override
  String get hostToggleCommanderDmgLifeSubtitle =>
      'O dano de commander também reduz a vida';

  @override
  String get hostTogglePhaseTracker => 'Rastreador de fases';

  @override
  String get hostTogglePhaseTrackerSubtitle =>
      'Mostra as fases com Voltar e Próximo';

  @override
  String get hostToggleTurnTimer => 'Timer de turno';

  @override
  String get hostToggleTurnTimerSubtitle =>
      'Mostra o tempo decorrido a cada turno';

  @override
  String get hostTurnLimit => 'Limite de turno';

  @override
  String get hostTurnLimitOff => 'Desligado';

  @override
  String hostTurnLimitSeconds(int seconds) {
    return '$seconds segundos';
  }

  @override
  String get hostNoCommanderSelected => 'Nenhum commander selecionado';

  @override
  String get hostNoDeckSelected => 'Nenhum deck selecionado';

  @override
  String hostTrackingDeck(String name) {
    return 'Rastreando: $name';
  }

  @override
  String get hostDeckListChanged => 'Deck (lista salva alterada)';

  @override
  String get hostSelectDeck => 'Deck';

  @override
  String get hostSelectCommander => 'Commander';

  @override
  String get hostMarkReady => 'Marcar pronto';

  @override
  String get hostMarkNotReady => 'Marcar não pronto';

  @override
  String get lobbyReady => 'Pronto';

  @override
  String get lobbyWaiting => 'Aguardando';

  @override
  String get deckPickerTitle => 'Deck desta partida';

  @override
  String get deckPickerManualOnly => 'Só commander manual';

  @override
  String get deckPickerManualOnlySubtitle =>
      'Mantenha os commanders como estão; não associe a um deck salvo';

  @override
  String deckPickerEmptyForFormat(String format) {
    return 'Ainda não há decks $format salvos. Crie um na aba Decks.';
  }

  @override
  String get deckPickerOpenDecks => 'Abrir Decks';

  @override
  String get joinTitle => 'Entrar em uma partida';

  @override
  String get joinLeaveTooltip => 'Sair';

  @override
  String get joinPointCamera => 'Aponte a câmera para o QR do host';

  @override
  String get joinCameraRequiredSnack =>
      'É preciso permissão da câmera para escanear o QR do host.';

  @override
  String get joinCameraDeniedBody =>
      'É preciso acesso à câmera para escanear o QR do host.\\nSe você já permitiu em Ajustes, toque em Tentar de novo.';

  @override
  String get joinOpenSettings => 'Abrir Ajustes';

  @override
  String get joinInvalidQr => 'Não é um QR válido do Life Spark.';

  @override
  String get joinMissingToken =>
      'Este QR está sem o token de entrada. Peça ao host para atualizar o QR.';

  @override
  String get joinCouldNotStartSession =>
      'Não foi possível iniciar a sessão. Conclua o perfil e tente de novo.';

  @override
  String get joinConnectTimeout =>
      'Tempo esgotado ao conectar. Confirme que está no mesmo Wi‑Fi e que o lobby do host ainda está aberto, e tente de novo.';

  @override
  String get joinHostRejected =>
      'O host rejeitou a conexão (versão incompatível).';

  @override
  String get joinDisconnected => 'Desconectado do host.';

  @override
  String get joinConnectionError => 'Erro de conexão.';

  @override
  String get joinHostEndedSession => 'O host encerrou a sessão.';

  @override
  String get joinConnecting => 'Conectando ao host…';

  @override
  String get joinWaitingForHost => 'Aguardando o host iniciar…';

  @override
  String get joinSelectDeck => 'Selecionar deck';

  @override
  String get joinSelectCommander => 'Selecionar commander';

  @override
  String get joinReady => 'Pronto';

  @override
  String get joinMarkReady => 'Marcar pronto';

  @override
  String get welcomeTagline => 'Seu companheiro de MTG.';

  @override
  String get welcomeReadyToPlay => 'Pronto para jogar';

  @override
  String get welcomeSkip => 'Pular';

  @override
  String get onboardingSlide1Title => 'Bem-vindo ao Life Spark';

  @override
  String get onboardingSlide1Body =>
      'Seu companheiro de mesa Commander — vida, contadores, política e a pilha, sincronizados na mesa.';

  @override
  String get onboardingSlide2Title => 'Hospedar ou entrar';

  @override
  String get onboardingSlide2Body =>
      'Um jogador hospeda — os outros escaneiam um QR na mesma rede Wi‑Fi. Sem conta na internet. Funciona com 4 a 6 jogadores na mesma mesa.';

  @override
  String get onboardingSlide3Title => 'Acompanhe sua vida';

  @override
  String get onboardingSlide3Body =>
      'Toque em +/- para mudar a vida em 1. Segure +/- para ±5. Arraste para a esquerda ou direita para ajustar rápido. Toque duas vezes na vida para um número exato. Desfazer fica na barra inferior (ou agite, se ativado).';

  @override
  String get onboardingSlide4Title => 'Fases e turnos';

  @override
  String get onboardingSlide4Body =>
      'Use a barra de fases para avançar o turno, ou deixe o rastreador desligado no lobby. A pausa interrompe a partida inteira.';

  @override
  String get onboardingSlide5Title => 'Commander e contadores';

  @override
  String get onboardingSlide5Body =>
      'O dano de commander abre como lista de ameaças — quanto cada oponente já causou rumo a 21. Acompanhe poison (10), energy, experience e rad. Use Proliferate para somar 1 a todos de uma vez.';

  @override
  String get onboardingSlide6Title => 'Alianças e política';

  @override
  String get onboardingSlide6Body =>
      'Proponha alianças secretas com outros jogadores. Elas expiram sozinhas ou quebram quando vocês se atacam. Acompanhe Monarch e Initiative com um toque.';

  @override
  String get onboardingNext => 'Próximo';

  @override
  String get onboardingReadyToPlay => 'Pronto para jogar';

  @override
  String get onboardingSkip => 'Pular';

  @override
  String get profileSetupTitle => 'Crie seu perfil';

  @override
  String get profileSetupSubtitle =>
      'Escolha um nome e uma foto que a mesa reconheça.';

  @override
  String get profileSetupUsername => 'Nome de usuário';

  @override
  String get profileSetupUsernameRequired => 'Digite um nome de usuário';

  @override
  String get profileSetupUsernameTooShort => 'Deve ter pelo menos 2 caracteres';

  @override
  String get profileSetupChoosePicture => 'Escolher foto de perfil';

  @override
  String get profileSetupChangePicture => 'Trocar foto';

  @override
  String get profileSetupContinue => 'Continuar';

  @override
  String get sessionLeaveTitle => 'Sair da partida ativa?';

  @override
  String get sessionLeaveMessage =>
      'Você tem um lobby ou partida em andamento. Sair desconectará os outros jogadores na mesa.';

  @override
  String get sessionLeaveConfirm => 'Sair';

  @override
  String get sessionLeaveStay => 'Ficar';

  @override
  String get gameLeaveTitle => 'Sair da partida?';

  @override
  String get gameLeaveMessageActive =>
      'Você sairá da partida e voltará ao início. As estatísticas só salvam quando a mesa termina a partida.';

  @override
  String get gameLeaveMessageAfterConcede =>
      'Você sairá da partida ao vivo e voltará ao início. Seu resultado de desistência será salvo antes de desconectar.';

  @override
  String get gameTabPlay => 'Jogar';

  @override
  String get gameTabStack => 'Pilha';

  @override
  String get gameTabLookupSemantics => 'Consultar regras da carta';

  @override
  String get gameBarHome => 'Início';

  @override
  String get gameBarUndo => 'Desfazer';

  @override
  String get gameBarTimeout => 'Pausa';

  @override
  String get gameBarEnd => 'Fim';

  @override
  String get gameBarTable => 'Mesa';

  @override
  String get gameEndTurn => 'Passar turno';

  @override
  String gameWaitingForPlayer(String name) {
    return 'Aguardando $name…';
  }

  @override
  String get gamePhaseBack => 'Voltar';

  @override
  String get gamePhaseNext => 'Próximo';

  @override
  String get gameChoosePhase => 'Escolher fase';

  @override
  String get gameYourTurn => 'Seu turno';

  @override
  String get gameYourTurnTapContinue => 'Toque para continuar';

  @override
  String get gameYourTurnSemantics =>
      'Seu turno. Toque duas vezes para fechar.';

  @override
  String get gameNowPlaying => 'JOGANDO AGORA';

  @override
  String get gameActiveTurn => 'TURNO ATIVO';

  @override
  String gamePlayersTurn(String name) {
    return 'Turno de $name';
  }

  @override
  String get gameCurrentTurn => 'Turno atual';

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
  String get timeoutPaused => 'Partida pausada — sem mudanças de vida';

  @override
  String get timeoutEnd => 'Encerrar pausa';

  @override
  String timeoutMinimized(String time) {
    return 'Pausa — $time';
  }

  @override
  String get timeoutMinimizeTooltip => 'Minimizar temporizador';

  @override
  String get reconnectToTable => 'Reconectando à mesa…';

  @override
  String get reconnectStillTrying => 'Ainda tentando alcançar a mesa…';

  @override
  String reconnectPeerOne(String name) {
    return '$name está reconectando…';
  }

  @override
  String reconnectPeerMany(int count) {
    return '$count jogadores reconectando…';
  }

  @override
  String get forfeitTitle => 'Desistir?';

  @override
  String get forfeitBodyMulti =>
      'Você sairá da partida. Opcionalmente avalie os oponentes antes de ir.';

  @override
  String get forfeitBodySolo =>
      'Sua partida de prática terminará. Opcionalmente anote como foi.';

  @override
  String get forfeitRateOpponents => 'Avaliar oponentes';

  @override
  String get forfeitConfirm => 'Desistir';

  @override
  String get forfeitYouForfeited => 'Você desistiu';

  @override
  String get forfeitStaySpectateBody =>
      'Os outros podem continuar jogando. Fique neste dispositivo para assistir até a mesa terminar. Voltar ao perfil agora salva sua desistência e desconecta da partida ao vivo.';

  @override
  String get forfeitStaySpectate => 'Ficar e assistir';

  @override
  String get forfeitReturnToProfile => 'Voltar ao perfil';

  @override
  String get gamePlayerLeftTitle => 'Jogador saiu';

  @override
  String gamePlayerLeftMessage(String username) {
    return '$username saiu da partida.';
  }

  @override
  String get gameSessionEndedTitle => 'Sessão encerrada';

  @override
  String get gameSessionEndedMessage => 'O host encerrou a partida.';

  @override
  String gamePeerOfflineTitle(String username) {
    return '$username ainda offline';
  }

  @override
  String get gamePeerOfflineBody =>
      'Continuar esperando a reconexão ou remover da mesa?';

  @override
  String get gameKeepWaiting => 'Continuar esperando';

  @override
  String get gameRemoveFromTable => 'Remover da mesa';

  @override
  String get gameSlotLoadFailedTitle => 'Não foi possível carregar sua vaga';

  @override
  String get gameSlotLoadFailedBody =>
      'A partida pode estar dessincronizada. Volte ao lobby e entre de novo.';

  @override
  String get gameReturnToLobby => 'Voltar ao lobby';

  @override
  String get profileSetupPrompt => 'Configure seu perfil para continuar.';

  @override
  String get profileCreateCta => 'Criar perfil';

  @override
  String get profileNewPlayer => 'Novo jogador';

  @override
  String profilePlayingSince(String date) {
    return 'Jogando desde $date';
  }

  @override
  String get profileOptions => 'Opções do perfil';

  @override
  String get profileDoneEditing => 'Concluir edição';

  @override
  String get profileDone => 'Concluído';

  @override
  String get profileEditName => 'Editar nome';

  @override
  String get profileEditNameTooltip => 'Editar nome';

  @override
  String get profileChangePicture => 'Trocar foto de perfil';

  @override
  String get profileStatRecord => 'Recorde';

  @override
  String get profileStatSparks => 'Sparks';

  @override
  String get profileStatGames => 'Partidas';

  @override
  String get profileEmptyRecentGames =>
      'Jogue sua primeira partida para liberar estatísticas e histórico.';

  @override
  String get profileEmptyDeckPerf =>
      'Adicione um deck para acompanhar o desempenho do commander aqui.';

  @override
  String get profileFilterAllGames => 'Todas';

  @override
  String get profileFilterRecent14 => 'Recentes (14 dias)';

  @override
  String get profileFilterThisWeek => 'Esta semana';

  @override
  String get profileFilterThisMonth => 'Este mês';

  @override
  String get profileNoMatchesFilter => 'Nenhuma partida neste filtro.';

  @override
  String get profileOpenLobbySemantics =>
      'Abrir lobby para hospedar ou entrar em uma partida';

  @override
  String get profileShowMore => 'Mostrar mais';

  @override
  String get profileStandings => 'Classificação';

  @override
  String get profileNoPlayerDetails =>
      'Nenhum detalhe de jogador salvo para esta partida.';

  @override
  String get profileResultConcede => 'Desistência';

  @override
  String get profileResultLoss => 'Derrota';

  @override
  String get decksEmptyTitle => 'Monte sua biblioteca de decks';

  @override
  String get decksEmptyBody =>
      'Salve um deck com nome, formato e carta de capa. Ao hospedar ou entrar, escolha a lista no lobby.';

  @override
  String get decksSearchHint => 'Buscar decks…';

  @override
  String decksNoSearchMatches(String query) {
    return 'Nenhum deck corresponde a “$query”.';
  }

  @override
  String get decksStyleNotSet => 'Estilo não definido';

  @override
  String get decksNoCoverCard => 'Sem carta de capa';

  @override
  String get lookupTitle => 'Busca de cartas';

  @override
  String get lookupHint => 'Busque qualquer carta de MTG…';

  @override
  String get lookupHelp => 'Texto Oracle e rulings oficiais do Scryfall.';

  @override
  String get lookupEmptyPrompt =>
      'Digite o nome de uma carta para ver as regras.';

  @override
  String lookupNoResults(String query) {
    return 'Nenhuma carta encontrada para “$query”.';
  }

  @override
  String get lookupNetworkError =>
      'Não foi possível alcançar o Scryfall. Verifique a conexão.';

  @override
  String get lookupSearch => 'Buscar';

  @override
  String get lookupOracleText => 'Texto Oracle';

  @override
  String get lookupNoOracle => 'Não há texto Oracle para esta carta.';

  @override
  String get lookupRulings => 'Rulings';

  @override
  String get lookupNoRulings => 'Não há rulings oficiais para esta carta.';

  @override
  String get endGameSavingResults => 'Salvando resultados…';

  @override
  String get endGameSaveFailedTitle => 'Não foi possível salvar os resultados.';

  @override
  String get endGameSaveFailedBody =>
      'Suas estatísticas podem não ter atualizado. Tente de novo.';

  @override
  String get endGameRetry => 'Tentar de novo';

  @override
  String get endGameContinueWithoutSaving => 'Continuar sem salvar';

  @override
  String get endGameFinalStandings => 'Classificação final';

  @override
  String get endGameOverNoWinner => 'Fim de jogo — Sem vencedor';

  @override
  String get endGamePracticeEnded => 'Prática encerrada';

  @override
  String get endGameYouWin => 'Você venceu!';

  @override
  String get endGameWinner => 'Vencedor';

  @override
  String get endGameRankUp => 'SUBIU DE RANK!';

  @override
  String endGameRankTransition(int oldLevel, int newLevel) {
    return 'Rank $oldLevel → $newLevel';
  }

  @override
  String endGameXpGained(int xp) {
    return '+$xp XP';
  }

  @override
  String get endGameWinBonusIncluded => 'Bônus de vitória incluído';

  @override
  String get endGameParticipationXp => 'XP de participação';

  @override
  String endGameRankLevel(int level) {
    return 'Rank $level';
  }

  @override
  String get endGameFeedbackThanks => 'Obrigado! Seu feedback foi registrado.';

  @override
  String get endGameRateOpponents => 'Avalie seus oponentes';

  @override
  String get endGameSubmitFeedback => 'Enviar feedback';

  @override
  String get endGameYouSuffix => '(você)';

  @override
  String get endGameElimReasonLife => 'Vida esgotada';

  @override
  String get endGameElimReasonPoison => '10 de veneno';

  @override
  String get endGameElimReasonCommanderDmg => 'Dano de Commander';

  @override
  String get endGameElimReasonConcede => 'Desistiu';

  @override
  String get endGameElimReasonDisconnect => 'Saiu do jogo';

  @override
  String get endGameElimReasonDefault => 'Eliminado';

  @override
  String get endGameBackToHome => 'Voltar ao início';

  @override
  String get feedbackTitle => 'Feedback';

  @override
  String get feedbackHeadline => 'Ajude-nos a melhorar';

  @override
  String get feedbackBody =>
      'Achou um bug? Tem uma ideia? Lemos cada mensagem.';

  @override
  String get feedbackMessageLabel => 'Sua mensagem';

  @override
  String get feedbackMessageHint => 'Conte o que você acha...';

  @override
  String get feedbackSend => 'Enviar feedback';

  @override
  String get feedbackOrDivider => 'ou';

  @override
  String get feedbackRatePlayStore => 'Avaliar na Play Store';

  @override
  String get feedbackMailSubject => 'Feedback do Life Spark';

  @override
  String get feedbackOpeningMail => 'Abrindo seu app de e-mail…';

  @override
  String feedbackNoMailAppCopied(String email) {
    return 'Sem app de e-mail — mensagem copiada. Cole em um e-mail para $email';
  }

  @override
  String feedbackClipboardFallback(String email, String message) {
    return 'Para: $email\\nAssunto: Feedback do Life Spark\\n\\n$message';
  }

  @override
  String get stackSortOrderOnStack => 'Ordem na pilha';

  @override
  String get stackSortByPlayer => 'Por jogador';

  @override
  String get stackAddSpellOrAbility => 'Adicionar magia ou habilidade';

  @override
  String get stackHowItWorksTooltip => 'Como a pilha funciona';

  @override
  String get stackFilterResolvedCountered => 'Resolvido / anulado';

  @override
  String get stackApnapHint => 'Quem adicionou o quê (jogador ativo primeiro)';

  @override
  String get stackClearAll => 'Limpar tudo';

  @override
  String get stackClearConfirmTitle => 'Limpar a pilha?';

  @override
  String get stackClearConfirmBody =>
      'Remove todas as magias e habilidades da pilha. Não dá para desfazer.';

  @override
  String stackActivePlayerLabel(String username) {
    return '$username · Jogador ativo';
  }

  @override
  String stackTurnOrderLabel(String username, int position) {
    return '$username · Ordem de turno: $position';
  }

  @override
  String get stackPutOnStack => 'Colocar na pilha';

  @override
  String get stackInResponseToEllipsis => 'Em resposta a…';

  @override
  String get stackEmptyTitle => 'Nada na pilha';

  @override
  String get stackEmptyBullet1 =>
      'Coloque magias e habilidades aqui antes de resolverem.';

  @override
  String get stackEmptyBullet2 => 'A última adicionada resolve primeiro.';

  @override
  String get stackAddSpell => 'Adicionar magia';

  @override
  String get stackStatusResolved => 'Resolvido';

  @override
  String get stackStatusCountered => 'Anulado';

  @override
  String get stackStatusFizzled => 'Falhou';

  @override
  String get stackYouSuffix => '(você)';

  @override
  String get stackUndoFizzle => 'Desfazer falha';

  @override
  String get stackFizzle => 'Falhar';

  @override
  String get stackUndoFizzleSubtitle =>
      'Coloca esta magia de volta na pilha como ativa';

  @override
  String get stackFizzleSubtitle =>
      'Alvo ilegal ou a magia saiu da pilha (counter de regras)';

  @override
  String get stackMarkCountered => 'Marcar anulado';

  @override
  String get stackRename => 'Renomear';

  @override
  String get stackOnStack => 'Na pilha';

  @override
  String get stackResolvesNext => 'Resolve a seguir';

  @override
  String get stackResolvesAfterAbove => 'Resolve depois dos de cima';

  @override
  String get stackTargetNoLongerOnStack => 'O alvo não está mais na pilha';

  @override
  String get stackCardRulesTooltip => 'Regras da carta';

  @override
  String stackInResponseToNamed(String name) {
    return 'Em resposta a $name';
  }

  @override
  String get stackResolve => 'Resolver';

  @override
  String get stackRespond => 'Responder';

  @override
  String get stackFizzledButton => 'Falhou';

  @override
  String get stackHelpTitle => 'Como a pilha funciona';

  @override
  String get stackHelpBullet1 =>
      'Quando alguém joga uma magia ou usa uma habilidade, ela vai para a pilha — uma fila de espera antes de acontecer.';

  @override
  String get stackHelpBullet2 =>
      'A última coisa adicionada resolve primeiro (como uma pilha de pratos). Por isso a entrada do topo diz Resolve a seguir.';

  @override
  String get stackHelpBullet3 =>
      'Ao adicionar uma magia, busque no Scryfall e escolha a carta da lista para guardar o nome e o texto de regras corretos.';

  @override
  String get stackHelpBullet4 =>
      'Para responder, toque em Responder ou use Em resposta a… — sua magia fica no topo e resolve antes da de baixo.';

  @override
  String get stackHelpBullet5 =>
      'Quando um efeito termina, toque em Resolver — a carta fica na pilha e fica verde. Para responder, toque em Responder. Se um counter funcionou, Marcar anulado (use o filtro Anulado para ver). Se uma magia perdeu o alvo, toque em Falhar — fica acinzentada; toque em Falhou de novo para desfazer.';

  @override
  String get stackHelpBullet6 =>
      'Na mesa você ainda diz “passo” em voz alta para a prioridade; esta tela ajuda todos a lembrar o que está esperando e em que ordem.';

  @override
  String get stackHelpExample =>
      'Exemplo: Você joga uma magia de pump na sua criatura. Seu oponente joga Lightning Bolt em resposta. Bolt resolve primeiro, depois seu pump (se o alvo ainda for legal).';

  @override
  String get stackHelpReadMore => 'Leia mais em Magic.com';

  @override
  String get stackHelpCouldNotOpenLink => 'Não foi possível abrir o link';

  @override
  String get stackPickerIntro =>
      'Busque no Scryfall para guardar o nome e o texto de regras corretos.';

  @override
  String get stackPickerCardNameLabel => 'Nome da carta';

  @override
  String get stackPickerCardNameHint => 'ex.: Lightning Bolt';

  @override
  String get stackPickerClearSearch => 'Limpar busca';

  @override
  String get stackPickerAdd => 'Adicionar';

  @override
  String get stackPickerNoCards =>
      'Nenhuma carta encontrada. Tente outra grafia.';

  @override
  String get stackPickerNetworkError =>
      'Não foi possível alcançar o Scryfall. Verifique sua internet.';

  @override
  String get stackPickerNeedSelection =>
      'Escolha uma carta da lista, ou digite um nome que o Scryfall reconheça.';

  @override
  String get stackPickerTypeToSearch => 'Digite para buscar cartas';

  @override
  String get allianceAPlayer => 'Um jogador';

  @override
  String get allianceYourAllyFallback => 'seu aliado';

  @override
  String get allianceOfferDeclined => 'Oferta de aliança secreta recusada';

  @override
  String get allianceEnded => 'Aliança secreta encerrada';

  @override
  String get allianceProposeTitle => 'Aliança secreta';

  @override
  String allianceProposeSubtitle(String username) {
    return 'Convide $username — só ele/ela saberá.';
  }

  @override
  String get allianceDurationSection => 'Duração';

  @override
  String get allianceDurationEndOfTurn => 'Até o fim do turno';

  @override
  String get allianceDurationEndOfRound => 'Até o fim da rodada';

  @override
  String get allianceDurationUntilBroken => 'Até ser quebrada';

  @override
  String get allianceWhenToDeliver => 'Quando entregar';

  @override
  String get allianceDeliverNow => 'Entregar agora';

  @override
  String allianceDeliverInSeconds(int seconds) {
    return 'Entregar em ${seconds}s';
  }

  @override
  String get allianceDeliverEndOfYourTurn => 'Entregar no fim do seu turno';

  @override
  String get allianceDeliverNextRound => 'Entregar na próxima rodada';

  @override
  String allianceSecondsShort(int seconds) {
    return '${seconds}s';
  }

  @override
  String get allianceSend => 'Enviar';

  @override
  String allianceWhisperSent(String username) {
    return 'Sussurro enviado para $username';
  }

  @override
  String allianceWhisperScheduled(String username) {
    return 'Sussurro agendado para $username';
  }

  @override
  String get allianceInviteTitle => 'Oferta secreta';

  @override
  String allianceInviteBody(String username, String duration) {
    return '$username propõe uma aliança secreta.\\n\\nDuração: $duration\\n\\nSó você pode ver isto.';
  }

  @override
  String get allianceAccept => 'Aceitar';

  @override
  String get allianceDecline => 'Recusar';

  @override
  String get allianceFormedTitle => 'Aliança formada';

  @override
  String allianceFormedBody(String username, String duration) {
    return 'Você e $username agora estão secretamente aliados ($duration).\\n\\nA mesa não sabe — a menos que revelem ou traiam.';
  }

  @override
  String allianceFormedBodyNoDuration(String username) {
    return 'Você e $username agora estão secretamente aliados.\\n\\nA mesa não sabe — a menos que revelem ou traiam.';
  }

  @override
  String get allianceUnderstood => 'Entendi';

  @override
  String get allianceRevealedTitle => 'Aliança revelada';

  @override
  String allianceRevealedBody(String playerA, String playerB) {
    return '$playerA e $playerB revelaram a aliança secreta à mesa.';
  }

  @override
  String get allianceOk => 'OK';

  @override
  String get allianceBetrayalTitle => 'Traição!';

  @override
  String allianceBetrayalBody(String playerA, String playerB) {
    return 'A aliança secreta entre $playerA e $playerB foi quebrada por traição.';
  }

  @override
  String get allianceBadgeAllied => 'Aliado';

  @override
  String get allianceBadgeSecretAlly => 'Aliado secreto';

  @override
  String allianceWhisperPending(String username) {
    return 'Sussurro pendente → $username';
  }

  @override
  String allianceAwaiting(String username) {
    return 'Aguardando $username';
  }

  @override
  String get cmdDmgSheetTitle => 'Dano de Commander';

  @override
  String get cmdDmgSheetSubtitle =>
      'Ameaças a você primeiro. Abra Causado para registrar o dano que você causou.';

  @override
  String cmdDmgBarA11y(String remaining, String ko, String taken) {
    return 'Dano de Commander: $remaining de $ko restantes, $taken no pior track, toque para gerenciar';
  }

  @override
  String get cmdDmgLeft => 'restantes';

  @override
  String get cmdDmgHideDealt => 'Ocultar causado';

  @override
  String cmdDmgDealtTotal(String total) {
    return 'Causado $total';
  }

  @override
  String get cmdDmgDefaultCommander => 'Commander';

  @override
  String get cmdDmgDefaultPartner => 'Partner';

  @override
  String get cmdDmgDefaultPartnerCommander => 'Commander Partner';

  @override
  String cmdDmgYouDealtTitle(String name) {
    return 'Você → $name';
  }

  @override
  String get cmdDmgYouDealtSubtitle => 'Dano que você causou';

  @override
  String get cmdDmgLethalTooltip => 'Dano letal de Commander!';

  @override
  String get cmdDmgIncreaseA11y => 'Aumentar dano de Commander';

  @override
  String get cmdDmgDecreaseA11y => 'Diminuir dano de Commander';

  @override
  String get cmdBarCastCommander => 'Jogar Commander';

  @override
  String get cmdBarEliminated => 'Eliminado';

  @override
  String get cmdBarNoTaxYet => 'Sem taxa ainda';

  @override
  String get cmdBarRemoveLastCast => 'Remover último cast de Commander';

  @override
  String get cmdBarCommanderTax => 'Taxa de Commander';

  @override
  String get cmdBarTapToRemoveLastCast => 'Toque para remover o último cast';

  @override
  String cmdBarTaxPlus(int tax) {
    return 'Taxa +$tax';
  }

  @override
  String get counterResetConfirmTitle => 'Zerar?';

  @override
  String get counterResetConfirmBody => 'Definir este contador como zero.';

  @override
  String get counterResetConfirmAction => 'Zerar';

  @override
  String get counterResetToZero => 'Zerar';

  @override
  String get counterDone => 'Concluído';

  @override
  String get firstPlayerRollTitle => 'Rolar pelo primeiro jogador';

  @override
  String get firstPlayerRollSubtitle =>
      'O maior resultado começa. Toque no dado para rolar!';

  @override
  String get firstPlayerRollDieA11y => 'Rolar dado';

  @override
  String get firstPlayerRollingA11y => 'Rolando';

  @override
  String firstPlayerRolledA11y(String value) {
    return 'Rolou $value';
  }

  @override
  String get firstPlayerNotRolledA11y => 'Não rolou';

  @override
  String firstPlayerYouRolled(String value) {
    return 'Você rolou $value!';
  }

  @override
  String firstPlayerYouRolledA11y(String value) {
    return 'Você rolou $value';
  }

  @override
  String get firstPlayerRolling => 'Rolando…';

  @override
  String get firstPlayerTapToRoll => 'Toque para rolar';

  @override
  String firstPlayerHostProgressA11y(String rolled, String total) {
    return '$rolled de $total jogadores rolaram';
  }

  @override
  String get firstPlayerWaitingOthersA11y =>
      'Aguardando outros jogadores rolarem';

  @override
  String get firstPlayerRollToContinueA11y => 'Role o dado para continuar';

  @override
  String firstPlayerHostProgress(String rolled, String total) {
    return '$rolled / $total jogadores rolaram';
  }

  @override
  String get firstPlayerWaitingOthers => 'Aguardando outros rolarem…';

  @override
  String get firstPlayerTapDieAbove => 'Toque no dado acima para rolar';

  @override
  String firstPlayerYouSuffix(String username) {
    return '$username (você)';
  }

  @override
  String get firstPlayerTurnOrderTitle => 'Ordem de turnos';

  @override
  String get firstPlayerTurnOrderSubtitle =>
      'O maior resultado lidera — o jogo segue nesta ordem.';

  @override
  String get firstPlayerStartGame => 'Começar jogo';

  @override
  String get firstPlayerOrdinal1 => '1º';

  @override
  String get firstPlayerOrdinal2 => '2º';

  @override
  String get firstPlayerOrdinal3 => '3º';

  @override
  String get firstPlayerOrdinal4 => '4º';

  @override
  String get firstPlayerOrdinal5 => '5º';

  @override
  String get firstPlayerOrdinal6 => '6º';

  @override
  String firstPlayerSlotA11y(String place, String name, String rollDetail) {
    return '$place, $name, $rollDetail';
  }

  @override
  String firstPlayerSlotYou(String username) {
    return '$username, você';
  }

  @override
  String get firstPlayerRollUnavailable => 'rolagem indisponível';

  @override
  String firstPlayerRolledDetail(String value) {
    return 'rolou $value';
  }

  @override
  String get firstPlayerGoesFirst => 'começa';

  @override
  String get historyTitle => 'Histórico';

  @override
  String get historySubtitle => 'Vida, contadores e outras ações da mesa.';

  @override
  String get historyEmptyTitle => 'Nenhuma ação ainda';

  @override
  String get historyEmptyBody =>
      'Mudanças de vida, contadores e outras ações aparecerão aqui conforme o jogo avança.';

  @override
  String historyTurn(String turn) {
    return 'Turno $turn';
  }

  @override
  String get overviewElimReasonLife => 'Perda de vida';

  @override
  String get overviewElimReasonPoison => 'Veneno';

  @override
  String get overviewElimReasonCommanderDmg => 'Dano de Commander';

  @override
  String get overviewElimReasonConcede => 'Desistiu';

  @override
  String get overviewElimReasonDisconnect => 'Desconectado';

  @override
  String overviewRound(int round) {
    return 'Rodada $round';
  }

  @override
  String get overviewClose => 'Fechar visão geral';

  @override
  String get overviewTools => 'Ferramentas';

  @override
  String get overviewHistory => 'Histórico';

  @override
  String get overviewPlayers => 'Jogadores';

  @override
  String get overviewHoldDragReorder =>
      'Segure e arraste para reordenar turnos';

  @override
  String get overviewDecreaseLife => 'Diminuir vida';

  @override
  String get overviewIncreaseLife => 'Aumentar vida';

  @override
  String overviewCommanderTaxPlus(int tax) {
    return 'Taxa de Commander mais $tax';
  }

  @override
  String overviewTaxPlus(int tax) {
    return 'Taxa +$tax';
  }

  @override
  String get overviewMonarchA11y => 'Monarch';

  @override
  String get overviewInitiativeA11y => 'Initiative';

  @override
  String get overviewNowPlaying => 'JOGANDO AGORA';

  @override
  String get overviewSendWhisper => 'Enviar sussurro';

  @override
  String get overviewAssignTeamColor => 'Atribuir cor de time';

  @override
  String get overviewProposeSecretAlliance => 'Propor aliança secreta';

  @override
  String get overviewRevealAlliance => 'Revelar aliança à mesa';

  @override
  String get overviewBreakAlliance => 'Quebrar aliança secreta';

  @override
  String get overviewAssignTeamTitle => 'Atribuir time';

  @override
  String get overviewTeamNone => 'Nenhum';

  @override
  String overviewTeamN(String index) {
    return 'Time $index';
  }

  @override
  String dialsStripLimitSnack(int max) {
    return 'Sua faixa comporta até $max contadores. Remova um para adicionar outro.';
  }

  @override
  String get dialsLabelPoison => 'Veneno';

  @override
  String get dialsLabelEnergy => 'Energia';

  @override
  String get dialsLabelExp => 'Exp';

  @override
  String get dialsLabelRad => 'Rad';

  @override
  String get dialsLabelBlood => 'Sangue';

  @override
  String get dialsLabelClue => 'Pista';

  @override
  String get dialsLabelMap => 'Mapa';

  @override
  String get dialsLabelTreasure => 'Tesouro';

  @override
  String get dialsLabelDevotion => 'Devoção';

  @override
  String get dialsLabelCreatures => 'Criaturas';

  @override
  String get dialsLabelEnchant => 'Encant.';

  @override
  String get dialsLabelArtifacts => 'Artefatos';

  @override
  String get dialsLabelGy => 'Cemitério';

  @override
  String get dialsLabelExile => 'Exílio';

  @override
  String get dialsAddCounterTitle => 'Adicionar contador';

  @override
  String dialsAddCounterBody(int max) {
    return 'Escolha trackers para sua faixa (máx. $max). Toque no X de um contador para removê-lo.';
  }

  @override
  String get dialsSectionCommon => 'Comuns';

  @override
  String get dialsSectionTokensZones => 'Tokens e zonas';

  @override
  String get dialsAllBuiltInsOnStrip =>
      'Todos os contadores embutidos já estão na sua faixa. Remova um para liberar um espaço.';

  @override
  String get dialsAddCounterTooltip => 'Adicionar contador';

  @override
  String get dialsRemoveFromStrip => 'Remover da faixa';

  @override
  String get hubGuideTitle => 'Tour rápido';

  @override
  String get hubGuideSkip => 'Pular';

  @override
  String get hubGuideNext => 'Próximo';

  @override
  String get hubGuideGotIt => 'Entendi';

  @override
  String get hubGuideSlidePlayTitle => 'Jogar';

  @override
  String get hubGuideSlidePlayBody =>
      'Acompanhe vida e contadores aqui. Fim do turno fica sob a barra de fases — ou desative o rastreador de fases no lobby para um controle grande de Fim do turno.';

  @override
  String get hubGuideSlideStackTitle => 'Pilha e busca';

  @override
  String get hubGuideSlideStackBody =>
      'A pilha é para Hold Priority e resolver efeitos. A busca abre o Scryfall sem sair do seu lugar — texto do oráculo e rulings.';

  @override
  String get hubGuideSlideTableTitle => 'Visão da mesa';

  @override
  String get hubGuideSlideTableBody =>
      'Abra Mesa para todo o pod. Ferramentas tem dados e moedas que todos veem; Histórico fica no cabeçalho. Fim do turno fica fixo; Desistir fica abaixo.';

  @override
  String get hubGuideSlideCommanderTitle => 'Seu turno e Commander';

  @override
  String get hubGuideSlideCommanderBody =>
      'Quando o assento for seu, toque no aviso Seu turno para dispensá-lo. O coração rastreia dano de Commander até 21.';

  @override
  String lifeA11yEliminatedAt(String life) {
    return 'Eliminado com $life de vida';
  }

  @override
  String lifeA11yLifeTotal(String life) {
    return '$life de vida total';
  }

  @override
  String get lifeA11yDecrease => 'Diminuir vida';

  @override
  String get lifeA11yIncrease => 'Aumentar vida';

  @override
  String get lifeSetTotalTitle => 'Definir vida total';

  @override
  String get glanceOpenTableA11y => 'Abrir visão da mesa, ordem de turnos';

  @override
  String get glanceYou => 'Você';

  @override
  String get phasePickerTitle => 'Selecionar fase';

  @override
  String get phasePickerSubtitle =>
      'Role e toque em uma fase, ou use Definir fase para o passo destacado.';

  @override
  String phasePickerSetPhase(String phase) {
    return 'Definir $phase';
  }

  @override
  String get whisperPresetTeamUp => 'Time juntos?';

  @override
  String get whisperPresetDontAttack => 'Não me ataque';

  @override
  String get whisperPresetHaveRemoval => 'Tenho remoção';

  @override
  String get whisperPresetAllGood => 'Tudo bem';

  @override
  String whisperSentSnack(String username) {
    return 'Sussurro enviado para $username';
  }

  @override
  String get whisperSendFailed =>
      'Não foi possível enviar — aguarde um momento ou verifique a conexão.';

  @override
  String whisperSheetTitle(String username) {
    return 'Sussurro para $username';
  }

  @override
  String get whisperSheetSubtitle =>
      'Só eles veem — some depois. Não é salvo no histórico.';

  @override
  String get whisperCustomLabel => 'Mensagem personalizada';

  @override
  String get whisperCustomHint => 'Nota curta…';

  @override
  String get whisperSend => 'Enviar sussurro';

  @override
  String whisperOverlayA11y(String username, String text) {
    return 'Sussurro de $username: $text';
  }

  @override
  String whisperOverlayHeader(String username) {
    return 'Sussurro de $username';
  }

  @override
  String get politicsTapToAssignA11y =>
      'Política da mesa. Toque para atribuir.';

  @override
  String get politicsStatusEmpty => 'Sem Monarch · Sem Initiative · —';

  @override
  String get politicsDay => 'Dia';

  @override
  String get politicsNight => 'Noite';

  @override
  String get politicsAssignSheetTitle => 'Atribuir política da mesa';

  @override
  String get politicsMonarch => 'Monarch';

  @override
  String get politicsInitiative => 'Initiative';

  @override
  String get politicsAssignMonarch => 'Atribuir Monarch';

  @override
  String get politicsAssignInitiative => 'Atribuir Initiative';

  @override
  String get politicsNone => 'Nenhum';

  @override
  String get politicsDayNight => 'Dia/Noite';

  @override
  String get tableToolsTitle => 'Ferramentas';

  @override
  String get tableToolsSubtitle => 'Todos na mesa veem o resultado.';

  @override
  String get tableToolsD6 => 'd6';

  @override
  String get tableToolsD20 => 'd20';

  @override
  String get tableToolsCoin => 'Moeda';

  @override
  String get tableToolsResultHint => 'O resultado aparece para toda a mesa';

  @override
  String get tableToolsRollD6 => 'Rolar d6';

  @override
  String get tableToolsRollD20 => 'Rolar d20';

  @override
  String get tableToolsFlipCoin => 'Jogar moeda';

  @override
  String get tableToolHeads => 'Cara';

  @override
  String get tableToolTails => 'Coroa';

  @override
  String tableToolRolledHeadline(String username, String result) {
    return '$username rolou um $result';
  }

  @override
  String tableToolFlippedHeadline(String username, String result) {
    return '$username tirou $result';
  }

  @override
  String get tableToolTapToDismiss => 'Toque para fechar';

  @override
  String tableToolDismissA11y(String headline) {
    return '$headline. Toque para fechar.';
  }

  @override
  String get tableToolPlayerFallback => 'Jogador';

  @override
  String get variantDeckSingular => 'Deck de variante';

  @override
  String get variantDeckPlural => 'Decks de variante';

  @override
  String variantDeckA11y(String label) {
    return '$label, toque para ver';
  }

  @override
  String get variantDecksSheetTitle => 'Decks de variante';

  @override
  String get variantLoading => 'Carregando decks de variante…';

  @override
  String get variantLoadFailed =>
      'Não foi possível carregar os decks (internet necessária)';

  @override
  String get variantPlanechase => 'Planechase';

  @override
  String get variantArchenemy => 'Archenemy';

  @override
  String get variantBounty => 'Bounty';

  @override
  String get variantNextCard => 'Próxima carta';

  @override
  String commanderSelectNoCommanders(String query) {
    return 'Nenhum commander encontrado para \"$query\"';
  }

  @override
  String commanderSelectNoCards(String query) {
    return 'Nenhuma carta encontrada para \"$query\"';
  }

  @override
  String get commanderSelectSearchFailed =>
      'Não foi possível buscar. Verifique a internet e tente de novo.';

  @override
  String get commanderSelectEditCommanders => 'Editar commanders';

  @override
  String get commanderSelectEditCover => 'Editar carta de capa';

  @override
  String get commanderSelectStep2Commander => 'Passo 2 de 2 — commander';

  @override
  String get commanderSelectStep2Cover => 'Passo 2 de 2 — carta de capa';

  @override
  String get commanderSelectPartnerTitle => 'Selecionar Partner';

  @override
  String get commanderSelectCommanderTitle => 'Selecionar Commander';

  @override
  String get commanderSelectCoverHint =>
      'Escolha qualquer carta para a arte do deck — não é sua lista completa.';

  @override
  String get commanderSelectSearchPartnerHint => 'Buscar commander Partner…';

  @override
  String get commanderSelectSearchCommanderHint => 'Buscar um commander…';

  @override
  String get commanderSelectSearchCardHint => 'Buscar uma carta…';

  @override
  String get commanderSelectConfirm => 'Confirmar';

  @override
  String get commanderSelectScryfallCommanderHelp =>
      'Digite um nome de commander para buscar no Scryfall.';

  @override
  String get commanderSelectScryfallCardHelp =>
      'Digite um nome de carta para buscar no Scryfall.';

  @override
  String get commanderSelectLabelCommander => 'Commander';

  @override
  String get commanderSelectLabelPartner => 'Partner';

  @override
  String get commanderSelectOptional => 'opcional';

  @override
  String get deckOptionsDeleteTitle => 'Excluir deck?';

  @override
  String deckOptionsDeleteBody(String name) {
    return 'Remover “$name” da sua biblioteca? O histórico de partidas permanece, mas este deck não aparecerá mais no seletor do lobby.';
  }

  @override
  String get deckOptionsDeleteConfirm => 'Excluir';

  @override
  String get deckOptionsStyleNotSet => 'Estilo não definido';

  @override
  String get deckOptionsEditCommanders => 'Editar commanders';

  @override
  String get deckOptionsEditCover => 'Editar carta de capa';

  @override
  String get deckOptionsNoGamesYet => 'Nenhuma partida ainda';

  @override
  String deckOptionsWinRate(String rate) {
    return '$rate% de vitórias';
  }

  @override
  String get deckOptionsUnpin => 'Desafixar do topo';

  @override
  String get deckOptionsPin => 'Fixar no topo';

  @override
  String get deckOptionsChangeFormat => 'Mudar formato';

  @override
  String get deckOptionsChangeStyle => 'Mudar estilo';

  @override
  String get deckOptionsStyleRequired => 'Obrigatório — não definido';

  @override
  String get deckOptionsRename => 'Renomear';

  @override
  String get deckOptionsDuplicate => 'Duplicar';

  @override
  String get deckOptionsDelete => 'Excluir deck';

  @override
  String get deckOptionsRenameTitle => 'Renomear deck';

  @override
  String get deckOptionsNameLabel => 'Nome do deck';

  @override
  String get deckOptionsNameHint => 'ex.: Raffine Tempo';

  @override
  String get newDeckChooseStyleError =>
      'Escolha um estilo de deck para continuar';

  @override
  String get newDeckTitle => 'Novo deck';

  @override
  String get newDeckSubtitle => 'Passo 1 de 2 — detalhes';

  @override
  String get newDeckIntro =>
      'Nomeie seu deck, escolha formato e estilo. Em seguida você escolhe o commander ou a carta de capa.';

  @override
  String get newDeckNameLabel => 'Nome do deck';

  @override
  String get newDeckNameHint => 'ex.: Raffine Tempo';

  @override
  String get newDeckNext => 'Próximo';

  @override
  String get formatPickerTitle => 'Formato';

  @override
  String get formatPickerSearchHint => 'Buscar formatos…';

  @override
  String get formatPickerFieldLabel => 'Formato';

  @override
  String formatPickerMultiplayerLife(String life) {
    return 'Multijogador · $life de vida inicial';
  }

  @override
  String formatPickerConstructedLife(String life) {
    return 'Constructed · $life de vida inicial';
  }

  @override
  String get stylePickerTitle => 'Estilo de deck';

  @override
  String get stylePickerSearchHint => 'Buscar estilos…';

  @override
  String get stylePickerChoose => 'Escolher estilo de deck';

  @override
  String get stylePickerFieldLabel => 'Estilo de deck';

  @override
  String get profileOptionsTitle => 'Perfil';

  @override
  String get profileOptionsEdit => 'Editar perfil';

  @override
  String get profileOptionsEditSubtitle => 'Altere seu nome ou avatar';

  @override
  String get profileOptionsBackup => 'Fazer backup do perfil';

  @override
  String get profileOptionsBackupSubtitle =>
      'Salve perfil, decks, jogos e feedback neste celular';

  @override
  String get profilePicTitle => 'Foto de perfil';

  @override
  String profilePicNoCards(String query) {
    return 'Nenhuma carta encontrada para \"$query\"';
  }

  @override
  String get profilePicSearchFailed =>
      'Não foi possível buscar. Verifique a internet e tente de novo.';

  @override
  String get profilePicPhotoFailed =>
      'Não foi possível usar essa foto. Tente outra imagem.';

  @override
  String get profilePicCommander => 'Commander';

  @override
  String get profilePicDefault => 'Padrão';

  @override
  String get profilePicRemove => 'Remover';

  @override
  String get profilePicUpload => 'Enviar foto';

  @override
  String get profilePicTake => 'Tirar foto';

  @override
  String get profilePicOrSearch => 'Ou busque arte de carta de MTG';

  @override
  String get profilePicSearchHint =>
      'Buscar cartas de MTG para foto de perfil…';

  @override
  String get profilePicHelp =>
      'Envie uma foto, tire uma ou busque uma carta—a arte vira sua foto de perfil.';

  @override
  String get ranksInfoTitle => 'Ranks e níveis';

  @override
  String get ranksInfoBody =>
      'O nível é seu progresso exato. O rank é o título da sua faixa de nível. Os tiers metálicos agrupam esses ranks.';

  @override
  String ranksInfoLevelRange(int min, int max) {
    return 'Nv $min–$max';
  }

  @override
  String get statsPlayerBehaviour => 'Comportamento';

  @override
  String get statsMostPlayed => 'Mais jogado';

  @override
  String get statsNoDeckStatsYet => 'Ainda sem estatísticas de decks.';

  @override
  String get statsToughRecord => 'Recorde difícil';

  @override
  String get statsNoLossesOnDeck => 'Ainda sem derrotas em um deck salvo.';

  @override
  String get statsPlayerStats => 'Estatísticas do jogador';

  @override
  String get statsSingularUnit => 'stat';

  @override
  String get statsPluralUnit => 'stats';

  @override
  String get statsLeaningGood => 'para bom';

  @override
  String get statsLeaningSalty => 'para salty';

  @override
  String get statsLeaningNeutral => 'neutro';

  @override
  String statsBehaviourA11y(String leaning) {
    return 'Espectro de comportamento, $leaning';
  }

  @override
  String get statsRecord => 'Recorde';

  @override
  String get statsWinRate => 'Taxa de vitórias';

  @override
  String statsRecordFooter(int wins, int losses, int games) {
    return '${wins}V–${losses}D  ·  $games jogos';
  }

  @override
  String get statsWinStreak => 'Sequência de vitórias';

  @override
  String get statsWinToStartStreak => 'Vença para começar uma sequência';

  @override
  String get statsPersonalBest => 'Recorde pessoal';

  @override
  String statsBestStreak(int best) {
    return 'Melhor: $best';
  }

  @override
  String get statsNoActiveStreak => 'Sem sequência ativa';

  @override
  String get statsCurrent => 'Atual';

  @override
  String statsLevelShort(int level) {
    return 'Nv $level';
  }

  @override
  String get statsLevelProgress => 'Progresso de nível';

  @override
  String get statsLevelProgressA11y =>
      'Progresso de nível. Ver todos os ranks.';

  @override
  String get statsGood => 'Bom';

  @override
  String get statsNeutral => 'Neutro';

  @override
  String get statsSalty => 'Salty';

  @override
  String get profileBackupSaveFailed => 'Não foi possível salvar o backup.';

  @override
  String get profileUsernameLabel => 'Nome de usuário';

  @override
  String get profileUsernameHint => 'ex.: The Archduke';

  @override
  String get profileUsernameRequired => 'Digite um nome de usuário';

  @override
  String get profileUsernameTooShort => 'Deve ter pelo menos 2 caracteres';

  @override
  String get profileSetupUsernameHint => 'ex.: The Archduke';

  @override
  String carouselFilterTooltip(String label) {
    return 'Filtro: $label';
  }

  @override
  String carouselRecentMatchA11y(String result, String format) {
    return 'Partida recente, $result, $format';
  }

  @override
  String get carouselCloseReturnsSummary => 'O botão Fechar volta ao resumo';

  @override
  String get carouselShowMoreDetails =>
      'Mostrar mais para detalhes completos, ou toque no card';

  @override
  String get decksClearSearchTooltip => 'Limpar';

  @override
  String get settingsDefaultFormatSheetTitle => 'Formato padrão';

  @override
  String get settingsDefaultStartingLifeSheetTitle => 'Vida inicial padrão';

  @override
  String settingsAboutVersionBeta(String version) {
    return 'Life Spark v$version · Beta';
  }

  @override
  String get settingsAboutByAuthor => 'por Federick Vidot';

  @override
  String get settingsAboutCardDataPoweredBy => 'Dados de cartas por';

  @override
  String get settingsAboutScryfall => 'Scryfall';

  @override
  String get settingsAboutDisclaimer =>
      'Life Spark é Fan Content não oficial permitido pela Fan Content Policy. Não aprovado/endossado pela Wizards. Parte do material é propriedade da Wizards of the Coast. ©Wizards of the Coast LLC.';

  @override
  String get feedbackLike => 'Curtir';

  @override
  String get feedbackClearLike => 'Remover curtida';

  @override
  String get feedbackDislike => 'Não curtir';

  @override
  String get feedbackClearDislike => 'Remover não curtida';

  @override
  String get feedbackSparkOfTheGame => 'Faísca do jogo';

  @override
  String get feedbackSparkHint => 'Opcional — escolha um jogador';

  @override
  String get feedbackNoneOption => '— Nenhum —';

  @override
  String tierBadgeLabel(String rank, int level) {
    return '$rank · Nv $level';
  }

  @override
  String tierBadgeA11y(String label) {
    return 'Rank $label. Ver todos os ranks.';
  }

  @override
  String get tierBronze => 'Bronze';

  @override
  String get tierSilver => 'Prata';

  @override
  String get tierGold => 'Ouro';

  @override
  String get tierPlatinum => 'Platina';

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
  String get rankArchmage => 'Arquimago';

  @override
  String get rankHighArchmage => 'Alto Arquimago';

  @override
  String get rankPlanewright => 'Planewright';

  @override
  String get rankGrandArchmage => 'Grande Arquimago';

  @override
  String get rankVoidcaller => 'Voidcaller';

  @override
  String get rankArchwizard => 'Archwizard';

  @override
  String get rankSpireLegend => 'Lenda da Spire';

  @override
  String get rankAscendantArchon => 'Arconte Ascendente';

  @override
  String get deckTileWinRateAbbr => 'WR';

  @override
  String get deckTileWinsAbbr => 'V';

  @override
  String get deckTileLossesAbbr => 'D';

  @override
  String get deckTileGamesAbbr => 'JG';

  @override
  String get brandLifeSpark => 'Life Spark';

  @override
  String get hostTogglePlanechase => 'Planechase';

  @override
  String get hostToggleArchenemy => 'Archenemy';

  @override
  String get hostToggleBounty => 'Bounty';

  @override
  String get lookupClearTooltip => 'Limpar';

  @override
  String phaseNavCurrentA11y(String phase) {
    return 'Fase atual, $phase';
  }

  @override
  String cmdDmgThreatHelp(int ko) {
    return 'Dano que cada comandante causou a você — $ko elimina.';
  }

  @override
  String get cmdDmgEmptyPod =>
      'Os oponentes aparecerão aqui quando outros entrarem na mesa.';

  @override
  String get statusOut => 'FORA';

  @override
  String infoBarAlly(String name) {
    return 'Aliado · $name';
  }

  @override
  String get infoBarAllySecret => 'secreto';

  @override
  String get gamePlayerDataUnavailable => 'Dados do jogador indisponíveis';

  @override
  String get startupErrorTitle => 'Erro na inicialização';

  @override
  String get startupStackTrace => 'Rastreamento de pilha:';

  @override
  String get paletteViolet => 'Violeta';

  @override
  String get paletteCrimson => 'Carmesim';

  @override
  String get paletteSlate => 'Ardósia';

  @override
  String get paletteForest => 'Floresta';

  @override
  String get paletteObsidian => 'Obsidiana';

  @override
  String get paletteFog => 'Névoa';

  @override
  String networkCannotReachHost(String error) {
    return 'Não foi possível alcançar o host: $error';
  }

  @override
  String get backupFileTypeLabel => 'Backup do Life Spark';

  @override
  String get backupNotValidFile => 'Não é um arquivo de backup do Life Spark.';

  @override
  String get backupNotValidJson => 'O arquivo de backup não é um JSON válido.';

  @override
  String get backupCouldNotRead =>
      'Não foi possível ler o arquivo de backup selecionado.';

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
    return '$name alterou sua vida $delta';
  }

  @override
  String logCounterChangedYours(String name, String counter, String delta) {
    return '$name alterou seu $counter $delta';
  }

  @override
  String logEndsTurn(String name) {
    return '$name encerra o turno';
  }

  @override
  String logCmdDmgDealtYou(String name, String delta) {
    return '$name causou a você $delta de dano de comandante';
  }

  @override
  String logCmdDmgYouDealt(String name, String delta) {
    return 'Você causou a $name $delta de dano de comandante';
  }

  @override
  String logCmdDmgOther(String from, String to, String delta) {
    return '$from → $to: Dano de comandante $delta';
  }

  @override
  String get logTurnOrderUpdated => 'Ordem de turnos atualizada pelo host';

  @override
  String get logProliferate => 'Proliferar: todos os jogadores';

  @override
  String logAllianceRevealed(String a, String b) {
    return 'Aliança revelada: $a e $b';
  }

  @override
  String logAllianceBetrayal(String a, String b) {
    return 'Aliança quebrada — traição: $a e $b';
  }

  @override
  String get logAllianceBroken => 'Aliança quebrada';

  @override
  String logAllianceFormed(String a, String b, String duration) {
    return 'Aliança secreta formada: $a e $b ($duration)';
  }

  @override
  String logPlayerLeft(String name) {
    return '$name saiu da partida';
  }

  @override
  String logRolled(String name, String result) {
    return '$name rolou um $result';
  }

  @override
  String logFlipped(String name, String result) {
    return '$name tirou $result';
  }

  @override
  String logStackAdded(String name, String item) {
    return '$name adicionou “$item”';
  }

  @override
  String logStackAddedResponse(String name, String item) {
    return '$name adicionou “$item” (resposta)';
  }

  @override
  String logStackRenamed(String name, String item) {
    return '$name renomeou item da pilha para “$item”';
  }

  @override
  String logStackStatus(String name, String item, String status) {
    return '“$item” de $name $status';
  }

  @override
  String get logClearedStack => 'Pilha limpa';

  @override
  String get logCounterPoison => 'Veneno';

  @override
  String get logCounterEnergy => 'Energia';

  @override
  String get logCounterExperience => 'Experiência';

  @override
  String get logCounterRad => 'Rad';

  @override
  String get logCounterBlood => 'Sangue';

  @override
  String get logCounterClue => 'Pista';

  @override
  String get logCounterMap => 'Mapa';

  @override
  String get logCounterTreasure => 'Tesouro';

  @override
  String get logCounterDevotion => 'Devoção';

  @override
  String get logCounterCreatures => 'Criaturas';

  @override
  String get logCounterEnchantments => 'Encantamentos';

  @override
  String get logCounterArtifacts => 'Artefatos';

  @override
  String get logCounterGyCreatures => 'Criaturas do cemitério';

  @override
  String get logCounterExile => 'Exílio';

  @override
  String get logStackStatusFizzled => 'falhou';

  @override
  String get logStackStatusCountered => 'anulado';

  @override
  String get logStackStatusResolved => 'resolvido';

  @override
  String get logStackStatusReactivated => 'reativado';

  @override
  String get logDurationEndOfTurn => 'Até o fim do turno';

  @override
  String get logDurationEndOfRound => 'Até o fim da rodada';

  @override
  String get logDurationUntilBroken => 'Até ser quebrada';

  @override
  String get logHeads => 'Cara';

  @override
  String get logTails => 'Coroa';
}
