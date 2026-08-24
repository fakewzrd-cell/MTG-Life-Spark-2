import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/game/game_format.dart';
import '../../core/game/lobby_state.dart';
import '../../core/models/match_record.dart';
import '../../core/models/player_slot.dart';
import '../../core/network/local_ip.dart';
import '../../core/network/session_join_uri.dart';
import '../../core/network/session_providers.dart';
import '../../core/network/ws_host_service.dart';
import '../../core/persistence/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/utils/app_router.dart';
import '../../shared/widgets/session_leave_dialog.dart';
import '../../ui/components/ui_app_bar.dart';
import '../../ui/components/ui_button.dart';
import '../../ui/theme/app_color_tokens.dart';
import '../../ui/tokens/font_tokens.dart';
import '../../ui/tokens/layout_tokens.dart';
import '../../ui/tokens/opacity_tokens.dart';
import '../../ui/tokens/radius_tokens.dart';
import '../../ui/tokens/typography_tokens.dart';
import '../game/widgets/game_modal_chrome.dart';
import 'deck_picker_sheet.dart';
import 'lobby_slot_widgets.dart';

enum _QrHostLoadState { loading, ready, unavailable, error }

class LobbyScreen extends ConsumerStatefulWidget {
  const LobbyScreen({super.key});

  @override
  ConsumerState<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends ConsumerState<LobbyScreen> {
  String? _qrData;
  _QrHostLoadState _qrLoadState = _QrHostLoadState.loading;
  String? _qrErrorMessage;
  /// True after we successfully became host — used to detect external leave.
  var _hadHostSession = false;
  var _leaveInProgress = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _prepareHostQr());
  }

  Future<void> _prepareHostQr() async {
    if (!mounted) return;

    if (kIsWeb) {
      ref.read(lobbyProvider.notifier).initAsHost();
      setState(() {
        _qrLoadState = _QrHostLoadState.unavailable;
        _qrData = null;
        _qrErrorMessage = AppLocalizations.of(context).hostNeedsMobileApp;
      });
      return;
    }

    setState(() {
      _qrLoadState = _QrHostLoadState.loading;
      _qrData = null;
      _qrErrorMessage = null;
    });

    final started = await startHostSession(ref);
    if (!mounted) return;
    if (!started) {
      final hasProfile = ref.read(profileRepositoryProvider).hasProfile;
      final l10n = AppLocalizations.of(context);
      setState(() {
        if (kIsWeb) {
          _qrLoadState = _QrHostLoadState.unavailable;
          _qrErrorMessage = l10n.hostNeedsMobileApp;
        } else if (!hasProfile) {
          _qrLoadState = _QrHostLoadState.error;
          _qrErrorMessage = l10n.hostCreateProfileFirst;
        } else {
          _qrLoadState = _QrHostLoadState.error;
          _qrErrorMessage = l10n.hostCouldNotStartServer;
        }
      });
      return;
    }

    _hadHostSession = true;
    ref.read(lobbyProvider.notifier).initAsHost();

    const maxAttempts = 12;
    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      if (!mounted) return;
      final host = ref.read(sessionServiceProvider);
      if (host is! WsHostService) {
        setState(() {
          _qrLoadState = _QrHostLoadState.error;
          _qrErrorMessage =
              AppLocalizations.of(context).hostSessionDidNotStart;
        });
        return;
      }
      if (!host.isReady) {
        if (attempt == maxAttempts - 1) {
          setState(() {
            _qrLoadState = _QrHostLoadState.unavailable;
            _qrErrorMessage = null;
          });
        } else {
          await Future.delayed(const Duration(milliseconds: 250));
        }
        continue;
      }

      final ip = await getLocalIpAddress();
      if (!mounted) return;
      if (ip != null && host.port > 0) {
        setState(() {
          _qrLoadState = _QrHostLoadState.ready;
          _qrData = SessionJoinUri.buildQrPayload(
            hostIp: ip,
            port: host.port,
            token: host.joinToken,
          );
        });
        return;
      }

      if (attempt == maxAttempts - 1) {
        setState(() {
          _qrLoadState = _QrHostLoadState.unavailable;
          _qrErrorMessage = AppLocalizations.of(context).hostNeedWifiRetry;
        });
        return;
      }
      await Future.delayed(const Duration(milliseconds: 400));
    }
  }

  Future<void> _leaveHostFlow() async {
    if (_leaveInProgress) return;
    _leaveInProgress = true;
    try {
      final left = await leaveActiveSessionIfConfirmed(context, ref);
      if (left && mounted) context.pop();
    } finally {
      _leaveInProgress = false;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If the session was torn down while this screen stayed mounted (shell
    // tab switch), bounce back to the Host/Join hub instead of a dead lobby.
    ref.listen<SessionRole>(sessionRoleProvider, (previous, next) {
      if (!_hadHostSession) return;
      if (_leaveInProgress) return;
      if (next != SessionRole.none) return;
      if (!context.mounted) return;
      context.go(AppRoutes.lobby);
    });

    final lobby = ref.watch(lobbyProvider);
    final colors = AppColorTokens.of(context);
    final l10n = AppLocalizations.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) unawaited(_leaveHostFlow());
      },
      child: Scaffold(
        backgroundColor: colors.backgroundPrimary,
        appBar: UiAppBar(
          title: l10n.hostLobbyTitle,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: l10n.hostLeaveLobbyTooltip,
            onPressed: () => unawaited(_leaveHostFlow()),
          ),
        ),
        body: SafeArea(
        bottom: false,
        child: Builder(
          builder: (context) {
            return ListView(
              padding: LayoutTokens.shellListPadding(context),
              children: [
          _QrHeader(
            qrData: _qrData,
            loadState: _qrLoadState,
            errorMessage: _qrErrorMessage,
            onRetry: _prepareHostQr,
            playerCount: lobby.players.length,
            maxPlayers: lobby.config.maxPlayers,
          ),
          SizedBox(height: LayoutTokens.shellSectionGap),
          ...lobby.players.map((slot) => _PlayerSlotCard(slot: slot)),
          if (lobby.players.length < lobby.config.maxPlayers)
            _EmptySlotCard(
              remaining: lobby.config.maxPlayers - lobby.players.length,
            ),
          SizedBox(height: LayoutTokens.shellSectionGap),
          const _MatchLabelSection(),
          SizedBox(height: LayoutTokens.shellSectionGap),
          _ConfigSection(config: lobby.config),
          SizedBox(height: LayoutTokens.shellSectionGap),
          _StartGameButton(
            canStart: lobby.canStart,
            hint: lobby.players.isEmpty
                ? l10n.hostNeedOnePlayer
                : lobby.players.any((p) => !p.isReady)
                    ? l10n.hostEveryoneMustBeReady
                    : l10n.hostStartGame,
          ),
              ],
            );
          },
        ),
        ),
      ),
    );
  }
}

// ── Optional match label ──────────────────────────────────────────────────

class _MatchLabelSection extends ConsumerStatefulWidget {
  const _MatchLabelSection();

  @override
  ConsumerState<_MatchLabelSection> createState() => _MatchLabelSectionState();
}

class _MatchLabelSectionState extends ConsumerState<_MatchLabelSection> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: ref.read(lobbyProvider).matchLabel ?? '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _applyLabel(String? value) {
    ref.read(lobbyProvider.notifier).setMatchLabel(value);
    final normalized = MatchRecord.normalizeLabel(value) ?? '';
    if (_controller.text != normalized) {
      _controller.value = TextEditingValue(
        text: normalized,
        selection: TextSelection.collapsed(offset: normalized.length),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTokens.of(context);
    final l10n = AppLocalizations.of(context);
    final compact = MediaQuery.sizeOf(context).width < 360;
    final recentLabels =
        ref.watch(matchRepositoryProvider).recentLabels(limit: 6);
    final current = ref.watch(lobbyProvider).matchLabel;
    // Keep the field in sync if lobby state changes outside this TextField
    // (e.g. host QR Retry re-init preserving or clearing the label).
    final currentText = current ?? '';
    if (_controller.text != currentText && !_controller.value.isComposingRangeValid) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _controller.text == currentText) return;
        _controller.value = TextEditingValue(
          text: currentText,
          selection: TextSelection.collapsed(offset: currentText.length),
        );
      });
    }

    return Container(
      padding: EdgeInsets.all(compact ? LayoutTokens.gr3 : LayoutTokens.gr4),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: RadiusTokens.radiusMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.hostMatchLabel,
            style: TypographyTokens.sectionTitle(colors.textPrimary),
          ),
          SizedBox(height: LayoutTokens.gr1),
          Text(
            l10n.hostMatchLabelHelp,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: FontTokens.caption,
            ),
          ),
          SizedBox(height: LayoutTokens.gr2),
          TextField(
            controller: _controller,
            maxLength: 40,
            textInputAction: TextInputAction.done,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: FontTokens.body,
            ),
            decoration: _lobbyDropdownDecoration(context).copyWith(
              hintText: l10n.hostMatchLabelHint,
              hintStyle: TextStyle(color: colors.textSecondary),
              counterText: '',
            ),
            onChanged: _applyLabel,
            onSubmitted: _applyLabel,
          ),
          if (recentLabels.isNotEmpty) ...[
            SizedBox(height: LayoutTokens.gr2),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final label in recentLabels)
                  ActionChip(
                    label: Text(
                      label,
                      style: TextStyle(
                        color: label == current
                            ? colors.primaryAccent
                            : colors.textPrimary,
                        fontSize: FontTokens.caption,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    backgroundColor: label == current
                        ? colors.primaryAccent
                            .withValues(alpha: OpacityTokens.soft)
                        : colors.backgroundSecondary,
                    side: BorderSide.none,
                    onPressed: () => _applyLabel(label),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ── QR code header ────────────────────────────────────────────────────────

class _QrHeader extends StatelessWidget {
  final String? qrData;
  final _QrHostLoadState loadState;
  final String? errorMessage;
  final VoidCallback onRetry;
  final int playerCount;
  final int maxPlayers;
  const _QrHeader({
    required this.qrData,
    required this.loadState,
    required this.errorMessage,
    required this.onRetry,
    required this.playerCount,
    required this.maxPlayers,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTokens.of(context);
    final l10n = AppLocalizations.of(context);
    final w = MediaQuery.sizeOf(context).width;
    final compact = w < 360;
    final qrSize = compact ? 140.0 : 160.0;
    final pad = compact ? LayoutTokens.gr3 : LayoutTokens.gr4;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: RadiusTokens.radiusMd,
      ),
      padding: EdgeInsets.symmetric(vertical: pad, horizontal: pad),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.qr_code, color: colors.primaryAccent, size: compact ? 16 : 18),
              SizedBox(width: LayoutTokens.gr1),
              Flexible(
                child: Text(
                  l10n.hostPlayersScanQr(playerCount, maxPlayers),
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: compact ? FontTokens.caption : FontTokens.hudSm,
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          SizedBox(height: LayoutTokens.gr3),
          if (loadState == _QrHostLoadState.unavailable)
            SizedBox(
              height: qrSize,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: LayoutTokens.gr2),
                child: Text(
                  errorMessage ?? l10n.hostNeedsMobileOrDev,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: compact ? FontTokens.caption : FontTokens.hudSm,
                    height: 1.4,
                  ),
                ),
              ),
            )
          else if (loadState == _QrHostLoadState.error)
            SizedBox(
              height: qrSize,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: LayoutTokens.gr2),
                child: Center(
                  child: Text(
                    errorMessage ?? l10n.hostCouldNotShowQr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: compact ? FontTokens.caption : FontTokens.hudSm,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            )
          else if (loadState == _QrHostLoadState.loading)
            SizedBox(
              height: qrSize,
              child: Center(
                child: CircularProgressIndicator(color: colors.primaryAccent),
              ),
            )
          else if (loadState == _QrHostLoadState.ready && qrData != null)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: RadiusTokens.radiusSm,
              ),
              padding: EdgeInsets.all(compact ? 10 : 12),
              child: QrImageView(
                data: qrData!,
                version: QrVersions.auto,
                size: qrSize,
                backgroundColor: Colors.white,
              ),
            )
          else
            SizedBox(height: qrSize),
          if (loadState == _QrHostLoadState.ready && qrData != null) ...[
            Padding(
              padding: EdgeInsets.only(top: LayoutTokens.gr1),
              child: Text(
                qrData!.replaceFirst('lifespark://', ''),
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: compact ? 9 : 10,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                textAlign: TextAlign.center,
              ),
            ),
          ] else if (loadState == _QrHostLoadState.unavailable ||
              loadState == _QrHostLoadState.error) ...[
            Padding(
              padding: EdgeInsets.only(top: LayoutTokens.gr2),
              child: TextButton(
                onPressed: onRetry,
                child: Text(l10n.hostRetry),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Player slot card ──────────────────────────────────────────────────────

class _PlayerSlotCard extends ConsumerWidget {
  final PlayerSlot slot;
  const _PlayerSlotCard({required this.slot});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColorTokens.of(context);
    final l10n = AppLocalizations.of(context);
    final isLocalHost = ref.watch(
      profileRepositoryProvider.select((r) => r.getProfile()?.playerId),
    );
    final isMe = slot.playerId == isLocalHost;
    final lobbyFormat = ref.watch(lobbyProvider).config.format;
    final isCommanderLobby = lobbyFormat.isCommanderStyle;
    final linkedDeck = isMe && slot.selectedDeckId != null
        ? ref.read(deckRepositoryProvider).getById(slot.selectedDeckId!)
        : null;

    final borderColor = isMe
        ? colors.primaryAccent
        : slot.playerColor.withValues(alpha: 0.25);

    // Resolved once so the displayed text and its color never disagree.
    final resolvedCommanderName = isCommanderLobby
        ? slot.commanderName
        : linkedDeck?.commanderName ?? slot.commanderName;

    final compact = MediaQuery.sizeOf(context).width < 360;

    return LobbySlotCardShell(
      emphasized: isMe,
      emphasizeColor: borderColor,
      compact: compact,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LobbySlotAvatar(
                slot: slot,
                size: compact
                    ? LayoutTokens.minTapTarget
                    : LayoutTokens.gr6 + LayoutTokens.gr0,
              ),
              SizedBox(width: LayoutTokens.gr2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LobbyPlayerIdentityRow(
                      username: slot.username,
                      playerColor: slot.playerColor,
                    ),
                    SizedBox(height: LayoutTokens.gr1),
                    Text(
                      resolvedCommanderName ??
                          (isCommanderLobby
                              ? l10n.hostNoCommanderSelected
                              : l10n.hostNoDeckSelected),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: resolvedCommanderName != null
                            ? colors.textSecondary
                            : colors.primaryAccent,
                        fontSize: FontTokens.caption,
                      ),
                    ),
                    if (isCommanderLobby &&
                        slot.hasPartner &&
                        slot.partnerCommanderName != null)
                      Text(
                        '+ ${slot.partnerCommanderName}',
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: FontTokens.sm,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (isMe && slot.selectedDeckId != null) ...[
                      SizedBox(height: LayoutTokens.gr0),
                      Text(
                        linkedDeck != null
                            ? l10n.hostTrackingDeck(linkedDeck.displayName)
                            : l10n.hostDeckListChanged,
                        style: TextStyle(
                          color: colors.primaryAccent,
                          fontSize: FontTokens.hudXs,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (isMe)
                _SlotReadyButton(slot: slot)
              else
                LobbyReadyBadge(isReady: slot.isReady),
            ],
          ),
          if (isMe) ...[
            SizedBox(height: LayoutTokens.gr2),
            _SlotCommanderControls(
              slot: slot,
              isCommanderLobby: isCommanderLobby,
            ),
          ],
        ],
      ),
    );
  }
}

/// Deck / Commander actions for the local player's slot (full-width row).
class _SlotCommanderControls extends ConsumerWidget {
  final PlayerSlot slot;
  final bool isCommanderLobby;

  const _SlotCommanderControls({
    required this.slot,
    required this.isCommanderLobby,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gap = LayoutTokens.gr1;
    final l10n = AppLocalizations.of(context);

    if (!isCommanderLobby) {
      return LobbyActionButton(
        label: l10n.hostSelectDeck,
        highlighted: slot.selectedDeckId != null,
        filled: true,
        onPressed: () => showDeckPickerSheet(context, ref, slot.playerId),
      );
    }

    return Row(
      children: [
        Expanded(
          child: LobbyActionButton(
            label: l10n.hostSelectDeck,
            highlighted: slot.selectedDeckId != null,
            filled: false,
            onPressed:
                () => showDeckPickerSheet(context, ref, slot.playerId),
          ),
        ),
        SizedBox(width: gap),
        Expanded(
          child: LobbyActionButton(
            label: l10n.hostSelectCommander,
            highlighted: slot.commanderName != null,
            filled: true,
            onPressed:
                () => context.push(
                  AppRoutes.commanderSelect,
                  extra: {'playerId': slot.playerId},
                ),
          ),
        ),
      ],
    );
  }
}

class _SlotReadyButton extends ConsumerWidget {
  final PlayerSlot slot;

  const _SlotReadyButton({required this.slot});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColorTokens.of(context);
    final l10n = AppLocalizations.of(context);
    return IconButton(
      tooltip: slot.isReady ? l10n.hostMarkNotReady : l10n.hostMarkReady,
      style: IconButton.styleFrom(
        minimumSize: const Size(
          LayoutTokens.minTapTarget,
          LayoutTokens.minTapTarget,
        ),
        backgroundColor:
            slot.isReady
                ? colors.primaryAccent.withValues(alpha: OpacityTokens.soft)
                : colors.backgroundSecondary,
        foregroundColor:
            slot.isReady ? colors.primaryAccent : colors.textSecondary,
      ),
      onPressed: () {
        final notifier = ref.read(lobbyProvider.notifier);
        notifier.setReady(slot.playerId, ready: !slot.isReady);
      },
      icon: const Icon(Icons.check_rounded, size: 24),
    );
  }
}

// ── Empty slots indicator ─────────────────────────────────────────────────

class _EmptySlotCard extends StatelessWidget {
  final int remaining;
  const _EmptySlotCard({required this.remaining});

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTokens.of(context);
    final l10n = AppLocalizations.of(context);
    return Container(
      margin: EdgeInsets.only(bottom: LayoutTokens.gr2),
      padding: EdgeInsets.symmetric(vertical: LayoutTokens.gr4),
      decoration: BoxDecoration(
        color: colors.backgroundSecondary,
        borderRadius: RadiusTokens.radiusMd,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: LayoutTokens.gr2),
        child: Text(
          l10n.hostOpenSlots(remaining),
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: MediaQuery.sizeOf(context).width < 360
                ? FontTokens.caption
                : FontTokens.hudSm,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
        ),
      ),
    );
  }
}

// ── Config section ────────────────────────────────────────────────────────

class _ConfigSection extends ConsumerWidget {
  final LobbyConfig config;
  const _ConfigSection({required this.config});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColorTokens.of(context);
    final l10n = AppLocalizations.of(context);
    final notifier = ref.read(lobbyProvider.notifier);

    final compact = MediaQuery.sizeOf(context).width < 360;

    return Container(
      padding: EdgeInsets.all(compact ? LayoutTokens.gr3 : LayoutTokens.gr4),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: RadiusTokens.radiusMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.hostGameSettings,
            style: TypographyTokens.sectionTitle(colors.textPrimary),
          ),
          SizedBox(height: LayoutTokens.gr3),
          _ConfigDropdownRow(
            label: l10n.hostFormat,
            child: _FormatDropdown(
              value: config.format,
              onChanged: (f) => notifier.updateConfig(
                config.copyWith(
                  format: f,
                  startingLife: f.defaultStartingLife,
                ),
              ),
            ),
          ),
          SizedBox(height: LayoutTokens.gr3),
          _ConfigDropdownRow(
            label: l10n.hostStartingLife,
            child: _StartingLifeDropdown(
              value: config.startingLife,
              onChanged:
                  (v) => notifier.updateConfig(
                    config.copyWith(startingLife: v),
                  ),
            ),
          ),
          SizedBox(height: LayoutTokens.gr4),
          // Gameplay settings
          Text(
            l10n.hostGameplay,
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: FontTokens.hudSm,
            ),
          ),
          SizedBox(height: LayoutTokens.gr2),
          _GameplayToggles(config: config, notifier: notifier),
        ],
      ),
    );
  }
}

InputDecoration _lobbyDropdownDecoration(BuildContext context) {
  final colors = AppColorTokens.of(context);
  final border = OutlineInputBorder(
    borderRadius: RadiusTokens.radiusSm,
    borderSide: BorderSide.none,
  );
  return InputDecoration(
    filled: true,
    fillColor: colors.backgroundSecondary,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: LayoutTokens.gr3,
      vertical: LayoutTokens.gr2,
    ),
    border: border,
    enabledBorder: border,
    focusedBorder: OutlineInputBorder(
      borderRadius: RadiusTokens.radiusSm,
      borderSide: BorderSide(color: colors.primaryAccent, width: 1.5),
    ),
  );
}

/// Label + full-width dropdown (Format, Starting Life, …).
class _ConfigDropdownRow extends StatelessWidget {
  final String label;
  final Widget child;

  const _ConfigDropdownRow({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTokens.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: FontTokens.label,
            ),
          ),
        ),
        SizedBox(width: LayoutTokens.gr2),
        Expanded(child: child),
      ],
    );
  }
}

class _FormatDropdown extends StatelessWidget {
  final GameFormat value;
  final ValueChanged<GameFormat> onChanged;

  const _FormatDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTokens.of(context);
    return DropdownButtonFormField<GameFormat>(
      key: ValueKey<GameFormat>(value),
      initialValue: value,
      isExpanded: true,
      decoration: _lobbyDropdownDecoration(context),
      dropdownColor: colors.surface,
      style: TextStyle(color: colors.textPrimary, fontSize: FontTokens.body),
      menuMaxHeight: 360,
      items:
          GameFormatDetails.lobbyPickerOrder
              .map(
                (f) => DropdownMenuItem(
                  value: f,
                  child: Text(f.displayName),
                ),
              )
              .toList(),
      onChanged: (f) {
        if (f != null) onChanged(f);
      },
    );
  }
}

class _StartingLifeDropdown extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const _StartingLifeDropdown({
    required this.value,
    required this.onChanged,
  });

  static const _presets = [20, 25, 30, 40, 60];
  static const _customMenuValue = -1;

  static void _showCustomDialog(
    BuildContext context, {
    required int current,
    required ValueChanged<int> onChanged,
  }) {
    final controller = TextEditingController(text: current.toString());
    final l10n = AppLocalizations.of(context);
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        void submit() {
          final v = int.tryParse(controller.text);
          if (v != null && v >= 1 && v <= 999) {
            onChanged(v);
            Navigator.pop(dialogContext);
          }
        }

        return GameFormDialog(
          title: l10n.hostCustomStartingLifeTitle,
          submitLabel: 'OK',
          onSubmit: submit,
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: InputDecoration(
              hintText: l10n.hostCustomStartingLifeHint,
            ),
            onSubmitted: (_) => submit(),
          ),
        );
      },
    ).whenComplete(controller.dispose);
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTokens.of(context);
    final l10n = AppLocalizations.of(context);
    final items = <DropdownMenuItem<int>>[
      ..._presets.map(
        (v) => DropdownMenuItem(value: v, child: Text('$v')),
      ),
      if (!_presets.contains(value))
        DropdownMenuItem(value: value, child: Text('$value')),
      DropdownMenuItem(
        value: _customMenuValue,
        child: Text(l10n.hostCustomEllipsis),
      ),
    ];

    return DropdownButtonFormField<int>(
      key: ValueKey<int>(value),
      initialValue: value,
      isExpanded: true,
      decoration: _lobbyDropdownDecoration(context),
      dropdownColor: colors.surface,
      style: TextStyle(color: colors.textPrimary, fontSize: FontTokens.body),
      items: items,
      onChanged: (v) {
        if (v == null) return;
        if (v == _customMenuValue) {
          _showCustomDialog(context, current: value, onChanged: onChanged);
        } else {
          onChanged(v);
        }
      },
    );
  }
}

class _TurnTimeLimitDropdown extends StatelessWidget {
  final int? value;
  final ValueChanged<int?> onChanged;

  const _TurnTimeLimitDropdown({
    required this.value,
    required this.onChanged,
  });

  static const _presets = <int?>[null, 30, 60];

  static String _label(AppLocalizations l10n, int? seconds) => switch (seconds) {
    null => l10n.hostTurnLimitOff,
    final int s => l10n.hostTurnLimitSeconds(s),
  };

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTokens.of(context);
    final l10n = AppLocalizations.of(context);
    final items = <DropdownMenuItem<int?>>[
      ..._presets.map(
        (v) => DropdownMenuItem(value: v, child: Text(_label(l10n, v))),
      ),
      if (value != null && !_presets.contains(value))
        DropdownMenuItem(value: value, child: Text(_label(l10n, value))),
    ];

    return DropdownButtonFormField<int?>(
      key: ValueKey<int?>(value),
      initialValue: value,
      isExpanded: true,
      decoration: _lobbyDropdownDecoration(context),
      dropdownColor: colors.surface,
      style: TextStyle(color: colors.textPrimary, fontSize: FontTokens.body),
      items: items,
      onChanged: onChanged,
    );
  }
}

// ── Gameplay toggles (reference: grouped card style with icons & subtitles) ─

class _GameplayToggles extends StatelessWidget {
  final LobbyConfig config;
  final LobbyNotifier notifier;
  const _GameplayToggles({required this.config, required this.notifier});

  bool get _autoKoAll =>
      config.autoKoFromLife &&
      config.autoKoFromPoison &&
      config.autoKoFromCommanderDamage;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _GameplaySwitchTile(
          title: l10n.hostToggleTeams,
          subtitle: l10n.hostToggleTeamsSubtitle,
          value: config.teamsEnabled,
          onChanged: (v) =>
              notifier.updateConfig(config.copyWith(teamsEnabled: v)),
        ),
        _GameplaySwitchTile(
          title: l10n.hostTogglePlanechase,
          subtitle: l10n.hostTogglePlanechaseSubtitle,
          value: config.planechaseEnabled,
          onChanged: (v) =>
              notifier.updateConfig(config.copyWith(planechaseEnabled: v)),
        ),
        _GameplaySwitchTile(
          title: l10n.hostToggleArchenemy,
          subtitle: l10n.hostToggleArchenemySubtitle,
          value: config.archenemyEnabled,
          onChanged: (v) =>
              notifier.updateConfig(config.copyWith(archenemyEnabled: v)),
        ),
        _GameplaySwitchTile(
          title: l10n.hostToggleBounty,
          subtitle: l10n.hostToggleBountySubtitle,
          value: config.bountyEnabled,
          onChanged: (v) =>
              notifier.updateConfig(config.copyWith(bountyEnabled: v)),
        ),
        _GameplaySwitchTile(
          title: l10n.hostToggleAutoKo,
          subtitle: l10n.hostToggleAutoKoSubtitle,
          value: _autoKoAll,
          onChanged: (v) => notifier.updateConfig(config.copyWith(
                autoKoFromLife: v,
                autoKoFromPoison: v,
                autoKoFromCommanderDamage: v,
              )),
        ),
        _GameplaySwitchTile(
          title: l10n.hostToggleCommanderDmgLife,
          subtitle: l10n.hostToggleCommanderDmgLifeSubtitle,
          value: config.commanderDamageReducesLife,
          onChanged: (v) => notifier.updateConfig(
              config.copyWith(commanderDamageReducesLife: v)),
        ),
        _GameplaySwitchTile(
          title: l10n.hostTogglePhaseTracker,
          subtitle: l10n.hostTogglePhaseTrackerSubtitle,
          value: config.phasesEnabled,
          onChanged: (v) =>
              notifier.updateConfig(config.copyWith(phasesEnabled: v)),
        ),
        _GameplaySwitchTile(
          title: l10n.hostToggleTurnTimer,
          subtitle: l10n.hostToggleTurnTimerSubtitle,
          value: config.trackTurnDuration,
          onChanged:
              (v) => notifier.updateConfig(
                config.copyWith(
                  trackTurnDuration: v,
                  turnTimeLimitSeconds: v ? config.turnTimeLimitSeconds : null,
                ),
              ),
        ),
        if (config.trackTurnDuration) ...[
          SizedBox(height: LayoutTokens.gr1),
          Padding(
            padding: const EdgeInsets.only(
              left: LayoutTokens.gr4,
              right: LayoutTokens.gr4,
              bottom: LayoutTokens.gr2,
            ),
            child: _ConfigDropdownRow(
              label: l10n.hostTurnLimit,
              child: _TurnTimeLimitDropdown(
                value: config.turnTimeLimitSeconds,
                onChanged:
                    (v) => notifier.updateConfig(
                      config.copyWith(turnTimeLimitSeconds: v),
                    ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _GameplaySwitchTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _GameplaySwitchTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTokens.of(context);
    final compact = MediaQuery.sizeOf(context).width < 360;

    return SwitchListTile(
      title: Text(
        title,
        style: TextStyle(
          color: colors.textPrimary,
          fontSize: compact ? FontTokens.body : FontTokens.title,
          fontWeight: FontWeight.w500,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: colors.textSecondary,
          fontSize: FontTokens.caption,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
      ),
      value: value,
      onChanged: onChanged,
      activeTrackColor: colors.primaryAccent.withValues(alpha: OpacityTokens.half),
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return colors.primaryAccent;
        }
        return null;
      }),
      contentPadding: EdgeInsets.symmetric(
        horizontal: compact ? LayoutTokens.gr2 : LayoutTokens.gr3,
        vertical: LayoutTokens.gr1,
      ),
    );
  }
}

// ── Start game button ─────────────────────────────────────────────────────

class _StartGameButton extends ConsumerStatefulWidget {
  final bool canStart;
  final String hint;
  const _StartGameButton({required this.canStart, required this.hint});

  @override
  ConsumerState<_StartGameButton> createState() => _StartGameButtonState();
}

class _StartGameButtonState extends ConsumerState<_StartGameButton> {
  bool _isStarting = false;

  @override
  Widget build(BuildContext context) {
    final canStart = widget.canStart && !_isStarting;
    final l10n = AppLocalizations.of(context);
    return UiButton(
      label: widget.canStart ? l10n.hostStartGame : widget.hint,
      enabled: widget.canStart,
      loading: _isStarting,
      onPressed: canStart
          ? () async {
              setState(() => _isStarting = true);
              try {
                await ref.read(lobbyProvider.notifier).broadcastGameStart();
                if (context.mounted) context.go(AppRoutes.game);
              } finally {
                if (mounted) setState(() => _isStarting = false);
              }
            }
          : null,
    );
  }
}
