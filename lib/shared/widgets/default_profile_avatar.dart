import 'package:flutter/material.dart';

import '../constants/app_icons.dart';
import '../../ui/theme/app_color_tokens.dart';

/// Bundled MTG silhouette shown when no custom profile picture is set.
///
/// Tints with [AppColorTokens.primaryAccent] so it follows the active colour scheme.
class DefaultProfileAvatarFill extends StatelessWidget {
  const DefaultProfileAvatarFill({
    super.key,
    required this.size,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTokens.of(context);
    final fill = Color.lerp(colors.surface, colors.primaryAccent, 0.28)!;

    return ColoredBox(
      color: fill,
      child: Center(
        child: ColorFiltered(
          colorFilter: ColorFilter.mode(
            colors.primaryAccent,
            BlendMode.srcIn,
          ),
          child: Image.asset(
            AppIcons.defaultProfileAvatar,
            width: size * 0.46,
            height: size * 0.78,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.medium,
            errorBuilder: (context, error, stackTrace) => Icon(
              Icons.person_rounded,
              size: size * 0.44,
              color: colors.primaryAccent,
            ),
          ),
        ),
      ),
    );
  }
}
