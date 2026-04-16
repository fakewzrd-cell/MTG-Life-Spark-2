import 'dart:convert';
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/models/match_record.dart';
import '../../core/models/player_deck.dart';
import '../../core/models/player_profile.dart';
import '../../core/persistence/providers.dart';
import '../../shared/utils/app_router.dart';
import '../../shared/widgets/tier_badge.dart';
import '../../ui/components/ui_app_bar.dart';
import '../../ui/components/ui_surface.dart';
import '../../ui/theme/app_color_tokens.dart';
import '../../ui/tokens/color_tokens.dart';
import '../../ui/tokens/font_tokens.dart';
import '../../ui/tokens/layout_tokens.dart';
import '../../ui/tokens/radius_tokens.dart';

int _xpNeededForLevel(int level) {
  const thresholds = [(10, 500), (25, 1000), (50, 2000), (75, 3500), (100, 5000)];
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

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final matchRepo = ref.watch(matchRepositoryProvider);

    if (profile == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final storedMatches = matchRepo.getAllMatches().toList();
    final allMatches =
        storedMatches.isEmpty ? <MatchRecord>[_previewPlaceholderMatch()] : storedMatches;

    final colors = AppColorTokens.of(context);
    return Scaffold(
      appBar: UiAppBar(
        actions: [
          IconButton(
            tooltip: 'My decks',
            onPressed: () => context.push(AppRoutes.profileDecks),
            icon: Icon(Icons.layers_outlined, color: colors.primaryAccent),
          ),
          IconButton(
            tooltip: 'My pods',
            onPressed: () => context.push(AppRoutes.profilePods),
            icon: Icon(Icons.groups_outlined, color: colors.primaryAccent),
          ),
        ],
      ),
      backgroundColor: colors.backgroundPrimary,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenW = MediaQuery.sizeOf(context).width;
          final raw = constraints.maxWidth;
          final bodyW =
              raw.isFinite && raw > 0 ? raw : screenW.clamp(320.0, 2000.0);
          final isNarrow = bodyW < 360;
          final hPad = isNarrow ? LayoutTokens.gr3 : LayoutTokens.gr4;

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _ProfileBannerAvatar(
                  profile: profile,
                  colors: colors,
                  bodyWidth: bodyW,
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(hPad, LayoutTokens.gr3, hPad, 0),
                sliver: SliverToBoxAdapter(
                  child: _ProfileIdentity(
                    profile: profile,
                    colors: colors,
                    bodyWidth: bodyW,
                  ),
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: LayoutTokens.gr4)),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(hPad, 0, hPad, hPad),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _ProfileBehaviourStatsBanner(
                      profile: profile,
                      colors: colors,
                    ),
                    SizedBox(height: LayoutTokens.gr4),
                    _DeckPerformanceSection(colors: colors),
                    SizedBox(height: LayoutTokens.gr4),
                    _RecentGamesModule(matches: allMatches, colors: colors),
                    SizedBox(height: LayoutTokens.gr5),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Full-width banner + avatar (no negative padding / [OverflowBox] hacks).
class _ProfileBannerAvatar extends StatelessWidget {
  final PlayerProfile profile;
  final AppColorTokens colors;
  final double bodyWidth;

  const _ProfileBannerAvatar({
    required this.profile,
    required this.colors,
    required this.bodyWidth,
  });

  void _onAvatarTap(BuildContext context) {
    context.push(AppRoutes.profileAvatar);
  }

  void _onBannerTap(BuildContext context) {
    context.push(AppRoutes.profileBanner);
  }

  String get _initials {
    final parts =
        profile.username.trim().split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      final s = parts.first;
      return s.length >= 2 ? s.substring(0, 2).toUpperCase() : s.toUpperCase();
    }
    final first = parts.first;
    final last = parts.last;
    if (first.isEmpty || last.isEmpty) return '?';
    return '${first[0]}${last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final narrow = bodyWidth < 360;
    final avatarRadius = (bodyWidth < 360 ? 70.0 : 90.0).clamp(64.0, 96.0);
    const ringStroke = 7.0;
    final outer = 2 * (avatarRadius + ringStroke);
    final bannerHeight = narrow ? 120.0 : 140.0;
    final headerStackHeight = bannerHeight + avatarRadius + ringStroke;

    final xpNeeded = _xpNeededForLevel(profile.level);
    final xpInLevel = profile.xp % xpNeeded;
    final progress =
        (xpNeeded > 0) ? (xpInLevel / xpNeeded).clamp(0.0, 1.0) : 0.0;

    Widget bannerBackground() {
      final url = profile.profileBannerImageUrl;
      if (url != null && url.isNotEmpty) {
        return CachedNetworkImage(
          key: ValueKey(url),
          imageUrl: url,
          fit: BoxFit.cover,
          width: double.infinity,
          height: bannerHeight,
          placeholder: (_, __) => Container(
            color: colors.backgroundSecondary,
          ),
          errorWidget: (_, __, ___) => _defaultBannerFill(colors),
        );
      }
      return _defaultBannerFill(colors);
    }

    return SizedBox(
      width: bodyWidth,
      height: headerStackHeight,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: bannerHeight,
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(RadiusTokens.md),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  bannerBackground(),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: 56,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0),
                            Colors.black.withValues(alpha: 0.45),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Material(
                      color: Colors.black.withValues(alpha: 0.35),
                      shape: const CircleBorder(),
                      clipBehavior: Clip.antiAlias,
                      child: IconButton(
                        tooltip: 'Change banner',
                        icon: const Icon(
                          Icons.wallpaper_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () => _onBannerTap(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: bannerHeight - (avatarRadius + ringStroke),
            left: 0,
            right: 0,
            height: 2 * (avatarRadius + ringStroke),
            child: Center(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _onAvatarTap(context),
                child: SizedBox(
                  width: outer,
                  height: outer,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        key: ValueKey(profile.profileAvatarImageUrl ?? ''),
                        radius: avatarRadius,
                        backgroundColor: colors.surface,
                        backgroundImage: profile.profileAvatarImageUrl != null &&
                                profile.profileAvatarImageUrl!.isNotEmpty
                            ? CachedNetworkImageProvider(
                                profile.profileAvatarImageUrl!,
                              )
                            : null,
                        child: profile.profileAvatarImageUrl != null &&
                                profile.profileAvatarImageUrl!.isNotEmpty
                            ? null
                            : Text(
                                _initials,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: colors.textPrimary,
                                    ),
                              ),
                      ),
                      IgnorePointer(
                        child: CustomPaint(
                          size: Size(outer, outer),
                          painter: _XpRingPainter(
                            progress: progress,
                            trackColor: colors.backgroundSecondary,
                            progressColor: colors.primaryAccent,
                            strokeWidth: ringStroke,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileIdentity extends StatelessWidget {
  final PlayerProfile profile;
  final AppColorTokens colors;
  final double bodyWidth;

  const _ProfileIdentity({
    required this.profile,
    required this.colors,
    required this.bodyWidth,
  });

  @override
  Widget build(BuildContext context) {
    final xpNeeded = _xpNeededForLevel(profile.level);
    final xpInLevel = profile.xp % xpNeeded;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          profile.username,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: colors.textPrimary,
                fontSize: bodyWidth < 360 ? 20 : null,
              ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        SizedBox(height: LayoutTokens.gr1),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TierBadge(tier: profile.tier, level: profile.level),
            SizedBox(width: LayoutTokens.gr1),
            Text(
              'Rank ${profile.level}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.textSecondary,
                  ),
            ),
          ],
        ),
        SizedBox(height: LayoutTokens.gr1),
        Text(
          '$xpInLevel / $xpNeeded XP',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colors.textSecondary,
                fontSize: bodyWidth < 360 ? 12 : null,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _XpRingPainter extends CustomPainter {
  _XpRingPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  final double progress;
  final Color trackColor;
  final Color progressColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = (size.shortestSide - strokeWidth) / 2;

    final track = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(c, r, track);

    final p = progress.clamp(0.0, 1.0);
    if (p <= 0) return;

    final arc = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(center: c, radius: r);
    final sweep = 2 * math.pi * p;
    canvas.drawArc(
      rect,
      -math.pi / 2,
      sweep,
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(covariant _XpRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

class _ProgressionStatsFourColumnRow extends StatelessWidget {
  final PlayerProfile profile;
  final AppColorTokens colors;

  const _ProgressionStatsFourColumnRow({
    required this.profile,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < 360;
    final valueSize = narrow ? 13.0 : 16.0;
    final labelSize = narrow ? 9.0 : 11.0;

    Widget cell(String value, String label) {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                value,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: valueSize,
                      color: colors.textPrimary,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: narrow ? 2 : 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: labelSize,
                      color: colors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        cell('${profile.totalWins}', 'Wins'),
        cell('${profile.honorsMvpReceived}', 'MVP'),
        cell('${profile.honorsTeamPlayerReceived}', 'Team player'),
        cell('${profile.honorsUnderdogReceived}', 'Underdog'),
      ],
    );
  }
}

class _ProfileBehaviourStatsBanner extends StatelessWidget {
  final PlayerProfile profile;
  final AppColorTokens colors;

  const _ProfileBehaviourStatsBanner({
    required this.profile,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: RadiusTokens.radiusLg,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.surfaceElevated,
            Color.lerp(colors.surfaceElevated, colors.backgroundSecondary, 0.35)!,
          ],
        ),
        border: Border.all(
          color: colors.borderSubtle.withValues(alpha: 0.55),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: RadiusTokens.radiusLg,
        child: Padding(
          padding: EdgeInsets.all(LayoutTokens.gr3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _BehaviourBarModule(profile: profile, colors: colors),
              Padding(
                padding: EdgeInsets.symmetric(vertical: LayoutTokens.gr3),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: colors.borderSubtle.withValues(alpha: 0.4),
                ),
              ),
              _ProgressionStatsFourColumnRow(profile: profile, colors: colors),
            ],
          ),
        ),
      ),
    );
  }
}

/// 0 = Good, 1 = Salty (from dislike ratio among reactions).
double _saltFraction(PlayerProfile profile) {
  final total = profile.likesReceived + profile.dislikesReceived;
  if (total == 0) return 0.5;
  return (profile.dislikesReceived / total).clamp(0.0, 1.0);
}

class _BehaviourBarModule extends StatelessWidget {
  final PlayerProfile profile;
  final AppColorTokens colors;
  const _BehaviourBarModule({required this.profile, required this.colors});

  @override
  Widget build(BuildContext context) {
    final salt = _saltFraction(profile);
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Player behaviour',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
          ),
          SizedBox(height: LayoutTokens.gr2),
          LayoutBuilder(
            builder: (context, c) {
              final w = c.maxWidth;
              final thumbX = 16.0 + (w - 32.0) * salt;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 8,
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
                    left: thumbX.clamp(4.0, w - 12.0) - 6,
                    top: -4,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: colors.textPrimary,
                        shape: BoxShape.circle,
                        border: Border.all(color: colors.backgroundPrimary, width: 2),
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
          SizedBox(height: LayoutTokens.gr2),
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
        ],
    );
  }
}

class _RecentGamesModule extends StatefulWidget {
  final List<MatchRecord> matches;
  final AppColorTokens colors;
  const _RecentGamesModule({required this.matches, required this.colors});

  @override
  State<_RecentGamesModule> createState() => _RecentGamesModuleState();
}

class _RecentGamesModuleState extends State<_RecentGamesModule> {
  bool _expanded = false;

  static const int _initialCount = 5;

  @override
  Widget build(BuildContext context) {
    final matches = widget.matches;
    final hasMore = matches.length > _initialCount;
    final displayed = _expanded
        ? matches
        : matches.take(_initialCount).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Games',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: widget.colors.textPrimary,
              ),
        ),
        SizedBox(height: LayoutTokens.gr2),
        if (matches.isEmpty)
          UiSurface(
            padding: EdgeInsets.all(MediaQuery.sizeOf(context).width < 360 ? LayoutTokens.gr3 : LayoutTokens.gr4),
            borderRadius: RadiusTokens.radiusMd,
            child: Center(
              child: Text(
                'No recent matches.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: widget.colors.textSecondary,
                    ),
              ),
            ),
          )
        else ...[
          ...displayed.map((m) => _RecentMatchRow(match: m, colors: widget.colors)),
          if (hasMore)
            Padding(
              padding: EdgeInsets.only(top: LayoutTokens.gr2),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => setState(() => _expanded = !_expanded),
                  child: Text(
                    _expanded ? 'See less' : 'See more',
                    style: TextStyle(
                      color: widget.colors.primaryAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
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

    return Padding(
      padding: EdgeInsets.only(bottom: LayoutTokens.gr2),
      child: UiSurface(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.sizeOf(context).width < 360 ? LayoutTokens.gr2 : LayoutTokens.gr3,
          vertical: LayoutTokens.gr2,
        ),
        borderRadius: RadiusTokens.radiusMd,
        borderColor: _resultColor.withValues(alpha: 0.5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: () => setState(() => _open = !_open),
              borderRadius: BorderRadius.circular(RadiusTokens.md),
              child: Row(
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
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: MediaQuery.sizeOf(context).width < 360 ? 14 : null,
                                ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                          SizedBox(height: LayoutTokens.gr0),
                          Text(
                            '${fmt.format(m.date)} · ${timeFmt.format(m.date)}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
                        fontSize: MediaQuery.sizeOf(context).width < 360 ? FontTokens.sm : FontTokens.caption,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
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
                  children: participants.map((p) {
                    return Chip(
                      avatar: CircleAvatar(
                        backgroundColor: colors.primaryAccent.withValues(alpha: 0.3),
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
                        style: TextStyle(color: colors.textPrimary, fontSize: 12),
                      ),
                      backgroundColor: colors.backgroundSecondary,
                      side: BorderSide(color: colors.textSecondary.withValues(alpha: 0.2)),
                    );
                  }).toList(),
                ),
              ],
            ],
          ],
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

MatchRecord _previewPlaceholderMatch() {
  final participants = [
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
  return MatchRecord(
    matchId: '__preview_placeholder__',
    date: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
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
    participantsJson: jsonEncode(
      participants.map((e) => e.toJson()).toList(),
    ),
    podNameSnapshot: 'Friday Night',
    locationSnapshot: null,
    localDeckIdSnapshot: null,
  );
}

class _DeckPerformanceSection extends ConsumerStatefulWidget {
  final AppColorTokens colors;
  const _DeckPerformanceSection({required this.colors});

  @override
  ConsumerState<_DeckPerformanceSection> createState() =>
      _DeckPerformanceSectionState();
}

class _DeckPerformanceSectionState extends ConsumerState<_DeckPerformanceSection> {
  List<PlayerDeck> _decks = [];

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    setState(() {
      _decks = ref.read(deckRepositoryProvider).getAll();
      _decks.sort((a, b) => b.gamesPlayed.compareTo(a.gamesPlayed));
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Deck performance',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
              ),
            ),
            TextButton(
              onPressed: () {
                context.push(AppRoutes.profileDecks).then((_) {
                  if (mounted) _reload();
                });
              },
              child: Text(
                'Manage',
                style: TextStyle(
                  color: colors.primaryAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: LayoutTokens.gr2),
        if (_decks.isEmpty)
          UiSurface(
            padding: EdgeInsets.all(
              MediaQuery.sizeOf(context).width < 360
                  ? LayoutTokens.gr3
                  : LayoutTokens.gr4,
            ),
            borderRadius: RadiusTokens.radiusMd,
            child: Text(
              'Register a deck with a commander, then tap “Deck” in the lobby '
              'before you ready up. Wins and losses roll up here by deck.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.textSecondary,
                  ),
            ),
          )
        else
          ..._decks.take(6).map(
                (d) => Padding(
                  padding: EdgeInsets.only(bottom: LayoutTokens.gr2),
                  child: UiSurface(
                    padding: EdgeInsets.symmetric(
                      horizontal: LayoutTokens.gr3,
                      vertical: LayoutTokens.gr2,
                    ),
                    borderRadius: RadiusTokens.radiusMd,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                d.displayName,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: colors.textPrimary,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                d.commanderName,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: colors.textSecondary,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              d.gamesPlayed == 0
                                  ? '—'
                                  : '${(d.winRate * 100).round()}%',
                              style: TextStyle(
                                color: colors.primaryAccent,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '${d.wins}W · ${d.losses}L · ${d.gamesPlayed} GP',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(color: colors.textSecondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ],
    );
  }
}
