import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/game/game_format.dart';
import '../../core/models/player_deck.dart';
import '../../ui/theme/app_color_tokens.dart';
import '../../ui/tokens/font_tokens.dart';
import '../../ui/tokens/layout_tokens.dart';
import '../game/widgets/game_modal_chrome.dart';

/// Actions available from the deck options bottom sheet.
enum DeckSheetAction {
  changeStyle,
  editCover,
  rename,
  delete,
}

/// Bottom sheet shown when tapping a deck in [DecksManageScreen].
Future<DeckSheetAction?> showDeckOptionsSheet(
  BuildContext context,
  PlayerDeck deck,
) {
  return showGameBottomSheet<DeckSheetAction>(
    context: context,
    builder: (ctx) => _DeckOptionsSheet(deck: deck),
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
  final ok = await showGameConfirmDialog(
    context: context,
    title: 'Delete deck?',
    message:
        'Remove “${deck.displayName}” from your library? Match history stays, '
        'but this deck will no longer appear in the lobby picker.',
    confirmLabel: 'Delete',
    destructive: true,
  );
  return ok == true;
}

String _deckOptionsSubtitle(PlayerDeck deck) {
  final parts = <String>[
    deck.gameFormat.displayName,
    deck.hasDeckStyle ? deck.deckStyleDisplayName : 'Style not set',
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

class _DeckOptionsSheet extends StatelessWidget {
  const _DeckOptionsSheet({required this.deck});

  final PlayerDeck deck;

  void _pick(BuildContext context, DeckSheetAction action) {
    HapticFeedback.selectionClick();
    Navigator.pop(context, action);
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTokens.of(context);
    final coverLabel =
        deck.isCommanderDeck ? 'Edit commanders' : 'Edit cover card';
    final styleTitle = deck.hasDeckStyle
        ? 'Deck style: ${deck.deckStyleDisplayName}'
        : 'Set deck style (required)';

    return GameSheetBody(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GameSheetHeader(
            title: deck.displayName,
            subtitle: _deckOptionsSubtitle(deck),
          ),
          SizedBox(height: LayoutTokens.gr2),
          _DeckOptionTile(
            colors: colors,
            icon: Icons.palette_outlined,
            title: styleTitle,
            titleColor: deck.hasDeckStyle ? colors.textPrimary : colors.warning,
            onTap: () => _pick(context, DeckSheetAction.changeStyle),
          ),
          _DeckOptionTile(
            colors: colors,
            icon: deck.isCommanderDeck
                ? Icons.groups_2_outlined
                : Icons.image_outlined,
            title: coverLabel,
            onTap: () => _pick(context, DeckSheetAction.editCover),
          ),
          _DeckOptionTile(
            colors: colors,
            icon: Icons.edit_outlined,
            title: 'Rename',
            iconColor: colors.textPrimary,
            onTap: () => _pick(context, DeckSheetAction.rename),
          ),
          Divider(
            height: LayoutTokens.gr2,
            color: colors.borderSubtle.withValues(alpha: 0.45),
          ),
          _DeckOptionTile(
            colors: colors,
            icon: Icons.delete_outline,
            title: 'Delete deck',
            iconColor: colors.error,
            titleColor: colors.error,
            onTap: () => _pick(context, DeckSheetAction.delete),
          ),
        ],
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
    this.iconColor,
    this.titleColor,
  });

  final AppColorTokens colors;
  final IconData icon;
  final String title;
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

    return GameFormDialog(
      title: 'Rename deck',
      submitLabel: 'Save',
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
          labelText: 'Deck name',
          hintText: 'e.g. Raffine Tempo',
          hintStyle: TextStyle(color: colors.textSecondary),
        ),
        style: TextStyle(color: colors.textPrimary),
      ),
    );
  }
}
