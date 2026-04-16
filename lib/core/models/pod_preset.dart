import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'pod_preset.g.dart';

@HiveType(typeId: 5)
class PodPreset extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  /// Default location label (e.g. office, LGS) shown on match history.
  @HiveField(2)
  String? defaultLocationLabel;

  /// Optional note for the player (not shown on match cards by default).
  @HiveField(3)
  String? note;

  /// In-game player ids (same as usernames in this app) in this pod.
  @HiveField(4)
  List<String> memberPlayerIds;

  PodPreset({
    required this.id,
    required this.name,
    this.defaultLocationLabel,
    this.note,
    this.memberPlayerIds = const [],
  });

  factory PodPreset.create({
    required String name,
    List<String> memberPlayerIds = const [],
  }) =>
      PodPreset(
        id: const Uuid().v4(),
        name: name,
        memberPlayerIds: memberPlayerIds,
      );
}
