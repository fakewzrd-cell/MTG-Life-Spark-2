import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mgt_life_spark/shared/theme/app_theme.dart';
import 'package:mgt_life_spark/ui/theme/app_color_tokens.dart';
import 'package:mgt_life_spark/ui/theme/app_system_ui.dart';

void main() {
  group('adaptive orientation policy', () {
    test('keeps compact phone displays portrait', () {
      expect(
        preferredOrientationsForLogicalWidth(599),
        const [DeviceOrientation.portraitUp],
      );
    });

    test('leaves tablets and foldables unrestricted', () {
      expect(preferredOrientationsForLogicalWidth(600), isEmpty);
      expect(preferredOrientationsForLogicalWidth(1280), isEmpty);
    });
  });

  testWidgets('system overlay tints the navigation bar to app chrome', (
    tester,
  ) async {
    late SystemUiOverlayStyle defaultStyle;
    late SystemUiOverlayStyle dockStyle;
    late Color backgroundPrimary;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: Builder(
          builder: (context) {
            backgroundPrimary = AppColorTokens.of(context).backgroundPrimary;
            defaultStyle = AppSystemUi.overlayStyle(context);
            dockStyle = AppSystemUi.overlayStyle(
              context,
              matchBottomNav: true,
            );
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(defaultStyle.statusBarColor, Colors.transparent);
    expect(defaultStyle.systemNavigationBarColor, backgroundPrimary);
    expect(defaultStyle.systemNavigationBarContrastEnforced, isFalse);
    expect(defaultStyle.statusBarIconBrightness, Brightness.light);
    expect(defaultStyle.systemNavigationBarIconBrightness, Brightness.light);

    final expectedDockColor = Color.alphaBlend(
      backgroundPrimary.withValues(alpha: 0.78),
      backgroundPrimary,
    );
    expect(dockStyle.systemNavigationBarColor, expectedDockColor);
  });
}
