import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/game/game_state.dart';
import '../../../core/game/player_game_state.dart';
import '../../../ui/tokens/motion_tokens.dart';
import '../../../ui/tokens/opacity_tokens.dart';
import '../../../ui/tokens/radius_tokens.dart';
import 'game_colors.dart';

// ── First player roll overlay ───────────────────────────────────────────────

class GameFirstPlayerRollOverlay extends StatefulWidget {
  final GameState game;
  final PlayerGameState local;
  final void Function(int roll) onRoll;

  const GameFirstPlayerRollOverlay({
    required this.game,
    required this.local,
    required this.onRoll,
  });

  @override
  State<GameFirstPlayerRollOverlay> createState() =>
      _GameFirstPlayerRollOverlayState();
}

class _GameFirstPlayerRollOverlayState extends State<GameFirstPlayerRollOverlay>
    with SingleTickerProviderStateMixin {
  final _rand = Random();
  int? _myRoll;
  bool _rolling = false;
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: MotionTokens.slow,
    );
    _scaleAnim = Tween<double>(
      begin: 0.5,
      end: 1.2,
    ).chain(CurveTween(curve: Curves.elasticOut)).animate(_animController);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _doRoll() {
    if (_myRoll != null || _rolling) return;
    setState(() => _rolling = true);
    final roll = _rand.nextInt(6) + 1;
    widget.onRoll(roll);
    _animController.forward(from: 0);
    setState(() {
      _myRoll = roll;
      _rolling = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    final hasRolled = _myRoll != null;
    final othersRolled = widget.game.firstPlayerRolls.length;
    final totalPlayers = widget.game.players.length;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.casino, size: 48, color: colors.emphasis),
          const SizedBox(height: 16),
          Text(
            'Roll for First Player!',
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Highest roll goes first. Tap the dice to roll!',
            style: TextStyle(color: colors.textSecondary, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          GestureDetector(
            onTap: hasRolled ? null : _doRoll,
            child: AnimatedBuilder(
              animation: _scaleAnim,
              builder: (context, child) {
                return Transform.scale(
                  scale: _rolling ? _scaleAnim.value : 1,
                  child: child,
                );
              },
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: RadiusTokens.radiusLg,
                  border: Border.all(
                    color: hasRolled ? colors.emphasis : colors.primaryAccent,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colors.primaryAccent.withValues(alpha: OpacityTokens.moderate),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child:
                      hasRolled
                          ? Text(
                            '$_myRoll',
                            style: TextStyle(
                              color: colors.emphasis,
                              fontSize: 56,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                          : Icon(
                            Icons.casino_outlined,
                            size: 64,
                            color: colors.primaryAccent,
                          ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (hasRolled)
            Text(
              'You rolled $_myRoll!',
              style: TextStyle(
                color: colors.success,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            )
          else
            Text(
              'Tap to roll',
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 16,
              ),
            ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: colors.backgroundSecondary,
              borderRadius: RadiusTokens.radiusControlSm,
            ),
            child: Text(
              widget.game.isHost
                  ? '$othersRolled / $totalPlayers players have rolled'
                  : hasRolled
                  ? 'Waiting for others to roll…'
                  : 'Tap the dice above to roll',
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
