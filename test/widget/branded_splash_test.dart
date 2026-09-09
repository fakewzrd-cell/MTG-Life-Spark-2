import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mgt_life_spark/shared/widgets/branded_splash.dart';
import 'package:video_player/video_player.dart';

void main() {
  test('intro fades in quickly after playback starts', () {
    expect(
      BrandedSplash.introFade.inMilliseconds,
      inInclusiveRange(100, 200),
    );
    expect(
      BrandedSplash.videoStartTimeout,
      greaterThan(BrandedSplash.introFade),
    );
  });

  testWidgets('BrandedSplash does not show loading cue on a fast ready path',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: BrandedSplash(ready: true, useVideoIntro: false),
      ),
    );

    await tester.pump();
    expect(find.text('Loading Life Spark…'), findsNothing);
    await tester.pump(BrandedSplash.revealDuration);
    await tester.pump(BrandedSplash.revealHold);
  });

  testWidgets('BrandedSplash shows loading cue only after slow threshold',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: BrandedSplash(useVideoIntro: false)),
    );

    await tester.pump();
    expect(find.text('Loading Life Spark…'), findsNothing);

    await tester.pump(BrandedSplash.slowLoadThreshold);
    expect(find.text('Loading Life Spark…'), findsOneWidget);
    await tester.pump(BrandedSplash.revealDuration);
  });

  testWidgets('BrandedSplash completes after black intro hold when ready',
      (tester) async {
    var completed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: BrandedSplash(
          ready: true,
          useVideoIntro: false,
          onRevealComplete: () => completed = true,
        ),
      ),
    );

    await tester.pump();
    await tester.pump(BrandedSplash.revealDuration);
    await tester.pump(BrandedSplash.revealHold);
    await tester.pump();

    expect(completed, isTrue);
  });

  testWidgets('disabled video intro stays black with no player', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: BrandedSplash(ready: true, useVideoIntro: false),
      ),
    );
    await tester.pump();
    expect(find.byType(VideoPlayer), findsNothing);
    await tester.pump(BrandedSplash.revealDuration);
    await tester.pump(BrandedSplash.revealHold);
  });
}
