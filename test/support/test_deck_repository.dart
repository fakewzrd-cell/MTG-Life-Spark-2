import 'package:mgt_life_spark/core/models/player_deck.dart';
import 'package:mgt_life_spark/core/persistence/deck_repository.dart';

/// In-memory deck repo for widget/integration tests (no Hive).
class TestDeckRepository extends DeckRepository {
  TestDeckRepository({List<PlayerDeck>? decks})
      : _decks = List<PlayerDeck>.from(decks ?? const []);

  final List<PlayerDeck> _decks;

  @override
  List<PlayerDeck> getAll() => List<PlayerDeck>.from(_decks);

  @override
  PlayerDeck? getById(String id) {
    for (final d in _decks) {
      if (d.id == id) return d;
    }
    return null;
  }
}
