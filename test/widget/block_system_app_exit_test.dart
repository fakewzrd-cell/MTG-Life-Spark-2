import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mgt_life_spark/shared/widgets/block_system_app_exit.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  GoRouter buildRouter({required String initialLocation}) {
    return GoRouter(
      initialLocation: initialLocation,
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => const BlockSystemAppExit(
            child: Scaffold(body: Text('Home root')),
          ),
          routes: [
            GoRoute(
              path: 'child',
              builder: (context, state) => const Scaffold(
                body: Text('Child page'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  testWidgets('system back at shell root does not remove the root page',
      (tester) async {
    final router = buildRouter(initialLocation: '/home');

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    expect(find.text('Home root'), findsOneWidget);

    final handled = await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(handled, isTrue);
    expect(find.text('Home root'), findsOneWidget);
    expect(router.canPop(), isFalse);
  });

  testWidgets('system back pops a nested child route', (tester) async {
    final router = buildRouter(initialLocation: '/home');

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    router.push('/home/child');
    await tester.pumpAndSettle();
    expect(find.text('Child page'), findsOneWidget);
    expect(router.canPop(), isTrue);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('Child page'), findsNothing);
    expect(find.text('Home root'), findsOneWidget);
  });

  testWidgets('after nested push, system back still returns to root',
      (tester) async {
    final router = buildRouter(initialLocation: '/home');

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    expect(router.canPop(), isFalse);

    router.push('/home/child');
    await tester.pumpAndSettle();
    expect(router.canPop(), isTrue);
    expect(find.text('Child page'), findsOneWidget);

    // Nested page leaves; root remains (app exit still blocked).
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Home root'), findsOneWidget);
    expect(router.canPop(), isFalse);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Home root'), findsOneWidget);
  });
}
