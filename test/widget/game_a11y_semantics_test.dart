import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mgt_life_spark/core/game/game_session_events.dart';
import 'package:mgt_life_spark/core/game/game_state.dart';
import 'package:mgt_life_spark/core/game/player_game_state.dart';
import 'package:mgt_life_spark/features/game/widgets/game_first_player_roll_overlay.dart';
import 'package:mgt_life_spark/features/game/widgets/game_hud_header.dart';
import 'package:mgt_life_spark/features/game/widgets/game_life_announcer.dart';
import 'package:mgt_life_spark/shared/theme/app_theme.dart';

PlayerGameState _player(String id, {String? username}) => PlayerGameState(
      playerId: id,
      username: username ?? id,
      playerColor: Colors.blue,
      life: 40,
    );

GameState _rollGame({
  required String localId,
  Map<String, int> rolls = const {},
}) {
  final players = [
    _player('alice'),
    _player('bob', username: 'Bob'),
  ];
  return GameState(
    players: players,
    turnOrder: players.map((p) => p.playerId).toList(),
    localPlayerId: localId,
    isHost: true,
    awaitingFirstPlayerRoll: true,
    firstPlayerRolls: rolls,
    gameStartTime: DateTime(2026, 1, 1),
  );
}

void main() {
  testWidgets('first-player die exposes stable button semantics', (tester) async {
    final handle = tester.ensureSemantics();
    try {
      final game = _rollGame(localId: 'alice');
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark(),
          home: Scaffold(
            body: GameFirstPlayerRollOverlay(
              game: game,
              local: game.localPlayer!,
              onRoll: (_) {},
            ),
          ),
        ),
      );

      expect(
        tester.getSemantics(find.bySemanticsLabel('Roll die')),
        matchesSemantics(
          label: 'Roll die',
          value: 'Not rolled',
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
        ),
      );
      expect(
        find.bySemanticsLabel('alice, you, waiting to roll'),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel('Bob, waiting to roll'),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel('0 of 2 players have rolled'),
        findsOneWidget,
      );
    } finally {
      handle.dispose();
    }
  });

  testWidgets('HUD turn label uses a live region', (tester) async {
    final handle = tester.ensureSemantics();
    try {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark(),
          home: Scaffold(
            body: GameHudHeader(
              selectedTabIndex: 0,
              onTabSelected: (_) {},
              accentColor: Colors.purple,
              turnLabel: 'Your turn',
              tightVertical: false,
              isLocalPlayersTurn: true,
            ),
          ),
        ),
      );

      expect(
        tester.getSemantics(find.bySemanticsLabel('Your turn')),
        matchesSemantics(
          label: 'Your turn',
          isLiveRegion: true,
        ),
      );
    } finally {
      handle.dispose();
    }
  });

  testWidgets(
      'life announcer debounces local changes and speaks remote immediately',
      (tester) async {
    final handle = tester.ensureSemantics();
    try {
      late ProviderContainer container;

      await tester.pumpWidget(
        ProviderScope(
          child: Builder(
            builder: (context) {
              container = ProviderScope.containerOf(context);
              return MaterialApp(
                theme: AppTheme.dark(),
                home: const Scaffold(
                  body: GameLifeAnnouncer(enabled: true),
                ),
              );
            },
          ),
        ),
      );

      container.read(localLifeChangeProvider.notifier).state =
          const LifeChangeAnnouncement(
        id: 1,
        total: 39,
        delta: -1,
        source: LifeChangeSource.local,
      );
      await tester.pump();
      expect(find.bySemanticsLabel('39 life'), findsNothing);

      await tester.pump(const Duration(milliseconds: 600));
      expect(find.bySemanticsLabel('39 life'), findsOneWidget);

      container.read(localLifeChangeProvider.notifier).state =
          const LifeChangeAnnouncement(
        id: 2,
        total: 35,
        delta: -4,
        source: LifeChangeSource.remote,
        actorUsername: 'Bob',
      );
      await tester.pump();
      expect(
        find.bySemanticsLabel('Bob changed your life minus 4, 35 life'),
        findsOneWidget,
      );
    } finally {
      handle.dispose();
    }
  });
}
