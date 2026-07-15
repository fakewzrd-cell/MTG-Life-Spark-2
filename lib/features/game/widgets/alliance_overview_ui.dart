import '../../../ui/tokens/color_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/game/alliance.dart';
import '../../../core/game/alliance_ui_events.dart';
import '../../../core/game/game_providers.dart';
import '../../../core/game/game_state.dart';
import '../../../core/game/player_game_state.dart';
import '../../../ui/tokens/font_tokens.dart';
import '../../../ui/tokens/layout_tokens.dart';
import '../../../ui/tokens/opacity_tokens.dart';
import '../../../ui/tokens/radius_tokens.dart';
import 'game_modal_chrome.dart';
import 'game_colors.dart';
import 'game_ui_tokens.dart';
import '../../../ui/components/ui_snack_bar.dart';

/// Shows alliance-related dialogs when [allianceUiEventProvider] updates.
void handleAllianceUiEvent(
  BuildContext context,
  WidgetRef ref,
  AllianceUiEvent? event,
) {
  if (event == null || !context.mounted) return;

  switch (event.kind) {
    case AllianceUiEventKind.inviteReceived:
      showAllianceInviteDialog(
        context: context,
        ref: ref,
        fromUsername: event.otherUsername ?? 'A player',
        durationLabel: event.durationLabel ?? allianceDurationLabel(
          AllianceDuration.manual,
        ),
      );
    case AllianceUiEventKind.allianceFormed:
      showAllianceFormedDialog(
        context: context,
        allyUsername: event.allyUsername ?? 'your ally',
        durationLabel: event.durationLabel,
      );
    case AllianceUiEventKind.allianceDeclined:
      showUiSnackBar(context, 'Secret alliance offer declined');
    case AllianceUiEventKind.allianceRevealed:
      showAllianceRevealedDialog(
        context: context,
        playerA: event.otherUsername ?? '?',
        playerB: event.allyUsername ?? '?',
      );
    case AllianceUiEventKind.allianceBroken:
      if (event.betrayal) {
        showAllianceBetrayalDialog(
          context: context,
          playerA: event.otherUsername ?? '?',
          playerB: event.allyUsername ?? '?',
        );
      } else {
        showUiSnackBar(context, 'Secret alliance ended');
      }
  }

  ref.read(gameProvider.notifier).clearAllianceUiEvent();
}

Future<void> showProposeAllianceSheet({
  required BuildContext context,
  required WidgetRef ref,
  required PlayerGameState target,
}) {
  AllianceDuration duration = AllianceDuration.endOfRound;
  AllianceDeliveryTiming timing = AllianceDeliveryTiming.now;
  var delaySeconds = 30;

  return showGameBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => StatefulBuilder(
      builder: (context, setState) {
        void sendWhisper() {
          final local = ref.read(gameProvider).localPlayer;
          if (local == null) return;
          ref.read(gameProvider.notifier).proposeAlliance(
                local.playerId,
                target.playerId,
                duration,
                timing: timing,
                delaySeconds: delaySeconds,
              );
          Navigator.pop(ctx);
          showUiSnackBar(
            context,
            timing == AllianceDeliveryTiming.now
                ? 'Whisper sent to ${target.username}'
                : 'Whisper scheduled for ${target.username}',
          );
        }

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.85,
            ),
            child: GameSheetBody(
              scrollable: true,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GameSheetHeader(
                    title: 'Secret alliance',
                    subtitle:
                        'Invite ${target.username} — only they will know.',
                  ),
                  SizedBox(height: LayoutTokens.gr2),
                  Text(
                    'Duration',
                    style: TextStyle(
                      color: ColorTokens.textSecondary,
                      fontSize: FontTokens.label,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: LayoutTokens.gr1),
                  ...AllianceDuration.values.map((d) {
                    final selected = duration == d;
                    return Padding(
                      padding: EdgeInsets.only(bottom: LayoutTokens.gr1),
                      child: ListTile(
                        tileColor: selected
                            ? ColorTokens.emphasis.withValues(alpha: 0.12)
                            : ColorTokens.backgroundSecondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: RadiusTokens.radiusControlSm,
                        ),
                        title: Text(allianceDurationLabel(d)),
                        trailing: selected
                            ? Icon(
                                Icons.check_circle,
                                color: ColorTokens.emphasis,
                              )
                            : null,
                        onTap: () => setState(() => duration = d),
                      ),
                    );
                  }),
                  SizedBox(height: LayoutTokens.gr2),
                  Text(
                    'When to deliver',
                    style: TextStyle(
                      color: ColorTokens.textSecondary,
                      fontSize: FontTokens.label,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: LayoutTokens.gr1),
                  Wrap(
                    spacing: LayoutTokens.gr1,
                    runSpacing: LayoutTokens.gr1,
                    children: AllianceDeliveryTiming.values.map((t) {
                      final selected = timing == t;
                      return ChoiceChip(
                        label: Text(
                          allianceDeliveryLabel(
                            t,
                            seconds: delaySeconds,
                          ),
                        ),
                        selected: selected,
                        onSelected: (_) => setState(() => timing = t),
                      );
                    }).toList(),
                  ),
                  if (timing == AllianceDeliveryTiming.delaySeconds) ...[
                    SizedBox(height: LayoutTokens.gr2),
                    Row(
                      children: [
                        Expanded(
                          child: Slider(
                            value: delaySeconds.toDouble(),
                            min: 10,
                            max: 120,
                            divisions: 11,
                            label: '${delaySeconds}s',
                            onChanged: (v) =>
                                setState(() => delaySeconds = v.round()),
                          ),
                        ),
                        Text('${delaySeconds}s'),
                      ],
                    ),
                  ],
                  SizedBox(height: LayoutTokens.gr2),
                  FilledButton(
                    style: GameUiTokens.sheetPrimaryButton(
                      context.gameColors.emphasis,
                    ),
                    onPressed: sendWhisper,
                    child: Text('Send'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}

Future<void> showAllianceInviteDialog({
  required BuildContext context,
  required WidgetRef ref,
  required String fromUsername,
  required String durationLabel,
}) async {
  final accepted = await showGameChoiceDialog(
    context: context,
    barrierDismissible: false,
    title: 'Secret offer',
    content: Text(
      '$fromUsername proposes a secret alliance.\n\n'
      'Duration: $durationLabel\n\n'
      'Only you can see this.',
      style: GameModalChrome.dialogBodyStyle(context),
    ),
    primaryLabel: 'Accept',
    secondaryLabel: 'Decline',
  );
  if (!context.mounted) return;
  final localId = ref.read(gameProvider).localPlayerId;
  ref.read(gameProvider.notifier).respondToAlliance(
        localId,
        accepted == true,
      );
}

Future<void> showAllianceFormedDialog({
  required BuildContext context,
  required String allyUsername,
  String? durationLabel,
}) async {
  await showGameConfirmDialog(
    context: context,
    title: 'Alliance formed',
    message: 'You and $allyUsername are now secretly allied'
        '${durationLabel != null ? ' ($durationLabel)' : ''}.\n\n'
        'The table does not know — unless you reveal or betray.',
    confirmLabel: 'Understood',
  );
}

Future<void> showAllianceRevealedDialog({
  required BuildContext context,
  required String playerA,
  required String playerB,
}) async {
  await showGameConfirmDialog(
    context: context,
    title: 'Alliance revealed',
    message:
        '$playerA and $playerB have revealed their secret alliance to the table.',
    confirmLabel: 'OK',
  );
}

Future<void> showAllianceBetrayalDialog({
  required BuildContext context,
  required String playerA,
  required String playerB,
}) async {
  await showGameConfirmDialog(
    context: context,
    title: 'Betrayal!',
    message:
        'The secret alliance between $playerA and $playerB has been broken '
        'by betrayal.',
    confirmLabel: 'OK',
    destructive: true,
  );
}

class OverviewPlayerMarkerBadges extends StatelessWidget {
  const OverviewPlayerMarkerBadges({
    super.key,
    required this.game,
    required this.playerId,
  });

  final GameState game;
  final String playerId;

  @override
  Widget build(BuildContext context) {
    final badges = <Widget>[];
    final localId = game.localPlayerId;
    final alliance = game.allianceFor(playerId);
    if (alliance != null && alliance.isRevealed) {
      badges.add(_chip('Allied'));
    } else if (alliance != null && alliance.involves(localId)) {
      badges.add(_chip('Secret ally'));
    }

    if (badges.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(top: LayoutTokens.gr0 + 1),
      child: Wrap(
        spacing: LayoutTokens.gr0 + 2,
        runSpacing: LayoutTokens.gr0,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: badges,
      ),
    );
  }

  Widget _chip(String label) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: LayoutTokens.gr0 + 2,
        vertical: LayoutTokens.gr0 - 1,
      ),
      decoration: BoxDecoration(
        color: ColorTokens.emphasis.withValues(alpha: OpacityTokens.subtle),
        borderRadius: RadiusTokens.radiusControlSm,
        border: Border.all(
          color: ColorTokens.emphasis.withValues(alpha: OpacityTokens.soft),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: ColorTokens.emphasis,
          fontSize: FontTokens.hudXs,
          fontWeight: FontWeight.w700,
          height: 1.1,
        ),
      ),
    );
  }
}

String? pendingAllianceLabel(GameState game, String playerId) {
  if (playerId != game.localPlayerId) return null;
  final scheduled =
      game.scheduledProposalsFrom(playerId).where((p) => !p.delivered);
  if (scheduled.isNotEmpty) {
    final target = game.playerById(scheduled.first.toId)?.username ?? '?';
    return 'Whisper pending → $target';
  }
  final outgoing = game.pendingProposals.where((p) => p.fromId == playerId);
  if (outgoing.isNotEmpty) {
    final target = game.playerById(outgoing.first.toId)?.username ?? '?';
    return 'Awaiting $target';
  }
  return null;
}
