import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/models/commander_stats.dart';
import 'core/models/player_profile.dart';
import 'core/models/match_record.dart';
import 'core/models/app_settings.dart';
import 'core/game/game_format.dart';
import 'core/models/player_deck.dart';
import 'core/persistence/deck_repository.dart';
import 'core/persistence/feedback_repository.dart';
import 'core/persistence/match_repository.dart';
import 'core/persistence/profile_repository.dart';
import 'core/debug/web_logo_splash.dart';
import 'core/network/session_connection_guard.dart';
import 'shared/theme/theme_provider.dart';
import 'shared/utils/app_router.dart';
import 'shared/widgets/branded_splash.dart';
import 'shared/utils/commander_image_resolver.dart';
import 'ui/tokens/color_tokens.dart';
import 'ui/theme/app_system_ui.dart';

Future<void> main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await AppSystemUi.bootstrap();

    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      if (kDebugMode) {
        debugPrint('FlutterError: ${details.exception}');
        debugPrint('Stack: ${details.stack}');
      }
    };

    runApp(
      const ProviderScope(
        child: AppAdaptiveOrientationScope(child: _AppBootstrap()),
      ),
    );
  }, (error, stack) {
    if (kDebugMode) {
      debugPrint('Zone error: $error');
      debugPrint('Stack: $stack');
    }
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
  var _initDone = false;
  var _revealDone = false;
  var _webEnterSignaled = false;

  void _signalWebEnterAfterFirstPaint() {
    if (_webEnterSignaled) return;
    _webEnterSignaled = true;
    // Wait until the real app has painted under the HTML layer, then dismiss —
    // otherwise removing the overlay reveals a black Flutter canvas.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        signalWebAppEntered();
      });
    });
  }

  void _forceDismissWebSplash() {
    if (_webEnterSignaled) return;
    _webEnterSignaled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      signalWebAppEntered();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          // Uncover the error UI — don't leave the HTML logo layer stuck.
          _forceDismissWebSplash();
          return _ErrorApp(
            message: snapshot.error.toString(),
            stack: snapshot.stackTrace.toString(),
          );
        }
        if (snapshot.connectionState == ConnectionState.done && !_initDone) {
          _initDone = true;
          // Defer so we don't setState during build. Do NOT dismiss the HTML
          // splash here — it owns the logo video on web and must finish once.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() {});
          });
        }
        if (_initDone && _revealDone) {
          _signalWebEnterAfterFirstPaint();
          return const MgtLifeSparkApp();
        }
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: BrandedSplash(
            ready: _initDone,
            onRevealComplete: () {
              if (!mounted || _revealDone) return;
              setState(() => _revealDone = true);
            },
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
  Hive.registerAdapter(AppSettingsAdapter());
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
    Hive.openBox<AppSettings>('appSettings'),
    Hive.openBox<String>('matchFeedback'),
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
    if (kDebugMode) {
      debugPrint('Deferred startup maintenance failed: $e');
      debugPrint('Stack: $st');
    }
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
      prof.playerId,
    );
  } catch (e, st) {
    if (kDebugMode) {
      debugPrint('Deferred profile maintenance failed: $e');
      debugPrint('Stack: $st');
    }
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

  await _migrateDeckFormats(deckBox);
}

/// Backfill [PlayerDeck.format] for decks saved before format categorization.
Future<void> _migrateDeckFormats(Box<PlayerDeck> deckBox) async {
  for (final deck in deckBox.values) {
    if (deck.format.isEmpty) {
      deck.format = GameFormat.commander.name;
      await deck.save();
    }
  }
}

class MgtLifeSparkApp extends ConsumerWidget {
  const MgtLifeSparkApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Web HTML splash is dismissed by _AppBootstrap after first paint — do not
    // tear it down here or the overlay vanishes before this frame is on screen.
    final router = ref.watch(routerProvider);

    final lightTheme = ref.watch(appLightThemeProvider);
    final darkTheme = ref.watch(appDarkThemeProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Life Spark',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
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
