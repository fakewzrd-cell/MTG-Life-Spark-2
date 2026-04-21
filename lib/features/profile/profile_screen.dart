import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' show DateFormat, NumberFormat;

import '../../core/models/match_record.dart';
import '../../core/models/player_deck.dart';
import '../../core/models/player_profile.dart';
import '../../core/persistence/providers.dart';
import '../../shared/utils/app_router.dart';
import '../../shared/widgets/deck_tile_visual.dart';
import '../../shared/widgets/mana_cost_pips.dart';
import '../../shared/widgets/tier_badge.dart';
import '../../ui/theme/app_color_tokens.dart';
import '../../ui/tokens/color_tokens.dart';
import '../../ui/tokens/font_tokens.dart';
import '../../ui/tokens/layout_tokens.dart';
import '../../ui/tokens/radius_tokens.dart';

/// Profile — bento-style tiles (large radius, layered depth).
const double _kBentoRadiusPx = 28;

/// Bundled MTG art when no custom banner is set (from project mana assets).
const String _kDefaultBannerPlaceholderAsset = 'assets/mana/MYB/fullManaCost.png';

BorderRadius get _kBentoRadius =>
    const BorderRadius.all(Radius.circular(_kBentoRadiusPx));

/// Typical phones (≥360 logical width) use the side‑by‑side level/behaviour row to save height.
const double _kProfileStatsRowBreakpoint = 360;

/// Upper block (hero + level/behaviour) vs lower (deck + recent) vertical split.
const int _kProfileUpperFlex = 3;
const int _kProfileLowerFlex = 2;

int _xpNeededForLevel(int level) {
  const thresholds = [
    (10, 500),
    (25, 1000),
    (50, 2000),
    (75, 3500),
    (100, 5000),
  ];
  for (final (max, xp) in thresholds) {
    if (level <= max) return xp;
  }
  return 5000;
}

Widget _defaultBannerFill(AppColorTokens colors) {
  return Container(
    width: double.infinity,
    height: double.infinity,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          colors.backgroundSecondary,
          colors.surface,
          colors.primaryAccent.withValues(alpha: 0.18),
        ],
      ),
    ),
  );
}

/// Rounded bento surface with optional soft gradient and depth.
class _BentoCard extends StatelessWidget {
  const _BentoCard({
    required this.child,
    required this.colors,
    this.gradientColors,
  });

  final Widget child;
  final AppColorTokens colors;
  final List<Color>? gradientColors;

  @override
  Widget build(BuildContext context) {
    final gradient =
        (gradientColors != null && gradientColors!.length >= 2)
            ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors!,
            )
            : LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colors.surfaceElevated,
                Color.lerp(
                  colors.surfaceElevated,
                  colors.backgroundSecondary,
                  0.35,
                )!,
              ],
            );

    return Container(
      decoration: BoxDecoration(
        borderRadius: _kBentoRadius,
        gradient: gradient,
        border: Border.all(color: colors.borderSubtle.withValues(alpha: 0.55)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: colors.primaryAccent.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: _kBentoRadius,
        child: Padding(
          padding: EdgeInsets.all(LayoutTokens.gr4),
          child: child,
        ),
      ),
    );
  }
}

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileWatch = ref.watch(profileProvider);
    final profile = profileWatch.profile;
    final matchRepo = ref.watch(matchRepositoryProvider);

    if (profile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final storedMatches = matchRepo.getAllMatches().toList();
    final allMatches =
        storedMatches.isEmpty ? _previewPlaceholderMatches() : storedMatches;

    final colors = AppColorTokens.of(context);
    return Scaffold(
      backgroundColor: colors.backgroundPrimary,
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenW = MediaQuery.sizeOf(context).width;
            final screenH = MediaQuery.sizeOf(context).height;
            final raw = constraints.maxWidth;
            final bodyW =
                raw.isFinite && raw > 0 ? raw : screenW.clamp(320.0, 2000.0);
            final isNarrow = bodyW < 360;
            final hPad = isNarrow ? LayoutTokens.gr3 : LayoutTokens.gr4;
            final sectionGap = LayoutTokens.gr2;

            final maxH = constraints.maxHeight;
            final useOneScreenLayout = maxH.isFinite && maxH > 200;

            if (useOneScreenLayout) {
              return Padding(
                padding: EdgeInsets.fromLTRB(hPad, 0, hPad, LayoutTokens.gr2),
                child: Column(
                  key: ValueKey(profileWatch.revision),
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: _kProfileUpperFlex,
                      child: LayoutBuilder(
                        builder: (context, upperConstraints) {
                          final total = upperConstraints.maxHeight;
                          final g = sectionGap;
                          final pair = total - g;
                          final statsCap =
                              bodyW >= _kProfileStatsRowBreakpoint ? 300.0 : 310.0;
                          var statsH = (pair * 0.58).clamp(210.0, statsCap);
                          var heroH = pair - statsH;
                          if (heroH < 92) {
                            heroH = 92;
                            statsH = pair - heroH;
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(
                                height: heroH,
                                child: _ProfileHeroCard(
                                  profile: profile,
                                  colors: colors,
                                  height: heroH,
                                ),
                              ),
                              SizedBox(height: g),
                              SizedBox(
                                height: statsH,
                                child: _ProfileLevelBehaviourBentoRow(
                                  profile: profile,
                                  colors: colors,
                                  bodyWidth: bodyW,
                                  rowHeight: statsH,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    SizedBox(height: sectionGap),
                    Expanded(
                      flex: _kProfileLowerFlex,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: _DeckPerformanceSection(colors: colors),
                          ),
                          SizedBox(height: sectionGap),
                          Expanded(
                            child: _RecentGamesModule(
                              matches: allMatches,
                              colors: colors,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            final scroll = CustomScrollView(
              key: ValueKey(profileWatch.revision),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 0),
                    child: _ProfileHeroCard(
                      profile: profile,
                      colors: colors,
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: LayoutTokens.gr5)),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(hPad, 0, hPad, hPad),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _ProfileLevelBehaviourBentoRow(
                        profile: profile,
                        colors: colors,
                        bodyWidth: bodyW,
                      ),
                      SizedBox(height: LayoutTokens.gr5),
                      _DeckPerformanceSection(
                        colors: colors,
                        listMaxHeight:
                            (MediaQuery.sizeOf(context).height * 0.32)
                                .clamp(200.0, 380.0),
                      ),
                      SizedBox(height: LayoutTokens.gr5),
                      _RecentGamesModule(
                        matches: allMatches,
                        colors: colors,
                        listMaxHeight:
                            (MediaQuery.sizeOf(context).height * 0.32)
                                .clamp(200.0, 380.0),
                      ),
                      SizedBox(height: LayoutTokens.gr5),
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

/// Rounded hero card: banner art, banner action, floating stats pill.
class _ProfileHeroCard extends StatelessWidget {
  const _ProfileHeroCard({
    required this.profile,
    required this.colors,
    this.height,
  });

  final PlayerProfile profile;
  final AppColorTokens colors;
  /// When null (scroll fallback), uses [_defaultCardHeight].
  final double? height;

  static const double _defaultCardHeight = 340;

  @override
  Widget build(BuildContext context) {
    final cardHeight = height ?? _defaultCardHeight;
    void onBanner() => context.push(AppRoutes.profileBanner);

    Widget background() {
      final url = profile.profileBannerImageUrl;
      if (url != null && url.isNotEmpty) {
        return CachedNetworkImage(
          key: ValueKey(url),
          imageUrl: url,
          fit: BoxFit.cover,
          width: double.infinity,
          height: cardHeight,
          placeholder: (_, __) => Container(color: colors.backgroundSecondary),
          errorWidget: (_, __, ___) => _defaultBannerFill(colors),
        );
      }
      return Image.asset(
        _kDefaultBannerPlaceholderAsset,
        fit: BoxFit.cover,
        width: double.infinity,
        height: cardHeight,
        errorBuilder: (_, __, ___) => _defaultBannerFill(colors),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(_kBentoRadiusPx),
      child: SizedBox(
        height: cardHeight,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned.fill(child: background()),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: (cardHeight * 0.52).clamp(96.0, 200.0),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.75),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
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
                        const Icon(
                          Icons.wallpaper_outlined,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Banner',
                          style: Theme.of(
                            context,
                          ).textTheme.labelLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: _ProfileHeroIdentityAndStats(
                profile: profile,
                colors: colors,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Name + tier badge above the stats pill (inside hero gradient). Rank is shown under Level progress.
class _ProfileHeroIdentityAndStats extends StatelessWidget {
  const _ProfileHeroIdentityAndStats({
    required this.profile,
    required this.colors,
  });

  final PlayerProfile profile;
  final AppColorTokens colors;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          profile.username,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
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
        SizedBox(height: LayoutTokens.gr1),
        Center(child: TierBadge(tier: profile.tier, level: profile.level)),
        SizedBox(height: LayoutTokens.gr3),
        _ProfileFloatingStatsPill(profile: profile),
      ],
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
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          shortLabel,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.65),
            fontWeight: FontWeight.w500,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

/// Counts XP-in-level numerals so the label matches the progress bar animation.
class _AnimatedXpInLevelLabel extends StatefulWidget {
  const _AnimatedXpInLevelLabel({
    required this.targetXpInLevel,
    required this.xpNeeded,
    required this.level,
    required this.style,
  });

  final int targetXpInLevel;
  final int xpNeeded;
  final int level;
  final TextStyle? style;

  @override
  State<_AnimatedXpInLevelLabel> createState() =>
      _AnimatedXpInLevelLabelState();
}

class _AnimatedXpInLevelLabelState extends State<_AnimatedXpInLevelLabel>
    with SingleTickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 1100);

  late final AnimationController _controller;
  Animation<double> _value = const AlwaysStoppedAnimation<double>(0);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _duration);
    _value = Tween<double>(
      begin: 0,
      end: widget.targetXpInLevel.toDouble(),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant _AnimatedXpInLevelLabel oldWidget) {
    super.didUpdateWidget(oldWidget);
    final bandChanged =
        oldWidget.level != widget.level ||
        oldWidget.xpNeeded != widget.xpNeeded;
    if (bandChanged) {
      _value = Tween<double>(
        begin: 0,
        end: widget.targetXpInLevel.toDouble(),
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.forward(from: 0);
      return;
    }
    if (oldWidget.targetXpInLevel != widget.targetXpInLevel) {
      final from = _value.value.clamp(0.0, 1e9);
      _value = Tween<double>(
        begin: from,
        end: widget.targetXpInLevel.toDouble(),
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final shown = _value.value.round().clamp(0, widget.xpNeeded);
        return Text(
          '$shown / ${widget.xpNeeded} XP',
          style: widget.style,
          textAlign: TextAlign.center,
        );
      },
    );
  }
}

/// Row (wide) or column: **Level progress** (donut) + **Player behaviour** (spectrum bar).
class _ProfileLevelBehaviourBentoRow extends StatelessWidget {
  const _ProfileLevelBehaviourBentoRow({
    required this.profile,
    required this.colors,
    required this.bodyWidth,
    this.rowHeight,
  });

  final PlayerProfile profile;
  final AppColorTokens colors;
  final double bodyWidth;
  /// When set (one-screen profile layout), constrains the row / stacked stats height.
  final double? rowHeight;

  /// Fixed height for the wide two-column row when [rowHeight] is not passed (scroll layout).
  static const double _kWideRowHeightFallback = 268;

  @override
  Widget build(BuildContext context) {
    final xpNeeded = _xpNeededForLevel(profile.level);
    final xpInLevel = profile.xp % xpNeeded;
    final xpProgress =
        (xpNeeded > 0) ? (xpInLevel / xpNeeded).clamp(0.0, 1.0) : 0.0;

    final wide = bodyWidth >= _kProfileStatsRowBreakpoint;

    final levelCard = _BentoCard(
      colors: colors,
      gradientColors: [
        Color.lerp(colors.surfaceElevated, ColorTokens.success, 0.14)!,
        colors.surfaceElevated,
      ],
      child: _LevelDonutCard(
        profile: profile,
        colors: colors,
        xpNeeded: xpNeeded,
        xpInLevel: xpInLevel,
        xpProgress: xpProgress,
        fillHeight: wide,
      ),
    );

    final behaviourCard = _BentoCard(
      colors: colors,
      gradientColors: [
        Color.lerp(colors.surfaceElevated, colors.primaryAccent, 0.12)!,
        colors.surfaceElevated,
      ],
      child: _BehaviourBarCard(
        profile: profile,
        colors: colors,
        fillHeight: wide,
      ),
    );

    final wideH = rowHeight ?? _kWideRowHeightFallback;

    if (wide) {
      return SizedBox(
        height: wideH,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: levelCard),
            SizedBox(width: LayoutTokens.gr3),
            Expanded(child: behaviourCard),
          ],
        ),
      );
    }

    final stack = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        levelCard,
        SizedBox(height: LayoutTokens.gr3),
        behaviourCard,
      ],
    );
    if (rowHeight != null) {
      return SizedBox(
        height: rowHeight,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: stack,
          ),
        ),
      );
    }
    return stack;
  }
}

/// 0 = Good, 1 = Salty (from dislike ratio among reactions).
double _saltFraction(PlayerProfile profile) {
  final total = profile.likesReceived + profile.dislikesReceived;
  if (total == 0) return 0.5;
  return (profile.dislikesReceived / total).clamp(0.0, 1.0);
}

/// Good / Neutral / Salty thirds — same bands as the spectrum labels.
int _behaviourSentimentIndex(double salt) {
  if (salt < 1 / 3) return 0;
  if (salt < 2 / 3) return 1;
  return 2;
}

class _LevelDonutCard extends StatelessWidget {
  const _LevelDonutCard({
    required this.profile,
    required this.colors,
    required this.xpNeeded,
    required this.xpInLevel,
    required this.xpProgress,
    this.fillHeight = false,
  });

  final PlayerProfile profile;
  final AppColorTokens colors;
  final int xpNeeded;
  final int xpInLevel;
  final double xpProgress;
  /// When true (wide side-by-side row), middle content expands to match sibling card height.
  final bool fillHeight;

  @override
  Widget build(BuildContext context) {
    final donutBlock = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: _AnimatedDonutGauge(
            targetProgress: xpProgress,
            size: 128,
            strokeWidth: 11,
            trackColor: colors.backgroundSecondary.withValues(alpha: 0.95),
            progressColor: colors.primaryAccent,
            centerBuilder: (ctx, t) {
              final pct = (t * 100).round().clamp(0, 100);
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$pct%',
                    style: Theme.of(ctx).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colors.textPrimary,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  Text(
                    'Lv ${profile.level}',
                    style: Theme.of(ctx).textTheme.labelMedium?.copyWith(
                      color: colors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        SizedBox(height: LayoutTokens.gr2),
        Center(
          child: _AnimatedXpInLevelLabel(
            targetXpInLevel: xpInLevel,
            xpNeeded: xpNeeded,
            level: profile.level,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Level progress',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                  color: colors.textPrimary,
                ),
              ),
            ),
            Tooltip(
              message:
                  'XP in your current level fills the ring. Reach 100% for the next level band.',
              child: Icon(
                Icons.info_outline_rounded,
                size: 20,
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
        SizedBox(height: LayoutTokens.gr1),
        Text(
          'Rank ${profile.level}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: colors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: LayoutTokens.gr2),
        if (fillHeight)
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [donutBlock],
            ),
          )
        else
          donutBlock,
      ],
    );
  }
}

class _BehaviourBarCard extends StatelessWidget {
  const _BehaviourBarCard({
    required this.profile,
    required this.colors,
    this.fillHeight = false,
  });

  final PlayerProfile profile;
  final AppColorTokens colors;
  /// When true (wide row), spectrum block expands so the bento matches level progress height.
  final bool fillHeight;

  @override
  Widget build(BuildContext context) {
    final salt = _saltFraction(profile);
    final moodIdx = _behaviourSentimentIndex(salt);
    final moodIcon = switch (moodIdx) {
      0 => Icons.sentiment_very_satisfied_rounded,
      1 => Icons.sentiment_neutral_rounded,
      _ => Icons.sentiment_very_dissatisfied_rounded,
    };
    final moodColor = switch (moodIdx) {
      0 => ColorTokens.success,
      1 => colors.textSecondary,
      _ => colors.primaryAccent,
    };

    final spectrumBlock = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: Icon(
              moodIcon,
              key: ValueKey<int>(moodIdx),
              size: 40,
              color: moodColor,
            ),
          ),
        ),
        SizedBox(height: LayoutTokens.gr4),
        LayoutBuilder(
          builder: (context, c) {
            final w = c.maxWidth;
            final thumbX = 16.0 + (w - 32.0) * salt;
            return Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 12,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    gradient: LinearGradient(
                      colors: [
                        ColorTokens.success,
                        colors.textSecondary,
                        colors.primaryAccent,
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: thumbX.clamp(4.0, w - 12.0) - 7,
                  top: -5,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: colors.textPrimary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colors.backgroundPrimary,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.35),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Player behaviour',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                  color: colors.textPrimary,
                ),
              ),
            ),
            Tooltip(
              message:
                  'Position on the spectrum reflects reactions from others—more dislikes shifts toward Salty.',
              child: Icon(
                Icons.info_outline_rounded,
                size: 20,
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
        SizedBox(height: fillHeight ? LayoutTokens.gr1 : LayoutTokens.gr2),
        if (fillHeight)
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [spectrumBlock],
            ),
          )
        else
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 132),
            child: spectrumBlock,
          ),
        SizedBox(height: LayoutTokens.gr3),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Good',
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: FontTokens.sm,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'Neutral',
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: FontTokens.sm,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'Salty',
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: FontTokens.sm,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(height: LayoutTokens.gr3),
        Center(
          child: Text(
            '${profile.likesReceived} likes · ${profile.dislikesReceived} dislikes',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: colors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

class _DonutRingPainter extends CustomPainter {
  _DonutRingPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
    this.strokeWidth = 11,
  });

  final double progress;
  final Color trackColor;
  final Color progressColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = (size.shortestSide - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: c, radius: r);

    final track =
        Paint()
          ..color = trackColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, 2 * math.pi, false, track);

    final p = progress.clamp(0.0, 1.0);
    if (p <= 0) return;

    final arc =
        Paint()
          ..color = progressColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * p, false, arc);
  }

  @override
  bool shouldRepaint(covariant _DonutRingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.progressColor != progressColor ||
      oldDelegate.strokeWidth != strokeWidth;
}

/// Animated donut; [targetProgress] in 0–1.
class _AnimatedDonutGauge extends StatefulWidget {
  const _AnimatedDonutGauge({
    required this.targetProgress,
    required this.trackColor,
    required this.progressColor,
    required this.centerBuilder,
    this.size = 120,
    this.strokeWidth = 11,
  });

  final double targetProgress;
  final Color trackColor;
  final Color progressColor;
  final Widget Function(BuildContext context, double animatedT) centerBuilder;
  final double size;
  final double strokeWidth;

  @override
  State<_AnimatedDonutGauge> createState() => _AnimatedDonutGaugeState();
}

class _AnimatedDonutGaugeState extends State<_AnimatedDonutGauge>
    with SingleTickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 1100);

  late final AnimationController _controller;
  Animation<double> _fill = const AlwaysStoppedAnimation<double>(0);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _duration);
    _fill = Tween<double>(
      begin: 0,
      end: widget.targetProgress,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant _AnimatedDonutGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.targetProgress != widget.targetProgress) {
      final from = _fill.value.clamp(0.0, 1.0);
      _fill = Tween<double>(begin: from, end: widget.targetProgress).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final v = _fill.value.clamp(0.0, 1.0);
          return Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _DonutRingPainter(
                  progress: v,
                  trackColor: widget.trackColor,
                  progressColor: widget.progressColor,
                  strokeWidth: widget.strokeWidth,
                ),
              ),
              widget.centerBuilder(context, v),
            ],
          );
        },
      ),
    );
  }
}

/// Scrollable list inside a bento with a fixed max height; auto-advances when idle.
class _BentoAutoScrollList extends StatefulWidget {
  const _BentoAutoScrollList({
    this.maxHeight,
    required this.itemCount,
    required this.itemBuilder,
    this.separator,
  });

  /// When null, the list expands within a parent [Expanded] (bounded height).
  final double? maxHeight;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final Widget? separator;

  @override
  State<_BentoAutoScrollList> createState() => _BentoAutoScrollListState();
}

class _BentoAutoScrollListState extends State<_BentoAutoScrollList> {
  final ScrollController _controller = ScrollController();
  Timer? _autoTimer;
  Timer? _resumeTimer;
  bool _programmatic = false;
  bool _autoBusy = false;

  static const _resumeAfterIdle = Duration(seconds: 5);
  static const _autoTick = Duration(seconds: 4);
  static const _stepPx = 88.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scheduleResume());
  }

  void _scheduleResume() {
    _resumeTimer?.cancel();
    _resumeTimer = Timer(_resumeAfterIdle, () {
      if (!mounted) return;
      _startAuto();
    });
  }

  void _userInteracted() {
    _autoTimer?.cancel();
    _autoTimer = null;
    _scheduleResume();
  }

  void _startAuto() {
    if (!mounted || widget.itemCount <= 1) return;
    _autoTimer?.cancel();
    _autoTimer = Timer.periodic(_autoTick, (_) => _autoAdvance());
  }

  Future<void> _autoAdvance() async {
    if (!mounted || _autoBusy) return;
    if (!_controller.hasClients) return;
    final pos = _controller.position;
    if (!pos.hasContentDimensions) return;
    final max = pos.maxScrollExtent;
    if (max < 8) return;

    _autoBusy = true;
    _programmatic = true;
    try {
      final o = _controller.offset;
      if (o + _stepPx >= max - 4) {
        await _controller.animateTo(
          0,
          duration: const Duration(milliseconds: 650),
          curve: Curves.easeInOut,
        );
      } else {
        await _controller.animateTo(
          (o + _stepPx).clamp(0.0, max),
          duration: const Duration(milliseconds: 480),
          curve: Curves.easeInOut,
        );
      }
    } finally {
      if (mounted) _programmatic = false;
      _autoBusy = false;
    }
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _resumeTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _BentoAutoScrollList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.itemCount != widget.itemCount) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_controller.hasClients) _controller.jumpTo(0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.itemCount == 0) return const SizedBox.shrink();

    final list = Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _userInteracted(),
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification n) {
          if (_programmatic) return false;
          if (n is UserScrollNotification) {
            _userInteracted();
          }
          return false;
        },
        child: ListView.separated(
          controller: _controller,
          primary: false,
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: widget.itemCount,
          separatorBuilder:
              (_, __) =>
                  widget.separator ?? SizedBox(height: LayoutTokens.gr2),
          itemBuilder: widget.itemBuilder,
        ),
      ),
    );
    final h = widget.maxHeight;
    if (h != null) {
      return SizedBox(height: h, child: list);
    }
    return list;
  }
}

class _RecentGamesModule extends StatelessWidget {
  final List<MatchRecord> matches;
  final AppColorTokens colors;
  /// When null, list fills remaining space inside an [Expanded] (one-screen layout).
  final double? listMaxHeight;

  const _RecentGamesModule({
    required this.matches,
    required this.colors,
    this.listMaxHeight,
  });

  @override
  Widget build(BuildContext context) {
    final c = colors;

    final emptyPlaceholder = Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: LayoutTokens.gr2),
        child: Text(
          'No recent matches.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: c.textSecondary,
          ),
        ),
      ),
    );

    final scrollList = _BentoAutoScrollList(
      maxHeight: listMaxHeight,
      itemCount: matches.length,
      itemBuilder: (context, i) {
        return _RecentMatchRow(match: matches[i], colors: c);
      },
    );

    return _BentoCard(
      colors: c,
      gradientColors: [
        Color.lerp(c.surfaceElevated, ColorTokens.success, 0.08)!,
        c.surfaceElevated,
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Recent Games',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
              color: c.textPrimary,
            ),
          ),
          SizedBox(height: LayoutTokens.gr2),
          if (matches.isEmpty)
            listMaxHeight == null
                ? Expanded(child: emptyPlaceholder)
                : emptyPlaceholder
          else if (listMaxHeight == null)
            Expanded(child: scrollList)
          else
            scrollList,
        ],
      ),
    );
  }
}

String _formatDurationSeconds(int seconds) {
  final h = seconds ~/ 3600;
  final m = (seconds % 3600) ~/ 60;
  final s = seconds % 60;
  if (h > 0) {
    return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
  return '$m:${s.toString().padLeft(2, '0')}';
}

class _RecentMatchRow extends ConsumerStatefulWidget {
  final MatchRecord match;
  final AppColorTokens colors;
  const _RecentMatchRow({required this.match, required this.colors});

  @override
  ConsumerState<_RecentMatchRow> createState() => _RecentMatchRowState();
}

class _RecentMatchRowState extends ConsumerState<_RecentMatchRow> {
  bool _open = false;

  Color get _resultColor {
    if (widget.match.result == 'win') return ColorTokens.success;
    return widget.colors.primaryAccent;
  }

  String get _resultLabel {
    if (widget.match.result == 'win') return 'Win';
    if (widget.match.result == 'concede') return 'Concede';
    return 'Loss';
  }

  String get _opponentLabel {
    if (widget.match.opponentNames.isNotEmpty) {
      return widget.match.opponentNames.join(', ');
    }
    return 'vs ${widget.match.playerCount} players';
  }

  String _initials(String name) {
    final t = name.trim();
    if (t.isEmpty) return '?';
    final parts = t.split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return t.length >= 2 ? t.substring(0, 2).toUpperCase() : t.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('MMM d, y');
    final timeFmt = DateFormat('HH:mm');
    final m = widget.match;
    final colors = widget.colors;
    final secs = m.durationSecondsEffective;
    final participants = m.participantSnapshots;

    final innerR = BorderRadius.circular(_kBentoRadiusPx - 6);
    return Material(
      color: colors.backgroundSecondary.withValues(alpha: 0.42),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: innerR,
        side: BorderSide(color: _resultColor.withValues(alpha: 0.42)),
      ),
      child: InkWell(
        onTap: () => setState(() => _open = !_open),
        borderRadius: innerR,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal:
                MediaQuery.sizeOf(context).width < 360
                    ? LayoutTokens.gr3
                    : LayoutTokens.gr4,
            vertical: LayoutTokens.gr3,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    _open ? Icons.expand_less : Icons.expand_more,
                    color: colors.textSecondary,
                    size: 22,
                  ),
                  SizedBox(width: LayoutTokens.gr1),
                  Expanded(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${m.matchTypeLabel} · ${m.format} · $_opponentLabel',
                            style: Theme.of(
                              context,
                            ).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize:
                                  MediaQuery.sizeOf(context).width < 360
                                      ? 14
                                      : null,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                          SizedBox(height: LayoutTokens.gr0),
                          Text(
                            '${fmt.format(m.date)} · ${timeFmt.format(m.date)}',
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                              color: colors.textSecondary,
                              fontSize: FontTokens.sm,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: LayoutTokens.gr2),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: LayoutTokens.gr2,
                      vertical: LayoutTokens.gr1,
                    ),
                    decoration: BoxDecoration(
                      color: _resultColor.withValues(alpha: 0.15),
                      borderRadius: RadiusTokens.radiusSm,
                    ),
                    child: Text(
                      _resultLabel,
                      style: TextStyle(
                        color: _resultColor,
                        fontWeight: FontWeight.w700,
                        fontSize:
                            MediaQuery.sizeOf(context).width < 360
                                ? FontTokens.sm
                                : FontTokens.caption,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
              if (_open) ...[
                Divider(color: colors.textSecondary.withValues(alpha: 0.2)),
                SizedBox(height: LayoutTokens.gr1),
                _detailRow(context, 'Duration', _formatDurationSeconds(secs)),
                if (m.podNameSnapshot != null && m.podNameSnapshot!.isNotEmpty)
                  _detailRow(context, 'Pod', m.podNameSnapshot!),
                if (m.localDeckIdSnapshot != null &&
                    m.localDeckIdSnapshot!.isNotEmpty)
                  _detailRow(
                    context,
                    'Deck',
                    ref
                            .read(deckRepositoryProvider)
                            .getById(m.localDeckIdSnapshot!)
                            ?.displayName ??
                        m.localDeckIdSnapshot!,
                  ),
                if (participants.isNotEmpty) ...[
                  SizedBox(height: LayoutTokens.gr2),
                  Text(
                    'Players',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: colors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: LayoutTokens.gr1),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        participants.map((p) {
                          return Chip(
                            avatar: CircleAvatar(
                              backgroundColor: colors.primaryAccent.withValues(
                                alpha: 0.3,
                              ),
                              child: Text(
                                _initials(p.username),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: colors.textPrimary,
                                ),
                              ),
                            ),
                            label: Text(
                              p.commanderName ?? p.username,
                              style: TextStyle(
                                color: colors.textPrimary,
                                fontSize: 12,
                              ),
                            ),
                            backgroundColor: colors.backgroundSecondary,
                            side: BorderSide(
                              color: colors.textSecondary.withValues(alpha: 0.2),
                            ),
                          );
                        }).toList(),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: LayoutTokens.gr1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 88,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: widget.colors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: widget.colors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Sample rows for Recent Games when there is no local history yet.
List<MatchRecord> _previewPlaceholderMatches() {
  final now = DateTime.now();

  final duel = [
    const MatchParticipantSnapshot(
      playerId: 'local',
      username: 'You',
      commanderName: 'The Ur-Dragon',
      teamIndex: 0,
    ),
    const MatchParticipantSnapshot(
      playerId: 'opp1',
      username: 'Alex',
      commanderName: 'Niv-Mizzet, Parun',
      teamIndex: 0,
    ),
  ];

  final fourPlayer = [
    const MatchParticipantSnapshot(
      playerId: 'local',
      username: 'You',
      commanderName: 'Atraxa, Praetors\' Voice',
      teamIndex: 0,
    ),
    const MatchParticipantSnapshot(
      playerId: 'p2',
      username: 'Sam',
      commanderName: 'Yuriko, the Tiger\'s Shadow',
      teamIndex: 0,
    ),
    const MatchParticipantSnapshot(
      playerId: 'p3',
      username: 'Jordan',
      commanderName: 'Kinnan, Bonder Prodigy',
      teamIndex: 0,
    ),
    const MatchParticipantSnapshot(
      playerId: 'p4',
      username: 'Taylor',
      commanderName: 'Winota, Joiner of Forces',
      teamIndex: 0,
    ),
  ];

  final podOfThree = [
    const MatchParticipantSnapshot(
      playerId: 'local',
      username: 'You',
      commanderName: 'Wilhelt, the Rotcleaver',
      teamIndex: 0,
    ),
    const MatchParticipantSnapshot(
      playerId: 'a',
      username: 'Morgan',
      commanderName: 'Lathril, Blade of Elves',
      teamIndex: 0,
    ),
    const MatchParticipantSnapshot(
      playerId: 'b',
      username: 'Riley',
      commanderName: 'Meren of Clan Nel Toth',
      teamIndex: 0,
    ),
  ];

  final olderDuel = [
    const MatchParticipantSnapshot(
      playerId: 'local',
      username: 'You',
      commanderName: 'Kinnan, Bonder Prodigy',
      teamIndex: 0,
    ),
    const MatchParticipantSnapshot(
      playerId: 'opp_casey',
      username: 'Casey',
      commanderName: 'Krark, the Thumbless',
      teamIndex: 0,
    ),
  ];

  return [
    MatchRecord(
      matchId: '__preview_placeholder_1__',
      date: now.subtract(const Duration(days: 1, hours: 2)),
      commanderName: 'The Ur-Dragon',
      partnerCommanderName: null,
      opponentNames: const ['Alex'],
      result: 'win',
      eliminationReason: 'survived',
      format: 'Commander',
      durationMinutes: 90,
      startingLifeTotal: 40,
      playerCount: 2,
      durationSeconds: 90 * 60 + 30,
      participantsJson: jsonEncode(duel.map((e) => e.toJson()).toList()),
      podNameSnapshot: 'Friday Night',
      locationSnapshot: 'Game shop',
      localDeckIdSnapshot: null,
    ),
    MatchRecord(
      matchId: '__preview_placeholder_2__',
      date: now.subtract(const Duration(days: 5, hours: 4)),
      commanderName: 'Atraxa, Praetors\' Voice',
      partnerCommanderName: null,
      opponentNames: const ['Sam', 'Jordan', 'Taylor'],
      result: 'loss',
      eliminationReason: 'life',
      format: 'Commander',
      durationMinutes: 127,
      startingLifeTotal: 40,
      playerCount: 4,
      durationSeconds: 127 * 60 + 12,
      participantsJson: jsonEncode(
        fourPlayer.map((e) => e.toJson()).toList(),
      ),
      podNameSnapshot: 'Game Store League',
      locationSnapshot: null,
      localDeckIdSnapshot: null,
    ),
    MatchRecord(
      matchId: '__preview_placeholder_3__',
      date: now.subtract(const Duration(days: 14, hours: 1)),
      commanderName: 'Wilhelt, the Rotcleaver',
      partnerCommanderName: null,
      opponentNames: const ['Morgan', 'Riley'],
      result: 'concede',
      eliminationReason: 'concede',
      format: 'Commander',
      durationMinutes: 52,
      startingLifeTotal: 40,
      playerCount: 3,
      durationSeconds: 52 * 60 + 45,
      participantsJson: jsonEncode(
        podOfThree.map((e) => e.toJson()).toList(),
      ),
      podNameSnapshot: 'Kitchen table',
      locationSnapshot: 'Home',
      localDeckIdSnapshot: null,
    ),
    MatchRecord(
      matchId: '__preview_placeholder_4__',
      date: now.subtract(const Duration(days: 21, hours: 3)),
      commanderName: 'Kinnan, Bonder Prodigy',
      partnerCommanderName: null,
      opponentNames: const ['Casey'],
      result: 'loss',
      eliminationReason: 'commanderDamage',
      format: 'Commander',
      durationMinutes: 74,
      startingLifeTotal: 40,
      playerCount: 2,
      durationSeconds: 74 * 60 + 6,
      participantsJson: jsonEncode(
        olderDuel.map((e) => e.toJson()).toList(),
      ),
      podNameSnapshot: 'Commander night',
      locationSnapshot: null,
      localDeckIdSnapshot: null,
    ),
  ];
}

bool _deckHasManaForProfile(PlayerDeck d) {
  final c = d.commanderManaCost?.trim();
  final p = d.partnerManaCost?.trim();
  return (c != null && c.isNotEmpty) ||
      (d.hasPartner && p != null && p.isNotEmpty);
}

/// Sample rows for Deck performance when there are no saved decks yet.
/// Mana strings use bundled `assets/mana/` symbols (WUBRG, hybrids, numbers).
List<PlayerDeck> _previewPlaceholderDecks() {
  return [
    PlayerDeck(
      id: '__preview_placeholder_deck__',
      displayName: "Ur-Dragon's Horde",
      commanderName: 'The Ur-Dragon',
      commanderManaCost: '{2}{W}{U}{B}{R}{G}',
      commanderImageUrl: null,
      partnerCommanderName: null,
      partnerCommanderImageUrl: null,
      partnerManaCost: null,
      wins: 12,
      losses: 7,
      gamesPlayed: 19,
    ),
    PlayerDeck(
      id: '__preview_placeholder_deck_2__',
      displayName: 'Rograkh / Silas artifacts',
      commanderName: 'Rograkh, Son of Rohgahh',
      commanderManaCost: '{R}',
      commanderImageUrl: null,
      partnerCommanderName: 'Silas Renn, Seeker Adept',
      partnerCommanderImageUrl: null,
      partnerManaCost: '{U}{B}',
      wins: 8,
      losses: 4,
      gamesPlayed: 12,
    ),
    PlayerDeck(
      id: '__preview_placeholder_deck_3__',
      displayName: 'Feather storm',
      commanderName: 'Feather, the Redeemed',
      commanderManaCost: '{3}{R/W}{R}',
      commanderImageUrl: null,
      partnerCommanderName: null,
      partnerCommanderImageUrl: null,
      partnerManaCost: null,
      wins: 15,
      losses: 6,
      gamesPlayed: 21,
    ),
    PlayerDeck(
      id: '__preview_placeholder_deck_4__',
      displayName: 'Yuriko turns',
      commanderName: 'Yuriko, the Tiger\'s Shadow',
      commanderManaCost: '{1}{U}{B}',
      commanderImageUrl: null,
      partnerCommanderName: null,
      partnerCommanderImageUrl: null,
      partnerManaCost: null,
      wins: 6,
      losses: 5,
      gamesPlayed: 11,
    ),
  ];
}

class _DeckPerformanceSection extends ConsumerStatefulWidget {
  final AppColorTokens colors;
  /// When null, list fills remaining space inside an [Expanded] (one-screen layout).
  final double? listMaxHeight;

  const _DeckPerformanceSection({
    required this.colors,
    this.listMaxHeight,
  });

  @override
  ConsumerState<_DeckPerformanceSection> createState() =>
      _DeckPerformanceSectionState();
}

class _DeckPerformanceSectionState extends ConsumerState<_DeckPerformanceSection> {
  @override
  Widget build(BuildContext context) {
    ref.watch(deckListRevisionProvider);
    final repoDecks = List<PlayerDeck>.from(
      ref.read(deckRepositoryProvider).getAll(),
    )..sort((a, b) => b.gamesPlayed.compareTo(a.gamesPlayed));

    final decks =
        repoDecks.isEmpty ? _previewPlaceholderDecks() : repoDecks;
    final colors = widget.colors;
    final lh = widget.listMaxHeight;

    final list = _BentoAutoScrollList(
      maxHeight: lh,
      itemCount: decks.length,
      separator: Divider(
        height: 1,
        thickness: 1,
        color: colors.borderSubtle.withValues(alpha: 0.45),
      ),
      itemBuilder: (context, i) {
        final d = decks[i];
        return Padding(
          padding: EdgeInsets.only(
            top: i == 0 ? LayoutTokens.gr1 : LayoutTokens.gr2,
            bottom: LayoutTokens.gr2,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DeckCommanderAvatarCluster(
                deck: d,
                colors: colors,
                size: 80,
                portraitStyle: CommanderPortraitStyle.card,
              ),
              SizedBox(width: LayoutTokens.gr3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      d.displayName,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      d.hasPartner
                          ? '${d.commanderName} // ${d.partnerCommanderName}'
                          : d.commanderName,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (_deckHasManaForProfile(d)) ...[
                      SizedBox(height: LayoutTokens.gr1),
                      DeckManaCostRows(
                        commanderManaCost: d.commanderManaCost,
                        partnerManaCost: d.partnerManaCost,
                        hasPartner: d.hasPartner,
                        compact: false,
                      ),
                    ],
                    SizedBox(height: LayoutTokens.gr1),
                    DeckWinLossRatioBar(
                      deck: d,
                      colors: colors,
                      height: 6,
                    ),
                    SizedBox(height: LayoutTokens.gr1),
                    DeckStatChips(
                      deck: d,
                      colors: colors,
                      compact: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );

    final sampleFooter = repoDecks.isEmpty
        ? Padding(
            padding: EdgeInsets.only(top: LayoutTokens.gr2),
            child: Text(
              'Sample rows with commander mana (pips), win/loss bar, and '
              'stats. Add decks from the Decks tab and pick one in the lobby '
              'to see your real numbers here.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colors.textSecondary,
              ),
            ),
          )
        : null;

    return _BentoCard(
      colors: colors,
      gradientColors: [
        Color.lerp(colors.surfaceElevated, colors.primaryAccent, 0.10)!,
        colors.surfaceElevated,
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Deck performance',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                    color: colors.textPrimary,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.layers_outlined,
                  size: 22,
                  color: colors.primaryAccent,
                ),
                tooltip: 'Manage decks',
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                onPressed: () => context.go(AppRoutes.decks),
              ),
            ],
          ),
          SizedBox(height: LayoutTokens.gr2),
          if (lh == null)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: list),
                  if (sampleFooter != null) sampleFooter,
                ],
              ),
            )
          else ...[
            list,
            if (sampleFooter != null) sampleFooter,
          ],
        ],
      ),
    );
  }
}
