import 'package:mgt_life_spark/core/models/player_identity.dart';
import 'package:mgt_life_spark/core/models/player_profile.dart';
import 'package:mgt_life_spark/core/persistence/profile_repository.dart';

/// Lightweight profile repo for unit tests (no Hive).
class TestProfileRepository extends ProfileRepository {
  TestProfileRepository({this.profile}) {
    final p = profile;
    if (p != null && p.playerId.isEmpty) {
      p.playerId = generatePlayerId();
    }
  }

  PlayerProfile? profile;
  int commanderKillIncrements = 0;

  @override
  PlayerProfile? getProfile() {
    final p = profile;
    if (p != null && p.playerId.isEmpty) {
      p.playerId = generatePlayerId();
    }
    return p;
  }

  @override
  Future<void> incrementCommanderKills() async {
    commanderKillIncrements++;
  }
}
