import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../debug/session_agent_log.dart';
import '../../../core/game/gameplay_dial_ids.dart';
import '../../../core/game/player_game_state.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/game_icon.dart';
import '../../../ui/tokens/layout_tokens.dart';
import 'counter_adjust_sheet.dart';

const int _kDialWheelMax = 60;

/// Max counter pills per row on phones (fits ~4 columns with gutters).
const int _kPillsPerRow = 4;

/// Responsive pill geometry — scales down on narrow phones so the strip doesn’t dominate the Play tab.
class _DialMetrics {
  const _DialMetrics({
    required this.headerHeight,
    required this.stepTapHeight,
    required this.wheelHeight,
    required this.itemExtent,
    required this.leadingSize,
    required this.stepIconSize,
    required this.wheelFontSize,
    required this.headerFontSize,
    required this.addIconSize,
    required this.prolifIconSize,
    required this.prolifFontSize,
  });

  final double headerHeight;
  final double stepTapHeight;
  final double wheelHeight;
  final double itemExtent;
  final double leadingSize;
  final double stepIconSize;
  final double wheelFontSize;
  final double headerFontSize;
  final double addIconSize;
  final double prolifIconSize;
  final double prolifFontSize;

  double get outerHeight =>
      headerHeight + 1 + stepTapHeight + wheelHeight + stepTapHeight;

  /// [shortestSide] = `MediaQuery.sizeOf(context).shortestSide`
  factory _DialMetrics.scale(double shortestSide) {
    final t = ((shortestSide - 300) / 180).clamp(0.0, 1.0);
    double lerp(double a, double b) => a + (b - a) * t;
    return _DialMetrics(
      headerHeight: lerp(22, 28),
      stepTapHeight: lerp(36, 42),
      wheelHeight: lerp(64, 84),
      itemExtent: lerp(18, 22),
      leadingSize: lerp(13, 16),
      stepIconSize: lerp(18, 22),
      wheelFontSize: lerp(13, 15.5),
      headerFontSize: lerp(9.25, 10.75),
      addIconSize: lerp(22, 29),
      prolifIconSize: lerp(16, 20),
      prolifFontSize: lerp(10, 12),
    );
  }
}

// #region agent log
void _agentDbgDialStrip(
  String hypothesisId,
  String location,
  String message,
  Map<String, Object?> data,
) {
  appendSessionNdjson({
    'sessionId': '02a8f6',
    'hypothesisId': hypothesisId,
    'location': location,
    'message': message,
    'data': data,
    'timestamp': DateTime.now().millisecondsSinceEpoch,
  });
}
// #endregion

String? _dbgLastDialStripSig;

/// Modular preset + custom counters with vertical wheel scrolling per dial.
///
/// Only dials listed on [PlayerGameState.visibleGameplayDials] render on the
/// strip; use **Add** to pick core/preset/custom trackers as needed.
class GameplayDialsStripWidget extends StatelessWidget {
  final PlayerGameState player;
  final bool isEliminated;
  final void Function(String field, int delta) onAdjustCounter;
  final void Function(String field, int absoluteValue) onSetCounterAbsolute;
  final VoidCallback onProliferate;
  final void Function(String dialKey, String label) onRegisterCustomDial;
  final void Function(String field) onAddDialToStrip;
  final void Function(String field) onRemoveDialFromStrip;

  const GameplayDialsStripWidget({
    super.key,
    required this.player,
    required this.isEliminated,
    required this.onAdjustCounter,
    required this.onSetCounterAbsolute,
    required this.onProliferate,
    required this.onRegisterCustomDial,
    required this.onAddDialToStrip,
    required this.onRemoveDialFromStrip,
  });

  static const Set<String> _coreFields = {
    'poison',
    'energy',
    'experience',
    'rad',
  };

  static IconData _iconForField(String field) {
    return switch (field) {
      'poison' => Icons.coronavirus_outlined,
      'energy' => Icons.bolt_rounded,
      'experience' => Icons.auto_graph_rounded,
      'rad' => Icons.warning_amber_rounded,
      GameplayDialIds.blood => Icons.water_drop_rounded,
      GameplayDialIds.clue => Icons.search_rounded,
      GameplayDialIds.map => Icons.map_rounded,
      GameplayDialIds.treasure => Icons.stars_rounded,
      GameplayDialIds.devotion => Icons.auto_awesome_rounded,
      GameplayDialIds.creatures => Icons.pets_rounded,
      GameplayDialIds.enchantments => Icons.auto_fix_high_rounded,
      GameplayDialIds.artifacts => Icons.handyman_rounded,
      GameplayDialIds.graveyardCreatures => Icons.layers_rounded,
      GameplayDialIds.exile => Icons.output_rounded,
      _ => Icons.tune_rounded,
    };
  }

  static Widget _leadingGlyph(String field, double size) {
    return switch (field) {
      'poison' => GameIcon.poison(size: size, color: AppTheme.success),
      'energy' => GameIcon.energy(size: size, color: AppTheme.accentGold),
      'experience' => GameIcon.experience(
        size: size,
        color: const Color(0xFF9C7AFF),
      ),
      'rad' => GameIcon.radiation(size: size, color: const Color(0xFF66FF66)),
      _ => Icon(
        _iconForField(field),
        size: size,
        color: AppTheme.textSecondary.withValues(alpha: 0.95),
      ),
    };
  }

  static String _labelFor(PlayerGameState p, String field) {
    switch (field) {
      case 'poison':
        return 'Poison';
      case 'energy':
        return 'Energy';
      case 'experience':
        return 'Exp';
      case 'rad':
        return 'Rad';
      default:
        return p.customDialLabels[field] ??
            switch (field) {
              GameplayDialIds.blood => 'Blood',
              GameplayDialIds.clue => 'Clue',
              GameplayDialIds.map => 'Map',
              GameplayDialIds.treasure => 'Treasure',
              GameplayDialIds.devotion => 'Devotion',
              GameplayDialIds.creatures => 'Creatures',
              GameplayDialIds.enchantments => 'Enchant',
              GameplayDialIds.artifacts => 'Artifacts',
              GameplayDialIds.graveyardCreatures => 'GY',
              GameplayDialIds.exile => 'Exile',
              _ => field,
            };
    }
  }

  static int _valueOf(PlayerGameState p, String field) => switch (field) {
    'poison' => p.poison,
    'energy' => p.energy,
    'experience' => p.experience,
    'rad' => p.rad,
    _ => p.extraDials[field] ?? 0,
  };

  static bool _fieldKnown(PlayerGameState p, String field) =>
      _coreFields.contains(field) ||
      GameplayDialIds.presets.contains(field) ||
      p.customDialLabels.containsKey(field);

  List<String> _orderedStripFields() {
    final seen = <String>{};
    final out = <String>[];
    for (final f in player.visibleGameplayDials) {
      if (_fieldKnown(player, f) && seen.add(f)) {
        out.add(f);
      }
    }
    return out;
  }

  void _showAdjust(
    BuildContext context,
    String field,
    String title,
    int current,
  ) {
    if (isEliminated) return;
    showCounterAdjustSheet(
      context,
      title: title,
      current: current,
      onChanged: (delta) => onAdjustCounter(field, delta),
    );
  }

  Future<void> _promptCustomDial(BuildContext context) async {
    if (isEliminated) return;
    final keyCtl = TextEditingController();
    final labelCtl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: AppTheme.card,
            title: const Text(
              'Custom dial',
              style: TextStyle(color: AppTheme.textPrimary),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: keyCtl,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Id (letters/numbers)',
                    labelStyle: TextStyle(color: AppTheme.textSecondary),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: labelCtl,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Label',
                    labelStyle: TextStyle(color: AppTheme.textSecondary),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Add'),
              ),
            ],
          ),
    );
    if (ok == true && context.mounted) {
      onRegisterCustomDial(keyCtl.text, labelCtl.text);
    }
    keyCtl.dispose();
    labelCtl.dispose();
  }

  Future<void> _showAddChooser(BuildContext context) async {
    if (isEliminated) return;
    final visible = player.visibleGameplayDials.toSet();
    final coreOrdered = ['poison', 'energy', 'experience', 'rad'];

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) {
        void pick(String field) {
          Navigator.pop(sheetCtx);
          onAddDialToStrip(field);
        }

        final bottomPad = MediaQuery.paddingOf(sheetCtx).bottom;
        Widget section(String title, List<String> ids) {
          final choices = ids
              .where((id) => !visible.contains(id))
              .toList(growable: false);
          if (choices.isEmpty) return const SizedBox.shrink();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  LayoutTokens.gr3,
                  LayoutTokens.gr2,
                  LayoutTokens.gr3,
                  LayoutTokens.gr1,
                ),
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                    color: AppTheme.textSecondary.withValues(alpha: 0.75),
                  ),
                ),
              ),
              ...choices.map(
                (id) => ListTile(
                  leading: SizedBox(
                    width: 36,
                    child: Center(child: _leadingGlyph(id, 18)),
                  ),
                  title: Text(
                    _labelFor(player, id),
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () => pick(id),
                ),
              ),
            ],
          );
        }

        final addableBuiltIn =
            [
              ...coreOrdered,
              ...GameplayDialIds.presets,
            ].where((id) => !visible.contains(id)).length;

        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(bottom: bottomPad + LayoutTokens.gr2),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: LayoutTokens.gr2),
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.textSecondary.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      LayoutTokens.gr3,
                      LayoutTokens.gr3,
                      LayoutTokens.gr3,
                      LayoutTokens.gr1,
                    ),
                    child: const Text(
                      'Add counter',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: LayoutTokens.gr3),
                    child: Text(
                      'Pick trackers for your strip. Long-press the counter title inside a pill to remove it.',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.35,
                        color: AppTheme.textSecondary.withValues(alpha: 0.88),
                      ),
                    ),
                  ),
                  SizedBox(height: LayoutTokens.gr2),
                  section('Common', coreOrdered),
                  section('Tokens & zones', [...GameplayDialIds.presets]),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      LayoutTokens.gr3,
                      LayoutTokens.gr2,
                      LayoutTokens.gr3,
                      0,
                    ),
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        Navigator.pop(sheetCtx);
                        await _promptCustomDial(context);
                      },
                      icon: Icon(
                        Icons.edit_note_rounded,
                        color: AppTheme.accent,
                      ),
                      label: Text(
                        'Custom dial…',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.accent,
                        ),
                      ),
                    ),
                  ),
                  if (addableBuiltIn == 0)
                    Padding(
                      padding: EdgeInsets.all(LayoutTokens.gr3),
                      child: Text(
                        'Every built-in counter is already on your strip. '
                        'Use Custom dial for anything else.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary.withValues(alpha: 0.75),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmRemove(BuildContext context, String field) async {
    if (isEliminated) return;
    final label = _labelFor(player, field);
    final ok = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: AppTheme.card,
            title: Text(
              'Remove $label?',
              style: const TextStyle(color: AppTheme.textPrimary),
            ),
            content: Text(
              'The counter stays at its current value; it only disappears from your strip.',
              style: TextStyle(
                color: AppTheme.textSecondary.withValues(alpha: 0.9),
                fontSize: 14,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text('Remove', style: TextStyle(color: AppTheme.accent)),
              ),
            ],
          ),
    );
    if (ok == true && context.mounted) {
      onRemoveDialFromStrip(field);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fields = _orderedStripFields();

    return LayoutBuilder(
      builder: (context, constraints) {
        final shortest = math.min(
          MediaQuery.sizeOf(context).shortestSide,
          constraints.maxWidth,
        );
        final metrics = _DialMetrics.scale(shortest);

        return Padding(
          padding: EdgeInsets.symmetric(vertical: LayoutTokens.gr1),
          child: LayoutBuilder(
            builder: (context, innerConstraints) {
              final gap = LayoutTokens.gr1;
              final rowContentW = innerConstraints.maxWidth;

              var cols = _kPillsPerRow;
              late double pillW;
              while (true) {
                pillW = (rowContentW - gap * (cols - 1)) / cols;
                if (pillW >= 46 || cols <= 2) {
                  pillW = math.max(pillW, 40.0);
                  break;
                }
                cols--;
              }

              final sig =
                  '${shortest.toStringAsFixed(1)}_${metrics.outerHeight.toStringAsFixed(1)}_${pillW.toStringAsFixed(1)}';
              if (_dbgLastDialStripSig != sig) {
                _dbgLastDialStripSig = sig;
                // #region agent log
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _agentDbgDialStrip(
                    'H1',
                    'gameplay_dials_strip_widget.dart:LayoutBuilder',
                    'dial_strip_metrics',
                    {
                      'shortestUsed': shortest,
                      'mqShortest': MediaQuery.sizeOf(context).shortestSide,
                      'innerMaxW': rowContentW,
                      'pillW': pillW,
                      'outerHeight': metrics.outerHeight,
                      'wheelHeight': metrics.wheelHeight,
                    },
                  );
                });
                // #endregion
              }

              final children = <Widget>[
                for (final field in fields)
                  SizedBox(
                    width: pillW,
                    height: metrics.outerHeight,
                    child: _GameplayDialPill(
                      metrics: metrics,
                      field: field,
                      label: _labelFor(player, field),
                      value: _valueOf(player, field).clamp(0, 9999),
                      leading: _leadingGlyph(field, metrics.leadingSize),
                      width: pillW,
                      isEliminated: isEliminated,
                      onStep: (d) => onAdjustCounter(field, d),
                      onSetAbsolute:
                          (v) => onSetCounterAbsolute(field, v.clamp(0, 9999)),
                      onTapHeader:
                          () => _showAdjust(
                            context,
                            field,
                            '${_labelFor(player, field)} counters',
                            _valueOf(player, field),
                          ),
                      onLongPressHeader: () => _confirmRemove(context, field),
                    ),
                  ),
                SizedBox(
                  width: pillW,
                  height: metrics.outerHeight,
                  child: _ProliferatePillTile(
                    metrics: metrics,
                    width: pillW,
                    isEliminated: isEliminated,
                    onTap: onProliferate,
                  ),
                ),
                SizedBox(
                  width: pillW,
                  height: metrics.outerHeight,
                  child: _AddCounterPillTile(
                    metrics: metrics,
                    width: pillW,
                    isEliminated: isEliminated,
                    onTap: () => _showAddChooser(context),
                  ),
                ),
              ];

              return SingleChildScrollView(
                child: SizedBox(
                  width: rowContentW,
                  child: Wrap(
                    spacing: gap,
                    runSpacing: gap,
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.start,
                    children: children,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

/// Proliferate as a pill matching counter tile size.
class _ProliferatePillTile extends StatelessWidget {
  final _DialMetrics metrics;
  final double width;
  final bool isEliminated;
  final VoidCallback onTap;

  const _ProliferatePillTile({
    required this.metrics,
    required this.width,
    required this.isEliminated,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Proliferate',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEliminated ? null : onTap,
          borderRadius: BorderRadius.circular(999),
          child: Ink(
            width: width,
            height: metrics.outerHeight,
            decoration: BoxDecoration(
              color: AppTheme.card.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color:
                    isEliminated
                        ? AppTheme.textSecondary.withValues(alpha: 0.25)
                        : AppTheme.accent.withValues(alpha: 0.55),
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.coronavirus_outlined,
                    size: metrics.prolifIconSize,
                    color:
                        isEliminated ? AppTheme.textSecondary : AppTheme.accent,
                  ),
                  SizedBox(height: metrics.prolifFontSize > 11 ? 5 : 4),
                  Text(
                    '+1 All',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: metrics.prolifFontSize,
                      fontWeight: FontWeight.w800,
                      color:
                          isEliminated
                              ? AppTheme.textSecondary
                              : AppTheme.accent,
                    ),
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

class _AddCounterPillTile extends StatelessWidget {
  final _DialMetrics metrics;
  final double width;
  final bool isEliminated;
  final VoidCallback onTap;

  const _AddCounterPillTile({
    required this.metrics,
    required this.width,
    required this.isEliminated,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Add counter',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEliminated ? null : onTap,
          borderRadius: BorderRadius.circular(999),
          child: Ink(
            width: width,
            height: metrics.outerHeight,
            decoration: BoxDecoration(
              color: AppTheme.card.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: AppTheme.accent.withValues(alpha: 0.45),
              ),
            ),
            child: Center(
              child: Icon(
                Icons.add_rounded,
                size: metrics.addIconSize,
                color: isEliminated ? AppTheme.textSecondary : AppTheme.accent,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GameplayDialPill extends StatefulWidget {
  final _DialMetrics metrics;
  final String field;
  final String label;
  final int value;
  final Widget leading;
  final double width;
  final bool isEliminated;
  final void Function(int delta) onStep;
  final void Function(int absolute) onSetAbsolute;
  final VoidCallback onTapHeader;
  final VoidCallback onLongPressHeader;

  const _GameplayDialPill({
    required this.metrics,
    required this.field,
    required this.label,
    required this.value,
    required this.leading,
    required this.width,
    required this.isEliminated,
    required this.onStep,
    required this.onSetAbsolute,
    required this.onTapHeader,
    required this.onLongPressHeader,
  });

  @override
  State<_GameplayDialPill> createState() => _GameplayDialPillState();
}

class _GameplayDialPillState extends State<_GameplayDialPill> {
  late FixedExtentScrollController _ctrl;
  bool _dragging = false;

  int get _clampedValue => widget.value.clamp(0, _kDialWheelMax);

  @override
  void initState() {
    super.initState();
    _ctrl = FixedExtentScrollController(initialItem: _clampedValue);
  }

  @override
  void didUpdateWidget(covariant _GameplayDialPill oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_dragging && oldWidget.value != widget.value && _ctrl.hasClients) {
      final i = _clampedValue;
      if (_ctrl.selectedItem != i) {
        _ctrl.jumpToItem(i);
      }
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dim = widget.isEliminated;
    final borderColor = AppTheme.surface.withValues(alpha: 0.65);

    return Material(
      color: Colors.transparent,
      child: Container(
        width: widget.width,
        height: widget.metrics.outerHeight,
        decoration: BoxDecoration(
          color: AppTheme.card.withValues(alpha: dim ? 0.55 : 0.92),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final hHeader = widget.metrics.headerHeight;
              final hStep = widget.metrics.stepTapHeight;
              final wheelH = math.max(
                0.0,
                constraints.maxHeight - hHeader - 1 - 2 * hStep,
              );

              return Column(
                children: [
                  GestureDetector(
                    onTap: widget.isEliminated ? null : widget.onTapHeader,
                    onLongPress:
                        widget.isEliminated ? null : widget.onLongPressHeader,
                    child: Tooltip(
                      message: 'Long-press to remove from strip',
                      child: SizedBox(
                        height: hHeader,
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              widget.leading,
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  widget.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: widget.metrics.headerFontSize,
                                    fontWeight: FontWeight.w800,
                                    color:
                                        dim
                                            ? AppTheme.textSecondary
                                            : AppTheme.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 1,
                    color: borderColor.withValues(alpha: 0.5),
                  ),
                  _stepButton(
                    dim: dim,
                    icon: Icons.remove_rounded,
                    onTap:
                        widget.isEliminated
                            ? null
                            : () {
                              HapticFeedback.lightImpact();
                              widget.onStep(-1);
                            },
                  ),
                  SizedBox(
                    height: wheelH,
                    width: double.infinity,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.12),
                      ),
                      child: IgnorePointer(
                        ignoring: widget.isEliminated,
                        child: NotificationListener<ScrollNotification>(
                          onNotification: (n) {
                            if (widget.isEliminated) return false;
                            if (n is ScrollStartNotification) {
                              _dragging = true;
                            } else if (n is ScrollEndNotification) {
                              _dragging = false;
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (!mounted || !_ctrl.hasClients) return;
                                final t = _ctrl.selectedItem;
                                if (t != _clampedValue) {
                                  HapticFeedback.selectionClick();
                                  widget.onSetAbsolute(t);
                                }
                              });
                            }
                            return false;
                          },
                          child: ListWheelScrollView.useDelegate(
                            controller: _ctrl,
                            itemExtent: widget.metrics.itemExtent,
                            physics: const FixedExtentScrollPhysics(),
                            perspective: 0.003,
                            diameterRatio: 1.45,
                            useMagnifier: true,
                            magnification: 1.14,
                            overAndUnderCenterOpacity: 0.4,
                            onSelectedItemChanged: (_) {},
                            childDelegate: ListWheelChildBuilderDelegate(
                              childCount: _kDialWheelMax + 1,
                              builder: (c, i) {
                                return Center(
                                  child: Text(
                                    '$i',
                                    style: TextStyle(
                                      fontSize: widget.metrics.wheelFontSize,
                                      fontWeight: FontWeight.w700,
                                      color:
                                          dim
                                              ? AppTheme.textSecondary
                                              : AppTheme.textPrimary.withValues(
                                                alpha: 0.88,
                                              ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  _stepButton(
                    dim: dim,
                    icon: Icons.add_rounded,
                    onTap:
                        widget.isEliminated
                            ? null
                            : () {
                              HapticFeedback.lightImpact();
                              widget.onStep(1);
                            },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _stepButton({
    required bool dim,
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: widget.metrics.stepTapHeight,
          width: double.infinity,
          child: Center(
            child: Icon(
              icon,
              size: widget.metrics.stepIconSize,
              color: dim ? AppTheme.textSecondary : AppTheme.accent,
            ),
          ),
        ),
      ),
    );
  }
}
