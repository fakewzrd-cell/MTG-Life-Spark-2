import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/models/commander_stats.dart';
import 'core/models/player_profile.dart';
import 'core/models/match_record.dart';
import 'core/models/achievement_record.dart';
import 'core/models/app_settings.dart';
import 'core/models/pod_preset.dart';
import 'core/models/player_deck.dart';
import 'core/persistence/deck_repository.dart';
import 'core/persistence/feedback_repository.dart';
import 'core/persistence/match_repository.dart';
import 'core/persistence/profile_repository.dart';
import 'core/debug/dismiss_web_splash.dart';
import 'core/network/session_connection_guard.dart';
import 'shared/theme/theme_provider.dart';
import 'shared/utils/app_router.dart';
import 'shared/utils/commander_image_resolver.dart';
import 'ui/tokens/color_tokens.dart';
import 'ui/theme/app_system_ui.dart';

Future<void> main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await AppSystemUi.bootstrap();

    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      debugPrint('FlutterError: ${details.exception}');
      debugPrint('Stack: ${details.stack}');
    };

    runApp(const ProviderScope(child: _AppBootstrap()));
  }, (error, stack) {
    debugPrint('Zone error: $error');
    debugPrint('Stack: $stack');
  });
}

/// Paints immediately so the HTML splash can dismiss, then finishes Hive init.
class _AppBootstrap extends StatefulWidget {
  const _AppBootstrap();

  @override
  State<_AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<_AppBootstrap> {
  late final Future<void> _initFuture = _initHive();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _ErrorApp(
            message: snapshot.error.toString(),
            stack: snapshot.stackTrace.toString(),
          );
        }
        if (snapshot.connectionState == ConnectionState.done) {
          dismissWebSplash();
          return const MgtLifeSparkApp();
        }
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            backgroundColor: ColorTokens.backgroundPrimary,
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: ColorTokens.brandPurple),
                  const SizedBox(height: 16),
                  Text(
                    'Loading MTG Life Spark…',
                    style: TextStyle(
                      color: ColorTokens.textPrimary.withValues(alpha: 0.75),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ErrorApp extends StatelessWidget {
  final String message;
  final String stack;

  const _ErrorApp({required this.message, required this.stack});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: ColorTokens.backgroundPrimary,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Startup Error',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: ColorTokens.danger,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: TextStyle(
                    color: ColorTokens.textPrimary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Stack trace:',
                  style: TextStyle(
                    color: ColorTokens.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                SelectableText(
                  stack,
                  style: TextStyle(
                    color: ColorTokens.textMuted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> _initHive() async {
  await _withStartupTimeout(
    'Opening local storage',
    Hive.initFlutter(),
  );

  // Register all adapters
  Hive.registerAdapter(PlayerProfileAdapter());
  Hive.registerAdapter(MatchRecordAdapter());
  Hive.registerAdapter(CommanderStatsAdapter());
  Hive.registerAdapter(AchievementRecordAdapter());
  Hive.registerAdapter(AppSettingsAdapter());
  Hive.registerAdapter(PodPresetAdapter());
  Hive.registerAdapter(PlayerDeckAdapter());

  // Web IndexedDB can hang when opening many Hive boxes in parallel.
  await _withStartupTimeout('Loading profile data', _openHiveBoxes());

  // Ensure default settings exist
  final settingsBox = Hive.box<AppSettings>('appSettings');
  if (!settingsBox.containsKey('settings')) {
    await settingsBox.put('settings', AppSettings());
  }

  // Warm fonts after first paint — never block startup on mobile networks.
  unawaited(GoogleFonts.pendingFonts([GoogleFonts.lato()]));

  // Non-blocking maintenance — keeps first paint fast on web/mobile.
  unawaited(_deferredStartupMaintenance());
}

Future<void> _openHiveBoxes() async {
  final opens = <Future<void>>[
    Hive.openBox<PlayerProfile>('playerProfile'),
    Hive.openBox<MatchRecord>('matchHistory'),
    Hive.openBox<CommanderStats>('commanderStats'),
    Hive.openBox<AchievementRecord>('achievements'),
    Hive.openBox<AppSettings>('appSettings'),
    Hive.openBox<String>('matchFeedback'),
    Hive.openBox<PodPreset>('podPresets'),
    Hive.openBox<PlayerDeck>('playerDecks'),
  ];
  if (kIsWeb) {
    for (final open in opens) {
      await open;
    }
  } else {
    await Future.wait(opens);
  }
}

Future<T> _withStartupTimeout<T>(String label, Future<T> future) {
  final timeout = kIsWeb
      ? const Duration(seconds: 20)
      : const Duration(seconds: 45);
  return future.timeout(
    timeout,
    onTimeout: () => throw TimeoutException(
      '$label timed out after ${timeout.inSeconds}s. '
      'Use the release dev server (not debug). '
      'If this persists, clear site data for this URL in browser settings.',
    ),
  );
}

Future<void> _deferredStartupMaintenance() async {
  try {
    await MatchRepository().purgeOldMatches();
    await FeedbackRepository().init();
    await _deferredProfileMaintenance();
  } catch (e, st) {
    debugPrint('Deferred startup maintenance failed: $e');
    debugPrint('Stack: $st');
  }
}

Future<void> _deferredProfileMaintenance() async {
  try {
    await _purgePreviewPlaceholderData();

    final profileRepo = ProfileRepository();
    final feedbackRepo = FeedbackRepository();
    final prof = profileRepo.getProfile();
    if (prof == null) return;
    await profileRepo.recomputeSocialStatsFromFeedback(
      feedbackRepo,
      prof.username,
    );
  } catch (e, st) {
    debugPrint('Deferred profile maintenance failed: $e');
    debugPrint('Stack: $st');
  }
}

/// Removes any layout-preview rows that may have been persisted during development.
Future<void> _purgePreviewPlaceholderData() async {
  final deckRepo = DeckRepository();
  final matchRepo = MatchRepository();
  // Purge legacy preview rows still in Hive (getAll* already hides them).
  final deckBox = Hive.box<PlayerDeck>('playerDecks');
  for (final key in deckBox.keys) {
    if (key is String && isPreviewPlaceholderDeckId(key)) {
      await deckRepo.delete(key);
    }
  }
  final matchBox = Hive.box<MatchRecord>('matchHistory');
  for (final key in matchBox.keys) {
    if (key is String && isPreviewPlaceholderMatchId(key)) {
      await matchRepo.deleteMatch(key);
    }
  }

  // Drop commander stats left from preview matches when history is empty.
  if (matchRepo.getAllMatches().isEmpty && Hive.isBoxOpen('commanderStats')) {
    await Hive.box<CommanderStats>('commanderStats').clear();
  }
}

class MgtLifeSparkApp extends ConsumerWidget {
  const MgtLifeSparkApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    dismissWebSplash();
    final router = ref.watch(routerProvider);

    final theme = ref.watch(effectiveThemeProvider);

    return MaterialApp.router(
      title: 'MTG Life Spark',
      theme: theme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) => SessionConnectionGuard(
        child: AppSystemUiScope(
          child: child ?? const SizedBox.shrink(),
        ),
      ),
    );
  }
}
