import 'package:flutter/material.dart';

import '../../../core/game/game_log_entry.dart';
import '../../../ui/tokens/font_tokens.dart';
import '../../../ui/tokens/layout_tokens.dart';
import '../../../ui/tokens/opacity_tokens.dart';
import '../../../ui/tokens/radius_tokens.dart';
import 'game_colors.dart';

class GameHistoryTab extends StatelessWidget {
  final List<GameLogEntry> entries;
  final String localPlayerId;

  const GameHistoryTab({
    required this.entries,
    required this.localPlayerId,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    if (entries.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(LayoutTokens.gr4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.history_rounded,
                size: 48,
                color: colors.textSecondary.withValues(alpha: 0.5),
              ),
              SizedBox(height: LayoutTokens.gr3),
              Text(
                'No actions yet',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: FontTokens.body,
                ),
              ),
              SizedBox(height: LayoutTokens.gr2),
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
        ),
      );
    }

    final grouped = <int, List<GameLogEntry>>{};
    for (final e in entries) {
      grouped.putIfAbsent(e.turnNumber, () => []).add(e);
    }
    final turns = grouped.keys.toList()..sort();

    final bottomSafe = MediaQuery.paddingOf(context).bottom;

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
        LayoutTokens.gr3,
        LayoutTokens.gr2,
        LayoutTokens.gr3,
        LayoutTokens.gr4 + bottomSafe,
      ),
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
