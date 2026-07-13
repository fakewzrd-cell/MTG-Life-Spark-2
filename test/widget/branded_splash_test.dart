import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mgt_life_spark/shared/widgets/branded_splash.dart';

void main() {
  testWidgets('BrandedSplash shows logo and loading message', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: BrandedSplash()),
    );

    expect(find.text('Loading Life Spark…'), findsOneWidget);
    expect(find.byType(BrandedSplash), findsOneWidget);
  });

  testWidgets('BrandedSplash reveals vertical wordmark when ready', (tester) async {
    var completed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: BrandedSplash(
          ready: true,
          onRevealComplete: () => completed = true,
        ),
      ),
    );

    // Minimum one spin cycle before reveal is allowed to start.
    await tester.pump();
    await tester.pump(BrandedSplash.spinCycle);
    // Reveal fade (900ms) + hold (850ms).
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pump(const Duration(milliseconds: 1000));

    expect(completed, isTrue);
  });
}
