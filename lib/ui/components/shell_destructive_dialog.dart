import 'package:flutter/material.dart';

import '../theme/app_color_tokens.dart';
import '../tokens/color_tokens.dart';
import '../tokens/font_tokens.dart';
import '../tokens/layout_tokens.dart';
import '../tokens/radius_tokens.dart';

/// Stacked confirm/cancel dialog for shell and in-game leave flows.
Future<bool> showShellDestructiveConfirm({
  required BuildContext context,
  required String title,
  required String message,
  String confirmLabel = 'Leave',
  String cancelLabel = 'Stay',
}) async {
  final colors = AppColorTokens.of(context);
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: RadiusTokens.radiusMd,
        side: BorderSide(color: colors.borderSubtle),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: colors.textPrimary,
          fontWeight: FontWeight.w800,
          fontSize: FontTokens.title,
        ),
      ),
      content: Text(
        message,
        style: TextStyle(
          color: colors.textSecondary,
          fontSize: FontTokens.body,
          height: 1.35,
        ),
      ),
      actionsPadding: EdgeInsets.fromLTRB(
        LayoutTokens.gr3,
        0,
        LayoutTokens.gr3,
        LayoutTokens.gr3,
      ),
      actions: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: LayoutTokens.minTapTarget,
              child: FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: FilledButton.styleFrom(
                  backgroundColor: ColorTokens.danger,
                  foregroundColor: ColorTokens.onAccent,
                  shape: const StadiumBorder(),
                  textStyle: TextStyle(
                    fontSize: FontTokens.body,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: Text(confirmLabel),
              ),
            ),
            SizedBox(height: LayoutTokens.gr2),
            SizedBox(
              height: LayoutTokens.minTapTarget,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(ctx, false),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.textPrimary,
                  side: BorderSide(color: colors.borderSubtle),
                  shape: const StadiumBorder(),
                  textStyle: TextStyle(
                    fontSize: FontTokens.body,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: Text(cancelLabel),
              ),
            ),
          ],
        ),
      ],
    ),
  );
  return result == true;
}
