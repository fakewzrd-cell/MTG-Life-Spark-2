import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mgt_life_spark/core/models/match_record.dart';
import 'package:mgt_life_spark/core/persistence/providers.dart';
import 'package:mgt_life_spark/features/profile/profile_carousel_sections.dart';
import 'package:mgt_life_spark/ui/theme/app_color_tokens.dart';

import 'support/game_widget_harness.dart';
import 'support/test_deck_repository.dart';

MatchRecord _matchWithLongNames() {
  final snaps = [
    const MatchParticipantSnapshot(
      playerId: 'alice',
      username: 'alice',
      commanderName: 'Atraxa, Praetors\' Voice of the Grand Conjunction',
      finalLife: 24,
      isWinner: true,
      placementRank: 1,
    ),
    const MatchParticipantSnapshot(
      playerId: 'bob',
      username: 'bob',
      commanderName: 'The Ur-Dragon, Scion of the Storm Herd Eternal',
      finalLife: -3,
      isWinner: false,
      placementRank: 2,
    ),
  ];
  return MatchRecord(
    matchId: 'm-standings',
    date: DateTime(2026, 7, 28, 18),
    commanderName: snaps.first.commanderName!,
    opponentNames: const ['bob'],
    result: 'win',
    eliminationReason: 'survived',
    format: 'Commander',
    durationMinutes: 72,
    durationSeconds: 72 * 60 + 15,
    startingLifeTotal: 40,
    playerCount: 2,
    participantsJson: jsonEncode(snaps.map((s) => s.toJson()).toList()),
    podNameSnapshot: 'Friday Night',
  );
}

MatchRecord _matchWithManyPlayers() {
  final snaps = [
    for (var i = 0; i < 5; i++)
      MatchParticipantSnapshot(
        playerId: 'p$i',
        username: 'player_$i',
        commanderName: 'Commander Name That Is Quite Long Number $i',
        finalLife: 40 - i * 12,
        isWinner: i == 0,
        placementRank: i + 1,
      ),
  ];
  return MatchRecord(
    matchId: 'm-many',
    date: DateTime(2026, 7, 20),
    commanderName: snaps.first.commanderName!,
    opponentNames: snaps.skip(1).map((s) => s.username).toList(),
    result: 'win',
    eliminationReason: 'survived',
    format: 'Commander',
    durationMinutes: 90,
    durationSeconds: 90 * 60,
    startingLifeTotal: 40,
    playerCount: 5,
    participantsJson: jsonEncode(snaps.map((s) => s.toJson()).toList()),
  );
}

Widget _harness(List<MatchRecord> matches) {
  final size = profileCarouselCardSize();
  // Title row + gap + card; leave headroom so module Column is not crushed.
  final moduleH = size.height + 72;
  return wrapGameWidget(
    game: harnessGame(localId: 'alice'),
    extraOverrides: [
      deckRepositoryProvider.overrideWithValue(TestDeckRepository()),
    ],
    child: Builder(
      builder: (context) {
        final colors = AppColorTokens.of(context);
        return Scaffold(
          body: SizedBox(
            height: moduleH,
            child: ProfileRecentGamesModule(
              matches: matches,
              colors: colors,
            ),
          ),
        );
      },
    ),
  );
}

Future<void> _pumpSettleBrief(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

void main() {
  testWidgets('expanded recent match keeps life visible beside long names',
      (tester) async {
    await tester.pumpWidget(_harness([_matchWithLongNames()]));
    await _pumpSettleBrief(tester);

    expect(find.text('Show more'), findsOneWidget);
    await tester.tap(find.text('Show more'));
    await _pumpSettleBrief(tester);

    expect(find.text('Standings'), findsOneWidget);
    expect(find.textContaining('1:12:15'), findsOneWidget);
    expect(find.textContaining('2 players'), findsWidgets);
    expect(find.textContaining('Friday Night'), findsOneWidget);

    // Life is its own widget — must remain findable even with long titles.
    expect(find.text('24'), findsOneWidget);
    expect(find.text('-3'), findsOneWidget);
    expect(find.textContaining('Atraxa'), findsOneWidget);
    expect(find.textContaining('Ur-Dragon'), findsOneWidget);

    // Legacy chip-style combined string must not appear.
    expect(find.textContaining('· 24 life'), findsNothing);

    await tester.tap(find.byTooltip('Close'));
    await _pumpSettleBrief(tester);
    expect(find.text('Show more'), findsOneWidget);
    expect(find.text('Standings'), findsNothing);
  });

  testWidgets('expanded recent match without snapshots shows empty standings',
      (tester) async {
    final match = MatchRecord(
      matchId: 'm-legacy',
      date: DateTime(2026, 7, 1),
      commanderName: 'Bolt',
      opponentNames: const ['carol'],
      result: 'loss',
      eliminationReason: 'life',
      format: 'Standard',
      durationMinutes: 20,
      startingLifeTotal: 20,
      playerCount: 2,
    );

    await tester.pumpWidget(_harness([match]));
    await _pumpSettleBrief(tester);
    await tester.tap(find.text('Show more'));
    await _pumpSettleBrief(tester);

    expect(
      find.text('No player details saved for this match.'),
      findsOneWidget,
    );
  });

  testWidgets('expanded 5-player standings keep life totals visible',
      (tester) async {
    await tester.pumpWidget(_harness([_matchWithManyPlayers()]));
    await _pumpSettleBrief(tester);
    await tester.tap(find.text('Show more'));
    await _pumpSettleBrief(tester);

    expect(find.text('Standings'), findsOneWidget);
    expect(find.text('40'), findsOneWidget);
    // Last place may need a scroll; drag the standings scroller.
    final lastLife = find.text('-8');
    if (lastLife.evaluate().isEmpty) {
      await tester.drag(find.text('Standings'), const Offset(0, -160));
      await _pumpSettleBrief(tester);
    }
    expect(find.text('-8'), findsOneWidget);
  });
}
