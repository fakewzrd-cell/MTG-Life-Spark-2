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
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/game_icon.dart';
import '../../shared/utils/app_router.dart';
import '../../shared/utils/commander_image_resolver.dart';
import '../../shared/widgets/deck_tile_visual.dart';
import '../../shared/widgets/profile_default_banner.dart';
import '../../ui/theme/app_color_tokens.dart';
import '../../ui/tokens/font_tokens.dart';
import '../../ui/tokens/layout_tokens.dart';
import '../../ui/tokens/motion_tokens.dart';
import '../../ui/tokens/opacity_tokens.dart';
import '../../ui/tokens/radius_tokens.dart';
import '../../ui/tokens/typography_tokens.dart';

/// Interior padding for 240×360 carousel cards ([LayoutTokens.gr2]).
/// Inner art radius = [RadiusTokens.carouselCard] − padding (nested radius rule).
const double kProfileCarouselCardPaddingPx = LayoutTokens.gr2;

const double _kCarouselCardPaddingPx = kProfileCarouselCardPaddingPx;
BorderRadius get _kProfileCarouselCardRadius => RadiusTokens.radiusCarouselCard;

Widget _recentMatchCommanderArt(BuildContext context, String? imageUrl) {
  if (imageUrl != null && imageUrl.isNotEmpty) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      placeholder: (_, __) => defaultBannerFill(context),
      errorWidget: (_, __, ___) => defaultBannerFill(context),
    );
  }
  return defaultProfileBannerArt(context);
}

/// Shared dark scrim for full-bleed commander art cards (Recent games,
/// Most played, Tough record) so text stays readable without drifting styles.
Widget profileArtCardVignette() {
  return const DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0x66000000),
          Color(0x99000000),
          Color(0xCC000000),
        ],
        stops: [0.0, 0.45, 1.0],
      ),
    ),
  );
}

/// Full-height carousel card with centered guidance copy (empty profile sections).
class ProfileCarouselPlaceholderCard extends StatelessWidget {
  const ProfileCarouselPlaceholderCard({super.key, 
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

/// Empty-state CTA: message + add glyph in one tappable carousel card.
class ProfileCarouselAddPromptCard extends StatelessWidget {
  const ProfileCarouselAddPromptCard({super.key, 
    required this.message,
    required this.colors,
    required this.width,
    required this.height,
    required this.onTap,
    required this.semanticsLabel,
  });

  final String message;
  final AppColorTokens colors;
  final double width;
  final double height;
  final VoidCallback onTap;
  final String semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ProfileCarouselCard(
        padding: EdgeInsets.zero,
        child: Semantics(
          button: true,
          label: semanticsLabel,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: RadiusTokens.radiusCarouselCard,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: LayoutTokens.gr3,
                  vertical: LayoutTokens.gr2,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ProfileCarouselAddGlyph(colors: colors),
                    SizedBox(height: LayoutTokens.gr3),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.textSecondary,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                        fontSize: FontTokens.sm,
                      ),
                    ),
                  ],
                ),
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
  const ProfileCarouselAddGlyph({super.key, required this.colors});

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
        color: colors.primaryAccent.withValues(alpha: OpacityTokens.subtle),
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
  const ProfileCarouselAddCard({super.key, 
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
    this.affordance = false,
  });

  final Widget child;

  /// When null, uses standard carousel card inset ([_kCarouselCardPaddingPx]).
  final EdgeInsetsGeometry? padding;

  /// Quieter empty-slot shell for "+" add tiles — lower fill opacity so content
  /// cards stay visually primary.
  final bool affordance;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fill = affordance
        ? scheme.surfaceContainerHigh.withValues(alpha: OpacityTokens.half)
        : scheme.surfaceContainerHigh;
    return Material(
      color: fill,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: _kProfileCarouselCardRadius),
      clipBehavior: Clip.antiAlias,
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
  const ProfileSectionHeader({super.key, 
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
  const ProfileSectionCountPill({super.key, 
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
        color: colors.primaryAccent.withValues(alpha: OpacityTokens.subtle),
        borderRadius: RadiusTokens.radiusChip,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: colors.primaryAccent,
          fontSize: FontTokens.sm,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}

/// Filled circular icon control for profile section headers (+, filter).
class ProfileHeaderCircleButton extends StatelessWidget {
  const ProfileHeaderCircleButton({
    super.key,
    required this.icon,
    required this.colors,
    required this.tooltip,
    this.onPressed,
    this.size = 36,
    this.iconSize = 20,
  });

  final IconData icon;
  final AppColorTokens colors;
  final String tooltip;
  final VoidCallback? onPressed;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final face = SizedBox(
      width: size,
      height: size,
      child: Icon(
        icon,
        size: iconSize,
        color: colors.primaryAccent,
      ),
    );
    // When [onPressed] is null (e.g. PopupMenuButton child), skip InkWell so
    // the parent owns the tap target.
    final button = onPressed == null
        ? Material(
            color: colors.primaryAccent.withValues(alpha: OpacityTokens.soft),
            shape: const CircleBorder(),
            child: face,
          )
        : Material(
            color: colors.primaryAccent.withValues(alpha: OpacityTokens.soft),
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onPressed,
              child: face,
            ),
          );
    return Tooltip(message: tooltip, child: button);
  }
}

/// Compact accent pill for header actions (e.g. Decks "+ Add").
class ProfileHeaderPillButton extends StatelessWidget {
  const ProfileHeaderPillButton({
    super.key,
    required this.label,
    required this.colors,
    required this.onPressed,
    this.icon = Icons.add_rounded,
  });

  final String label;
  final AppColorTokens colors;
  final VoidCallback onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: colors.primaryAccent.withValues(alpha: OpacityTokens.soft),
      borderRadius: BorderRadius.circular(RadiusTokens.pill),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(RadiusTokens.pill),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: LayoutTokens.gr3,
            vertical: LayoutTokens.gr1,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: colors.primaryAccent),
              SizedBox(width: LayoutTokens.gr1),
              Text(
                label,
                style: TextStyle(
                  color: colors.primaryAccent,
                  fontSize: FontTokens.body,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shared width for profile/My Decks horizontal carousel cards.
const double kProfileCarouselCardWidth = LayoutTokens.profileCarouselCardWidth;

/// Fixed height for every carousel card (same on all pages).
const double kProfileCarouselCardHeight = LayoutTokens.profileCarouselCardCanonicalHeight;

const double _kProfileDeckCardPortraitMin = 72;

/// Line heights for deck card footer (matches [ProfileDeckCard] text styles).
const double _kDeckCardTitleLine = 18;
const double _kDeckCardSubtitleLine = 15;
const double _kDeckCardMetaLine = 14;

/// Single-line record ("75% WR · 12W–4L") height under the win/loss bar.
const double _kDeckCardStatLine = 16.0;

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
  // W/L bar + single WR/record line ([_ProfileDeckRecordLine]).
  h += (LayoutTokens.gr1 + 8 + LayoutTokens.gr1 + _kDeckCardStatLine) * ts;
  return h + LayoutTokens.gr1 * ts;
}

/// Smallest card height that fits the heaviest deck footer + minimum art band.
double profileDeckCardMinHeight({double textScale = 1.0}) {
  final heavy = PlayerDeck(
    id: '_layout_probe',
    displayName: 'Probe',
    commanderName: 'Commander // Partner',
    partnerCommanderName: 'Partner',
    format: 'commander',
    deckStyleId: 'voltron',
  );
  final footer = profileDeckCardFooterReserveHeight(heavy, textScale: textScale);
  return footer + _kProfileDeckCardPortraitMin + 2 * kProfileCarouselCardPaddingPx;
}

/// Commander art band height inside a deck card (fills remaining vertical space).
///
/// Height-driven on purpose: width no longer caps the portrait so the art
/// always uses the available band height (sides may inset or clip).
double profileDeckCardArtHeight(
  double cardWidth,
  double cardHeight, {
  required PlayerDeck deck,
  required bool hasPartner,
}) {
  // [cardWidth] / [hasPartner] kept for call-site compatibility; sizing is
  // vertical-only so partner width never shrinks the portrait.
  assert(cardWidth > 0);
  final innerH = cardHeight - 2 * kProfileCarouselCardPaddingPx;
  final footer = profileDeckCardFooterReserveHeight(deck);
  final maxByFooter = math.max(_kProfileDeckCardPortraitMin, innerH - footer);
  return math.max(_kProfileDeckCardPortraitMin, maxByFooter);
}

/// Fixed 2:3 height for every carousel card (240×360 at default width).
double profileCarouselCardHeight(BuildContext context) {
  return LayoutTokens.profileCarouselCardCanonicalHeight;
}

/// Canonical carousel tile size (width × height) for layout tests and tiles.
Size profileCarouselCardSize() => Size(
  kProfileCarouselCardWidth,
  kProfileCarouselCardHeight,
);

/// Time window for Recent Games list filtering.
enum _RecentGamesTimeFilter {
  all,
  recent,
  thisWeek,
  thisMonth,
}

extension _RecentGamesTimeFilterLabel on _RecentGamesTimeFilter {
  String menuLabel(AppLocalizations l10n) => switch (this) {
    _RecentGamesTimeFilter.all => l10n.profileFilterAllGames,
    _RecentGamesTimeFilter.recent => l10n.profileFilterRecent14,
    _RecentGamesTimeFilter.thisWeek => l10n.profileFilterThisWeek,
    _RecentGamesTimeFilter.thisMonth => l10n.profileFilterThisMonth,
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
  if (m.result == 'win') return colors.success;
  if (m.result == 'concede') return colors.warning;
  return colors.error;
}

String _recentMatchResultLabel(MatchRecord m, AppLocalizations l10n) {
  if (m.result == 'win') return 'Win';
  if (m.result == 'concede') return l10n.profileResultConcede;
  return l10n.profileResultLoss;
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

/// One standings row: avatar + name (ellipsis) + fixed life column.
class _RecentMatchStandingRow extends StatelessWidget {
  const _RecentMatchStandingRow({
    required this.participant,
    required this.colors,
    this.imageUrl,
    this.onDarkOverlay = false,
  });

  final MatchParticipantSnapshot participant;
  final AppColorTokens colors;
  final String? imageUrl;

  /// When true, force light text for readability on the dark card vignette.
  final bool onDarkOverlay;

  @override
  Widget build(BuildContext context) {
    final p = participant;
    final title = (p.commanderName != null && p.commanderName!.trim().isNotEmpty)
        ? p.commanderName!.trim()
        : p.username;
    final showUsernameSubtitle =
        p.commanderName != null &&
        p.commanderName!.trim().isNotEmpty &&
        p.username.trim().isNotEmpty &&
        p.username.trim().toLowerCase() != p.commanderName!.trim().toLowerCase();
    final initials = _recentMatchPlayerInitials(title);
    final lifeLabel = p.finalLife != null ? '${p.finalLife}' : '—';
    final primary = onDarkOverlay ? Colors.white : colors.textPrimary;
    final secondary = onDarkOverlay
        ? Colors.white.withValues(alpha: 0.78)
        : colors.textSecondary;
    final winnerAccent =
        onDarkOverlay ? const Color(0xFFFFD54F) : colors.emphasis;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: onDarkOverlay
              ? Colors.white.withValues(alpha: 0.22)
              : colors.primaryAccent.withValues(alpha: 0.28),
          backgroundImage: imageUrl != null && imageUrl!.isNotEmpty
              ? CachedNetworkImageProvider(imageUrl!)
              : null,
          child: imageUrl == null || imageUrl!.isEmpty
              ? Text(
                  initials,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: primary,
                  ),
                )
              : null,
        ),
        SizedBox(width: LayoutTokens.gr2),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  if (p.isWinner) ...[
                    GameIcon.monarch(
                      size: 13,
                      color: winnerAccent,
                    ),
                    const SizedBox(width: 4),
                  ],
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: primary,
                        fontSize: FontTokens.hudSm,
                        fontWeight:
                            p.isWinner ? FontWeight.w700 : FontWeight.w600,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (showUsernameSubtitle)
                Text(
                  p.username,
                  style: TextStyle(
                    color: secondary,
                    fontSize: FontTokens.caption,
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
        SizedBox(width: LayoutTokens.gr1),
        SizedBox(
          width: 44,
          child: Text(
            lifeLabel,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: p.isWinner ? winnerAccent : primary,
              fontSize: FontTokens.hudSm,
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
              height: 1.2,
            ),
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}

class ProfileRecentGamesModule extends StatefulWidget {
  final List<MatchRecord> matches;
  final AppColorTokens colors;

  const ProfileRecentGamesModule({super.key, 
    required this.matches,
    required this.colors,
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
    final l10n = AppLocalizations.of(context);
    final filtered = _filterMatchesForRecentGames(widget.matches, _filter);
    final showFilterMenu = widget.matches.isNotEmpty;

    final titleStyle = TypographyTokens.sectionTitle(c.textPrimary);

    Widget titleRow() {
      return ProfileSectionHeader(
        title: l10n.profileRecentGames,
        titleStyle: titleStyle,
        colors: c,
        count: filtered.length,
        singularUnit: 'game',
        pluralUnit: 'games',
        trailing: showFilterMenu
            ? PopupMenuButton<_RecentGamesTimeFilter>(
                tooltip: l10n.carouselFilterTooltip(_filter.menuLabel(l10n)),
                padding: EdgeInsets.zero,
                offset: const Offset(0, 8),
                onSelected: (v) => setState(() => _filter = v),
                child: ProfileHeaderCircleButton(
                  icon: Icons.filter_list_rounded,
                  colors: c,
                  tooltip: l10n.carouselFilterTooltip(_filter.menuLabel(l10n)),
                ),
                itemBuilder: (context) => [
                  for (final f in _RecentGamesTimeFilter.values)
                    CheckedPopupMenuItem<_RecentGamesTimeFilter>(
                      value: f,
                      checked: f == _filter,
                      child: Text(f.menuLabel(l10n)),
                    ),
                ],
              )
            : null,
      );
    }

    final cardHeight = profileCarouselCardHeight(context);

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
                ProfileCarouselAddPromptCard(
                  message: l10n.profileEmptyRecentGames,
                  colors: c,
                  width: kProfileCarouselCardWidth,
                  height: cardHeight,
                  onTap: () => context.go(AppRoutes.lobby),
                  semanticsLabel: l10n.profileOpenLobbySemantics,
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
                  message: l10n.profileNoMatchesFilter,
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

  final byPlacement = _participantsByPlacement(snaps);
  if (byPlacement.isNotEmpty && byPlacement.first.placementRank == 1) {
    return byPlacement.first;
  }

  // Local win with incomplete snapshots — treat local as winner.
  if (m.result == 'win') {
    for (final p in snaps) {
      if (_participantSnapshotIsLocal(p, profile)) return p;
    }
  }

  // Unknown winner — don't invent an opponent (misleading in multiplayer).
  return null;
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

List<PlayerDeck> _decksOrEmpty(WidgetRef ref) {
  try {
    return ref.read(deckRepositoryProvider).getAll();
  } catch (_) {
    return const [];
  }
}

PlayerDeck? _deckByIdOrNull(WidgetRef ref, String id) {
  try {
    return ref.read(deckRepositoryProvider).getById(id);
  } catch (_) {
    return null;
  }
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
    for (final d in _decksOrEmpty(ref)) {
      if (d.commanderName.toLowerCase() == commander.toLowerCase()) {
        final url = d.commanderImageUrl?.trim();
        if (url != null && url.isNotEmpty) return url;
      }
    }
  }

  if (_participantSnapshotIsLocal(participant, profile)) {
    final deckId = match.localDeckIdSnapshot?.trim();
    if (deckId != null && deckId.isNotEmpty) {
      final url = _deckByIdOrNull(ref, deckId)?.commanderImageUrl?.trim();
      if (url != null && url.isNotEmpty) return url;
    }
    final selectedName = profile?.selectedCommanderName?.trim();
    final selected = profile?.selectedCommanderImageUrl?.trim();
    if (commander != null &&
        commander.isNotEmpty &&
        selected != null &&
        selected.isNotEmpty &&
        selectedName != null &&
        selectedName.isNotEmpty &&
        selectedName.toLowerCase() == commander.toLowerCase()) {
      return selected;
    }
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
    final m = widget.match;
    final colors = widget.colors;
    final fmt = DateFormat('MMM d, y');
    final timeFmt = DateFormat('HH:mm');
    final dateStr = fmt.format(m.date);
    final timeStr = timeFmt.format(m.date);
    final secs = m.durationSecondsEffective;
    final participants = m.participantSnapshots;
    final resultColor = _recentMatchResultColor(m, colors);
    final l10n = AppLocalizations.of(context);
    final resultLabel = _recentMatchResultLabel(m, l10n);
    final n = _recentMatchPlayerCount(m);
    final playerLine = '$n ${n == 1 ? 'player' : 'players'}';

    final structureStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: colors.textSecondary,
      fontWeight: FontWeight.w600,
      fontSize: FontTokens.caption,
      height: 1.35,
    );
    final formatStyle = Theme.of(context).textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.w600,
      letterSpacing: -0.15,
      height: 1.25,
      color: colors.textPrimary,
    );
    final metaStyle = Theme.of(context).textTheme.titleSmall?.copyWith(
      color: colors.textSecondary,
      fontWeight: FontWeight.w600,
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
      ),
      child: Text(
        resultLabel,
        style: TextStyle(
          color: resultColor,
          fontWeight: FontWeight.w600,
          fontSize: FontTokens.caption,
          letterSpacing: 0.15,
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
      final matchLabel = MatchRecord.normalizeLabel(m.labelSnapshot);
      final overlayFormatStyle = formatStyle!.copyWith(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.28,
        letterSpacing: -0.2,
        shadows: const [
          Shadow(
            color: Color(0x99000000),
            blurRadius: 10,
            offset: Offset(0, 1),
          ),
        ],
      );
      final overlayMetaStyle = metaStyle!.copyWith(
        color: Colors.white.withValues(alpha: 0.82),
        fontSize: 13,
        fontWeight: FontWeight.w500,
        height: 1.35,
      );
      final overlayLabelStyle = overlayMetaStyle.copyWith(
        color: Colors.white.withValues(alpha: 0.92),
        fontWeight: FontWeight.w600,
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
            if (matchLabel != null) ...[
              SizedBox(height: LayoutTokens.gr1),
              Text(
                matchLabel,
                style: overlayLabelStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            SizedBox(height: LayoutTokens.gr1),
            Text(
              '$playerLine · $dateStr · $timeStr',
              style: overlayMetaStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: LayoutTokens.gr3),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  if (!_expanded) setState(() => _expanded = true);
                },
                style: FilledButton.styleFrom(
                  visualDensity: VisualDensity.standard,
                  padding: EdgeInsets.symmetric(
                    horizontal: LayoutTokens.gr3,
                    vertical: LayoutTokens.gr2,
                  ),
                  minimumSize: const Size(
                    double.infinity,
                    LayoutTokens.minTapTarget,
                  ),
                  tapTargetSize: MaterialTapTargetSize.padded,
                  shape: const StadiumBorder(),
                  foregroundColor: colors.textPrimary,
                  backgroundColor: colors.surface,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                ),
                child: Text(
                  l10n.profileShowMore,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    letterSpacing: 0.2,
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    Widget detailsColumn(double maxHeight) {
      final durationLabel = _formatDurationSeconds(secs);
      final deckName = (m.localDeckIdSnapshot != null &&
              m.localDeckIdSnapshot!.isNotEmpty)
          ? (_deckByIdOrNull(ref, m.localDeckIdSnapshot!)?.displayName ??
              m.localDeckIdSnapshot!)
          : null;
      final matchLabel = MatchRecord.normalizeLabel(m.labelSnapshot);

      // Expanded panel sits on the dark vignette — always use light type so
      // light-theme tokens (dark text) never paint onto the scrim.
      const overlayPrimary = Colors.white;
      final overlaySecondary = Colors.white.withValues(alpha: 0.78);
      final overlayMuted = Colors.white.withValues(alpha: 0.62);

      final structureOverlayStyle = structureStyle?.copyWith(
            color: overlaySecondary,
          ) ??
          TextStyle(
            color: overlaySecondary,
            fontWeight: FontWeight.w600,
            fontSize: FontTokens.caption,
            height: 1.35,
          );
      final metaStripStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
            color: overlaySecondary,
            fontWeight: FontWeight.w600,
            fontSize: FontTokens.caption,
            height: 1.35,
          );
      final metaExtraStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
            color: overlayMuted,
            fontWeight: FontWeight.w500,
            fontSize: FontTokens.caption,
            height: 1.3,
          );

      final metaBits = <String>[durationLabel, playerLine];
      final metaExtras = <String>[
        if (matchLabel != null) matchLabel,
        if (deckName != null) deckName,
      ];

      Widget? standingsBlock;
      if (participants.isNotEmpty) {
        final ordered = _participantsByPlacement(participants);
        standingsBlock = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.profileStandings,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: overlaySecondary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                    fontSize: FontTokens.caption,
                  ),
            ),
            SizedBox(height: LayoutTokens.gr1),
            for (var i = 0; i < ordered.length; i++) ...[
              if (i > 0) SizedBox(height: LayoutTokens.gr1),
              _RecentMatchStandingRow(
                participant: ordered[i],
                colors: colors,
                onDarkOverlay: true,
                imageUrl: _resolveCommanderImageForRecentCard(
                  ref,
                  ordered[i],
                  m,
                  profile,
                ),
              ),
            ],
          ],
        );
      }

      return SizedBox(
        height: maxHeight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Material(
                color: Colors.black.withValues(alpha: 0.45),
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: IconButton(
                  onPressed: () => setState(() => _expanded = false),
                  icon: const Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: overlayPrimary,
                  ),
                  tooltip: l10n.commonClose,
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  constraints: const BoxConstraints(
                    minWidth: LayoutTokens.minTapTarget,
                    minHeight: LayoutTokens.minTapTarget,
                  ),
                ),
              ),
            ),
            SizedBox(height: LayoutTokens.gr0),
            Text(
              structureLine,
              style: structureOverlayStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: LayoutTokens.gr1),
            Text(
              metaBits.join(' · '),
              style: metaStripStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (metaExtras.isNotEmpty) ...[
              SizedBox(height: LayoutTokens.gr0),
              Text(
                metaExtras.join(' · '),
                style: metaExtraStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            SizedBox(height: LayoutTokens.gr1),
            Divider(
              height: 1,
              thickness: 1,
              color: Colors.white.withValues(alpha: 0.22),
            ),
            SizedBox(height: LayoutTokens.gr2),
            Expanded(
              child: SingleChildScrollView(
                child: standingsBlock ??
                    Text(
                      l10n.profileNoPlayerDetails,
                      style: metaStripStyle,
                    ),
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
                              profileArtCardVignette(),
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
                              profileArtCardVignette(),
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
        label: l10n.carouselRecentMatchA11y(resultLabel, m.format),
        value: '$playerLine. $dateStr $timeStr.',
        hint: _expanded
            ? l10n.carouselCloseReturnsSummary
            : l10n.carouselShowMoreDetails,
        child: card,
      ),
    );
  }
}

class ProfileDeckPerformanceSection extends ConsumerStatefulWidget {
  final AppColorTokens colors;
  final bool hasPlayedGames;

  const ProfileDeckPerformanceSection({super.key, 
    required this.colors,
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
    final l10n = AppLocalizations.of(context);

    final deckTitleStyle = TypographyTokens.sectionTitle(colors.textPrimary);
    final showPlaceholder =
        repoDecks.isEmpty || !widget.hasPlayedGames;
    final needsAddPrompt = repoDecks.isEmpty;
    final placeholderMessage =
        needsAddPrompt
            ? l10n.profileEmptyDeckPerf
            : l10n.profileEmptyRecentGames;

    void openDecks() => context.go(AppRoutes.decks);

    Widget titleRow() {
      return ProfileSectionHeader(
        title: l10n.profileDeckPerformance,
        titleStyle: deckTitleStyle,
        colors: colors,
        count: repoDecks.length,
        singularUnit: 'deck',
        pluralUnit: 'decks',
        // Empty CTA lives on the fused card; header + only when decks are listed.
        trailing: !needsAddPrompt
            ? ProfileHeaderCircleButton(
                icon: Icons.add_rounded,
                colors: colors,
                tooltip: l10n.decksAddDeck,
                onPressed: openDecks,
              )
            : null,
      );
    }

    Widget carouselRow(double cardHeight) {
      final children = <Widget>[];
      if (showPlaceholder) {
        if (needsAddPrompt) {
          children.add(
            ProfileCarouselAddPromptCard(
              message: placeholderMessage,
              colors: colors,
              width: kProfileCarouselCardWidth,
              height: cardHeight,
              onTap: openDecks,
              semanticsLabel: l10n.decksAddDeck,
            ),
          );
        } else {
          children.add(
            ProfileCarouselPlaceholderCard(
              message: placeholderMessage,
              colors: colors,
              width: kProfileCarouselCardWidth,
              height: cardHeight,
            ),
          );
        }
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
      }

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
            profileCarouselCardHeight(context);
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
  fontWeight: FontWeight.w600,
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
  const ProfileDeckCard({super.key, 
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
                  // Inset so the card rim shadow isn't clipped by the
                  // carousel Material; still fill nearly the full band height.
                  const shadowInset = 6.0;
                  final portraitSize = math.max(
                    _kProfileDeckCardPortraitMin,
                    math.min(artH, maxH) - shadowInset,
                  );
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(4, 2, 4, 4),
                    child: Center(
                      child: ResolvedDeckCommanderAvatarCluster(
                        deck: deck,
                        colors: colors,
                        size: portraitSize,
                        portraitStyle: CommanderPortraitStyle.card,
                        // Fill the portrait frame height; crop sides if needed.
                        imageFit: BoxFit.cover,
                      ),
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
            SizedBox(height: LayoutTokens.gr1),
            DeckWinLossRatioBar(deck: deck, colors: colors, height: 8),
            SizedBox(height: LayoutTokens.gr1),
            _ProfileDeckRecordLine(deck: deck, colors: colors),
          ],
        ),
      ),
    );
  }
}

/// Compact record line under the win/loss bar — win rate leads (accent,
/// bold), exact W–L trails (muted). Replaces the old WR/W/L/GP chip grid,
/// which repeated the same signal the bar above already shows.
class _ProfileDeckRecordLine extends StatelessWidget {
  const _ProfileDeckRecordLine({required this.deck, required this.colors});

  final PlayerDeck deck;
  final AppColorTokens colors;

  @override
  Widget build(BuildContext context) {
    final gp = deck.gamesPlayed;
    final wr = gp == 0 ? null : (deck.winRate * 100).round();
    final base = _profileDeckCardMetaStyle(colors, accent: false);

    return Text.rich(
      TextSpan(
        style: base,
        children: [
          TextSpan(
            text: wr == null ? '— WR' : '$wr% WR',
            style: base.copyWith(
              color: colors.primaryAccent,
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(
            text: '  ·  ${deck.wins}W–${deck.losses}L',
            style: base.copyWith(color: colors.textSecondary),
          ),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
