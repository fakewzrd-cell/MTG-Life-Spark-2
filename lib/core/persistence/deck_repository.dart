import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

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

  /// Copy identity (not W–L) into a new deck entry.
  Future<PlayerDeck> duplicate(PlayerDeck source) async {
    final copy = PlayerDeck(
      id: const Uuid().v4(),
      displayName: _uniqueCopyName(source.displayName),
      commanderName: source.commanderName,
      commanderImageUrl: source.commanderImageUrl,
      partnerCommanderName: source.partnerCommanderName,
      partnerCommanderImageUrl: source.partnerCommanderImageUrl,
      commanderManaCost: source.commanderManaCost,
      partnerManaCost: source.partnerManaCost,
      commanderColorIdentity: List<String>.from(source.commanderColorIdentity),
      format: source.format,
      deckStyleId: source.deckStyleId,
      isPinned: false,
    );
    await save(copy);
    return copy;
  }

  String _uniqueCopyName(String base) {
    final existing = _box.values.map((d) => d.displayName.toLowerCase()).toSet();
    var candidate = '$base (copy)';
    if (!existing.contains(candidate.toLowerCase())) return candidate;
    var n = 2;
    while (existing.contains('$base (copy $n)'.toLowerCase())) {
      n++;
    }
    return '$base (copy $n)';
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
