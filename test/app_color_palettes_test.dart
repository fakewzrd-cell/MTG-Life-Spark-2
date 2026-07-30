import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mgt_life_spark/ui/tokens/app_color_palettes.dart';
import 'package:mgt_life_spark/ui/tokens/color_tokens.dart';

double _contrast(Color a, Color b) {
  final lighter = a.computeLuminance() >= b.computeLuminance() ? a : b;
  final darker = identical(lighter, a) ? b : a;
  return (lighter.computeLuminance() + 0.05) /
      (darker.computeLuminance() + 0.05);
}

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

  test('dark palette accents have AA label contrast', () {
    for (final palette in AppColorPalettes.all) {
      expect(
        _contrast(palette.onAccent, palette.brandAccent),
        greaterThanOrEqualTo(4.5),
        reason: '${palette.label} onAccent must meet WCAG AA',
      );
    }
  });

  test('appearance previews match the dark fields the app renders', () {
    for (final palette in AppColorPalettes.all) {
      expect(
        palette.previewBackground,
        palette.backgroundPrimary,
        reason: '${palette.label} preview background must match dark mode',
      );
      expect(
        palette.previewAccent,
        palette.brandAccent,
        reason: '${palette.label} preview accent must match dark mode',
      );
    }
  });

  test('muted text has AA contrast on every dark surface', () {
    for (final palette in AppColorPalettes.all) {
      final surfaces = {
        'backgroundPrimary': palette.backgroundPrimary,
        'backgroundSecondary': palette.backgroundSecondary,
        'surface': palette.surface,
        'surfaceElevated': palette.surfaceElevated,
      };
      for (final entry in surfaces.entries) {
        expect(
          _contrast(palette.textMuted, entry.value),
          greaterThanOrEqualTo(4.5),
          reason:
              '${palette.label} textMuted must meet WCAG AA on ${entry.key}',
        );
      }
      expect(
        palette.textMuted.computeLuminance(),
        lessThan(palette.textSecondary.computeLuminance()),
        reason: '${palette.label} muted/secondary hierarchy must remain',
      );
    }
  });

  test('danger and arbitrary-fill foregrounds remain legible', () {
    expect(
      _contrast(ColorTokens.onDanger, ColorTokens.danger),
      greaterThanOrEqualTo(4.5),
    );
    for (final palette in AppColorPalettes.all) {
      for (final fill in [palette.brandAccent, palette.emphasis]) {
        expect(
          _contrast(ColorTokens.onColor(fill), fill),
          greaterThanOrEqualTo(4.5),
          reason: '${palette.label} arbitrary fill must get a legible on-color',
        );
      }
    }
  });
}
