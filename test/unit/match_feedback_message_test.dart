import 'package:flutter_test/flutter_test.dart';
import 'package:mgt_life_spark/core/bluetooth/ble_message.dart';
import 'package:mgt_life_spark/core/bluetooth/ble_protocol.dart';
import 'package:mgt_life_spark/core/models/game_feedback.dart';

void main() {
  test('matchFeedback message round-trips GameFeedback payload', () {
    const feedback = GameFeedback(
      matchId: 'm1',
      voterPlayerId: 'Alice',
      likePlayerIds: ['Bob'],
      starPlayerId: 'Bob',
    );

    final msg = BleMessage.matchFeedback(
      seqNum: 7,
      feedbackJson: feedback.toJson(),
    );
    expect(msg.type, BleMessageType.matchFeedback);

    final encoded = msg.toBytes();
    final decoded = BleMessage.fromBytes(encoded);
    expect(decoded.type, BleMessageType.matchFeedback);

    final parsed = GameFeedback.fromJson(decoded.payload);
    expect(parsed.matchId, 'm1');
    expect(parsed.voterPlayerId, 'Alice');
    expect(parsed.starPlayerId, 'Bob');
    expect(parsed.likePlayerIds, ['Bob']);
  });
}
