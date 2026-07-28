/// Feedback data without matchId (used when conceding before match is saved).
class PendingFeedbackData {
  final List<String> likePlayerIds;
  final List<String> dislikePlayerIds;
  final String? starPlayerId;

  const PendingFeedbackData({
    this.likePlayerIds = const [],
    this.dislikePlayerIds = const [],
    this.starPlayerId,
  });

  bool get hasContent =>
      likePlayerIds.isNotEmpty ||
      dislikePlayerIds.isNotEmpty ||
      starPlayerId != null;
}

/// Feedback given by a player after a game ends.
class GameFeedback {
  final String matchId;
  final String voterPlayerId;
  final List<String> likePlayerIds;
  final List<String> dislikePlayerIds;

  /// Optional single honor: Spark of the game.
  final String? starPlayerId;

  const GameFeedback({
    required this.matchId,
    required this.voterPlayerId,
    this.likePlayerIds = const [],
    this.dislikePlayerIds = const [],
    this.starPlayerId,
  });

  Map<String, dynamic> toJson() => {
        'matchId': matchId,
        'voterPlayerId': voterPlayerId,
        'likePlayerIds': likePlayerIds,
        'dislikePlayerIds': dislikePlayerIds,
        'starPlayerId': starPlayerId,
      };

  factory GameFeedback.fromJson(Map<String, dynamic> json) {
    // Legacy ballots used mvpPlayerId; fold into star.
    final star = json['starPlayerId'] as String? ??
        json['mvpPlayerId'] as String?;
    return GameFeedback(
      matchId: json['matchId'] as String,
      voterPlayerId: json['voterPlayerId'] as String,
      likePlayerIds: (json['likePlayerIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      dislikePlayerIds: (json['dislikePlayerIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      starPlayerId: star,
    );
  }
}
