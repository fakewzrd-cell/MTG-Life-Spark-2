import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/commander_stats.dart';
import '../../core/models/player_deck.dart';
import '../../core/models/player_profile.dart';
import '../../core/persistence/providers.dart';
import 'profile_optional_stat_ids.dart';
import '../../shared/utils/commander_image_resolver.dart';
import '../../shared/widgets/profile_default_banner.dart';
import '../../ui/theme/app_color_tokens.dart';
import '../../ui/tokens/font_tokens.dart';
import '../../ui/tokens/layout_tokens.dart';
import '../../ui/tokens/motion_tokens.dart';
import '../../ui/tokens/radius_tokens.dart';
import '../../ui/tokens/typography_tokens.dart';
import '../game/widgets/game_modal_chrome.dart';
import 'profile_carousel_sections.dart';

const String _kProfileUntilFirstGameMessage =
    'Play your first game to unlock stats and history.';

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

/// Highest-volume commander from hive stats with deck art when possible.
/// Fixed-size carousel card for the player stats horizontal shelf.
class _PlayerStatsCarouselTile extends StatelessWidget {
  const _PlayerStatsCarouselTile({
    required this.width,
    required this.height,
    required this.child,
    this.onLongPress,
    this.semanticsHint,
  });

  final double width;
  final double height;
  final Widget child;
  final VoidCallback? onLongPress;
  final String? semanticsHint;

  @override
  Widget build(BuildContext context) {
    Widget card = SizedBox(
      width: width,
      height: height,
      child: ProfileCarouselCard(child: child),
    );
    if (onLongPress == null) return card;
    return Semantics(
      hint: semanticsHint,
      child: GestureDetector(
        onLongPress: onLongPress,
        child: card,
      ),
    );
  }
}

Widget _mostPlayedTile({
  required bool hasPlayedGames,
  required PlayerProfile profile,
  required AppColorTokens colors,
  required CommanderStats? top,
}) {
  if (!hasPlayedGames) {
    return _PlayerStatsEmptyCard(
      title: 'Most played',
      colors: colors,
    );
  }
  if (top != null) {
    return _MostPlayedCard(
      profile: profile,
      colors: colors,
      top: top,
    );
  }
  return _PlayerStatsEmptyCard(
    title: 'Most played',
    colors: colors,
    message: 'No commander stats yet.',
  );
}

/// Deck with the lowest win rate among decks with at least one recorded game.
PlayerDeck? _pickWorstDeck(Iterable<PlayerDeck> decks) {
  final played = decks.where((d) => d.gamesPlayed > 0).toList();
  if (played.isEmpty) return null;
  played.sort((a, b) {
    final wr = a.winRate.compareTo(b.winRate);
    if (wr != 0) return wr;
    final lossCmp = b.losses.compareTo(a.losses);
    if (lossCmp != 0) return lossCmp;
    return a.wins.compareTo(b.wins);
  });
  return played.first;
}

class ProfilePlayerStatsSection extends ConsumerWidget {
  const ProfilePlayerStatsSection({
    required this.profile,
    required this.colors,
    required this.listMaxHeight,
    required this.hasPlayedGames,
  });

  final PlayerProfile profile;
  final AppColorTokens colors;
  final double listMaxHeight;
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

    final stats =
        List<CommanderStats>.from(
          ref.watch(profileRepositoryProvider).getAllCommanderStats(),
        )..sort((a, b) {
          final g = b.gamesPlayed.compareTo(a.gamesPlayed);
          if (g != 0) return g;
          return b.wins.compareTo(a.wins);
        });
    CommanderStats? top;
    if (hasPlayedGames &&
        stats.isNotEmpty &&
        stats.first.gamesPlayed > 0) {
      top = stats.first;
    }

    final worst = hasPlayedGames ? _pickWorstDeck(repoDecks) : null;

    final seenExtra = <String>{};
    final extraStatIds = <String>[];
    for (final id in profile.profileExtraStatIds) {
      if (ProfileOptionalStatIds.isKnown(id) && seenExtra.add(id)) {
        extraStatIds.add(id);
      }
    }
    final addableStatIds =
        ProfileOptionalStatIds.catalog
            .where((id) => !seenExtra.contains(id))
            .toList();

    final titleStyle = TypographyTokens.sectionTitle(colors.textPrimary);

    return LayoutBuilder(
      builder: (context, _) {
        final cardHeight = profileCarouselCardHeight(
          context,
          listMaxHeight: listMaxHeight,
        );
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
            child: _BehaviourBarCard(
              profile: profile,
              colors: colors,
              fillHeight: true,
            ),
          ),
          for (final statId in extraStatIds)
            _PlayerStatsCarouselTile(
              width: cardWidth,
              height: cardHeight,
              semanticsHint: 'Long press to remove',
              onLongPress: () => _confirmRemoveOptionalStat(
                context,
                ref,
                profile,
                statId,
              ),
              child: _optionalStatTile(
                statId: statId,
                hasPlayedGames: hasPlayedGames,
                profile: profile,
                colors: colors,
                top: top,
                worst: worst,
              ),
            ),
          if (addableStatIds.isNotEmpty)
            SizedBox(
              width: cardWidth,
              height: cardHeight,
              child: ProfileCarouselCard(
                padding: EdgeInsets.zero,
                affordance: true,
                child: ProfileCarouselAddCard(
                  colors: colors,
                  semanticsLabel: 'Add stat card',
                  onTap:
                      () => _showAddStatPicker(
                        context,
                        ref,
                        profile,
                        addableStatIds,
                      ),
                ),
              ),
            ),
        ];

        final statCount = 2 + extraStatIds.length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ProfileSectionHeader(
              title: 'Player stats',
              titleStyle: titleStyle,
              colors: colors,
              count: statCount,
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

Widget _optionalStatTile({
  required String statId,
  required bool hasPlayedGames,
  required PlayerProfile profile,
  required AppColorTokens colors,
  required CommanderStats? top,
  required PlayerDeck? worst,
}) {
  switch (statId) {
    case ProfileOptionalStatIds.mostPlayed:
      return _mostPlayedTile(
        hasPlayedGames: hasPlayedGames,
        profile: profile,
        colors: colors,
        top: top,
      );
    case ProfileOptionalStatIds.toughRecord:
      return hasPlayedGames && worst != null
          ? _WorstDeckCard(
            profile: profile,
            colors: colors,
            deck: worst,
          )
          : _PlayerStatsEmptyCard(
            title: 'Tough record',
            colors: colors,
            message:
                hasPlayedGames
                    ? 'No deck stats yet.'
                    : _kProfileUntilFirstGameMessage,
          );
    default:
      return const SizedBox.shrink();
  }
}

Future<void> _confirmRemoveOptionalStat(
  BuildContext context,
  WidgetRef ref,
  PlayerProfile profile,
  String statId,
) async {
  final title = ProfileOptionalStatIds.title(statId);
  final remove = await showGameChoiceDialog(
    context: context,
    title: 'Remove $title?',
    content: Text(
      'You can add this card again later from the + tile.',
      style: GameModalChrome.dialogBodyStyle(context),
    ),
    primaryLabel: 'Remove',
    secondaryLabel: 'Cancel',
    primaryDestructive: true,
  );
  if (remove != true) return;
  profile.profileExtraStatIds = [
    for (final id in profile.profileExtraStatIds)
      if (id != statId) id,
  ];
  await ref.read(profileRepositoryProvider).saveProfile(profile);
  bumpProfileRevision(ref);
}

Future<void> _showAddStatPicker(
  BuildContext context,
  WidgetRef ref,
  PlayerProfile profile,
  List<String> availableIds,
) {
  final colors = AppColorTokens.of(context);
  return showGameBottomSheet<void>(
    context: context,
    builder: (ctx) {
      return GameSheetBody(
        scrollable: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const GameSheetHeader(title: 'Add stat card'),
            SizedBox(height: LayoutTokens.gr1),
            Text(
              'Choose a card to show in your player stats row.',
              style: GameModalChrome.dialogBodyStyle(ctx),
            ),
            SizedBox(height: LayoutTokens.gr2),
            for (final id in availableIds) ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: RadiusTokens.radiusMd,
                ),
                title: Text(
                  ProfileOptionalStatIds.title(id),
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: Text(
                  ProfileOptionalStatIds.description(id),
                  style: TextStyle(
                    color: colors.textSecondary,
                    height: 1.3,
                  ),
                ),
                trailing: Icon(
                  Icons.add_circle_outline,
                  color: colors.primaryAccent,
                ),
                onTap: () async {
                  Navigator.pop(ctx);
                  profile.profileExtraStatIds = [
                    ...profile.profileExtraStatIds,
                    id,
                  ];
                  await ref
                      .read(profileRepositoryProvider)
                      .saveProfile(profile);
                  bumpProfileRevision(ref);
                },
              ),
              SizedBox(height: LayoutTokens.gr1),
            ],
          ],
        ),
      );
    },
  );
}

/// Stats carousel card before match history exists (or no commander/deck data yet).
class _PlayerStatsEmptyCard extends StatelessWidget {
  const _PlayerStatsEmptyCard({
    required this.title,
    required this.colors,
    this.message = _kProfileUntilFirstGameMessage,
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

/// Compact "62% WR · 8W–5L" line — mirrors [ProfileDeckCard]'s record line
/// so win rate leads consistently across every profile stat card, and
/// "Tough record" actually shows the number that justifies its name.
Widget _profileRecordLine({
  required int wins,
  required int losses,
  required int gamesPlayed,
  required AppColorTokens colors,
}) {
  final wr = gamesPlayed == 0 ? null : ((wins / gamesPlayed) * 100).round();
  final base = TextStyle(
    fontSize: FontTokens.sm,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );
  return Text.rich(
    TextSpan(
      style: base,
      children: [
        TextSpan(
          text: wr == null ? '— WR' : '$wr% WR',
          style: base.copyWith(
            color: colors.primaryAccent,
            fontWeight: FontWeight.w800,
          ),
        ),
        TextSpan(
          text: '  ·  ${wins}W–${losses}L',
          style: base.copyWith(color: colors.textSecondary),
        ),
      ],
    ),
    textAlign: TextAlign.center,
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
  );
}

Widget _profileRecordPlaceholder(String message, AppColorTokens colors) {
  return Text(
    message,
    textAlign: TextAlign.center,
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    style: TextStyle(
      fontSize: FontTokens.sm,
      color: colors.textSecondary,
      fontWeight: FontWeight.w600,
      height: 1.2,
    ),
  );
}

/// Shared layout for Most played / Worst deck player-stats tiles.
class _PlayerStatsHighlightCard extends StatelessWidget {
  const _PlayerStatsHighlightCard({
    required this.title,
    required this.colors,
    required this.primaryLabel,
    required this.statsLine,
    required this.imageUrl,
  });

  final String title;
  final AppColorTokens colors;
  final String primaryLabel;
  final Widget statsLine;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final innerRadius = RadiusTokens.carouselCard - kProfileCarouselCardPaddingPx;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _CarouselSectionHeader(title: title, colors: colors),
        SizedBox(height: LayoutTokens.gr2),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 5,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(innerRadius),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (imageUrl != null && imageUrl!.isNotEmpty)
                        CachedNetworkImage(
                          imageUrl: imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) =>
                              defaultBannerFill(context),
                          errorWidget: (_, __, ___) =>
                              defaultBannerFill(context),
                        )
                      else
                        defaultProfileBannerArt(context),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.08),
                              Colors.black.withValues(alpha: 0.65),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: LayoutTokens.gr2),
              Text(
                primaryLabel,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: FontTokens.hudSm + 1,
                  fontWeight: FontWeight.w800,
                  color: colors.textPrimary,
                  height: 1.2,
                  letterSpacing: -0.1,
                ),
              ),
              SizedBox(height: LayoutTokens.gr0),
              statsLine,
            ],
          ),
        ),
      ],
    );
  }
}

class _MostPlayedCard extends ConsumerWidget {
  const _MostPlayedCard({
    required this.profile,
    required this.colors,
    required this.top,
  });

  final PlayerProfile profile;
  final AppColorTokens colors;
  final CommanderStats? top;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commander = top;

    String? imageUrl;
    if (commander != null) {
      final decks =
          ref
              .watch(deckRepositoryProvider)
              .getAll()
              .where((d) => !isPreviewPlaceholderDeck(d));
      for (final d in decks) {
        if (d.commanderName.toLowerCase() ==
            commander.commanderName.toLowerCase()) {
          imageUrl = resolveDeckCommanderImageUrl(deck: d, profile: profile);
          break;
        }
      }
      imageUrl ??= profile.selectedCommanderImageUrl;
    }

    final commanderName = commander?.commanderName ?? 'No data yet';
    final statsLine = commander != null
        ? _profileRecordLine(
            wins: commander.wins,
            losses: commander.losses,
            gamesPlayed: commander.gamesPlayed,
            colors: colors,
          )
        : _profileRecordPlaceholder('Play games to see stats', colors);

    return _PlayerStatsHighlightCard(
      title: 'Most played',
      colors: colors,
      primaryLabel: commanderName,
      statsLine: statsLine,
      imageUrl: imageUrl,
    );
  }
}

class _WorstDeckCard extends ConsumerWidget {
  const _WorstDeckCard({
    required this.profile,
    required this.colors,
    required this.deck,
  });

  final PlayerProfile profile;
  final AppColorTokens colors;
  final PlayerDeck? deck;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final d = deck;
    final String? imageUrl =
        d == null
            ? null
            : resolveDeckCommanderImageUrl(deck: d, profile: profile);
    final primaryLabel = d?.displayName ?? 'No data yet';
    final statsLine = d != null
        ? _profileRecordLine(
            wins: d.wins,
            losses: d.losses,
            gamesPlayed: d.gamesPlayed,
            colors: colors,
          )
        : _profileRecordPlaceholder('Add a deck and play matches', colors);

    return _PlayerStatsHighlightCard(
      title: 'Tough record',
      colors: colors,
      primaryLabel: primaryLabel,
      statsLine: statsLine,
      imageUrl: imageUrl,
    );
  }
}

/// 0 = Good, 1 = Salty (from dislike ratio among reactions).
double _saltFraction(PlayerProfile profile) {
  final total = profile.likesReceived + profile.dislikesReceived;
  if (total == 0) return 0.5;
  return (profile.dislikesReceived / total).clamp(0.0, 1.0);
}

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
  required PlayerProfile profile,
  required AppColorTokens colors,
}) {
  final salt = _saltFraction(profile);
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
  required PlayerProfile profile,
  required AppColorTokens colors,
  required double width,
}) {
  final salt = _saltFraction(profile);
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

  return SizedBox(
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
              border: Border.all(
                color: colors.borderSubtle.withValues(alpha: 0.55),
                width: 1,
              ),
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

  /// Reserve for the `… / … XP` line at the bottom of the card (fill-height layout).
  static const double _kBottomXpLabelReserveH = 24.0;

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
                  fontWeight: FontWeight.w800,
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
    return Center(
      child: _AnimatedXpInLevelLabel(
        targetXpInLevel: xpInLevel,
        xpNeeded: xpNeeded,
        level: profile.level,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: colors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
  /// When true (wide row), spectrum block expands so the card matches level progress height.
  final bool fillHeight;

  /// Smiley (44) + spectrum track (20) + axis row + reaction line — remainder split evenly.
  static const double _kFillBehaviourCoreH = 100.0;
  static const int _kFillBehaviourBandGaps = 4;

  static double _fillBehaviourBandGap(double maxHeight, double layoutTextScale) {
    final core = _kFillBehaviourCoreH * layoutTextScale;
    final slack = maxHeight - core;
    final raw = slack / _kFillBehaviourBandGaps;
    if (!raw.isFinite) return LayoutTokens.gr1;
    return math.max(0.0, raw);
  }

  @override
  Widget build(BuildContext context) {
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _CarouselSectionHeader(
          title: 'Player behaviour',
          colors: colors,
        ),
        SizedBox(height: LayoutTokens.gr2),
        if (fillHeight)
          Expanded(
            child: LayoutBuilder(
              builder: (context, c) {
                final w =
                    c.maxWidth.isFinite && c.maxWidth > 0 ? c.maxWidth : 280.0;
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
                        profile: profile,
                        colors: colors,
                      ),
                    ),
                    SizedBox(height: bandGap),
                    _behaviourSpectrumTrack(
                      profile: profile,
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
              profile: profile,
              colors: colors,
            ),
          ),
          SizedBox(height: LayoutTokens.gr1),
          LayoutBuilder(
            builder: (context, c) {
              final w =
                  c.maxWidth.isFinite && c.maxWidth > 0 ? c.maxWidth : 280.0;
              return _behaviourSpectrumTrack(
                profile: profile,
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
