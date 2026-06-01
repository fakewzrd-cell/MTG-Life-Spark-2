import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../shared/constants/app_icons.dart';
import '../../shared/utils/app_router.dart';
import '../../ui/theme/app_color_tokens.dart';
import '../../ui/tokens/color_tokens.dart';
import '../../ui/tokens/font_tokens.dart';
import '../../ui/tokens/layout_tokens.dart';
import '../../ui/tokens/radius_tokens.dart';

/// Image crop alignment — subjects sit slightly right in the source PNGs.
const Alignment _kLobbyHostArtAlignment = Alignment(0.22, 0);
const Alignment _kLobbyJoinArtAlignment = Alignment(0.18, 0);

/// Game lobby — Host and Join split the viewport 50/50 with uniform page inset.
class GameLobbyScreen extends StatelessWidget {
  const GameLobbyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTokens.of(context);
    return Scaffold(
      backgroundColor: colors.backgroundPrimary,
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            LayoutTokens.shellPageInset,
            LayoutTokens.shellPageInset,
            LayoutTokens.shellPageInset,
            LayoutTokens.shellBottomInset(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _BigActionButton(
                  label: 'Host Game',
                  subtitle: 'Create a session — others join you',
                  icon: Icons.groups_rounded,
                  artAsset: AppIcons.lobbyHostParty,
                  artAlignment: _kLobbyHostArtAlignment,
                  onTap: () => context.push(AppRoutes.lobbyHost),
                ),
              ),
              SizedBox(height: LayoutTokens.gr2),
              Expanded(
                child: _BigActionButton(
                  label: 'Join Game',
                  subtitle: 'Scan for a nearby host',
                  icon: Icons.qr_code_scanner_rounded,
                  artAsset: AppIcons.lobbyJoinPortal,
                  artAlignment: _kLobbyJoinArtAlignment,
                  onTap: () => context.push(AppRoutes.lobbyJoin),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Full-bleed card art tinted with [AppColorTokens.primaryAccent].
class _LobbyCardArtBackdrop extends StatelessWidget {
  const _LobbyCardArtBackdrop({
    required this.artAsset,
    required this.artAlignment,
    required this.colors,
  });

  final String artAsset;
  final Alignment artAlignment;
  final AppColorTokens colors;

  @override
  Widget build(BuildContext context) {
    final accent = colors.primaryAccent;
    final surface = colors.surface;

    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                surface,
                Color.lerp(surface, accent, 0.18)!,
                Color.lerp(surface, accent, 0.38)!,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),
        Positioned.fill(
          child: Image.asset(
            artAsset,
            fit: BoxFit.cover,
            alignment: artAlignment,
            color: Color.lerp(accent, Colors.white, 0.12),
            colorBlendMode: BlendMode.modulate,
            errorBuilder: (context, error, stackTrace) =>
                const SizedBox.shrink(),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.05,
                colors: [
                  surface.withValues(alpha: 0.35),
                  surface.withValues(alpha: 0.72),
                ],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  accent.withValues(alpha: 0.1),
                  Colors.transparent,
                  accent.withValues(alpha: 0.16),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BigActionButton extends StatelessWidget {
  const _BigActionButton({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.artAsset,
    required this.artAlignment,
    required this.onTap,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final String artAsset;
  final Alignment artAlignment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTokens.of(context);
    final isCompact =
        MediaQuery.sizeOf(context).width < 360 ||
        MediaQuery.sizeOf(context).height < 600;
    final padding = isCompact ? LayoutTokens.gr3 : LayoutTokens.gr4;
    final titleSize =
        isCompact ? FontTokens.headline : FontTokens.headline + LayoutTokens.gr1;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: RadiusTokens.radiusXl,
        boxShadow: [
          BoxShadow(
            color: colors.primaryAccent.withValues(alpha: 0.14),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: RadiusTokens.radiusXl,
          side: BorderSide(
            color: colors.primaryAccent.withValues(alpha: 0.45),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          splashColor: colors.primaryAccent.withValues(alpha: 0.14),
          highlightColor: colors.primaryAccent.withValues(alpha: 0.08),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _LobbyCardArtBackdrop(
                artAsset: artAsset,
                artAlignment: artAlignment,
                colors: colors,
              ),
              Padding(
                padding: EdgeInsets.all(padding),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _LobbyIconBadge(
                        icon: icon,
                        isCompact: isCompact,
                        colors: colors,
                      ),
                      SizedBox(height: LayoutTokens.gr3),
                      Text(
                        label,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontSize: titleSize,
                              fontWeight: FontWeight.w800,
                              color: colors.textPrimary,
                              height: 1.1,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: LayoutTokens.gr1),
                      Text(
                        subtitle,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colors.textSecondary,
                          height: 1.35,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Fixed-size circular badge so the Material icon is layout-centered.
class _LobbyIconBadge extends StatelessWidget {
  const _LobbyIconBadge({
    required this.icon,
    required this.isCompact,
    required this.colors,
  });

  final IconData icon;
  final bool isCompact;
  final AppColorTokens colors;

  @override
  Widget build(BuildContext context) {
    final badgeSize = isCompact ? 52.0 : 56.0;
    final iconSize = isCompact ? 26.0 : 30.0;

    return SizedBox(
      width: badgeSize,
      height: badgeSize,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.primaryAccent.withValues(alpha: 0.22),
          shape: BoxShape.circle,
          border: Border.all(
            color: colors.primaryAccent.withValues(alpha: 0.55),
          ),
        ),
        child: Center(
          child: Icon(
            icon,
            size: iconSize,
            color: ColorTokens.onAccent,
          ),
        ),
      ),
    );
  }
}
