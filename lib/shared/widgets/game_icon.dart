import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants/app_icons.dart';

/// Displays a game icon from assets. SVG and single-color PNGs tint via [color].
class GameIcon extends StatelessWidget {
  final String assetPath;
  final double size;
  final Color? color;

  const GameIcon({
    super.key,
    required this.assetPath,
    this.size = 24,
    this.color,
  });

  /// Poison counter icon
  factory GameIcon.poison({double size = 24, Color? color}) =>
      GameIcon(assetPath: AppIcons.poison, size: size, color: color);
  /// Energy counter icon
  factory GameIcon.energy({double size = 24, Color? color}) =>
      GameIcon(assetPath: AppIcons.energy, size: size, color: color);
  /// Radiation counter icon
  factory GameIcon.radiation({double size = 24, Color? color}) =>
      GameIcon(assetPath: AppIcons.radiation, size: size, color: color);
  /// Experience counter icon
  factory GameIcon.experience({double size = 24, Color? color}) =>
      GameIcon(assetPath: AppIcons.experience, size: size, color: color);
  /// Treasure counter icon
  factory GameIcon.treasure({double size = 24, Color? color}) =>
      GameIcon(assetPath: AppIcons.treasure, size: size, color: color);

  /// Bounty variant icon
  factory GameIcon.bounty({double size = 24, Color? color}) =>
      GameIcon(assetPath: AppIcons.bounty, size: size, color: color);

  /// Mana symbol (W, U, B, R, G)
  factory GameIcon.mana(String symbol, {double size = 24}) {
    final path = AppIcons.manaFor(symbol);
    return GameIcon(assetPath: path ?? AppIcons.manaW, size: size);
  }

  bool get _isRaster =>
      assetPath.endsWith('.png') ||
      assetPath.endsWith('.jpg') ||
      assetPath.endsWith('.jpeg') ||
      assetPath.endsWith('.webp');

  @override
  Widget build(BuildContext context) {
    if (_isRaster) {
      final image = Image.asset(
        assetPath,
        width: size,
        height: size,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
      );
      if (color == null) return image;
      return ColorFiltered(
        colorFilter: ColorFilter.mode(color!, BlendMode.srcIn),
        child: image,
      );
    }
    return SvgPicture.asset(
      assetPath,
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color!, BlendMode.srcIn)
          : null,
    );
  }
}
