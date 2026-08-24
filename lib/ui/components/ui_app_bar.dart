import 'package:flutter/material.dart';

/// Material 3 [AppBar] — inherits [ThemeData.appBarTheme] and [TextTheme].
class UiAppBar extends StatelessWidget implements PreferredSizeWidget {
  const UiAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.leading,
    this.actions = const [],
  }) : assert(title == null || titleWidget == null);

  final String? title;
  final Widget? titleWidget;
  final Widget? leading;
  final List<Widget> actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Widget? resolvedTitle = titleWidget ??
        (title != null && title!.isNotEmpty
            ? Text(
                title!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.appBarTheme.titleTextStyle ??
                    theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              )
            : null);

    return AppBar(
      leading: leading,
      title: resolvedTitle,
      actions: actions,
    );
  }
}
