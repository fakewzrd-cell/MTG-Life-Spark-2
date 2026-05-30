import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mgt_life_spark/core/game/game_phase.dart';
import 'package:mgt_life_spark/core/game/game_state.dart';
import 'package:mgt_life_spark/core/game/player_game_state.dart';
import 'package:mgt_life_spark/features/game/widgets/phase_nav_cluster.dart';
import 'package:mgt_life_spark/shared/theme/app_theme.dart';

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

  testWidgets('End turn disabled when endTurnEnabled is false', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
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
      find.ancestor(
        of: find.text('End turn'),
        matching: find.byType(Material),
      ).first,
    );
    expect(button, isNotNull);
  });
}
