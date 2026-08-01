import 'package:flutter/material.dart';

import '../theme/app_color_tokens.dart';
import '../tokens/font_tokens.dart';
import '../tokens/layout_tokens.dart';
import '../tokens/radius_tokens.dart';

enum UiButtonVariant { primary, secondary, ghost }

/// Full-width action button. Primary is flat fill (no glow / dual shadow).
class UiButton extends StatelessWidget {
  const UiButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = UiButtonVariant.primary,
    this.icon,
    this.loading = false,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final UiButtonVariant variant;
  final Widget? icon;
  final bool loading;
  final bool enabled;

  static const double _minHeight = 52;

  bool _useSingleLineLabel(BuildContext context) =>
      MediaQuery.textScalerOf(context).scale(1) <= 1.15;

  Widget _label(BuildContext context) {
    final singleLine = _useSingleLineLabel(context);
    return Text(
      label,
      textAlign: TextAlign.center,
      maxLines: singleLine ? 1 : null,
      overflow: singleLine ? TextOverflow.ellipsis : TextOverflow.visible,
      softWrap: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTokens.of(context);
    final effectiveOnPressed = enabled && !loading ? onPressed : null;
    final labelStyle = TextStyle(
      fontSize: FontTokens.bodyLg,
      fontWeight: FontWeight.w600,
    );
    final buttonPadding = EdgeInsets.symmetric(
      horizontal: LayoutTokens.gr3,
      vertical: LayoutTokens.gr2,
    );

    if (variant == UiButtonVariant.primary) {
      return SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: effectiveOnPressed,
          icon: loading
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colors.onAccent,
                  ),
                )
              : (icon ?? const SizedBox.shrink()),
          label: loading ? const SizedBox.shrink() : _label(context),
          style: FilledButton.styleFrom(
            backgroundColor: colors.primaryAccent,
            foregroundColor: colors.onAccent,
            disabledBackgroundColor: colors.surface,
            disabledForegroundColor: colors.textMuted,
            elevation: 0,
            shadowColor: Colors.transparent,
            minimumSize: const Size(double.infinity, _minHeight),
            padding: buttonPadding,
            shape: RoundedRectangleBorder(
              borderRadius: RadiusTokens.radiusMd,
            ),
            textStyle: labelStyle,
          ),
        ),
      );
    }

    if (variant == UiButtonVariant.secondary) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: effectiveOnPressed,
          icon: loading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : (icon ?? const SizedBox.shrink()),
          label: loading ? const SizedBox.shrink() : _label(context),
          style: OutlinedButton.styleFrom(
            foregroundColor: colors.textPrimary,
            side: BorderSide(color: colors.borderSubtle),
            minimumSize: const Size(double.infinity, _minHeight),
            padding: buttonPadding,
            shape: RoundedRectangleBorder(
              borderRadius: RadiusTokens.radiusMd,
            ),
            textStyle: labelStyle,
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: TextButton.icon(
        onPressed: effectiveOnPressed,
        icon: loading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : (icon ?? const SizedBox.shrink()),
        label: loading ? const SizedBox.shrink() : _label(context),
        style: TextButton.styleFrom(
          foregroundColor: colors.textPrimary,
          minimumSize: const Size(double.infinity, _minHeight),
          padding: buttonPadding,
          textStyle: labelStyle,
        ),
      ),
    );
  }
}
