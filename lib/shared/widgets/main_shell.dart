import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/bluetooth/ble_providers.dart';
import '../../ui/components/app_bottom_nav_bar.dart';
import 'session_leave_dialog.dart';

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

    final role = ref.read(bleRoleProvider);
    if (role != BleRole.none && index != _lobbyBranchIndex) {
      final left = await leaveActiveSessionIfConfirmed(context, ref);
      if (!left || !context.mounted) return;
    }

    navigationShell.goBranch(index);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: AppBottomNavBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) =>
            _onDestinationSelected(context, ref, index),
        destinations: AppBottomNavBar.shellDestinations,
      ),
    );
  }
}
