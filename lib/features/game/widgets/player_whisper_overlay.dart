import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/game/game_providers.dart';
import '../../../core/game/game_session_events.dart';
import '../../../ui/tokens/font_tokens.dart';
import '../../../ui/tokens/layout_tokens.dart';
import '../../../ui/tokens/opacity_tokens.dart';
import '../../../ui/tokens/radius_tokens.dart';
import 'game_colors.dart';

/// Subtle banner when another player sends a private whisper.
class PlayerWhisperOverlay extends ConsumerStatefulWidget {
  const PlayerWhisperOverlay({
    super.key,
    required this.whisper,
    this.autoDismiss = const Duration(seconds: 7),
  });

  final PlayerWhisperAnnouncement whisper;
  final Duration autoDismiss;

  @override
  ConsumerState<PlayerWhisperOverlay> createState() =>
      _PlayerWhisperOverlayState();
}

class _PlayerWhisperOverlayState extends ConsumerState<PlayerWhisperOverlay> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _armTimer();
  }

  @override
  void didUpdateWidget(covariant PlayerWhisperOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.whisper.id != widget.whisper.id) {
      _armTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _armTimer() {
    _timer?.cancel();
    _timer = Timer(widget.autoDismiss, _dismiss);
  }

  void _dismiss() {
    if (!mounted) return;
    ref.read(gameProvider.notifier).dismissPlayerWhisper();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    final w = widget.whisper;

    return Positioned(
      left: LayoutTokens.gr3,
      right: LayoutTokens.gr3,
      bottom: LayoutTokens.gr4 + MediaQuery.paddingOf(context).bottom,
      child: Semantics(
        liveRegion: true,
        label: 'Whisper from ${w.fromUsername}: ${w.text}',
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _dismiss,
            borderRadius: RadiusTokens.radiusMd,
            child: Ink(
              decoration: BoxDecoration(
                color: colors.surface.withValues(alpha: 0.96),
                borderRadius: RadiusTokens.radiusMd,
                border: Border.all(
                  color: colors.primaryAccent.withValues(alpha: 0.45),
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.backgroundPrimary.withValues(
                      alpha: OpacityTokens.soft,
                    ),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: LayoutTokens.gr3,
                  vertical: LayoutTokens.gr2,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 20,
                      color: colors.primaryAccent,
                    ),
                    SizedBox(width: LayoutTokens.gr2),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Whisper from ${w.fromUsername}',
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontSize: FontTokens.sm,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: LayoutTokens.gr0),
                          Text(
                            w.text,
                            style: TextStyle(
                              color: colors.textPrimary,
                              fontSize: FontTokens.body,
                              fontWeight: FontWeight.w600,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: colors.textMuted,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
