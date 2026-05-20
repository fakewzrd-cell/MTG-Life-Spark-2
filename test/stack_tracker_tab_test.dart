import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mgt_life_spark/core/game/game_providers.dart';
import 'package:mgt_life_spark/core/game/scryfall_service.dart';
import 'package:mgt_life_spark/core/game/game_state.dart';
import 'package:mgt_life_spark/core/game/game_state_notifier.dart';
import 'package:mgt_life_spark/core/game/player_game_state.dart';
import 'package:mgt_life_spark/core/game/stack_item.dart';
import 'package:mgt_life_spark/features/game/widgets/stack_tracker_tab.dart';
import 'package:mgt_life_spark/shared/theme/app_theme.dart';
// AppTheme.dark() includes AppColorTokens for ManaCostPips on stack tiles.

GameState _gameWithLocalPlayer() {
  const localId = 'local';
  return GameState(
    players: [
      PlayerGameState(
        playerId: localId,
        username: 'You',
        playerColor: AppTheme.accent,
        life: 40,
        commanderName: 'Atraxa',
      ),
    ],
    turnOrder: [localId],
    localPlayerId: localId,
    isHost: true,
  );
}

class _FakeScryfallService extends ScryfallService {
  _FakeScryfallService() : super(client: null);

  static const _counterspell = ScryfallCard(
    name: 'Counterspell',
    manaCost: '{U}{U}',
    typeLine: 'Instant',
    oracleText: 'Counter target spell.',
  );

  @override
  Future<List<ScryfallCard>> searchCards(String query) async {
    if (query.toLowerCase().contains('counter')) {
      return [_counterspell];
    }
    return [];
  }

  @override
  Future<ScryfallCard?> fetchCardByName(String name) async {
    if (name == 'Counterspell') return _counterspell;
    return null;
  }

  @override
  Future<ScryfallCard?> fetchCardFuzzy(String name) async {
    if (name.toLowerCase().contains('counter')) return _counterspell;
    return null;
  }
}

void main() {
  testWidgets('StackTrackerTab renders after addStackItem without layout errors',
      (tester) async {
    late GameStateNotifier notifier;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          gameProvider.overrideWith((ref) {
            notifier = GameStateNotifier(ref);
            notifier.state = _gameWithLocalPlayer();
            return notifier;
          }),
        ],
        child: MaterialApp(
          theme: AppTheme.dark(),
          home: Scaffold(
            body: Consumer(
              builder: (context, ref, _) {
                final game = ref.watch(gameProvider);
                return StackTrackerTab(game: game);
              },
            ),
          ),
        ),
      ),
    );

    await tester.pump();

    notifier.addStackItem(name: 'Lightning Bolt');
    await tester.pump();

    expect(find.text('Lightning Bolt'), findsOneWidget);
    expect(find.text('Resolves next'), findsOneWidget);

    notifier.addStackItem(name: 'Counterspell', parentId: notifier.state.stackItems.first.id);
    await tester.pump();

    expect(find.text('Counterspell'), findsOneWidget);
    expect(find.text('In response to Lightning Bolt'), findsOneWidget);

    notifier.addStackItem(name: 'Growth');
    await tester.pumpAndSettle();

    expect(find.text('Growth'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('StackTrackerTab empty then first item via notifier', (tester) async {
    late GameStateNotifier notifier;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          gameProvider.overrideWith((ref) {
            notifier = GameStateNotifier(ref);
            notifier.state = _gameWithLocalPlayer();
            return notifier;
          }),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Consumer(
              builder: (context, ref, _) {
                return StackTrackerTab(game: ref.watch(gameProvider));
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text('Nothing on the stack'), findsOneWidget);

    notifier.addStackItem(name: 'Shock');
    await tester.pumpAndSettle();

    expect(find.text('Nothing on the stack'), findsNothing);
    expect(find.text('Shock'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('add via dialog does not dispose controller during route pop',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          scryfallServiceProvider.overrideWithValue(_FakeScryfallService()),
          gameProvider.overrideWith((ref) {
            final n = GameStateNotifier(ref);
            n.state = _gameWithLocalPlayer();
            return n;
          }),
        ],
        child: MaterialApp(
          theme: AppTheme.dark(),
          home: Scaffold(
            body: Consumer(
              builder: (context, ref, _) {
                return StackTrackerTab(game: ref.watch(gameProvider));
              },
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Add spell or ability'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Counterspell');
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.widgetWithText(FilledButton, 'Add'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    expect(find.text('Counterspell'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
