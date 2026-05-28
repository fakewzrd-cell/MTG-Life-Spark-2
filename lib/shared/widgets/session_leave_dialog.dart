import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/session_providers.dart';
import '../../ui/theme/app_color_tokens.dart';
import '../../ui/tokens/font_tokens.dart';
import '../../ui/tokens/layout_tokens.dart';
import '../../ui/tokens/color_tokens.dart';

/// Confirms leaving an active host/join session (WebSocket + lobby state).
Future<bool> confirmLeaveActiveSession(BuildContext context) async {
  final colors = AppColorTokens.of(context);
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: colors.surface,
      title: Text(
        'Leave active game?',
        style: TextStyle(
          color: colors.textPrimary,
          fontWeight: FontWeight.w800,
        ),
      ),
      content: Text(
        'You have a lobby or game session running. Leaving will disconnect '
        'other players at the table.',
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
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: FilledButton.styleFrom(
                  backgroundColor: colors.primaryAccent,
                  foregroundColor: ColorTokens.onAccent,
                  shape: const StadiumBorder(),
                  textStyle: TextStyle(
                    fontSize: FontTokens.body,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: const Text('Yes'),
              ),
            ),
            SizedBox(height: LayoutTokens.gr2),
            SizedBox(
              width: double.infinity,
              height: 48,
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
                child: const Text('No'),
              ),
            ),
          ],
        ),
      ],
    ),
  );
  return result == true;
}

/// Ends session and resets game/lobby after user confirms.
Future<bool> leaveActiveSessionIfConfirmed(
  BuildContext context,
  WidgetRef ref,
) async {
  final ok = await confirmLeaveActiveSession(context);
  if (!ok) return false;
  await endSession(ref);
  return true;
}
