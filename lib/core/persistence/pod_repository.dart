import 'package:hive_flutter/hive_flutter.dart';

import '../models/pod_preset.dart';

class PodRepository {
  static const _boxName = 'podPresets';

  Future<void> init() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<PodPreset>(_boxName);
    }
  }

  Box<PodPreset> get _box => Hive.box<PodPreset>(_boxName);

  List<PodPreset> getAll() {
    final list = _box.values.toList();
    list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return list;
  }

  Future<void> save(PodPreset preset) async {
    await _box.put(preset.id, preset);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  PodPreset? getById(String id) => _box.get(id);
}
