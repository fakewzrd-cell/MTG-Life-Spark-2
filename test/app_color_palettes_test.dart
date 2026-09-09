import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mgt_life_spark/shared/widgets/tier_badge.dart';
import 'package:mgt_life_spark/ui/theme/app_color_tokens.dart';
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
    expect(
      _contrast(
        ColorTokens.onColor(ColorTokens.lightDanger),
        ColorTokens.lightDanger,
      ),
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

  test('light tokens keep HUD paint AA on every light surface', () {
    const aa = 4.5;
    for (final palette in AppColorPalettes.all) {
      final tokens = AppColorTokens.fromLightPalette(palette);
      final surfaces = {
        'backgroundPrimary': tokens.backgroundPrimary,
        'backgroundSecondary': tokens.backgroundSecondary,
        'surface': tokens.surface,
        'surfaceElevated': tokens.surfaceElevated,
      };
      final chrome = {
        'textMuted': tokens.textMuted,
        'textSecondary': tokens.textSecondary,
        'textPrimary': tokens.textPrimary,
        'primaryAccent': tokens.primaryAccent,
        'emphasis': tokens.emphasis,
      };
      final status = {
        'success': tokens.success,
        'warning': tokens.warning,
        'error': tokens.error,
      };
      for (final surface in surfaces.entries) {
        for (final paint in chrome.entries) {
          expect(
            _contrast(paint.value, surface.value),
            greaterThanOrEqualTo(aa),
            reason:
                '${palette.label} light ${paint.key} must meet WCAG AA on ${surface.key}',
          );
        }
      }
      for (final surfaceName in ['backgroundPrimary', 'surface']) {
        for (final paint in status.entries) {
          expect(
            _contrast(paint.value, surfaces[surfaceName]!),
            greaterThanOrEqualTo(aa),
            reason:
                '${palette.label} light ${paint.key} must meet WCAG AA on $surfaceName',
          );
        }
      }
      expect(
        _contrast(tokens.onAccent, tokens.primaryAccent),
        greaterThanOrEqualTo(aa),
        reason: '${palette.label} light onAccent on primaryAccent',
      );
      expect(
        _contrast(tokens.onEmphasis, tokens.emphasis),
        greaterThanOrEqualTo(aa),
        reason: '${palette.label} light onEmphasis on emphasis',
      );
      expect(
        _contrast(tokens.onError, tokens.error),
        greaterThanOrEqualTo(aa),
        reason: '${palette.label} light onError on error',
      );
    }
  });

  test('dark tokens keep HUD paint AA on every dark surface', () {
    const aa = 4.5;
    for (final palette in AppColorPalettes.all) {
      final tokens = AppColorTokens.fromPalette(palette);
      final surfaces = {
        'backgroundPrimary': tokens.backgroundPrimary,
        'backgroundSecondary': tokens.backgroundSecondary,
        'surface': tokens.surface,
        'surfaceElevated': tokens.surfaceElevated,
      };
      final chrome = {
        'textMuted': tokens.textMuted,
        'textSecondary': tokens.textSecondary,
        'textPrimary': tokens.textPrimary,
        'emphasis': tokens.emphasis,
      };
      final status = {
        'success': tokens.success,
        'warning': tokens.warning,
        'error': tokens.error,
      };
      for (final surface in surfaces.entries) {
        for (final paint in chrome.entries) {
          expect(
            _contrast(paint.value, surface.value),
            greaterThanOrEqualTo(aa),
            reason:
                '${palette.label} dark ${paint.key} must meet WCAG AA on ${surface.key}',
          );
        }
      }
      for (final surfaceName in ['backgroundPrimary', 'surface']) {
        for (final paint in status.entries) {
          expect(
            _contrast(paint.value, surfaces[surfaceName]!),
            greaterThanOrEqualTo(aa),
            reason:
                '${palette.label} dark ${paint.key} must meet WCAG AA on $surfaceName',
          );
        }
      }
      expect(
        _contrast(tokens.onAccent, tokens.primaryAccent),
        greaterThanOrEqualTo(aa),
        reason: '${palette.label} dark onAccent on primaryAccent',
      );
      expect(
        _contrast(tokens.onEmphasis, tokens.emphasis),
        greaterThanOrEqualTo(aa),
        reason: '${palette.label} dark onEmphasis on emphasis',
      );
    }
  });

  test('rank metals stay readable on light and dark page fills', () {
    for (final palette in AppColorPalettes.all) {
      for (final tokens in [
        AppColorTokens.fromPalette(palette),
        AppColorTokens.fromLightPalette(palette),
      ]) {
        for (final tier in ['Bronze', 'Silver', 'Gold', 'Platinum', 'Diamond']) {
          expect(
            _contrast(
              wizardTierColor(tier, tokens),
              tokens.backgroundPrimary,
            ),
            greaterThanOrEqualTo(4.5),
            reason:
                '${palette.label} $tier must meet WCAG AA on the page background',
          );
        }
      }
    }
  });
}
