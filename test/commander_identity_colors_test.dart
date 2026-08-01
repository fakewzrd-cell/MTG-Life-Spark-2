import 'package:flutter_test/flutter_test.dart';
import 'package:mgt_life_spark/core/game/commander_identity_colors.dart';
import 'package:mgt_life_spark/ui/theme/app_color_tokens.dart';
import 'package:mgt_life_spark/ui/tokens/app_color_palettes.dart';

void main() {
  test('gameplayGradient uses light tokens in light mode', () {
    final palette = AppColorPalettes.violet;
    final dark = AppColorTokens.fromPalette(palette);
    final light = AppColorTokens.fromLightPalette(palette);

    final darkGradient = CommanderIdentityColors.gameplayGradient(dark);
    final lightGradient = CommanderIdentityColors.gameplayGradient(light);

    expect(darkGradient.first, palette.backgroundPrimary);
    expect(lightGradient.first, palette.lightBackgroundPrimary);
    expect(darkGradient.first, isNot(lightGradient.first));
  });

  test('gameChromeAccent follows primary accent token', () {
    final palette = AppColorPalettes.fog;
    final light = AppColorTokens.fromLightPalette(palette);

    expect(
      CommanderIdentityColors.gameChromeAccent(light),
      palette.lightPrimaryAccent,
    );
  });
}
