import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mgt_life_spark/core/models/deck_style.dart';
import 'package:mgt_life_spark/core/persistence/providers.dart';
import 'package:mgt_life_spark/features/game_lobby/game_lobby_screen.dart';
import 'package:mgt_life_spark/features/profile/deck_style_picker_sheet.dart';
import 'package:mgt_life_spark/features/settings/settings_screen.dart';
import 'package:mgt_life_spark/l10n/app_localizations.dart';
import 'package:mgt_life_spark/shared/theme/app_theme.dart';
import 'package:mgt_life_spark/shared/utils/deck_style_l10n.dart';
import 'package:mgt_life_spark/ui/components/app_bottom_nav_bar.dart';
import 'package:mgt_life_spark/ui/components/ui_app_bar.dart';
import 'package:mgt_life_spark/ui/theme/app_color_tokens.dart';
import 'package:mgt_life_spark/ui/tokens/font_tokens.dart';

import '../support/test_l10n.dart';
import '../support/test_settings_repository.dart';

/// Every locale the app ships.
final _allLocales = AppLocalizations.supportedLocales;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpAt(
    WidgetTester tester, {
    required Locale locale,
    required Size size,
    required Widget home,
    double textScale = 1.0,
  }) async {
    tester.view.physicalSize = Size(size.width * 3, size.height * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(
            TestSettingsRepository(),
          ),
        ],
        child: MediaQuery(
          data: MediaQueryData(
            size: size,
            textScaler: TextScaler.linear(textScale),
          ),
          child: MaterialApp(
            theme: AppTheme.dark(),
            locale: locale,
            localizationsDelegates: testLocalizationDelegates,
            supportedLocales: testSupportedLocales,
            home: home,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  List<String> takeOverflowExceptions(WidgetTester tester) {
    final overflows = <String>[];
    // Drain every pending exception — Flutter may report more than one.
    Object? exception;
    while ((exception = tester.takeException()) != null) {
      final text = exception.toString();
      if (text.contains('overflowed') || text.contains('OVERFLOW')) {
        overflows.add(text);
      } else {
        fail('Unexpected exception for locale audit: $exception');
      }
    }
    return overflows;
  }

  bool textExceedsLines({
    required String text,
    required TextStyle style,
    required double maxWidth,
    required int maxLines,
    double textScale = 1.0,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: maxLines,
      textScaler: TextScaler.linear(textScale),
    )..layout(maxWidth: maxWidth);
    return painter.didExceedMaxLines;
  }

  testWidgets('bottom nav labels do not overflow in all locales',
      (tester) async {
    final failures = <String>[];

    for (final locale in _allLocales) {
      late AppLocalizations l10n;
      await pumpAt(
        tester,
        locale: locale,
        size: const Size(320, 640),
        home: Builder(
          builder: (context) {
            l10n = AppLocalizations.of(context);
            return Scaffold(
              body: const SizedBox.expand(),
              bottomNavigationBar: AppBottomNavBar(
                selectedIndex: 3,
                onDestinationSelected: (_) {},
                destinations: AppBottomNavBar.shellDestinations(l10n),
              ),
            );
          },
        ),
      );

      failures.addAll(
        takeOverflowExceptions(tester).map((e) => '$locale nav: $e'),
      );

      expect(find.text(l10n.navSettings), findsOneWidget);
      expect(find.text(l10n.navProfile), findsOneWidget);
    }

    expect(failures, isEmpty, reason: failures.join('\n'));
  });

  testWidgets('settings screen does not overflow in all locales',
      (tester) async {
    final failures = <String>[];

    for (final locale in _allLocales) {
      await pumpAt(
        tester,
        locale: locale,
        size: const Size(320, 640),
        textScale: 1.3,
        home: const SettingsScreen(),
      );

      failures.addAll(
        takeOverflowExceptions(tester).map((e) => '$locale settings: $e'),
      );

      final scrollable = find.byType(Scrollable).first;
      await tester.drag(scrollable, const Offset(0, -800));
      await tester.pumpAndSettle();
      failures.addAll(
        takeOverflowExceptions(tester)
            .map((e) => '$locale settings-scrolled: $e'),
      );
    }

    expect(failures, isEmpty, reason: failures.join('\n'));
  });

  testWidgets('lobby hub does not overflow in all locales', (tester) async {
    final failures = <String>[];

    for (final locale in _allLocales) {
      late AppLocalizations l10n;
      await pumpAt(
        tester,
        locale: locale,
        size: const Size(320, 640),
        textScale: 1.3,
        home: Builder(
          builder: (context) {
            l10n = AppLocalizations.of(context);
            return const GameLobbyScreen();
          },
        ),
      );

      failures.addAll(
        takeOverflowExceptions(tester).map((e) => '$locale lobby: $e'),
      );
      expect(find.text(l10n.lobbyHostGame), findsOneWidget);
      expect(find.text(l10n.lobbyJoinGame), findsOneWidget);
    }

    expect(failures, isEmpty, reason: failures.join('\n'));
  });

  testWidgets('app bar titles ellipsize instead of overflowing', (tester) async {
    final failures = <String>[];

    for (final locale in _allLocales) {
      late String title;
      await pumpAt(
        tester,
        locale: locale,
        size: const Size(280, 640),
        home: Builder(
          builder: (context) {
            title = AppLocalizations.of(context).settingsTitle;
            return Scaffold(
              appBar: UiAppBar(title: title),
              body: const SizedBox.shrink(),
            );
          },
        ),
      );

      failures.addAll(
        takeOverflowExceptions(tester).map((e) => '$locale appbar: $e'),
      );
      expect(find.textContaining(title.substring(0, 1)), findsWidgets);
    }

    expect(failures, isEmpty, reason: failures.join('\n'));
  });

  testWidgets('deck style picker sheet does not overflow in all locales',
      (tester) async {
    final failures = <String>[];

    for (final locale in _allLocales) {
      await pumpAt(
        tester,
        locale: locale,
        size: const Size(320, 640),
        textScale: 1.3,
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => showDeckStylePickerSheet(context),
                  child: const Text('open'),
                ),
              ),
            );
          },
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      failures.addAll(
        takeOverflowExceptions(tester).map((e) => '$locale style-sheet: $e'),
      );

      // Scroll through the full list so every tile lays out.
      final list = find.byType(Scrollable).last;
      for (var i = 0; i < 6; i++) {
        await tester.drag(list, const Offset(0, -280));
        await tester.pumpAndSettle();
        failures.addAll(
          takeOverflowExceptions(tester)
              .map((e) => '$locale style-sheet-scroll-$i: $e'),
        );
      }

      // Dismiss modal before the next locale pump.
      Navigator.of(tester.element(find.byType(ListView).first)).pop();
      await tester.pumpAndSettle();
    }

    expect(failures, isEmpty, reason: failures.join('\n'));
  });

  testWidgets('deck style picker field does not overflow longest names',
      (tester) async {
    final failures = <String>[];

    for (final locale in _allLocales) {
      late AppLocalizations l10n;
      late DeckStyle longest;
      await pumpAt(
        tester,
        locale: locale,
        size: const Size(280, 640),
        textScale: 1.3,
        home: Builder(
          builder: (context) {
            l10n = AppLocalizations.of(context);
            longest = DeckStyle.values.reduce((a, b) {
              final an = localizedDeckStyleName(l10n, a);
              final bn = localizedDeckStyleName(l10n, b);
              return an.length >= bn.length ? a : b;
            });
            return Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(16),
                child: DeckStylePickerField(
                  selected: longest,
                  onPick: () {},
                ),
              ),
            );
          },
        ),
      );

      failures.addAll(
        takeOverflowExceptions(tester).map((e) => '$locale style-field: $e'),
      );
      expect(
        find.textContaining(
          localizedDeckStyleName(l10n, longest).substring(0, 1),
        ),
        findsWidgets,
      );
    }

    expect(failures, isEmpty, reason: failures.join('\n'));
  });

  testWidgets('profile deck format+style line does not overflow',
      (tester) async {
    final failures = <String>[];

    for (final locale in _allLocales) {
      late AppLocalizations l10n;
      await pumpAt(
        tester,
        locale: locale,
        size: const Size(240, 640),
        textScale: 1.35,
        home: Builder(
          builder: (context) {
            l10n = AppLocalizations.of(context);
            final colors = AppColorTokens.of(context);
            final style = TextStyle(
              fontSize: FontTokens.hudXs + 1,
              fontWeight: FontWeight.w600,
              height: 1.25,
              color: colors.textSecondary,
            );
            return Scaffold(
              body: Center(
                child: SizedBox(
                  width: 180,
                  child: Text.rich(
                    TextSpan(
                      style: style,
                      children: [
                        TextSpan(
                          text: 'Commander',
                          style: style.copyWith(color: colors.primaryAccent),
                        ),
                        const TextSpan(text: ' · '),
                        TextSpan(
                          text: localizedDeckStyleName(
                            l10n,
                            DeckStyle.stealTheft,
                          ),
                        ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            );
          },
        ),
      );

      failures.addAll(
        takeOverflowExceptions(tester)
            .map((e) => '$locale profile-style-line: $e'),
      );
    }

    expect(failures, isEmpty, reason: failures.join('\n'));
  });

  test('deck style names fit two lines at narrow width in all locales', () {
    final failures = <String>[];
    const maxWidth = 240.0; // field / tile content after padding + check icon
    const nameStyle = TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: FontTokens.body,
    );

    for (final locale in _allLocales) {
      final l10n = lookupAppLocalizations(locale);
      for (final style in DeckStyle.values) {
        final name = localizedDeckStyleName(l10n, style);
        if (textExceedsLines(
          text: name,
          style: nameStyle,
          maxWidth: maxWidth,
          maxLines: 2,
          textScale: 1.3,
        )) {
          failures.add('$locale ${style.id} name exceeds 2 lines: "$name"');
        }
      }
    }

    expect(failures, isEmpty, reason: failures.join('\n'));
  });

  test('deck style descriptions stay within a tall but finite line budget', () {
    // Widget tests use the Ahem test font (≈ square glyphs), which wraps far
    // more aggressively than production fonts. Budget for that + 1.3× scale.
    final warnings = <String>[];
    const maxWidth = 280.0;
    const descStyle = TextStyle(
      fontSize: FontTokens.sm,
      height: 1.35,
    );
    const softMaxLines = 12;

    for (final locale in _allLocales) {
      final l10n = lookupAppLocalizations(locale);
      for (final style in DeckStyle.values) {
        final desc = localizedDeckStyleDescription(l10n, style);
        if (textExceedsLines(
          text: desc,
          style: descStyle,
          maxWidth: maxWidth,
          maxLines: softMaxLines,
          textScale: 1.3,
        )) {
          warnings.add(
            '$locale ${style.id} desc > $softMaxLines lines: "$desc"',
          );
        }
      }
    }

    expect(warnings, isEmpty, reason: warnings.join('\n'));
  });
}
