import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mgt_life_spark/features/profile/profile_hero_layout.dart';
import 'package:mgt_life_spark/ui/tokens/layout_tokens.dart';

Future<ProfileHeroLayoutMetrics> _resolve(
  WidgetTester tester, {
  required Size size,
  double textScale = 1.0,
  double topPadding = 47,
}) async {
  late ProfileHeroLayoutMetrics metrics;
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(
        size: size,
        padding: EdgeInsets.only(top: topPadding),
        textScaler: TextScaler.linear(textScale),
      ),
      child: MaterialApp(
        home: Builder(
          builder: (context) {
            metrics = ProfileHeroLayoutMetrics.resolve(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    ),
  );
  return metrics;
}

void main() {
  group('ProfileHeroLayoutMetrics', () {
    testWidgets('reserves room for the status bar and Edit pill', (
      tester,
    ) async {
      final metrics = await _resolve(tester, size: const Size(390, 844));

      expect(
        metrics.overlayTopReserve,
        greaterThanOrEqualTo(47 + LayoutTokens.minTapTarget),
      );
    });

    testWidgets('card is tall enough for its own overlay content', (
      tester,
    ) async {
      for (final scale in [1.0, 1.2, 1.45]) {
        final metrics = await _resolve(
          tester,
          size: const Size(390, 844),
          textScale: scale,
        );

        final contentFloor =
            metrics.overlayTopReserve + metrics.overlayBottomPadding;

        expect(
          metrics.cardHeight,
          greaterThan(contentFloor),
          reason: 'content must fit at text scale $scale',
        );
      }
    });

    testWidgets('banner does not stretch on very tall screens', (tester) async {
      final tall = await _resolve(tester, size: const Size(390, 1400));

      expect(tall.cardHeight, lessThanOrEqualTo(372.0));
    });

    testWidgets('larger text scale never shrinks the card', (tester) async {
      final normal = await _resolve(tester, size: const Size(390, 844));
      final scaled = await _resolve(
        tester,
        size: const Size(390, 844),
        textScale: 1.45,
      );

      expect(scaled.cardHeight, greaterThanOrEqualTo(normal.cardHeight));
    });
  });
}
