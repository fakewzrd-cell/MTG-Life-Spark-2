import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/game/game_providers.dart';
import '../../../core/game/player_game_state.dart';
import '../../../ui/components/ui_snack_bar.dart';
import '../../../ui/components/ui_text_field.dart';
import '../../../ui/tokens/font_tokens.dart';
import '../../../ui/tokens/layout_tokens.dart';
import '../../../ui/tokens/radius_tokens.dart';
import 'game_colors.dart';
import 'game_modal_chrome.dart';

/// Preset whispers — one tap to send.
const kWhisperChipLabels = [
  'Team up?',
  "Don't attack me",
  'I have removal',
  'All good',
];

const _kWhisperMaxLength = 80;

Future<void> showPlayerWhisperSheet({
  required BuildContext context,
  required WidgetRef ref,
  required PlayerGameState target,
}) {
  return showGameBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => _PlayerWhisperSheet(target: target),
  );
}

class _PlayerWhisperSheet extends ConsumerStatefulWidget {
  const _PlayerWhisperSheet({required this.target});

  final PlayerGameState target;

  @override
  ConsumerState<_PlayerWhisperSheet> createState() =>
      _PlayerWhisperSheetState();
}

class _PlayerWhisperSheetState extends ConsumerState<_PlayerWhisperSheet> {
  final _customController = TextEditingController();

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  void _send(String text) {
    final ok = ref.read(gameProvider.notifier).sendPlayerWhisper(
          widget.target.playerId,
          text,
        );
    if (!context.mounted) return;
    if (ok) {
      Navigator.pop(context);
      showUiSnackBar(context, 'Whisper sent to ${widget.target.username}');
    } else {
      showUiSnackBar(
        context,
        'Could not send — wait a moment or check your connection.',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    return Padding(
      padding: EdgeInsets.only(
        left: GameModalChrome.horizontalInset(context),
        right: GameModalChrome.horizontalInset(context),
        bottom: MediaQuery.viewInsetsOf(context).bottom + LayoutTokens.gr4,
        top: LayoutTokens.gr2,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Whisper to ${widget.target.username}',
            style: GameModalChrome.sheetTitleStyle(context),
          ),
          SizedBox(height: LayoutTokens.gr1),
          Text(
            'Only they see this — it fades away. Not saved to match history.',
            style: GameModalChrome.dialogBodyStyle(context),
          ),
          SizedBox(height: LayoutTokens.gr3),
          Wrap(
            spacing: LayoutTokens.gr1,
            runSpacing: LayoutTokens.gr1,
            children: [
              for (final label in kWhisperChipLabels)
                ActionChip(
                  label: Text(
                    label,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: FontTokens.body,
                    ),
                  ),
                  backgroundColor: colors.surface,
                  side: BorderSide(color: colors.borderSubtle),
                  shape: RoundedRectangleBorder(
                    borderRadius: RadiusTokens.radiusSm,
                  ),
                  onPressed: () => _send(label),
                ),
            ],
          ),
          SizedBox(height: LayoutTokens.gr3),
          UiTextField(
            controller: _customController,
            labelText: 'Custom message',
            hintText: 'Short note…',
            maxLength: _kWhisperMaxLength,
            onSubmitted: (v) {
              if (v.trim().isNotEmpty) _send(v);
            },
          ),
          SizedBox(height: LayoutTokens.gr3),
          FilledButton(
            onPressed: () {
              final text = _customController.text.trim();
              if (text.isEmpty) return;
              _send(text);
            },
            style: FilledButton.styleFrom(
              backgroundColor: colors.primaryAccent,
              foregroundColor: colors.onAccent,
              minimumSize: Size.fromHeight(LayoutTokens.minTapTarget),
            ),
            child: const Text('Send whisper'),
          ),
        ],
      ),
    );
  }
}
