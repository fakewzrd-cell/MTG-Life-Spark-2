import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/game/game_state_notifier.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/tokens/font_tokens.dart';
import '../../../ui/tokens/layout_tokens.dart';
import '../../../ui/tokens/opacity_tokens.dart';
import '../../../ui/tokens/radius_tokens.dart';
import 'game_colors.dart';
import 'game_modal_chrome.dart';

// ── Timeout bottom sheet ───────────────────────────────────────────────────

class _GameTimeoutPickerSheet extends StatelessWidget {
  final GameStateNotifier notifier;
  const _GameTimeoutPickerSheet({required this.notifier});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final options = <(String, int)>[
      (l10n.timeout15Seconds, 15),
      (l10n.timeout30Seconds, 30),
      (l10n.timeout1Minute, 60),
    ];
    return GameSheetBody(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GameSheetHeader(title: l10n.timeoutStartTitle),
          SizedBox(height: LayoutTokens.gr3),
          for (var i = 0; i < options.length; i++) ...[
            if (i > 0) SizedBox(height: LayoutTokens.gr1),
            _GameTimeoutOption(
              label: options[i].$1,
              icon: Icons.timer,
              onTap: () {
                Navigator.pop(context);
                notifier.startTimeout(durationSeconds: options[i].$2);
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _GameTimeoutOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _GameTimeoutOption({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    return ListTile(
      tileColor: colors.backgroundSecondary,
      shape: RoundedRectangleBorder(borderRadius: RadiusTokens.radiusControlSm),
      leading: Icon(icon, color: colors.emphasis),
      title: Text(label, style: TextStyle(color: colors.textPrimary)),
      onTap: onTap,
    );
  }
}

// ── Banners ────────────────────────────────────────────────────────────────

/// Full-screen overlay when timeout is active. Blocks life/counter changes.
/// [onEndTimeout] ends the pause immediately (toggle off).
class GameTimeoutOverlay extends StatefulWidget {
  final DateTime? startTime;
  final int? durationSeconds;
  final VoidCallback onEndTimeout;

  const GameTimeoutOverlay({super.key, 
    this.startTime,
    this.durationSeconds,
    required this.onEndTimeout,
  });

  @override
  State<GameTimeoutOverlay> createState() => _GameTimeoutOverlayState();
}

class _GameTimeoutOverlayState extends State<GameTimeoutOverlay> {
  Timer? _ticker;
  int _elapsed = 0;
  bool _minimized = false;

  @override
  void initState() {
    super.initState();
    if (widget.startTime != null) {
      _elapsed = DateTime.now().difference(widget.startTime!).inSeconds;
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() => _elapsed++);
      });
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  String get _timeStr {
    if (widget.durationSeconds != null) {
      final remaining = (widget.durationSeconds! - _elapsed).clamp(0, 9999);
      final m = remaining ~/ 60;
      final s = remaining % 60;
      return '$m:${s.toString().padLeft(2, '0')}';
    }
    final m = _elapsed ~/ 60;
    final s = _elapsed % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    final l10n = AppLocalizations.of(context);
    if (_minimized) {
      return Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () => setState(() => _minimized = false),
              behavior: HitTestBehavior.opaque,
              child: Container(
                color: Colors.black.withValues(alpha: 0.45),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: LayoutTokens.gr3,
                  vertical: LayoutTokens.gr2,
                ),
                child: Center(
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: LayoutTokens.gr2,
                        vertical: LayoutTokens.gr1,
                      ),
                      decoration: BoxDecoration(
                        color: colors.emphasis.withValues(alpha: OpacityTokens.subtle),
                        borderRadius: RadiusTokens.radiusLg,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: () => setState(() => _minimized = false),
                            borderRadius: RadiusTokens.radiusMd,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: LayoutTokens.gr1,
                                vertical: LayoutTokens.gr1,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.timer,
                                    size: 18,
                                    color: colors.emphasis,
                                  ),
                                  SizedBox(width: LayoutTokens.gr1),
                                  Text(
                                    widget.durationSeconds != null
                                        ? '$_timeStr left'
                                        : _timeStr,
                                    style: TextStyle(
                                      color: colors.emphasis,
                                      fontSize: FontTokens.body,
                                      fontWeight: FontWeight.w700,
                                      fontFeatures: const [
                                        FontFeature.tabularFigures(),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: LayoutTokens.gr1),
                          FilledButton(
                            onPressed: widget.onEndTimeout,
                            style: FilledButton.styleFrom(
                              backgroundColor: colors.emphasis,
                              foregroundColor: colors.backgroundPrimary,
                              minimumSize: const Size(
                                0,
                                LayoutTokens.minTapTarget,
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: LayoutTokens.gr2,
                              ),
                            ),
                            child: Text(l10n.gameBarEnd),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Positioned.fill(
      child: GestureDetector(
        onTap: () {}, // Absorb all touches
        behavior: HitTestBehavior.opaque,
        child: Container(
          color: Colors.black.withValues(alpha: 0.7),
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: RadiusTokens.radiusLg,
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: -8,
                    right: -8,
                    child: IconButton(
                      icon: Icon(
                        Icons.close,
                        color: colors.textSecondary,
                      ),
                      tooltip: l10n.timeoutMinimizeTooltip,
                      onPressed: () => setState(() => _minimized = true),
                      style: IconButton.styleFrom(
                        backgroundColor: colors.backgroundSecondary,
                        padding: const EdgeInsets.all(8),
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.timer, size: 56, color: colors.emphasis),
                      SizedBox(height: LayoutTokens.gr3),
                      Text(
                        l10n.timeoutBanner,
                        style: TextStyle(
                          color: colors.emphasis,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.durationSeconds != null
                            ? '$_timeStr remaining'
                            : '$_timeStr elapsed',
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: FontTokens.displayCommander,
                          fontWeight: FontWeight.w700,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                      SizedBox(height: LayoutTokens.gr2),
                      Text(
                        l10n.timeoutPaused,
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: FontTokens.body,
                        ),
                      ),
                      SizedBox(height: LayoutTokens.gr4),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: widget.onEndTimeout,
                          style: FilledButton.styleFrom(
                            backgroundColor: colors.emphasis,
                            foregroundColor: colors.backgroundPrimary,
                            minimumSize: const Size(
                              0,
                              LayoutTokens.minTapTarget,
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: LayoutTokens.gr2,
                            ),
                          ),
                          child: Text(l10n.timeoutEnd),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GameTimeoutBanner extends StatefulWidget {
  final DateTime? startTime;
  final int? durationSeconds;

  const GameTimeoutBanner({super.key, this.startTime, this.durationSeconds});

  @override
  State<GameTimeoutBanner> createState() => _GameTimeoutBannerState();
}

class _GameTimeoutBannerState extends State<GameTimeoutBanner> {
  Timer? _ticker;
  int _elapsed = 0;

  @override
  void initState() {
    super.initState();
    if (widget.startTime != null) {
      _elapsed = DateTime.now().difference(widget.startTime!).inSeconds;
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() => _elapsed++);
      });
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  String get _timeStr {
    if (widget.durationSeconds != null) {
      final remaining = (widget.durationSeconds! - _elapsed).clamp(0, 9999);
      final m = remaining ~/ 60;
      final s = remaining % 60;
      return '$m:${s.toString().padLeft(2, '0')} remaining';
    }
    final m = _elapsed ~/ 60;
    final s = _elapsed % 60;
    return '$m:${s.toString().padLeft(2, '0')} elapsed';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    final l10n = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      margin: EdgeInsets.zero,
      padding: EdgeInsets.symmetric(
        horizontal: LayoutTokens.gr2,
        vertical: LayoutTokens.gr1 + 2,
      ),
      decoration: BoxDecoration(
        color: colors.emphasis.withValues(alpha: OpacityTokens.subtle),
        borderRadius: RadiusTokens.radiusControlSm,
      ),
      child: Row(
        children: [
          Icon(Icons.timer, color: colors.emphasis, size: 16),
          SizedBox(width: LayoutTokens.gr1),
          Expanded(
            child: Text(
              l10n.timeoutMinimized(_timeStr),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colors.emphasis,
                fontSize: FontTokens.caption,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GameTurnDurationBanner extends StatefulWidget {
  final DateTime turnStartTime;
  final int? limitSeconds;
  final bool isActiveTurn;
  final String activePlayerName;

  const GameTurnDurationBanner({super.key, 
    required this.turnStartTime,
    this.limitSeconds,
    required this.isActiveTurn,
    required this.activePlayerName,
  });

  @override
  State<GameTurnDurationBanner> createState() => _GameTurnDurationBannerState();
}

class _GameTurnDurationBannerState extends State<GameTurnDurationBanner> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    final l10n = AppLocalizations.of(context);
    final elapsed = DateTime.now().difference(widget.turnStartTime).inSeconds;
    final hasLimit = widget.limitSeconds != null;
    final remaining =
        hasLimit ? (widget.limitSeconds! - elapsed).clamp(0, 9999) : null;

    final prefix = widget.isActiveTurn
        ? l10n.gameYourTurn
        : l10n.gamePlayersTurn(widget.activePlayerName);
    String label;
    if (hasLimit && remaining != null) {
      final m = remaining ~/ 60;
      final s = remaining % 60;
      label = '$prefix: $m:${s.toString().padLeft(2, '0')} left';
    } else {
      final m = elapsed ~/ 60;
      final s = elapsed % 60;
      label = '$prefix: $m:${s.toString().padLeft(2, '0')}';
    }

    return Container(
      margin: EdgeInsets.symmetric(vertical: LayoutTokens.gr0),
      padding: EdgeInsets.symmetric(
        horizontal: LayoutTokens.gr2,
        vertical: LayoutTokens.gr1,
      ),
      decoration: BoxDecoration(
        color: colors.primaryAccent.withValues(alpha: OpacityTokens.subtle),
        borderRadius: RadiusTokens.radiusControlSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.schedule,
            color:
                widget.isActiveTurn ? colors.primaryAccent : colors.textSecondary,
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color:
                  widget.isActiveTurn
                      ? colors.primaryAccent
                      : colors.textSecondary,
              fontSize: FontTokens.caption,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}


void showGameTimeoutPicker(BuildContext context, GameStateNotifier notifier) {
  showGameBottomSheet<void>(
    context: context,
    builder: (_) => _GameTimeoutPickerSheet(notifier: notifier),
  );
}
