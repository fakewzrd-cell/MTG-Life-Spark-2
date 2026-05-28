import 'package:mgt_life_spark/core/models/app_settings.dart';
import 'package:mgt_life_spark/core/persistence/settings_repository.dart';

/// In-memory settings for widget tests (no Hive).
class TestSettingsRepository extends SettingsRepository {
  TestSettingsRepository([AppSettings? initial])
      : _settings = initial ?? AppSettings();

  AppSettings _settings;

  @override
  AppSettings get settings => _settings;

  @override
  Future<void> update(AppSettings updated) async {
    _settings = updated;
  }
}
