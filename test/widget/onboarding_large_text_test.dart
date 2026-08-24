import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mgt_life_spark/core/persistence/providers.dart';
import 'package:mgt_life_spark/features/onboarding/onboarding_screen.dart';
import 'package:mgt_life_spark/shared/theme/app_theme.dart';

import '../support/test_l10n.dart';
import '../support/test_settings_repository.dart';

void main() {
  testWidgets('onboarding body text is fully readable at 200% text scale',
      (tester) async {
    tester.view.physicalSize = const Size(360 * 3, 640 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsRepositoryProvider
              .overrideWithValue(TestSettingsRepository()),
        ],
        child: MaterialApp(
          theme: AppTheme.dark(),
          localizationsDelegates: testLocalizationDelegates,
          supportedLocales: testSupportedLocales,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(2.0)),
            child: child!,
          ),
          home: const OnboardingScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final bodyFinder = find.textContaining('Commander battlefield companion');
    expect(bodyFinder, findsOneWidget);

    final body = tester.widget<Text>(bodyFinder);
    expect(body.maxLines, isNull);
    expect(body.overflow, isNot(TextOverflow.ellipsis));

    // The slide must be scrollable so nothing is cut off at large scales.
    expect(
      find.ancestor(
        of: bodyFinder,
        matching: find.byType(SingleChildScrollView),
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
