import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mgt_life_spark/shared/widgets/branded_splash.dart';

void main() {
  testWidgets('BrandedSplash shows logo and loading message', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: BrandedSplash()),
    );

    expect(find.text('Loading MTG Life Spark…'), findsOneWidget);
    expect(find.byType(BrandedSplash), findsOneWidget);
  });
}
