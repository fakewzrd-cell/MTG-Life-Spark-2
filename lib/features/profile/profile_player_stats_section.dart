import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/game/game_format.dart';
import '../../core/models/match_record.dart';
import '../../core/models/player_deck.dart';
import '../../core/models/player_profile.dart';
import '../../core/persistence/providers.dart';
import '../../shared/utils/commander_image_resolver.dart';
import '../../shared/utils/wizard_rank_titles.dart';
import '../../shared/widgets/profile_default_banner.dart';
import '../../ui/theme/app_color_tokens.dart';
import '../../ui/tokens/font_tokens.dart';
import '../../ui/tokens/layout_tokens.dart';
import '../../ui/tokens/motion_tokens.dart';
import '../../ui/tokens/radius_tokens.dart';
import '../../ui/tokens/typography_tokens.dart';
import 'profile_carousel_sections.dart';
import 'ranks_info_sheet.dart';

/// Chronological win flags (oldest → newest). Returns current and best streaks.
({int current, int best}) computeWinStreaks(List<bool> winsOldestFirst) {
  if (winsOldestFirst.isEmpty) return (current: 0, best: 0);
  var best = 0;
  var run = 0;
  for (final won in winsOldestFirst) {
    if (won) {
      run += 1;
      if (run > best) best = run;
    } else {
      run = 0;
    }
  }
  var current = 0;
  for (var i = winsOldestFirst.length - 1; i >= 0; i--) {
    if (!winsOldestFirst[i]) break;
    current += 1;
  }
  return (current: current, best: best);
}

({int current, int best}) computeWinStreaksFromMatches(
  Iterable<MatchRecord> matches,
) {
  final ordered = List<MatchRecord>.from(matches)
    ..sort((a, b) => a.date.compareTo(b.date));
  return computeWinStreaks([
    for (final m in ordered) m.result == 'win',
  ]);
}

double _profileLayoutTextScale(BuildContext context) {
  final t = MediaQuery.textScalerOf(context).scale(1.0);
  if (!t.isFinite || t <= 0) return 1.0;
  return t.clamp(1.0, 1.45);
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
  static const _duration = MotionTokens.emphasis;

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

/// Fixed-size carousel card for the player stats horizontal shelf.
class _PlayerStatsCarouselTile extends StatelessWidget {
  const _PlayerStatsCarouselTile({
    required this.width,
    required this.height,
    required this.child,
    this.edgeToEdge = false,
  });

  final double width;
  final double height;
  final Widget child;

  /// When true, content paints full-bleed (recent-games style).
  final bool edgeToEdge;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ProfileCarouselCard(
        padding: edgeToEdge ? EdgeInsets.zero : null,
        child: child,
      ),
    );
  }
}

/// Saved deck with the most recorded games (tie-break: more wins).
@visibleForTesting
PlayerDeck? pickMostPlayedDeck(Iterable<PlayerDeck> decks) {
  final played = decks.where((d) => d.gamesPlayed > 0).toList();
  if (played.isEmpty) return null;
  played.sort((a, b) {
    final g = b.gamesPlayed.compareTo(a.gamesPlayed);
    if (g != 0) return g;
    return b.wins.compareTo(a.wins);
  });
  return played.first;
}

/// Deck with the lowest win rate among decks that have actually lost a game.
///
/// Undefeated decks are excluded so "Tough record" never highlights a winner.
@visibleForTesting
PlayerDeck? pickWorstDeck(Iterable<PlayerDeck> decks) {
  final beaten = decks
      .where((d) => d.gamesPlayed > 0 && d.losses > 0)
      .toList();
  if (beaten.isEmpty) return null;
  beaten.sort((a, b) {
    final wr = a.winRate.compareTo(b.winRate);
    if (wr != 0) return wr;
    final lossCmp = b.losses.compareTo(a.losses);
    if (lossCmp != 0) return lossCmp;
    return a.wins.compareTo(b.wins);
  });
  return beaten.first;
}

class ProfilePlayerStatsSection extends ConsumerWidget {
  const ProfilePlayerStatsSection({super.key, 
    required this.profile,
    required this.colors,
    required this.hasPlayedGames,
  });

  final PlayerProfile profile;
  final AppColorTokens colors;
  final bool hasPlayedGames;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(deckListRevisionProvider);
    final repoDecks =
        ref
            .watch(deckRepositoryProvider)
            .getAll()
            .where((d) => !isPreviewPlaceholderDeck(d))
            .toList();
    final (xpInLevel, xpNeeded) = ref
        .read(profileRepositoryProvider)
        .computeXpProgress(profile.xp);
    final xpProgress =
        (xpNeeded > 0) ? (xpInLevel / xpNeeded).clamp(0.0, 1.0) : 0.0;

    final mostPlayed =
        hasPlayedGames ? pickMostPlayedDeck(repoDecks) : null;
    final worst = hasPlayedGames ? pickWorstDeck(repoDecks) : null;

    final matches = ref
        .watch(matchRepositoryProvider)
        .getAllMatches()
        .where((m) => !m.matchId.startsWith('__preview_placeholder'))
        .toList();
    final streaks = computeWinStreaksFromMatches(matches);
    // Prefer match history when present; fall back to persisted streak.
    final currentStreak = matches.isNotEmpty
        ? streaks.current
        : (hasPlayedGames ? profile.currentWinStreak : 0);
    final bestStreak = matches.isNotEmpty
        ? math.max(streaks.best, profile.currentWinStreak)
        : (hasPlayedGames ? profile.currentWinStreak : 0);

    final titleStyle = TypographyTokens.sectionTitle(colors.textPrimary);

    return LayoutBuilder(
      builder: (context, _) {
        final cardHeight = profileCarouselCardHeight(context);
        final cardWidth = kProfileCarouselCardWidth;

        final tiles = <Widget>[
          _PlayerStatsCarouselTile(
            width: cardWidth,
            height: cardHeight,
            child: _LevelDonutCard(
              profile: profile,
              colors: colors,
              xpNeeded: xpNeeded,
              xpInLevel: xpInLevel,
              xpProgress: xpProgress,
              fillHeight: true,
            ),
          ),
          _PlayerStatsCarouselTile(
            width: cardWidth,
            height: cardHeight,
            child: _RecordCard(
              profile: profile,
              colors: colors,
              hasPlayedGames: hasPlayedGames,
              fillHeight: true,
            ),
          ),
          _PlayerStatsCarouselTile(
            width: cardWidth,
            height: cardHeight,
            child: _WinStreakCard(
              colors: colors,
              hasPlayedGames: hasPlayedGames,
              currentStreak: currentStreak,
              bestStreak: bestStreak,
              fillHeight: true,
            ),
          ),
          _PlayerStatsCarouselTile(
            width: cardWidth,
            height: cardHeight,
            child: hasPlayedGames
                ? _BehaviourBarCard(
                    profile: profile,
                    colors: colors,
                    fillHeight: true,
                  )
                : _PlayerStatsEmptyCard(
                    title: 'Player behaviour',
                    colors: colors,
                    message: kProfileUntilFirstGameMessage,
                  ),
          ),
          _PlayerStatsCarouselTile(
            width: cardWidth,
            height: cardHeight,
            edgeToEdge: hasPlayedGames && mostPlayed != null,
            child: hasPlayedGames && mostPlayed != null
                ? _DeckHighlightCard(
                    title: 'Most played',
                    profile: profile,
                    deck: mostPlayed,
                    statKind: _DeckHighlightStat.wins,
                  )
                : _PlayerStatsEmptyCard(
                    title: 'Most played',
                    colors: colors,
                    message: hasPlayedGames
                        ? 'No deck stats yet.'
                        : kProfileUntilFirstGameMessage,
                  ),
          ),
          _PlayerStatsCarouselTile(
            width: cardWidth,
            height: cardHeight,
            edgeToEdge: hasPlayedGames && worst != null,
            child: hasPlayedGames && worst != null
                ? _DeckHighlightCard(
                    title: 'Tough record',
                    profile: profile,
                    deck: worst,
                    statKind: _DeckHighlightStat.losses,
                  )
                : _PlayerStatsEmptyCard(
                    title: 'Tough record',
                    colors: colors,
                    message: hasPlayedGames
                        ? 'No losses on a saved deck yet.'
                        : kProfileUntilFirstGameMessage,
                  ),
          ),
        ];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ProfileSectionHeader(
              title: 'Player stats',
              titleStyle: titleStyle,
              colors: colors,
              count: tiles.length,
              singularUnit: 'stat',
              pluralUnit: 'stats',
            ),
            SizedBox(height: LayoutTokens.gr2),
            SizedBox(
              height: cardHeight,
              child: ListView.separated(
                primary: false,
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                padding: EdgeInsets.only(right: LayoutTokens.gr1),
                physics: kProfileHorizontalCarouselPhysics,
                itemCount: tiles.length,
                separatorBuilder: (_, __) =>
                    SizedBox(width: LayoutTokens.gr2),
                itemBuilder: (_, i) => tiles[i],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Stats carousel card before match history exists (or no commander/deck data yet).
class _PlayerStatsEmptyCard extends StatelessWidget {
  const _PlayerStatsEmptyCard({
    required this.title,
    required this.colors,
    this.message = kProfileUntilFirstGameMessage,
  });

  final String title;
  final AppColorTokens colors;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _CarouselSectionHeader(title: title, colors: colors),
        SizedBox(height: LayoutTokens.gr2),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: LayoutTokens.gr1),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                  fontSize: FontTokens.sm,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

enum _DeckHighlightStat { wins, losses }

/// Full-bleed deck highlight (Most played / Tough record), recent-games style.
class _DeckHighlightCard extends ConsumerWidget {
  const _DeckHighlightCard({
    required this.title,
    required this.profile,
    required this.deck,
    required this.statKind,
  });

  final String title;
  final PlayerProfile profile;
  final PlayerDeck deck;
  final _DeckHighlightStat statKind;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matches = ref
        .watch(matchRepositoryProvider)
        .getAllMatches()
        .where((m) => !isPreviewPlaceholderMatchId(m.matchId));
    final imageUrl = resolveDeckCommanderImageUrl(
          deck: deck,
          profile: profile,
        ) ??
        resolveCommanderArtByName(
          commanderName: deck.commanderName,
          decks: [deck],
          profile: profile,
          matches: matches,
          localPlayerId: profile.playerId,
        );

    final count = switch (statKind) {
      _DeckHighlightStat.wins => deck.wins,
      _DeckHighlightStat.losses => deck.losses,
    };
    final statLabel = switch (statKind) {
      _DeckHighlightStat.wins => count == 1 ? '1 Win' : '$count Wins',
      _DeckHighlightStat.losses => count == 1 ? '1 Loss' : '$count Losses',
    };

    return Stack(
      fit: StackFit.expand,
      children: [
        if (imageUrl != null && imageUrl.isNotEmpty)
          CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            placeholder: (_, __) => defaultBannerFill(context),
            errorWidget: (_, __, ___) => defaultBannerFill(context),
          )
        else
          defaultProfileBannerArt(context),
        profileArtCardVignette(),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: LayoutTokens.gr3,
            vertical: LayoutTokens.gr3,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.78),
                  fontSize: FontTokens.caption,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
              SizedBox(height: LayoutTokens.gr2),
              Text(
                deck.displayName,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: FontTokens.body,
                  fontWeight: FontWeight.w700,
                  height: 1.15,
                  letterSpacing: -0.2,
                ),
              ),
              SizedBox(height: LayoutTokens.gr1),
              Text(
                deck.gameFormat.displayName,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.72),
                  fontSize: FontTokens.caption,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: LayoutTokens.gr2),
              Text(
                statLabel,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: FontTokens.headline,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Behaviour spectrum position in \[0, 1\]: 0 = Good, 0.5 = Neutral, 1 = Salty.
///
/// Starts neutral with no reactions. Likes nudge left; dislikes nudge right.
/// Uses a soft curve so early feedback does not slam the knob to an extreme.
@visibleForTesting
double behaviourSaltFraction({
  required int likes,
  required int dislikes,
}) {
  final l = likes < 0 ? 0 : likes;
  final d = dislikes < 0 ? 0 : dislikes;
  if (l == 0 && d == 0) return 0.5;
  // Higher = slower drift from center; ~4 keeps first few reactions gentle.
  const scale = 4.0;
  final net = (l - d).toDouble();
  // softsign in (-1, 1); +likes → Good (left).
  final signed = net / (scale + net.abs());
  return (0.5 - 0.5 * signed).clamp(0.0, 1.0);
}

double _saltFraction(PlayerProfile profile) => behaviourSaltFraction(
      likes: profile.likesReceived,
      dislikes: profile.dislikesReceived,
    );

IconData _behaviourSmileyIcon(double salt) {
  if (salt < 0.28) return Icons.sentiment_very_satisfied_rounded;
  if (salt < 0.42) return Icons.sentiment_satisfied_alt_rounded;
  if (salt < 0.58) return Icons.sentiment_neutral_rounded;
  if (salt < 0.72) return Icons.sentiment_dissatisfied_rounded;
  return Icons.sentiment_very_dissatisfied_rounded;
}

Color _behaviourSmileyColor(double salt, AppColorTokens colors) {
  return Color.lerp(
        colors.textMuted,
        colors.primaryAccent,
        salt,
      ) ??
      colors.textPrimary;
}

/// Sentiment icon for the behaviour card (centered separately from the track).
Widget _behaviourSmileyMark({
  required double salt,
  required AppColorTokens colors,
}) {
  const double dp = 44.0;
  return Icon(
    _behaviourSmileyIcon(salt),
    size: dp,
    color: _behaviourSmileyColor(salt, colors),
    shadows: [
      Shadow(
        color: colors.backgroundPrimary.withValues(alpha: 0.9),
        blurRadius: 2,
      ),
    ],
  );
}

/// Gradient spectrum track + thumb only; [width] must be finite and positive.
Widget _behaviourSpectrumTrack({
  required double salt,
  required AppColorTokens colors,
  required double width,
}) {
  final w =
      width.isFinite && width > 0 ? width : 280.0;
  const double sideInset = 16.0;
  final double trackUsableW = math.max(0.0, w - 2 * sideInset);
  const double barHeight = 14.0;
  const double thumbSize = 18.0;
  final double knobCenterX = sideInset + trackUsableW * salt;
  final double knobLeft = (knobCenterX - thumbSize / 2).clamp(
    0.0,
    math.max(0.0, w - thumbSize),
  );
  final double h = thumbSize;
  final double barTop = (thumbSize - barHeight) / 2;
  final saltPct = (salt * 100).round();
  final leaning = saltPct < 45
      ? 'leaning good'
      : saltPct > 55
          ? 'leaning salty'
          : 'neutral';

  return Semantics(
    label: 'Behaviour spectrum, $leaning',
    value: '$saltPct% toward salty',
    child: SizedBox(
    width: w,
    height: h,
    child: Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.centerLeft,
      children: [
        Positioned(
          left: 0,
          top: barTop,
          child: Container(
            width: w,
            height: barHeight,
            decoration: BoxDecoration(
              borderRadius: RadiusTokens.radiusPill,
              gradient: LinearGradient(
                colors: [
                  colors.textMuted,
                  colors.textSecondary,
                  colors.primaryAccent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: knobLeft,
          top: 0,
          child: Container(
            width: thumbSize,
            height: thumbSize,
            decoration: BoxDecoration(
              color: colors.textPrimary,
              shape: BoxShape.circle,
              border: Border.all(
                color: colors.backgroundPrimary,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    ),
  ),
  );
}

/// Centered title for carousel stat cards (Level, Behaviour, Most played, etc.).
class _CarouselSectionHeader extends StatelessWidget {
  const _CarouselSectionHeader({
    required this.title,
    required this.colors,
  });

  final String title;
  final AppColorTokens colors;

  static const double _minRowHeight = 32;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: _minRowHeight),
      child: Center(
        child: Text(
          title,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TypographyTokens.cardTitle(colors.textPrimary),
        ),
      ),
    );
  }
}

/// Career W–L with win rate as the hero metric.
class _RecordCard extends StatefulWidget {
  const _RecordCard({
    required this.profile,
    required this.colors,
    required this.hasPlayedGames,
    this.fillHeight = false,
  });

  final PlayerProfile profile;
  final AppColorTokens colors;
  final bool hasPlayedGames;
  final bool fillHeight;

  @override
  State<_RecordCard> createState() => _RecordCardState();
}

class _RecordCardState extends State<_RecordCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _wrAnim;

  int get _targetWr {
    final wins = widget.profile.totalWins;
    final losses = widget.profile.totalLosses;
    final games = widget.profile.totalGamesPlayed > 0
        ? widget.profile.totalGamesPlayed
        : wins + losses;
    return games == 0 ? 0 : ((wins / games) * 100).round().clamp(0, 100);
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: MotionTokens.emphasis,
    );
    _wrAnim = Tween<double>(begin: 0, end: _targetWr.toDouble()).animate(
      CurvedAnimation(parent: _controller, curve: MotionTokens.easeOut),
    );
    if (widget.hasPlayedGames && widget.profile.totalGamesPlayed > 0) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant _RecordCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = _targetWr.toDouble();
    if (oldWidget.profile.totalWins != widget.profile.totalWins ||
        oldWidget.profile.totalLosses != widget.profile.totalLosses ||
        oldWidget.profile.totalGamesPlayed !=
            widget.profile.totalGamesPlayed) {
      _wrAnim = Tween<double>(begin: _wrAnim.value, end: next).animate(
        CurvedAnimation(parent: _controller, curve: MotionTokens.easeOut),
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
    if (!widget.hasPlayedGames || widget.profile.totalGamesPlayed <= 0) {
      return _PlayerStatsEmptyCard(
        title: 'Record',
        colors: widget.colors,
      );
    }

    final wins = widget.profile.totalWins;
    final losses = widget.profile.totalLosses;
    final games = widget.profile.totalGamesPlayed > 0
        ? widget.profile.totalGamesPlayed
        : wins + losses;
    final colors = widget.colors;

    Widget hero(int wr) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$wr%',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: colors.primaryAccent,
              fontFeatures: const [FontFeature.tabularFigures()],
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: LayoutTokens.gr0),
          Text(
            'Win rate',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    Widget footer() {
      return Text(
        '${wins}W–${losses}L  ·  $games games',
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: colors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    return AnimatedBuilder(
      animation: _wrAnim,
      builder: (context, _) {
        final wr = _wrAnim.value.round().clamp(0, 100);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _CarouselSectionHeader(title: 'Record', colors: colors),
            SizedBox(height: LayoutTokens.gr2),
            if (widget.fillHeight)
              Expanded(
                child: Column(
                  children: [
                    Expanded(child: Center(child: hero(wr))),
                    footer(),
                  ],
                ),
              )
            else ...[
              Center(child: hero(wr)),
              SizedBox(height: LayoutTokens.gr2),
              footer(),
            ],
          ],
        );
      },
    );
  }
}

/// Current win streak with best-from-history as supporting context.
class _WinStreakCard extends StatefulWidget {
  const _WinStreakCard({
    required this.colors,
    required this.hasPlayedGames,
    required this.currentStreak,
    required this.bestStreak,
    this.fillHeight = false,
  });

  final AppColorTokens colors;
  final bool hasPlayedGames;
  final int currentStreak;
  final int bestStreak;
  final bool fillHeight;

  @override
  State<_WinStreakCard> createState() => _WinStreakCardState();
}

class _WinStreakCardState extends State<_WinStreakCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _countAnim;
  late Animation<double> _flameScale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: MotionTokens.emphasis,
    );
    _countAnim = Tween<double>(
      begin: 0,
      end: widget.currentStreak.toDouble(),
    ).animate(CurvedAnimation(parent: _controller, curve: MotionTokens.easeOut));
    _flameScale = Tween<double>(begin: 0.55, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: MotionTokens.enter),
    );
    if (widget.hasPlayedGames) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant _WinStreakCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentStreak != widget.currentStreak) {
      _countAnim = Tween<double>(
        begin: _countAnim.value,
        end: widget.currentStreak.toDouble(),
      ).animate(
        CurvedAnimation(parent: _controller, curve: MotionTokens.easeOut),
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
    if (!widget.hasPlayedGames) {
      return _PlayerStatsEmptyCard(
        title: 'Win streak',
        colors: widget.colors,
      );
    }

    final colors = widget.colors;
    final flame = widget.currentStreak > 0;

    Widget footer() {
      final bestLabel = widget.bestStreak <= 0
          ? 'Win to start a streak'
          : widget.bestStreak == widget.currentStreak &&
                  widget.currentStreak > 0
              ? 'Personal best'
              : 'Best: ${widget.bestStreak}';
      return Text(
        bestLabel,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: colors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final shown = _countAnim.value.round().clamp(0, 999);
        Widget hero() {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: _flameScale,
                child: Icon(
                  flame
                      ? Icons.local_fire_department_rounded
                      : Icons.local_fire_department_outlined,
                  size: 28,
                  color: flame ? colors.primaryAccent : colors.textMuted,
                ),
              ),
              SizedBox(height: LayoutTokens.gr1),
              Text(
                '$shown',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: LayoutTokens.gr0),
              Text(
                widget.currentStreak == 0 ? 'No active streak' : 'Current',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _CarouselSectionHeader(title: 'Win streak', colors: colors),
            SizedBox(height: LayoutTokens.gr2),
            if (widget.fillHeight)
              Expanded(
                child: Column(
                  children: [
                    Expanded(child: Center(child: hero())),
                    footer(),
                  ],
                ),
              )
            else ...[
              Center(child: hero()),
              SizedBox(height: LayoutTokens.gr2),
              footer(),
            ],
          ],
        );
      },
    );
  }
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

  /// Reserve for rank + `… / … XP` lines at the bottom of the card.
  static const double _kBottomXpLabelReserveH = 42.0;

  static const double _kDonutSizeMin = 56.0;
  static const double _kDonutSizeMax = 172.0;
  static const double _kDonutStrokeReferenceSize = 140.0;

  /// Donut + center (% + level) only; stroke scales with [size].
  Widget _donutGaugeOnly(BuildContext context, double size) {
    final stroke =
        (size / _kDonutStrokeReferenceSize * 12).clamp(8.0, 14.0);
    return Center(
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
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  fontSize: size < 100 ? 17 : 20,
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
    );
  }

  Widget _xpNumeralsLine(BuildContext context) {
    final rank = wizardRankTitle(profile.level);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          rank,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: colors.primaryAccent,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 2),
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
    final card = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _CarouselSectionHeader(
          title: 'Level progress',
          colors: colors,
        ),
        SizedBox(height: LayoutTokens.gr2),
        if (fillHeight)
          Expanded(
            child: LayoutBuilder(
              builder: (context, c) {
                final layoutTs = _profileLayoutTextScale(context);
                final bottomReserve = _kBottomXpLabelReserveH * layoutTs;
                final widthLimit = c.maxWidth.isFinite && c.maxWidth > 0
                    ? c.maxWidth
                    : _kDonutSizeMax;
                final heightLimit =
                    math.max(0.0, c.maxHeight - bottomReserve);
                final donutSize = math
                    .min(widthLimit, heightLimit)
                    .clamp(_kDonutSizeMin, _kDonutSizeMax);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: _donutGaugeOnly(context, donutSize),
                        ),
                      ),
                    ),
                    _xpNumeralsLine(context),
                  ],
                );
              },
            ),
          )
        else
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _donutGaugeOnly(context, _kDonutSizeMax),
              SizedBox(height: LayoutTokens.gr2),
              _xpNumeralsLine(context),
            ],
          ),
      ],
    );

    return Semantics(
      button: true,
      label: 'Level progress. View all ranks.',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => showRanksInfoSheet(
            context,
            currentLevel: profile.level,
          ),
          borderRadius: BorderRadius.circular(RadiusTokens.carouselCard),
          child: card,
        ),
      ),
    );
  }
}

class _BehaviourBarCard extends StatefulWidget {
  const _BehaviourBarCard({
    required this.profile,
    required this.colors,
    this.fillHeight = false,
  });

  final PlayerProfile profile;
  final AppColorTokens colors;
  /// When true (wide row), spectrum block expands so the card matches level progress height.
  final bool fillHeight;

  @override
  State<_BehaviourBarCard> createState() => _BehaviourBarCardState();
}

class _BehaviourBarCardState extends State<_BehaviourBarCard>
    with SingleTickerProviderStateMixin {
  /// Smiley (44) + spectrum track (20) + axis row + reaction line — remainder split evenly.
  static const double _kFillBehaviourCoreH = 100.0;
  static const int _kFillBehaviourBandGaps = 4;

  late final AnimationController _controller;
  late Animation<double> _saltAnim;

  double get _targetSalt => _saltFraction(widget.profile);

  static double _fillBehaviourBandGap(double maxHeight, double layoutTextScale) {
    final core = _kFillBehaviourCoreH * layoutTextScale;
    final slack = maxHeight - core;
    final raw = slack / _kFillBehaviourBandGaps;
    if (!raw.isFinite) return LayoutTokens.gr1;
    return math.max(0.0, raw);
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: MotionTokens.emphasis,
    );
    // Start neutral, then ease to the real position when the card builds
    // (typically as the carousel scrolls it into view).
    _saltAnim = Tween<double>(begin: 0.5, end: _targetSalt).animate(
      CurvedAnimation(parent: _controller, curve: MotionTokens.easeOut),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant _BehaviourBarCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile.likesReceived != widget.profile.likesReceived ||
        oldWidget.profile.dislikesReceived !=
            widget.profile.dislikesReceived) {
      _saltAnim = Tween<double>(begin: _saltAnim.value, end: _targetSalt)
          .animate(
        CurvedAnimation(parent: _controller, curve: MotionTokens.easeOut),
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
    final colors = widget.colors;
    final profile = widget.profile;

    Widget axisRow() {
      return Row(
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
      );
    }

    Widget reactionsLine() {
      return Text(
        '${profile.likesReceived} likes · ${profile.dislikesReceived} dislikes',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: colors.textSecondary,
          fontSize: FontTokens.caption,
        ),
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    return AnimatedBuilder(
      animation: _saltAnim,
      builder: (context, _) {
        final salt = _saltAnim.value.clamp(0.0, 1.0);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _CarouselSectionHeader(
              title: 'Player behaviour',
              colors: colors,
            ),
            SizedBox(height: LayoutTokens.gr2),
            if (widget.fillHeight)
              Expanded(
                child: LayoutBuilder(
                  builder: (context, c) {
                    final w = c.maxWidth.isFinite && c.maxWidth > 0
                        ? c.maxWidth
                        : 280.0;
                    final bandGap = _fillBehaviourBandGap(
                      c.maxHeight,
                      _profileLayoutTextScale(context),
                    );
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: bandGap),
                        Center(
                          child: _behaviourSmileyMark(
                            salt: salt,
                            colors: colors,
                          ),
                        ),
                        SizedBox(height: bandGap),
                        _behaviourSpectrumTrack(
                          salt: salt,
                          colors: colors,
                          width: w,
                        ),
                        SizedBox(height: bandGap),
                        axisRow(),
                        SizedBox(height: bandGap),
                        reactionsLine(),
                      ],
                    );
                  },
                ),
              )
            else ...[
              Center(
                child: _behaviourSmileyMark(
                  salt: salt,
                  colors: colors,
                ),
              ),
              SizedBox(height: LayoutTokens.gr1),
              LayoutBuilder(
                builder: (context, c) {
                  final w = c.maxWidth.isFinite && c.maxWidth > 0
                      ? c.maxWidth
                      : 280.0;
                  return _behaviourSpectrumTrack(
                    salt: salt,
                    colors: colors,
                    width: w,
                  );
                },
              ),
              SizedBox(height: LayoutTokens.gr1),
              axisRow(),
              SizedBox(height: LayoutTokens.gr1),
              reactionsLine(),
            ],
          ],
        );
      },
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
  static const _duration = MotionTokens.emphasis;

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
