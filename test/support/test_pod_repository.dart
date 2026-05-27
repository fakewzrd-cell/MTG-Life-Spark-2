import 'package:mgt_life_spark/core/models/pod_preset.dart';
import 'package:mgt_life_spark/core/persistence/pod_repository.dart';

/// In-memory pod repo for widget/integration tests (no Hive).
class TestPodRepository extends PodRepository {
  TestPodRepository({List<PodPreset>? presets})
      : _presets = List<PodPreset>.from(presets ?? const []);

  final List<PodPreset> _presets;

  @override
  List<PodPreset> getAll() => List<PodPreset>.from(_presets);

  @override
  PodPreset? getById(String id) {
    for (final p in _presets) {
      if (p.id == id) return p;
    }
    return null;
  }
}
