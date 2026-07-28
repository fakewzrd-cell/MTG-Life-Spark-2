import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/game/session_exit_helpers.dart';
import '../../core/network/session_providers.dart';
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
    final concededEarly = localConcededWhileTableActive(ref);
    final quit = await showShellDestructiveConfirm(
      context: context,
      title: 'Leave game?',
      message: concededEarly
          ? 'You will leave the live game and return home. Your concede '
              'result will be saved before disconnecting.'
          : 'You will leave the game and return home. Match stats only '
              'save when the table finishes the game.',
      confirmLabel: 'Leave',
      cancelLabel: 'Stay',
    );
    if (!quit || !context.mounted) return;
    if (concededEarly) {
      await recordLocalConcedeBeforeExit(ref);
    }
    if (context.mounted) context.go(AppRoutes.home);
    await quitActiveGame(ref);
  }
}
