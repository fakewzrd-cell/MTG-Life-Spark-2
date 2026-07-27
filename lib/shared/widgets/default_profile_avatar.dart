import 'package:flutter/material.dart';

import '../constants/app_icons.dart';
import '../../ui/theme/app_color_tokens.dart';

/// Bundled default profile picture when no custom avatar is set.
class DefaultProfileAvatarFill extends StatelessWidget {
  const DefaultProfileAvatarFill({
    super.key,
    required this.size,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTokens.of(context);

    return Image.asset(
      AppIcons.defaultProfileAvatar,
      width: size,
      height: size,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.high,
      errorBuilder: (context, error, stackTrace) => ColoredBox(
        color: Color.lerp(colors.surface, colors.primaryAccent, 0.28)!,
        child: Icon(
          Icons.person_rounded,
          size: size * 0.44,
          color: colors.primaryAccent,
        ),
      ),
    );
  }
}
