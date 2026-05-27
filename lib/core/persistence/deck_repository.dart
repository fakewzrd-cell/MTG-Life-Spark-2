import 'package:hive_flutter/hive_flutter.dart';

import '../../shared/utils/commander_image_resolver.dart';
import '../models/player_deck.dart';

class DeckRepository {
  static const _boxName = 'playerDecks';

  Future<void> init() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<PlayerDeck>(_boxName);
    }
  }

  Box<PlayerDeck> get _box => Hive.box<PlayerDeck>(_boxName);

  List<PlayerDeck> getAll() {
    final list =
        _box.values.where((d) => !isPreviewPlaceholderDeck(d)).toList();
    list.sort(
      (a, b) => a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()),
    );
    return list;
  }

  PlayerDeck? getById(String id) => _box.get(id);

  Future<void> save(PlayerDeck deck) async {
    await _box.put(deck.id, deck);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Future<void> recordMatchResult(String deckId, bool won) async {
    final deck = _box.get(deckId);
    if (deck == null) return;
    deck.gamesPlayed += 1;
    if (won) {
      deck.wins += 1;
    } else {
      deck.losses += 1;
    }
    await deck.save();
  }
}
