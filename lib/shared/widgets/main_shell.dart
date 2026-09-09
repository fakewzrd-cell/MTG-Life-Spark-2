import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/network/session_providers.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/components/app_bottom_nav_bar.dart';
import '../../ui/theme/app_system_ui.dart';
import 'block_system_app_exit.dart';
import 'session_leave_dialog.dart';

/// Pops Host/Join back to the lobby hub, then switches shell tabs next frame.
///
/// [StatefulNavigationShell.goBranch] is `GoRouter.go`. Two `go()` calls in
/// the same turn keep only the last location, which left `/lobby/host` on the
/// lobby branch after confirming leave and opening Profile.
void resetLobbyBranchThenGoTab({
  required BuildContext context,
  required StatefulNavigationShell navigationShell,
  required int destinationIndex,
  int lobbyBranchIndex = 1,
}) {
  navigationShell.goBranch(lobbyBranchIndex, initialLocation: true);
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!context.mounted) return;
    navigationShell.goBranch(destinationIndex);
  });
}

/// Shell scaffold with a floating dock-style bottom nav.
class MainShell extends ConsumerWidget {
  const MainShell({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  static const _lobbyBranchIndex = 1;

  Future<void> _onDestinationSelected(
    BuildContext context,
    WidgetRef ref,
    int index,
  ) async {
    if (index == navigationShell.currentIndex) return;

    final role = ref.read(sessionRoleProvider);
    if (role != SessionRole.none && index != _lobbyBranchIndex) {
      final left = await leaveActiveSessionIfConfirmed(context, ref);
      if (!left || !context.mounted) return;
      // Host/Join sit on nested lobby routes. Ending the session must also
      // reset that branch — otherwise returning to Lobby restores a dead
      // Host screen with no active seat/QR session.
      //
      // goBranch() is GoRouter.go(). Two go() calls in the same turn keep
      // only the last one, so resetting lobby then immediately going to
      // Profile left /lobby/host on the stack. Apply the reset this frame
      // and switch tabs on the next.
      resetLobbyBranchThenGoTab(
        context: context,
        navigationShell: navigationShell,
        destinationIndex: index,
        lobbyBranchIndex: _lobbyBranchIndex,
      );
      return;
    }

    navigationShell.goBranch(index);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return BlockSystemAppExit(
      child: AppSystemUiScope(
        matchBottomNav: true,
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          extendBody: true,
          body: navigationShell,
          bottomNavigationBar: AppBottomNavBar(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: (index) =>
                _onDestinationSelected(context, ref, index),
            destinations: AppBottomNavBar.shellDestinations(l10n),
          ),
        ),
      ),
    );
  }
}
