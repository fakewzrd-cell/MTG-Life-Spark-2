import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mgt_life_spark/core/game/game_providers.dart';
import 'package:mgt_life_spark/core/models/game_feedback.dart';
import 'package:mgt_life_spark/features/end_game/end_game_screen.dart';
import 'package:mgt_life_spark/features/game/widgets/game_bottom_bar.dart';
import 'package:mgt_life_spark/features/game_lobby/game_lobby_screen.dart';
import 'package:mgt_life_spark/shared/theme/app_theme.dart';
import '../support/game_widget_harness.dart';

void main() {
  testWidgets('game lobby shows Host Game and Join Game', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: const GameLobbyScreen(),
      ),
    );

    expect(find.text('Host Game'), findsOneWidget);
    expect(find.text('Join Game'), findsOneWidget);
  });

  testWidgets('forfeit opens dialog with rate opponents and Forfeit button',
      (tester) async {
    final game = harnessGame(localId: 'alice');
    final local = game.localPlayer!;

    await tester.pumpWidget(
      wrapGameWidget(
        game: game,
        child: Scaffold(
          body: GameBottomBar(
            game: game,
            local: local,
            onToggleOverview: () {},
          ),
        ),
      ),
    );

    await tester.tap(find.bySemanticsLabel('Forfeit'));
    await tester.pumpAndSettle();

    expect(find.text('Forfeit?'), findsOneWidget);
    expect(find.text('Rate opponents'), findsOneWidget);
    expect(
      find.widgetWithText(FilledButton, 'Forfeit'),
      findsOneWidget,
    );
  });

  testWidgets('end game screen shows standings after match saves',
      (tester) async {
    final game = harnessGame(
      localId: 'bob',
      gameOver: true,
      winnerId: 'alice',
      players: [
        harnessPlayer(id: 'alice'),
        harnessPlayer(id: 'bob', eliminated: true),
      ],
    );

    await tester.pumpWidget(
      wrapGameWidget(
        game: game,
        child: const EndGameScreen(),
      ),
    );

    await tester.pump();
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.text('Final Standings'), findsOneWidget);
    expect(find.text('Rate Your Opponents'), findsOneWidget);
    expect(find.text('Thanks! Your feedback has been recorded.'), findsNothing);
  });

  testWidgets('end game shows thanks when forfeit included feedback',
      (tester) async {
    final game = harnessGame(
      localId: 'bob',
      gameOver: true,
      winnerId: 'alice',
    );

    await tester.pumpWidget(
      wrapGameWidget(
        game: game,
        extraOverrides: [
          pendingFeedbackProvider.overrideWith(
            (ref) => const PendingFeedbackData(likePlayerIds: ['alice']),
          ),
        ],
        child: const EndGameScreen(),
      ),
    );

    await tester.pump();
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(
      find.text('Thanks! Your feedback has been recorded.'),
      findsOneWidget,
    );
    expect(find.text('Rate Your Opponents'), findsNothing);
  });
}
