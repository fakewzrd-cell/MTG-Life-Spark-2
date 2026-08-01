import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mgt_life_spark/core/bluetooth/ble_message.dart';
import 'package:mgt_life_spark/core/bluetooth/ble_protocol.dart';
import 'package:mgt_life_spark/core/game/game_providers.dart';
import 'package:mgt_life_spark/core/game/game_session_events.dart';
import 'package:mgt_life_spark/core/network/session_providers.dart';
import 'package:mgt_life_spark/core/persistence/providers.dart';

import 'support/fake_ble_service.dart';
import 'support/game_widget_harness.dart';
import 'support/test_profile_repository.dart';

ProviderContainer _container(FakeBleService ble) {
  return ProviderContainer(
    overrides: [
      sessionServiceProvider.overrideWith((ref) => ble),
      profileRepositoryProvider.overrideWithValue(TestProfileRepository()),
    ],
  );
}

void main() {
  test('sendPlayerWhisper targets recipient and does not show locally', () {
    final ble = FakeBleService();
    final container = _container(ble);
    addTearDown(container.dispose);

    final notifier = container.read(gameProvider.notifier);
    notifier.setGameStateForTest(harnessGame(localId: 'alice'));

    final ok = notifier.sendPlayerWhisper('bob', 'Team up?');
    expect(ok, isTrue);
    expect(container.read(playerWhisperAnnouncementProvider), isNull);

    expect(ble.sentMessages, isNotEmpty);
    final msg = ble.sentMessages.last;
    expect(msg.type, BleMessageType.playerWhisper);
    expect(msg.targetPlayerId, 'bob');
    expect(msg.payload['text'], 'Team up?');
    expect(msg.payload['from'], 'alice');
    expect(msg.payload['to'], 'bob');

    expect(
      container.read(gameProvider).sessionActionLog,
      isEmpty,
    );
  });

  test('remote playerWhisper shows overlay for recipient only', () {
    final ble = FakeBleService();
    final container = _container(ble);
    addTearDown(container.dispose);

    final notifier = container.read(gameProvider.notifier);
    notifier.setGameStateForTest(harnessGame(localId: 'bob'));

    notifier.handleSessionMessageForTest(
      BleMessage.playerWhisper(
        seqNum: 1,
        id: 'w1',
        fromPlayerId: 'alice',
        fromUsername: 'Alice',
        toPlayerId: 'bob',
        text: "Don't attack me",
      ),
    );

    final shown = container.read(playerWhisperAnnouncementProvider);
    expect(shown, isNotNull);
    expect(shown!.fromUsername, 'Alice');
    expect(shown.text, "Don't attack me");

    notifier.dismissPlayerWhisper();
    expect(container.read(playerWhisperAnnouncementProvider), isNull);
  });

  test('ignores whisper not addressed to local seat', () {
    final ble = FakeBleService();
    final container = _container(ble);
    addTearDown(container.dispose);

    final notifier = container.read(gameProvider.notifier);
    notifier.setGameStateForTest(harnessGame(localId: 'alice'));

    notifier.handleSessionMessageForTest(
      BleMessage.playerWhisper(
        seqNum: 1,
        id: 'w2',
        fromPlayerId: 'bob',
        fromUsername: 'Bob',
        toPlayerId: 'carol',
        text: 'Psst',
      ),
    );

    expect(container.read(playerWhisperAnnouncementProvider), isNull);
  });

  test('rate limits repeat whispers to same player', () {
    final ble = FakeBleService();
    final container = _container(ble);
    addTearDown(container.dispose);

    final notifier = container.read(gameProvider.notifier);
    notifier.setGameStateForTest(harnessGame(localId: 'alice'));

    expect(notifier.sendPlayerWhisper('bob', 'One'), isTrue);
    expect(notifier.sendPlayerWhisper('bob', 'Two'), isFalse);
  });
}
