import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/session_providers.dart';
import '../../ui/components/shell_destructive_dialog.dart';

/// Confirms leaving an active host/join session (WebSocket + lobby state).
Future<bool> confirmLeaveActiveSession(BuildContext context) async {
  return showShellDestructiveConfirm(
    context: context,
    title: 'Leave active game?',
    message:
        'You have a lobby or game session running. Leaving will disconnect '
        'other players at the table.',
    confirmLabel: 'Leave',
    cancelLabel: 'Stay',
  );
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
