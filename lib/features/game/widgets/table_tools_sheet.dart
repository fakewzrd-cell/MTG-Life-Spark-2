import 'dart:math';

import 'package:flutter/material.dart';

import '../../../shared/utils/game_haptics.dart';
import '../../../ui/tokens/font_tokens.dart';
import '../../../ui/tokens/layout_tokens.dart';
import '../../../ui/tokens/opacity_tokens.dart';
import '../../../ui/tokens/radius_tokens.dart';
import 'game_colors.dart';
import 'game_modal_chrome.dart';

/// Local-only mid-match dice / coin tools (not synced to the table).
Future<void> showTableToolsSheet(BuildContext context) {
  return showGameBottomSheet<void>(
    context: context,
    builder: (ctx) => const _TableToolsSheet(),
  );
}

enum _ToolKind { d6, d20, coin }

class _TableToolsSheet extends StatefulWidget {
  const _TableToolsSheet();

  @override
  State<_TableToolsSheet> createState() => _TableToolsSheetState();
}

class _TableToolsSheetState extends State<_TableToolsSheet> {
  final _rand = Random();
  _ToolKind _kind = _ToolKind.d6;
  int? _dieResult;
  bool? _coinHeads;

  void _roll() {
    context.gameHapticMedium();
    setState(() {
      switch (_kind) {
        case _ToolKind.d6:
          _dieResult = _rand.nextInt(6) + 1;
          _coinHeads = null;
        case _ToolKind.d20:
          _dieResult = _rand.nextInt(20) + 1;
          _coinHeads = null;
        case _ToolKind.coin:
          _coinHeads = _rand.nextBool();
          _dieResult = null;
      }
    });
  }

  void _select(_ToolKind kind) {
    if (_kind == kind) return;
    context.gameHapticSelection();
    setState(() {
      _kind = kind;
      _dieResult = null;
      _coinHeads = null;
    });
  }

  String get _actionLabel => switch (_kind) {
        _ToolKind.d6 => 'Roll d6',
        _ToolKind.d20 => 'Roll d20',
        _ToolKind.coin => 'Flip coin',
      };

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    return GameSheetBody(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const GameSheetHeader(
            title: 'Tools',
            subtitle: 'Local only — others at the table do not see this roll.',
          ),
          SizedBox(height: LayoutTokens.gr3),
          Row(
            children: [
              Expanded(
                child: _ToolChip(
                  label: 'd6',
                  selected: _kind == _ToolKind.d6,
                  onTap: () => _select(_ToolKind.d6),
                ),
              ),
              SizedBox(width: LayoutTokens.gr1),
              Expanded(
                child: _ToolChip(
                  label: 'd20',
                  selected: _kind == _ToolKind.d20,
                  onTap: () => _select(_ToolKind.d20),
                ),
              ),
              SizedBox(width: LayoutTokens.gr1),
              Expanded(
                child: _ToolChip(
                  label: 'Coin',
                  selected: _kind == _ToolKind.coin,
                  onTap: () => _select(_ToolKind.coin),
                ),
              ),
            ],
          ),
          SizedBox(height: LayoutTokens.gr4),
          SizedBox(
            height: 120,
            child: Center(
              child: _ResultDisplay(
                kind: _kind,
                dieResult: _dieResult,
                coinHeads: _coinHeads,
              ),
            ),
          ),
          SizedBox(height: LayoutTokens.gr3),
          SizedBox(
            height: LayoutTokens.minTapTarget + 8,
            width: double.infinity,
            child: FilledButton(
              onPressed: _roll,
              style: FilledButton.styleFrom(
                backgroundColor: colors.primaryAccent,
                foregroundColor: colors.onAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: RadiusTokens.radiusControlSm,
                ),
              ),
              child: Text(
                _dieResult == null && _coinHeads == null
                    ? _actionLabel
                    : 'Again',
                style: TextStyle(
                  fontSize: FontTokens.title,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          SizedBox(height: LayoutTokens.gr1),
        ],
      ),
    );
  }
}

class _ToolChip extends StatelessWidget {
  const _ToolChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    return Material(
      color: selected
          ? colors.primaryAccent.withValues(alpha: OpacityTokens.soft)
          : colors.backgroundSecondary.withValues(alpha: 0.55),
      borderRadius: RadiusTokens.radiusControlSm,
      child: InkWell(
        onTap: onTap,
        borderRadius: RadiusTokens.radiusControlSm,
        child: SizedBox(
          height: LayoutTokens.minTapTarget,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? colors.primaryAccent : colors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: FontTokens.body,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultDisplay extends StatelessWidget {
  const _ResultDisplay({
    required this.kind,
    required this.dieResult,
    required this.coinHeads,
  });

  final _ToolKind kind;
  final int? dieResult;
  final bool? coinHeads;

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    if (kind == _ToolKind.coin) {
      if (coinHeads == null) {
        return Text(
          'Tap Flip coin',
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: FontTokens.body,
            fontWeight: FontWeight.w600,
          ),
        );
      }
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            coinHeads! ? Icons.circle : Icons.monetization_on_outlined,
            size: 48,
            color: colors.primaryAccent,
          ),
          SizedBox(height: LayoutTokens.gr2),
          Text(
            coinHeads! ? 'Heads' : 'Tails',
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: FontTokens.displayCommander,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
        ],
      );
    }

    if (dieResult == null) {
      return Text(
        kind == _ToolKind.d6 ? 'Tap Roll d6' : 'Tap Roll d20',
        style: TextStyle(
          color: colors.textSecondary,
          fontSize: FontTokens.body,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    if (kind == _ToolKind.d6) {
      return _D6Face(value: dieResult!);
    }

    return Text(
      '$dieResult',
      style: TextStyle(
        color: colors.textPrimary,
        fontSize: 64,
        fontWeight: FontWeight.w800,
        height: 1,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}

class _D6Face extends StatelessWidget {
  const _D6Face({required this.value});

  final int value;

  static const _pips = <int, List<List<bool>>>{
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
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    final face = _pips[value]!;
    return Container(
      width: 88,
      height: 88,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.backgroundSecondary,
        borderRadius: RadiusTokens.radiusMd,
        border: Border.all(
          color: colors.primaryAccent.withValues(alpha: 0.45),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          for (final row in face)
            Expanded(
              child: Row(
                children: [
                  for (final on in row)
                    Expanded(
                      child: Center(
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: on
                                ? colors.textPrimary
                                : Colors.transparent,
                          ),
                        ),
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
