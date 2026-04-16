import 'package:flutter/material.dart';

/// In-memory model representing one player's slot in the lobby and game.
/// Not persisted to Hive — reconstructed each session.
class PlayerSlot {
  final String playerId;
  final String username;
  final String? commanderName;
  final String? commanderImageUrl;
  final String? partnerCommanderName;
  final String? partnerCommanderImageUrl;
  final bool hasPartner;
  final Color playerColor;
  final bool isHost;
  final bool isReady;

  /// Registered deck id when the player chose a saved deck (local tracking).
  final String? selectedDeckId;

  const PlayerSlot({
    required this.playerId,
    required this.username,
    this.commanderName,
    this.commanderImageUrl,
    this.partnerCommanderName,
    this.partnerCommanderImageUrl,
    this.hasPartner = false,
    required this.playerColor,
    this.isHost = false,
    this.isReady = false,
    this.selectedDeckId,
  });

  PlayerSlot copyWith({
    String? commanderName,
    String? commanderImageUrl,
    String? partnerCommanderName,
    String? partnerCommanderImageUrl,
    bool? hasPartner,
    bool? isHost,
    bool? isReady,
    Object? selectedDeckId = _sentinelDeck,
  }) {
    return PlayerSlot(
      playerId: playerId,
      username: username,
      commanderName: commanderName ?? this.commanderName,
      commanderImageUrl: commanderImageUrl ?? this.commanderImageUrl,
      partnerCommanderName: partnerCommanderName ?? this.partnerCommanderName,
      partnerCommanderImageUrl:
          partnerCommanderImageUrl ?? this.partnerCommanderImageUrl,
      hasPartner: hasPartner ?? this.hasPartner,
      playerColor: playerColor,
      isHost: isHost ?? this.isHost,
      isReady: isReady ?? this.isReady,
      selectedDeckId: identical(selectedDeckId, _sentinelDeck)
          ? this.selectedDeckId
          : selectedDeckId as String?,
    );
  }

  static const Object _sentinelDeck = Object();

  Map<String, dynamic> toJson() => {
        'pid': playerId,
        'username': username,
        'commanderName': commanderName,
        'commanderImageUrl': commanderImageUrl,
        'partnerCommanderName': partnerCommanderName,
        'partnerCommanderImageUrl': partnerCommanderImageUrl,
        'hasPartner': hasPartner,
        'colorValue': playerColor.toARGB32(),
        'isHost': isHost,
        'isReady': isReady,
        'selectedDeckId': selectedDeckId,
      };

  factory PlayerSlot.fromJson(Map<String, dynamic> json) {
    return PlayerSlot(
      playerId: json['pid'] as String,
      username: json['username'] as String,
      commanderName: json['commanderName'] as String?,
      commanderImageUrl: json['commanderImageUrl'] as String?,
      partnerCommanderName: json['partnerCommanderName'] as String?,
      partnerCommanderImageUrl: json['partnerCommanderImageUrl'] as String?,
      hasPartner: json['hasPartner'] as bool? ?? false,
      playerColor: Color(json['colorValue'] as int),
      isHost: json['isHost'] as bool? ?? false,
      isReady: json['isReady'] as bool? ?? false,
      selectedDeckId: json['selectedDeckId'] as String?,
    );
  }
}
