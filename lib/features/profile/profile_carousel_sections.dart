import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../core/game/game_format.dart';
import '../../core/models/match_record.dart';
import '../../core/models/player_deck.dart';
import '../../core/models/player_profile.dart';
import '../../core/persistence/providers.dart';
import '../../shared/constants/app_icons.dart';
import '../../shared/widgets/game_icon.dart';
import '../../shared/utils/app_router.dart';
import '../../shared/utils/commander_image_resolver.dart';
import '../../shared/widgets/deck_tile_visual.dart';
import '../../shared/widgets/mana_cost_pips.dart';
import '../../ui/theme/app_color_tokens.dart';
import '../../ui/tokens/color_tokens.dart';
import '../../ui/tokens/font_tokens.dart';
import '../../ui/tokens/layout_tokens.dart';
import '../../ui/tokens/motion_tokens.dart';
import '../../ui/tokens/radius_tokens.dart';
import '../../ui/tokens/typography_tokens.dart';

const String _kProfileUntilFirstGameMessage =
    'Play your first game to unlock stats and history.';

const String _kProfileAddDeckMessage =
    'Add a deck to track commander performance here.';

/// Interior padding for 240×360 carousel cards ([LayoutTokens.gr3]).
/// Inner art radius = [RadiusTokens.carouselCard] − padding (nested radius rule).
const double kProfileCarouselCardPaddingPx = LayoutTokens.gr3;

const double _kCarouselCardPaddingPx = kProfileCarouselCardPaddingPx;
const double _kCarouselCardBorderAlpha = 0.55;
BorderRadius get _kProfileCarouselCardRadius => RadiusTokens.radiusCarouselCard;

RoundedRectangleBorder _profileCarouselCardShape(ColorScheme scheme) {
  return RoundedRectangleBorder(
    borderRadius: _kProfileCarouselCardRadius,
    side: BorderSide(
      color: scheme.outlineVariant.withValues(alpha: _kCarouselCardBorderAlpha),
      width: 1,
    ),
  );
}

Widget _defaultBannerFill(BuildContext context) {
  final scheme = Theme.of(context).colorScheme;
  return ColoredBox(color: scheme.surfaceContainerHighest);
}

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

Widget _recentMatchCommanderArt(BuildContext context, String? imageUrl) {
  if (imageUrl != null && imageUrl.isNotEmpty) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      placeholder: (_, __) => _defaultBannerFill(context),
      errorWidget: (_, __, ___) => _defaultBannerFill(context),
    );
  }
  return _defaultProfileBannerArt(context);
}

Widget _recentMatchCardVignette({bool expanded = false}) {
  if (expanded) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(color: Colors.black.withValues(alpha: 0.38)),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.05),
                Colors.black.withValues(alpha: 0.55),
              ],
            ),
          ),
        ),
      ],
    );
  }
  return ColoredBox(color: Colors.black.withValues(alpha: 0.42));
}

const List<Shadow> _recentMatchOverlayShadow = [
  Shadow(color: Color(0xF0000000), blurRadius: 16, offset: Offset(0, 2)),
  Shadow(color: Color(0xB3000000), blurRadius: 6, offset: Offset(0, 1)),
];

/// Full-height carousel card with centered guidance copy (empty profile sections).
class ProfileCarouselPlaceholderCard extends StatelessWidget {
  const ProfileCarouselPlaceholderCard({
    required this.message,
    required this.colors,
    required this.width,
    required this.height,
  });

  final String message;
  final AppColorTokens colors;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ProfileCarouselCard(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: LayoutTokens.gr2),
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
    );
  }
}

/// Shared add affordance for carousel cards (decks shelf, optional stats).
class ProfileCarouselAddGlyph extends StatelessWidget {
  const ProfileCarouselAddGlyph({required this.colors});

  final AppColorTokens colors;

  static const double circleSize = 60;
  static const double iconSize = 28;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: circleSize,
      height: circleSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.primaryAccent.withValues(alpha: 0.14),
        border: Border.all(
          color: colors.primaryAccent.withValues(alpha: 0.45),
          width: 2,
        ),
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.add_rounded,
        size: iconSize,
        color: colors.primaryAccent,
      ),
    );
  }
}

/// "+" carousel card — full-card tap target (matches player-stats add card).
class ProfileCarouselAddCard extends StatelessWidget {
  const ProfileCarouselAddCard({
    required this.colors,
    required this.onTap,
    required this.semanticsLabel,
  });

  final AppColorTokens colors;
  final VoidCallback onTap;
  final String semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticsLabel,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: RadiusTokens.radiusCarouselCard,
          child: SizedBox.expand(
            child: Center(
              child: ProfileCarouselAddGlyph(colors: colors),
            ),
          ),
        ),
      ),
    );
  }
}

class ProfileCarouselCard extends StatelessWidget {
  const ProfileCarouselCard({
    super.key,
    required this.child,
    this.padding,
  });

  final Widget child;

  /// When null, uses standard carousel card inset ([_kCarouselCardPaddingPx]).
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      color: scheme.surfaceContainerHigh,
      elevation: 1,
      surfaceTintColor: scheme.surfaceTint,
      shape: _profileCarouselCardShape(scheme),
      child: Padding(
        padding: padding ?? EdgeInsets.all(_kCarouselCardPaddingPx),
        child: child,
      ),
    );
  }
}

/// Horizontal carousel physics — nested inside profile [CustomScrollView].
const ScrollPhysics kProfileHorizontalCarouselPhysics = BouncingScrollPhysics(
  parent: AlwaysScrollableScrollPhysics(),
);

/// Section title + optional count pill + optional trailing control (e.g. filter).
class ProfileSectionHeader extends StatelessWidget {
  const ProfileSectionHeader({
    required this.title,
    required this.titleStyle,
    required this.colors,
    this.count,
    this.singularUnit,
    this.pluralUnit,
    this.trailing,
  });

  final String title;
  final TextStyle titleStyle;
  final AppColorTokens colors;
  final int? count;
  final String? singularUnit;
  final String? pluralUnit;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            title,
            style: titleStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (count != null && singularUnit != null && pluralUnit != null) ...[
          SizedBox(width: LayoutTokens.gr2),
          ProfileSectionCountPill(
            count: count!,
            colors: colors,
            singularUnit: singularUnit!,
            pluralUnit: pluralUnit!,
          ),
        ],
        if (trailing != null) ...[
          SizedBox(width: LayoutTokens.gr1),
          trailing!,
        ],
      ],
    );
  }
}

/// Accent count pill for profile section headers (My Decks, Deck performance, etc.).
class ProfileSectionCountPill extends StatelessWidget {
  const ProfileSectionCountPill({
    required this.count,
    required this.colors,
    required this.singularUnit,
    required this.pluralUnit,
  });

  final int count;
  final AppColorTokens colors;
  final String singularUnit;
  final String pluralUnit;

  @override
  Widget build(BuildContext context) {
    final label =
        count == 1 ? '1 $singularUnit' : '$count $pluralUnit';
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: LayoutTokens.gr2,
        vertical: LayoutTokens.gr1,
      ),
      decoration: BoxDecoration(
        color: colors.primaryAccent.withValues(alpha: 0.12),
        borderRadius: RadiusTokens.radiusChip,
        border: Border.all(
          color: colors.primaryAccent.withValues(alpha: 0.35),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: colors.primaryAccent,
          fontSize: FontTokens.sm,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}

/// Shared width for profile/My Decks horizontal carousel cards.
const double kProfileCarouselCardWidth = LayoutTokens.profileCarouselCardWidth;

/// Fixed height for every carousel card (same on all pages).
const double kProfileCarouselCardHeight = LayoutTokens.profileCarouselCardCanonicalHeight;

/// MTG card art proportion (63×88) for commander portraits in deck cards.
const double _kDeckPortraitWidthOverHeight = 63 / 88;

const double _kProfileDeckCardPortraitMin = 72;
const double _kProfileDeckCardPortraitMax = 200;

/// Line heights for deck card footer (matches [ProfileDeckCard] text styles).
const double _kDeckCardTitleLine = 18;
const double _kDeckCardSubtitleLine = 15;
const double _kDeckCardMetaLine = 14;

/// Estimated footer height so commander art shrinks instead of overflowing.
double profileDeckCardFooterReserveHeight(
  PlayerDeck deck, {
  double textScale = 1.0,
}) {
  final ts = textScale.clamp(1.0, 1.35);
  // Title + commander + combined format/style + gap (see [ProfileDeckCard]).
  var h = (_kDeckCardTitleLine + _kDeckCardSubtitleLine + _kDeckCardMetaLine) *
      ts +
      LayoutTokens.gr0;
  if (deck.isCommanderDeck && _deckHasManaForProfile(deck)) {
    h += (LayoutTokens.gr1 + (deck.hasPartner ? 32.0 : 16.0)) * ts;
  }
  // W/L bar + 2×2 carousel chip grid ([DeckStatChips.forCarousel]).
  h += (LayoutTokens.gr1 + 8 + LayoutTokens.gr1 + 56) * ts;
  return h + LayoutTokens.gr1 * ts;
}

/// Smallest card height that fits the heaviest deck footer + minimum art band.
double profileDeckCardMinHeight({double textScale = 1.0}) {
  final heavy = PlayerDeck(
    id: '_layout_probe',
    displayName: 'Probe',
    commanderName: 'Commander // Partner',
    partnerCommanderName: 'Partner',
    commanderManaCost: '{2}{U}{R}',
    partnerManaCost: '{1}{W}',
    format: 'commander',
    deckStyleId: 'voltron',
  );
  final footer = profileDeckCardFooterReserveHeight(heavy, textScale: textScale);
  return footer + _kProfileDeckCardPortraitMin + 2 * kProfileCarouselCardPaddingPx;
}

/// Commander art band height inside a deck card (fits remaining space).
double profileDeckCardArtHeight(
  double cardWidth,
  double cardHeight, {
  required PlayerDeck deck,
  required bool hasPartner,
}) {
  final innerW = cardWidth - 2 * kProfileCarouselCardPaddingPx;
  final innerH = cardHeight - 2 * kProfileCarouselCardPaddingPx;
  final footer = profileDeckCardFooterReserveHeight(deck);
  final maxByFooter = math.max(_kProfileDeckCardPortraitMin, innerH - footer);
  final wRatio = hasPartner
      ? _kDeckPortraitWidthOverHeight * (1 + 0.35 * 0.58)
      : _kDeckPortraitWidthOverHeight;
  final byCardRatio = innerW / wRatio;
  return math.min(byCardRatio, maxByFooter).clamp(
    _kProfileDeckCardPortraitMin,
    math.min(_kProfileDeckCardPortraitMax, maxByFooter),
  );
}

/// Fixed 2:3 height for every carousel card (240×360 at default width).
///
/// [listMaxHeight] is ignored — all profile/My Decks carousels share one size.
double profileCarouselCardHeight(
  BuildContext context, {
  double? listMaxHeight,
}) {
  return LayoutTokens.profileCarouselCardCanonicalHeight;
}

/// Canonical carousel tile size (width × height) for layout tests and tiles.
Size profileCarouselCardSize() => Size(
  kProfileCarouselCardWidth,
  kProfileCarouselCardHeight,
);

bool _deckHasManaForProfile(PlayerDeck d) {
  final c = d.commanderManaCost?.trim();
  final p = d.partnerManaCost?.trim();
  return (c != null && c.isNotEmpty) ||
      (d.hasPartner && p != null && p.isNotEmpty);
}

/// Time window for Recent Games list filtering.
enum _RecentGamesTimeFilter {
  all,
  recent,
  thisWeek,
  thisMonth,
}

extension _RecentGamesTimeFilterLabel on _RecentGamesTimeFilter {
  String get menuLabel => switch (this) {
    _RecentGamesTimeFilter.all => 'All games',
    _RecentGamesTimeFilter.recent => 'Recent (14 days)',
    _RecentGamesTimeFilter.thisWeek => 'This week',
    _RecentGamesTimeFilter.thisMonth => 'This month',
  };
}

DateTime _startOfLocalWeekMonday(DateTime d) {
  final day = DateTime(d.year, d.month, d.day);
  final diff = day.weekday - DateTime.monday;
  return day.subtract(Duration(days: diff));
}

List<MatchRecord> _filterMatchesForRecentGames(
  List<MatchRecord> matches,
  _RecentGamesTimeFilter filter,
) {
  final sorted = List<MatchRecord>.from(matches)
    ..sort((a, b) => b.date.compareTo(a.date));
  final now = DateTime.now();
  switch (filter) {
    case _RecentGamesTimeFilter.all:
      return sorted;
    case _RecentGamesTimeFilter.recent:
      final startOfToday = DateTime(now.year, now.month, now.day);
      final cutoff = startOfToday.subtract(const Duration(days: 14));
      return sorted.where((m) => !m.date.isBefore(cutoff)).toList();
    case _RecentGamesTimeFilter.thisWeek:
      final start = _startOfLocalWeekMonday(now);
      return sorted.where((m) => !m.date.isBefore(start)).toList();
    case _RecentGamesTimeFilter.thisMonth:
      final start = DateTime(now.year, now.month, 1);
      return sorted.where((m) => !m.date.isBefore(start)).toList();
  }
}

Color _recentMatchResultColor(MatchRecord m, AppColorTokens colors) {
  if (m.result == 'win') return ColorTokens.success;
  return colors.primaryAccent;
}

String _recentMatchResultLabel(MatchRecord m) {
  if (m.result == 'win') return 'Win';
  if (m.result == 'concede') return 'Concede';
  return 'Loss';
}

String _recentMatchPlayerInitials(String name) {
  final t = name.trim();
  if (t.isEmpty) return '?';
  final parts = t.split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();
  if (parts.length >= 2) {
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
  return t.length >= 2 ? t.substring(0, 2).toUpperCase() : t.toUpperCase();
}

Widget _recentMatchDetailRow(
  BuildContext context,
  AppColorTokens colors,
  String label,
  String value, {
  bool compact = false,
}) {
  final labelStyle = Theme.of(context).textTheme.labelMedium?.copyWith(
    color: colors.textSecondary,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.2,
    fontSize: compact ? FontTokens.caption : null,
  );
  final valueStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
    color: colors.textPrimary,
    fontWeight: FontWeight.w600,
    fontSize: compact ? FontTokens.sm : null,
    height: compact ? 1.25 : null,
  );
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(label, style: labelStyle, maxLines: 1, overflow: TextOverflow.ellipsis),
      SizedBox(height: compact ? LayoutTokens.gr0 : LayoutTokens.gr1),
      Text(
        value,
        style: valueStyle,
        maxLines: compact ? 2 : 3,
        overflow: TextOverflow.ellipsis,
      ),
    ],
  );
}

class ProfileRecentGamesModule extends StatefulWidget {
  final List<MatchRecord> matches;
  final AppColorTokens colors;
  final double listMaxHeight;

  const ProfileRecentGamesModule({
    required this.matches,
    required this.colors,
    required this.listMaxHeight,
  });

  @override
  State<ProfileRecentGamesModule> createState() =>
      _ProfileRecentGamesModuleState();
}

class _ProfileRecentGamesModuleState extends State<ProfileRecentGamesModule> {
  _RecentGamesTimeFilter _filter = _RecentGamesTimeFilter.all;
  late final ScrollController _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ProfileRecentGamesModule oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.matches.isEmpty && _filter != _RecentGamesTimeFilter.all) {
      setState(() => _filter = _RecentGamesTimeFilter.all);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.colors;
    final lh = widget.listMaxHeight;
    final filtered = _filterMatchesForRecentGames(widget.matches, _filter);
    final showFilterMenu = widget.matches.isNotEmpty;

    final titleStyle = TypographyTokens.sectionTitle(c.textPrimary);

    Widget titleRow() {
      return ProfileSectionHeader(
        title: 'Recent games',
        titleStyle: titleStyle,
        colors: c,
        count: filtered.length,
        singularUnit: 'game',
        pluralUnit: 'games',
        trailing: showFilterMenu
            ? PopupMenuButton<_RecentGamesTimeFilter>(
                tooltip: 'Filter: ${_filter.menuLabel}',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: kMinInteractiveDimension,
                  minHeight: kMinInteractiveDimension,
                ),
                onSelected: (v) => setState(() => _filter = v),
                icon: Icon(
                  Icons.filter_list_rounded,
                  size: 22,
                  color: c.primaryAccent,
                ),
                itemBuilder: (context) => [
                  for (final f in _RecentGamesTimeFilter.values)
                    CheckedPopupMenuItem<_RecentGamesTimeFilter>(
                      value: f,
                      checked: f == _filter,
                      child: Text(f.menuLabel),
                    ),
                ],
              )
            : null,
      );
    }

    final cardHeight = profileCarouselCardHeight(context, listMaxHeight: lh);

    if (widget.matches.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          titleRow(),
          SizedBox(height: LayoutTokens.gr2),
          SizedBox(
            height: cardHeight,
            child: ListView(
              primary: false,
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              physics: kProfileHorizontalCarouselPhysics,
              children: [
                ProfileCarouselPlaceholderCard(
                  message: _kProfileUntilFirstGameMessage,
                  colors: c,
                  width: kProfileCarouselCardWidth,
                  height: cardHeight,
                ),
              ],
            ),
          ),
        ],
      );
    }

    if (filtered.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          titleRow(),
          SizedBox(height: LayoutTokens.gr2),
          SizedBox(
            height: cardHeight,
            child: ListView(
              primary: false,
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              physics: kProfileHorizontalCarouselPhysics,
              children: [
                ProfileCarouselPlaceholderCard(
                  message: 'No matches for this filter.',
                  colors: c,
                  width: kProfileCarouselCardWidth,
                  height: cardHeight,
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        titleRow(),
        SizedBox(height: LayoutTokens.gr2),
        SizedBox(
          height: cardHeight,
          child: ListView.separated(
            primary: false,
            controller: _scrollCtrl,
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            padding: EdgeInsets.only(right: LayoutTokens.gr1),
            physics: kProfileHorizontalCarouselPhysics,
            itemCount: filtered.length,
            separatorBuilder: (_, __) => SizedBox(width: LayoutTokens.gr2),
            itemBuilder: (context, i) {
              return _ProfileRecentMatchCard(
                key: ValueKey<String>(filtered[i].matchId),
                match: filtered[i],
                colors: c,
                width: kProfileCarouselCardWidth,
                height: cardHeight,
              );
            },
          ),
        ),
      ],
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

/// Readable match structure for Recent Games (uses [MatchRecord.matchTypeLabel]).
String _recentMatchStructureLine(MatchRecord m) {
  final raw = m.matchTypeLabel;
  final label = raw
      .replaceAll('1vs1', '1 vs 1')
      .replaceAll('2vs2', '2 vs 2');
  final n =
      m.participantSnapshots.isNotEmpty
          ? m.participantSnapshots.length
          : m.playerCount;
  if (n >= 2) return '$label · $n players';
  return label;
}

int _recentMatchPlayerCount(MatchRecord m) {
  if (m.participantSnapshots.isNotEmpty) {
    return m.participantSnapshots.length;
  }
  return m.playerCount;
}

/// Best-effort winner row for profile recent-game tiles ([MatchRecord.result]
/// is from the local player's perspective).
List<MatchParticipantSnapshot> _participantsByPlacement(
  List<MatchParticipantSnapshot> snaps,
) {
  final list = List<MatchParticipantSnapshot>.from(snaps);
  list.sort((a, b) {
    final ar = a.placementRank > 0 ? a.placementRank : 999;
    final br = b.placementRank > 0 ? b.placementRank : 999;
    if (ar != br) return ar.compareTo(br);
    if (a.isWinner != b.isWinner) return a.isWinner ? -1 : 1;
    final al = a.finalLife ?? 0;
    final bl = b.finalLife ?? 0;
    return bl.compareTo(al);
  });
  return list;
}

MatchParticipantSnapshot? _winnerParticipantForRecentCard(
  MatchRecord m,
  PlayerProfile? profile,
) {
  final snaps = m.participantSnapshots;
  if (snaps.isEmpty) return null;

  for (final p in snaps) {
    if (p.isWinner) return p;
  }

  MatchParticipantSnapshot? localSnap;
  final un = profile?.username.trim().toLowerCase();
  for (final p in snaps) {
    final pn = p.username.trim().toLowerCase();
    if (un != null && un.isNotEmpty && pn == un) {
      localSnap = p;
      break;
    }
    if (p.playerId == 'local') {
      localSnap = p;
      break;
    }
  }
  localSnap ??= snaps.first;

  if (m.result == 'win') {
    return localSnap;
  }
  for (final p in snaps) {
    if (p.playerId != localSnap.playerId) return p;
  }
  return snaps.length > 1 ? snaps[1] : localSnap;
}

bool _participantSnapshotIsLocal(
  MatchParticipantSnapshot p,
  PlayerProfile? profile,
) {
  if (profile != null &&
      p.username.trim().toLowerCase() ==
          profile.username.trim().toLowerCase()) {
    return true;
  }
  return p.playerId == 'local';
}

/// Commander art for recent-game tiles: snapshot URL, then saved deck lookup.
String? _resolveCommanderImageForRecentCard(
  WidgetRef ref,
  MatchParticipantSnapshot? participant,
  MatchRecord match,
  PlayerProfile? profile,
) {
  if (participant == null) return null;

  final stored = participant.commanderImageUrl?.trim();
  if (stored != null && stored.isNotEmpty) return stored;

  final commander = participant.commanderName?.trim();
  if (commander != null && commander.isNotEmpty) {
    final decks = ref.read(deckRepositoryProvider).getAll();
    for (final d in decks) {
      if (d.commanderName.toLowerCase() == commander.toLowerCase()) {
        final url = d.commanderImageUrl?.trim();
        if (url != null && url.isNotEmpty) return url;
      }
    }
  }

  if (_participantSnapshotIsLocal(participant, profile)) {
    final deckId = match.localDeckIdSnapshot?.trim();
    if (deckId != null && deckId.isNotEmpty) {
      final deck = ref.read(deckRepositoryProvider).getById(deckId);
      final url = deck?.commanderImageUrl?.trim();
      if (url != null && url.isNotEmpty) return url;
    }
    final selected = profile?.selectedCommanderImageUrl?.trim();
    if (selected != null && selected.isNotEmpty) return selected;
  }

  return null;
}

/// One match: collapsed summary; tap expands to full details (horizontal list).
class _ProfileRecentMatchCard extends ConsumerStatefulWidget {
  const _ProfileRecentMatchCard({
    super.key,
    required this.match,
    required this.colors,
    required this.width,
    required this.height,
  });

  final MatchRecord match;
  final AppColorTokens colors;
  final double width;
  final double height;

  @override
  ConsumerState<_ProfileRecentMatchCard> createState() =>
      _ProfileRecentMatchCardState();
}

class _ProfileRecentMatchCardState extends ConsumerState<_ProfileRecentMatchCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final m = widget.match;
    final colors = widget.colors;
    final fmt = DateFormat('MMM d, y');
    final timeFmt = DateFormat('HH:mm');
    final dateStr = fmt.format(m.date);
    final timeStr = timeFmt.format(m.date);
    final secs = m.durationSecondsEffective;
    final participants = m.participantSnapshots;
    final resultColor = _recentMatchResultColor(m, colors);
    final resultLabel = _recentMatchResultLabel(m);
    final n = _recentMatchPlayerCount(m);
    final playerLine = '$n ${n == 1 ? 'player' : 'players'}';

    final structureStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: colors.textSecondary,
      fontWeight: FontWeight.w600,
      fontSize: 12,
      height: 1.35,
    );
    final formatStyle = Theme.of(context).textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.w800,
      letterSpacing: -0.15,
      height: 1.25,
      color: colors.textPrimary,
    );
    final metaStyle = Theme.of(context).textTheme.titleSmall?.copyWith(
      color: colors.textSecondary,
      fontWeight: FontWeight.w700,
      height: 1.2,
    );
    final dateStyle = Theme.of(context).textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.w800,
      color: colors.textPrimary,
      height: 1.2,
    );

    final resultPill = Container(
      padding: EdgeInsets.symmetric(
        horizontal: LayoutTokens.gr2,
        vertical: LayoutTokens.gr1,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.48),
        borderRadius: RadiusTokens.radiusSm,
        border: Border.all(
          color: resultColor.withValues(alpha: 0.65),
          width: 1,
        ),
      ),
      child: Text(
        resultLabel,
        style: TextStyle(
          color: resultColor,
          fontWeight: FontWeight.w800,
          fontSize: FontTokens.caption,
          letterSpacing: 0.15,
          shadows: _recentMatchOverlayShadow,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );

    final structureLine = _recentMatchStructureLine(m);

    final innerPad = _kCarouselCardPaddingPx;
    final expandedInnerH = math.max(0.0, widget.height - 2 * innerPad);
    final profile = ref.watch(profileProvider).profile;
    final winner = _winnerParticipantForRecentCard(m, profile);
    final commanderImageUrl = _resolveCommanderImageForRecentCard(
      ref,
      winner,
      m,
      profile,
    );

    Widget summaryForeground() {
      final overlayFormatStyle = formatStyle!.copyWith(
        color: Colors.white,
        fontSize: 17,
        fontWeight: FontWeight.w900,
        height: 1.32,
        letterSpacing: -0.2,
        shadows: _recentMatchOverlayShadow,
      );
      final overlayMetaStyle = metaStyle!.copyWith(
        color: Colors.white.withValues(alpha: 0.94),
        fontSize: 13,
        height: 1.35,
        shadows: _recentMatchOverlayShadow,
      );
      final overlayDateStyle = dateStyle!.copyWith(
        color: Colors.white,
        fontSize: 14,
        height: 1.3,
        shadows: _recentMatchOverlayShadow,
      );

      return Padding(
        padding: EdgeInsets.all(LayoutTokens.gr3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [resultPill],
            ),
            const Spacer(),
            Text(
              m.format,
              style: overlayFormatStyle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: LayoutTokens.gr1),
            Text(
              playerLine,
              style: overlayMetaStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: LayoutTokens.gr1),
            Text(
              '$dateStr · $timeStr',
              style: overlayDateStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: LayoutTokens.gr3),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  if (!_expanded) setState(() => _expanded = true);
                },
                style: OutlinedButton.styleFrom(
                  visualDensity: VisualDensity.standard,
                  padding: EdgeInsets.symmetric(
                    horizontal: LayoutTokens.gr3,
                    vertical: LayoutTokens.gr2,
                  ),
                  minimumSize: const Size(double.infinity, 44),
                  tapTargetSize: MaterialTapTargetSize.padded,
                  shape: const StadiumBorder(),
                  side: BorderSide(
                    color: Colors.white.withValues(alpha: 0.72),
                    width: 1.25,
                  ),
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.black.withValues(alpha: 0.38),
                ),
                child: Text(
                  'Show more',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    letterSpacing: 0.2,
                    color: Colors.white,
                    shadows: _recentMatchOverlayShadow,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    Widget detailsColumn(double maxHeight) {
      final metaBlocks = <Widget>[
        _recentMatchDetailRow(
          context,
          colors,
          'Duration',
          _formatDurationSeconds(secs),
          compact: true,
        ),
        if (m.podNameSnapshot != null && m.podNameSnapshot!.isNotEmpty)
          _recentMatchDetailRow(
            context,
            colors,
            'Pod',
            m.podNameSnapshot!,
            compact: true,
          ),
        if (m.localDeckIdSnapshot != null &&
            m.localDeckIdSnapshot!.isNotEmpty)
          _recentMatchDetailRow(
            context,
            colors,
            'Deck',
            ref
                    .read(deckRepositoryProvider)
                    .getById(m.localDeckIdSnapshot!)
                    ?.displayName ??
                m.localDeckIdSnapshot!,
            compact: true,
          ),
      ];

      Widget? playersBlock;
      if (participants.isNotEmpty) {
        playersBlock = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Players',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: colors.textSecondary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
                fontSize: FontTokens.caption,
              ),
            ),
            SizedBox(height: LayoutTokens.gr0),
            Wrap(
              spacing: LayoutTokens.gr1,
              runSpacing: LayoutTokens.gr1,
              children: _participantsByPlacement(participants).map((p) {
                final chipImageUrl = _resolveCommanderImageForRecentCard(
                  ref,
                  p,
                  m,
                  profile,
                );
                final chipInitials = _recentMatchPlayerInitials(
                  (p.commanderName != null &&
                          p.commanderName!.trim().isNotEmpty)
                      ? p.commanderName!
                      : p.username,
                );
                return Chip(
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  labelPadding: const EdgeInsets.only(left: 2, right: 4),
                  avatar: CircleAvatar(
                    radius: 10,
                    backgroundColor: colors.primaryAccent.withValues(
                      alpha: 0.28,
                    ),
                    backgroundImage:
                        chipImageUrl != null && chipImageUrl.isNotEmpty
                            ? CachedNetworkImageProvider(chipImageUrl)
                            : null,
                    child: chipImageUrl == null || chipImageUrl.isEmpty
                        ? Text(
                            chipInitials,
                            style: TextStyle(
                              fontSize: 7,
                              fontWeight: FontWeight.w800,
                              color: colors.textPrimary,
                            ),
                          )
                        : null,
                  ),
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (p.isWinner) ...[
                        GameIcon.monarch(
                          size: 12,
                          color: colors.emphasis,
                        ),
                        const SizedBox(width: 4),
                      ],
                      Flexible(
                        child: Text(
                          '${p.commanderName ?? p.username}'
                          '${p.finalLife != null ? ' · ${p.finalLife} life' : ''}',
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontSize: FontTokens.hudXs,
                            fontWeight:
                                p.isWinner ? FontWeight.w800 : FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: scheme.surfaceContainerLow,
                  side: BorderSide(
                    color: scheme.outlineVariant.withValues(alpha: 0.45),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      }

      final bodyChildren = <Widget>[];
      for (var i = 0; i < metaBlocks.length; i++) {
        if (i > 0) bodyChildren.add(SizedBox(height: LayoutTokens.gr2));
        bodyChildren.add(metaBlocks[i]);
      }
      if (playersBlock != null) {
        if (bodyChildren.isNotEmpty) {
          bodyChildren.add(SizedBox(height: LayoutTokens.gr2));
        }
        bodyChildren.add(playersBlock);
      }

      return SizedBox(
        height: maxHeight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Material(
                color: colors.backgroundSecondary.withValues(alpha: 0.92),
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: IconButton(
                  onPressed: () => setState(() => _expanded = false),
                  icon: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: colors.textPrimary,
                  ),
                  tooltip: 'Close',
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                ),
              ),
            ),
            SizedBox(height: LayoutTokens.gr0),
            Text(
              structureLine,
              style: structureStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: LayoutTokens.gr1),
            Divider(
              height: 1,
              thickness: 1,
              color: colors.textSecondary.withValues(alpha: 0.18),
            ),
            SizedBox(height: LayoutTokens.gr2),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ...bodyChildren,
                  const Spacer(),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final card = SizedBox(
      width: widget.width,
      height: widget.height,
      child: ProfileCarouselCard(
        padding: EdgeInsets.zero,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _expanded
                ? null
                : () => setState(() => _expanded = true),
            borderRadius: _kProfileCarouselCardRadius,
            child: SizedBox(
              height: widget.height,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _recentMatchCommanderArt(context, commanderImageUrl),
                  AnimatedSwitcher(
                    duration: MotionTokens.standard,
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    // Only paint the active overlay — avoids double-vignette flash on close.
                    layoutBuilder: (current, _) =>
                        current ?? const SizedBox.shrink(),
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                    child: _expanded
                        ? Stack(
                            key: const ValueKey('recent_match_expanded'),
                            fit: StackFit.expand,
                            children: [
                              _recentMatchCardVignette(expanded: true),
                              Padding(
                                padding: EdgeInsets.all(innerPad),
                                child: SizedBox(
                                  height: expandedInnerH,
                                  width: double.infinity,
                                  child: ClipRect(
                                    child: detailsColumn(expandedInnerH),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Stack(
                            key: const ValueKey('recent_match_summary'),
                            fit: StackFit.expand,
                            children: [
                              _recentMatchCardVignette(expanded: false),
                              summaryForeground(),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    return MergeSemantics(
      child: Semantics(
        container: true,
        expanded: _expanded,
        label: 'Recent match, $resultLabel, ${m.format}',
        value: '$playerLine. $dateStr $timeStr.',
        hint: _expanded
            ? 'Close button returns to summary'
            : 'Show more for full match details, or tap the card',
        child: card,
      ),
    );
  }
}

class ProfileDeckPerformanceSection extends ConsumerStatefulWidget {
  final AppColorTokens colors;
  /// When null, list uses remaining flex height (one-screen layout).
  final double? listMaxHeight;
  final bool hasPlayedGames;

  const ProfileDeckPerformanceSection({
    required this.colors,
    this.listMaxHeight,
    this.hasPlayedGames = false,
  });

  @override
  ConsumerState<ProfileDeckPerformanceSection> createState() =>
      _ProfileDeckPerformanceSectionState();
}

class _ProfileDeckPerformanceSectionState
    extends ConsumerState<ProfileDeckPerformanceSection> {
  late final ScrollController _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(deckListRevisionProvider);
    final repoDecks =
        List<PlayerDeck>.from(
            ref
                .read(deckRepositoryProvider)
                .getAll()
                .where((d) => !isPreviewPlaceholderDeck(d)),
          )
          ..sort((a, b) => b.gamesPlayed.compareTo(a.gamesPlayed));

    final colors = widget.colors;
    final lh = widget.listMaxHeight;

    final deckTitleStyle = TypographyTokens.sectionTitle(colors.textPrimary);
    final showPlaceholder =
        repoDecks.isEmpty || !widget.hasPlayedGames;
    final placeholderMessage =
        repoDecks.isEmpty
            ? _kProfileAddDeckMessage
            : _kProfileUntilFirstGameMessage;

    Widget titleRow() {
      return ProfileSectionHeader(
        title: 'Deck performance',
        titleStyle: deckTitleStyle,
        colors: colors,
        count: repoDecks.length,
        singularUnit: 'deck',
        pluralUnit: 'decks',
      );
    }

    Widget carouselRow(double cardHeight) {
      final children = <Widget>[];
      if (showPlaceholder) {
        children.add(
          ProfileCarouselPlaceholderCard(
            message: placeholderMessage,
            colors: colors,
            width: kProfileCarouselCardWidth,
            height: cardHeight,
          ),
        );
        children.add(SizedBox(width: LayoutTokens.gr2));
      } else {
        for (var i = 0; i < repoDecks.length; i++) {
          if (i > 0) children.add(SizedBox(width: LayoutTokens.gr2));
          children.add(
            ProfileDeckCard(
              deck: repoDecks[i],
              colors: colors,
              width: kProfileCarouselCardWidth,
              height: cardHeight,
            ),
          );
        }
        children.add(SizedBox(width: LayoutTokens.gr2));
      }
      children.add(
        SizedBox(
          width: kProfileCarouselCardWidth,
          height: cardHeight,
          child: ProfileCarouselCard(
            padding: EdgeInsets.zero,
            child: ProfileCarouselAddCard(
              colors: colors,
              semanticsLabel: 'Add deck',
              onTap: () => context.go(AppRoutes.decks),
            ),
          ),
        ),
      );

      return SizedBox(
        height: cardHeight,
        child: ListView(
          primary: false,
          controller: _scrollCtrl,
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          padding: EdgeInsets.only(right: LayoutTokens.gr1),
          physics: kProfileHorizontalCarouselPhysics,
          children: children,
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, c) {
        final double cardHeight =
            profileCarouselCardHeight(context, listMaxHeight: lh);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            titleRow(),
            SizedBox(height: LayoutTokens.gr2),
            carouselRow(cardHeight),
          ],
        );
      },
    );
  }
}

TextStyle _profileDeckCardTitleStyle(AppColorTokens colors) => TextStyle(
  fontSize: FontTokens.hudSm + 2,
  fontWeight: FontWeight.w800,
  height: 1.2,
  letterSpacing: -0.15,
  color: colors.textPrimary,
);

TextStyle _profileDeckCardSubtitleStyle(AppColorTokens colors) => TextStyle(
  fontSize: FontTokens.sm,
  fontWeight: FontWeight.w500,
  height: 1.25,
  color: colors.textSecondary,
);

TextStyle _profileDeckCardMetaStyle(
  AppColorTokens colors, {
  required bool accent,
}) =>
    TextStyle(
      fontSize: FontTokens.hudXs + 1,
      fontWeight: FontWeight.w600,
      height: 1.25,
      letterSpacing: 0.1,
      color: accent ? colors.primaryAccent : colors.textSecondary,
    );

/// Format + deck style on one line (single layout pass — no baseline drift).
class _ProfileDeckFormatStyleLine extends StatelessWidget {
  const _ProfileDeckFormatStyleLine({
    required this.deck,
    required this.colors,
  });

  final PlayerDeck deck;
  final AppColorTokens colors;

  @override
  Widget build(BuildContext context) {
    final base = _profileDeckCardMetaStyle(colors, accent: false);
    final styleColor =
        deck.hasDeckStyle ? colors.textSecondary : colors.primaryAccent;
    return Text.rich(
      TextSpan(
        style: base,
        children: [
          TextSpan(
            text: deck.gameFormat.displayName,
            style: base.copyWith(color: colors.primaryAccent),
          ),
          const TextSpan(text: ' · '),
          TextSpan(
            text: deck.deckStyleDisplayName,
            style: base.copyWith(color: styleColor),
          ),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      strutStyle: StrutStyle(
        fontSize: base.fontSize,
        height: base.height,
        fontWeight: base.fontWeight,
        leadingDistribution: TextLeadingDistribution.even,
        forceStrutHeight: true,
      ),
      textHeightBehavior: const TextHeightBehavior(
        applyHeightToFirstAscent: true,
        applyHeightToLastDescent: false,
      ),
    );
  }
}

/// Portrait deck card for profile carousel + My Decks (2:3 ratio).
class ProfileDeckCard extends StatelessWidget {
  const ProfileDeckCard({
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
    final innerW = width - 2 * kProfileCarouselCardPaddingPx;
    final wRatio = deck.hasPartner
        ? _kDeckPortraitWidthOverHeight * (1 + 0.35 * 0.58)
        : _kDeckPortraitWidthOverHeight;

    return SizedBox(
      width: width,
      height: height,
      child: ProfileCarouselCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Flexible(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final artH = profileDeckCardArtHeight(
                    width,
                    height,
                    deck: deck,
                    hasPartner: deck.hasPartner,
                  );
                  final maxH = constraints.maxHeight.isFinite
                      ? constraints.maxHeight
                      : artH;
                  final bandH = math.min(artH, maxH);
                  final portraitSize = math
                      .min(bandH, innerW / wRatio)
                      .clamp(
                        _kProfileDeckCardPortraitMin,
                        _kProfileDeckCardPortraitMax,
                      );
                  return Center(
                    child: ResolvedDeckCommanderAvatarCluster(
                      deck: deck,
                      colors: colors,
                      size: portraitSize,
                      portraitStyle: CommanderPortraitStyle.card,
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: LayoutTokens.gr1),
            Text(
              deck.displayName,
              style: _profileDeckCardTitleStyle(colors),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: LayoutTokens.gr0),
            Text(
              deck.isCommanderDeck && deck.hasPartner
                  ? '${deck.commanderName} // ${deck.partnerCommanderName}'
                  : deck.commanderName,
              style: _profileDeckCardSubtitleStyle(colors),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: LayoutTokens.gr0),
            _ProfileDeckFormatStyleLine(deck: deck, colors: colors),
            if (deck.isCommanderDeck && _deckHasManaForProfile(deck)) ...[
              SizedBox(height: LayoutTokens.gr1),
              Align(
                alignment: Alignment.centerLeft,
                child: DeckManaCostRows(
                  commanderManaCost: deck.commanderManaCost,
                  partnerManaCost: deck.partnerManaCost,
                  hasPartner: deck.hasPartner,
                  compact: true,
                ),
              ),
            ],
            SizedBox(height: LayoutTokens.gr1),
            DeckWinLossRatioBar(deck: deck, colors: colors, height: 8),
            SizedBox(height: LayoutTokens.gr1),
            DeckStatChips(
              deck: deck,
              colors: colors,
              forCarousel: true,
            ),
          ],
        ),
      ),
    );
  }
}
