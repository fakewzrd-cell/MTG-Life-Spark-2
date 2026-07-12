import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../shared/constants/app_icons.dart';
import '../theme/app_color_tokens.dart';
import '../tokens/font_tokens.dart';
import '../tokens/layout_tokens.dart';
import '../tokens/motion_tokens.dart';

/// Shell tab descriptor for [AppBottomNavBar].
class AppNavDestination {
  const AppNavDestination({
    required this.label,
    this.icon,
    this.selectedIcon,
    this.iconAsset,
    this.selectedIconAsset,
  }) : assert(
         (iconAsset != null) || (icon != null && selectedIcon != null),
         'Provide iconAsset or both icon and selectedIcon',
       );

  final IconData? icon;
  final IconData? selectedIcon;

  /// Inactive raster icon (tinted). Optional [selectedIconAsset] for morph.
  final String? iconAsset;

  /// Active raster icon. Falls back to [iconAsset] when null.
  final String? selectedIconAsset;

  final String label;
}

/// Edge-to-edge glass bottom nav — color + icon morph, no selection pill.
class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<AppNavDestination> destinations;

  static const shellDestinations = [
    AppNavDestination(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
      label: 'Profile',
    ),
    AppNavDestination(
      icon: Icons.groups_outlined,
      selectedIcon: Icons.groups_rounded,
      label: 'Lobby',
    ),
    AppNavDestination(
      iconAsset: AppIcons.playTabCards,
      label: 'Decks',
    ),
    AppNavDestination(
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings_rounded,
      label: 'Settings',
    ),
  ];

  static const double barHeight = LayoutTokens.bottomNavHeight;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTokens.of(context);

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.backgroundPrimary.withValues(alpha: 0.78),
            border: Border(
              top: BorderSide(
                color: colors.borderSubtle.withValues(alpha: 0.22),
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: barHeight,
              child: Row(
                children: [
                  for (var i = 0; i < destinations.length; i++)
                    Expanded(
                      child: _DockNavItem(
                        destination: destinations[i],
                        selected: selectedIndex == i,
                        accent: colors.primaryAccent,
                        inactive: colors.textMuted,
                        onTap: () {
                          if (i == selectedIndex) return;
                          HapticFeedback.lightImpact();
                          onDestinationSelected(i);
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DockNavItem extends StatelessWidget {
  const _DockNavItem({
    required this.destination,
    required this.selected,
    required this.accent,
    required this.inactive,
    required this.onTap,
  });

  final AppNavDestination destination;
  final bool selected;
  final Color accent;
  final Color inactive;
  final VoidCallback onTap;

  static const double _iconSize = 24;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: destination.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: TweenAnimationBuilder<double>(
          duration: MotionTokens.standard,
          curve: MotionTokens.easeOut,
          tween: Tween(end: selected ? 1.0 : 0.0),
          builder: (context, t, _) {
            final fg = Color.lerp(inactive, accent, t)!;
            final labelOpacity = lerpDouble(0.55, 1.0, t)!;

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Transform.scale(
                  scale: lerpDouble(0.96, 1.0, t)!,
                  child: _NavIcon(
                    destination: destination,
                    color: fg,
                    progress: t,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  destination.label,
                  style: TextStyle(
                    fontSize: FontTokens.label,
                    fontWeight: FontWeight.lerp(
                      FontWeight.w500,
                      FontWeight.w700,
                      t,
                    ),
                    letterSpacing: 0.15,
                    color: fg.withValues(alpha: labelOpacity),
                    height: 1.0,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({
    required this.destination,
    required this.color,
    required this.progress,
  });

  final AppNavDestination destination;
  final Color color;

  /// 0 = inactive icon, 1 = selected icon (synced with color tween).
  final double progress;

  @override
  Widget build(BuildContext context) {
    final asset = destination.iconAsset;
    if (asset != null) {
      final selectedAsset = destination.selectedIconAsset ?? asset;
      if (selectedAsset == asset) {
        return Image.asset(
          asset,
          width: _DockNavItem._iconSize,
          height: _DockNavItem._iconSize,
          fit: BoxFit.contain,
          color: color,
          colorBlendMode: BlendMode.srcIn,
          filterQuality: FilterQuality.medium,
        );
      }
      return SizedBox(
        width: _DockNavItem._iconSize,
        height: _DockNavItem._iconSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Opacity(
              opacity: (1.0 - progress).clamp(0.0, 1.0),
              child: Image.asset(
                asset,
                width: _DockNavItem._iconSize,
                height: _DockNavItem._iconSize,
                fit: BoxFit.contain,
                color: color,
                colorBlendMode: BlendMode.srcIn,
                filterQuality: FilterQuality.medium,
              ),
            ),
            Opacity(
              opacity: progress.clamp(0.0, 1.0),
              child: Image.asset(
                selectedAsset,
                width: _DockNavItem._iconSize,
                height: _DockNavItem._iconSize,
                fit: BoxFit.contain,
                color: color,
                colorBlendMode: BlendMode.srcIn,
                filterQuality: FilterQuality.medium,
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      width: _DockNavItem._iconSize,
      height: _DockNavItem._iconSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Opacity(
            opacity: (1.0 - progress).clamp(0.0, 1.0),
            child: Icon(
              destination.icon,
              size: _DockNavItem._iconSize,
              color: color,
            ),
          ),
          Opacity(
            opacity: progress.clamp(0.0, 1.0),
            child: Icon(
              destination.selectedIcon,
              size: _DockNavItem._iconSize,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
