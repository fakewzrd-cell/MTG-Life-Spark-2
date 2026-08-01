import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mgt_life_spark/ui/components/ui_button.dart';
import 'package:mgt_life_spark/shared/theme/app_theme.dart';

void main() {
  testWidgets('UiButton wraps label at 200% text scale instead of ellipsizing',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(2.0)),
          child: child!,
        ),
        home: Scaffold(
          body: UiButton(
            label: 'Ready to play Commander at the table',
            onPressed: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final label = tester.widget<Text>(
      find.descendant(
        of: find.byType(UiButton),
        matching: find.textContaining('Ready to play Commander'),
      ),
    );
    expect(label.maxLines, isNull);
    expect(label.overflow, isNot(TextOverflow.ellipsis));
    expect(tester.takeException(), isNull);
  });
}
