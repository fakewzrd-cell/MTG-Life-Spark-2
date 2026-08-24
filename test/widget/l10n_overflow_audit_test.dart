import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mgt_life_spark/core/persistence/providers.dart';
import 'package:mgt_life_spark/features/game_lobby/game_lobby_screen.dart';
import 'package:mgt_life_spark/features/settings/settings_screen.dart';
import 'package:mgt_life_spark/l10n/app_localizations.dart';
import 'package:mgt_life_spark/shared/theme/app_theme.dart';
import 'package:mgt_life_spark/ui/components/app_bottom_nav_bar.dart';
import 'package:mgt_life_spark/ui/components/ui_app_bar.dart';

import '../support/test_l10n.dart';
import '../support/test_settings_repository.dart';

/// Locales that ship with Phase 1 translations.
const _phase1Locales = <Locale>[
  Locale('en'),
  Locale('es'),
  Locale('pt', 'BR'),
  Locale('fr'),
  Locale('de'),
  Locale('ja'),
];

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
    final exception = tester.takeException();
    if (exception != null) {
      final text = exception.toString();
      if (text.contains('overflowed') || text.contains('OVERFLOW')) {
        overflows.add(text);
      } else {
        // Unexpected non-overflow failure — rethrow via expect.
        fail('Unexpected exception for locale audit: $exception');
      }
    }
    return overflows;
  }

  testWidgets('bottom nav labels do not overflow in phase-1 locales',
      (tester) async {
    final failures = <String>[];

    for (final locale in _phase1Locales) {
      late AppLocalizations l10n;
      await pumpAt(
        tester,
        locale: locale,
        size: const Size(320, 640), // narrow phone
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

      // Labels must still be present for semantics/a11y.
      expect(find.text(l10n.navSettings), findsOneWidget);
      expect(find.text(l10n.navProfile), findsOneWidget);
    }

    expect(failures, isEmpty, reason: failures.join('\n'));
  });

  testWidgets('settings screen does not overflow in phase-1 locales',
      (tester) async {
    final failures = <String>[];

    for (final locale in _phase1Locales) {
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

      // Scroll through long German/Japanese copy so off-screen tiles layout.
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

  testWidgets('lobby hub does not overflow in phase-1 locales', (tester) async {
    final failures = <String>[];

    for (final locale in _phase1Locales) {
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

    for (final locale in _phase1Locales) {
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
}
