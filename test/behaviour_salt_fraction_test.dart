import 'package:flutter_test/flutter_test.dart';
import 'package:mgt_life_spark/features/profile/profile_player_stats_section.dart';

void main() {
  group('behaviourSaltFraction', () {
    test('no reactions stays exactly neutral', () {
      expect(behaviourSaltFraction(likes: 0, dislikes: 0), 0.5);
    });

    test('first like only nudges left of center (not full Good)', () {
      // softsign: 1/(4+1)=0.2 → salt = 0.5 - 0.1 = 0.4
      expect(behaviourSaltFraction(likes: 1, dislikes: 0), closeTo(0.4, 1e-9));
    });

    test('first dislike only nudges right of center (not full Salty)', () {
      expect(behaviourSaltFraction(likes: 0, dislikes: 1), closeTo(0.6, 1e-9));
    });

    test('likes and dislikes are symmetric around neutral', () {
      for (final n in [1, 2, 5, 20]) {
        final good = behaviourSaltFraction(likes: n, dislikes: 0);
        final salty = behaviourSaltFraction(likes: 0, dislikes: n);
        expect(good + salty, closeTo(1.0, 1e-9), reason: 'n=$n');
        expect(0.5 - good, closeTo(salty - 0.5, 1e-9), reason: 'n=$n');
      }
    });

    test('more likes move further toward Good without hitting 0', () {
      final one = behaviourSaltFraction(likes: 1, dislikes: 0);
      final few = behaviourSaltFraction(likes: 3, dislikes: 0);
      final many = behaviourSaltFraction(likes: 12, dislikes: 0);
      expect(few, lessThan(one));
      expect(many, lessThan(few));
      expect(many, greaterThan(0.0));
      expect(many, lessThan(0.2));
    });

    test('more dislikes move further toward Salty without hitting 1', () {
      final one = behaviourSaltFraction(likes: 0, dislikes: 1);
      final few = behaviourSaltFraction(likes: 0, dislikes: 3);
      final many = behaviourSaltFraction(likes: 0, dislikes: 12);
      expect(few, greaterThan(one));
      expect(many, greaterThan(few));
      expect(many, lessThan(1.0));
      expect(many, greaterThan(0.8));
    });

    test('equal likes and dislikes stay neutral at any volume', () {
      for (final n in [1, 4, 50]) {
        expect(
          behaviourSaltFraction(likes: n, dislikes: n),
          closeTo(0.5, 1e-9),
          reason: 'n=$n',
        );
      }
    });

    test('net likes lean Good; net dislikes lean Salty', () {
      expect(behaviourSaltFraction(likes: 5, dislikes: 2), lessThan(0.5));
      expect(behaviourSaltFraction(likes: 2, dislikes: 5), greaterThan(0.5));
    });

    test('negative counts are treated as zero', () {
      expect(behaviourSaltFraction(likes: -3, dislikes: -1), 0.5);
      expect(
        behaviourSaltFraction(likes: -2, dislikes: 0),
        behaviourSaltFraction(likes: 0, dislikes: 0),
      );
    });

    test('same net score shares the same position', () {
      // Net +1 whether 1–0 or 10–9.
      expect(
        behaviourSaltFraction(likes: 1, dislikes: 0),
        behaviourSaltFraction(likes: 10, dislikes: 9),
      );
    });
  });
}
