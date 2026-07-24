import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/game/game_log_entry.dart';
import '../../../core/game/game_providers.dart';
import '../../../ui/tokens/font_tokens.dart';
import '../../../ui/tokens/layout_tokens.dart';
import '../../../ui/tokens/opacity_tokens.dart';
import '../../../ui/tokens/radius_tokens.dart';
import 'game_colors.dart';
import 'game_modal_chrome.dart';

/// Opens the session action log from Table overview (sheet, not a hub tab).
Future<void> showGameHistorySheet(BuildContext context) {
  return showGameBottomSheet<void>(
    context: context,
    builder: (ctx) {
      final maxH = MediaQuery.sizeOf(ctx).height * 0.88;
      const chromeReserve = 96.0;
      final maxListH = (maxH - chromeReserve).clamp(160.0, maxH);
      return ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxH),
        child: GameSheetBody(
          child: Consumer(
            builder: (context, ref, _) {
              final entries = ref.watch(
                gameProvider.select((g) => g.sessionActionLog),
              );
              final localId = ref.watch(
                gameProvider.select((g) => g.localPlayerId),
              );
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const GameSheetHeader(
                    title: 'History',
                    subtitle: 'Life, counters, and other table actions.',
                  ),
                  SizedBox(height: LayoutTokens.gr2),
                  LimitedBox(
                    maxHeight: maxListH,
                    child: GameHistoryList(
                      entries: entries,
                      localPlayerId: localId,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      );
    },
  );
}

/// Turn-grouped session action log body (used by the overview History sheet).
class GameHistoryList extends StatelessWidget {
  final List<GameLogEntry> entries;
  final String localPlayerId;

  const GameHistoryList({
    super.key,
    required this.entries,
    required this.localPlayerId,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    if (entries.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: LayoutTokens.gr4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.history_rounded,
              size: 40,
              color: colors.textSecondary.withValues(alpha: 0.5),
            ),
            SizedBox(height: LayoutTokens.gr2),
            Text(
              'No actions yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: FontTokens.body,
              ),
            ),
            SizedBox(height: LayoutTokens.gr1),
            Text(
              'Life changes, counters, and other table actions '
              'will show up here as the game goes on.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.textSecondary
                    .withValues(alpha: OpacityTokens.nearOpaque),
                fontSize: FontTokens.hudSm,
                height: 1.4,
              ),
            ),
          ],
        ),
      );
    }

    final grouped = <int, List<GameLogEntry>>{};
    for (final e in entries) {
      grouped.putIfAbsent(e.turnNumber, () => []).add(e);
    }
    final turns = grouped.keys.toList()..sort();

    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.only(bottom: LayoutTokens.gr2),
      itemCount: turns.length,
      itemBuilder: (context, ti) {
        final turn = turns[ti];
        final rows = grouped[turn]!;
        return Padding(
          padding: EdgeInsets.only(bottom: LayoutTokens.gr3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Turn $turn',
                style: TextStyle(
                  color: colors.primaryAccent,
                  fontWeight: FontWeight.w800,
                  fontSize: FontTokens.title,
                ),
              ),
              SizedBox(height: LayoutTokens.gr1),
              ...rows.map(
                (e) {
                  final affectsYou = _entryAffectsLocalPlayer(
                    e.message,
                    localPlayerId,
                  );
                  return Padding(
                    padding: EdgeInsets.only(bottom: LayoutTokens.gr1),
                    child: Container(
                      decoration: affectsYou
                          ? BoxDecoration(
                              color: colors.emphasis.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: RadiusTokens.radiusSm,
                              border: Border.all(
                                color: colors.emphasis.withValues(
                                  alpha: 0.35,
                                ),
                              ),
                            )
                          : null,
                      padding: affectsYou
                          ? EdgeInsets.all(LayoutTokens.gr1)
                          : EdgeInsets.zero,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (affectsYou) ...[
                            Icon(
                              Icons.person_pin,
                              size: 16,
                              color: colors.emphasis,
                            ),
                            SizedBox(width: LayoutTokens.gr1),
                          ],
                          Text(
                            _formatTime(e.time),
                            style: TextStyle(
                              fontSize: FontTokens.hudXs,
                              color: colors.textSecondary.withValues(
                                alpha: 0.85,
                              ),
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                          SizedBox(width: LayoutTokens.gr2),
                          Expanded(
                            child: Text(
                              e.message,
                              style: TextStyle(
                                color: affectsYou
                                    ? colors.emphasis
                                    : colors.textPrimary,
                                fontSize: FontTokens.hudSm,
                                fontWeight: affectsYou
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                height: 1.25,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  static bool _entryAffectsLocalPlayer(String message, String localPlayerId) {
    if (localPlayerId.isEmpty) return false;
    final lower = message.toLowerCase();
    return lower.contains('dealt you') ||
        lower.contains('changed your') ||
        lower.contains('(you)') ||
        lower.startsWith('you ');
  }

  static String _formatTime(DateTime t) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(t.hour)}:${two(t.minute)}';
  }
}
