import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' show NumberFormat;

import '../../core/models/player_profile.dart';
import '../../core/persistence/providers.dart';
import '../../shared/constants/app_icons.dart';
import '../../shared/utils/app_router.dart';
import '../../shared/widgets/tier_badge.dart';
import '../../ui/components/ui_button.dart';
import '../../ui/theme/app_color_tokens.dart';
import '../../ui/tokens/color_tokens.dart';
import '../../ui/tokens/layout_tokens.dart';
import '../../ui/tokens/radius_tokens.dart';
import 'profile_carousel_sections.dart';
import 'profile_player_stats_section.dart';

/// Typical phones (≥360 logical width) use tighter horizontal page padding.
const double _kProfileStatsRowBreakpoint = 360;

/// Circular profile picture in the hero (above username).
const double _kProfileAvatarSize = 104;

/// Clamped text scale (1.0 = default) for layout reserves and hero sizing.
double _profileLayoutTextScale(BuildContext context) {
  final t = MediaQuery.textScalerOf(context).scale(1.0);
  if (!t.isFinite || t <= 0) return 1.0;
  return t.clamp(1.0, 1.45);
}

/// Hero banner height from viewport and orientation; stays within [260, 380].
double _profileHeroCardHeight(BuildContext context) {
  final size = MediaQuery.sizeOf(context);
  final padding = MediaQuery.paddingOf(context);
  final availH = math.max(200.0, size.height - padding.vertical);
  final portrait = size.height >= size.width;
  final ts = _profileLayoutTextScale(context);
  final frac = portrait ? 0.36 : 0.30;
  return (availH * frac * (0.88 + 0.12 * (ts - 1.0))).clamp(260.0, 380.0);
}

Widget _defaultBannerFill(BuildContext context) {
  final scheme = Theme.of(context).colorScheme;
  return ColoredBox(
    color: scheme.surfaceContainer,
    child: DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.surfaceContainerLow,
            scheme.surfaceContainer,
            Color.lerp(scheme.surfaceContainer, scheme.primary, 0.06)!,
          ],
        ),
      ),
    ),
  );
}

/// Bundled profile / commander art when no network image is available.
Widget _defaultProfileBannerArt(
  BuildContext context, {
  double? height,
}) {
  return Image.asset(
    AppIcons.defaultProfileBanner,
    fit: BoxFit.cover,
    width: double.infinity,
    height: height,
    alignment: const Alignment(0, -0.15),
    errorBuilder: (ctx, _, __) => _defaultBannerFill(ctx),
  );
}

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileWatch = ref.watch(profileProvider);
    final profile = profileWatch.profile;
    final matchRepo = ref.watch(matchRepositoryProvider);

    if (profile == null) {
      return Scaffold(
        backgroundColor: AppColorTokens.of(context).backgroundPrimary,
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(LayoutTokens.gr4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Set up your profile to continue.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: LayoutTokens.gr4),
                UiButton(
                  label: 'Create profile',
                  onPressed: () => context.go(AppRoutes.profileSetup),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final allMatches =
        matchRepo
            .getAllMatches()
            .where((m) => !m.matchId.startsWith('__preview_placeholder'))
            .toList();

    final colors = AppColorTokens.of(context);
    return Scaffold(
      backgroundColor: colors.backgroundPrimary,
      body: SafeArea(
        top: false,
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenW = MediaQuery.sizeOf(context).width;
            final screenH = MediaQuery.sizeOf(context).height;
            final raw = constraints.maxWidth;
            final bodyW =
                raw.isFinite && raw > 0 ? raw : screenW.clamp(320.0, 2000.0);
            final isNarrow = bodyW < _kProfileStatsRowBreakpoint;
            final hPad = isNarrow ? LayoutTokens.gr2 : LayoutTokens.gr3;
            // MainShell uses extendBody; reserve space so bottom sections clear the dock.
            final scrollBottomPad = LayoutTokens.shellBottomInset(context);

            final maxH = constraints.maxHeight;
            final layoutTs = _profileLayoutTextScale(context);
            final sectionCardListMaxHeight =
                (MediaQuery.sizeOf(context).height *
                        0.42 *
                        (0.94 + 0.06 * (layoutTs - 1.0)))
                    .clamp(280.0, 560.0);

            final scroll = CustomScrollView(
              key: ValueKey(profileWatch.revision),
              slivers: [
                SliverToBoxAdapter(
                  child: _ProfileHeroCard(
                    profile: profile,
                    colors: colors,
                    overlayHPadding: hPad,
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: LayoutTokens.gr4)),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(hPad, 0, hPad, scrollBottomPad),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      ProfilePlayerStatsSection(
                        profile: profile,
                        colors: colors,
                        listMaxHeight: sectionCardListMaxHeight,
                        hasPlayedGames: allMatches.isNotEmpty,
                      ),
                      SizedBox(height: LayoutTokens.gr4),
                      ProfileDeckPerformanceSection(
                        colors: colors,
                        listMaxHeight: sectionCardListMaxHeight,
                        hasPlayedGames: allMatches.isNotEmpty,
                      ),
                      SizedBox(height: LayoutTokens.gr4),
                      ProfileRecentGamesModule(
                        matches: allMatches,
                        colors: colors,
                        listMaxHeight: sectionCardListMaxHeight,
                      ),
                      SizedBox(height: LayoutTokens.gr4),
                    ]),
                  ),
                ),
              ],
            );

            if (maxH.isFinite && maxH > 0) {
              return scroll;
            }
            return SizedBox(
              height: screenH,
              width: double.infinity,
              child: scroll,
            );
          },
        ),
      ),
    );
  }
}

String _formatProfileStat(int n) => NumberFormat.decimalPattern().format(n);

/// Subtle tint over the full hero banner so text stays legible without blurring art.
class _ProfileHeroFrostVeil extends StatelessWidget {
  const _ProfileHeroFrostVeil();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.42),
            Colors.black.withValues(alpha: 0.30),
            Colors.black.withValues(alpha: 0.52),
          ],
          stops: const [0.0, 0.55, 1.0],
        ),
      ),
      child: const SizedBox.expand(),
    );
  }
}

/// Full-bleed hero header: edge-to-edge banner, rounded bottom only.
class _ProfileHeroCard extends StatelessWidget {
  const _ProfileHeroCard({
    required this.profile,
    required this.colors,
    required this.overlayHPadding,
  });

  final PlayerProfile profile;
  final AppColorTokens colors;
  final double overlayHPadding;

  static final BorderRadius _heroRadius = BorderRadius.vertical(
    bottom: Radius.circular(RadiusTokens.bento),
  );

  @override
  Widget build(BuildContext context) {
    final cardHeight = _profileHeroCardHeight(context);
    void onBanner() => context.push(AppRoutes.profileBanner);
    void onAvatar() => context.push(AppRoutes.profileAvatar);

    Widget background() {
      final url = profile.profileBannerImageUrl;
      if (url != null && url.isNotEmpty) {
        return CachedNetworkImage(
          key: ValueKey(url),
          imageUrl: url,
          fit: BoxFit.cover,
          width: double.infinity,
          height: cardHeight,
          placeholder: (ctx, _) =>
              _defaultProfileBannerArt(ctx, height: cardHeight),
          errorWidget: (ctx, _, __) =>
              _defaultProfileBannerArt(ctx, height: cardHeight),
        );
      }
      return _defaultProfileBannerArt(context, height: cardHeight);
    }

    final topInset = MediaQuery.paddingOf(context).top;

    return ClipRRect(
      borderRadius: _heroRadius,
      child: SizedBox(
        height: cardHeight,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned.fill(child: background()),
            const Positioned.fill(child: _ProfileHeroFrostVeil()),
            Positioned(
              top: topInset + LayoutTokens.gr2,
              right: overlayHPadding,
              child: Semantics(
                button: true,
                label: 'Change profile banner',
                child: Material(
                  color: Colors.black.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(999),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: onBanner,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.wallpaper_outlined,
                            color: ColorTokens.onAccent,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Banner',
                            style: Theme.of(
                              context,
                            ).textTheme.labelLarge?.copyWith(
                              color: ColorTokens.onAccent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: overlayHPadding,
              right: overlayHPadding,
              bottom: LayoutTokens.gr3,
              child: _ProfileHeroIdentityAndStats(
                profile: profile,
                colors: colors,
                onAvatarTap: onAvatar,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Avatar, name, tier badge, and stats pill (inside hero gradient).
class _ProfileHeroIdentityAndStats extends StatelessWidget {
  const _ProfileHeroIdentityAndStats({
    required this.profile,
    required this.colors,
    required this.onAvatarTap,
  });

  final PlayerProfile profile;
  final AppColorTokens colors;
  final VoidCallback onAvatarTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: _ProfileHeroAvatar(
            profile: profile,
            colors: colors,
            onTap: onAvatarTap,
          ),
        ),
        SizedBox(height: LayoutTokens.gr2),
        Text(
          profile.username,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: ColorTokens.onAccent,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.65),
                blurRadius: 12,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
        SizedBox(height: LayoutTokens.gr0),
        Center(child: TierBadge(tier: profile.tier, level: profile.level)),
        SizedBox(height: LayoutTokens.gr2),
        _ProfileFloatingStatsPill(profile: profile),
      ],
    );
  }
}

String? _profileAvatarImageUrl(PlayerProfile profile) {
  final avatar = profile.profileAvatarImageUrl;
  if (avatar != null && avatar.isNotEmpty) return avatar;
  final commander = profile.selectedCommanderImageUrl;
  if (commander != null && commander.isNotEmpty) return commander;
  return null;
}

String _profileInitials(String username) {
  final trimmed = username.trim();
  if (trimmed.isEmpty) return '?';
  final parts = trimmed.split(RegExp(r'\s+'));
  if (parts.length >= 2) {
    return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
  }
  if (trimmed.length >= 2) {
    return trimmed.substring(0, 2).toUpperCase();
  }
  return trimmed[0].toUpperCase();
}

/// Tappable circular profile picture above the username.
class _ProfileHeroAvatar extends StatelessWidget {
  const _ProfileHeroAvatar({
    required this.profile,
    required this.colors,
    required this.onTap,
  });

  final PlayerProfile profile;
  final AppColorTokens colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final imageUrl = _profileAvatarImageUrl(profile);
    const radius = _kProfileAvatarSize / 2;

    Widget avatarChild;
    if (imageUrl != null) {
      avatarChild = ClipOval(
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          width: _kProfileAvatarSize,
          height: _kProfileAvatarSize,
          fit: BoxFit.cover,
          placeholder: (_, __) => _initialsAvatar(radius),
          errorWidget: (_, __, ___) => _initialsAvatar(radius),
        ),
      );
    } else {
      avatarChild = _initialsAvatar(radius);
    }

    return Semantics(
      button: true,
      label: 'Change profile picture',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Container(
            width: _kProfileAvatarSize,
            height: _kProfileAvatarSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.9),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.45),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: Stack(
                fit: StackFit.expand,
                clipBehavior: Clip.none,
                children: [
                  avatarChild,
                  Positioned(
                    right: LayoutTokens.gr0,
                    bottom: LayoutTokens.gr0,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: colors.primaryAccent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.9),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        size: 18,
                        color: ColorTokens.onAccent,
                      ),
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

  Widget _initialsAvatar(double radius) {
    return ColoredBox(
      color: colors.primaryAccent.withValues(alpha: 0.85),
      child: Center(
        child: Text(
          _profileInitials(profile.username),
          style: TextStyle(
            color: ColorTokens.onAccent,
            fontWeight: FontWeight.w800,
            fontSize: radius * 0.72,
          ),
        ),
      ),
    );
  }
}

/// Dark pill: value + label per stat, no dividers.
class _ProfileFloatingStatsPill extends StatelessWidget {
  const _ProfileFloatingStatsPill({required this.profile});

  final PlayerProfile profile;

  @override
  Widget build(BuildContext context) {
    final items = <(String, String)>[
      (_formatProfileStat(profile.totalWins), 'Wins'),
      (_formatProfileStat(profile.honorsMvpReceived), 'MVP'),
      (_formatProfileStat(profile.honorsTeamPlayerReceived), 'Team'),
      (_formatProfileStat(profile.honorsUnderdogReceived), 'Underdog'),
    ];

    return Material(
      color: Colors.black.withValues(alpha: 0.72),
      borderRadius: BorderRadius.circular(999),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (final item in items)
              Expanded(child: _StatColumn(value: item.$1, shortLabel: item.$2)),
          ],
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({required this.value, required this.shortLabel});

  final String value;
  final String shortLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: ColorTokens.onAccent,
            fontWeight: FontWeight.w700,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          shortLabel,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.65),
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
