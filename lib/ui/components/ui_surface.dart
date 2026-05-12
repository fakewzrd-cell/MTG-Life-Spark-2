import 'package:flutter/material.dart';

import '../tokens/radius_tokens.dart';
import '../tokens/spacing_tokens.dart';

/// Material 3 surface: [Material] with [ColorScheme] container roles and optional elevation.
class UiSurface extends StatelessWidget {
  const UiSurface({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.borderColor,
    this.borderRadius = RadiusTokens.radiusMd,
    this.elevation = 0,
    this.glass = false,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Color? borderColor;
  final BorderRadius? borderRadius;
  final double elevation;
  final bool glass;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final radius = borderRadius ?? RadiusTokens.radiusMd;
    final bg = color ??
        (glass
            ? scheme.surfaceContainer.withValues(alpha: 0.72)
            : scheme.surfaceContainer);
    final outline = borderColor ?? scheme.outlineVariant;

    return Material(
      color: bg,
      elevation: elevation,
      surfaceTintColor: scheme.surfaceTint,
      shadowColor: scheme.shadow,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: outline, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: padding ?? const EdgeInsets.all(SpacingTokens.md),
        child: child,
      ),
    );
  }
}
