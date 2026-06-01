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

/// Centered popup for creating a deck — matches deck options / rename dialogs.
Future<NewDeckSheetResult?> showNewDeckSheet(BuildContext context) {
  return showDialog<NewDeckSheetResult>(
    context: context,
    builder: (ctx) => const _NewDeckDialog(),
  );
}

class _NewDeckDialog extends StatefulWidget {
  const _NewDeckDialog();

  @override
  State<_NewDeckDialog> createState() => _NewDeckDialogState();
}

class _NewDeckDialogState extends State<_NewDeckDialog> {
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
    final hPad = LayoutTokens.gr2;
    // Dialog route already applies [MediaQuery.viewInsets] — do not pad again.
    final maxH = MediaQuery.sizeOf(context).height * 0.75;

    return AlertDialog(
      backgroundColor: colors.surface,
      insetPadding: EdgeInsets.symmetric(
        horizontal: LayoutTokens.gr4,
        vertical: LayoutTokens.gr4,
      ),
      titlePadding: EdgeInsets.fromLTRB(hPad, LayoutTokens.gr2, hPad, 0),
      contentPadding: EdgeInsets.fromLTRB(
        hPad,
        LayoutTokens.gr2,
        hPad,
        LayoutTokens.gr2,
      ),
      actionsPadding: EdgeInsets.fromLTRB(
        hPad,
        0,
        hPad,
        LayoutTokens.gr3,
      ),
      title: GameDialogTitleRow(
        title: 'New deck',
        onClose: () => Navigator.pop(context),
      ),
      content: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxH),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
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
            ],
          ),
        ),
      ),
      actions: [
        UiButton(
          label: 'Next',
          icon: const Icon(Icons.arrow_forward_rounded, size: 22),
          enabled: _canNext,
          onPressed: _canNext ? _submit : null,
        ),
      ],
    );
  }
}
