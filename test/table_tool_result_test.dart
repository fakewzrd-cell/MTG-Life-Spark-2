import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mgt_life_spark/core/bluetooth/ble_message.dart';
import 'package:mgt_life_spark/core/bluetooth/ble_protocol.dart';
import 'package:mgt_life_spark/core/game/game_providers.dart';
import 'package:mgt_life_spark/core/game/game_session_events.dart';
import 'package:mgt_life_spark/core/game/progression_service.dart';
import 'package:mgt_life_spark/core/network/session_providers.dart';
import 'package:mgt_life_spark/core/persistence/providers.dart';
import 'package:mgt_life_spark/features/game/widgets/table_tool_result_overlay.dart';

import 'support/fake_ble_service.dart';
import 'support/game_widget_harness.dart';
import 'support/test_profile_repository.dart';
import 'support/test_progression_service.dart';
import 'support/test_settings_repository.dart';

ProviderContainer _container(FakeBleService ble) {
  return ProviderContainer(
    overrides: [
      sessionServiceProvider.overrideWith((ref) => ble),
      profileRepositoryProvider.overrideWithValue(TestProfileRepository()),
      settingsRepositoryProvider.overrideWithValue(TestSettingsRepository()),
      progressionServiceProvider.overrideWithValue(TestProgressionService()),
    ],
  );
}

void main() {
  test('announceTableToolRoll publishes overlay and broadcasts', () {
    final ble = FakeBleService();
    final container = _container(ble);
    addTearDown(container.dispose);

    final notifier = container.read(gameProvider.notifier);
    notifier.setGameStateForTest(
      harnessGame(localId: 'alice').copyWith(isHost: true),
    );
    notifier.announceTableToolRoll(TableToolKind.d20);

    final shown = container.read(tableToolAnnouncementProvider);
    expect(shown, isNotNull);
    expect(shown!.kind, TableToolKind.d20);
    expect(shown.dieValue, inInclusiveRange(1, 20));
    expect(shown.playerId, 'alice');
    expect(shown.headline, contains('rolled a'));

    expect(ble.sentMessages, isNotEmpty);
    final msg = ble.sentMessages.last;
    expect(msg.type, BleMessageType.tableToolResult);
    expect(msg.payload['tool'], 'd20');
    expect(msg.payload['die'], shown.dieValue);

    final logs = container.read(gameProvider).sessionActionLog;
    expect(logs.last.message, shown.headline);
  });

  test('remote tableToolResult shows overlay for other seats', () {
    final ble = FakeBleService();
    final container = _container(ble);
    addTearDown(container.dispose);

    final notifier = container.read(gameProvider.notifier);
    notifier.setGameStateForTest(harnessGame(localId: 'alice'));

    notifier.handleSessionMessageForTest(
      BleMessage.tableToolResult(
        seqNum: 1,
        id: 'roll-1',
        playerId: 'bob',
        username: 'bob',
        tool: 'coin',
        coinHeads: true,
      ),
    );

    final shown = container.read(tableToolAnnouncementProvider);
    expect(shown, isNotNull);
    expect(shown!.playerId, 'bob');
    expect(shown.headline, 'bob flipped Heads');
    expect(container.read(gameProvider).sessionActionLog.last.message,
        'bob flipped Heads');

    notifier.dismissTableToolAnnouncement();
    expect(container.read(tableToolAnnouncementProvider), isNull);
  });

  test('ignores own echoed tableToolResult', () {
    final ble = FakeBleService();
    final container = _container(ble);
    addTearDown(container.dispose);

    final notifier = container.read(gameProvider.notifier);
    notifier.setGameStateForTest(harnessGame(localId: 'alice'));
    notifier.announceTableToolRoll(TableToolKind.d6);
    final first = container.read(tableToolAnnouncementProvider)!;

    notifier.handleSessionMessageForTest(
      BleMessage.tableToolResult(
        seqNum: 2,
        id: 'echo',
        playerId: 'alice',
        username: 'alice',
        tool: 'd6',
        dieValue: 1,
      ),
    );

    expect(container.read(tableToolAnnouncementProvider)?.id, first.id);
  });

  testWidgets('overlay dismisses on tap', (tester) async {
    final announcement = TableToolAnnouncement(
      id: 't1',
      playerId: 'alice',
      username: 'alice',
      kind: TableToolKind.d6,
      dieValue: 4,
    );

    await tester.pumpWidget(
      wrapGameWidget(
        game: harnessGame(localId: 'alice'),
        extraOverrides: [
          tableToolAnnouncementProvider.overrideWith((ref) => announcement),
        ],
        child: Scaffold(
          body: Stack(
            children: [
              const SizedBox.expand(),
              Consumer(
                builder: (context, ref, _) {
                  final a = ref.watch(tableToolAnnouncementProvider);
                  if (a == null) return const SizedBox.shrink();
                  return TableToolResultOverlay(
                    announcement: a,
                    autoDismiss: const Duration(hours: 1),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('alice rolled a 4'), findsOneWidget);
    await tester.tap(find.text('Tap to dismiss'));
    await tester.pump();
    expect(find.text('alice rolled a 4'), findsNothing);
  });

  testWidgets('overlay auto-dismisses after timeout', (tester) async {
    final announcement = TableToolAnnouncement(
      id: 't2',
      playerId: 'bob',
      username: 'bob',
      kind: TableToolKind.coin,
      coinHeads: false,
    );

    await tester.pumpWidget(
      wrapGameWidget(
        game: harnessGame(localId: 'alice'),
        extraOverrides: [
          tableToolAnnouncementProvider.overrideWith((ref) => announcement),
        ],
        child: Scaffold(
          body: Stack(
            children: [
              Consumer(
                builder: (context, ref, _) {
                  final a = ref.watch(tableToolAnnouncementProvider);
                  if (a == null) return const SizedBox.shrink();
                  return TableToolResultOverlay(
                    announcement: a,
                    autoDismiss: const Duration(seconds: 5),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('bob flipped Tails'), findsOneWidget);

    await tester.pump(const Duration(seconds: 5));
    await tester.pump();
    expect(find.text('bob flipped Tails'), findsNothing);
  });
}
