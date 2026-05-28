import 'package:flutter/material.dart';

import '../tokens/color_tokens.dart';

/// Standard cancel / confirm actions for [UiDialog.show].
class UiDialogActions {
  UiDialogActions._();

  static Widget cancel(
    BuildContext context, {
    String label = 'Cancel',
    VoidCallback? onPressed,
  }) {
    return TextButton(
      onPressed: onPressed ?? () => Navigator.pop(context),
      child: Text(label),
    );
  }

  static Widget confirm(
    BuildContext context, {
    required String label,
    required VoidCallback onPressed,
    bool isDestructive = false,
  }) {
    return FilledButton(
      onPressed: onPressed,
      style: isDestructive
          ? FilledButton.styleFrom(backgroundColor: ColorTokens.danger)
          : null,
      child: Text(label),
    );
  }

  static List<Widget> cancelConfirm({
    required BuildContext context,
    String cancelLabel = 'Cancel',
    required String confirmLabel,
    required VoidCallback onConfirm,
    bool isDestructive = false,
  }) {
    return [
      cancel(context, label: cancelLabel),
      confirm(
        context,
        label: confirmLabel,
        onPressed: onConfirm,
        isDestructive: isDestructive,
      ),
    ];
  }
}
