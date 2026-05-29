import 'package:flutter_test/flutter_test.dart';
import 'package:mgt_life_spark/core/models/game_feedback.dart';

void main() {
  group('PendingFeedbackData.hasContent', () {
    test('false when all fields empty', () {
      const pending = PendingFeedbackData();
      expect(pending.hasContent, isFalse);
    });

    test('true when any vote is set', () {
      expect(
        const PendingFeedbackData(likePlayerIds: ['a']).hasContent,
        isTrue,
      );
      expect(
        const PendingFeedbackData(mvpPlayerId: 'b').hasContent,
        isTrue,
      );
    });
  });
}
