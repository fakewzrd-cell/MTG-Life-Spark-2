import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mgt_life_spark/shared/widgets/brand_logo.dart';
import 'package:mgt_life_spark/ui/theme/app_theme.dart';

void main() {
  testWidgets('BrandLogo tints for light and dark themes', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(
          body: Center(child: BrandLogo(height: 32)),
        ),
      ),
    );
    expect(find.byType(ColorFiltered), findsOneWidget);
    final lightFilter = tester.widget<ColorFiltered>(find.byType(ColorFiltered));
    expect(lightFilter.colorFilter, isNotNull);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: const Scaffold(
          body: Center(child: BrandLogo(height: 32)),
        ),
      ),
    );
    expect(find.byType(ColorFiltered), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: Center(
            child: BrandLogo(height: 32, color: Colors.red),
          ),
        ),
      ),
    );
    expect(find.byType(ColorFiltered), findsOneWidget);
  });
}
