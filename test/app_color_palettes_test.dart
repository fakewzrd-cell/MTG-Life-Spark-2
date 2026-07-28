import 'package:flutter_test/flutter_test.dart';
import 'package:mgt_life_spark/ui/tokens/app_color_palettes.dart';

void main() {
  test('appearance palettes include Obsidian and Fog', () {
    expect(
      AppColorPalettes.all.map((p) => p.id),
      containsAll([AppColorSchemeId.obsidian, AppColorSchemeId.fog]),
    );
    expect(AppColorPalettes.parse('obsidian'), AppColorSchemeId.obsidian);
    expect(AppColorPalettes.parse('fog'), AppColorSchemeId.fog);
    expect(AppColorPalettes.byId(AppColorSchemeId.obsidian).label, 'Obsidian');
    expect(AppColorPalettes.byId(AppColorSchemeId.fog).label, 'Fog');
  });
}
