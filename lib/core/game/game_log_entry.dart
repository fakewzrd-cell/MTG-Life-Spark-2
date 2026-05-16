/// One row in the session action log (grouped by turn in the History UI).
class GameLogEntry {
  const GameLogEntry({
    required this.turnNumber,
    required this.time,
    required this.message,
  });

  final int turnNumber;
  final DateTime time;
  final String message;

  Map<String, dynamic> toJson() => {
        'turn': turnNumber,
        'time': time.toIso8601String(),
        'msg': message,
      };

  factory GameLogEntry.fromJson(Map<String, dynamic> json) => GameLogEntry(
        turnNumber: (json['turn'] as num).toInt(),
        time: DateTime.parse(json['time'] as String),
        message: json['msg'] as String,
      );
}
