import 'package:flutter/material.dart';

import '../../ui/theme/app_color_tokens.dart';
import '../../ui/tokens/layout_tokens.dart';

/// Curved top shelf with a **stadium cutout** around the nav bar. The hole is
/// the nav capsule **[detachmentInset] larger** than the real bar so a thin
/// ring of body shows through — reads as negative space / “floating” dock.
class _ShelfWithNavGapClipper extends CustomClipper<Path> {
  _ShelfWithNavGapClipper({
    required this.curveLift,
    required this.bottomInset,
    required this.detachmentInset,
  });

  final double curveLift;
  /// Device bottom safe inset (home indicator), must match [MainBottomNav].
  final double bottomInset;
  /// Extra margin around the bar rect for the hole (body bleeds through = gap).
  final double detachmentInset;

  @override
  Path getClip(Size size) {
    final outer = Path();
    final y0 = curveLift;
    outer.moveTo(0, y0);
    outer.quadraticBezierTo(size.width / 2, 0, size.width, y0);
    outer.lineTo(size.width, size.height);
    outer.lineTo(0, size.height);
    outer.close();

    // Must match `SafeArea` + `Padding` around the nav [DecoratedBox] exactly.
    final navLeft = LayoutTokens.gr3.toDouble();
    final navTop = curveLift + LayoutTokens.gr0;
    final navRight = size.width - LayoutTokens.gr3;
    final navBottom = size.height - bottomInset - LayoutTokens.gr2;

    final navRect = Rect.fromLTRB(navLeft, navTop, navRight, navBottom);
    final holeRect = navRect.inflate(detachmentInset);
    final holeR = holeRect.height > 0 ? holeRect.height / 2 : 0.0;

    final hole = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          holeRect,
          Radius.circular(holeR),
        ),
      );

    return Path.combine(PathOperation.difference, outer, hole);
  }

  @override
  bool shouldReclip(covariant _ShelfWithNavGapClipper oldClipper) =>
      oldClipper.curveLift != curveLift ||
      oldClipper.bottomInset != bottomInset ||
      oldClipper.detachmentInset != detachmentInset;
}

/// Persistent bottom navigation — floating capsule on a curved shelf (fluid split).
/// Icon-only tabs; selected segment uses a nested darker circle (reference UI).
class MainBottomNav extends StatelessWidget {
  const MainBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  /// Tooltips only — no on-screen labels (see reference screenshots).
  static const _items = [
    _NavItem(icon: Icons.home_rounded, tooltip: 'Home'),
    _NavItem(icon: Icons.groups_rounded, tooltip: 'Lobby'),
    _NavItem(icon: Icons.layers_rounded, tooltip: 'Decks'),
    _NavItem(icon: Icons.settings_rounded, tooltip: 'Settings'),
  ];

  static const double _curveLift = 22;

  /// Body shows in a thin ring around the bar (detachment / negative space).
  static const double _detachmentInset = 14;

  /// Shelf + nav chrome above the device safe area (see [SizedBox] height in [build]).
  static const double _kShelfStackHeight = 108.0;

  /// Total height of this widget for a given bottom safe inset.
  /// [MainShell] must use the same value for body bottom padding when [extendBody] is true.
  static double reservedBottomHeight(double bottomInset) =>
      _kShelfStackHeight + bottomInset;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTokens.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final shelfHeight = reservedBottomHeight(bottomInset);

    final pillBg = isDark
        ? const Color(0xFF3A3A3C)
        : const Color(0xFFE5E5EA);
    final selectedDisc = isDark
        ? const Color(0xFF2C2C2E)
        : const Color(0xFFD1D1D6);
    final shadowColor = isDark
        ? Colors.black.withValues(alpha: 0.45)
        : Colors.black.withValues(alpha: 0.12);

    final shelfTop = Color.lerp(
          colors.backgroundPrimary,
          isDark ? Colors.black : colors.surfaceElevated,
          isDark ? 0.55 : 0.08,
        )!;
    final shelfBottom = Color.lerp(
      colors.backgroundSecondary,
      isDark ? Colors.black : colors.backgroundPrimary,
      isDark ? 0.35 : 0.12,
    )!;

    return SizedBox(
      height: shelfHeight,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: ClipPath(
              clipper: _ShelfWithNavGapClipper(
                curveLift: _curveLift,
                bottomInset: bottomInset,
                detachmentInset: _detachmentInset,
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [shelfTop, shelfBottom],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                      blurRadius: 28,
                      offset: const Offset(0, -6),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            minimum: EdgeInsets.zero,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                LayoutTokens.gr3,
                _curveLift + LayoutTokens.gr0,
                LayoutTokens.gr3,
                LayoutTokens.gr2,
              ),
              child: Material(
                color: Colors.transparent,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: pillBg,
                    boxShadow: [
                      BoxShadow(
                        color: shadowColor,
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                        spreadRadius: -2,
                      ),
                      BoxShadow(
                        color: colors.primaryAccent.withValues(alpha: 0.06),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: LayoutTokens.gr1,
                      vertical: LayoutTokens.gr1,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(_items.length, (index) {
                        final item = _items[index];
                        return Expanded(
                          child: _NavItemTile(
                            icon: item.icon,
                            tooltip: item.tooltip,
                            isSelected: currentIndex == index,
                            colors: colors,
                            selectedDisc: selectedDisc,
                            onTap: () => onTap(index),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  const _NavItem({required this.icon, required this.tooltip});
  final IconData icon;
  final String tooltip;
}

class _NavItemTile extends StatelessWidget {
  const _NavItemTile({
    required this.icon,
    required this.tooltip,
    required this.isSelected,
    required this.colors,
    required this.selectedDisc,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final bool isSelected;
  final AppColorTokens colors;
  final Color selectedDisc;
  final VoidCallback onTap;

  static const double _discSize = 48;

  @override
  Widget build(BuildContext context) {
    final iconColor = isSelected ? colors.textPrimary : colors.textSecondary;

    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        label: tooltip,
        selected: isSelected,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(999),
            splashColor: colors.primaryAccent.withValues(alpha: 0.12),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  width: _discSize,
                  height: _discSize,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? selectedDisc : Colors.transparent,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.22),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    icon,
                    size: 26,
                    color: iconColor,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
