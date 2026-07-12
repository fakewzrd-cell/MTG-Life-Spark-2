import 'package:flutter/material.dart';

import '../theme/app_color_tokens.dart';
import '../tokens/color_tokens.dart';

/// Theme-aware snackbar helper (error uses danger; otherwise theme surface).
void showUiSnackBar(
  BuildContext context,
  String message, {
  bool isError = false,
}) {
  final colors = AppColorTokens.of(context);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: isError ? ColorTokens.danger : colors.surfaceElevated,
    ),
  );
}
