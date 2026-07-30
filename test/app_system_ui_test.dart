import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
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

  testWidgets('system overlay avoids deprecated Android bar color controls', (
    tester,
  ) async {
    late SystemUiOverlayStyle style;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: Builder(
          builder: (context) {
            style = AppSystemUi.overlayStyle(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(style.statusBarColor, isNull);
    expect(style.systemNavigationBarColor, isNull);
    expect(style.systemNavigationBarDividerColor, isNull);
    expect(style.systemNavigationBarContrastEnforced, isNull);
    expect(style.statusBarIconBrightness, Brightness.light);
    expect(style.systemNavigationBarIconBrightness, Brightness.light);
  });
}
