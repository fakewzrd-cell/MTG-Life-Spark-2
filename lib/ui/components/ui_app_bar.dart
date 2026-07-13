import 'package:flutter/material.dart';

import '../../shared/widgets/brand_logo.dart';

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

  /// Horizontal Life Spark wordmark as the title.
  factory UiAppBar.brand({
    Key? key,
    Widget? leading,
    List<Widget> actions = const [],
    double logoHeight = 26,
  }) {
    return UiAppBar(
      key: key,
      leading: leading,
      actions: actions,
      titleWidget: BrandLogo(
        layout: BrandLogoLayout.horizontal,
        height: logoHeight,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Widget? resolvedTitle = titleWidget ??
        (title != null && title!.isNotEmpty
            ? Text(
                title!,
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
