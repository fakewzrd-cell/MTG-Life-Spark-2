import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../game/game_format.dart';
import 'deck_style.dart';

part 'player_deck.g.dart';

@HiveType(typeId: 6)
class PlayerDeck extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String displayName;

  /// Cover card name (commander for EDH, signature card for constructed).
  @HiveField(2)
  String commanderName;

  @HiveField(3)
  String? commanderImageUrl;

  @HiveField(4)
  String? partnerCommanderName;

  @HiveField(5)
  String? partnerCommanderImageUrl;

  @HiveField(6)
  int wins;

  @HiveField(7)
  int losses;

  @HiveField(8)
  int gamesPlayed;

  /// Scryfall-style mana cost, e.g. `{3}{W}{U}`.
  @HiveField(9)
  String? commanderManaCost;

  @HiveField(10)
  String? partnerManaCost;

  /// Union of commander (+ partner) Scryfall `color_identity` letters (W,U,B,R,G).
  @HiveField(11)
  List<String> commanderColorIdentity;

  /// `GameFormat.name`, e.g. `commander`, `standard`.
  @HiveField(12, defaultValue: 'commander')
  String format;

  /// [DeckStyle.id]; empty until set on legacy decks.
  @HiveField(13, defaultValue: '')
  String deckStyleId;

  /// Pinned decks sort to the top of their format group.
  @HiveField(14, defaultValue: false)
  bool isPinned;

  PlayerDeck({
    required this.id,
    required this.displayName,
    required this.commanderName,
    this.commanderImageUrl,
    this.partnerCommanderName,
    this.partnerCommanderImageUrl,
    this.wins = 0,
    this.losses = 0,
    this.gamesPlayed = 0,
    this.commanderManaCost,
    this.partnerManaCost,
    this.commanderColorIdentity = const [],
    this.format = 'commander',
    this.deckStyleId = '',
    this.isPinned = false,
  });

  bool get hasDeckStyle => DeckStyle.isValidId(deckStyleId);

  DeckStyle? get deckStyle => DeckStyle.fromId(deckStyleId);

  String get deckStyleDisplayName =>
      deckStyle?.displayName ?? DeckStyle.unsetLabel;

  GameFormat get gameFormat =>
      GameFormatDetails.fromName(format) ?? GameFormat.commander;

  bool get isCommanderDeck => gameFormat.isCommanderStyle;

  bool get hasPartner =>
      isCommanderDeck &&
      partnerCommanderName != null &&
      partnerCommanderName!.isNotEmpty;

  double get winRate => gamesPlayed == 0 ? 0 : wins / gamesPlayed;

  factory PlayerDeck.create({
    required String displayName,
    required String commanderName,
    required GameFormat format,
    required String deckStyleId,
    String? commanderImageUrl,
    String? partnerCommanderName,
    String? partnerCommanderImageUrl,
    String? commanderManaCost,
    String? partnerManaCost,
    List<String> commanderColorIdentity = const [],
  }) =>
      PlayerDeck(
        id: const Uuid().v4(),
        displayName: displayName,
        commanderName: commanderName,
        commanderImageUrl: commanderImageUrl,
        partnerCommanderName:
            format.isCommanderStyle ? partnerCommanderName : null,
        partnerCommanderImageUrl:
            format.isCommanderStyle ? partnerCommanderImageUrl : null,
        commanderManaCost: commanderManaCost,
        partnerManaCost: format.isCommanderStyle ? partnerManaCost : null,
        commanderColorIdentity: commanderColorIdentity,
        format: format.name,
        deckStyleId: deckStyleId,
      );

  /// Saved deck format must match the lobby host format for picker and W/L.
  bool matchesLobbyFormat(GameFormat lobbyFormat) => gameFormat == lobbyFormat;
}
