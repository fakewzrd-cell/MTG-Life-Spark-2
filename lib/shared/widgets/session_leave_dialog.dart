import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/session_providers.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/components/shell_destructive_dialog.dart';

/// Confirms leaving an active host/join session (WebSocket + lobby state).
Future<bool> confirmLeaveActiveSession(BuildContext context) async {
  final l10n = AppLocalizations.of(context);
  return showShellDestructiveConfirm(
    context: context,
    title: l10n.sessionLeaveTitle,
    message: l10n.sessionLeaveMessage,
    confirmLabel: l10n.sessionLeaveConfirm,
    cancelLabel: l10n.sessionLeaveStay,
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
