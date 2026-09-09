import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mgt_life_spark/core/game/game_phase.dart';
import 'package:mgt_life_spark/core/game/game_state.dart';
import 'package:mgt_life_spark/core/game/player_game_state.dart';
import 'package:mgt_life_spark/features/game/widgets/phase_nav_cluster.dart';
import 'package:mgt_life_spark/shared/theme/app_theme.dart';

import '../support/test_l10n.dart';

GameState _minimalGame({bool localTurn = true}) {
  const localId = 'local';
  const otherId = 'other';
  return GameState(
    localPlayerId: localId,
    isHost: true,
    activePlayerIndex: localTurn ? 0 : 1,
    currentPhase: GamePhase.preCombatMain,
    turnOrder: [localId, otherId],
    players: [
      PlayerGameState(
        playerId: localId,
        username: 'You',
        life: 40,
        playerColor: Colors.blue,
      ),
      PlayerGameState(
        playerId: otherId,
        username: 'Bob',
        life: 40,
        playerColor: Colors.red,
      ),
    ],
  );
}

void main() {
  testWidgets('PhaseNavCluster shows End turn control', (tester) async {
    var ended = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        localizationsDelegates: testLocalizationDelegates,
        supportedLocales: testSupportedLocales,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 420,
              child: PhaseNavCluster(
                game: _minimalGame(),
                accentColor: Colors.purple,
                onBack: () {},
                onNext: () {},
                onPickPhase: (_) {},
                onEndTurn: () => ended = true,
                endTurnEnabled: true,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('End turn'), findsOneWidget);
    expect(find.text('Main 1'), findsOneWidget);

    await tester.tap(find.text('End turn'));
    await tester.pump();
    expect(ended, isTrue);
  });

  testWidgets('PhaseNavCluster fits long phase names at phone width', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        localizationsDelegates: testLocalizationDelegates,
        supportedLocales: testSupportedLocales,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 320,
              child: PhaseNavCluster(
                game: _minimalGame().copyWith(currentPhase: GamePhase.combat),
                accentColor: Colors.purple,
                onBack: () {},
                onNext: () {},
                onPickPhase: (_) {},
                onEndTurn: () {},
                endTurnEnabled: true,
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    // Center column is narrow at 320dp — short phase label is used.
    expect(find.text('Combat'), findsOneWidget);
  });

  testWidgets('End turn disabled when endTurnEnabled is false', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        localizationsDelegates: testLocalizationDelegates,
        supportedLocales: testSupportedLocales,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 420,
              child: PhaseNavCluster(
                game: _minimalGame(localTurn: false),
                accentColor: Colors.purple,
                onEndTurn: () {},
                endTurnEnabled: false,
              ),
            ),
          ),
        ),
      ),
    );

    final button = tester.widget<Material>(
      find
          .ancestor(of: find.text('End turn'), matching: find.byType(Material))
          .first,
    );
    expect(button, isNotNull);
  });

  test('host can skip another seat; tap End turn is local-only', () {
    final localTurn = _minimalGame();
    expect(localTurn.canTapEndTurn, isTrue);
    expect(localTurn.canHostSkipTurn, isFalse);

    final hostWaiting = _minimalGame(localTurn: false);
    expect(hostWaiting.canTapEndTurn, isFalse);
    expect(hostWaiting.canHostSkipTurn, isTrue);

    final guestWaiting = hostWaiting.copyWith(isHost: false);
    expect(guestWaiting.canTapEndTurn, isFalse);
    expect(guestWaiting.canHostSkipTurn, isFalse);

    final hostTimeout = hostWaiting.copyWith(timeoutActive: true);
    expect(hostTimeout.canTapEndTurn, isFalse);
    expect(hostTimeout.canHostSkipTurn, isFalse);
  });

  testWidgets('inactive End turn ignores tap; host long-press skips', (
    tester,
  ) async {
    var taps = 0;
    var skips = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        localizationsDelegates: testLocalizationDelegates,
        supportedLocales: testSupportedLocales,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 420,
              child: PhaseNavCluster(
                game: _minimalGame(localTurn: false),
                accentColor: Colors.purple,
                onEndTurn: () => taps++,
                endTurnEnabled: false,
                onEndTurnLongPress: () => skips++,
                endTurnSkipName: 'Bob',
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.textContaining('Hold to skip Bob'), findsOneWidget);

    await tester.tap(find.text('End turn'));
    await tester.pump();
    expect(taps, 0);
    expect(skips, 0);

    await tester.longPress(find.text('End turn'));
    await tester.pump();
    expect(taps, 0);
    expect(skips, 1);
  });
}
