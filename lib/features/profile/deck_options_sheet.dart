import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/game/game_format.dart';
import '../../core/models/player_deck.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/utils/deck_style_l10n.dart';
import '../../shared/widgets/deck_tile_visual.dart';
import '../../ui/theme/app_color_tokens.dart';
import '../../ui/tokens/font_tokens.dart';
import '../../ui/tokens/layout_tokens.dart';
import '../../ui/tokens/radius_tokens.dart';
import '../game/widgets/game_modal_chrome.dart';

/// Actions available from the deck detail / options sheet.
enum DeckSheetAction {
  togglePin,
  changeFormat,
  changeStyle,
  editCover,
  rename,
  duplicate,
  delete,
}

/// Detail + actions sheet when tapping a deck in [DecksManageScreen].
Future<DeckSheetAction?> showDeckDetailSheet(
  BuildContext context,
  PlayerDeck deck,
) {
  return showGameBottomSheet<DeckSheetAction>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) => _DeckDetailSheet(deck: deck),
  );
}

/// Keyboard-safe rename dialog matching shared game chrome.
Future<String?> showRenameDeckDialog(
  BuildContext context, {
  required String initialName,
}) {
  return showDialog<String>(
    context: context,
    builder: (ctx) => _RenameDeckDialog(initialName: initialName),
  );
}

/// Destructive confirm for removing a deck from the library.
Future<bool> showDeleteDeckConfirm(
  BuildContext context,
  PlayerDeck deck,
) async {
  final l10n = AppLocalizations.of(context);
  final ok = await showGameConfirmDialog(
    context: context,
    title: l10n.deckOptionsDeleteTitle,
    message: l10n.deckOptionsDeleteBody(deck.displayName),
    confirmLabel: l10n.deckOptionsDeleteConfirm,
    destructive: true,
  );
  return ok == true;
}

String _deckDetailSubtitle(AppLocalizations l10n, PlayerDeck deck) {
  final parts = <String>[
    deck.gameFormat.displayName,
    deck.hasDeckStyle
        ? localizedDeckStyleName(l10n, deck.deckStyle!)
        : l10n.deckOptionsStyleNotSet,
  ];
  if (deck.commanderName.isNotEmpty) {
    parts.add(
      deck.hasPartner
          ? '${deck.commanderName} // ${deck.partnerCommanderName}'
          : deck.commanderName,
    );
  }
  return parts.join(' · ');
}

class _DeckDetailSheet extends StatelessWidget {
  const _DeckDetailSheet({required this.deck});

  final PlayerDeck deck;

  void _pick(BuildContext context, DeckSheetAction action) {
    HapticFeedback.selectionClick();
    Navigator.pop(context, action);
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTokens.of(context);
    final l10n = AppLocalizations.of(context);
    final coverLabel = deck.isCommanderDeck
        ? l10n.deckOptionsEditCommanders
        : l10n.deckOptionsEditCover;
    final wr = deck.gamesPlayed == 0 ? null : (deck.winRate * 100).round();

    return GameSheetBody(
      // Scroll when the action list exceeds short viewports. Dismiss stays on
      // the Material drag handle (showDragHandle: true above).
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GameSheetHeader(
              title: deck.displayName,
              subtitle: _deckDetailSubtitle(l10n, deck),
              showHandle: false,
            ),
            SizedBox(height: LayoutTokens.gr3),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DeckDetailCoverThumb(deck: deck, colors: colors),
                SizedBox(width: LayoutTokens.gr3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        wr == null
                            ? l10n.deckOptionsNoGamesYet
                            : l10n.deckOptionsWinRate('$wr'),
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: FontTokens.body,
                        ),
                      ),
                      SizedBox(height: LayoutTokens.gr0),
                      Text(
                        l10n.statsRecordFooter(
                          deck.wins,
                          deck.losses,
                          deck.gamesPlayed,
                        ),
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: FontTokens.sm,
                        ),
                      ),
                      SizedBox(height: LayoutTokens.gr2),
                      DeckWinLossRatioBar(
                        deck: deck,
                        colors: colors,
                        height: 8,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: LayoutTokens.gr3),
            _DeckOptionTile(
              colors: colors,
              icon:
                  deck.isPinned
                      ? Icons.push_pin_rounded
                      : Icons.push_pin_outlined,
              title:
                  deck.isPinned ? l10n.deckOptionsUnpin : l10n.deckOptionsPin,
              onTap: () => _pick(context, DeckSheetAction.togglePin),
            ),
            _DeckOptionTile(
              colors: colors,
              icon: Icons.category_outlined,
              title: l10n.deckOptionsChangeFormat,
              subtitle: deck.gameFormat.displayName,
              onTap: () => _pick(context, DeckSheetAction.changeFormat),
            ),
            _DeckOptionTile(
              colors: colors,
              icon: Icons.palette_outlined,
              title: l10n.deckOptionsChangeStyle,
              subtitle: deck.hasDeckStyle
                  ? localizedDeckStyleName(l10n, deck.deckStyle!)
                  : l10n.deckOptionsStyleRequired,
              titleColor:
                  deck.hasDeckStyle ? colors.textPrimary : colors.warning,
              onTap: () => _pick(context, DeckSheetAction.changeStyle),
            ),
            _DeckOptionTile(
              colors: colors,
              icon:
                  deck.isCommanderDeck
                      ? Icons.groups_2_outlined
                      : Icons.image_outlined,
              title: coverLabel,
              onTap: () => _pick(context, DeckSheetAction.editCover),
            ),
            _DeckOptionTile(
              colors: colors,
              icon: Icons.edit_outlined,
              title: l10n.deckOptionsRename,
              iconColor: colors.textPrimary,
              onTap: () => _pick(context, DeckSheetAction.rename),
            ),
            _DeckOptionTile(
              colors: colors,
              icon: Icons.copy_outlined,
              title: l10n.deckOptionsDuplicate,
              onTap: () => _pick(context, DeckSheetAction.duplicate),
            ),
            Divider(
              height: LayoutTokens.gr2,
              color: colors.borderSubtle.withValues(alpha: 0.45),
            ),
            _DeckOptionTile(
              colors: colors,
              icon: Icons.delete_outline,
              title: l10n.deckOptionsDelete,
              iconColor: colors.error,
              titleColor: colors.error,
              onTap: () => _pick(context, DeckSheetAction.delete),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeckDetailCoverThumb extends StatelessWidget {
  const _DeckDetailCoverThumb({required this.deck, required this.colors});

  final PlayerDeck deck;
  final AppColorTokens colors;

  @override
  Widget build(BuildContext context) {
    final url = deck.commanderImageUrl;
    return ClipRRect(
      borderRadius: RadiusTokens.radiusSm,
      child: SizedBox(
        width: 56,
        height: 78,
        child:
            url != null && url.isNotEmpty
                ? CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.cover,
                  errorWidget:
                      (_, __, ___) => ColoredBox(
                        color: colors.surface,
                        child: Icon(
                          Icons.style_outlined,
                          color: colors.textSecondary,
                        ),
                      ),
                )
                : ColoredBox(
                  color: colors.surface,
                  child: Icon(
                    Icons.style_outlined,
                    color: colors.textSecondary,
                  ),
                ),
      ),
    );
  }
}

class _DeckOptionTile extends StatelessWidget {
  const _DeckOptionTile({
    required this.colors,
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.iconColor,
    this.titleColor,
  });

  final AppColorTokens colors;
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      leading: Icon(icon, color: iconColor ?? colors.primaryAccent, size: 22),
      title: Text(
        title,
        style: TextStyle(
          color: titleColor ?? colors.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: FontTokens.body,
        ),
      ),
      subtitle:
          subtitle == null
              ? null
              : Text(
                subtitle!,
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: FontTokens.sm,
                ),
              ),
      onTap: onTap,
    );
  }
}

class _RenameDeckDialog extends StatefulWidget {
  const _RenameDeckDialog({required this.initialName});

  final String initialName;

  @override
  State<_RenameDeckDialog> createState() => _RenameDeckDialogState();
}

class _RenameDeckDialogState extends State<_RenameDeckDialog> {
  late final TextEditingController _controller;
  bool _canSave = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
    _canSave = widget.initialName.trim().isNotEmpty;
    _controller.addListener(_syncCanSave);
  }

  @override
  void dispose() {
    _controller.removeListener(_syncCanSave);
    _controller.dispose();
    super.dispose();
  }

  void _syncCanSave() {
    final next = _controller.text.trim().isNotEmpty;
    if (next != _canSave) setState(() => _canSave = next);
  }

  void _submit() {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    Navigator.pop(context, name);
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTokens.of(context);
    final l10n = AppLocalizations.of(context);

    return GameFormDialog(
      title: l10n.deckOptionsRenameTitle,
      submitLabel: l10n.commonSave,
      enabled: _canSave,
      onSubmit: _canSave ? _submit : null,
      content: TextField(
        controller: _controller,
        autofocus: true,
        scrollPadding: const EdgeInsets.only(bottom: 120),
        textInputAction: TextInputAction.done,
        onSubmitted: (_) {
          if (_canSave) _submit();
        },
        decoration: InputDecoration(
          labelText: l10n.deckOptionsNameLabel,
          hintText: l10n.deckOptionsNameHint,
          hintStyle: TextStyle(color: colors.textSecondary),
        ),
        style: TextStyle(color: colors.textPrimary),
      ),
    );
  }
}
