import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mgt_life_spark/core/network/session_providers.dart';
import 'package:mgt_life_spark/core/game/game_phase.dart';
import 'package:mgt_life_spark/core/game/game_providers.dart';
import 'package:mgt_life_spark/core/game/lobby_state.dart';
import 'package:mgt_life_spark/core/models/player_profile.dart';
import 'package:mgt_life_spark/core/persistence/providers.dart';

import 'support/fake_ble_service.dart';
import 'support/test_profile_repository.dart';
import 'support/test_settings_repository.dart';

void main() {
  test('lobby ready state initializes game with local player and turn order', () {
    final ble = FakeBleService();
    final profile = PlayerProfile(username: 'host', playerId: 'host-seat');
    final container = ProviderContainer(
      overrides: [
        sessionServiceProvider.overrideWith((ref) => ble),
        profileRepositoryProvider.overrideWithValue(
          TestProfileRepository(profile: profile),
        ),
        settingsRepositoryProvider.overrideWithValue(TestSettingsRepository()),
      ],
    );
    addTearDown(container.dispose);

    container.read(sessionRoleProvider.notifier).state = SessionRole.host;

    final lobbyNotifier = container.read(lobbyProvider.notifier);
    lobbyNotifier.initAsHost();
    lobbyNotifier.setReady('host-seat', ready: true);

    final lobby = container.read(lobbyProvider);
    expect(lobby.canStart, isTrue);

    final gameNotifier = container.read(gameProvider.notifier);
    expect(gameNotifier.shouldInitializeFromLobby(), isTrue);
    gameNotifier.initFromLobbyIfNeeded(lobby);

    final game = container.read(gameProvider);
    expect(game.localPlayer?.playerId, 'host-seat');
    expect(game.isHost, isTrue);
    expect(game.players.length, 1);
    expect(game.players.single.playerId, 'host-seat');
    expect(game.turnOrder, contains('host-seat'));
    expect(game.currentPhase, GamePhase.untap);
    expect(game.gameStartTime, isNotNull);
  });
}
