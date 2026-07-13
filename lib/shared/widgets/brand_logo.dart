import 'package:flutter/material.dart';

import '../constants/app_icons.dart';

enum BrandLogoLayout { mark, horizontal, vertical }

/// Life Spark brand art — white marks for dark / gradient surfaces.
class BrandLogo extends StatelessWidget {
  const BrandLogo({
    super.key,
    this.layout = BrandLogoLayout.horizontal,
    this.height = 28,
    this.width,
  });

  final BrandLogoLayout layout;
  final double height;
  final double? width;

  String get _asset => switch (layout) {
        // Placeholder wordmarks until final art is provided — still use the
        // dedicated H/V assets (currently generated stand-ins from the mark).
        BrandLogoLayout.mark => AppIcons.lifeSparkLogo,
        BrandLogoLayout.horizontal => AppIcons.logoHorizontal,
        BrandLogoLayout.vertical => AppIcons.logoVertical,
      };

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      _asset,
      height: height,
      width: width,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      semanticLabel: 'Life Spark',
    );
  }
}
