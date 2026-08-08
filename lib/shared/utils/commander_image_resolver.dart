import '../../core/models/match_record.dart';
import '../../core/models/player_deck.dart';
import '../../core/models/player_profile.dart';
import '../../core/persistence/deck_repository.dart';

bool _namesMatch(String? a, String? b) {
  final left = a?.trim() ?? '';
  final right = b?.trim() ?? '';
  if (left.isEmpty || right.isEmpty) return false;
  return left.toLowerCase() == right.toLowerCase();
}

/// Immediate commander art URL for a saved deck (no network).
String? resolveDeckCommanderImageUrl({
  required PlayerDeck deck,
  PlayerProfile? profile,
}) {
  final stored = deck.commanderImageUrl?.trim();
  if (stored != null && stored.isNotEmpty) return stored;

  if (profile != null) {
    final deckCmd = deck.commanderName.trim();
    final selName = profile.selectedCommanderName?.trim();
    if (selName != null &&
        selName.isNotEmpty &&
        selName.toLowerCase() == deckCmd.toLowerCase()) {
      final url = profile.selectedCommanderImageUrl?.trim();
      if (url != null && url.isNotEmpty) return url;
    }
  }
  return null;
}

/// Art for a commander by name: matching deck → matching profile selection →
/// newest match snapshot with that commander (local seat preferred).
///
/// Never returns another commander's profile art when names do not match.
String? resolveCommanderArtByName({
  required String commanderName,
  required Iterable<PlayerDeck> decks,
  PlayerProfile? profile,
  Iterable<MatchRecord>? matches,
  String? localPlayerId,
}) {
  final name = commanderName.trim();
  if (name.isEmpty) return null;

  for (final d in decks) {
    if (isPreviewPlaceholderDeck(d)) continue;
    if (!_namesMatch(d.commanderName, name)) continue;
    final url = resolveDeckCommanderImageUrl(deck: d, profile: profile);
    if (url != null && url.isNotEmpty) return url;
  }

  if (profile != null &&
      _namesMatch(profile.selectedCommanderName, name)) {
    final url = profile.selectedCommanderImageUrl?.trim();
    if (url != null && url.isNotEmpty) return url;
  }

  if (matches == null) return null;

  final ordered = List<MatchRecord>.from(matches)
    ..sort((a, b) => b.date.compareTo(a.date));

  String? anyMatchUrl;
  for (final m in ordered) {
    if (isPreviewPlaceholderMatchId(m.matchId)) continue;
    for (final p in m.participantSnapshots) {
      if (!_namesMatch(p.commanderName, name)) continue;
      final url = p.commanderImageUrl?.trim();
      if (url == null || url.isEmpty) continue;
      if (localPlayerId != null && p.playerId == localPlayerId) {
        return url;
      }
      anyMatchUrl ??= url;
    }
  }
  return anyMatchUrl;
}

/// Immediate partner art URL for a saved deck (no network).
String? resolveDeckPartnerImageUrl({
  required PlayerDeck deck,
  PlayerProfile? profile,
}) {
  final stored = deck.partnerCommanderImageUrl?.trim();
  if (stored != null && stored.isNotEmpty) return stored;

  if (profile != null && deck.hasPartner) {
    final partner = deck.partnerCommanderName!.trim();
    final selPartner = profile.selectedPartnerCommanderName?.trim();
    if (selPartner != null &&
        selPartner.isNotEmpty &&
        selPartner.toLowerCase() == partner.toLowerCase()) {
      final url = profile.selectedPartnerCommanderImageUrl?.trim();
      if (url != null && url.isNotEmpty) return url;
    }
  }
  return null;
}

/// Commander art for an in-game player row (slot/deck/profile, no network).
String? resolvePlayerCommanderImageUrl({
  required String? commanderName,
  required String? commanderImageUrl,
  String? selectedDeckId,
  PlayerProfile? profile,
  DeckRepository? deckRepo,
}) {
  final stored = commanderImageUrl?.trim();
  if (stored != null && stored.isNotEmpty) return stored;

  if (selectedDeckId != null && deckRepo != null) {
    final deck = deckRepo.getById(selectedDeckId);
    if (deck != null) {
      final fromDeck = resolveDeckCommanderImageUrl(deck: deck, profile: profile);
      if (fromDeck != null && fromDeck.isNotEmpty) return fromDeck;
    }
  }

  if (profile != null && commanderName != null) {
    final name = commanderName.trim();
    if (name.isNotEmpty) {
      final selName = profile.selectedCommanderName?.trim();
      if (selName != null &&
          selName.isNotEmpty &&
          selName.toLowerCase() == name.toLowerCase()) {
        final url = profile.selectedCommanderImageUrl?.trim();
        if (url != null && url.isNotEmpty) return url;
      }
    }
  }
  return null;
}

/// Partner art for an in-game player row (slot/deck/profile, no network).
String? resolvePlayerPartnerImageUrl({
  required String? partnerCommanderName,
  required String? partnerCommanderImageUrl,
  String? selectedDeckId,
  PlayerProfile? profile,
  DeckRepository? deckRepo,
}) {
  final stored = partnerCommanderImageUrl?.trim();
  if (stored != null && stored.isNotEmpty) return stored;

  if (selectedDeckId != null && deckRepo != null) {
    final deck = deckRepo.getById(selectedDeckId);
    if (deck != null && deck.hasPartner) {
      final fromDeck =
          resolveDeckPartnerImageUrl(deck: deck, profile: profile);
      if (fromDeck != null && fromDeck.isNotEmpty) return fromDeck;
    }
  }

  if (profile != null && partnerCommanderName != null) {
    final name = partnerCommanderName.trim();
    if (name.isNotEmpty) {
      final selPartner = profile.selectedPartnerCommanderName?.trim();
      if (selPartner != null &&
          selPartner.isNotEmpty &&
          selPartner.toLowerCase() == name.toLowerCase()) {
        final url = profile.selectedPartnerCommanderImageUrl?.trim();
        if (url != null && url.isNotEmpty) return url;
      }
    }
  }
  return null;
}

bool isPreviewPlaceholderDeckId(String id) =>
    id.startsWith('__preview_placeholder_deck');

bool isPreviewPlaceholderDeck(PlayerDeck deck) =>
    isPreviewPlaceholderDeckId(deck.id);

bool isPreviewPlaceholderMatchId(String matchId) =>
    matchId.startsWith('__preview_placeholder');
