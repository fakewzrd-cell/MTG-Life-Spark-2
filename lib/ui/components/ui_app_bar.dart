import 'package:flutter/material.dart';

/// Material 3 [AppBar] — inherits [ThemeData.appBarTheme] and [TextTheme].
class UiAppBar extends StatelessWidget implements PreferredSizeWidget {
  const UiAppBar({
    super.key,
    this.title,
    this.leading,
    this.actions = const [],
  });

  final String? title;
  final Widget? leading;
  final List<Widget> actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: leading,
      title: title != null && title!.isNotEmpty
          ? Text(
              title!,
              style: Theme.of(context).textTheme.titleLarge,
            )
          : null,
      actions: actions,
    );
  }
}
