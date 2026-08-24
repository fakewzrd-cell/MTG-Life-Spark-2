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
import '../support/test_l10n.dart';

void main() {
  testWidgets('game lobby shows Host Game and Join Game', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        localizationsDelegates: testLocalizationDelegates,
        supportedLocales: testSupportedLocales,
        home: const GameLobbyScreen(),
      ),
    );

    expect(find.text('Host Game'), findsOneWidget);
    expect(find.text('Join Game'), findsOneWidget);
  });

  testWidgets('forfeit dialog shows like/dislike and star of the game',
      (tester) async {
    final game = harnessGame(localId: 'alice');

    await tester.pumpWidget(
      wrapGameWidget(
        game: game,
        child: Consumer(
          builder: (context, ref, _) => Scaffold(
            body: TextButton(
              onPressed: () =>
                  showGameForfeitFlow(context, ref, game.localPlayerId),
              child: const Text('Open forfeit'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open forfeit'));
    await tester.pumpAndSettle();

    expect(find.text('Forfeit?'), findsOneWidget);
    expect(find.text('Rate opponents'), findsOneWidget);
    expect(find.text('Spark of the game'), findsOneWidget);
    expect(find.text('MVP'), findsNothing);
    expect(find.text('Team Player'), findsNothing);
    expect(find.text('Underdog'), findsNothing);
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
    expect(find.text('Spark of the game'), findsOneWidget);
    expect(find.text('MVP'), findsNothing);
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
