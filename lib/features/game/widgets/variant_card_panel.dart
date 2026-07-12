import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/game/game_providers.dart';
import '../../../core/game/game_state.dart';
import '../../../core/game/scryfall_service.dart';
import '../../../shared/utils/game_haptics.dart';
import 'game_colors.dart';
import '../../../shared/widgets/game_icon.dart';
import '../../../ui/tokens/font_tokens.dart';
import '../../../ui/tokens/layout_tokens.dart';
import '../../../ui/tokens/opacity_tokens.dart';
import '../../../ui/tokens/radius_tokens.dart';
import 'game_modal_chrome.dart';
import '../../../ui/tokens/spacing_tokens.dart';

/// Compact tap target that opens the full [VariantCardPanel] in a bottom
/// sheet — keeps variant deck content (which can be tall with card art) off
/// the Play tab's flexible layout budget entirely, so it never competes with
/// the life counter for space. Renders nothing when no variant is enabled.
class VariantQuickAccessChip extends ConsumerWidget {
  const VariantQuickAccessChip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.gameColors;
    final variantFlags = ref.watch(
      gameProvider.select(
        (g) => (g.planechaseEnabled, g.archenemyEnabled, g.bountyEnabled),
      ),
    );
    final activeCount =
        [variantFlags.$1, variantFlags.$2, variantFlags.$3]
            .where((enabled) => enabled)
            .length;

    if (activeCount == 0) return const SizedBox.shrink();

    final label = activeCount == 1 ? 'Variant deck' : 'Variant decks';

    return Center(
      child: Semantics(
        button: true,
        label: '$label, tap to view',
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              context.gameHapticSelection();
              _showVariantSheet(context);
            },
            borderRadius: RadiusTokens.radiusPill,
            child: Container(
              constraints: const BoxConstraints(
                minHeight: LayoutTokens.minTapTarget,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: LayoutTokens.gr3,
                vertical: LayoutTokens.gr1,
              ),
              decoration: BoxDecoration(
                color: colors.backgroundSecondary.withValues(
                  alpha: OpacityTokens.soft,
                ),
                borderRadius: RadiusTokens.radiusPill,
                border: Border.all(
                  color: colors.borderSubtle.withValues(
                    alpha: OpacityTokens.strong,
                  ),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.style_outlined,
                    size: 16,
                    color: colors.textPrimary,
                  ),
                  SizedBox(width: LayoutTokens.gr1),
                  Text(
                    label,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: FontTokens.hudSm,
                    ),
                  ),
                  SizedBox(width: LayoutTokens.gr0),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: colors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showVariantSheet(BuildContext context) {
    showGameBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: false,
      builder: (ctx) => GameSheetBody(
        scrollable: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: const [
            GameSheetHeader(title: 'Variant decks'),
            SizedBox(height: LayoutTokens.gr2),
            VariantCardPanel(),
          ],
        ),
      ),
    );
  }
}

/// Shows current Planechase plane, Archenemy scheme, or Bounty card with
/// advance controls. Requires internet for deck data.
class VariantCardPanel extends ConsumerWidget {
  const VariantCardPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.gameColors;
    final variantFlags = ref.watch(
      gameProvider.select(
        (g) => (
          g.planechaseEnabled,
          g.archenemyEnabled,
          g.bountyEnabled,
        ),
      ),
    );
    ref.watch(
      gameProvider.select(
        (g) => (
          g.currentPlanarIndex,
          g.currentSchemeIndex,
          g.currentBountyIndex,
        ),
      ),
    );

    if (!variantFlags.$1 && !variantFlags.$2 && !variantFlags.$3) {
      return const SizedBox.shrink();
    }

    final decksAsync = ref.watch(variantDecksProvider);
    final game = ref.read(gameProvider);

    return decksAsync.when(
      data: (decks) => _VariantContent(
        game: game,
        decks: decks,
        notifier: ref.read(gameProvider.notifier),
      ),
      loading: () => Padding(
        padding: SpacingTokens.horizontalMd.add(SpacingTokens.verticalXs),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: LayoutTokens.gr5 - LayoutTokens.gr0,
              height: LayoutTokens.gr5 - LayoutTokens.gr0,
              child: CircularProgressIndicator(
                strokeWidth: LayoutTokens.gr0 / 2,
              ),
            ),
            SizedBox(width: LayoutTokens.gr2),
            Text(
              'Loading variant decks…',
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: LayoutTokens.gr3,
              ),
            ),
          ],
        ),
      ),
      error: (_, __) => Padding(
          padding: SpacingTokens.horizontalMd.add(SpacingTokens.verticalXs),
          child: Text(
            'Could not load decks (internet required)',
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: LayoutTokens.gr2,
            ),
          ),
        ),
    );
  }
}

class _VariantContent extends StatelessWidget {
  final GameState game;
  final Map<String, List<ScryfallCard>> decks;
  final dynamic notifier;

  const _VariantContent({
    required this.game,
    required this.decks,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    final children = <Widget>[];

    if (game.planechaseEnabled) {
      final planar = decks['planar'] ?? [];
      if (planar.isNotEmpty) {
        children.add(
          _VariantTile(
            title: 'Planechase',
            icon: Icons.public,
            iconWidget: null,
            card: planar[game.currentPlanarIndex % planar.length],
            deckSize: planar.length,
            onAdvance: () => notifier.advancePlanar(planar.length),
          ),
        );
      }
    }

    if (game.archenemyEnabled) {
      final scheme = decks['scheme'] ?? [];
      if (scheme.isNotEmpty) {
        children.add(
          _VariantTile(
            title: 'Archenemy',
            icon: Icons.shield,
            iconWidget: null,
            card: scheme[game.currentSchemeIndex % scheme.length],
            deckSize: scheme.length,
            onAdvance: () => notifier.advanceScheme(scheme.length),
          ),
        );
      }
    }

    if (game.bountyEnabled) {
      final bounty = decks['bounty'] ?? [];
      if (bounty.isNotEmpty) {
        children.add(
          _VariantTile(
            title: 'Bounty',
            iconWidget: GameIcon.bounty(size: 20, color: colors.primaryAccent),
            card: bounty[game.currentBountyIndex % bounty.length],
            deckSize: bounty.length,
            onAdvance: () => notifier.advanceBounty(bounty.length),
          ),
        );
      }
    }

    if (children.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: LayoutTokens.gr2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

class _VariantTile extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Widget? iconWidget;
  final ScryfallCard card;
  final int deckSize;
  final VoidCallback onAdvance;

  const _VariantTile({
    required this.title,
    this.icon,
    this.iconWidget,
    required this.card,
    required this.deckSize,
    required this.onAdvance,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    final pad = LayoutTokens.gr3;
    final narrow = MediaQuery.sizeOf(context).width < 360;
    final thumbW = narrow ? 56.0 : 72.0;
    final thumbH = narrow ? 80.0 : 100.0;
    return Container(
      margin: EdgeInsets.only(bottom: pad),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: RadiusTokens.radiusMd,
        border: Border.all(color: colors.backgroundSecondary, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showCardDetail(context),
          borderRadius: RadiusTokens.radiusMd,
          child: Padding(
            padding: EdgeInsets.all(pad),
            child: Row(
              children: [
                // Card thumbnail
                ClipRRect(
                  borderRadius: RadiusTokens.radiusSm,
                  child: SizedBox(
                    width: thumbW,
                    height: thumbH,
                    child: card.imageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: card.imageUrl!,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              color: colors.backgroundSecondary,
                              child: Center(
                                child: Icon(
                                  Icons.image_outlined,
                                  color: colors.textSecondary,
                                  size: 24,
                                ),
                              ),
                            ),
                            errorWidget: (_, __, ___) => Container(
                              color: colors.backgroundSecondary,
                              child: Icon(
                                Icons.broken_image_outlined,
                                color: colors.textSecondary,
                              ),
                            ),
                          )
                        : Container(
                            color: colors.backgroundSecondary,
                            child: Icon(
                              Icons.help_outline,
                              color: colors.textSecondary,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 16),
                // Name + oracle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (iconWidget != null)
                            iconWidget!
                          else if (icon != null)
                            Icon(icon, size: 20, color: colors.primaryAccent),
                          const SizedBox(width: 8),
                          Text(
                            title,
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontSize: FontTokens.caption,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        card.name,
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: FontTokens.body,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (card.oracleText != null &&
                          card.oracleText!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          card.oracleText!,
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: FontTokens.caption,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                // Advance button
                IconButton(
                  icon: Icon(Icons.skip_next),
                  onPressed: onAdvance,
                  tooltip: 'Next card',
                  color: colors.primaryAccent,
                  style: IconButton.styleFrom(
                    backgroundColor: colors.primaryAccent.withValues(alpha: 0.2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCardDetail(BuildContext context) {
    final colors = context.gameColors;
    showGameBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: GameModalChrome.sheetPadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const GameSheetHandle(),
              SizedBox(height: LayoutTokens.gr2),
              GameSheetHeader(
                title: card.name,
                showHandle: false,
              ),
              SizedBox(height: LayoutTokens.gr3),
              if (card.imageUrl != null)
                Center(
                  child: ClipRRect(
                    borderRadius: RadiusTokens.radiusSm,
                    child: CachedNetworkImage(
                      imageUrl: card.imageUrl!,
                      width: (MediaQuery.sizeOf(context).width - 40)
                          .clamp(200.0, 280.0),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              if (card.oracleText != null && card.oracleText!.isNotEmpty) ...[
                SizedBox(height: LayoutTokens.gr3),
                Text(
                  card.oracleText!,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: FontTokens.body,
                    height: 1.4,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
