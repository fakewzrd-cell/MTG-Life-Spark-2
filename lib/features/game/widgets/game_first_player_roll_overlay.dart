import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/game/game_state.dart';
import '../../../core/game/player_game_state.dart';
import '../../../ui/theme/app_color_tokens.dart';
import '../../../ui/tokens/layout_tokens.dart';
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
    with TickerProviderStateMixin {
  final _rand = Random();
  int? _myRoll;
  int _displayFace = 1;
  bool _rolling = false;

  late AnimationController _tumbleController;
  late AnimationController _landController;
  late Animation<double> _wobble;
  late Animation<double> _landScale;

  static const _dicePips = <int, List<List<bool>>>{
    1: [
      [false, false, false],
      [false, true, false],
      [false, false, false],
    ],
    2: [
      [true, false, false],
      [false, false, false],
      [false, false, true],
    ],
    3: [
      [true, false, false],
      [false, true, false],
      [false, false, true],
    ],
    4: [
      [true, false, true],
      [false, false, false],
      [true, false, true],
    ],
    5: [
      [true, false, true],
      [false, true, false],
      [true, false, true],
    ],
    6: [
      [true, false, true],
      [true, false, true],
      [true, false, true],
    ],
  };

  @override
  void initState() {
    super.initState();
    _tumbleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _landController = AnimationController(
      vsync: this,
      duration: MotionTokens.slow,
    );
    _wobble = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _tumbleController, curve: Curves.easeInOut),
    );
    _landScale = Tween<double>(begin: 0.82, end: 1).animate(
      CurvedAnimation(parent: _landController, curve: Curves.elasticOut),
    );
    _tumbleController.addListener(_onTumbleTick);
  }

  void _onTumbleTick() {
    if (!_rolling) return;
    setState(() => _displayFace = _rand.nextInt(6) + 1);
  }

  @override
  void dispose() {
    _tumbleController.removeListener(_onTumbleTick);
    _tumbleController.dispose();
    _landController.dispose();
    super.dispose();
  }

  Future<void> _doRoll() async {
    if (_myRoll != null || _rolling) return;
    setState(() => _rolling = true);
    await _tumbleController.forward(from: 0);
    final roll = _rand.nextInt(6) + 1;
    widget.onRoll(roll);
    setState(() {
      _myRoll = roll;
      _displayFace = roll;
      _rolling = false;
    });
    await _landController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    final hasRolled = _myRoll != null;
    final othersRolled = widget.game.firstPlayerRolls.length;
    final totalPlayers = widget.game.players.length;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: LayoutTokens.gr4,
          vertical: LayoutTokens.gr3,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.casino, size: 44, color: colors.emphasis),
              const SizedBox(height: LayoutTokens.gr3),
              Text(
                'Roll for First Player',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: LayoutTokens.gr1),
              Text(
                'Highest roll goes first. Tap the die to roll!',
                style: TextStyle(color: colors.textSecondary, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: LayoutTokens.gr5),
              GestureDetector(
                onTap: hasRolled || _rolling ? null : _doRoll,
                child: AnimatedBuilder(
                  animation: Listenable.merge([_wobble, _landScale]),
                  builder: (context, child) {
                    final wobbleAngle =
                        _rolling ? _wobble.value * pi * 4 : 0.0;
                    final tiltX = _rolling ? sin(_wobble.value * pi * 6) * 0.35 : 0.0;
                    final scale = _rolling ? 1.0 : _landScale.value;
                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateX(tiltX)
                        ..rotateZ(wobbleAngle),
                      child: Transform.scale(scale: scale, child: child),
                    );
                  },
                  child: _DieFace(
                    value: _displayFace,
                    colors: colors,
                    highlighted: hasRolled,
                  ),
                ),
              ),
              const SizedBox(height: LayoutTokens.gr4),
              if (hasRolled)
                Text(
                  'You rolled $_myRoll!',
                  style: TextStyle(
                    color: colors.success,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                )
              else if (_rolling)
                Text(
                  'Rolling…',
                  style: TextStyle(
                    color: colors.emphasis,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                )
              else
                Text(
                  'Tap to roll',
                  style: TextStyle(color: colors.textSecondary, fontSize: 16),
                ),
              const SizedBox(height: LayoutTokens.gr4),
              _RollProgressList(game: widget.game),
              const SizedBox(height: LayoutTokens.gr3),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: LayoutTokens.gr3,
                  vertical: LayoutTokens.gr1,
                ),
                decoration: BoxDecoration(
                  color: colors.backgroundSecondary,
                  borderRadius: RadiusTokens.radiusControlSm,
                ),
                child: Text(
                  widget.game.isHost
                      ? '$othersRolled / $totalPlayers players have rolled'
                      : hasRolled
                          ? 'Waiting for others to roll…'
                          : 'Tap the die above to roll',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DieFace extends StatelessWidget {
  final int value;
  final AppColorTokens colors;
  final bool highlighted;

  const _DieFace({
    required this.value,
    required this.colors,
    required this.highlighted,
  });

  @override
  Widget build(BuildContext context) {
    final face = _GameFirstPlayerRollOverlayState._dicePips[value]!;
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.surface,
            colors.backgroundSecondary,
          ],
        ),
        borderRadius: RadiusTokens.radiusLg,
        border: Border.all(
          color: highlighted ? colors.emphasis : colors.primaryAccent,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.primaryAccent.withValues(
              alpha: OpacityTokens.moderate,
            ),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: face
              .map(
                (row) => Expanded(
                  child: Row(
                    children: row
                        .map(
                          (pip) => Expanded(
                            child: Center(
                              child: pip
                                  ? Container(
                                      width: 14,
                                      height: 14,
                                      decoration: BoxDecoration(
                                        color: highlighted
                                            ? colors.emphasis
                                            : colors.primaryAccent,
                                        shape: BoxShape.circle,
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _RollProgressList extends StatelessWidget {
  final GameState game;

  const _RollProgressList({required this.game});

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: game.players.map((p) {
        final roll = game.firstPlayerRolls[p.playerId];
        final isLocal = p.playerId == game.localPlayerId;
        return Padding(
          padding: const EdgeInsets.only(bottom: LayoutTokens.gr1),
          child: Row(
            children: [
              Icon(
                roll != null ? Icons.check_circle : Icons.hourglass_empty,
                size: 18,
                color: roll != null ? colors.success : colors.textMuted,
              ),
              const SizedBox(width: LayoutTokens.gr1),
              Expanded(
                child: Text(
                  isLocal ? '${p.username} (you)' : p.username,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: isLocal ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
              if (roll != null)
                Text(
                  '$roll',
                  style: TextStyle(
                    color: colors.emphasis,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ── Turn order reveal (after all rolls) ─────────────────────────────────────

class TurnOrderRevealOverlay extends StatelessWidget {
  final GameState game;
  final VoidCallback onContinue;

  const TurnOrderRevealOverlay({
    required this.game,
    required this.onContinue,
  });

  static const _placeLabels = [
    '1st',
    '2nd',
    '3rd',
    '4th',
    '5th',
    '6th',
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    final order = game.turnOrder;
    final firstId = order.isNotEmpty ? order.first : null;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: LayoutTokens.gr4,
          vertical: LayoutTokens.gr3,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.emoji_events, size: 44, color: colors.emphasis),
              const SizedBox(height: LayoutTokens.gr3),
              Text(
                'Turn Order',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: LayoutTokens.gr1),
              Text(
                'Highest roll leads — play proceeds in this order.',
                style: TextStyle(color: colors.textSecondary, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: LayoutTokens.gr5),
              ...List.generate(order.length, (index) {
                final playerId = order[index];
                final player = game.playerById(playerId);
                final label = index < _placeLabels.length
                    ? _placeLabels[index]
                    : '${index + 1}';
                final isFirst = playerId == firstId;
                final isLocal = playerId == game.localPlayerId;
                final roll = game.firstPlayerRolls[playerId];
                return _TurnOrderSlotCard(
                  placeLabel: label,
                  username: player?.username ?? playerId,
                  roll: roll,
                  isFirst: isFirst,
                  isLocal: isLocal,
                  accent: player?.playerColor ?? colors.primaryAccent,
                );
              }),
              const SizedBox(height: LayoutTokens.gr5),
              FilledButton(
                onPressed: onContinue,
                child: const Text('Start game'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TurnOrderSlotCard extends StatelessWidget {
  final String placeLabel;
  final String username;
  final int? roll;
  final bool isFirst;
  final bool isLocal;
  final Color accent;

  const _TurnOrderSlotCard({
    required this.placeLabel,
    required this.username,
    required this.roll,
    required this.isFirst,
    required this.isLocal,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    return Container(
      margin: const EdgeInsets.only(bottom: LayoutTokens.gr2),
      padding: const EdgeInsets.symmetric(
        horizontal: LayoutTokens.gr3,
        vertical: LayoutTokens.gr2,
      ),
      decoration: BoxDecoration(
        color: isFirst
            ? colors.emphasis.withValues(alpha: 0.12)
            : colors.surface,
        borderRadius: RadiusTokens.radiusMd,
        border: Border.all(
          color: isFirst
              ? colors.emphasis
              : colors.borderSubtle.withValues(alpha: OpacityTokens.soft),
          width: isFirst ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.25),
              borderRadius: RadiusTokens.radiusControlSm,
            ),
            child: Text(
              placeLabel,
              style: TextStyle(
                color: colors.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: LayoutTokens.gr2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isLocal ? '$username (you)' : username,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                if (isFirst)
                  Text(
                    'Goes first',
                    style: TextStyle(
                      color: colors.emphasis,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
          if (roll != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: colors.backgroundSecondary,
                borderRadius: RadiusTokens.radiusControlSm,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.casino, size: 14, color: colors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    '$roll',
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
