import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/game/session_exit_helpers.dart';
import '../../core/network/session_providers.dart';
import '../../ui/components/shell_destructive_dialog.dart';
import '../../ui/tokens/font_tokens.dart';
import '../../ui/tokens/spacing_tokens.dart';
import '../utils/app_router.dart';

/// Navigation bar with Home button.
/// [showQuitConfirmation] — when true, shows "Are you sure you want to quit?" before navigating.
/// Only use true when the user is in an active game.
class HomeNavBar extends ConsumerWidget {
  const HomeNavBar({
    super.key,
    this.showQuitConfirmation = false,
  });

  final bool showQuitConfirmation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerLow,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(SpacingTokens.md),
          child: SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () => showQuitConfirmation
                  ? _showQuitDialog(context, ref)
                  : _goHome(context),
              icon: Icon(Icons.home_rounded, color: scheme.primary),
              label: Text(
                'Home',
                style: TextStyle(
                  color: scheme.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: FontTokens.bodyLg,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Future<void> _showQuitDialog(BuildContext context, WidgetRef ref) async {
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
    await quitActiveGame(ref);
    if (context.mounted) {
      context.go(AppRoutes.home);
    }
  }

  static void _goHome(BuildContext context) {
    context.go(AppRoutes.home);
  }

  /// Call from anywhere (e.g. game screen) to show quit confirmation.
  static void promptQuitAndGoHome(BuildContext context, WidgetRef ref) {
    _showQuitDialog(context, ref);
  }
}
