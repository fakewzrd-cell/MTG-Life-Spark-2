import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mgt_life_spark/core/game/game_providers.dart';
import 'package:mgt_life_spark/core/game/game_state.dart';
import 'package:mgt_life_spark/core/game/player_game_state.dart';
import 'package:mgt_life_spark/features/game/widgets/game_overview_view.dart';

import '../support/game_widget_harness.dart';

Future<void> _pumpOverview(
  WidgetTester tester, {
  required GameState game,
}) async {
  await tester.pumpWidget(
    wrapGameWidget(
      game: game,
      child: Scaffold(
        body: Consumer(
          builder: (context, ref, _) => GameOverviewView(
            game: ref.watch(gameProvider),
            onClose: () {},
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  testWidgets('overview marks active player card as Now playing once',
      (tester) async {
    final game = harnessGame(localId: 'alice').copyWith(activePlayerIndex: 1);

    await _pumpOverview(tester, game: game);

    expect(find.text('NOW PLAYING'), findsOneWidget);
    expect(find.text('bob'), findsWidgets);
  });

  testWidgets('local active player also gets Now playing on their card',
      (tester) async {
    final game = harnessGame(localId: 'alice').copyWith(activePlayerIndex: 0);

    await _pumpOverview(tester, game: game);

    expect(find.text('NOW PLAYING'), findsOneWidget);
    expect(find.textContaining('· you'), findsWidgets);
  });

  testWidgets('eliminated active player does not show Now playing',
      (tester) async {
    final game = harnessGame(
      localId: 'alice',
      players: [
        harnessPlayer(id: 'alice', eliminated: true),
        harnessPlayer(id: 'bob'),
      ],
    ).copyWith(activePlayerIndex: 0);

    await _pumpOverview(tester, game: game);

    expect(find.text('NOW PLAYING'), findsNothing);
  });

  testWidgets('Now playing moves when active player index changes',
      (tester) async {
    final game = harnessGame(localId: 'alice').copyWith(
      activePlayerIndex: 0,
      isHost: true,
    );

    await _pumpOverview(tester, game: game);
    expect(find.text('NOW PLAYING'), findsOneWidget);

    final container = TesterProviderScope.containerOf(
      tester.element(find.byType(GameOverviewView)),
    );
    container.read(gameProvider.notifier).setGameStateForTest(
          game.copyWith(activePlayerIndex: 1),
        );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('NOW PLAYING'), findsOneWidget);
    // Active is bob — still a single label in the list (no spotlight band).
    expect(find.text('NOW PLAYING'), findsOneWidget);
  });

  testWidgets('four-player overview keeps a single Now playing label',
      (tester) async {
    final players = <PlayerGameState>[
      harnessPlayer(id: 'p0'),
      harnessPlayer(id: 'p1'),
      harnessPlayer(id: 'p2'),
      harnessPlayer(id: 'p3'),
    ];
    final game = GameState(
      players: players,
      turnOrder: players.map((p) => p.playerId).toList(),
      localPlayerId: 'p0',
      activePlayerIndex: 2,
      gameStartTime: DateTime(2026, 1, 1),
      autoKoFromCommanderDamage: true,
      commanderDamageReducesLife: true,
    );

    await _pumpOverview(tester, game: game);

    expect(find.text('NOW PLAYING'), findsOneWidget);
    expect(find.text('p2'), findsWidgets);
  });
}

/// Tiny helper — ProviderScope from flutter_riverpod doesn't expose container
/// on Element; use UncontrolledProviderScope ancestor.
class TesterProviderScope {
  static ProviderContainer containerOf(Element element) {
    return ProviderScope.containerOf(element);
  }
}
