import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:mgt_life_spark/core/models/player_identity.dart';

void main() {
  group('player identity', () {
    test('generatePlayerId returns unique non-empty UUIDs', () {
      final a = generatePlayerId();
      final b = generatePlayerId();
      expect(a, isNotEmpty);
      expect(b, isNotEmpty);
      expect(a, isNot(b));
    });

    test('generateSparkDisplayName uses Spark + 4 hex digits', () {
      final name = generateSparkDisplayName(Random(42));
      expect(name, matches(RegExp(r'^Spark[0-9A-F]{4}$')));
    });

    test('isPlaceholderDisplayName treats Planeswalker and blanks as placeholders',
        () {
      expect(isPlaceholderDisplayName('Planeswalker'), isTrue);
      expect(isPlaceholderDisplayName(' planeswalker '), isTrue);
      expect(isPlaceholderDisplayName(''), isTrue);
      expect(isPlaceholderDisplayName('Alex'), isFalse);
      expect(isPlaceholderDisplayName('SparkA3F2'), isFalse);
    });
  });
}
