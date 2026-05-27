import 'package:flutter_test/flutter_test.dart';
import 'package:mgt_life_spark/core/persistence/profile_repository.dart';

void main() {
  group('ProfileRepository.computeXpProgress', () {
    test('progress within bronze band', () {
      final (inLevel, needed) =
          ProfileRepository().computeXpProgress(250);
      expect(inLevel, 250);
      expect(needed, 500);
    });

    test('does not wrap at band boundary', () {
      // Level 27 at 24000 total XP → 500 XP into the 2000-XP gold band.
      final (inLevel, needed) =
          ProfileRepository().computeXpProgress(24000);
      expect(inLevel, 500);
      expect(needed, 2000);
    });

    test('xpRequiredForLevel matches tier table', () {
      expect(ProfileRepository.xpRequiredForLevel(5), 500);
      expect(ProfileRepository.xpRequiredForLevel(15), 1000);
      expect(ProfileRepository.xpRequiredForLevel(30), 2000);
    });
  });
}
