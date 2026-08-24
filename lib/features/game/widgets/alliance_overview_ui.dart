import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/game/alliance.dart';
import '../../../core/game/alliance_ui_events.dart';
import '../../../core/game/game_providers.dart';
import '../../../core/game/game_state.dart';
import '../../../core/game/player_game_state.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/tokens/font_tokens.dart';
import '../../../ui/tokens/layout_tokens.dart';
import '../../../ui/tokens/opacity_tokens.dart';
import '../../../ui/tokens/radius_tokens.dart';
import 'game_modal_chrome.dart';
import '../../../ui/theme/app_color_tokens.dart';
import 'game_colors.dart';
import 'game_ui_tokens.dart';
import '../../../ui/components/ui_snack_bar.dart';

String _localizedDurationLabel(AppLocalizations l10n, AllianceDuration duration) {
  switch (duration) {
    case AllianceDuration.endOfTurn:
      return l10n.allianceDurationEndOfTurn;
    case AllianceDuration.endOfRound:
      return l10n.allianceDurationEndOfRound;
    case AllianceDuration.manual:
      return l10n.allianceDurationUntilBroken;
  }
}

String _localizedDeliveryLabel(
  AppLocalizations l10n,
  AllianceDeliveryTiming timing, {
  int? seconds,
}) {
  switch (timing) {
    case AllianceDeliveryTiming.now:
      return l10n.allianceDeliverNow;
    case AllianceDeliveryTiming.delaySeconds:
      return l10n.allianceDeliverInSeconds(seconds ?? 30);
    case AllianceDeliveryTiming.endOfProposerTurn:
      return l10n.allianceDeliverEndOfYourTurn;
    case AllianceDeliveryTiming.startOfNextRound:
      return l10n.allianceDeliverNextRound;
  }
}

/// Maps English duration labels from session events to the active locale.
String _localizeStoredDurationLabel(AppLocalizations l10n, String? label) {
  if (label == null || label.isEmpty) {
    return l10n.allianceDurationUntilBroken;
  }
  if (label == allianceDurationLabel(AllianceDuration.endOfTurn)) {
    return l10n.allianceDurationEndOfTurn;
  }
  if (label == allianceDurationLabel(AllianceDuration.endOfRound)) {
    return l10n.allianceDurationEndOfRound;
  }
  if (label == allianceDurationLabel(AllianceDuration.manual)) {
    return l10n.allianceDurationUntilBroken;
  }
  return label;
}

/// Shows alliance-related dialogs when [allianceUiEventProvider] updates.
void handleAllianceUiEvent(
  BuildContext context,
  WidgetRef ref,
  AllianceUiEvent? event,
) {
  if (event == null || !context.mounted) return;
  final l10n = AppLocalizations.of(context);

  switch (event.kind) {
    case AllianceUiEventKind.inviteReceived:
      showAllianceInviteDialog(
        context: context,
        ref: ref,
        fromUsername: event.otherUsername ?? l10n.allianceAPlayer,
        durationLabel: _localizeStoredDurationLabel(
          l10n,
          event.durationLabel ??
              allianceDurationLabel(AllianceDuration.manual),
        ),
      );
    case AllianceUiEventKind.allianceFormed:
      showAllianceFormedDialog(
        context: context,
        allyUsername: event.allyUsername ?? l10n.allianceYourAllyFallback,
        durationLabel: event.durationLabel == null
            ? null
            : _localizeStoredDurationLabel(l10n, event.durationLabel),
      );
    case AllianceUiEventKind.allianceDeclined:
      showUiSnackBar(context, l10n.allianceOfferDeclined);
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
        showUiSnackBar(context, l10n.allianceEnded);
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
        final colors = context.gameColors;
        final l10n = AppLocalizations.of(context);
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
                ? l10n.allianceWhisperSent(target.username)
                : l10n.allianceWhisperScheduled(target.username),
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
                    title: l10n.allianceProposeTitle,
                    subtitle: l10n.allianceProposeSubtitle(target.username),
                  ),
                  SizedBox(height: LayoutTokens.gr2),
                  Text(
                    l10n.allianceDurationSection,
                    style: TextStyle(
                      color: colors.textSecondary,
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
                            ? colors.emphasis.withValues(alpha: OpacityTokens.subtle)
                            : colors.backgroundSecondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: RadiusTokens.radiusControlSm,
                        ),
                        title: Text(_localizedDurationLabel(l10n, d)),
                        trailing: selected
                            ? Icon(
                                Icons.check_circle,
                                color: colors.emphasis,
                              )
                            : null,
                        onTap: () => setState(() => duration = d),
                      ),
                    );
                  }),
                  SizedBox(height: LayoutTokens.gr2),
                  Text(
                    l10n.allianceWhenToDeliver,
                    style: TextStyle(
                      color: colors.textSecondary,
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
                          _localizedDeliveryLabel(
                            l10n,
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
                            label: l10n.allianceSecondsShort(delaySeconds),
                            onChanged: (v) =>
                                setState(() => delaySeconds = v.round()),
                          ),
                        ),
                        Text(l10n.allianceSecondsShort(delaySeconds)),
                      ],
                    ),
                  ],
                  SizedBox(height: LayoutTokens.gr2),
                  FilledButton(
                    style: GameUiTokens.sheetPrimaryButton(
                      context.gameColors.emphasis,
                    ),
                    onPressed: sendWhisper,
                    child: Text(l10n.allianceSend),
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
  final l10n = AppLocalizations.of(context);
  final accepted = await showGameChoiceDialog(
    context: context,
    barrierDismissible: false,
    title: l10n.allianceInviteTitle,
    content: Text(
      l10n.allianceInviteBody(fromUsername, durationLabel),
      style: GameModalChrome.dialogBodyStyle(context),
    ),
    primaryLabel: l10n.allianceAccept,
    secondaryLabel: l10n.allianceDecline,
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
  final l10n = AppLocalizations.of(context);
  await showGameConfirmDialog(
    context: context,
    title: l10n.allianceFormedTitle,
    message: durationLabel != null
        ? l10n.allianceFormedBody(allyUsername, durationLabel)
        : l10n.allianceFormedBodyNoDuration(allyUsername),
    confirmLabel: l10n.allianceUnderstood,
  );
}

Future<void> showAllianceRevealedDialog({
  required BuildContext context,
  required String playerA,
  required String playerB,
}) async {
  final l10n = AppLocalizations.of(context);
  await showGameConfirmDialog(
    context: context,
    title: l10n.allianceRevealedTitle,
    message: l10n.allianceRevealedBody(playerA, playerB),
    confirmLabel: l10n.allianceOk,
  );
}

Future<void> showAllianceBetrayalDialog({
  required BuildContext context,
  required String playerA,
  required String playerB,
}) async {
  final l10n = AppLocalizations.of(context);
  await showGameConfirmDialog(
    context: context,
    title: l10n.allianceBetrayalTitle,
    message: l10n.allianceBetrayalBody(playerA, playerB),
    confirmLabel: l10n.allianceOk,
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
    final colors = context.gameColors;
    final l10n = AppLocalizations.of(context);
    final badges = <Widget>[];
    final localId = game.localPlayerId;
    final alliance = game.allianceFor(playerId);
    if (alliance != null && alliance.isRevealed) {
      badges.add(_chip(colors, l10n.allianceBadgeAllied));
    } else if (alliance != null && alliance.involves(localId)) {
      badges.add(_chip(colors, l10n.allianceBadgeSecretAlly));
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

  Widget _chip(AppColorTokens colors, String label) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: LayoutTokens.gr0 + 2,
        vertical: LayoutTokens.gr0 - 1,
      ),
      decoration: BoxDecoration(
        color: colors.emphasis.withValues(alpha: OpacityTokens.subtle),
        borderRadius: RadiusTokens.radiusControlSm,
        border: Border.all(
          color: colors.emphasis.withValues(alpha: OpacityTokens.soft),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: colors.emphasis,
          fontSize: FontTokens.hudXs,
          fontWeight: FontWeight.w700,
          height: 1.1,
        ),
      ),
    );
  }
}

String? pendingAllianceLabel(
  GameState game,
  String playerId,
  AppLocalizations l10n,
) {
  if (playerId != game.localPlayerId) return null;
  final scheduled =
      game.scheduledProposalsFrom(playerId).where((p) => !p.delivered);
  if (scheduled.isNotEmpty) {
    final target = game.playerById(scheduled.first.toId)?.username ?? '?';
    return l10n.allianceWhisperPending(target);
  }
  final outgoing = game.pendingProposals.where((p) => p.fromId == playerId);
  if (outgoing.isNotEmpty) {
    final target = game.playerById(outgoing.first.toId)?.username ?? '?';
    return l10n.allianceAwaiting(target);
  }
  return null;
}
