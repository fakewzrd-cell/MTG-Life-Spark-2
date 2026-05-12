import 'package:flutter/material.dart';

import '../tokens/spacing_tokens.dart';

/// Material 3 [Dialog] — uses [ThemeData.dialogTheme].
class UiDialog extends StatelessWidget {
  const UiDialog({
    super.key,
    this.title,
    required this.content,
    this.actions,
  });

  final String? title;
  final Widget content;
  final List<Widget>? actions;

  static Future<T?> show<T>(
    BuildContext context, {
    String? title,
    required Widget content,
    List<Widget>? actions,
  }) {
    return showDialog<T>(
      context: context,
      builder: (ctx) => UiDialog(
        title: title,
        content: content,
        actions: actions,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).dialogTheme.titleTextStyle ??
        Theme.of(context).textTheme.titleLarge;
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (title != null) ...[
              Text(title!, style: titleStyle),
              const SizedBox(height: SpacingTokens.md),
            ],
            content,
            if (actions != null && actions!.isNotEmpty) ...[
              const SizedBox(height: SpacingTokens.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: actions!
                    .map(
                      (a) => Padding(
                        padding: const EdgeInsets.only(left: SpacingTokens.sm),
                        child: a,
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
