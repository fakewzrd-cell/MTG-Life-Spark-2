import 'package:flutter/material.dart';

import '../../../core/game/game_phase.dart';
import '../../../core/game/game_state.dart';
import 'game_colors.dart';
import '../../../ui/tokens/font_tokens.dart';
import '../../../ui/tokens/layout_tokens.dart';
import '../../../ui/tokens/opacity_tokens.dart';
import '../../../ui/tokens/radius_tokens.dart';
import 'phase_picker_sheet.dart';

/// Play-tab bar: phase status · Back · Next · End turn.
class PhaseNavCluster extends StatelessWidget {
  const PhaseNavCluster({
    super.key,
    required this.game,
    required this.accentColor,
    this.onBack,
    this.onNext,
    this.onPickPhase,
    this.onEndTurn,
    this.endTurnEnabled = false,
  });

  final GameState game;
  final Color accentColor;
  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final void Function(GamePhase phase)? onPickPhase;
  final VoidCallback? onEndTurn;
  final bool endTurnEnabled;

  static const double barHeight = 52;

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    final borderColor = accentColor.withValues(alpha: 0.45);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.94),
        borderRadius: RadiusTokens.radiusControlSm,
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: RadiusTokens.radiusControlSm,
        child: PhaseNavClusterStrip(
          game: game,
          accentColor: accentColor,
          onBack: onBack,
          onNext: onNext,
          onPickPhase: onPickPhase,
          onEndTurn: onEndTurn,
          endTurnEnabled: endTurnEnabled,
        ),
      ),
    );
  }
}

class PhaseNavClusterStrip extends StatelessWidget {
  const PhaseNavClusterStrip({
    super.key,
    required this.game,
    required this.accentColor,
    this.onBack,
    this.onNext,
    this.onPickPhase,
    this.onEndTurn,
    this.endTurnEnabled = false,
  });

  final GameState game;
  final Color accentColor;
  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final void Function(GamePhase phase)? onPickPhase;
  final VoidCallback? onEndTurn;
  final bool endTurnEnabled;

  static const double _sideMinWidth = 72;
  static const double _endTurnMinWidth = 88;

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    final dividerColor = colors.textSecondary.withValues(alpha: 0.14);

    return SizedBox(
      height: PhaseNavCluster.barHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _PhaseNavCenter(
              game: game,
              accentColor: accentColor,
              onPickPhase: onPickPhase,
            ),
          ),
          if (onBack != null) ...[
            VerticalDivider(width: 1, thickness: 1, color: dividerColor),
            SizedBox(
              width: _sideMinWidth,
              child: _PhaseNavSideButton(
                label: 'Back',
                icon: Icons.chevron_left_rounded,
                iconFirst: true,
                enabled: !game.timeoutActive,
                onPressed: onBack,
              ),
            ),
          ],
          if (onNext != null) ...[
            VerticalDivider(width: 1, thickness: 1, color: dividerColor),
            SizedBox(
              width: _sideMinWidth,
              child: _PhaseNavSideButton(
                label: 'Next',
                icon: Icons.chevron_right_rounded,
                iconFirst: false,
                enabled: !game.timeoutActive,
                onPressed: onNext,
              ),
            ),
          ],
          if (onEndTurn != null) ...[
            VerticalDivider(width: 1, thickness: 1, color: dividerColor),
            SizedBox(
              width: _endTurnMinWidth,
              child: _PhaseNavEndTurnButton(
                enabled: endTurnEnabled && !game.timeoutActive,
                accentColor: accentColor,
                onPressed: onEndTurn,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PhaseNavEndTurnButton extends StatelessWidget {
  const _PhaseNavEndTurnButton({
    required this.enabled,
    required this.accentColor,
    this.onPressed,
  });

  final bool enabled;
  final Color accentColor;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    final bg = enabled
        ? accentColor.withValues(alpha: OpacityTokens.soft)
        : colors.backgroundSecondary.withValues(alpha: 0.35);
    final fg = enabled
        ? accentColor
        : colors.textSecondary.withValues(alpha: 0.45);

    return Semantics(
      button: true,
      enabled: enabled,
      label: 'End turn',
      child: Material(
        color: bg,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          child: Center(
            child: Text(
              'End turn',
              style: TextStyle(
                fontSize: FontTokens.hudSm,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.1,
                color: fg,
                height: 1.1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PhaseNavSideButton extends StatelessWidget {
  const _PhaseNavSideButton({
    required this.label,
    required this.icon,
    required this.iconFirst,
    required this.enabled,
    this.onPressed,
  });

  final String label;
  final IconData icon;
  final bool iconFirst;
  final bool enabled;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    final fg =
        enabled
            ? colors.textPrimary
            : colors.textSecondary.withValues(alpha: 0.45);
    final iconWidget = Icon(icon, size: 20, color: fg);
    final labelWidget = Text(
      label,
      style: TextStyle(
        fontSize: FontTokens.hudSm,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        color: fg,
        height: 1.1,
      ),
    );

    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children:
                    iconFirst
                        ? [iconWidget, SizedBox(width: LayoutTokens.gr0), labelWidget]
                        : [labelWidget, SizedBox(width: LayoutTokens.gr0), iconWidget],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PhaseNavCenter extends StatelessWidget {
  const _PhaseNavCenter({
    required this.game,
    required this.accentColor,
    this.onPickPhase,
  });

  final GameState game;
  final Color accentColor;
  final void Function(GamePhase phase)? onPickPhase;

  bool get _canPick => onPickPhase != null;

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    final phaseColor =
        game.isLocalPlayersTurn ? colors.primaryAccent : colors.textSecondary;

    final label = FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            game.currentPhase.displayName,
            textAlign: TextAlign.center,
            maxLines: 1,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: FontTokens.title,
              letterSpacing: 0.2,
              color: phaseColor,
            ),
          ),
          if (_canPick) ...[
            const SizedBox(width: LayoutTokens.gr0),
            Icon(
              Icons.unfold_more_rounded,
              size: 18,
              color: phaseColor.withValues(alpha: OpacityTokens.nearOpaque),
            ),
          ],
        ],
      ),
    );

    if (!_canPick) {
      return Semantics(
        header: true,
        label: 'Current phase, ${game.currentPhase.displayName}',
        child: Center(child: label),
      );
    }

    return Semantics(
      button: true,
      label: 'Choose phase, ${game.currentPhase.displayName}',
      child: Material(
        color: colors.backgroundPrimary.withValues(alpha: 0.08),
        child: InkWell(
          onTap:
              () => showPhasePickerSheet(
                context,
                currentPhase: game.currentPhase,
                accentColor: accentColor,
                onSelected: onPickPhase!,
              ),
          child: Center(
            child: Tooltip(message: 'Choose phase', child: label),
          ),
        ),
      ),
    );
  }
}
