import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mgt_life_spark/features/game_lobby/game_lobby_screen.dart';
import 'package:mgt_life_spark/shared/theme/app_theme.dart';

import '../support/test_l10n.dart';

void main() {
  testWidgets('game lobby entry shows host and join actions', (tester) async {
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
    expect(
      find.text('Create a session — others join you'),
      findsOneWidget,
    );
    expect(find.text('Scan for a nearby host'), findsOneWidget);
  });
}
