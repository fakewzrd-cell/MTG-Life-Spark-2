import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mgt_life_spark/core/persistence/providers.dart';
import 'package:mgt_life_spark/features/game/widgets/hub_guide_sheet.dart';
import 'package:mgt_life_spark/shared/theme/app_theme.dart';
import 'package:mgt_life_spark/shared/theme/theme_provider.dart';

import '../support/test_settings_repository.dart';

void main() {
  testWidgets('hub guide body is fully readable at 200% text scale',
      (tester) async {
    tester.view.physicalSize = const Size(360 * 3, 640 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(
            TestSettingsRepository(),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.dark(),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(2.0)),
            child: child!,
          ),
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () => showHubGuideSheet(context),
                child: const Text('Open'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    final bodyFinder = find.textContaining('Track life and counters here');
    expect(bodyFinder, findsOneWidget);

    final body = tester.widget<Text>(bodyFinder);
    expect(body.maxLines, isNull);
    expect(body.overflow, isNot(TextOverflow.ellipsis));

    expect(
      find.ancestor(
        of: bodyFinder,
        matching: find.byType(SingleChildScrollView),
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  test('theme mode follows useDarkTheme setting', () {
    final container = ProviderContainer(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(
          TestSettingsRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(themeModeProvider), ThemeMode.dark);

    final repo = container.read(settingsRepositoryProvider);
    repo.settings.useDarkTheme = false;
    container.read(settingsRevisionProvider.notifier).state++;

    expect(container.read(themeModeProvider), ThemeMode.light);
    expect(
      container.read(effectiveThemeProvider).brightness,
      Brightness.light,
    );
  });
}
