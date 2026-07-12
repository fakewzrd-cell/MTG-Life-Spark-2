import 'package:flutter/material.dart';

import '../../core/game/game_format.dart';
import '../../core/models/deck_style.dart';
import '../../ui/components/ui_button.dart';
import '../../ui/theme/app_color_tokens.dart';
import '../../ui/tokens/font_tokens.dart';
import '../../ui/tokens/layout_tokens.dart';
import '../game/widgets/game_modal_chrome.dart';
import 'deck_style_picker_sheet.dart';
import 'game_format_picker_sheet.dart';

/// Result of the new-deck builder (name + format + style).
typedef NewDeckSheetResult = ({
  String name,
  GameFormat format,
  String deckStyleId,
});

/// Bottom sheet for creating a deck — matches style/format picker chrome.
Future<NewDeckSheetResult?> showNewDeckSheet(BuildContext context) {
  return showGameBottomSheet<NewDeckSheetResult>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => const _NewDeckSheet(),
  );
}

class _NewDeckSheet extends StatefulWidget {
  const _NewDeckSheet();

  @override
  State<_NewDeckSheet> createState() => _NewDeckSheetState();
}

class _NewDeckSheetState extends State<_NewDeckSheet> {
  final _nameCtrl = TextEditingController();
  GameFormat _format = GameFormat.commander;
  DeckStyle? _style;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  bool get _canNext => _nameCtrl.text.trim().isNotEmpty && _style != null;

  void _submit() {
    if (!_canNext) return;
    final style = _style;
    if (style == null) return;
    Navigator.pop(
      context,
      (
        name: _nameCtrl.text.trim(),
        format: _format,
        deckStyleId: style.id,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTokens.of(context);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: GameSheetBody(
        scrollable: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            const GameSheetHeader(title: 'New deck'),
            SizedBox(height: LayoutTokens.gr2),
            Text(
              'Name your deck, pick a format and playstyle, then choose '
              'your commander or cover card.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colors.textSecondary,
                fontSize: FontTokens.sm,
                height: 1.45,
              ),
            ),
            SizedBox(height: LayoutTokens.gr3),
            TextField(
              controller: _nameCtrl,
              scrollPadding: const EdgeInsets.only(bottom: 120),
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'Deck name',
                hintText: 'e.g. Raffine Tempo',
                hintStyle: TextStyle(color: colors.textSecondary),
              ),
              style: TextStyle(color: colors.textPrimary),
            ),
            SizedBox(height: LayoutTokens.gr3),
            GameFormatPickerField(
              selected: _format,
              onPick: () async {
                final picked = await showGameFormatPickerSheet(
                  context,
                  selected: _format,
                );
                if (picked == null || !mounted) return;
                setState(() => _format = picked);
              },
            ),
            SizedBox(height: LayoutTokens.gr3),
            DeckStylePickerField(
              selected: _style,
              errorText: _style == null ? 'Required' : null,
              onPick: () async {
                final picked = await showDeckStylePickerSheet(
                  context,
                  selected: _style,
                );
                if (picked == null || !mounted) return;
                setState(() => _style = picked);
              },
            ),
            SizedBox(height: LayoutTokens.gr3),
            UiButton(
              label: 'Next',
              icon: const Icon(Icons.arrow_forward_rounded, size: 22),
              enabled: _canNext,
              onPressed: _canNext ? _submit : null,
            ),
          ],
        ),
      ),
    );
  }
}
