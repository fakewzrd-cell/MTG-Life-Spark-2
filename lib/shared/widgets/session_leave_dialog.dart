import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/session_providers.dart';
import '../../ui/theme/app_color_tokens.dart';

/// Confirms leaving an active host/join session (WebSocket + lobby state).
Future<bool> confirmLeaveActiveSession(BuildContext context) async {
  final colors = AppColorTokens.of(context);
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(
        'Leave active game?',
        style: TextStyle(color: colors.textPrimary),
      ),
      content: Text(
        'You have a lobby or game session running. Leaving will disconnect '
        'other players at the table.',
        style: TextStyle(color: colors.textSecondary),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('No'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Yes'),
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
