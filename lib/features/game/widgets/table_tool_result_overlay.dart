import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/game/game_providers.dart';
import '../../../core/game/game_session_events.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/tokens/font_tokens.dart';
import '../../../ui/tokens/layout_tokens.dart';
import '../../../ui/tokens/opacity_tokens.dart';
import '../../../ui/tokens/radius_tokens.dart';
import 'game_colors.dart';

/// Full-screen shared dice / coin result. Tap or wait [autoDismiss] to clear.
class TableToolResultOverlay extends ConsumerStatefulWidget {
  const TableToolResultOverlay({
    super.key,
    required this.announcement,
    this.autoDismiss = const Duration(seconds: 5),
  });

  final TableToolAnnouncement announcement;
  final Duration autoDismiss;

  @override
  ConsumerState<TableToolResultOverlay> createState() =>
      _TableToolResultOverlayState();
}

class _TableToolResultOverlayState extends ConsumerState<TableToolResultOverlay> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _armTimer();
  }

  @override
  void didUpdateWidget(covariant TableToolResultOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.announcement.id != widget.announcement.id) {
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
    ref.read(gameProvider.notifier).dismissTableToolAnnouncement();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    final l10n = AppLocalizations.of(context);
    final a = widget.announcement;
    final headline = a.localizedHeadline(l10n);
    final resultStyle = TextStyle(
      color: colors.onAccent,
      fontSize: a.kind == TableToolKind.coin
          ? FontTokens.displayCommander
          : FontTokens.displayLife,
      fontWeight: FontWeight.w800,
      height: 1.05,
    );

    return Positioned.fill(
      child: Semantics(
        button: true,
        label: l10n.tableToolDismissA11y(headline),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _dismiss,
          child: ColoredBox(
            color: colors.backgroundPrimary.withValues(
              alpha: OpacityTokens.strong,
            ),
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: LayoutTokens.gr6),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.primaryAccent,
                    borderRadius: RadiusTokens.radiusLg,
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: LayoutTokens.gr5,
                      vertical: LayoutTokens.gr5,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          a.localizedToolLabel(l10n).toUpperCase(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: colors.onAccent.withValues(alpha: 0.85),
                            fontSize: FontTokens.caption,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                        SizedBox(height: LayoutTokens.gr2),
                        Text(
                          a.localizedResultLabel(l10n),
                          textAlign: TextAlign.center,
                          style: resultStyle,
                        ),
                        SizedBox(height: LayoutTokens.gr3),
                        Text(
                          headline,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: colors.onAccent,
                            fontSize: FontTokens.title,
                            fontWeight: FontWeight.w700,
                            height: 1.25,
                          ),
                        ),
                        SizedBox(height: LayoutTokens.gr2),
                        Text(
                          l10n.tableToolTapToDismiss,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: colors.onAccent.withValues(alpha: 0.85),
                            fontSize: FontTokens.body,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
