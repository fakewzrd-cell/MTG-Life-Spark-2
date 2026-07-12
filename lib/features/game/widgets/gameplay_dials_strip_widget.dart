import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../../ui/tokens/font_tokens.dart';
import '../../../core/game/gameplay_dial_ids.dart';
import '../../../core/game/player_game_state.dart';
import 'game_colors.dart';
import '../../../ui/theme/app_color_tokens.dart';
import 'game_modal_chrome.dart';
import '../../../shared/widgets/game_icon.dart';
import '../../../shared/utils/game_haptics.dart';
import '../../../ui/tokens/layout_tokens.dart';
import '../../../ui/tokens/motion_tokens.dart';
import '../../../ui/tokens/radius_tokens.dart';
import 'counter_adjust_sheet.dart';

const int _kDialWheelMax = 999;

/// Max counter pills per row on phones (fits ~4 columns with gutters).
const int _kPillsPerRow = 4;

/// Counter dial / action tiles — modest rounding (not stadium pills).
const double _kDialPillCornerRadius = RadiusTokens.controlSm;

/// Responsive pill geometry — scales down on narrow phones so the strip doesn’t dominate the Play tab.
class _DialMetrics {
  const _DialMetrics({
    required this.pillHeaderHeight,
    required this.stepTapHeight,
    required this.wheelHeight,
    required this.itemExtent,
    required this.leadingSize,
    required this.stepIconSize,
    required this.wheelFontSize,
    required this.addIconSize,
  });

  /// Icon row inside the pill top edge.
  final double pillHeaderHeight;
  final double stepTapHeight;
  final double wheelHeight;
  final double itemExtent;
  final double leadingSize;
  final double stepIconSize;
  final double wheelFontSize;
  final double addIconSize;

  /// Steppers + wheel below the in-pill header.
  double get pillBodyHeight => stepTapHeight + wheelHeight + stepTapHeight;

  /// Full counter tile height (single bordered pill).
  double get tileStackHeight => pillHeaderHeight + pillBodyHeight;

  /// [shortestSide] = `MediaQuery.sizeOf(context).shortestSide`
  /// [compactVertical] shrinks step/wheel bands when Play tab height is tight.
  factory _DialMetrics.scale(
    double shortestSide, {
    bool compactVertical = false,
  }) {
    if (compactVertical) {
      return const _DialMetrics(
        pillHeaderHeight: 36,
        stepTapHeight: 40,
        wheelHeight: 44,
        itemExtent: 20,
        leadingSize: 16,
        stepIconSize: 20,
        wheelFontSize: 14,
        addIconSize: 22,
      );
    }
    final t = ((shortestSide - 300) / 180).clamp(0.0, 1.0);
    double lerp(double a, double b) => a + (b - a) * t;
    double r4(double x) => (x / 4).round() * 4.0;
    return _DialMetrics(
      pillHeaderHeight: r4(lerp(40, 44)),
      stepTapHeight: LayoutTokens.minTapTarget,
      wheelHeight: r4(lerp(48, 64)),
      itemExtent: r4(lerp(20, 24)),
      leadingSize: r4(lerp(16, 20)),
      stepIconSize: r4(lerp(20, 24)),
      wheelFontSize: r4(lerp(14, 16)),
      addIconSize: r4(lerp(22, 26)),
    );
  }
}

/// Modular preset + custom counters with vertical wheel scrolling per dial.
///
/// Only dials listed on [PlayerGameState.visibleGameplayDials] render on the
/// strip; use **Add** to pick core/preset/custom trackers as needed.
class GameplayDialsStripWidget extends StatelessWidget {
  final PlayerGameState Function() getPlayer;
  final bool isEliminated;
  final void Function(String field, int delta) onAdjustCounter;
  final void Function(String field, int absoluteValue) onSetCounterAbsolute;
  final bool Function(String dialKey, String label) onRegisterCustomDial;
  final bool Function(String field) onAddDialToStrip;
  final void Function(String field) onRemoveDialFromStrip;

  const GameplayDialsStripWidget({
    super.key,
    required this.getPlayer,
    required this.isEliminated,
    required this.onAdjustCounter,
    required this.onSetCounterAbsolute,
    required this.onRegisterCustomDial,
    required this.onAddDialToStrip,
    required this.onRemoveDialFromStrip,
    this.compactVertical = false,
  });

  final bool compactVertical;

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

  static Color _listIconColor(AppColorTokens colors) =>
      colors.textSecondary.withValues(alpha: 0.95);

  /// Visual scale per counter artwork so mixed aspect ratios read evenly.
  static double _glyphVisualScale(String field) => switch (field) {
    'poison' => 1.08,
    'energy' => 1.0,
    'experience' => 0.94,
    _ => 1.0,
  };

  /// Counter artwork accepts [tintColor]; strip/list default to secondary text.
  static Widget _leadingGlyph(
    String field,
    double size,
    AppColorTokens colors, {
    Color? tintColor,
  }) {
    final tone = tintColor ?? _listIconColor(colors);
    final iconSize = size * _glyphVisualScale(field);
    return switch (field) {
      'poison' => GameIcon.poison(size: iconSize, color: tone),
      'energy' => GameIcon.energy(size: iconSize, color: tone),
      'experience' => GameIcon.experience(size: iconSize, color: tone),
      'rad' => GameIcon.radiation(size: iconSize, color: tone),
      GameplayDialIds.treasure => GameIcon.treasure(size: iconSize, color: tone),
      _ => Icon(_iconForField(field), size: iconSize, color: tone),
    };
  }

  PlayerGameState get player => getPlayer();

  static void _showStripLimitSnack(BuildContext context, {bool custom = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          custom
              ? 'You can have up to ${GameplayDialIds.maxCustomDials} custom counters '
                  'and ${GameplayDialIds.maxStripDials} counters total on your strip. '
                  'Remove one to add another.'
              : 'Your strip holds up to ${GameplayDialIds.maxStripDials} counters. '
                  'Remove one to add another.',
        ),
      ),
    );
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

  /// Strip dial tiles shown (same ordering as the strip widget).
  static int orderedStripFieldCount(PlayerGameState p) {
    final seen = <String>{};
    var n = 0;
    for (final f in p.visibleGameplayDials) {
      if (_fieldKnown(p, f) && seen.add(f)) n++;
    }
    return n;
  }

  /// Dial strip is always a single row (max 4 pills + optional Add).
  static int dialStripRowCount() => 1;

  /// Approximate vertical space for the dial row (planning Play tab layout).
  static double estimatedStripHeight(
    BuildContext context, {
    bool compactVertical = false,
    bool hasVisibleDials = true,
  }) {
    if (!hasVisibleDials) return 0;
    final shortest = MediaQuery.sizeOf(context).shortestSide;
    final metrics = _DialMetrics.scale(
      shortest,
      compactVertical: compactVertical,
    );
    return metrics.tileStackHeight + LayoutTokens.gr1;
  }

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
    final isCustom = getPlayer().customDialLabels.containsKey(field);
    showCounterAdjustSheet(
      context,
      title: title,
      current: current,
      confirmReset: !isCustom,
      onChanged: (delta) => onAdjustCounter(field, delta),
    );
  }

  Future<void> _promptCustomDial(BuildContext context) async {
    if (isEliminated) return;
    if (!GameplayDialLimits.canAddCustomDial(getPlayer())) {
      _showStripLimitSnack(context, custom: true);
      return;
    }
    final keyCtl = TextEditingController();
    final labelCtl = TextEditingController();
    final dialogColors = context.gameColors;
    final ok = await showGameChoiceDialog(
      context: context,
      title: 'Custom dial',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: keyCtl,
            style: TextStyle(color: dialogColors.textPrimary),
            decoration: InputDecoration(
              labelText: 'Id (letters/numbers)',
              labelStyle: TextStyle(color: dialogColors.textSecondary),
            ),
          ),
          SizedBox(height: LayoutTokens.gr2),
          TextField(
            controller: labelCtl,
            style: TextStyle(color: dialogColors.textPrimary),
            decoration: InputDecoration(
              labelText: 'Label',
              labelStyle: TextStyle(color: dialogColors.textSecondary),
            ),
          ),
        ],
      ),
      primaryLabel: 'Add',
    );
    if (ok == true && context.mounted) {
      final added = onRegisterCustomDial(keyCtl.text, labelCtl.text);
      if (!added && context.mounted) {
        _showStripLimitSnack(context, custom: true);
      }
    }
    keyCtl.dispose();
    labelCtl.dispose();
  }

  Future<void> _showAddChooser(BuildContext context) async {
    if (isEliminated) return;
    if (!GameplayDialLimits.canAddDialToStrip(getPlayer())) {
      _showStripLimitSnack(context);
      return;
    }
    final visible = getPlayer().visibleGameplayDials.toSet();
    final coreOrdered = ['poison', 'energy', 'experience', 'rad'];

    await showGameBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        void pick(String field) {
          final added = onAddDialToStrip(field);
          Navigator.pop(sheetCtx);
          if (!added && context.mounted) {
            _showStripLimitSnack(context);
          }
        }

        final livePlayer = getPlayer();
        final canAddCustom = GameplayDialLimits.canAddCustomDial(livePlayer);

        return _AddCounterSheetScaffold(
          player: livePlayer,
          visible: visible,
          coreOrdered: coreOrdered,
          onPick: pick,
          onCustomDial: canAddCustom
              ? () async {
                  Navigator.pop(sheetCtx);
                  await _promptCustomDial(context);
                }
              : null,
        );
      },
    );
  }

  Future<void> _confirmRemove(BuildContext context, String field) async {
    if (isEliminated) return;
    final label = _labelFor(player, field);
    final ok = await showGameConfirmDialog(
      context: context,
      title: 'Remove $label?',
      message:
          'The counter stays at its current value; it only disappears from your strip.',
      confirmLabel: 'Remove',
      destructive: true,
    );
    if (ok == true && context.mounted) {
      onRemoveDialFromStrip(field);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    final fields = _orderedStripFields();

    return LayoutBuilder(
      builder: (context, constraints) {
        final shortest = math.min(
          MediaQuery.sizeOf(context).shortestSide,
          constraints.maxWidth,
        );
        final metrics = _DialMetrics.scale(
          shortest,
          compactVertical: compactVertical,
        );

        return Padding(
          padding: EdgeInsets.only(top: LayoutTokens.gr1, bottom: LayoutTokens.gr0),
          child: LayoutBuilder(
            builder: (context, innerConstraints) {
              final gap = LayoutTokens.gr1;
              final rowContentW = innerConstraints.maxWidth;

              final livePlayer = getPlayer();
              final showAddButton = GameplayDialLimits.showAddCounterTile(
                livePlayer,
                isEliminated: isEliminated,
              );
              // The strip is always a single row and never holds more than
              // maxStripDials (4) slots total (the Add tile only shows while
              // the strip has room), so `slots` must always equal the actual
              // number of rendered children — never a narrower assumption,
              // or pills get sized for fewer slots than are actually drawn
              // and the row overflows past the screen edge.
              final slotCount = fields.length + (showAddButton ? 1 : 0);
              final slots = math.max(1, math.min(slotCount, _kPillsPerRow));
              var pillW = (rowContentW - gap * (slots - 1)) / slots;
              pillW = math.max(pillW, 40.0);

              final rowChildren = <Widget>[
                for (var i = 0; i < fields.length; i++) ...[
                  if (i > 0) SizedBox(width: gap),
                  Builder(
                    builder: (context) {
                      final field = fields[i];
                      return SizedBox(
                        width: pillW,
                        height: metrics.tileStackHeight,
                        child: _GameplayDialPill(
                          metrics: metrics,
                          value: _valueOf(livePlayer, field).clamp(
                            0,
                            9999,
                          ),
                          width: pillW,
                          isEliminated: isEliminated,
                          tooltip:
                              '${_labelFor(livePlayer, field)} — tap to adjust, long-press to remove',
                          headerLeading: _leadingGlyph(
                            field,
                            metrics.leadingSize,
                            colors,
                          ),
                          onHeaderTap:
                              isEliminated
                                  ? null
                                  : () => _showAdjust(
                                    context,
                                    field,
                                    '${_labelFor(livePlayer, field)} counters',
                                    _valueOf(livePlayer, field),
                                  ),
                          onHeaderLongPress:
                              isEliminated
                                  ? null
                                  : () => _confirmRemove(context, field),
                          onStep: (d) => onAdjustCounter(field, d),
                          onSetAbsolute:
                              (v) => onSetCounterAbsolute(
                                field,
                                v.clamp(0, 9999),
                              ),
                        ),
                      );
                    },
                  ),
                ],
                if (showAddButton) ...[
                  if (fields.isNotEmpty) SizedBox(width: gap),
                  SizedBox(
                    width: pillW,
                    height: metrics.tileStackHeight,
                    child: _AddCounterPillTile(
                      metrics: metrics,
                      width: pillW,
                      isEliminated: isEliminated,
                      onTap: () => _showAddChooser(context),
                    ),
                  ),
                ],
              ];

              return SizedBox(
                width: rowContentW,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: rowChildren,
                ),
              );
            },
          ),
        );
      },
    );
  }
}

/// Draggable add-counter sheet — drag the handle or pull down to dismiss.
class _AddCounterSheetScaffold extends StatefulWidget {
  const _AddCounterSheetScaffold({
    required this.player,
    required this.visible,
    required this.coreOrdered,
    required this.onPick,
    this.onCustomDial,
  });

  final PlayerGameState player;
  final Set<String> visible;
  final List<String> coreOrdered;
  final void Function(String field) onPick;
  final Future<void> Function()? onCustomDial;

  @override
  State<_AddCounterSheetScaffold> createState() => _AddCounterSheetScaffoldState();
}

class _AddCounterSheetScaffoldState extends State<_AddCounterSheetScaffold> {
  /// Pop once the user drags the sheet below this fraction of the viewport.
  static const _dismissExtent = 0.22;

  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  bool _dismissing = false;

  @override
  void initState() {
    super.initState();
    _sheetController.addListener(_onSheetSizeChanged);
  }

  @override
  void dispose() {
    _sheetController.removeListener(_onSheetSizeChanged);
    _sheetController.dispose();
    super.dispose();
  }

  void _onSheetSizeChanged() {
    if (_dismissing || !_sheetController.isAttached) return;
    if (_sheetController.size <= _dismissExtent) {
      _dismissing = true;
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    return DraggableScrollableSheet(
      controller: _sheetController,
      initialChildSize: 0.62,
      minChildSize: 0,
      maxChildSize: 0.92,
      expand: false,
      builder: (_, scrollController) => Material(
        color: colors.surface,
        borderRadius: RadiusTokens.radiusSheetTop,
        clipBehavior: Clip.antiAlias,
        child: _AddCounterChooserSheet(
          scrollController: scrollController,
          sheetExtentListenable: _sheetController,
          player: widget.player,
          visible: widget.visible,
          coreOrdered: widget.coreOrdered,
          onPick: widget.onPick,
          onCustomDial: widget.onCustomDial,
        ),
      ),
    );
  }
}

/// Scrollable add-counter list with scrollbar and bottom fade when more items exist.
class _AddCounterChooserSheet extends StatefulWidget {
  const _AddCounterChooserSheet({
    required this.scrollController,
    required this.sheetExtentListenable,
    required this.player,
    required this.visible,
    required this.coreOrdered,
    required this.onPick,
    this.onCustomDial,
  });

  final ScrollController scrollController;
  final Listenable sheetExtentListenable;
  final PlayerGameState player;
  final Set<String> visible;
  final List<String> coreOrdered;
  final void Function(String field) onPick;
  final Future<void> Function()? onCustomDial;

  @override
  State<_AddCounterChooserSheet> createState() => _AddCounterChooserSheetState();
}

class _AddCounterChooserSheetState extends State<_AddCounterChooserSheet> {
  double _bottomFadeOpacity = 0;

  ScrollPhysics get _listPhysics {
    final parent = switch (Theme.of(context).platform) {
      TargetPlatform.iOS || TargetPlatform.macOS => const BouncingScrollPhysics(),
      _ => const ClampingScrollPhysics(),
    };
    return AlwaysScrollableScrollPhysics(parent: parent);
  }

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_syncScrollAffordance);
    widget.sheetExtentListenable.addListener(_syncScrollAffordance);
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncScrollAffordance());
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_syncScrollAffordance);
    widget.sheetExtentListenable.removeListener(_syncScrollAffordance);
    super.dispose();
  }

  void _syncScrollAffordance() {
    if (!widget.scrollController.hasClients) return;
    final pos = widget.scrollController.position;
    final canScrollList = pos.maxScrollExtent > 12;
    final notAtBottom = pos.pixels < pos.maxScrollExtent - 12;
    final opacity = canScrollList && notAtBottom ? 1.0 : 0.0;
    if ((opacity - _bottomFadeOpacity).abs() > 0.02 && mounted) {
      setState(() => _bottomFadeOpacity = opacity);
    }
  }

  Widget _section(AppColorTokens colors, String title, List<String> ids) {
    final choices =
        ids.where((id) => !widget.visible.contains(id)).toList(growable: false);
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
              fontSize: FontTokens.hudXs,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
              color: colors.textSecondary.withValues(alpha: 0.75),
            ),
          ),
        ),
        ...choices.map(
          (id) => ListTile(
            leading: SizedBox(
              width: 36,
              height: 28,
              child: Center(
                child: GameplayDialsStripWidget._leadingGlyph(
                  id,
                  20,
                  colors,
                  tintColor: GameplayDialsStripWidget._listIconColor(colors),
                ),
              ),
            ),
            title: Text(
              GameplayDialsStripWidget._labelFor(widget.player, id),
              style: TextStyle(
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: () => widget.onPick(id),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    final bottomPad = MediaQuery.paddingOf(context).bottom;
    final canAddCustom = widget.onCustomDial != null;
    final addableBuiltIn =
        [
          ...widget.coreOrdered,
          ...GameplayDialIds.presets,
        ].where((id) => !widget.visible.contains(id)).length;
    final fadePad = _bottomFadeOpacity > 0.02 ? 28.0 : 0.0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Scrollbar(
          controller: widget.scrollController,
          thumbVisibility: true,
          interactive: true,
          radius: const Radius.circular(8),
          child: SingleChildScrollView(
            controller: widget.scrollController,
            physics: _listPhysics,
            padding: EdgeInsets.only(
              bottom: bottomPad + LayoutTokens.gr2 + fadePad,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    LayoutTokens.gr3,
                    LayoutTokens.gr2,
                    LayoutTokens.gr3,
                    LayoutTokens.gr1,
                  ),
                  child: const Center(child: GameSheetHandle()),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    LayoutTokens.gr3,
                    LayoutTokens.gr1,
                    LayoutTokens.gr3,
                    LayoutTokens.gr1,
                  ),
                  child: Text(
                    'Add counter',
                    style: GameModalChrome.sheetTitleStyle(context),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: LayoutTokens.gr3),
                  child: Text(
                    'Pick trackers for your strip (max ${GameplayDialIds.maxStripDials}). '
                    'Long-press a counter on the strip to remove it.',
                    style: TextStyle(
                      fontSize: FontTokens.hudSm,
                      height: 1.35,
                      color: colors.textSecondary.withValues(alpha: 0.88),
                    ),
                  ),
                ),
                SizedBox(height: LayoutTokens.gr2),
                _section(colors, 'Common', widget.coreOrdered),
                _section(colors, 'Tokens & zones', [...GameplayDialIds.presets]),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    LayoutTokens.gr3,
                    LayoutTokens.gr2,
                    LayoutTokens.gr3,
                    0,
                  ),
                  child: OutlinedButton.icon(
                    onPressed: widget.onCustomDial,
                    icon: Icon(
                      Icons.edit_note_rounded,
                      color:
                          canAddCustom
                              ? colors.primaryAccent
                              : colors.textSecondary,
                    ),
                    label: Text(
                      canAddCustom
                          ? 'Custom dial…'
                          : 'Custom dial (max ${GameplayDialIds.maxCustomDials})',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color:
                            canAddCustom
                                ? colors.primaryAccent
                                : colors.textSecondary,
                      ),
                    ),
                  ),
                ),
                if (!canAddCustom)
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      LayoutTokens.gr3,
                      LayoutTokens.gr1,
                      LayoutTokens.gr3,
                      0,
                    ),
                    child: Text(
                      'You already have ${GameplayDialIds.maxCustomDials} custom counters '
                      'or your strip is full (${GameplayDialIds.maxStripDials} max). '
                      'Remove one from your strip before adding another.',
                      style: TextStyle(
                        fontSize: FontTokens.hudSm,
                        height: 1.35,
                        color: colors.textSecondary.withValues(alpha: 0.88),
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
                        color: colors.textSecondary.withValues(alpha: 0.75),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: bottomPad,
          height: 52,
          child: IgnorePointer(
            child: AnimatedOpacity(
              opacity: _bottomFadeOpacity,
              duration: MotionTokens.standard,
              curve: MotionTokens.easeOut,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      colors.surface.withValues(alpha: 0),
                      colors.surface.withValues(alpha: 0.92),
                      colors.surface,
                    ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: bottomPad + 6,
          child: IgnorePointer(
            child: AnimatedOpacity(
              opacity: _bottomFadeOpacity,
              duration: MotionTokens.standard,
              curve: MotionTokens.easeOut,
              child: Center(
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 22,
                  color: colors.textSecondary.withValues(alpha: 0.55),
                ),
              ),
            ),
          ),
        ),
      ],
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
    final colors = context.gameColors;
    return Tooltip(
      message: 'Add counter',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEliminated ? null : onTap,
          borderRadius: BorderRadius.circular(_kDialPillCornerRadius),
          child: Ink(
            width: width,
            height: metrics.tileStackHeight,
            decoration: BoxDecoration(
              color: colors.surface.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(_kDialPillCornerRadius),
              border: Border.all(
                color: colors.primaryAccent.withValues(alpha: 0.45),
              ),
            ),
            child: Center(
              child: Icon(
                Icons.add_rounded,
                size: metrics.addIconSize,
                color: isEliminated ? colors.textSecondary : colors.primaryAccent,
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
  final int value;
  final double width;
  final bool isEliminated;
  final String tooltip;
  final Widget headerLeading;
  final VoidCallback? onHeaderTap;
  final VoidCallback? onHeaderLongPress;
  final void Function(int delta) onStep;
  final void Function(int absolute) onSetAbsolute;

  const _GameplayDialPill({
    required this.metrics,
    required this.value,
    required this.width,
    required this.isEliminated,
    required this.tooltip,
    required this.headerLeading,
    this.onHeaderTap,
    this.onHeaderLongPress,
    required this.onStep,
    required this.onSetAbsolute,
  });

  @override
  State<_GameplayDialPill> createState() => _GameplayDialPillState();
}

class _GameplayDialPillState extends State<_GameplayDialPill> {
  late FixedExtentScrollController _ctrl;
  bool _dragging = false;

  int get _clampedValue => widget.value.clamp(0, _kDialWheelMax);

  int _wheelIndexForValue(int value) => _kDialWheelMax - value;

  int _valueFromWheelIndex(int index) => _kDialWheelMax - index;

  @override
  void initState() {
    super.initState();
    _ctrl = FixedExtentScrollController(
      initialItem: _wheelIndexForValue(_clampedValue),
    );
  }

  @override
  void didUpdateWidget(covariant _GameplayDialPill oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_dragging && oldWidget.value != widget.value && _ctrl.hasClients) {
      final i = _wheelIndexForValue(_clampedValue);
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
    final colors = context.gameColors;
    final dim = widget.isEliminated;
    final borderColor = colors.backgroundSecondary.withValues(alpha: 0.65);

    return Material(
      color: Colors.transparent,
      child: Semantics(
        button: true,
        label: widget.tooltip,
        enabled: !widget.isEliminated,
        child: Tooltip(
          message: widget.tooltip,
          child: Container(
          width: widget.width,
          height: widget.metrics.tileStackHeight,
          decoration: BoxDecoration(
            color: colors.surface.withValues(alpha: dim ? 0.55 : 0.92),
            borderRadius: BorderRadius.circular(_kDialPillCornerRadius),
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
            borderRadius: BorderRadius.circular(_kDialPillCornerRadius),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: widget.metrics.pillHeaderHeight,
                  child: Center(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: widget.onHeaderTap,
                      onLongPress: widget.onHeaderLongPress,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        child: widget.headerLeading,
                      ),
                    ),
                  ),
                ),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: colors.textSecondary.withValues(alpha: 0.12),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final hStep = widget.metrics.stepTapHeight;
                      final wheelH = math.max(
                        0.0,
                        constraints.maxHeight - 2 * hStep,
                      );

                      return Column(
                        children: [
                          _stepButton(
                            colors: colors,
                            dim: dim,
                            icon: Icons.add_rounded,
                            onTap:
                                widget.isEliminated
                                    ? null
                                    : () {
                                      context.gameHapticLight();
                                      widget.onStep(1);
                                    },
                          ),
                          SizedBox(
                            height: wheelH,
                            width: double.infinity,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: colors.backgroundPrimary.withValues(alpha: 0.12),
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
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) {
                                        if (!mounted || !_ctrl.hasClients) {
                                          return;
                                        }
                                        final t = _valueFromWheelIndex(
                                          _ctrl.selectedItem,
                                        );
                                        if (t != _clampedValue) {
                                          context.gameHapticSelection();
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
                                    overAndUnderCenterOpacity: 0,
                                    onSelectedItemChanged: (_) {},
                                    childDelegate:
                                        ListWheelChildBuilderDelegate(
                                      childCount: _kDialWheelMax + 1,
                                      builder: (c, i) {
                                        return Center(
                                          child: Text(
                                            '${_valueFromWheelIndex(i)}',
                                            style: TextStyle(
                                              fontSize:
                                                  widget.metrics.wheelFontSize,
                                              fontWeight: FontWeight.w700,
                                              color:
                                                  dim
                                                      ? colors.textSecondary
                                                      : colors.textPrimary
                                                          .withValues(
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
                                // Groove shadow — reads as a channel the wheel
                                // is set into, rather than floating flat on the pill.
                                const IgnorePointer(child: _WheelGrooveShadow()),
                              ],
                            ),
                          ),
                          _stepButton(
                            colors: colors,
                            dim: dim,
                            icon: Icons.remove_rounded,
                            onTap:
                                widget.isEliminated
                                    ? null
                                    : () {
                                      context.gameHapticLight();
                                      widget.onStep(-1);
                                    },
                          ),
                        ],
                      );
                    },
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

  Widget _stepButton({
    required AppColorTokens colors,
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
              size: widget.metrics.stepIconSize + 2,
              color: dim ? colors.textSecondary : colors.primaryAccent,
            ),
          ),
        ),
      ),
    );
  }
}

/// Soft inward-fading edges on the counter wheel — reads as a shallow
/// carved channel the wheel sits inside (a soft-UI "inset shadow" fake,
/// since [BoxShadow] has no inset support). Purely decorative, ignored
/// for hit testing by the caller.
class _WheelGrooveShadow extends StatelessWidget {
  const _WheelGrooveShadow();

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTokens.of(context);
    final grooveColor =
        Color.lerp(colors.backgroundPrimary, Colors.black, 0.55)!;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            grooveColor.withValues(alpha: 0.4),
            Colors.transparent,
            Colors.transparent,
            grooveColor.withValues(alpha: 0.4),
          ],
          stops: const [0.0, 0.22, 0.78, 1.0],
        ),
      ),
    );
  }
}
