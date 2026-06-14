import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mgt_life_spark/core/game/game_format.dart';
import 'package:mgt_life_spark/core/models/player_deck.dart';
import 'package:mgt_life_spark/core/persistence/providers.dart';
import 'package:mgt_life_spark/features/profile/deck_options_sheet.dart';
import 'package:mgt_life_spark/features/profile/decks_manage_screen.dart';
import 'package:mgt_life_spark/features/settings/settings_screen.dart';
import 'package:mgt_life_spark/shared/theme/app_theme.dart';
import 'package:mgt_life_spark/ui/theme/app_color_tokens.dart';

import 'support/test_deck_repository.dart';
import 'support/test_settings_repository.dart';

PlayerDeck _testDeck({String name = 'Test Deck'}) => PlayerDeck(
      id: 'deck-1',
      displayName: name,
      commanderName: 'Atraxa, Praetors\' Voice',
      format: GameFormat.commander.name,
      deckStyleId: 'control',
    );

void main() {
  testWidgets('decks manage shows empty-state copy when no decks', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          deckRepositoryProvider.overrideWithValue(TestDeckRepository()),
        ],
        child: MaterialApp(
          theme: AppTheme.dark(),
          home: const DecksManageScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Build your deck library'), findsOneWidget);
    expect(find.text('Add deck'), findsOneWidget);
  });

  testWidgets('deck options sheet lists actions', (tester) async {
    final deck = _testDeck();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => showDeckOptionsSheet(context, deck),
                child: const Text('Open options'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open options'));
    await tester.pumpAndSettle();

    expect(find.text('Deck style: Control'), findsOneWidget);
    expect(find.text('Edit commanders'), findsOneWidget);
    expect(find.text('Rename'), findsOneWidget);
    expect(find.text('Delete deck'), findsOneWidget);
  });

  testWidgets('settings default format opens picker dialog', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(
            TestSettingsRepository(),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.dark(),
          home: const SettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Default Format'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(Dialog),
        matching: find.text('Standard'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(Dialog),
        matching: find.text('Commander'),
      ),
      findsOneWidget,
    );

    final dialogContext = tester.element(
      find.descendant(
        of: find.byType(Dialog),
        matching: find.text('Standard'),
      ),
    );
    final colors = AppColorTokens.of(dialogContext);
    expect(colors.textPrimary, isNotNull);
  });

  testWidgets('settings screen renders gameplay section', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(
            TestSettingsRepository(),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.dark(),
          home: const SettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Default Format'), findsOneWidget);
    expect(find.text('Keep display awake'), findsOneWidget);
  });
}
