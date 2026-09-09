import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mgt_life_spark/shared/widgets/main_shell.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'leaving host then opening another tab does not restore host on lobby',
    (tester) async {
      late StatefulNavigationShell shell;

      final router = GoRouter(
        initialLocation: '/lobby/host',
        routes: [
          StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) {
              shell = navigationShell;
              return Scaffold(
                body: navigationShell,
                bottomNavigationBar: NavigationBar(
                  selectedIndex: navigationShell.currentIndex,
                  onDestinationSelected: (index) {
                    if (navigationShell.currentIndex == 1 && index != 1) {
                      resetLobbyBranchThenGoTab(
                        context: context,
                        navigationShell: navigationShell,
                        destinationIndex: index,
                        lobbyBranchIndex: 1,
                      );
                      return;
                    }
                    navigationShell.goBranch(index);
                  },
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.person),
                      label: 'Profile',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.groups),
                      label: 'Lobby',
                    ),
                  ],
                ),
              );
            },
            branches: [
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/home',
                    builder: (context, state) =>
                        const Text('Profile root'),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/lobby',
                    builder: (context, state) => const Text('Lobby hub'),
                    routes: [
                      GoRoute(
                        path: 'host',
                        builder: (context, state) =>
                            const Text('Host lobby'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();
      expect(find.text('Host lobby'), findsOneWidget);

      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      expect(find.text('Profile root'), findsOneWidget);
      expect(find.text('Host lobby'), findsNothing);

      shell.goBranch(1);
      await tester.pumpAndSettle();
      expect(find.text('Lobby hub'), findsOneWidget);
      expect(find.text('Host lobby'), findsNothing);
    },
  );

  testWidgets(
    'two goBranch calls in the same turn restore host (regression)',
    (tester) async {
      late StatefulNavigationShell shell;

      final router = GoRouter(
        initialLocation: '/lobby/host',
        routes: [
          StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) {
              shell = navigationShell;
              return Scaffold(body: navigationShell);
            },
            branches: [
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/home',
                    builder: (context, state) =>
                        const Text('Profile root'),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/lobby',
                    builder: (context, state) => const Text('Lobby hub'),
                    routes: [
                      GoRoute(
                        path: 'host',
                        builder: (context, state) =>
                            const Text('Host lobby'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      // Old MainShell sequence — second go() wins, lobby stays on host.
      shell.goBranch(1, initialLocation: true);
      shell.goBranch(0);
      await tester.pumpAndSettle();
      expect(find.text('Profile root'), findsOneWidget);

      shell.goBranch(1);
      await tester.pumpAndSettle();
      expect(find.text('Host lobby'), findsOneWidget);
    },
  );
}
