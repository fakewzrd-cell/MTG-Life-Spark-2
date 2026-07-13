import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' show NumberFormat;

import '../../core/models/player_profile.dart';
import '../../core/persistence/providers.dart';
import '../../shared/utils/app_router.dart';
import '../../shared/widgets/default_profile_avatar.dart';
import '../../shared/widgets/profile_default_banner.dart';
import '../../shared/widgets/tier_badge.dart';
import '../../ui/components/ui_button.dart';
import '../../ui/theme/app_color_tokens.dart';
import '../../ui/tokens/color_tokens.dart';
import '../../ui/tokens/font_tokens.dart';
import '../../ui/tokens/layout_tokens.dart';
import '../../ui/tokens/radius_tokens.dart';
import 'profile_carousel_sections.dart';
import 'profile_hero_layout.dart';
import 'profile_player_stats_section.dart';

/// Camera badge diameter — centered on the avatar ring at bottom-right.
const double _kProfileCameraBadgeSize = 32;

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
        child: Builder(
          builder: (context) {
            final bodyW = MediaQuery.sizeOf(context).width;
            final isNarrow = bodyW < GameLayoutBreakpoints.compact;
            final heroMetrics = ProfileHeroLayoutMetrics.resolve(
              context,
              isNarrow: isNarrow,
            );
            final hPad = heroMetrics.overlayHPadding;
            final scrollBottomPad = LayoutTokens.shellBottomInset(context);
            final layoutTs = profileSectionTextScale(context);
            final sectionCardListMaxHeight =
                (MediaQuery.sizeOf(context).height *
                        0.42 *
                        (0.94 + 0.06 * (layoutTs - 1.0)))
                    .clamp(280.0, 560.0);

            return CustomScrollView(
              key: ValueKey(profileWatch.revision),
              slivers: [
                SliverToBoxAdapter(
                  child: _ProfileHeroCard(
                    profile: profile,
                    colors: colors,
                    metrics: heroMetrics,
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
                      SizedBox(height: LayoutTokens.shellSectionGap),
                      ProfileDeckPerformanceSection(
                        colors: colors,
                        listMaxHeight: sectionCardListMaxHeight,
                        hasPlayedGames: allMatches.isNotEmpty,
                      ),
                      SizedBox(height: LayoutTokens.shellSectionGap),
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
          },
        ),
      ),
    );
  }
}

String _formatProfileStat(int n) => NumberFormat.decimalPattern().format(n);

/// Full-bleed hero header: edge-to-edge color banner, rounded bottom only.
class _ProfileHeroCard extends StatelessWidget {
  const _ProfileHeroCard({
    required this.profile,
    required this.colors,
    required this.metrics,
  });

  final PlayerProfile profile;
  final AppColorTokens colors;
  final ProfileHeroLayoutMetrics metrics;

  static final BorderRadius _heroRadius = BorderRadius.vertical(
    bottom: Radius.circular(RadiusTokens.bento),
  );

  @override
  Widget build(BuildContext context) {
    final cardHeight = metrics.cardHeight;
    void onAvatar() => context.push(AppRoutes.profileAvatar);

    return ClipRRect(
      borderRadius: _heroRadius,
      child: SizedBox(
        height: cardHeight,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: defaultBannerFill(context),
            ),
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.only(
                  left: metrics.overlayHPadding,
                  right: metrics.overlayHPadding,
                  top: metrics.overlayTopReserve,
                  bottom: metrics.overlayBottomPadding,
                ),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: _ProfileHeroIdentityAndStats(
                    profile: profile,
                    colors: colors,
                    avatarSize: ProfileHeroLayoutMetrics.avatarDiameter,
                    onAvatarTap: onAvatar,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Avatar, name, tier badge, and stats pill (inside hero gradient).
class _ProfileHeroIdentityAndStats extends ConsumerWidget {
  const _ProfileHeroIdentityAndStats({
    required this.profile,
    required this.colors,
    required this.avatarSize,
    required this.onAvatarTap,
  });

  final PlayerProfile profile;
  final AppColorTokens colors;
  final double avatarSize;
  final VoidCallback onAvatarTap;

  Future<void> _editUsername(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController(text: profile.username);
    final formKey = GlobalKey<FormState>();
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: colors.surface,
          title: Text(
            'Edit name',
            style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
              color: colors.textPrimary,
            ),
          ),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              autofocus: true,
              maxLength: 20,
              textCapitalization: TextCapitalization.words,
              style: TextStyle(color: colors.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Username',
                hintText: 'e.g. The Archduke',
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Enter a username';
                }
                if (v.trim().length < 2) {
                  return 'Must be at least 2 characters';
                }
                return null;
              },
              onFieldSubmitted: (_) {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.pop(ctx, true);
                }
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(
                'Cancel',
                style: TextStyle(color: colors.textSecondary),
              ),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.pop(ctx, true);
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: colors.primaryAccent,
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    final next = controller.text.trim();
    controller.dispose();
    if (saved != true || !context.mounted) return;
    if (next == profile.username) return;

    profile.username = next;
    await ref.read(profileRepositoryProvider).saveProfile(profile);
    bumpProfileRevision(ref);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _ProfileHeroAvatar(
              profile: profile,
              colors: colors,
              size: avatarSize,
              onTap: onAvatarTap,
            ),
            SizedBox(width: LayoutTokens.gr3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          profile.username,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: ColorTokens.onAccent,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => _editUsername(context, ref),
                        tooltip: 'Edit name',
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: LayoutTokens.minTapTarget,
                          minHeight: LayoutTokens.minTapTarget,
                        ),
                        icon: Icon(
                          Icons.edit_rounded,
                          size: 20,
                          color: ColorTokens.onAccent.withValues(alpha: 0.92),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: LayoutTokens.gr0),
                  TierBadge(tier: profile.tier, level: profile.level),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: LayoutTokens.gr4),
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

/// Tappable circular profile picture beside the username.
class _ProfileHeroAvatar extends StatelessWidget {
  const _ProfileHeroAvatar({
    required this.profile,
    required this.colors,
    required this.size,
    required this.onTap,
  });

  final PlayerProfile profile;
  final AppColorTokens colors;
  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final imageUrl = _profileAvatarImageUrl(profile);

    Widget avatarChild;
    if (imageUrl != null) {
      avatarChild = ClipOval(
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          placeholder: (context, url) =>
              DefaultProfileAvatarFill(size: size),
          errorWidget: (context, url, error) =>
              DefaultProfileAvatarFill(size: size),
        ),
      );
    } else {
      avatarChild = DefaultProfileAvatarFill(size: size);
    }

    const ringWidth = 3.0;
    // Place badge center on the circle at ~315° (bottom-right on the ring).
    final ringRadius = size / 2 - ringWidth / 2;
    final edgeInset = ringRadius * (1 - 0.7071067811865476);
    final badgeOffset = edgeInset - _kProfileCameraBadgeSize / 2;

    return Semantics(
      button: true,
      label: 'Change profile picture',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: size,
            height: size,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.9),
                      width: ringWidth,
                    ),
                  ),
                  child: ClipOval(child: avatarChild),
                ),
                Positioned(
                  right: badgeOffset,
                  bottom: badgeOffset,
                  child: Container(
                    width: _kProfileCameraBadgeSize,
                    height: _kProfileCameraBadgeSize,
                    decoration: BoxDecoration(
                      color: colors.primaryAccent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.9),
                        width: 2,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      size: 16,
                      color: ColorTokens.onAccent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}

/// Dark pill: Wins as the primary career stat, honors as a quieter cluster.
class _ProfileFloatingStatsPill extends StatelessWidget {
  const _ProfileFloatingStatsPill({required this.profile});

  final PlayerProfile profile;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTokens.of(context);
    final honors = <(String, String)>[
      (_formatProfileStat(profile.honorsMvpReceived), 'MVP'),
      (_formatProfileStat(profile.honorsTeamPlayerReceived), 'Team'),
      (_formatProfileStat(profile.honorsUnderdogReceived), 'Underdog'),
    ];

    return Material(
      color: colors.surface.withValues(alpha: 0.88),
      borderRadius: RadiusTokens.radiusPill,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: _StatColumn(
                value: _formatProfileStat(profile.totalWins),
                shortLabel: 'Wins',
                emphasized: true,
                accentColor: colors.primaryAccent,
              ),
            ),
            Container(
              width: 1,
              height: 28,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              color: colors.borderSubtle.withValues(alpha: 0.55),
            ),
            for (final item in honors)
              Expanded(
                flex: 4,
                child: _StatColumn(
                  value: item.$1,
                  shortLabel: item.$2,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({
    required this.value,
    required this.shortLabel,
    this.emphasized = false,
    this.accentColor,
  });

  final String value;
  final String shortLabel;
  final bool emphasized;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTokens.of(context);
    final valueColor = emphasized
        ? (accentColor ?? colors.textPrimary)
        : colors.textPrimary.withValues(alpha: 0.88);
    final labelColor = emphasized
        ? colors.textSecondary
        : colors.textMuted;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: valueColor,
            fontWeight: emphasized ? FontWeight.w700 : FontWeight.w600,
            fontSize: emphasized ? 17 : 14,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        SizedBox(height: LayoutTokens.gr0),
        Text(
          shortLabel,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: labelColor,
            fontWeight: emphasized ? FontWeight.w600 : FontWeight.w500,
            fontSize: FontTokens.caption,
          ),
        ),
      ],
    );
  }
}
