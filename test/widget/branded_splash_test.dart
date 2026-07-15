import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mgt_life_spark/shared/widgets/branded_splash.dart';

void main() {
  testWidgets('BrandedSplash does not show loading cue on a fast ready path',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: BrandedSplash(ready: true),
      ),
    );

    await tester.pump();
    expect(find.text('Loading Life Spark…'), findsNothing);
  });

  testWidgets('BrandedSplash shows loading cue only after slow threshold',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: BrandedSplash()),
    );

    await tester.pump();
    expect(find.text('Loading Life Spark…'), findsNothing);

    await tester.pump(BrandedSplash.slowLoadThreshold);
    expect(find.text('Loading Life Spark…'), findsOneWidget);
  });

  testWidgets('BrandedSplash reveals vertical wordmark when ready',
      (tester) async {
    var completed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: BrandedSplash(
          ready: true,
          onRevealComplete: () => completed = true,
        ),
      ),
    );

    // Post-frame schedules reveal; second pump starts the controller.
    await tester.pump();
    await tester.pump();
    await tester.pump(BrandedSplash.revealDuration + const Duration(milliseconds: 50));
    await tester.pump(BrandedSplash.revealHold + const Duration(milliseconds: 50));
    await tester.pump();

    expect(completed, isTrue);
  });
}
