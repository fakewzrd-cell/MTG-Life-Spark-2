import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/game/game_providers.dart';
import '../../../core/game/player_game_state.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/components/ui_snack_bar.dart';
import '../../../ui/components/ui_text_field.dart';
import '../../../ui/tokens/font_tokens.dart';
import '../../../ui/tokens/layout_tokens.dart';
import '../../../ui/tokens/radius_tokens.dart';
import 'game_colors.dart';
import 'game_modal_chrome.dart';

/// Preset whispers — one tap to send.
List<String> whisperChipLabels(AppLocalizations l10n) => [
      l10n.whisperPresetTeamUp,
      l10n.whisperPresetDontAttack,
      l10n.whisperPresetHaveRemoval,
      l10n.whisperPresetAllGood,
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
    final l10n = AppLocalizations.of(context);
    final ok = ref.read(gameProvider.notifier).sendPlayerWhisper(
          widget.target.playerId,
          text,
        );
    if (!context.mounted) return;
    if (ok) {
      Navigator.pop(context);
      showUiSnackBar(context, l10n.whisperSentSnack(widget.target.username));
    } else {
      showUiSnackBar(
        context,
        l10n.whisperSendFailed,
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    final l10n = AppLocalizations.of(context);
    final presets = whisperChipLabels(l10n);
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
            l10n.whisperSheetTitle(widget.target.username),
            style: GameModalChrome.sheetTitleStyle(context),
          ),
          SizedBox(height: LayoutTokens.gr1),
          Text(
            l10n.whisperSheetSubtitle,
            style: GameModalChrome.dialogBodyStyle(context),
          ),
          SizedBox(height: LayoutTokens.gr3),
          Wrap(
            spacing: LayoutTokens.gr1,
            runSpacing: LayoutTokens.gr1,
            children: [
              for (final label in presets)
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
            labelText: l10n.whisperCustomLabel,
            hintText: l10n.whisperCustomHint,
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
            child: Text(l10n.whisperSend),
          ),
        ],
      ),
    );
  }
}
