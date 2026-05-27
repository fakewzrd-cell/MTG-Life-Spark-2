import 'package:flutter/material.dart';

import '../../../ui/theme/app_color_tokens.dart';
import '../../../ui/tokens/color_tokens.dart';
import '../../../ui/tokens/layout_tokens.dart';

/// Shared control chrome for [GameScreen] and related HUD widgets.
abstract final class GameUiTokens {
  static ButtonStyle sheetSecondaryButton(AppColorTokens colors) =>
      TextButton.styleFrom(
        minimumSize: const Size(0, LayoutTokens.minTapTarget),
        padding: const EdgeInsets.symmetric(horizontal: LayoutTokens.gr3),
        foregroundColor: colors.textSecondary,
      );

  static ButtonStyle sheetPrimaryButton(Color accent) => FilledButton.styleFrom(
        minimumSize: const Size(0, LayoutTokens.minTapTarget),
        backgroundColor: accent,
        foregroundColor: ColorTokens.onAccent,
      );

  static ButtonStyle sheetCancelButton(AppColorTokens colors) =>
      OutlinedButton.styleFrom(
        minimumSize: const Size(0, LayoutTokens.minTapTarget),
        foregroundColor: colors.textSecondary,
        side: BorderSide(
          color: colors.textSecondary.withValues(alpha: 0.4),
        ),
      );

  static ButtonStyle destructiveFilledButton(AppColorTokens colors) =>
      FilledButton.styleFrom(
        minimumSize: const Size(0, LayoutTokens.minTapTarget),
        backgroundColor: colors.error,
        foregroundColor: colors.textPrimary,
      );
}
