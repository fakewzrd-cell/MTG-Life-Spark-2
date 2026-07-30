import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Fired when a remote player leaves/disconnects mid-match so the UI can toast
/// and (when the table ends) land on the feedback screen.
class PlayerLeftUiEvent {
  const PlayerLeftUiEvent({
    required this.username,
    required this.gameEnded,
  });

  final String username;
  final bool gameEnded;
}

final playerLeftUiEventProvider =
    StateProvider<PlayerLeftUiEvent?>((ref) => null);

/// A seat whose socket dropped; host may wait or remove after grace.
class PeerLinkIssue {
  const PeerLinkIssue({
    required this.playerId,
    required this.username,
    required this.awaitingHostDecision,
  });

  final String playerId;
  final String username;

  /// True after reconnect grace — host should Keep waiting / Remove.
  final bool awaitingHostDecision;
}

/// playerId → soft-drop status (cleared when they reconnect or are removed).
final peerLinkIssuesProvider =
    StateProvider<Map<String, PeerLinkIssue>>((ref) => {});

/// Bumped when a peer's grace expires so the host UI can prompt once.
final peerReconnectDecisionTickProvider = StateProvider<int>((ref) => 0);

enum LifeChangeSource { local, remote }

/// Ephemeral accessibility event for changes to the local seat's life total.
class LifeChangeAnnouncement {
  const LifeChangeAnnouncement({
    required this.id,
    required this.total,
    required this.delta,
    required this.source,
    this.actorUsername,
  });

  final int id;
  final int total;
  final int delta;
  final LifeChangeSource source;
  final String? actorUsername;
}

final localLifeChangeProvider =
    StateProvider<LifeChangeAnnouncement?>((ref) => null);

/// Shared mid-match dice / coin announcement (ephemeral UI, not game state).
enum TableToolKind { d6, d20, coin }

class TableToolAnnouncement {
  const TableToolAnnouncement({
    required this.id,
    required this.playerId,
    required this.username,
    required this.kind,
    this.dieValue,
    this.coinHeads,
  });

  final String id;
  final String playerId;
  final String username;
  final TableToolKind kind;
  final int? dieValue;
  final bool? coinHeads;

  String get resultLabel {
    switch (kind) {
      case TableToolKind.d6:
      case TableToolKind.d20:
        return '${dieValue ?? '?'}';
      case TableToolKind.coin:
        return (coinHeads ?? false) ? 'Heads' : 'Tails';
    }
  }

  String get toolLabel => switch (kind) {
        TableToolKind.d6 => 'd6',
        TableToolKind.d20 => 'd20',
        TableToolKind.coin => 'Coin',
      };

  String get headline => switch (kind) {
        TableToolKind.d6 => '$username rolled a $resultLabel',
        TableToolKind.d20 => '$username rolled a $resultLabel',
        TableToolKind.coin => '$username flipped $resultLabel',
      };

  factory TableToolAnnouncement.fromPayload(Map<String, dynamic> payload) {
    final tool = payload['tool'] as String? ?? 'd6';
    final kind = switch (tool) {
      'd20' => TableToolKind.d20,
      'coin' => TableToolKind.coin,
      _ => TableToolKind.d6,
    };
    return TableToolAnnouncement(
      id: payload['id'] as String? ?? '',
      playerId: payload['pid'] as String? ?? '',
      username: payload['username'] as String? ?? 'Player',
      kind: kind,
      dieValue: (payload['die'] as num?)?.toInt(),
      coinHeads: payload['heads'] as bool?,
    );
  }

  Map<String, dynamic> toPayload() => {
        'id': id,
        'pid': playerId,
        'username': username,
        'tool': switch (kind) {
          TableToolKind.d6 => 'd6',
          TableToolKind.d20 => 'd20',
          TableToolKind.coin => 'coin',
        },
        if (dieValue != null) 'die': dieValue,
        if (coinHeads != null) 'heads': coinHeads,
      };
}

final tableToolAnnouncementProvider =
    StateProvider<TableToolAnnouncement?>((ref) => null);
