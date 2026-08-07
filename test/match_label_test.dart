import 'package:flutter_test/flutter_test.dart';
import 'package:mgt_life_spark/core/models/match_record.dart';

void main() {
  group('MatchRecord.normalizeLabel', () {
    test('trims and rejects blanks', () {
      expect(MatchRecord.normalizeLabel(null), isNull);
      expect(MatchRecord.normalizeLabel(''), isNull);
      expect(MatchRecord.normalizeLabel('   '), isNull);
      expect(MatchRecord.normalizeLabel('  Friday EDH  '), 'Friday EDH');
    });

    test('caps length at 40', () {
      final long = 'a' * 50;
      expect(MatchRecord.normalizeLabel(long)?.length, 40);
    });
  });
}
