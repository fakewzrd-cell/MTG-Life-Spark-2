import 'package:flutter/material.dart';

import '../constants/app_icons.dart';
import '../../ui/theme/app_color_tokens.dart';

enum BrandLogoLayout { mark, horizontal, vertical }

/// Life Spark brand art — white PNG silhouettes tinted for the active theme.
class BrandLogo extends StatelessWidget {
  const BrandLogo({
    super.key,
    this.layout = BrandLogoLayout.horizontal,
    this.height = 28,
    this.width,
    this.color,
  });

  final BrandLogoLayout layout;
  final double height;
  final double? width;

  /// When null, uses [AppColorTokens.textPrimary] so the mark reads on light
  /// and dark surfaces. Pass [Colors.white] for purple banners, etc.
  final Color? color;

  String get _asset => switch (layout) {
        BrandLogoLayout.mark => AppIcons.lifeSparkLogo,
        BrandLogoLayout.horizontal => AppIcons.logoHorizontal,
        BrandLogoLayout.vertical => AppIcons.logoVertical,
      };

  @override
  Widget build(BuildContext context) {
    final tint = color ?? AppColorTokens.of(context).textPrimary;
    final image = Image.asset(
      _asset,
      height: height,
      width: width,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      semanticLabel: 'Life Spark',
    );

    return ColorFiltered(
      colorFilter: ColorFilter.mode(tint, BlendMode.srcIn),
      child: image,
    );
  }
}
