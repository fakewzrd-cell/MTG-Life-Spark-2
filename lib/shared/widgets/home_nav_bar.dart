import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/game/session_exit_helpers.dart';
import '../../core/network/session_providers.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/components/shell_destructive_dialog.dart';
import '../utils/app_router.dart';

/// Quit / leave helpers used from the in-game chrome.
class HomeNavBar {
  HomeNavBar._();

  /// Call from anywhere (e.g. game screen) to show quit confirmation.
  static void promptQuitAndGoHome(BuildContext context, WidgetRef ref) {
    _showQuitDialog(context, ref);
  }

  static Future<void> _showQuitDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final l10n = AppLocalizations.of(context);
    final concededEarly = localConcededWhileTableActive(ref);
    final quit = await showShellDestructiveConfirm(
      context: context,
      title: l10n.gameLeaveTitle,
      message: concededEarly
          ? l10n.gameLeaveMessageAfterConcede
          : l10n.gameLeaveMessageActive,
      confirmLabel: l10n.sessionLeaveConfirm,
      cancelLabel: l10n.sessionLeaveStay,
    );
    if (!quit || !context.mounted) return;
    if (concededEarly) {
      await recordLocalConcedeBeforeExit(ref);
    }
    if (context.mounted) context.go(AppRoutes.home);
    await quitActiveGame(ref);
  }
}
