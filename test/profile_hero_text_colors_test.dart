import 'package:flutter_test/flutter_test.dart';
import 'package:mgt_life_spark/ui/tokens/app_color_palettes.dart';

void main() {
  test('dark onAccent themes keep light textPrimary for surface copy', () {
    const darkOnAccentSchemes = [
      AppColorSchemeId.violet,
      AppColorSchemeId.slate,
      AppColorSchemeId.forest,
      AppColorSchemeId.obsidian,
    ];
    for (final id in darkOnAccentSchemes) {
      final palette = AppColorPalettes.byId(id);
      expect(
        palette.textPrimary.computeLuminance(),
        greaterThan(0.7),
        reason: '${palette.label} textPrimary must stay light on dark surfaces',
      );
      expect(
        palette.onAccent.computeLuminance(),
        lessThan(palette.textPrimary.computeLuminance()),
        reason: '${palette.label} onAccent is for accent buttons, not hero copy',
      );
    }
  });
}
