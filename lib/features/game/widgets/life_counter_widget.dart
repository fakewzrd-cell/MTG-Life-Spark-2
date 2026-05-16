import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/game/commander_identity_colors.dart';
import '../../../shared/theme/app_theme.dart';

/// The main life counter — occupies the center of the personal view.
///
/// Interactions:
///   • Tap left half  → −1
///   • Tap right half → +1
///   • Hold left      → −5 repeated every 150 ms (after 500 ms threshold)
///   • Hold right     → +5 repeated every 150 ms (after 500 ms threshold)
///   • Swipe up/down  → ±1 per 28 px dragged
///   • Double-tap      → numeric input dialog
class LifeCounterWidget extends StatefulWidget {
  final int life;
  final Color playerColor;

  /// Optional WUBRG letters for halo / gradient chrome.
  final List<String> commanderColorIdentity;
  final bool isEliminated;
  final void Function(int delta) onLifeChange;

  const LifeCounterWidget({
    super.key,
    required this.life,
    required this.playerColor,
    this.commanderColorIdentity = const [],
    required this.onLifeChange,
    this.isEliminated = false,
  });

  @override
  State<LifeCounterWidget> createState() => _LifeCounterWidgetState();
}

class _LifeCounterWidgetState extends State<LifeCounterWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _deltaAnim;
  late Animation<double> _deltaFade;
  late Animation<Offset> _deltaSlide;

  int? _lastDelta;
  Timer? _holdTimer;
  bool _holding = false;

  double _dragAccum = 0;

  void _feedVerticalDrag(double dy) {
    _dragAccum -= dy;
    while (_dragAccum.abs() >= 28) {
      _change(_dragAccum > 0 ? 1 : -1);
      _dragAccum += _dragAccum > 0 ? -28 : 28;
    }
  }

  @override
  void initState() {
    super.initState();
    _deltaAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _deltaFade = CurvedAnimation(parent: _deltaAnim, curve: Curves.easeOut);
    _deltaSlide = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -1.5),
    ).animate(CurvedAnimation(parent: _deltaAnim, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _deltaAnim.dispose();
    _holdTimer?.cancel();
    super.dispose();
  }

  // ── Actions ────────────────────────────────────────────────────────────

  void _change(int delta) {
    if (widget.isEliminated) return;
    setState(() => _lastDelta = delta);
    _deltaAnim.forward(from: 0);
    widget.onLifeChange(delta);
    HapticFeedback.lightImpact();
  }

  void _startHold(int direction) {
    if (widget.isEliminated) return;
    _holding = true;
    _holdTimer = Timer(const Duration(milliseconds: 500), () {
      if (!_holding || !mounted) return;
      _change(direction * 5);
      _holdTimer = Timer.periodic(const Duration(milliseconds: 150), (_) {
        if (!_holding || !mounted) {
          _holdTimer?.cancel();
          return;
        }
        _change(direction * 5);
      });
    });
  }

  void _stopHold() {
    _holding = false;
    _holdTimer?.cancel();
    _holdTimer = null;
  }

  Future<void> _showNumberPad() async {
    if (widget.isEliminated) return;
    final result = await showDialog<int>(
      context: context,
      builder: (_) => _LifeInputDialog(currentLife: widget.life),
    );
    if (result != null && mounted) {
      final delta = result - widget.life;
      if (delta != 0) _change(delta);
    }
  }

  // ── Colors ─────────────────────────────────────────────────────────────

  Color get _lifeColor {
    if (widget.isEliminated) return AppTheme.textSecondary;
    if (widget.life <= 5) return AppTheme.textSecondary;
    return widget.playerColor;
  }

  Color get _deltaColor =>
      (_lastDelta ?? 0) > 0 ? AppTheme.success : AppTheme.textSecondary;

  // ── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final halo = CommanderIdentityColors.emphasisBorder(
          widget.commanderColorIdentity,
          widget.playerColor,
        );

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              colors: CommanderIdentityColors.gameplayGradient(
                widget.commanderColorIdentity,
                widget.playerColor,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: halo.withValues(alpha: 0.35),
                blurRadius: 18,
                spreadRadius: -2,
              ),
            ],
          ),
          padding: const EdgeInsets.all(3),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: Container(
              color: AppTheme.primary.withValues(alpha: 0.88),
              child: GestureDetector(
                onVerticalDragUpdate: (d) => _feedVerticalDrag(d.delta.dy),
                onVerticalDragEnd: (_) => _dragAccum = 0,
                onDoubleTap: widget.isEliminated ? null : _showNumberPad,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final wBody = constraints.maxWidth;
                    final hBody = constraints.maxHeight;
                    final tapHalf = wBody / 2;
                    final baseFontSize =
                        (wBody < 200 || hBody < 120)
                            ? 48.0
                            : (wBody < 280 || hBody < 150)
                            ? 64.0
                            : (widget.life.abs() >= 100 ? 80.0 : 96.0);
                    final deltaFontSize = (baseFontSize * 0.27).clamp(
                      18.0,
                      26.0,
                    );

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          width: (wBody * 0.14).clamp(36.0, 52.0),
                          child: IgnorePointer(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                for (var i = -3; i <= 3; i++)
                                  Expanded(
                                    child: Center(
                                      child: Text(
                                        '${(widget.life + i).clamp(0, 999)}',
                                        maxLines: 1,
                                        overflow: TextOverflow.fade,
                                        softWrap: false,
                                        style: TextStyle(
                                          fontSize: i == 0 ? 17 : 11,
                                          fontWeight:
                                              i == 0
                                                  ? FontWeight.w800
                                                  : FontWeight.w500,
                                          color:
                                              i == 0
                                                  ? _lifeColor.withValues(
                                                    alpha:
                                                        widget.isEliminated
                                                            ? 0.35
                                                            : 1,
                                                  )
                                                  : AppTheme.textSecondary
                                                      .withValues(alpha: 0.28),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                left: 0,
                                top: 0,
                                width: tapHalf,
                                height: hBody,
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () => _change(-1),
                                  onLongPressStart: (_) => _startHold(-1),
                                  onLongPressEnd: (_) => _stopHold(),
                                  onLongPressCancel: _stopHold,
                                  child: Container(
                                    color: Colors.transparent,
                                    alignment: Alignment.center,
                                    child: Icon(
                                      Icons.remove_rounded,
                                      size: 40,
                                      color: AppTheme.textSecondary.withValues(
                                        alpha: 0.15,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                width: tapHalf,
                                height: hBody,
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () => _change(1),
                                  onLongPressStart: (_) => _startHold(1),
                                  onLongPressEnd: (_) => _stopHold(),
                                  onLongPressCancel: _stopHold,
                                  child: Container(
                                    color: Colors.transparent,
                                    alignment: Alignment.center,
                                    child: Icon(
                                      Icons.add_rounded,
                                      size: 40,
                                      color: AppTheme.textSecondary.withValues(
                                        alpha: 0.15,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Center(
                                child: IgnorePointer(
                                  child: Stack(
                                    alignment: Alignment.center,
                                    clipBehavior: Clip.none,
                                    children: [
                                      Text(
                                        widget.isEliminated
                                            ? '☠'
                                            : '${widget.life}',
                                        style: TextStyle(
                                          fontSize: baseFontSize,
                                          fontWeight: FontWeight.w800,
                                          color: _lifeColor,
                                          letterSpacing: -3,
                                          shadows: [
                                            Shadow(
                                              color: _lifeColor.withValues(
                                                alpha: 0.4,
                                              ),
                                              blurRadius: 32,
                                              offset: const Offset(0, 2),
                                            ),
                                            Shadow(
                                              color: Colors.black.withValues(
                                                alpha: 0.2,
                                              ),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (_lastDelta != null)
                                        Positioned(
                                          top: -32,
                                          child: FadeTransition(
                                            opacity: Tween(
                                              begin: 1.0,
                                              end: 0.0,
                                            ).animate(_deltaFade),
                                            child: SlideTransition(
                                              position: _deltaSlide,
                                              child: Text(
                                                _lastDelta! > 0
                                                    ? '+$_lastDelta'
                                                    : '$_lastDelta',
                                                style: TextStyle(
                                                  fontSize: deltaFontSize,
                                                  fontWeight: FontWeight.bold,
                                                  color: _deltaColor,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Numeric input dialog ───────────────────────────────────────────────────

class _LifeInputDialog extends StatefulWidget {
  final int currentLife;
  const _LifeInputDialog({required this.currentLife});

  @override
  State<_LifeInputDialog> createState() => _LifeInputDialogState();
}

class _LifeInputDialogState extends State<_LifeInputDialog> {
  String _input = '';

  void _press(String digit) {
    if (_input.length >= 4) return;
    setState(() => _input += digit);
  }

  void _delete() {
    if (_input.isEmpty) return;
    setState(() => _input = _input.substring(0, _input.length - 1));
  }

  void _confirm() {
    final val = int.tryParse(_input);
    Navigator.pop(context, val);
  }

  Widget _key(String label, {VoidCallback? onTap}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.surface,
            foregroundColor: AppTheme.textPrimary,
            minimumSize: const Size(0, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: onTap ?? () => _press(label),
          child: Text(
            label,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.card,
      title: Text(
        _input.isEmpty ? 'Set Life Total' : _input,
        style: TextStyle(
          color: _input.isEmpty ? AppTheme.textSecondary : AppTheme.textPrimary,
          fontSize: _input.isEmpty ? 16 : 32,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
      contentPadding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final row in [
            ['1', '2', '3'],
            ['4', '5', '6'],
            ['7', '8', '9'],
            ['⌫', '0', '✓'],
          ])
            Row(
              children:
                  row.map((label) {
                    if (label == '⌫') {
                      return _key(label, onTap: _delete);
                    }
                    if (label == '✓') {
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.accent,
                              minimumSize: const Size(0, 56),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: _input.isNotEmpty ? _confirm : null,
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      );
                    }
                    return _key(label);
                  }).toList(),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancel',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
        ),
      ],
    );
  }
}
