import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Prevents the Android system back gesture/button from leaving the app when
/// there is no in-app route to pop.
///
/// Nested GoRouter pages and modal routes (sheets/dialogs) still dismiss
/// normally — only the empty-stack / shell-root case is absorbed.
class BlockSystemAppExit extends StatelessWidget {
  const BlockSystemAppExit({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final router = GoRouter.maybeOf(context);
    if (router == null) {
      final canPopInApp = Navigator.of(context).canPop();
      return PopScope(
        canPop: canPopInApp,
        onPopInvokedWithResult: (didPop, result) {},
        child: child,
      );
    }

    // Rebuild whenever the route stack changes so [canPop] stays accurate
    // after pushing nested pages (e.g. Settings → Feedback).
    return ListenableBuilder(
      listenable: router.routerDelegate,
      builder: (context, _) {
        return PopScope(
          canPop: router.canPop(),
          // When false, absorb the back — stay in Life Spark.
          onPopInvokedWithResult: (didPop, result) {},
          child: child,
        );
      },
    );
  }
}
