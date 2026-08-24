// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Life Spark';

  @override
  String get navProfile => 'プロフィール';

  @override
  String get navLobby => 'ロビー';

  @override
  String get navDecks => 'デッキ';

  @override
  String get navSettings => '設定';

  @override
  String get settingsTitle => '設定';

  @override
  String get settingsSectionGameplay => 'ゲームプレイ';

  @override
  String get settingsDefaultFormat => 'デフォルトのフォーマット';

  @override
  String settingsDefaultFormatSubtitle(String format) {
    return '$format · ホスト時に使用';
  }

  @override
  String get settingsDefaultStartingLife => 'デフォルトの初期ライフ';

  @override
  String settingsDefaultStartingLifeSubtitle(int life) {
    return 'ライフ $life · ホスト時に使用';
  }

  @override
  String get settingsSectionMisc => 'その他';

  @override
  String get settingsKeepDisplayAwake => '画面を常時点灯';

  @override
  String get settingsKeepDisplayAwakeSubtitle => '対戦中に画面がスリープしないようにします';

  @override
  String get settingsHideSystemBars => 'ナビ／ステータスバーを隠す';

  @override
  String get settingsHideSystemBarsSubtitle => '対戦中はフルスクリーン表示';

  @override
  String get settingsSectionAppearance => '外観';

  @override
  String get settingsDarkAppearance => 'ダーク表示';

  @override
  String get settingsDarkAppearanceSubtitle =>
      'ライトモードは柔らかい背景を使用 — Fog や Slate をお試しください';

  @override
  String get settingsLanguage => '言語';

  @override
  String get settingsLanguageSystem => 'システムのデフォルト';

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
  String get settingsSectionFeel => '操作感';

  @override
  String get settingsHapticFeedback => '触覚フィードバック';

  @override
  String get settingsHapticFeedbackSubtitle => 'ライフ変更やランクアップ時に振動';

  @override
  String get settingsShakeToUndo => '振って取り消し';

  @override
  String get settingsShakeToUndoSubtitle => '端末を振って直前のライフ変更を取り消します';

  @override
  String get settingsSectionData => 'データ';

  @override
  String get settingsCacheCommanderImages => '統率者画像をキャッシュ';

  @override
  String get settingsCacheCommanderImagesSubtitle => 'オフライン用に Scryfall 画像を保存';

  @override
  String get settingsClearImageCache => '画像キャッシュを削除';

  @override
  String get settingsClearImageCacheSubtitle => 'キャッシュしたカード画像の容量を解放';

  @override
  String get settingsSaveBackup => 'バックアップを保存';

  @override
  String get settingsSaveBackupSubtitle =>
      'プロフィール、デッキ、設定、最近の対戦、フィードバックをファイルに書き出します';

  @override
  String get settingsRestoreBackup => 'バックアップを復元';

  @override
  String get settingsRestoreBackupSubtitle =>
      '.lifespark ファイルからこの端末のデータを置き換えます';

  @override
  String get settingsSectionHelp => 'ヘルプ';

  @override
  String get settingsFeedback => 'フィードバック';

  @override
  String get settingsFeedbackSubtitle => 'ご意見・ご要望をお送りください';

  @override
  String get settingsViewHubGuide => 'ハブガイドを見る';

  @override
  String get settingsViewHubGuideSubtitle => '対戦中のプレイ、スタック、検索、テーブルの使い方';

  @override
  String get settingsViewTutorialAgain => 'チュートリアルを再表示';

  @override
  String get settingsViewTutorialAgainSubtitle => '初期オンボーディングを再度起動';

  @override
  String get settingsBeta => 'ベータ';

  @override
  String get commonCancel => 'キャンセル';

  @override
  String get commonSave => '保存';

  @override
  String get commonAdd => '追加';

  @override
  String get commonRemove => '削除';

  @override
  String get commonClose => '閉じる';

  @override
  String get commonTryAgain => '再試行';

  @override
  String get backupSaved => 'バックアップを保存しました。';

  @override
  String get backupSaveFailed => 'バックアップを保存できませんでした。';

  @override
  String backupRestoreTitle(String username) {
    return '$username を復元しますか？';
  }

  @override
  String get backupRestoreMessage =>
      '選択したバックアップで、この端末のプロフィール、デッキ、設定、最近の対戦、スパーク、振る舞いが置き換えられます。';

  @override
  String get backupRestoreConfirm => '復元';

  @override
  String backupRestored(String username) {
    return '$username のバックアップを復元しました。';
  }

  @override
  String get backupRestoreFailed => 'バックアップを復元できませんでした。ファイルを確認してもう一度お試しください。';

  @override
  String get cacheCleared => '画像キャッシュを削除しました。';

  @override
  String get cacheClearFailed => '画像キャッシュを削除できませんでした。';

  @override
  String get decksTitle => 'デッキ';

  @override
  String get decksAddDeck => 'デッキを追加';

  @override
  String get profileTitle => 'プロフィール';

  @override
  String get profileRecentGames => '最近の対戦';

  @override
  String get profileDeckPerformance => 'デッキ成績';

  @override
  String get lobbyTitle => 'ロビー';

  @override
  String get lobbyHostGame => 'ホストする';

  @override
  String get lobbyHostGameSubtitle => 'セッションを作成 — 他の人が参加';

  @override
  String get lobbyJoinGame => '参加する';

  @override
  String get lobbyJoinGameSubtitle => '近くのホストを探す';

  @override
  String get hostLobbyTitle => 'ホストロビー';

  @override
  String get hostLeaveLobbyTooltip => 'ロビーを退出';

  @override
  String hostPlayersScanQr(int count, int max) {
    return 'プレイヤー: $count / $max  •  QRをスキャンして参加';
  }

  @override
  String get hostNeedWifiRetry => 'この端末をWi‑Fi（ゲストと同じネットワーク）に接続してから、再試行をタップ。';

  @override
  String get hostNeedsMobileApp =>
      'ホストには同じWi‑Fi上のモバイルアプリ（iOSまたはAndroid）が必要です。ブラウザはQRスキャンで参加できますが、ホストはできません。';

  @override
  String get hostNeedsMobileOrDev => 'ホストにはモバイルアプリ、またはローカル開発ビルドが必要です。';

  @override
  String get hostCreateProfileFirst =>
      '先にプロフィールを作成（ホーム → ユーザー名を設定）してから、再試行をタップ。';

  @override
  String get hostCouldNotStartServer => 'この端末でホストサーバーを開始できませんでした。再試行をタップ。';

  @override
  String get hostSessionDidNotStart => 'ホストセッションが開始しませんでした。再試行をタップ。';

  @override
  String get hostCouldNotShowQr => '参加用QRを表示できませんでした。';

  @override
  String get hostRetry => '再試行';

  @override
  String get hostNeedOnePlayer => 'プレイヤーが1人以上必要です';

  @override
  String get hostEveryoneMustBeReady => '全員が準備完了である必要があります';

  @override
  String get hostStartGame => 'ゲーム開始';

  @override
  String hostOpenSlots(int count) {
    return '空きスロット $count — 端末を共有して友達を参加させよう';
  }

  @override
  String get hostMatchLabel => 'ラベル';

  @override
  String get hostMatchLabelHelp => '任意。最近のゲームでこの試合を見つけやすくします。';

  @override
  String get hostMatchLabelHint => '例: 金曜EDH';

  @override
  String get hostGameSettings => 'ゲーム設定';

  @override
  String get hostFormat => 'フォーマット';

  @override
  String get hostStartingLife => '開始ライフ';

  @override
  String get hostCustomStartingLifeTitle => 'カスタム開始ライフ';

  @override
  String get hostCustomStartingLifeHint => 'ライフを入力（1–999）';

  @override
  String get hostCustomEllipsis => 'カスタム…';

  @override
  String get hostGameplay => 'ゲームプレイ';

  @override
  String get hostToggleTeams => 'チーム';

  @override
  String get hostToggleTeamsSubtitle => 'テーブルでチーム色を割り当て';

  @override
  String get hostTogglePlanechaseSubtitle => '次元デッキにはインターネットが必要';

  @override
  String get hostToggleArchenemySubtitle => '策略デッキにはインターネットが必要';

  @override
  String get hostToggleBountySubtitle => 'Bountyデッキにはインターネットが必要';

  @override
  String get hostToggleAutoKo => 'Auto-KO';

  @override
  String get hostToggleAutoKoSubtitle => 'ライフ・毒・統率者ダメージによる';

  @override
  String get hostToggleCommanderDmgLife => '統率者ダメージでライフ減少';

  @override
  String get hostToggleCommanderDmgLifeSubtitle => '統率者ダメージもライフを減らす';

  @override
  String get hostTogglePhaseTracker => 'フェーズトラッカー';

  @override
  String get hostTogglePhaseTrackerSubtitle => '戻る／次へでターンフェーズを表示';

  @override
  String get hostToggleTurnTimer => 'ターンタイマー';

  @override
  String get hostToggleTurnTimerSubtitle => '各ターンの経過時間を表示';

  @override
  String get hostTurnLimit => 'ターン制限';

  @override
  String get hostTurnLimitOff => 'オフ';

  @override
  String hostTurnLimitSeconds(int seconds) {
    return '$seconds 秒';
  }

  @override
  String get hostNoCommanderSelected => '統率者が未選択';

  @override
  String get hostNoDeckSelected => 'デッキが未選択';

  @override
  String hostTrackingDeck(String name) {
    return '追跡中: $name';
  }

  @override
  String get hostDeckListChanged => 'デッキ（保存リストが変更）';

  @override
  String get hostSelectDeck => 'デッキ';

  @override
  String get hostSelectCommander => '統率者';

  @override
  String get hostMarkReady => '準備完了にする';

  @override
  String get hostMarkNotReady => '準備中にする';

  @override
  String get lobbyReady => '準備完了';

  @override
  String get lobbyWaiting => '待機中';

  @override
  String get deckPickerTitle => 'この試合のデッキ';

  @override
  String get deckPickerManualOnly => '手動統率者のみ';

  @override
  String get deckPickerManualOnlySubtitle => '統率者はそのまま。保存デッキには紐づけない';

  @override
  String deckPickerEmptyForFormat(String format) {
    return '$format デッキがまだありません。デッキタブから作成してください。';
  }

  @override
  String get deckPickerOpenDecks => 'デッキを開く';

  @override
  String get joinTitle => 'ゲームに参加';

  @override
  String get joinLeaveTooltip => '退出';

  @override
  String get joinPointCamera => 'ホストのQRコードにカメラを向けてください';

  @override
  String get joinCameraRequiredSnack => 'ホストのQRをスキャンするにはカメラ許可が必要です。';

  @override
  String get joinCameraDeniedBody =>
      'ホストのQRをスキャンするにはカメラアクセスが必要です。\\n設定で既に許可している場合は、再試行をタップ。';

  @override
  String get joinOpenSettings => '設定を開く';

  @override
  String get joinInvalidQr => '有効なLife SparkのQRコードではありません。';

  @override
  String get joinMissingToken => 'このQRには参加トークンがありません。ホストにQRの更新を依頼してください。';

  @override
  String get joinCouldNotStartSession =>
      '参加セッションを開始できませんでした。プロフィール設定を完了して再試行してください。';

  @override
  String get joinConnectTimeout =>
      'ホストへの接続がタイムアウトしました。同じWi‑Fiでホストロビーが開いていることを確認して再試行してください。';

  @override
  String get joinHostRejected => 'ホストが接続を拒否しました（バージョン不一致）。';

  @override
  String get joinDisconnected => 'ホストから切断されました。';

  @override
  String get joinConnectionError => '接続エラー。';

  @override
  String get joinHostEndedSession => 'ホストがセッションを終了しました。';

  @override
  String get joinConnecting => 'ホストに接続中…';

  @override
  String get joinWaitingForHost => 'ホストの開始を待っています…';

  @override
  String get joinSelectDeck => 'デッキを選択';

  @override
  String get joinSelectCommander => '統率者を選択';

  @override
  String get joinReady => '準備完了';

  @override
  String get joinMarkReady => '準備完了にする';

  @override
  String get welcomeTagline => 'あなたのMTGコンパニオン。';

  @override
  String get welcomeReadyToPlay => 'プレイ準備OK';

  @override
  String get welcomeSkip => 'スキップ';

  @override
  String get onboardingSlide1Title => 'Life Sparkへようこそ';

  @override
  String get onboardingSlide1Body =>
      'Commanderの戦場コンパニオン — ライフ、カウンター、政治、スタックをテーブルで同期。';

  @override
  String get onboardingSlide2Title => 'ホストまたは参加';

  @override
  String get onboardingSlide2Body =>
      '1人がホストし、他の人は同じWi‑Fi上でQRをスキャン。インターネットアカウント不要。同じテーブルの4〜6人向け。';

  @override
  String get onboardingSlide3Title => 'ライフを追跡';

  @override
  String get onboardingSlide3Body =>
      '+/-をタップでライフ±1。+/-を長押しで±5。左右にドラッグで素早く調整。ライフをダブルタップで正確な数値。取り消しは下部バー（または有効ならシェイク）。';

  @override
  String get onboardingSlide4Title => 'フェーズバーとターン';

  @override
  String get onboardingSlide4Body =>
      'フェーズバーでターンを進めるか、ロビーでフェーズトラッカーをオフに。一時停止はゲーム全体を止めます。';

  @override
  String get onboardingSlide5Title => '統率者とカウンター';

  @override
  String get onboardingSlide5Body =>
      '統率者ダメージは脅威リストとして開く — 各対戦相手が21に向けて与えた量。毒（10）、エネルギー、経験、放射線を追跡。増殖で一度にすべて+1。';

  @override
  String get onboardingSlide6Title => '同盟と政治';

  @override
  String get onboardingSlide6Body =>
      '他プレイヤーと秘密の同盟を提案。自動で期限切れ、または互いに攻撃すると解消。君主と主導権はワンタップで追跡。';

  @override
  String get onboardingNext => '次へ';

  @override
  String get onboardingReadyToPlay => 'プレイ準備OK';

  @override
  String get onboardingSkip => 'スキップ';

  @override
  String get profileSetupTitle => 'プロフィールを作成';

  @override
  String get profileSetupSubtitle => 'テーブルが認識する名前と画像を選びましょう。';

  @override
  String get profileSetupUsername => 'ユーザー名';

  @override
  String get profileSetupUsernameRequired => 'ユーザー名を入力';

  @override
  String get profileSetupUsernameTooShort => '2文字以上必要です';

  @override
  String get profileSetupChoosePicture => 'プロフィール画像を選択';

  @override
  String get profileSetupChangePicture => '画像を変更';

  @override
  String get profileSetupContinue => '続ける';

  @override
  String get sessionLeaveTitle => '進行中のゲームを退出しますか？';

  @override
  String get sessionLeaveMessage =>
      'ロビーまたはゲームセッションが実行中です。退出するとテーブルの他プレイヤーが切断されます。';

  @override
  String get sessionLeaveConfirm => '退出';

  @override
  String get sessionLeaveStay => '残る';

  @override
  String get gameLeaveTitle => 'ゲームを退出しますか？';

  @override
  String get gameLeaveMessageActive =>
      'ゲームを退出してホームに戻ります。試合統計はテーブルがゲームを終えたときだけ保存されます。';

  @override
  String get gameLeaveMessageAfterConcede =>
      'ライブゲームを退出してホームに戻ります。切断前に降参結果が保存されます。';

  @override
  String get gameTabPlay => 'プレイ';

  @override
  String get gameTabStack => 'スタック';

  @override
  String get gameTabLookupSemantics => 'カードルールを調べる';

  @override
  String get gameBarHome => 'ホーム';

  @override
  String get gameBarUndo => '取り消し';

  @override
  String get gameBarTimeout => '一時停止';

  @override
  String get gameBarEnd => '終了';

  @override
  String get gameBarTable => 'テーブル';

  @override
  String get gameEndTurn => 'ターン終了';

  @override
  String gameWaitingForPlayer(String name) {
    return '$name を待っています…';
  }

  @override
  String get gamePhaseBack => '戻る';

  @override
  String get gamePhaseNext => '次へ';

  @override
  String get gameChoosePhase => 'フェーズを選択';

  @override
  String get gameYourTurn => 'あなたのターン';

  @override
  String get gameYourTurnTapContinue => 'タップして続ける';

  @override
  String get gameYourTurnSemantics => 'あなたのターン。ダブルタップで閉じる。';

  @override
  String get gameNowPlaying => 'プレイ中';

  @override
  String get gameActiveTurn => 'アクティブターン';

  @override
  String gamePlayersTurn(String name) {
    return '$name のターン';
  }

  @override
  String get gameCurrentTurn => '現在のターン';

  @override
  String get timeoutStartTitle => '一時停止を開始';

  @override
  String get timeout15Seconds => '15秒';

  @override
  String get timeout30Seconds => '30秒';

  @override
  String get timeout1Minute => '1分';

  @override
  String get timeoutBanner => '一時停止';

  @override
  String get timeoutPaused => 'ゲーム一時停止 — ライフ変更なし';

  @override
  String get timeoutEnd => '一時停止を終了';

  @override
  String timeoutMinimized(String time) {
    return '一時停止 — $time';
  }

  @override
  String get timeoutMinimizeTooltip => 'タイマーを最小化';

  @override
  String get reconnectToTable => 'テーブルに再接続中…';

  @override
  String get reconnectStillTrying => 'テーブルへの到達を再試行中…';

  @override
  String reconnectPeerOne(String name) {
    return '$name が再接続中…';
  }

  @override
  String reconnectPeerMany(int count) {
    return '$count 人が再接続中…';
  }

  @override
  String get forfeitTitle => '降参しますか？';

  @override
  String get forfeitBodyMulti => 'ゲームを退出します。任意で対戦相手を評価してから退出できます。';

  @override
  String get forfeitBodySolo => '練習ゲームが終了します。任意で結果をメモできます。';

  @override
  String get forfeitRateOpponents => '対戦相手を評価';

  @override
  String get forfeitConfirm => '降参';

  @override
  String get forfeitYouForfeited => '降参しました';

  @override
  String get forfeitStaySpectateBody =>
      '他のプレイヤーは続行できます。テーブルが終わるまでこの端末で観戦できます。今プロフィールに戻ると降参結果を保存し、ライブゲームから切断します。';

  @override
  String get forfeitStaySpectate => '残って観戦';

  @override
  String get forfeitReturnToProfile => 'プロフィールに戻る';

  @override
  String get gamePlayerLeftTitle => 'プレイヤーが退出';

  @override
  String gamePlayerLeftMessage(String username) {
    return '$username がゲームを退出しました。';
  }

  @override
  String get gameSessionEndedTitle => 'セッション終了';

  @override
  String get gameSessionEndedMessage => 'ホストがゲームを終了しました。';

  @override
  String gamePeerOfflineTitle(String username) {
    return '$username はまだオフライン';
  }

  @override
  String get gamePeerOfflineBody => '再接続を待ちますか？それともテーブルから外しますか？';

  @override
  String get gameKeepWaiting => '待ち続ける';

  @override
  String get gameRemoveFromTable => 'テーブルから外す';

  @override
  String get gameSlotLoadFailedTitle => 'プレイヤースロットを読み込めません';

  @override
  String get gameSlotLoadFailedBody => 'ゲームが同期ずれしている可能性があります。ロビーに戻って再参加してください。';

  @override
  String get gameReturnToLobby => 'ロビーに戻る';

  @override
  String get profileSetupPrompt => '続けるにはプロフィールを設定してください。';

  @override
  String get profileCreateCta => 'プロフィール作成';

  @override
  String get profileNewPlayer => '新規プレイヤー';

  @override
  String profilePlayingSince(String date) {
    return '$date からプレイ';
  }

  @override
  String get profileOptions => 'プロフィールオプション';

  @override
  String get profileDoneEditing => '編集完了';

  @override
  String get profileDone => '完了';

  @override
  String get profileEditName => '名前を編集';

  @override
  String get profileEditNameTooltip => '名前を編集';

  @override
  String get profileChangePicture => 'プロフィール画像を変更';

  @override
  String get profileStatRecord => '戦績';

  @override
  String get profileStatSparks => 'Sparks';

  @override
  String get profileStatGames => '試合';

  @override
  String get profileEmptyRecentGames => '最初のゲームをプレイして統計と履歴を解除。';

  @override
  String get profileEmptyDeckPerf => 'デッキを追加して統率者の成績を追跡。';

  @override
  String get profileFilterAllGames => 'すべて';

  @override
  String get profileFilterRecent14 => '最近（14日）';

  @override
  String get profileFilterThisWeek => '今週';

  @override
  String get profileFilterThisMonth => '今月';

  @override
  String get profileNoMatchesFilter => 'このフィルターに一致する試合はありません。';

  @override
  String get profileOpenLobbySemantics => 'ロビーを開いてホストまたは参加';

  @override
  String get profileShowMore => 'もっと見る';

  @override
  String get profileStandings => '順位';

  @override
  String get profileNoPlayerDetails => 'この試合のプレイヤー詳細は保存されていません。';

  @override
  String get profileResultConcede => '降参';

  @override
  String get profileResultLoss => '敗北';

  @override
  String get decksEmptyTitle => 'デッキライブラリを作ろう';

  @override
  String get decksEmptyBody =>
      '名前・フォーマット・カバーカード付きでデッキを保存。ホストや参加時にロビーでリストを選べます。';

  @override
  String get decksSearchHint => 'デッキを検索…';

  @override
  String decksNoSearchMatches(String query) {
    return '“$query” に一致するデッキはありません。';
  }

  @override
  String get decksStyleNotSet => 'スタイル未設定';

  @override
  String get decksNoCoverCard => 'カバーカードなし';

  @override
  String get lookupTitle => 'カード検索';

  @override
  String get lookupHint => '任意のMTGカードを検索…';

  @override
  String get lookupHelp => 'ScryfallのOracleテキストと公式裁定。';

  @override
  String get lookupEmptyPrompt => 'カード名を入力してルールを調べる。';

  @override
  String lookupNoResults(String query) {
    return '“$query” のカードは見つかりませんでした。';
  }

  @override
  String get lookupNetworkError => 'Scryfallに接続できません。接続を確認してください。';

  @override
  String get lookupSearch => '検索';

  @override
  String get lookupOracleText => 'Oracleテキスト';

  @override
  String get lookupNoOracle => 'このカードのOracleテキストはありません。';

  @override
  String get lookupRulings => '裁定';

  @override
  String get lookupNoRulings => 'このカードの公式裁定はありません。';

  @override
  String get endGameSavingResults => '試合結果を保存中…';

  @override
  String get endGameSaveFailedTitle => '試合結果を保存できませんでした。';

  @override
  String get endGameSaveFailedBody => '統計が更新されていない可能性があります。もう一度お試しください。';

  @override
  String get endGameRetry => '再試行';

  @override
  String get endGameContinueWithoutSaving => '保存せずに続ける';

  @override
  String get endGameFinalStandings => '最終順位';

  @override
  String get endGameOverNoWinner => 'ゲーム終了 — 勝者なし';

  @override
  String get endGamePracticeEnded => '練習終了';

  @override
  String get endGameYouWin => '勝利！';

  @override
  String get endGameWinner => '勝者';

  @override
  String get endGameRankUp => 'ランクアップ！';

  @override
  String endGameRankTransition(int oldLevel, int newLevel) {
    return 'ランク $oldLevel → $newLevel';
  }

  @override
  String endGameXpGained(int xp) {
    return '+$xp XP';
  }

  @override
  String get endGameWinBonusIncluded => '勝利ボーナス込み';

  @override
  String get endGameParticipationXp => '参加XP';

  @override
  String endGameRankLevel(int level) {
    return 'ランク $level';
  }

  @override
  String get endGameFeedbackThanks => 'ありがとう！フィードバックを記録しました。';

  @override
  String get endGameRateOpponents => '対戦相手を評価';

  @override
  String get endGameSubmitFeedback => 'フィードバックを送信';

  @override
  String get endGameYouSuffix => '（あなた）';

  @override
  String get endGameElimReasonLife => 'ライフ尽きた';

  @override
  String get endGameElimReasonPoison => '毒10';

  @override
  String get endGameElimReasonCommanderDmg => '統率者ダメージ';

  @override
  String get endGameElimReasonConcede => '投了';

  @override
  String get endGameElimReasonDisconnect => '退席';

  @override
  String get endGameElimReasonDefault => '敗退';

  @override
  String get endGameBackToHome => 'ホームに戻る';

  @override
  String get feedbackTitle => 'フィードバック';

  @override
  String get feedbackHeadline => '改善にご協力ください';

  @override
  String get feedbackBody => 'バグやアイデアはありますか？すべてのメッセージを読んでいます。';

  @override
  String get feedbackMessageLabel => 'メッセージ';

  @override
  String get feedbackMessageHint => 'ご意見をお聞かせください...';

  @override
  String get feedbackSend => 'フィードバックを送信';

  @override
  String get feedbackOrDivider => 'または';

  @override
  String get feedbackRatePlayStore => 'Playストアで評価';

  @override
  String get feedbackMailSubject => 'Life Spark フィードバック';

  @override
  String get feedbackOpeningMail => 'メールアプリを開いています…';

  @override
  String feedbackNoMailAppCopied(String email) {
    return 'メールアプリなし — メッセージをコピーしました。$email 宛てに貼り付けてください';
  }

  @override
  String feedbackClipboardFallback(String email, String message) {
    return '宛先: $email\\n件名: Life Spark フィードバック\\n\\n$message';
  }

  @override
  String get stackSortOrderOnStack => 'スタック上の順序';

  @override
  String get stackSortByPlayer => 'プレイヤー別';

  @override
  String get stackAddSpellOrAbility => '呪文または能力を追加';

  @override
  String get stackHowItWorksTooltip => 'スタックの仕組み';

  @override
  String get stackFilterResolvedCountered => '解決済み / 打ち消し';

  @override
  String get stackApnapHint => '誰が何を追加したか（アクティブプレイヤー優先）';

  @override
  String get stackClearAll => 'すべてクリア';

  @override
  String get stackClearConfirmTitle => 'スタックをクリアしますか？';

  @override
  String get stackClearConfirmBody => 'スタック上の呪文と能力をすべて削除します。元に戻せません。';

  @override
  String stackActivePlayerLabel(String username) {
    return '$username · アクティブプレイヤー';
  }

  @override
  String stackTurnOrderLabel(String username, int position) {
    return '$username · ターン順: $position';
  }

  @override
  String get stackPutOnStack => 'スタックに載せる';

  @override
  String get stackInResponseToEllipsis => 'これに対応して…';

  @override
  String get stackEmptyTitle => 'スタックは空です';

  @override
  String get stackEmptyBullet1 => '解決前の呪文と能力をここに載せます。';

  @override
  String get stackEmptyBullet2 => '最後に載せたものが先に解決します。';

  @override
  String get stackAddSpell => '呪文を追加';

  @override
  String get stackStatusResolved => '解決済み';

  @override
  String get stackStatusCountered => '打ち消し';

  @override
  String get stackStatusFizzled => '不発';

  @override
  String get stackYouSuffix => '（あなた）';

  @override
  String get stackUndoFizzle => '不発を取り消す';

  @override
  String get stackFizzle => '不発';

  @override
  String get stackUndoFizzleSubtitle => 'この呪文をアクティブな状態でスタックに戻す';

  @override
  String get stackFizzleSubtitle => '対象不正、または呪文がスタックを離れた（ルール上の打ち消し）';

  @override
  String get stackMarkCountered => '打ち消し済みにする';

  @override
  String get stackRename => '名前を変更';

  @override
  String get stackOnStack => 'スタック上';

  @override
  String get stackResolvesNext => '次に解決';

  @override
  String get stackResolvesAfterAbove => '上のものより後に解決';

  @override
  String get stackTargetNoLongerOnStack => '対象はもうスタックにありません';

  @override
  String get stackCardRulesTooltip => 'カードのルール';

  @override
  String stackInResponseToNamed(String name) {
    return '$name に対応して';
  }

  @override
  String get stackResolve => '解決';

  @override
  String get stackRespond => '対応';

  @override
  String get stackFizzledButton => '不発';

  @override
  String get stackHelpTitle => 'スタックの仕組み';

  @override
  String get stackHelpBullet1 => '誰かが呪文を唱えるか能力を使うと、スタックに乗ります — 実行前の待ち行列です。';

  @override
  String get stackHelpBullet2 =>
      '最後に載せたものが先に解決します（お皿の山と同じ）。だから一番上は「次に解決」と表示されます。';

  @override
  String get stackHelpBullet3 =>
      '呪文を追加するときは Scryfall で検索し、リストからカードを選んで正しい名前とルールテキストを保存します。';

  @override
  String get stackHelpBullet4 =>
      '対応するには「対応」をタップするか「これに対応して…」を使います — あなたの呪文が上に乗り、下より先に解決します。';

  @override
  String get stackHelpBullet5 =>
      '効果が終わったら「解決」をタップ — カードはスタックに残り緑になります。対応するなら「対応」。打ち消しが成功したら「打ち消し済みにする」（打ち消しフィルターで表示）。対象を失ったら「不発」— 灰色のまま；もう一度「不発」で取り消し。';

  @override
  String get stackHelpBullet6 =>
      '卓では優先権のために声に出して「パス」します。この画面は何がどの順で待っているかを覚える助けになります。';

  @override
  String get stackHelpExample =>
      '例: 自分のクリーチャーにパンプ呪文。相手が対応で Lightning Bolt。Bolt が先に解決し、その後パンプ（対象が合法なら）。';

  @override
  String get stackHelpReadMore => 'Magic.com で詳しく';

  @override
  String get stackHelpCouldNotOpenLink => 'リンクを開けませんでした';

  @override
  String get stackPickerIntro => 'Scryfall で検索して正しいカード名とルールテキストを保存します。';

  @override
  String get stackPickerCardNameLabel => 'カード名';

  @override
  String get stackPickerCardNameHint => '例: Lightning Bolt';

  @override
  String get stackPickerClearSearch => '検索をクリア';

  @override
  String get stackPickerAdd => '追加';

  @override
  String get stackPickerNoCards => 'カードが見つかりません。別の綴りを試してください。';

  @override
  String get stackPickerNetworkError => 'Scryfall に接続できません。インターネットを確認してください。';

  @override
  String get stackPickerNeedSelection =>
      'リストからカードを選ぶか、Scryfall が認識する名前を入力してください。';

  @override
  String get stackPickerTypeToSearch => '入力してカードを検索';

  @override
  String get allianceAPlayer => 'プレイヤー';

  @override
  String get allianceYourAllyFallback => '味方';

  @override
  String get allianceOfferDeclined => '秘密同盟の提案が拒否されました';

  @override
  String get allianceEnded => '秘密同盟が終了しました';

  @override
  String get allianceProposeTitle => '秘密同盟';

  @override
  String allianceProposeSubtitle(String username) {
    return '$username を招待 — 相手だけが知ります。';
  }

  @override
  String get allianceDurationSection => '期間';

  @override
  String get allianceDurationEndOfTurn => 'ターン終了まで';

  @override
  String get allianceDurationEndOfRound => 'ラウンド終了まで';

  @override
  String get allianceDurationUntilBroken => '破られるまで';

  @override
  String get allianceWhenToDeliver => '配達タイミング';

  @override
  String get allianceDeliverNow => '今すぐ配達';

  @override
  String allianceDeliverInSeconds(int seconds) {
    return '$seconds秒後に配達';
  }

  @override
  String get allianceDeliverEndOfYourTurn => '自分のターン終了時に配達';

  @override
  String get allianceDeliverNextRound => '次のラウンドに配達';

  @override
  String allianceSecondsShort(int seconds) {
    return '$seconds秒';
  }

  @override
  String get allianceSend => '送信';

  @override
  String allianceWhisperSent(String username) {
    return '$username にささやきを送信しました';
  }

  @override
  String allianceWhisperScheduled(String username) {
    return '$username へのささやきを予約しました';
  }

  @override
  String get allianceInviteTitle => '秘密の提案';

  @override
  String allianceInviteBody(String username, String duration) {
    return '$username が秘密同盟を提案しています。\\n\\n期間: $duration\\n\\nあなただけが見られます。';
  }

  @override
  String get allianceAccept => '承諾';

  @override
  String get allianceDecline => '拒否';

  @override
  String get allianceFormedTitle => '同盟成立';

  @override
  String allianceFormedBody(String username, String duration) {
    return 'あなたと $username は秘密同盟中です（$duration）。\\n\\n卓は知りません — 公開するか裏切らない限り。';
  }

  @override
  String allianceFormedBodyNoDuration(String username) {
    return 'あなたと $username は秘密同盟中です。\\n\\n卓は知りません — 公開するか裏切らない限り。';
  }

  @override
  String get allianceUnderstood => '了解';

  @override
  String get allianceRevealedTitle => '同盟が公開されました';

  @override
  String allianceRevealedBody(String playerA, String playerB) {
    return '$playerA と $playerB が秘密同盟を卓に公開しました。';
  }

  @override
  String get allianceOk => 'OK';

  @override
  String get allianceBetrayalTitle => '裏切り！';

  @override
  String allianceBetrayalBody(String playerA, String playerB) {
    return '$playerA と $playerB の秘密同盟が裏切りで破れました。';
  }

  @override
  String get allianceBadgeAllied => '同盟中';

  @override
  String get allianceBadgeSecretAlly => '秘密の味方';

  @override
  String allianceWhisperPending(String username) {
    return 'ささやき保留 → $username';
  }

  @override
  String allianceAwaiting(String username) {
    return '$username を待っています';
  }

  @override
  String get cmdDmgSheetTitle => '統率者ダメージ';

  @override
  String get cmdDmgSheetSubtitle => 'あなたへの脅威を先に。与えたダメージは「与えた」で記録。';

  @override
  String cmdDmgBarA11y(String remaining, String ko, String taken) {
    return '統率者ダメージ 残り $remaining / $ko、最悪トラックで $taken、タップで管理';
  }

  @override
  String get cmdDmgLeft => '残り';

  @override
  String get cmdDmgHideDealt => '与えたを隠す';

  @override
  String cmdDmgDealtTotal(String total) {
    return '与えた $total';
  }

  @override
  String get cmdDmgDefaultCommander => 'Commander';

  @override
  String get cmdDmgDefaultPartner => 'Partner';

  @override
  String get cmdDmgDefaultPartnerCommander => 'Partner 統率者';

  @override
  String cmdDmgYouDealtTitle(String name) {
    return 'あなた → $name';
  }

  @override
  String get cmdDmgYouDealtSubtitle => 'あなたが与えたダメージ';

  @override
  String get cmdDmgLethalTooltip => '致死の統率者ダメージ！';

  @override
  String get cmdDmgIncreaseA11y => '統率者ダメージを増やす';

  @override
  String get cmdDmgDecreaseA11y => '統率者ダメージを減らす';

  @override
  String get cmdBarCastCommander => '統率者を唱える';

  @override
  String get cmdBarEliminated => '敗退';

  @override
  String get cmdBarNoTaxYet => 'まだ課税なし';

  @override
  String get cmdBarRemoveLastCast => '最後の統率者唱を取り消す';

  @override
  String get cmdBarCommanderTax => '統率者税';

  @override
  String get cmdBarTapToRemoveLastCast => 'タップして最後の唱を取り消し';

  @override
  String cmdBarTaxPlus(int tax) {
    return '税 +$tax';
  }

  @override
  String get counterResetConfirmTitle => '0にリセットしますか？';

  @override
  String get counterResetConfirmBody => 'このカウンターをゼロにします。';

  @override
  String get counterResetConfirmAction => 'リセット';

  @override
  String get counterResetToZero => '0にリセット';

  @override
  String get counterDone => '完了';

  @override
  String get firstPlayerRollTitle => '先攻を決めるダイス';

  @override
  String get firstPlayerRollSubtitle => '高い出目が先攻。ダイスをタップ！';

  @override
  String get firstPlayerRollDieA11y => 'ダイスを振る';

  @override
  String get firstPlayerRollingA11y => '振っています';

  @override
  String firstPlayerRolledA11y(String value) {
    return '$value が出ました';
  }

  @override
  String get firstPlayerNotRolledA11y => '未ロール';

  @override
  String firstPlayerYouRolled(String value) {
    return '$value が出ました！';
  }

  @override
  String firstPlayerYouRolledA11y(String value) {
    return '$value が出ました';
  }

  @override
  String get firstPlayerRolling => '振っています…';

  @override
  String get firstPlayerTapToRoll => 'タップして振る';

  @override
  String firstPlayerHostProgressA11y(String rolled, String total) {
    return '$total 人中 $rolled 人が振りました';
  }

  @override
  String get firstPlayerWaitingOthersA11y => '他のプレイヤーのロール待ち';

  @override
  String get firstPlayerRollToContinueA11y => 'ダイスを振って続ける';

  @override
  String firstPlayerHostProgress(String rolled, String total) {
    return '$rolled / $total 人が振りました';
  }

  @override
  String get firstPlayerWaitingOthers => '他のプレイヤー待ち…';

  @override
  String get firstPlayerTapDieAbove => '上のダイスをタップして振る';

  @override
  String firstPlayerYouSuffix(String username) {
    return '$username（あなた）';
  }

  @override
  String get firstPlayerTurnOrderTitle => 'ターン順';

  @override
  String get firstPlayerTurnOrderSubtitle => '高い出目が先頭 — この順で進行します。';

  @override
  String get firstPlayerStartGame => 'ゲーム開始';

  @override
  String get firstPlayerOrdinal1 => '1位';

  @override
  String get firstPlayerOrdinal2 => '2位';

  @override
  String get firstPlayerOrdinal3 => '3位';

  @override
  String get firstPlayerOrdinal4 => '4位';

  @override
  String get firstPlayerOrdinal5 => '5位';

  @override
  String get firstPlayerOrdinal6 => '6位';

  @override
  String firstPlayerSlotA11y(String place, String name, String rollDetail) {
    return '$place、$name、$rollDetail';
  }

  @override
  String firstPlayerSlotYou(String username) {
    return '$username、あなた';
  }

  @override
  String get firstPlayerRollUnavailable => 'ロール不可';

  @override
  String firstPlayerRolledDetail(String value) {
    return '$value を出した';
  }

  @override
  String get firstPlayerGoesFirst => '先攻';

  @override
  String get historyTitle => '履歴';

  @override
  String get historySubtitle => 'ライフ、カウンター、その他の卓の行動。';

  @override
  String get historyEmptyTitle => 'まだ行動がありません';

  @override
  String get historyEmptyBody => 'ライフ変更、カウンター、その他の行動がゲーム進行とともにここに表示されます。';

  @override
  String historyTurn(String turn) {
    return 'ターン $turn';
  }

  @override
  String get overviewElimReasonLife => 'ライフ喪失';

  @override
  String get overviewElimReasonPoison => '毒';

  @override
  String get overviewElimReasonCommanderDmg => '統率者ダメージ';

  @override
  String get overviewElimReasonConcede => '投了';

  @override
  String get overviewElimReasonDisconnect => '切断';

  @override
  String overviewRound(int round) {
    return 'ラウンド $round';
  }

  @override
  String get overviewClose => '概要を閉じる';

  @override
  String get overviewTools => 'ツール';

  @override
  String get overviewHistory => '履歴';

  @override
  String get overviewPlayers => 'プレイヤー';

  @override
  String get overviewHoldDragReorder => '長押しドラッグでターン順を変更';

  @override
  String get overviewDecreaseLife => 'ライフを減らす';

  @override
  String get overviewIncreaseLife => 'ライフを増やす';

  @override
  String overviewCommanderTaxPlus(int tax) {
    return '統率者税プラス $tax';
  }

  @override
  String overviewTaxPlus(int tax) {
    return '税 +$tax';
  }

  @override
  String get overviewMonarchA11y => 'Monarch';

  @override
  String get overviewInitiativeA11y => 'Initiative';

  @override
  String get overviewNowPlaying => 'プレイ中';

  @override
  String get overviewSendWhisper => 'ささやきを送る';

  @override
  String get overviewAssignTeamColor => 'チーム色を割り当て';

  @override
  String get overviewProposeSecretAlliance => '秘密同盟を提案';

  @override
  String get overviewRevealAlliance => '同盟を卓に公開';

  @override
  String get overviewBreakAlliance => '秘密同盟を破棄';

  @override
  String get overviewAssignTeamTitle => 'チームを割り当て';

  @override
  String get overviewTeamNone => 'なし';

  @override
  String overviewTeamN(String index) {
    return 'チーム $index';
  }

  @override
  String dialsStripLimitSnack(int max) {
    return 'ストリップは最大 $max 個まで。追加するには1つ外してください。';
  }

  @override
  String get dialsLabelPoison => '毒';

  @override
  String get dialsLabelEnergy => 'エネルギー';

  @override
  String get dialsLabelExp => '経験';

  @override
  String get dialsLabelRad => '放射線';

  @override
  String get dialsLabelBlood => '血';

  @override
  String get dialsLabelClue => '手がかり';

  @override
  String get dialsLabelMap => '地図';

  @override
  String get dialsLabelTreasure => '宝物';

  @override
  String get dialsLabelDevotion => '信心';

  @override
  String get dialsLabelCreatures => 'クリーチャー';

  @override
  String get dialsLabelEnchant => 'エンチャント';

  @override
  String get dialsLabelArtifacts => 'アーティファクト';

  @override
  String get dialsLabelGy => '墓地';

  @override
  String get dialsLabelExile => '追放';

  @override
  String get dialsAddCounterTitle => 'カウンターを追加';

  @override
  String dialsAddCounterBody(int max) {
    return 'ストリップ用トラッカーを選ぶ（最大 $max）。X でストリップから削除。';
  }

  @override
  String get dialsSectionCommon => 'よく使う';

  @override
  String get dialsSectionTokensZones => 'トークンと領域';

  @override
  String get dialsAllBuiltInsOnStrip =>
      '組み込みカウンターはすべてストリップ上です。枠を空けるには1つ外してください。';

  @override
  String get dialsAddCounterTooltip => 'カウンターを追加';

  @override
  String get dialsRemoveFromStrip => 'ストリップから削除';

  @override
  String get hubGuideTitle => 'クイックツアー';

  @override
  String get hubGuideSkip => 'スキップ';

  @override
  String get hubGuideNext => '次へ';

  @override
  String get hubGuideGotIt => '了解';

  @override
  String get hubGuideSlidePlayTitle => 'プレイ';

  @override
  String get hubGuideSlidePlayBody =>
      'ここでライフとカウンターを管理。ターン終了はフェイズバーの下 — ロビーでフェイズ追跡をオフにすると大きなターン終了ボタンになります。';

  @override
  String get hubGuideSlideStackTitle => 'スタックと検索';

  @override
  String get hubGuideSlideStackBody =>
      'スタックは Hold Priority と効果解決用。検索は席を離れず Scryfall — オラクルテキストと裁定。';

  @override
  String get hubGuideSlideTableTitle => '卓の概要';

  @override
  String get hubGuideSlideTableBody =>
      '卓でポッド全体を表示。ツールは全員が見るダイスとコイン。履歴はヘッダー。ターン終了は固定、投了はその下。';

  @override
  String get hubGuideSlideCommanderTitle => 'あなたのターンと統率者';

  @override
  String get hubGuideSlideCommanderBody =>
      '席が自分になったら「あなたのターン」をタップして閉じます。ハートは統率者ダメージを21まで追跡します。';

  @override
  String lifeA11yEliminatedAt(String life) {
    return 'ライフ $life で敗退';
  }

  @override
  String lifeA11yLifeTotal(String life) {
    return 'ライフ合計 $life';
  }

  @override
  String get lifeA11yDecrease => 'ライフを減らす';

  @override
  String get lifeA11yIncrease => 'ライフを増やす';

  @override
  String get lifeSetTotalTitle => 'ライフ合計を設定';

  @override
  String get glanceOpenTableA11y => '卓の概要を開く、ターン順';

  @override
  String get glanceYou => 'あなた';

  @override
  String get phasePickerTitle => 'フェイズを選択';

  @override
  String get phasePickerSubtitle => 'スクロールしてフェイズをタップ、または強調されたステップに「フェイズを設定」。';

  @override
  String phasePickerSetPhase(String phase) {
    return '$phase を設定';
  }

  @override
  String get whisperPresetTeamUp => '組もう？';

  @override
  String get whisperPresetDontAttack => '攻撃しないで';

  @override
  String get whisperPresetHaveRemoval => '除去あるよ';

  @override
  String get whisperPresetAllGood => '大丈夫';

  @override
  String whisperSentSnack(String username) {
    return '$username にささやきを送信しました';
  }

  @override
  String get whisperSendFailed => '送信できません — 少し待つか接続を確認してください。';

  @override
  String whisperSheetTitle(String username) {
    return '$username へのささやき';
  }

  @override
  String get whisperSheetSubtitle => '相手だけが見ます — 消えます。試合履歴には残りません。';

  @override
  String get whisperCustomLabel => 'カスタムメッセージ';

  @override
  String get whisperCustomHint => '短いメモ…';

  @override
  String get whisperSend => 'ささやきを送信';

  @override
  String whisperOverlayA11y(String username, String text) {
    return '$username からのささやき: $text';
  }

  @override
  String whisperOverlayHeader(String username) {
    return '$username からのささやき';
  }

  @override
  String get politicsTapToAssignA11y => '卓の政治。タップして割り当て。';

  @override
  String get politicsStatusEmpty => 'Monarchなし · Initiativeなし · —';

  @override
  String get politicsDay => '昼';

  @override
  String get politicsNight => '夜';

  @override
  String get politicsAssignSheetTitle => '卓の政治を割り当て';

  @override
  String get politicsMonarch => 'Monarch';

  @override
  String get politicsInitiative => 'Initiative';

  @override
  String get politicsAssignMonarch => 'Monarch を割り当て';

  @override
  String get politicsAssignInitiative => 'Initiative を割り当て';

  @override
  String get politicsNone => 'なし';

  @override
  String get politicsDayNight => '昼/夜';

  @override
  String get tableToolsTitle => 'ツール';

  @override
  String get tableToolsSubtitle => '卓の全員が結果を見ます。';

  @override
  String get tableToolsD6 => 'd6';

  @override
  String get tableToolsD20 => 'd20';

  @override
  String get tableToolsCoin => 'コイン';

  @override
  String get tableToolsResultHint => '結果が卓全体に表示されます';

  @override
  String get tableToolsRollD6 => 'd6を振る';

  @override
  String get tableToolsRollD20 => 'd20を振る';

  @override
  String get tableToolsFlipCoin => 'コインを投げる';

  @override
  String get tableToolHeads => '表';

  @override
  String get tableToolTails => '裏';

  @override
  String tableToolRolledHeadline(String username, String result) {
    return '$username が $result を出した';
  }

  @override
  String tableToolFlippedHeadline(String username, String result) {
    return '$username が $result';
  }

  @override
  String get tableToolTapToDismiss => 'タップして閉じる';

  @override
  String tableToolDismissA11y(String headline) {
    return '$headline。タップして閉じる。';
  }

  @override
  String get tableToolPlayerFallback => 'プレイヤー';

  @override
  String get variantDeckSingular => 'バリアントデッキ';

  @override
  String get variantDeckPlural => 'バリアントデッキ';

  @override
  String variantDeckA11y(String label) {
    return '$label、タップして表示';
  }

  @override
  String get variantDecksSheetTitle => 'バリアントデッキ';

  @override
  String get variantLoading => 'バリアントデッキを読み込み中…';

  @override
  String get variantLoadFailed => 'デッキを読み込めません（インターネットが必要）';

  @override
  String get variantPlanechase => 'Planechase';

  @override
  String get variantArchenemy => 'Archenemy';

  @override
  String get variantBounty => 'Bounty';

  @override
  String get variantNextCard => '次のカード';

  @override
  String commanderSelectNoCommanders(String query) {
    return '「$query」の統率者が見つかりません';
  }

  @override
  String commanderSelectNoCards(String query) {
    return '「$query」のカードが見つかりません';
  }

  @override
  String get commanderSelectSearchFailed => '検索できません。接続を確認してもう一度。';

  @override
  String get commanderSelectEditCommanders => '統率者を編集';

  @override
  String get commanderSelectEditCover => 'カバーカードを編集';

  @override
  String get commanderSelectStep2Commander => 'ステップ 2/2 — 統率者';

  @override
  String get commanderSelectStep2Cover => 'ステップ 2/2 — カバーカード';

  @override
  String get commanderSelectPartnerTitle => 'Partner を選択';

  @override
  String get commanderSelectCommanderTitle => 'Commander を選択';

  @override
  String get commanderSelectCoverHint => 'デッキアート用に任意のカードを選択 — フルリストではありません。';

  @override
  String get commanderSelectSearchPartnerHint => 'Partner 統率者を検索…';

  @override
  String get commanderSelectSearchCommanderHint => '統率者を検索…';

  @override
  String get commanderSelectSearchCardHint => 'カードを検索…';

  @override
  String get commanderSelectConfirm => '確定';

  @override
  String get commanderSelectScryfallCommanderHelp => '統率者名を入力して Scryfall を検索。';

  @override
  String get commanderSelectScryfallCardHelp => 'カード名を入力して Scryfall を検索。';

  @override
  String get commanderSelectLabelCommander => 'Commander';

  @override
  String get commanderSelectLabelPartner => 'Partner';

  @override
  String get commanderSelectOptional => '任意';

  @override
  String get deckOptionsDeleteTitle => 'デッキを削除しますか？';

  @override
  String deckOptionsDeleteBody(String name) {
    return '「$name」をライブラリから削除しますか？試合履歴は残りますが、ロビーの選択には出なくなります。';
  }

  @override
  String get deckOptionsDeleteConfirm => '削除';

  @override
  String get deckOptionsStyleNotSet => 'スタイル未設定';

  @override
  String get deckOptionsEditCommanders => '統率者を編集';

  @override
  String get deckOptionsEditCover => 'カバーカードを編集';

  @override
  String get deckOptionsNoGamesYet => 'まだ試合なし';

  @override
  String deckOptionsWinRate(String rate) {
    return '勝率 $rate%';
  }

  @override
  String get deckOptionsUnpin => '先頭固定を解除';

  @override
  String get deckOptionsPin => '先頭に固定';

  @override
  String get deckOptionsChangeFormat => 'フォーマットを変更';

  @override
  String get deckOptionsChangeStyle => 'スタイルを変更';

  @override
  String get deckOptionsStyleRequired => '必須 — 未設定';

  @override
  String get deckOptionsRename => '名前を変更';

  @override
  String get deckOptionsDuplicate => '複製';

  @override
  String get deckOptionsDelete => 'デッキを削除';

  @override
  String get deckOptionsRenameTitle => 'デッキ名を変更';

  @override
  String get deckOptionsNameLabel => 'デッキ名';

  @override
  String get deckOptionsNameHint => '例: Raffine Tempo';

  @override
  String get newDeckChooseStyleError => '続けるにはデッキスタイルを選んでください';

  @override
  String get newDeckTitle => '新しいデッキ';

  @override
  String get newDeckSubtitle => 'ステップ 1/2 — 詳細';

  @override
  String get newDeckIntro => 'デッキに名前を付け、フォーマットとスタイルを選びます。次に統率者またはカバーカードを選びます。';

  @override
  String get newDeckNameLabel => 'デッキ名';

  @override
  String get newDeckNameHint => '例: Raffine Tempo';

  @override
  String get newDeckNext => '次へ';

  @override
  String get formatPickerTitle => 'フォーマット';

  @override
  String get formatPickerSearchHint => 'フォーマットを検索…';

  @override
  String get formatPickerFieldLabel => 'フォーマット';

  @override
  String formatPickerMultiplayerLife(String life) {
    return 'マルチプレイヤー · 初期ライフ $life';
  }

  @override
  String formatPickerConstructedLife(String life) {
    return 'Constructed · 初期ライフ $life';
  }

  @override
  String get stylePickerTitle => 'デッキスタイル';

  @override
  String get stylePickerSearchHint => 'スタイルを検索…';

  @override
  String get stylePickerChoose => 'デッキスタイルを選ぶ';

  @override
  String get stylePickerFieldLabel => 'デッキスタイル';

  @override
  String get deckStyleBattlecruiser => 'バトルクルーザー';

  @override
  String get deckStyleBattlecruiserDesc => '大型クリーチャーと対面ダメージ中心。干渉は少なめの初心者向け卓向き。';

  @override
  String get deckStyleStax => 'スタックス';

  @override
  String get deckStyleStaxDesc => '相手を遅らせたり止めたりし、応答できない間に勝つ。';

  @override
  String get deckStyleSpellslinger => 'スペルズリンガー';

  @override
  String get deckStyleSpellslingerDesc => 'インスタントとソーサリー中心。ストーム系のコピーで一気に勝つ。';

  @override
  String get deckStyleControl => 'コントロール';

  @override
  String get deckStyleControlDesc => '除去と盤面管理でゲームを完全に掌握するまで耐える。';

  @override
  String get deckStylePillowfort => 'ピローフォート';

  @override
  String get deckStylePillowfortDesc => '攻撃コストを上げる税・抑止。別勝利条件も多い。';

  @override
  String get deckStyleVoltron => 'ヴォルトロン';

  @override
  String get deckStyleVoltronDesc => '装備とオーラを1体の守られた統率者に重ねる。';

  @override
  String get deckStyleGroupHug => 'グループハグ';

  @override
  String get deckStyleGroupHugDesc => '卓全体に小さなボーナスを配りつつ隠れた勝ち筋を仕込む。';

  @override
  String get deckStyleGroupSlug => 'グループスラッグ';

  @override
  String get deckStyleGroupSlugDesc => '全員に均等なライフ減少や捨て札を課して卓を削る。';

  @override
  String get deckStyleReanimator => 'リアニメイト';

  @override
  String get deckStyleReanimatorDesc => '墓地を溜めて巨大クリーチャーを安く戦場に出す。';

  @override
  String get deckStyleMill => 'ミル';

  @override
  String get deckStyleMillDesc => 'ライブラリーを追放や墓地に送り、ドロー負けで勝つ。';

  @override
  String get deckStyleStealTheft => '奪取';

  @override
  String get deckStyleStealTheftDesc => '相手のパーマネントを奪い、卓で最も強いものを使う。';

  @override
  String get deckStyleTribal => '部族';

  @override
  String get deckStyleTribalDesc => 'クリーチャータイプの連携とロード系の強化。';

  @override
  String get deckStyleSliver => 'スリヴァー';

  @override
  String get deckStyleSliverDesc => '他のスリヴァーを強化する巣のようなデッキ。';

  @override
  String get deckStyleTokens => 'トークン';

  @override
  String get deckStyleTokensDesc => '大量トークン生成とアンセムで一気に戦闘キル。';

  @override
  String get deckStyleAristocrats => 'アリストクラット';

  @override
  String get deckStyleAristocratsDesc => '生け贄ループと死亡・登場誘発、再帰で勝つ。';

  @override
  String get deckStyleWeenie => 'ウィーニー';

  @override
  String get deckStyleWeenieDesc => '小さなクリーチャーを多数展開し、互いに強化して広域攻撃。';

  @override
  String get deckStyleLands => '土地';

  @override
  String get deckStyleLandsDesc => 'ランドフォールなど土地中心のエンジン。干渉しにくい。';

  @override
  String get deckStyleSuperfriends => 'スーパーフレンズ';

  @override
  String get deckStyleSuperfriendsDesc => 'プレインズウォーカーを連鎖させ、忠誠度と起動を増やす。';

  @override
  String get deckStyleArtifact => 'アーティファクト';

  @override
  String get deckStyleArtifactDesc => 'アーティファクト連携と機械戦。青のサポートが多い。';

  @override
  String get deckStyleInfect => '感染';

  @override
  String get deckStyleInfectDesc => 'ライフの代わりに毒カウンター。少人数卓で強い。';

  @override
  String get deckStyleCounters => 'カウンター';

  @override
  String get deckStyleCountersDesc => '+1/+1カウンターの報酬とカウンター関連能力。';

  @override
  String get deckStyleChaos => 'カオス';

  @override
  String get deckStyleChaosDesc => 'ランダムや妨害効果で通常のプランをねじ曲げる。';

  @override
  String get deckStylePolitical => '政治';

  @override
  String get deckStylePoliticalDesc => '投票・交渉・卓政治で結果を誘導する。';

  @override
  String get profileOptionsTitle => 'プロフィール';

  @override
  String get profileOptionsEdit => 'プロフィールを編集';

  @override
  String get profileOptionsEditSubtitle => '名前またはアバターを変更';

  @override
  String get profileOptionsBackup => 'プロフィールをバックアップ';

  @override
  String get profileOptionsBackupSubtitle => 'プロフィール、デッキ、試合、フィードバックをこの端末に保存';

  @override
  String get profilePicTitle => 'プロフィール写真';

  @override
  String profilePicNoCards(String query) {
    return '「$query」のカードが見つかりません';
  }

  @override
  String get profilePicSearchFailed => '検索できません。接続を確認してもう一度。';

  @override
  String get profilePicPhotoFailed => 'その写真は使えません。別の画像を試してください。';

  @override
  String get profilePicCommander => 'Commander';

  @override
  String get profilePicDefault => 'デフォルト';

  @override
  String get profilePicRemove => '削除';

  @override
  String get profilePicUpload => '写真をアップロード';

  @override
  String get profilePicTake => '写真を撮る';

  @override
  String get profilePicOrSearch => 'または MTG カードアートを検索';

  @override
  String get profilePicSearchHint => 'プロフィール用に MTG カードを検索…';

  @override
  String get profilePicHelp => '写真をアップ、撮影、またはカード検索—そのアートがプロフィール写真になります。';

  @override
  String get ranksInfoTitle => 'ランクとレベル';

  @override
  String get ranksInfoBody => 'レベルは正確な進行度。ランクは現在のレベル帯の称号。メタルティアはそれらのランクをまとめます。';

  @override
  String ranksInfoLevelRange(int min, int max) {
    return 'Lv $min–$max';
  }

  @override
  String get statsPlayerBehaviour => 'プレイヤーの振る舞い';

  @override
  String get statsMostPlayed => '最多プレイ';

  @override
  String get statsNoDeckStatsYet => 'まだデッキ統計がありません。';

  @override
  String get statsToughRecord => '厳しい成績';

  @override
  String get statsNoLossesOnDeck => '保存デッキでの敗北はまだありません。';

  @override
  String get statsPlayerStats => 'プレイヤースタッツ';

  @override
  String get statsSingularUnit => 'スタッツ';

  @override
  String get statsPluralUnit => 'スタッツ';

  @override
  String get statsLeaningGood => '良い寄り';

  @override
  String get statsLeaningSalty => 'salty寄り';

  @override
  String get statsLeaningNeutral => '中立';

  @override
  String statsBehaviourA11y(String leaning) {
    return '振る舞いスペクトラム、$leaning';
  }

  @override
  String get statsRecord => '戦績';

  @override
  String get statsWinRate => '勝率';

  @override
  String statsRecordFooter(int wins, int losses, int games) {
    return '$wins勝–$losses敗  ·  $games試合';
  }

  @override
  String get statsWinStreak => '連勝';

  @override
  String get statsWinToStartStreak => '勝利して連勝を開始';

  @override
  String get statsPersonalBest => '自己ベスト';

  @override
  String statsBestStreak(int best) {
    return '最高: $best';
  }

  @override
  String get statsNoActiveStreak => '連勝なし';

  @override
  String get statsCurrent => '現在';

  @override
  String statsLevelShort(int level) {
    return 'Lv $level';
  }

  @override
  String get statsLevelProgress => 'レベル進行';

  @override
  String get statsLevelProgressA11y => 'レベル進行。すべてのランクを表示。';

  @override
  String get statsGood => '良い';

  @override
  String get statsNeutral => '中立';

  @override
  String get statsSalty => 'Salty';

  @override
  String get profileBackupSaveFailed => 'バックアップを保存できませんでした。';

  @override
  String get profileUsernameLabel => 'ユーザー名';

  @override
  String get profileUsernameHint => '例: The Archduke';

  @override
  String get profileUsernameRequired => 'ユーザー名を入力してください';

  @override
  String get profileUsernameTooShort => '2文字以上にしてください';

  @override
  String get profileSetupUsernameHint => '例: The Archduke';

  @override
  String carouselFilterTooltip(String label) {
    return 'フィルター: $label';
  }

  @override
  String carouselRecentMatchA11y(String result, String format) {
    return '最近の試合、$result、$format';
  }

  @override
  String get carouselCloseReturnsSummary => '閉じるで概要に戻ります';

  @override
  String get carouselShowMoreDetails => '詳細を表示するかカードをタップ';

  @override
  String get decksClearSearchTooltip => 'クリア';

  @override
  String get settingsDefaultFormatSheetTitle => 'デフォルトフォーマット';

  @override
  String get settingsDefaultStartingLifeSheetTitle => 'デフォルト初期ライフ';

  @override
  String settingsAboutVersionBeta(String version) {
    return 'Life Spark v$version · Beta';
  }

  @override
  String get settingsAboutByAuthor => 'by Federick Vidot';

  @override
  String get settingsAboutCardDataPoweredBy => 'カードデータ提供';

  @override
  String get settingsAboutScryfall => 'Scryfall';

  @override
  String get settingsAboutDisclaimer =>
      'Life Spark は Fan Content Policy に基づく非公式ファンコンテンツです。Wizards の承認・推奨はありません。使用素材の一部は Wizards of the Coast の所有物です。©Wizards of the Coast LLC.';

  @override
  String get feedbackLike => 'いいね';

  @override
  String get feedbackClearLike => 'いいねを解除';

  @override
  String get feedbackDislike => 'よくない';

  @override
  String get feedbackClearDislike => 'よくないを解除';

  @override
  String get feedbackSparkOfTheGame => '試合のスパーク';

  @override
  String get feedbackSparkHint => '任意 — 1人選ぶ';

  @override
  String get feedbackNoneOption => '— なし —';

  @override
  String tierBadgeLabel(String rank, int level) {
    return '$rank · Lv $level';
  }

  @override
  String tierBadgeA11y(String label) {
    return 'ランク $label。すべてのランクを表示。';
  }

  @override
  String get tierBronze => 'ブロンズ';

  @override
  String get tierSilver => 'シルバー';

  @override
  String get tierGold => 'ゴールド';

  @override
  String get tierPlatinum => 'プラチナ';

  @override
  String get tierDiamond => 'ダイヤモンド';

  @override
  String get rankApprentice => '見習い';

  @override
  String get rankNeophyte => '新参';

  @override
  String get rankAdept => '熟練';

  @override
  String get rankEvoker => '喚起術師';

  @override
  String get rankThaumaturge => '奇術師';

  @override
  String get rankEnchanter => '付与術師';

  @override
  String get rankSummoner => '召喚士';

  @override
  String get rankArcanist => '奥術師';

  @override
  String get rankMagus => 'マガス';

  @override
  String get rankWarWizard => '戦術魔導士';

  @override
  String get rankHighMagus => 'ハイマガス';

  @override
  String get rankSpellbinder => '呪文縛り';

  @override
  String get rankArchmage => '大魔導士';

  @override
  String get rankHighArchmage => 'ハイ大魔導士';

  @override
  String get rankPlanewright => 'プレーンライト';

  @override
  String get rankGrandArchmage => 'グランド大魔導士';

  @override
  String get rankVoidcaller => 'ヴォイドコーラー';

  @override
  String get rankArchwizard => 'アークウィザード';

  @override
  String get rankSpireLegend => 'スパイアの伝説';

  @override
  String get rankAscendantArchon => '昇天アルコン';

  @override
  String get deckTileWinRateAbbr => 'WR';

  @override
  String get deckTileWinsAbbr => '勝';

  @override
  String get deckTileLossesAbbr => '敗';

  @override
  String get deckTileGamesAbbr => '試合';

  @override
  String get brandLifeSpark => 'Life Spark';

  @override
  String get hostTogglePlanechase => 'Planechase';

  @override
  String get hostToggleArchenemy => 'Archenemy';

  @override
  String get hostToggleBounty => 'Bounty';

  @override
  String get lookupClearTooltip => 'クリア';

  @override
  String phaseNavCurrentA11y(String phase) {
    return '現在のフェイズ、$phase';
  }

  @override
  String cmdDmgThreatHelp(int ko) {
    return '各統率者が与えたダメージ — $koで敗北。';
  }

  @override
  String get cmdDmgEmptyPod => '他のプレイヤーが参加すると、ここに対戦相手が表示されます。';

  @override
  String get statusOut => '脱落';

  @override
  String infoBarAlly(String name) {
    return '同盟 · $name';
  }

  @override
  String get infoBarAllySecret => '秘密';

  @override
  String get gamePlayerDataUnavailable => 'プレイヤーデータを読み込めません';

  @override
  String get startupErrorTitle => '起動エラー';

  @override
  String get startupStackTrace => 'スタックトレース:';

  @override
  String get paletteViolet => 'バイオレット';

  @override
  String get paletteCrimson => 'クリムゾン';

  @override
  String get paletteSlate => 'スレート';

  @override
  String get paletteForest => 'フォレスト';

  @override
  String get paletteObsidian => 'オブシディアン';

  @override
  String get paletteFog => 'フォグ';

  @override
  String networkCannotReachHost(String error) {
    return 'ホストに接続できません: $error';
  }

  @override
  String get backupFileTypeLabel => 'Life Sparkバックアップ';

  @override
  String get backupNotValidFile => 'Life Sparkのバックアップファイルではありません。';

  @override
  String get backupNotValidJson => 'バックアップファイルが有効なJSONではありません。';

  @override
  String get backupCouldNotRead => '選択したバックアップファイルを読み取れませんでした。';

  @override
  String logLifeChange(String name, String delta) {
    return '$name: ライフ $delta';
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
    return '$name があなたのライフを変更 $delta';
  }

  @override
  String logCounterChangedYours(String name, String counter, String delta) {
    return '$name があなたの$counterを変更 $delta';
  }

  @override
  String logEndsTurn(String name) {
    return '$name がターン終了';
  }

  @override
  String logCmdDmgDealtYou(String name, String delta) {
    return '$name があなたに統率者ダメージ $delta';
  }

  @override
  String logCmdDmgYouDealt(String name, String delta) {
    return 'あなたが $name に統率者ダメージ $delta';
  }

  @override
  String logCmdDmgOther(String from, String to, String delta) {
    return '$from → $to: 統率者ダメージ $delta';
  }

  @override
  String get logTurnOrderUpdated => 'ホストがターン順を更新';

  @override
  String get logProliferate => '増殖: 全プレイヤー';

  @override
  String logAllianceRevealed(String a, String b) {
    return '同盟を公開: $a と $b';
  }

  @override
  String logAllianceBetrayal(String a, String b) {
    return '同盟決裂 — 裏切り: $a と $b';
  }

  @override
  String get logAllianceBroken => '同盟決裂';

  @override
  String logAllianceFormed(String a, String b, String duration) {
    return '秘密同盟成立: $a と $b（$duration）';
  }

  @override
  String logPlayerLeft(String name) {
    return '$name がゲームを退出';
  }

  @override
  String logRolled(String name, String result) {
    return '$name が $result を出した';
  }

  @override
  String logFlipped(String name, String result) {
    return '$name が $result';
  }

  @override
  String logStackAdded(String name, String item) {
    return '$name が「$item」を追加';
  }

  @override
  String logStackAddedResponse(String name, String item) {
    return '$name が「$item」を追加（対応）';
  }

  @override
  String logStackRenamed(String name, String item) {
    return '$name がスタック項目を「$item」に改名';
  }

  @override
  String logStackStatus(String name, String item, String status) {
    return '$name の「$item」が$status';
  }

  @override
  String get logClearedStack => 'スタックをクリア';

  @override
  String get logCounterPoison => '毒';

  @override
  String get logCounterEnergy => 'エネルギー';

  @override
  String get logCounterExperience => '経験';

  @override
  String get logCounterRad => '放射線';

  @override
  String get logCounterBlood => '血';

  @override
  String get logCounterClue => '手がかり';

  @override
  String get logCounterMap => '地図';

  @override
  String get logCounterTreasure => '宝物';

  @override
  String get logCounterDevotion => '信心';

  @override
  String get logCounterCreatures => 'クリーチャー';

  @override
  String get logCounterEnchantments => 'エンチャント';

  @override
  String get logCounterArtifacts => 'アーティファクト';

  @override
  String get logCounterGyCreatures => '墓地のクリーチャー';

  @override
  String get logCounterExile => '追放';

  @override
  String get logStackStatusFizzled => '不発';

  @override
  String get logStackStatusCountered => '打ち消し';

  @override
  String get logStackStatusResolved => '解決';

  @override
  String get logStackStatusReactivated => '再稼働';

  @override
  String get logDurationEndOfTurn => 'ターン終了まで';

  @override
  String get logDurationEndOfRound => 'ラウンド終了まで';

  @override
  String get logDurationUntilBroken => '破棄まで';

  @override
  String get logHeads => '表';

  @override
  String get logTails => '裏';
}
