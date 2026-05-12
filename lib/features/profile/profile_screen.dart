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

/// Internal padding of every bento card.
/// Inner element radius = _kBentoRadiusPx − _kBentoCardPaddingPx (nested radius rule).
const double _kBentoCardPaddingPx = 16;

/// Bundled MTG art when no custom banner is set (from project mana assets).
const String _kDefaultBannerPlaceholderAsset = 'assets/mana/MYB/fullManaCost.png';

BorderRadius get _kBentoRadius =>
    const BorderRadius.all(Radius.circular(_kBentoRadiusPx));

/// Typical phones (≥360 logical width) use the side‑by‑side level/behaviour row to save height.
const double _kProfileStatsRowBreakpoint = 360;

/// Recent-games snap slot height for the vertical list inside the bento.
const double _kRecentMatchSnapSlotExtent = 132;

/// Title row is painted in a [Stack] overlay; list [ListView] top padding = title + gap (kept in sync).
const double _kRecentGamesOverlayTopInset = 38;

/// Max width for listing rows (deck + recent games); narrower viewports use full width.
const double _kBentoListingMaxContentWidth = 520;

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

/// Keeps bento section titles readable when list rows scroll underneath (stacked headers).
List<Shadow> _profileBentoTitleShadows(AppColorTokens colors) {
  return [
    Shadow(
      color: colors.backgroundPrimary.withValues(alpha: 0.94),
      blurRadius: 8,
      offset: const Offset(0, 1),
    ),
    Shadow(
      color: colors.surfaceElevated.withValues(alpha: 0.55),
      blurRadius: 4,
    ),
  ];
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

/// Bento section surface — Material 3 [Card] with tiered container color.
class _BentoCard extends StatelessWidget {
  const _BentoCard({
    required this.child,
    this.gradientColors,
  });

  final Widget child;
  final List<Color>? gradientColors;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final Color cardColor;
    if (gradientColors != null && gradientColors!.length >= 2) {
      cardColor = Color.lerp(gradientColors![0], gradientColors![1], 0.5)!;
    } else {
      cardColor = scheme.surfaceContainerHigh;
    }

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      color: cardColor,
      elevation: 1,
      surfaceTintColor: scheme.surfaceTint,
      shape: RoundedRectangleBorder(
        borderRadius: _kBentoRadius,
        side: BorderSide(
          color: scheme.outlineVariant.withValues(alpha: 0.65),
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(_kBentoCardPaddingPx),
        child: child,
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
            final hPad = isNarrow ? LayoutTokens.gr2 : LayoutTokens.gr3;

            final maxH = constraints.maxHeight;

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
                SliverToBoxAdapter(child: SizedBox(height: LayoutTokens.gr4)),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(hPad, 0, hPad, hPad),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _ProfileLevelBehaviourBentoRow(
                        profile: profile,
                        colors: colors,
                        bodyWidth: bodyW,
                      ),
                      SizedBox(height: LayoutTokens.gr4),
                      _DeckPerformanceSection(
                        colors: colors,
                        listMaxHeight:
                            (MediaQuery.sizeOf(context).height * 0.42)
                                .clamp(280.0, 560.0),
                      ),
                      SizedBox(height: LayoutTokens.gr4),
                      _RecentGamesModule(
                        matches: allMatches,
                        colors: colors,
                        listMaxHeight:
                            (MediaQuery.sizeOf(context).height * 0.42)
                                .clamp(280.0, 560.0),
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

/// Rounded hero card: banner art, banner action, floating stats pill.
class _ProfileHeroCard extends StatelessWidget {
  const _ProfileHeroCard({
    required this.profile,
    required this.colors,
  });

  final PlayerProfile profile;
  final AppColorTokens colors;

  static const double _defaultCardHeight = 340;

  @override
  Widget build(BuildContext context) {
    const cardHeight = _defaultCardHeight;
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
          placeholder: (ctx, _) => _defaultBannerFill(ctx),
          errorWidget: (ctx, _, __) => _defaultBannerFill(ctx),
        );
      }
      return Image.asset(
        _kDefaultBannerPlaceholderAsset,
        fit: BoxFit.cover,
        width: double.infinity,
        height: cardHeight,
        errorBuilder: (ctx, _, __) => _defaultBannerFill(ctx),
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
        SizedBox(height: LayoutTokens.gr0),
        Center(child: TierBadge(tier: profile.tier, level: profile.level)),
        SizedBox(height: LayoutTokens.gr2),
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
  });

  final PlayerProfile profile;
  final AppColorTokens colors;
  final double bodyWidth;

  /// Height for the wide two-column row in the scroll layout.
  static const double _kWideRowHeight = 268;

  @override
  Widget build(BuildContext context) {
    final xpNeeded = _xpNeededForLevel(profile.level);
    final xpInLevel = profile.xp % xpNeeded;
    final xpProgress =
        (xpNeeded > 0) ? (xpInLevel / xpNeeded).clamp(0.0, 1.0) : 0.0;

    final wide = bodyWidth >= _kProfileStatsRowBreakpoint;

    final levelCard = _BentoCard(
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

    if (wide) {
      return SizedBox(
        height: _kWideRowHeight,
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
    return stack;
  }
}

/// 0 = Good, 1 = Salty (from dislike ratio among reactions).
double _saltFraction(PlayerProfile profile) {
  final total = profile.likesReceived + profile.dislikesReceived;
  if (total == 0) return 0.5;
  return (profile.dislikesReceived / total).clamp(0.0, 1.0);
}

/// Gradient spectrum + thumb; [width] must be finite and positive for a visible bar.
Widget _behaviourSpectrumBar({
  required PlayerProfile profile,
  required AppColorTokens colors,
  required double width,
}) {
  final salt = _saltFraction(profile);
  final w =
      width.isFinite && width > 0 ? width : 280.0;
  final thumbX = 16.0 + (w - 32.0) * salt;
  return SizedBox(
    width: w,
    height: 22,
    child: Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.centerLeft,
      children: [
        Container(
          width: w,
          height: 14,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: colors.borderSubtle.withValues(alpha: 0.55),
              width: 1,
            ),
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
          top: 2,
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
    ),
  );
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

  /// Builds the donut + XP label block at a given [size].
  /// strokeWidth scales proportionally, clamped to [6, 10].
  Widget _donutBlock(BuildContext context, double size) {
    final stroke = (size / 112 * 10).clamp(6.0, 10.0);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: _AnimatedDonutGauge(
            targetProgress: xpProgress,
            size: size,
            strokeWidth: stroke,
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
                      fontSize: size < 90 ? 16 : null,
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
        SizedBox(height: LayoutTokens.gr1),
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
  }

  @override
  Widget build(BuildContext context) {
    const _kXpLabelH = 20.0; // label (~14px) + gr1 gap (6px)

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Level progress',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 18,
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
        SizedBox(height: LayoutTokens.gr2),
        if (fillHeight)
          // LayoutBuilder sizes donut to fit; FittedBox scales down any remaining
          // overflow (e.g. XP label at minimum donut size on very short cards).
          Expanded(
            child: LayoutBuilder(
              builder: (context, c) {
                final donutSize =
                    (c.maxHeight - _kXpLabelH).clamp(48.0, 112.0);
                return FittedBox(
                  fit: BoxFit.scaleDown,
                  child: _donutBlock(context, donutSize),
                );
              },
            ),
          )
        else
          _donutBlock(context, 112),
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
    Widget spectrumForConstraints(BoxConstraints c) {
      final w = c.maxWidth.isFinite && c.maxWidth > 0 ? c.maxWidth : 280.0;
      return _behaviourSpectrumBar(
        profile: profile,
        colors: colors,
        width: w,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Player behaviour',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 18,
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
        SizedBox(height: LayoutTokens.gr1),
        if (fillHeight)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, c) {
                      return Align(
                        alignment: Alignment.center,
                        child: spectrumForConstraints(c),
                      );
                    },
                  ),
                ),
                SizedBox(height: LayoutTokens.gr0),
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
                const SizedBox(height: 2),
                Text(
                  '${profile.likesReceived} likes · ${profile.dislikesReceived} dislikes',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.textSecondary,
                    fontSize: FontTokens.caption,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          )
        else ...[
          LayoutBuilder(
            builder: (context, c) => spectrumForConstraints(c),
          ),
          SizedBox(height: LayoutTokens.gr1),
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
          SizedBox(height: LayoutTokens.gr1),
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

/// Snaps scroll to multiples of [itemExtent] on fling/release.
class _SnapScrollPhysics extends ScrollPhysics {
  const _SnapScrollPhysics({required this.itemExtent, super.parent});

  final double itemExtent;

  @override
  _SnapScrollPhysics applyTo(ScrollPhysics? ancestor) =>
      _SnapScrollPhysics(itemExtent: itemExtent, parent: buildParent(ancestor));

  double _snapTarget(ScrollMetrics pos, double velocity, Tolerance tol) {
    double item = pos.pixels / itemExtent;
    if (velocity < -tol.velocity) {
      item -= 0.5;
    } else if (velocity > tol.velocity) {
      item += 0.5;
    }
    return (item.roundToDouble() * itemExtent)
        .clamp(pos.minScrollExtent, pos.maxScrollExtent);
  }

  @override
  Simulation? createBallisticSimulation(ScrollMetrics pos, double velocity) {
    if ((velocity <= 0.0 && pos.pixels <= pos.minScrollExtent) ||
        (velocity >= 0.0 && pos.pixels >= pos.maxScrollExtent)) {
      return super.createBallisticSimulation(pos, velocity);
    }
    final tol = toleranceFor(pos);
    final target = _snapTarget(pos, velocity, tol);
    if ((target - pos.pixels).abs() < tol.distance) return null;
    return ScrollSpringSimulation(
      spring,
      pos.pixels,
      target,
      velocity,
      tolerance: tol,
    );
  }

  @override
  bool get allowImplicitScrolling => false;
}

/// Scrollable list inside a bento with a fixed max height; auto-advances when idle.
class _BentoAutoScrollList extends StatefulWidget {
  const _BentoAutoScrollList({
    this.maxHeight,
    required this.itemCount,
    required this.itemBuilder,
    this.separator,
    this.snapScroll = true,
    this.snapItemExtent = _kRecentMatchSnapSlotExtent,
    this.scrollableTopInset = 0,
  });

  /// When null, the list expands within a parent [Expanded] (bounded height).
  final double? maxHeight;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final Widget? separator;
  /// When false, uses smooth [ClampingScrollPhysics]. Defaults to true (recent games).
  final bool snapScroll;
  /// Grid for snap physics and auto-advance when [snapScroll] is true.
  final double snapItemExtent;
  /// Space above the first list item (e.g. stacked section title overlay).
  final double scrollableTopInset;

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

    final o = _controller.offset;
    double target;
    if (widget.snapScroll) {
      final step = widget.snapItemExtent;
      final nextSnap = ((o / step).floor() + 1) * step;
      if (nextSnap >= max - 4) {
        target = 0;
      } else {
        target = nextSnap.clamp(0.0, max);
      }
    } else {
      final step = (pos.viewportDimension * 0.88).clamp(96.0, 520.0);
      if (o + step >= max - 4) {
        target = 0;
      } else {
        target = (o + step).clamp(0.0, max);
      }
    }

    _autoBusy = true;
    _programmatic = true;
    try {
      await _controller.animateTo(
        target,
        duration: Duration(
          milliseconds: target == 0 && o > 8 ? 650 : 520,
        ),
        curve: Curves.easeInOut,
      );
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
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
            scrollbars: false,
          ),
          child:
              widget.snapScroll
                  ? ListView.builder(
                      controller: _controller,
                      primary: false,
                      physics: _SnapScrollPhysics(
                        itemExtent: widget.snapItemExtent,
                      ),
                      padding: EdgeInsets.only(
                        top: widget.scrollableTopInset,
                        bottom: LayoutTokens.gr2,
                      ),
                      cacheExtent: 400,
                      itemCount: widget.itemCount,
                      itemBuilder: (context, i) {
                        return SizedBox(
                          height: widget.snapItemExtent,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: Align(
                                  alignment: Alignment.center,
                                  child: widget.itemBuilder(context, i),
                                ),
                              ),
                              if (i < widget.itemCount - 1)
                                widget.separator ??
                                    SizedBox(height: LayoutTokens.gr2),
                            ],
                          ),
                        );
                      },
                    )
                  : ListView.separated(
                      controller: _controller,
                      primary: false,
                      physics: const ClampingScrollPhysics(),
                      padding: EdgeInsets.only(
                        top: widget.scrollableTopInset,
                        bottom: LayoutTokens.gr2,
                      ),
                      cacheExtent: 400,
                      itemCount: widget.itemCount,
                      separatorBuilder:
                          (_, __) =>
                              widget.separator ??
                              SizedBox(height: LayoutTokens.gr2),
                      itemBuilder: widget.itemBuilder,
                    ),
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
  /// When null, list uses remaining flex height (one-screen layout).
  final double? listMaxHeight;

  const _RecentGamesModule({
    required this.matches,
    required this.colors,
    this.listMaxHeight,
  });

  @override
  Widget build(BuildContext context) {
    final c = colors;
    final listMaxHeight = this.listMaxHeight;
    const inset = _kRecentGamesOverlayTopInset;

    final titleStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
      fontSize: 18,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.2,
      color: c.textPrimary,
      shadows: _profileBentoTitleShadows(c),
    );

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

    final overlayHeader = Positioned(
      left: 0,
      right: 0,
      top: 0,
      child: IgnorePointer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Recent Games', style: titleStyle),
            SizedBox(height: LayoutTokens.gr1),
          ],
        ),
      ),
    );

    final double bodyHeight = listMaxHeight ?? 320.0;
    final Widget body = matches.isEmpty
        ? emptyPlaceholder
        : _RecentMatchListBody(
            matches: matches,
            colors: c,
            viewportHeight: bodyHeight,
            scrollableTopInset: inset,
          );

    return _BentoCard(
      gradientColors: [
        Color.lerp(c.surfaceElevated, ColorTokens.success, 0.08)!,
        c.surfaceElevated,
      ],
      child: SizedBox(
        height: bodyHeight,
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned.fill(child: body),
            overlayHeader,
          ],
        ),
      ),
    );
  }
}

/// List area: equal-height rows when all rows fit; otherwise scroll + snap.
class _RecentMatchListBody extends StatelessWidget {
  const _RecentMatchListBody({
    required this.matches,
    required this.colors,
    this.viewportHeight,
    this.scrollableTopInset = 0,
  });

  final List<MatchRecord> matches;
  final AppColorTokens colors;
  /// When set, height is known without [LayoutBuilder] (scroll-layout bento).
  final double? viewportHeight;
  /// Matches [_kRecentGamesOverlayTopInset] when titles use a [Stack] overlay.
  final double scrollableTopInset;

  static const double _kMinRowForEqualSplit = 56.0;

  bool _useEqualSlots(double h, int n, double gap) {
    if (n <= 0 || h <= 0) return false;
    if (n == 1) return true;
    final need = n * _kMinRowForEqualSplit + (n - 1) * gap;
    return need <= h;
  }

  @override
  Widget build(BuildContext context) {
    final gap = LayoutTokens.gr2;
    final n = matches.length;
    final inset = scrollableTopInset;

    Widget scrollList({double? maxH}) {
      return _BentoAutoScrollList(
        maxHeight: maxH ?? viewportHeight,
        scrollableTopInset: inset,
        snapScroll: true,
        snapItemExtent: _kRecentMatchSnapSlotExtent,
        separator: SizedBox(height: LayoutTokens.gr2),
        itemCount: n,
        itemBuilder: (context, i) {
          return _RecentMatchRow(match: matches[i], colors: colors);
        },
      );
    }

    if (viewportHeight != null) {
      final h = viewportHeight!;
      final innerH = (h - inset).clamp(0.0, double.infinity);
      if (_useEqualSlots(innerH, n, gap)) {
        return Padding(
          padding: EdgeInsets.only(top: inset),
          child: SizedBox(
            height: innerH,
            child: _RecentGamesEqualSlots(
              matches: matches,
              colors: colors,
              gap: gap,
              viewportHeight: innerH,
            ),
          ),
        );
      }
      return scrollList(maxH: h);
    }

    return LayoutBuilder(
      builder: (context, c) {
        final h = c.maxHeight;
        final innerH = (h - inset).clamp(0.0, double.infinity);
        if (_useEqualSlots(innerH, n, gap)) {
          return Padding(
            padding: EdgeInsets.only(top: inset),
            child: SizedBox(
              height: innerH,
              child: _RecentGamesEqualSlots(
                matches: matches,
                colors: colors,
                gap: gap,
                viewportHeight: innerH,
              ),
            ),
          );
        }
        return scrollList(maxH: h);
      },
    );
  }
}

/// Fills [viewportHeight] with [n] equal vertical slots and even [gap] between rows.
class _RecentGamesEqualSlots extends StatelessWidget {
  const _RecentGamesEqualSlots({
    required this.matches,
    required this.colors,
    required this.gap,
    required this.viewportHeight,
  });

  final List<MatchRecord> matches;
  final AppColorTokens colors;
  final double gap;
  final double viewportHeight;

  @override
  Widget build(BuildContext context) {
    final n = matches.length;
    return SizedBox(
      height: viewportHeight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (int i = 0; i < n; i++) ...[
            if (i > 0) SizedBox(height: gap),
            Expanded(
              child: LayoutBuilder(
                builder: (context, c) {
                  return _RecentMatchRow(
                    match: matches[i],
                    colors: colors,
                    slotHeight: c.maxHeight,
                  );
                },
              ),
            ),
          ],
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
  /// When set (equal-slot recent games layout), row fills this height and scrolls if needed.
  final double? slotHeight;

  const _RecentMatchRow({
    required this.match,
    required this.colors,
    this.slotHeight,
  });

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

    final innerR = BorderRadius.circular(_kBentoRadiusPx - _kBentoCardPaddingPx);
    final columnMainAxis =
        widget.slotHeight != null && !_open
            ? MainAxisAlignment.center
            : MainAxisAlignment.start;
    final paddedColumn = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: LayoutTokens.gr3,
        vertical: LayoutTokens.gr2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: columnMainAxis,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
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
              SizedBox(height: LayoutTokens.gr1),
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
    );

    final inkChild =
        widget.slotHeight != null
            ? SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: widget.slotHeight!),
                  child: paddedColumn,
                ),
              )
            : paddedColumn;

    Widget card = Material(
      color: colors.backgroundSecondary.withValues(alpha: 0.42),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: innerR,
        side: BorderSide(color: _resultColor.withValues(alpha: 0.42)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => setState(() => _open = !_open),
        borderRadius: innerR,
        child: inkChild,
      ),
    );

    if (widget.slotHeight != null) {
      card = SizedBox(height: widget.slotHeight, child: card);
    }

    return LayoutBuilder(
      builder: (context, c) {
        final w = math.min(_kBentoListingMaxContentWidth, c.maxWidth);
        return Align(
          alignment: Alignment.center,
          child: SizedBox(width: w, child: card),
        );
      },
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
  /// When null, list uses remaining flex height (one-screen layout).
  final double? listMaxHeight;

  const _DeckPerformanceSection({
    required this.colors,
    this.listMaxHeight,
  });

  @override
  ConsumerState<_DeckPerformanceSection> createState() =>
      _DeckPerformanceSectionState();
}

/// Horizontal card width — sized so 1.5 cards peek on a 360px-wide viewport
/// (signals "more to scroll") and 2+ cards show on wider devices.
const double _kDeckPerfCardWidth = 220;

/// Title row height (text + spacing) reserved inside the bento.
const double _kDeckPerfTitleHeight = 44;

class _DeckPerformanceSectionState
    extends ConsumerState<_DeckPerformanceSection> {
  late final ScrollController _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

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

    final deckTitleStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
      fontSize: 18,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.2,
      color: colors.textPrimary,
    );

    Widget horizontalList(double cardHeight) {
      return SizedBox(
        height: cardHeight,
        child: ListView.separated(
          controller: _scrollCtrl,
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.zero,
          physics: const BouncingScrollPhysics(),
          itemCount: decks.length,
          separatorBuilder: (_, __) => SizedBox(width: LayoutTokens.gr2),
          itemBuilder: (context, i) {
            return _DeckPerfCard(
              deck: decks[i],
              colors: colors,
              width: _kDeckPerfCardWidth,
              height: cardHeight,
            );
          },
        ),
      );
    }

    Widget titleRow() {
      return Row(
        children: [
          Expanded(child: Text('Deck performance', style: deckTitleStyle)),
          IconButton(
            icon: Icon(
              Icons.layers_outlined,
              size: 22,
              color: colors.primaryAccent,
            ),
            tooltip: 'Manage decks',
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            onPressed: () => context.go(AppRoutes.decks),
          ),
        ],
      );
    }

    return _BentoCard(
      gradientColors: [
        Color.lerp(colors.surfaceElevated, colors.primaryAccent, 0.10)!,
        colors.surfaceElevated,
      ],
      child: LayoutBuilder(
        builder: (context, c) {
          // Card height = remaining space below the title row when [lh] is set,
          // otherwise a sensible default for scroll/fallback layouts.
          final double cardHeight = (lh != null && lh.isFinite && lh > 0)
              ? math.max(180.0, lh - _kDeckPerfTitleHeight)
              : 240.0;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              titleRow(),
              SizedBox(height: LayoutTokens.gr2),
              horizontalList(cardHeight),
            ],
          );
        },
      ),
    );
  }
}

/// Vertical card showing one deck's commander art, names, mana, WR bar, and chips.
class _DeckPerfCard extends StatelessWidget {
  const _DeckPerfCard({
    required this.deck,
    required this.colors,
    required this.width,
    required this.height,
  });

  final PlayerDeck deck;
  final AppColorTokens colors;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: width,
      height: height,
      child: Card(
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
        color: scheme.surfaceContainerHigh,
        elevation: 1,
        surfaceTintColor: scheme.surfaceTint,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.55),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(LayoutTokens.gr2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: DeckCommanderAvatarCluster(
                  deck: deck,
                  colors: colors,
                  size: 76,
                  portraitStyle: CommanderPortraitStyle.card,
                ),
              ),
              SizedBox(height: LayoutTokens.gr2),
              Text(
                deck.displayName,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                deck.hasPartner
                    ? '${deck.commanderName} // ${deck.partnerCommanderName}'
                    : deck.commanderName,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (_deckHasManaForProfile(deck)) ...[
                SizedBox(height: LayoutTokens.gr1),
                DeckManaCostRows(
                  commanderManaCost: deck.commanderManaCost,
                  partnerManaCost: deck.partnerManaCost,
                  hasPartner: deck.hasPartner,
                  compact: true,
                ),
              ],
              const Spacer(),
              DeckWinLossRatioBar(deck: deck, colors: colors, height: 6),
              SizedBox(height: LayoutTokens.gr1),
              DeckStatChips(deck: deck, colors: colors, compact: true),
            ],
          ),
        ),
      ),
    );
  }
}
