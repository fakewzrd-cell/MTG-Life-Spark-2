import 'package:flutter_test/flutter_test.dart';
import 'package:mgt_life_spark/shared/utils/wizard_rank_titles.dart';

void main() {
  group('wizardRankTitle', () {
    test('maps level bands to titles', () {
      expect(wizardRankTitle(1), 'Apprentice');
      expect(wizardRankTitle(5), 'Apprentice');
      expect(wizardRankTitle(6), 'Neophyte');
      expect(wizardRankTitle(26), 'Enchanter');
      expect(wizardRankTitle(100), 'Ascendant Archon');
    });

    test('clamps out-of-range levels', () {
      expect(wizardRankTitle(0), 'Apprentice');
      expect(wizardRankTitle(101), 'Ascendant Archon');
    });
  });

  group('tierForLevel', () {
    test('matches metal progression bands', () {
      expect(tierForLevel(1), 'Bronze');
      expect(tierForLevel(10), 'Bronze');
      expect(tierForLevel(11), 'Silver');
      expect(tierForLevel(25), 'Silver');
      expect(tierForLevel(26), 'Gold');
      expect(tierForLevel(50), 'Gold');
      expect(tierForLevel(51), 'Platinum');
      expect(tierForLevel(75), 'Platinum');
      expect(tierForLevel(76), 'Diamond');
      expect(tierForLevel(100), 'Diamond');
    });
  });

  group('rank and tier tables', () {
    test('ranks cover 1–100 without gaps or overlaps', () {
      expect(kWizardRankBands, isNotEmpty);
      expect(kWizardRankBands.first.minLevel, 1);
      expect(kWizardRankBands.last.maxLevel, 100);

      var expectedStart = 1;
      for (final band in kWizardRankBands) {
        expect(band.minLevel, expectedStart);
        expect(band.maxLevel, greaterThanOrEqualTo(band.minLevel));
        expectedStart = band.maxLevel + 1;
      }
      expect(expectedStart, 101);
    });

    test('each rank sits inside exactly one metal tier', () {
      for (final rank in kWizardRankBands) {
        final owners = kWizardTierBands.where(
          (t) =>
              rank.minLevel >= t.minLevel && rank.maxLevel <= t.maxLevel,
        );
        expect(owners.length, 1, reason: rank.title);
        expect(tierForLevel(rank.minLevel), owners.first.tier);
        expect(tierForLevel(rank.maxLevel), owners.first.tier);
      }
    });

    test('wizardRankTitle matches band table', () {
      for (final band in kWizardRankBands) {
        expect(wizardRankTitle(band.minLevel), band.title);
        expect(wizardRankTitle(band.maxLevel), band.title);
      }
    });
  });
}
