import 'package:flutter_test/flutter_test.dart';
import 'package:mgt_life_spark/features/profile/profile_player_stats_section.dart';

void main() {
  group('computeWinStreaks', () {
    test('empty history is zero', () {
      final s = computeWinStreaks(const []);
      expect(s.current, 0);
      expect(s.best, 0);
    });

    test('tracks current and best streaks', () {
      // W L W W W L W W  → current 2, best 3
      final s = computeWinStreaks(const [
        true,
        false,
        true,
        true,
        true,
        false,
        true,
        true,
      ]);
      expect(s.current, 2);
      expect(s.best, 3);
    });

    test('loss resets current streak', () {
      final s = computeWinStreaks(const [true, true, false]);
      expect(s.current, 0);
      expect(s.best, 2);
    });

    test('all wins are current and best', () {
      final s = computeWinStreaks(const [true, true, true, true]);
      expect(s.current, 4);
      expect(s.best, 4);
    });
  });
}
