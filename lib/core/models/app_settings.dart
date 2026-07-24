import 'package:hive/hive.dart';

part 'app_settings.g.dart';

@HiveType(typeId: 4)
class AppSettings extends HiveObject {
  @HiveField(0)
  bool hapticEnabled;

  /// Persisted for Hive compatibility; SFX not wired in app yet.
  @HiveField(1)
  bool soundEnabled;

  @HiveField(2)
  String defaultFormat; // 'Commander' | 'Standard'

  @HiveField(3)
  int defaultStartingLife;

  @HiveField(4)
  bool scryfallCacheEnabled;

  @HiveField(5)
  bool shakeToUndoEnabled;

  @HiveField(6)
  bool onboardingCompleted;

  @HiveField(7)
  bool keepDisplayAwake;

  @HiveField(8)
  bool hideSystemBars;

  @HiveField(9, defaultValue: true)
  bool useDarkTheme;

  /// Persisted color scheme id: `violet` | `crimson` | `slate` | `forest`.
  @HiveField(10, defaultValue: 'violet')
  String colorSchemeId;

  /// User dismissed the in-match life gesture tip.
  @HiveField(11, defaultValue: false)
  bool lifeGestureHintDismissed;

  /// User finished or skipped the in-match hub guide slideshow.
  @HiveField(12, defaultValue: false)
  bool hubGuideCompleted;

  AppSettings({
    this.hapticEnabled = true,
    this.soundEnabled = true,
    this.defaultFormat = 'Commander',
    this.defaultStartingLife = 40,
    this.scryfallCacheEnabled = true,
    this.shakeToUndoEnabled = true,
    this.onboardingCompleted = false,
    this.keepDisplayAwake = true,
    this.hideSystemBars = false,
    this.useDarkTheme = true,
    this.colorSchemeId = 'violet',
    this.lifeGestureHintDismissed = false,
    this.hubGuideCompleted = false,
  });
}
