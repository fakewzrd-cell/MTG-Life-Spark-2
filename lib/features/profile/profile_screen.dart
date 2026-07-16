import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../game/widgets/game_modal_chrome.dart';
import 'profile_carousel_sections.dart';
import 'profile_hero_layout.dart';
import 'profile_player_stats_section.dart';
import 'ranks_info_sheet.dart';

/// Camera badge diameter — centered on the avatar ring at bottom-right.
const double _kProfileCameraBadgeSize = 32;

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  var _editing = false;

  void _enterEditMode() {
    HapticFeedback.selectionClick();
    setState(() => _editing = true);
  }

  void _exitEditMode() {
    HapticFeedback.selectionClick();
    setState(() => _editing = false);
  }

  Future<void> _editUsername(PlayerProfile profile) async {
    final next = await showDialog<String>(
      context: context,
      builder: (ctx) => _EditUsernameDialog(initialName: profile.username),
    );
    if (next == null || !mounted) return;
    if (next == profile.username) return;
    profile.username = next;
    await ref.read(profileRepositoryProvider).saveProfile(profile);
    bumpProfileRevision(ref);
  }

  @override
  Widget build(BuildContext context) {
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

    final allMatches = matchRepo
        .getAllMatches()
        .where((m) => !m.matchId.startsWith('__preview_placeholder'))
        .toList();

    final colors = AppColorTokens.of(context);
    final heroMetrics = ProfileHeroLayoutMetrics.resolve(context);
    final hPad = heroMetrics.overlayHPadding;
    final scrollBottomPad = LayoutTokens.shellBottomInset(context);
    final hasPlayedGames =
        profile.totalGamesPlayed > 0 || allMatches.isNotEmpty;

    return Scaffold(
      backgroundColor: colors.backgroundPrimary,
      body: SafeArea(
        top: false,
        bottom: false,
        child: CustomScrollView(
          key: ValueKey('${profileWatch.revision}-$_editing'),
          slivers: [
            SliverToBoxAdapter(
              child: _ProfileHeroCard(
                profile: profile,
                colors: colors,
                metrics: heroMetrics,
                editing: _editing,
                onEnterEdit: _enterEditMode,
                onExitEdit: _exitEditMode,
                onEditName: () => _editUsername(profile),
                onEditAvatar: () => context.push(AppRoutes.profileAvatar),
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
                    hasPlayedGames: hasPlayedGames,
                  ),                  SizedBox(height: LayoutTokens.shellSectionGap),
                  ProfileDeckPerformanceSection(
                    colors: colors,
                    hasPlayedGames: hasPlayedGames,
                  ),
                  SizedBox(height: LayoutTokens.shellSectionGap),
                  ProfileRecentGamesModule(
                    matches: allMatches,
                    colors: colors,
                  ),
                  SizedBox(height: LayoutTokens.gr4),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatProfileStat(int n) => NumberFormat.decimalPattern().format(n);

/// Full-bleed hero header: brand gradient, rounded bottom only.
class _ProfileHeroCard extends StatelessWidget {
  const _ProfileHeroCard({
    required this.profile,
    required this.colors,
    required this.metrics,
    required this.editing,
    required this.onEnterEdit,
    required this.onExitEdit,
    required this.onEditName,
    required this.onEditAvatar,
  });

  final PlayerProfile profile;
  final AppColorTokens colors;
  final ProfileHeroLayoutMetrics metrics;
  final bool editing;
  final VoidCallback onEnterEdit;
  final VoidCallback onExitEdit;
  final VoidCallback onEditName;
  final VoidCallback onEditAvatar;

  static final BorderRadius _heroRadius = BorderRadius.vertical(
    bottom: Radius.circular(RadiusTokens.bento),
  );

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: _heroRadius,
      child: SizedBox(
        height: metrics.cardHeight,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(child: defaultBannerFill(context)),
            Positioned(
              top: metrics.topInset + LayoutTokens.gr2,
              right: metrics.overlayHPadding,
              child: _ProfileEditModePill(
                editing: editing,
                onPressed: editing ? onExitEdit : onEnterEdit,
              ),
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
                    editing: editing,
                    onEditName: onEditName,
                    onEditAvatar: onEditAvatar,
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

/// Top-trailing Edit ↔ Done mode toggle — quiet so it doesn't compete with the hero.
class _ProfileEditModePill extends StatelessWidget {
  const _ProfileEditModePill({
    required this.editing,
    required this.onPressed,
  });

  final bool editing;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ColorTokens.onAccent.withValues(alpha: 0.08),
      shape: CircleBorder(
        side: BorderSide(
          color: ColorTokens.onAccent.withValues(alpha: 0.22),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: LayoutTokens.minTapTarget,
          height: LayoutTokens.minTapTarget,
          child: Icon(
            editing ? Icons.check_rounded : Icons.edit_outlined,
            size: 18,
            color: ColorTokens.onAccent.withValues(alpha: 0.72),
            semanticLabel: editing ? 'Done editing' : 'Edit profile',
          ),
        ),
      ),
    );
  }
}

/// Avatar, name, tier badge, and stats pill.
class _ProfileHeroIdentityAndStats extends StatelessWidget {
  const _ProfileHeroIdentityAndStats({
    required this.profile,
    required this.colors,
    required this.avatarSize,
    required this.editing,
    required this.onEditName,
    required this.onEditAvatar,
  });

  final PlayerProfile profile;
  final AppColorTokens colors;
  final double avatarSize;
  final bool editing;
  final VoidCallback onEditName;
  final VoidCallback onEditAvatar;

  @override
  Widget build(BuildContext context) {
    final nameStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
      color: ColorTokens.onAccent,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.3,
    );

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
              showCameraBadge: editing,
              onTap: editing ? onEditAvatar : null,
            ),
            SizedBox(width: LayoutTokens.gr3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          profile.username,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: nameStyle,
                        ),
                      ),
                      if (editing) ...[
                        SizedBox(width: LayoutTokens.gr1),
                        IconButton(
                          onPressed: onEditName,
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
                    ],
                  ),
                  SizedBox(height: LayoutTokens.gr0),
                  TierBadge(
                    tier: profile.tier,
                    level: profile.level,
                    showInfoIcon: !editing,
                    onTap: editing
                        ? null
                        : () => showRanksInfoSheet(
                            context,
                            currentLevel: profile.level,
                          ),
                  ),
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

class _EditUsernameDialog extends StatefulWidget {
  const _EditUsernameDialog({required this.initialName});

  final String initialName;

  @override
  State<_EditUsernameDialog> createState() => _EditUsernameDialogState();
}

class _EditUsernameDialogState extends State<_EditUsernameDialog> {
  late final TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();
  var _canSave = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
    _canSave = _isValid(widget.initialName);
    _controller.addListener(_syncCanSave);
  }

  @override
  void dispose() {
    _controller.removeListener(_syncCanSave);
    _controller.dispose();
    super.dispose();
  }

  bool _isValid(String raw) => raw.trim().length >= 2;

  void _syncCanSave() {
    final next = _isValid(_controller.text);
    if (next != _canSave) setState(() => _canSave = next);
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.pop(context, _controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTokens.of(context);
    return GameFormDialog(
      title: 'Edit name',
      submitLabel: 'Save',
      enabled: _canSave,
      onSubmit: _canSave ? _submit : null,
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          maxLength: 20,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) {
            if (_canSave) _submit();
          },
          style: TextStyle(color: colors.textPrimary),
          decoration: InputDecoration(
            labelText: 'Username',
            hintText: 'e.g. The Archduke',
            hintStyle: TextStyle(color: colors.textSecondary),
          ),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Enter a username';
            if (v.trim().length < 2) return 'Must be at least 2 characters';
            return null;
          },
        ),
      ),
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

/// Circular profile picture beside the username.
class _ProfileHeroAvatar extends StatelessWidget {
  const _ProfileHeroAvatar({
    required this.profile,
    required this.colors,
    required this.size,
    required this.showCameraBadge,
    this.onTap,
  });

  final PlayerProfile profile;
  final AppColorTokens colors;
  final double size;
  final bool showCameraBadge;
  final VoidCallback? onTap;

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
          placeholder: (context, url) => DefaultProfileAvatarFill(size: size),
          errorWidget: (context, url, error) =>
              DefaultProfileAvatarFill(size: size),
        ),
      );
    } else {
      avatarChild = DefaultProfileAvatarFill(size: size);
    }

    const ringWidth = 3.0;
    final ringRadius = size / 2 - ringWidth / 2;
    final edgeInset = ringRadius * (1 - 0.7071067811865476);
    final badgeOffset = edgeInset - _kProfileCameraBadgeSize / 2;

    final face = SizedBox(
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
                color: Colors.white.withValues(alpha: showCameraBadge ? 1 : 0.9),
                width: showCameraBadge ? 3.5 : ringWidth,
              ),
            ),
            child: ClipOval(child: avatarChild),
          ),
          if (showCameraBadge)
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
    );

    if (onTap == null) return face;

    return Semantics(
      button: true,
      label: 'Change profile picture',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: face,
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

    return Semantics(
      label:
          '${profile.totalWins} wins, '
          '${profile.honorsMvpReceived} MVP, '
          '${profile.honorsTeamPlayerReceived} team player, '
          '${profile.honorsUnderdogReceived} underdog honors',
      child: Material(
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
    final labelColor =
        emphasized ? colors.textSecondary : colors.textMuted;

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
