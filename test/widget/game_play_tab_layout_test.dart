// Regression coverage for the Play tab's flex-based layout (game_screen.dart).
//
// Renders the same zone structure — pinned phase bar/dial strip, pinned
// variant chip/turn timer rows, and a flexible life counter — using the
// real production widgets, at a range of tight viewport heights with every
// optional element enabled simultaneously (variant decks + turn timer + 4
// gameplay counters). This is the worst case for overflow.
//
// `tester.takeException()` returns non-null whenever a `RenderFlex` overflow
// (or any other render-time exception) occurred during the pump, so it is
// the standard way to assert "no overflow" for a widget test.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mgt_life_spark/features/game/widgets/game_performance_widgets.dart';
import 'package:mgt_life_spark/features/game/widgets/game_timeout_widgets.dart';
import 'package:mgt_life_spark/features/game/widgets/gameplay_dials_strip_widget.dart';
import 'package:mgt_life_spark/features/game/widgets/life_gesture_hint_banner.dart';
import 'package:mgt_life_spark/features/game/widgets/phase_nav_cluster.dart';
import 'package:mgt_life_spark/features/game/widgets/variant_card_panel.dart';

import '../support/game_widget_harness.dart';

/// Mirrors the Play tab `Column` in `_PersonalViewState.build` — including
/// its "comfortable flex" vs. "scrollable safety net" branch — so the test
/// exercises the exact structure (and real leaf widgets) shipped in
/// production, without pulling in `GameScreen`'s unrelated plugin side
/// effects (wakelock, shake-to-undo sensors).
Widget _playTabHarness({required bool hasExtraRows}) {
  const playGapSm = SizedBox(height: 8);
  const playGapMd = SizedBox(height: 12);
  const lifeBandMaxW = 360.0;
  const lifeBandH = 192.0;
  const lifeMinFloor = 96.0;
  const extraRowEstimate = 44.0;

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    child: LayoutBuilder(
      builder: (context, playConstraints) {
        final dialCompact = playConstraints.maxHeight < 520;

        final phaseBar = Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: lifeBandMaxW),
            child: PhaseNavCluster(
              game: harnessGame(localId: 'alice'),
              accentColor: Colors.blue,
              onBack: () {},
              onNext: () {},
              onPickPhase: (_) {},
              onEndTurn: () {},
              endTurnEnabled: true,
            ),
          ),
        );
        final lifeCounter = Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: lifeBandMaxW,
              maxHeight: lifeBandH,
            ),
            child: const ScopedLifeCounter(
              playerId: 'alice',
              onLifeChange: _noopLifeChange,
            ),
          ),
        );
        final dialStrip = Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: ScopedGameplayDials(
            playerId: 'alice',
            compactVertical: dialCompact,
            onAdjustCounter: (_, _) {},
            onSetCounterAbsolute: (_, _) {},
            onRegisterCustomDial: (_, _) => true,
            onAddDialToStrip: (_) => true,
            onRemoveDialFromStrip: (_) {},
          ),
        );

        // Variant decks and the turn timer are now pinned, fixed-height
        // rows — the variant panel itself only ever renders in a bottom
        // sheet via `VariantQuickAccessChip`, off the Play tab's budget.
        final extraRows = <Widget>[
          if (hasExtraRows) ...[
            const VariantQuickAccessChip(),
            playGapSm,
            GameTurnDurationBanner(
              turnStartTime: DateTime.now(),
              limitSeconds: 120,
              isActiveTurn: true,
              activePlayerName: 'alice',
            ),
            playGapSm,
          ],
        ];

        final dialStripH = GameplayDialsStripWidget.estimatedStripHeight(
          context,
          compactVertical: dialCompact,
        );
        final comfortableMin = PhaseNavCluster.barHeight +
            12 +
            (hasExtraRows ? extraRowEstimate * 2 : 0.0) +
            lifeMinFloor +
            8 +
            dialStripH;

        if (playConstraints.maxHeight >= comfortableMin) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              phaseBar,
              playGapMd,
              ...extraRows,
              Expanded(child: lifeCounter),
              const LifeGestureHintBanner(),
              playGapSm,
              dialStrip,
            ],
          );
        }

        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: playConstraints.maxHeight),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                phaseBar,
                playGapMd,
                ...extraRows,
                SizedBox(height: lifeMinFloor, child: lifeCounter),
                const LifeGestureHintBanner(),
                playGapSm,
                dialStrip,
              ],
            ),
          ),
        );
      },
    ),
  );
}

void _noopLifeChange(int delta) {}

void main() {
  // Worst case: every optional Play tab element enabled at once — variant
  // decks, a turn timer, and the maximum 4 gameplay counters.
  final worstCaseGame = harnessGame(
    localId: 'alice',
    players: [
      harnessPlayer(id: 'alice').copyWith(
        visibleGameplayDials: ['poison', 'energy', 'experience', 'rad'],
      ),
      harnessPlayer(id: 'bob'),
    ],
  ).copyWith(
    planechaseEnabled: true,
    trackTurnDuration: true,
    turnStartTime: DateTime.now(),
  );

  // A representative spread from an extremely short landscape/split-screen
  // viewport up through comfortably tall tablets — the Play tab content
  // area rarely gets the full device height (header/bottom bar consume
  // some), so these heights stand in for "space left for the Play tab"
  // rather than raw device size.
  const heightsToTest = [160.0, 220.0, 280.0, 340.0, 420.0, 520.0, 640.0, 900.0];

  for (final height in heightsToTest) {
    testWidgets(
      'Play tab layout has no overflow at height=$height '
      '(variant chip + timer + 4 counters)',
      (tester) async {
        await tester.pumpWidget(
          wrapGameWidget(
            game: worstCaseGame,
            child: Scaffold(
              body: SizedBox(
                height: height,
                child: _playTabHarness(hasExtraRows: true),
              ),
            ),
          ),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'Play tab layout has no overflow at height=$height (no extras)',
      (tester) async {
        await tester.pumpWidget(
          wrapGameWidget(
            game: harnessGame(localId: 'alice'),
            child: Scaffold(
              body: SizedBox(
                height: height,
                child: _playTabHarness(hasExtraRows: false),
              ),
            ),
          ),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
      },
    );
  }
}
