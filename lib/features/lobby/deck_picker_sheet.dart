import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/game/game_format.dart';
import '../../core/game/lobby_state.dart';
import '../../core/persistence/providers.dart';
import '../../features/game/widgets/game_modal_chrome.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/utils/app_router.dart';
import '../../ui/theme/app_color_tokens.dart';
import '../../ui/tokens/font_tokens.dart';
import '../../ui/tokens/layout_tokens.dart';

/// Pick a registered deck for match tracking, or clear deck selection.
Future<void> showDeckPickerSheet(
  BuildContext context,
  WidgetRef ref,
  String playerId,
) async {
  final lobbyFormat = ref.read(lobbyProvider).config.format;
  final isCommanderLobby = lobbyFormat.isCommanderStyle;
  final allForFormat = ref
      .read(deckRepositoryProvider)
      .getAll()
      .where((d) => d.matchesLobbyFormat(lobbyFormat))
      .toList();
  final decks = allForFormat.where((d) => d.hasDeckStyle).toList();
  final needsStyle = allForFormat.where((d) => !d.hasDeckStyle).length;
  await showGameBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) {
      final colors = AppColorTokens.of(ctx);
      final l10n = AppLocalizations.of(ctx);
      return GameSheetBody(
        scrollable: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            GameSheetHeader(title: l10n.deckPickerTitle),
            SizedBox(height: LayoutTokens.gr2),
            if (isCommanderLobby)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading:
                    Icon(Icons.person_outline, color: colors.textSecondary),
                title: Text(
                  l10n.deckPickerManualOnly,
                  style: TextStyle(color: colors.textPrimary),
                ),
                subtitle: Text(
                  l10n.deckPickerManualOnlySubtitle,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: FontTokens.caption,
                  ),
                ),
                onTap: () {
                  ref.read(lobbyProvider.notifier).clearSelectedDeck(playerId);
                  Navigator.pop(ctx);
                },
              ),
            if (isCommanderLobby)
              Divider(color: colors.borderSubtle, height: 1),
            if (decks.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: LayoutTokens.gr2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      needsStyle > 0
                          ? '$needsStyle deck${needsStyle == 1 ? '' : 's'} '
                              'need a style set in the Decks tab before lobby use.'
                          : l10n.deckPickerEmptyForFormat(
                              lobbyFormat.displayName,
                            ),
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: FontTokens.hudSm,
                      ),
                    ),
                    SizedBox(height: LayoutTokens.gr2),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        ctx.go(AppRoutes.decks);
                      },
                      child: Text(l10n.deckPickerOpenDecks),
                    ),
                  ],
                ),
              )
            else
              ...decks.map(
                (d) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.style, color: colors.primaryAccent),
                  title: Text(
                    d.displayName,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    [
                      d.deckStyleDisplayName,
                      d.hasPartner
                          ? '${d.commanderName} // ${d.partnerCommanderName}'
                          : d.commanderName,
                    ].join(' · '),
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: FontTokens.caption,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    d.gamesPlayed > 0
                        ? '${(d.winRate * 100).round()}% WR'
                        : '—',
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: FontTokens.caption,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    ref
                        .read(lobbyProvider.notifier)
                        .applyDeck(playerId: playerId, deck: d);
                    Navigator.pop(ctx);
                  },
                ),
              ),
          ],
        ),
      );
    },
  );
}
