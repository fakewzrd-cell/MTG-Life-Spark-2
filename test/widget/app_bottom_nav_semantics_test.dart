import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mgt_life_spark/shared/theme/app_theme.dart';
import 'package:mgt_life_spark/ui/components/app_bottom_nav_bar.dart';

void main() {
  testWidgets('bottom nav exposes each destination label once', (tester) async {
    final handle = tester.ensureSemantics();
    try {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark(),
          home: Scaffold(
            bottomNavigationBar: AppBottomNavBar(
              selectedIndex: 0,
              onDestinationSelected: (_) {},
              destinations: const [
                AppNavDestination(
                  icon: Icons.person_outline_rounded,
                  selectedIcon: Icons.person_rounded,
                  label: 'Profile',
                ),
                AppNavDestination(
                  icon: Icons.groups_outlined,
                  selectedIcon: Icons.groups_rounded,
                  label: 'Lobby',
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.bySemanticsLabel('Profile'), findsOneWidget);
      expect(find.bySemanticsLabel('Lobby'), findsOneWidget);
    } finally {
      handle.dispose();
    }
  });
}
