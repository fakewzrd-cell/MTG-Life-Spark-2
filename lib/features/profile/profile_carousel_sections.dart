import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../core/models/match_record.dart';
import '../../core/models/player_deck.dart';
import '../../core/models/player_profile.dart';
import '../../core/persistence/providers.dart';
import '../../shared/constants/app_icons.dart';
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

/// Internal padding of every profile carousel card ([LayoutTokens.gr2]).
/// Inner element radius = RadiusTokens.bento − padding (nested radius rule).
const double kProfileBentoCardPaddingPx = LayoutTokens.gr2;

const double _kBentoCardPaddingPx = kProfileBentoCardPaddingPx;
const double _kBentoCardBorderAlpha = 0.55;
BorderRadius get _kProfileBentoRadius => RadiusTokens.radiusBento;

RoundedRectangleBorder _profileCarouselCardShape(ColorScheme scheme) {
  return RoundedRectangleBorder(
    borderRadius: _kProfileBentoRadius,
    side: BorderSide(
      color: scheme.outlineVariant.withValues(alpha: _kBentoCardBorderAlpha),
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

class ProfileBentoCard extends StatelessWidget {
  const ProfileBentoCard({super.key, required this.child});
  final Widget child;

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
        padding: EdgeInsets.all(_kBentoCardPaddingPx),
        child: child,
      ),
    );
  }
}

const double kProfileDeckPerfCardWidth = LayoutTokens.profileCarouselCardWidth;
const double _kDeckPerfTitleHeight = 44;
const double _kDeckPerfCommanderPortraitMin = 108;
const double _kDeckPerfCommanderPortraitMax = 168;
const double _kDeckPerfCardIdealHeight = 400;

double deckPerfCardMinHeightPx(BuildContext context) {
  final scale = MediaQuery.textScalerOf(context).scale(12) / 12.0;
  const double atUnitScale = 388;
  return (atUnitScale * scale.clamp(1.0, 1.45)).clamp(318.0, 480.0);
}

double profileSectionHorizontalCardHeight(
  BuildContext context,
  double? listMaxHeight,
) {
  final double listBudget =
      (listMaxHeight != null && listMaxHeight.isFinite && listMaxHeight > 0)
          ? listMaxHeight - _kDeckPerfTitleHeight
          : 240.0;
  final double budget = math.max(180.0, listBudget);
  final double need = deckPerfCardMinHeightPx(context);
  final double softCap = math.max(_kDeckPerfCardIdealHeight, need);
  return math.max(need, math.min(budget, softCap));
}

double profilePlayerStatsCardHeight(
  BuildContext context,
  double? listMaxHeight,
) {
  final full = profileSectionHorizontalCardHeight(context, listMaxHeight);
  const scale = 0.86;
  const softCap = 320.0;
  const floor = 252.0;
  return (full * scale).clamp(floor, softCap);
}

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
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  'Recent games',
                  style: titleStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (showFilterMenu)
                PopupMenuButton<_RecentGamesTimeFilter>(
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
                ),
            ],
          ),
        ],
      );
    }

    Widget emptyBody(String message) {
      return SizedBox(
        height: 148,
        child: Center(
          child: Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: c.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (widget.matches.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          titleRow(),
          SizedBox(height: LayoutTokens.gr2),
          emptyBody(_kProfileUntilFirstGameMessage),
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
          emptyBody('No matches for this filter.'),
        ],
      );
    }

    final cardHeight = profileSectionHorizontalCardHeight(context, lh);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        titleRow(),
        SizedBox(height: LayoutTokens.gr2),
        SizedBox(
          height: cardHeight,
          child: ListView.separated(
            controller: _scrollCtrl,
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            padding: EdgeInsets.zero,
            physics: const BouncingScrollPhysics(),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => SizedBox(width: LayoutTokens.gr2),
            itemBuilder: (context, i) {
              return _ProfileRecentMatchCard(
                key: ValueKey<String>(filtered[i].matchId),
                match: filtered[i],
                colors: c,
                width: kProfileDeckPerfCardWidth,
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
MatchParticipantSnapshot? _winnerParticipantForRecentCard(
  MatchRecord m,
  PlayerProfile? profile,
) {
  final snaps = m.participantSnapshots;
  if (snaps.isEmpty) return null;

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

    final innerPad = _kBentoCardPaddingPx;
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
              children: participants.map((p) {
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
                  label: Text(
                    p.commanderName ?? p.username,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        color: scheme.surfaceContainerHigh,
        elevation: 1,
        surfaceTintColor: scheme.surfaceTint,
        shape: _profileCarouselCardShape(scheme),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _expanded
                ? null
                : () => setState(() => _expanded = true),
            borderRadius: _kProfileBentoRadius,
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

  const ProfileDeckPerformanceSection({
    required this.colors,
    this.listMaxHeight,
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

    Widget emptyBody(String message) {
      return SizedBox(
        height: 148,
        child: Center(
          child: Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    Widget horizontalList(double cardHeight, List<PlayerDeck> decks) {
      return SizedBox(
        height: cardHeight,
        child: ListView.separated(
          controller: _scrollCtrl,
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          padding: EdgeInsets.zero,
          physics: const BouncingScrollPhysics(),
          itemCount: decks.length,
          separatorBuilder: (_, __) => SizedBox(width: LayoutTokens.gr2),
          itemBuilder: (context, i) {
            return _ProfileDeckPerfCard(
              deck: decks[i],
              colors: colors,
              width: kProfileDeckPerfCardWidth,
              height: cardHeight,
            );
          },
        ),
      );
    }

    Widget titleRow() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text('Deck performance', style: deckTitleStyle),
              ),
              IconButton(
                icon: Icon(
                  Icons.layers_outlined,
                  size: 22,
                  color: colors.primaryAccent,
                ),
                tooltip: 'Manage decks',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: kMinInteractiveDimension,
                  minHeight: kMinInteractiveDimension,
                ),
                onPressed: () => context.go(AppRoutes.decks),
              ),
            ],
          ),
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, c) {
        final double cardHeight =
            profileSectionHorizontalCardHeight(context, lh);
        if (repoDecks.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              titleRow(),
              SizedBox(height: LayoutTokens.gr2),
              emptyBody('No decks yet. Open Decks to add one.'),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            titleRow(),
            SizedBox(height: LayoutTokens.gr2),
            horizontalList(cardHeight, repoDecks),
          ],
        );
      },
    );
  }
}

/// Vertical card showing one deck's commander art, names, mana, WR bar, and chips.
class _ProfileDeckPerfCard extends StatelessWidget {
  const _ProfileDeckPerfCard({
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
    return SizedBox(
      width: width,
      height: height,
      child: ProfileBentoCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, c) {
                  // Primary card height `size`; cluster width scales with partner overlap.
                  final wRatio = deck.hasPartner
                      ? (63 / 88) * (1 + 0.35 * 0.58)
                      : (63 / 88);
                  final maxByWidth = c.maxWidth / wRatio;
                  final sz = math
                      .min(c.maxHeight, maxByWidth)
                      .clamp(
                        _kDeckPerfCommanderPortraitMin,
                        _kDeckPerfCommanderPortraitMax,
                      );
                  return Center(
                    child: ResolvedDeckCommanderAvatarCluster(
                      deck: deck,
                      colors: colors,
                      size: sz,
                      portraitStyle: CommanderPortraitStyle.card,
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: LayoutTokens.gr0),
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
            SizedBox(height: LayoutTokens.gr2),
            DeckWinLossRatioBar(deck: deck, colors: colors, height: 6),
            SizedBox(height: LayoutTokens.gr1),
            DeckStatChips(deck: deck, colors: colors, compact: true),
          ],
        ),
      ),
    );
  }
}
