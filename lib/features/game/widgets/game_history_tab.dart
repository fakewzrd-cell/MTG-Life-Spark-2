import 'package:flutter/material.dart';

import '../../../core/game/game_log_entry.dart';
import '../../../ui/tokens/font_tokens.dart';
import '../../../ui/tokens/layout_tokens.dart';
import '../../../ui/tokens/opacity_tokens.dart';
import 'game_colors.dart';

class GameHistoryTab extends StatelessWidget {
  final List<GameLogEntry> entries;

  const GameHistoryTab({required this.entries});

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    if (entries.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(LayoutTokens.gr4),
          child: Text(
            'No actions logged yet.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.textSecondary.withValues(alpha: OpacityTokens.nearOpaque),
              fontSize: 14,
            ),
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
                (e) => Padding(
                  padding: EdgeInsets.only(bottom: LayoutTokens.gr1),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatTime(e.time),
                        style: TextStyle(
                          fontSize: FontTokens.hudXs,
                          color: colors.textSecondary.withValues(alpha: 0.85),
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      SizedBox(width: LayoutTokens.gr2),
                      Expanded(
                        child: Text(
                          e.message,
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontSize: FontTokens.hudSm,
                            height: 1.25,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static String _formatTime(DateTime t) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(t.hour)}:${two(t.minute)}';
  }
}
