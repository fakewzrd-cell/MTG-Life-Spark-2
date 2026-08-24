import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' show DateFormat, NumberFormat;

import '../../core/debug/app_log.dart';
import '../../core/models/player_profile.dart';
import '../../core/persistence/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/utils/app_router.dart';
import '../../shared/widgets/profile_avatar_image.dart';
import '../../shared/widgets/profile_default_banner.dart';
import '../../shared/widgets/tier_badge.dart';
import '../../ui/components/ui_button.dart';
import '../../ui/components/ui_snack_bar.dart';
import '../../ui/theme/app_color_tokens.dart';
import '../../ui/tokens/font_tokens.dart';
import '../../ui/tokens/layout_tokens.dart';
import '../../ui/tokens/motion_tokens.dart';
import '../../ui/tokens/opacity_tokens.dart';
import '../../ui/tokens/radius_tokens.dart';
import '../game/widgets/game_modal_chrome.dart';
import 'profile_carousel_sections.dart';
import 'profile_hero_layout.dart';
import 'profile_options_sheet.dart';
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

  Future<void> _openProfileOptions() async {
    final action = await showProfileOptionsSheet(context);
    if (!mounted || action == null) return;
    switch (action) {
      case ProfileSheetAction.editProfile:
        _enterEditMode();
      case ProfileSheetAction.backupProfile:
        // Wait for the options sheet to finish dismissing before share UI.
        await Future<void>.delayed(MotionTokens.standard);
        if (!mounted) return;
        await _exportBackup();
    }
  }

  Future<void> _exportBackup() async {
    try {
      final saved = await ref.read(backupServiceProvider).exportToFile();
      if (!mounted) return;
      if (saved) {
        showUiSnackBar(context, AppLocalizations.of(context).backupSaved);
      }
    } catch (e, st) {
      appLog('Profile: export backup failed', error: e, stackTrace: st);
      if (!mounted) return;
      showUiSnackBar(
        context,
        AppLocalizations.of(context).profileBackupSaveFailed,
        isError: true,
      );
    }
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
                  AppLocalizations.of(context).profileSetupPrompt,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: LayoutTokens.gr4),
                UiButton(
                  label: AppLocalizations.of(context).profileCreateCta,
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
    final firstPlayed = allMatches.isEmpty
        ? null
        : allMatches.map((m) => m.date).reduce((a, b) => a.isBefore(b) ? a : b);

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
                firstPlayed: firstPlayed,
                editing: _editing,
                onOpenOptions: _openProfileOptions,
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
                  ),
                  SizedBox(height: LayoutTokens.shellSectionGap),
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
    required this.firstPlayed,
    required this.editing,
    required this.onOpenOptions,
    required this.onExitEdit,
    required this.onEditName,
    required this.onEditAvatar,
  });

  final PlayerProfile profile;
  final AppColorTokens colors;
  final ProfileHeroLayoutMetrics metrics;
  final DateTime? firstPlayed;
  final bool editing;
  final VoidCallback onOpenOptions;
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
              left: metrics.overlayHPadding,
              right: metrics.overlayHPadding,
              child: Row(
                children: [
                  Expanded(
                    child: _ProfileHeroCaption(
                      firstPlayed: firstPlayed,
                      colors: colors,
                    ),
                  ),
                  SizedBox(width: LayoutTokens.gr1),
                  _ProfileHeroActionPill(
                    editing: editing,
                    onPressed: editing ? onExitEdit : onOpenOptions,
                  ),
                ],
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

/// Top-leading tenure caption — balances the action pill across the banner.
class _ProfileHeroCaption extends StatelessWidget {
  const _ProfileHeroCaption({
    required this.firstPlayed,
    required this.colors,
  });

  final DateTime? firstPlayed;
  final AppColorTokens colors;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final since = firstPlayed;
    return Text(
      since == null
          ? l10n.profileNewPlayer
          : l10n.profilePlayingSince(DateFormat.yMMM().format(since)),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: FontTokens.label,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
        color: colors.textSecondary,
      ),
    );
  }
}

/// Top-trailing control: opens Profile menu, or exits edit with one tap (Done).
class _ProfileHeroActionPill extends StatelessWidget {
  const _ProfileHeroActionPill({
    required this.editing,
    required this.onPressed,
  });

  final bool editing;
  final VoidCallback onPressed;

  static const double _visualHeight = 28;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTokens.of(context);
    final l10n = AppLocalizations.of(context);
    return Semantics(
      button: true,
      label: editing ? l10n.profileDoneEditing : l10n.profileOptions,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: LayoutTokens.minTapTarget,
          minHeight: LayoutTokens.minTapTarget,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            customBorder: const StadiumBorder(),
            child: Center(
              child: Container(
                height: _visualHeight,
                padding: EdgeInsets.symmetric(horizontal: LayoutTokens.gr2),
                decoration: ShapeDecoration(
                  color: colors.textPrimary.withValues(alpha: OpacityTokens.faint),
                  shape: StadiumBorder(
                    side: BorderSide(
                      color: colors.textPrimary.withValues(
                        alpha: OpacityTokens.soft,
                      ),
                    ),
                  ),
                ),
                child: Center(
                  child: ExcludeSemantics(
                    child: editing
                        ? Text(
                            l10n.profileDone,
                            style: TextStyle(
                              fontSize: FontTokens.label,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                              color: colors.textPrimary.withValues(
                                alpha: OpacityTokens.nearOpaque,
                              ),
                            ),
                          )
                        : Icon(
                            Icons.more_vert_rounded,
                            size: 20,
                            color: colors.textPrimary.withValues(
                              alpha: OpacityTokens.nearOpaque,
                            ),
                          ),
                  ),
                ),
              ),
            ),
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
      color: colors.textPrimary,
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
                          tooltip:
                              AppLocalizations.of(context).profileEditNameTooltip,
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: LayoutTokens.minTapTarget,
                            minHeight: LayoutTokens.minTapTarget,
                          ),
                          icon: Icon(
                            Icons.edit_rounded,
                            size: 20,
                            color: colors.textPrimary.withValues(alpha: 0.92),
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
    final l10n = AppLocalizations.of(context);
    return GameFormDialog(
      title: l10n.profileEditName,
      submitLabel: l10n.commonSave,
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
            labelText: l10n.profileUsernameLabel,
            hintText: l10n.profileUsernameHint,
            hintStyle: TextStyle(color: colors.textSecondary),
          ),
          validator: (v) {
            if (v == null || v.trim().isEmpty) {
              return l10n.profileUsernameRequired;
            }
            if (v.trim().length < 2) return l10n.profileUsernameTooShort;
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

    final avatarChild = ClipOval(
      child: ProfileAvatarImage(imageRef: imageUrl, size: size),
    );

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
                child: Icon(
                  Icons.camera_alt_rounded,
                  size: 16,
                  color: colors.onAccent,
                ),
              ),
            ),
        ],
      ),
    );

    if (onTap == null) return face;

    return Semantics(
      button: true,
      label: AppLocalizations.of(context).profileChangePicture,
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

/// Dark pill: win–loss record leads, with sparks and games as quieter cells.
class _ProfileFloatingStatsPill extends StatelessWidget {
  const _ProfileFloatingStatsPill({required this.profile});

  final PlayerProfile profile;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTokens.of(context);
    final l10n = AppLocalizations.of(context);
    final wins = profile.totalWins;
    final losses = profile.totalLosses;
    final games = profile.totalGamesPlayed > 0
        ? profile.totalGamesPlayed
        : wins + losses;

    return Semantics(
      label:
          '$wins wins, $losses losses, '
          '${profile.honorsStarReceived} sparks of the game, '
          '$games games played',
      child: Material(
        color: colors.surface.withValues(alpha: 0.88),
        borderRadius: RadiusTokens.radiusPill,
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          child: Row(
            children: [
              Expanded(
                child: _StatColumn(
                  value: '$wins–$losses',
                  shortLabel: l10n.profileStatRecord,
                  emphasized: true,
                  accentColor: colors.primaryAccent,
                ),
              ),
              _StatDivider(colors: colors),
              Expanded(
                child: _StatColumn(
                  value: _formatProfileStat(profile.honorsStarReceived),
                  shortLabel: l10n.profileStatSparks,
                ),
              ),
              _StatDivider(colors: colors),
              Expanded(
                child: _StatColumn(
                  value: _formatProfileStat(games),
                  shortLabel: l10n.profileStatGames,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider({required this.colors});

  final AppColorTokens colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 28,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      color: colors.borderSubtle.withValues(alpha: 0.55),
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
