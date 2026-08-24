import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mgt_life_spark/features/profile/profile_options_sheet.dart';
import 'package:mgt_life_spark/ui/theme/app_theme.dart';
import 'package:mgt_life_spark/ui/tokens/app_color_palettes.dart';
import 'package:mgt_life_spark/ui/tokens/color_tokens.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    ColorTokens.applyScheme(AppColorSchemeId.violet);
  });

  Future<void> pumpHost(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () => showProfileOptionsSheet(context),
                  child: const Text('Open'),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  testWidgets('profile options sheet lists edit and backup actions',
      (tester) async {
    await pumpHost(tester);
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Edit profile'), findsOneWidget);
    expect(find.text('Back up profile'), findsOneWidget);
    expect(find.text('Change your name or avatar'), findsOneWidget);
    expect(find.text('Save profile, decks, games, and feedback on this phone'),
        findsOneWidget);
  });

  testWidgets('choosing Edit profile returns editProfile', (tester) async {
    ProfileSheetAction? result;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () async {
                    result = await showProfileOptionsSheet(context);
                  },
                  child: const Text('Open'),
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit profile'));
    await tester.pumpAndSettle();

    expect(result, ProfileSheetAction.editProfile);
  });

  testWidgets('choosing Back up profile returns backupProfile', (tester) async {
    ProfileSheetAction? result;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () async {
                    result = await showProfileOptionsSheet(context);
                  },
                  child: const Text('Open'),
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Back up profile'));
    await tester.pumpAndSettle();

    expect(result, ProfileSheetAction.backupProfile);
  });
}
