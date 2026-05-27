import 'package:mgt_life_spark/core/models/player_profile.dart';
import 'package:mgt_life_spark/core/persistence/profile_repository.dart';

/// Lightweight profile repo for unit tests (no Hive).
class TestProfileRepository extends ProfileRepository {
  TestProfileRepository({this.profile});

  PlayerProfile? profile;
  int commanderKillIncrements = 0;

  @override
  PlayerProfile? getProfile() => profile;

  @override
  Future<void> incrementCommanderKills() async {
    commanderKillIncrements++;
  }
}
