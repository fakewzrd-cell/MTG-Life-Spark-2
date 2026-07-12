import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/game/game_format.dart';
import '../../ui/theme/app_color_tokens.dart';
import '../../ui/tokens/font_tokens.dart';
import '../../ui/tokens/layout_tokens.dart';
import '../../ui/tokens/radius_tokens.dart';
import '../game/widgets/game_modal_chrome.dart';

/// Searchable list of [GameFormat] values for create/edit deck flows.
Future<GameFormat?> showGameFormatPickerSheet(
  BuildContext context, {
  GameFormat? selected,
}) {
  return showGameBottomSheet<GameFormat>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => _GameFormatPickerSheet(initial: selected),
  );
}

String _formatPickerSubtitle(GameFormat format) {
  if (format.isCommanderStyle) {
    return 'Multiplayer · ${format.defaultStartingLife} starting life';
  }
  return 'Constructed · ${format.defaultStartingLife} starting life';
}

class _GameFormatPickerSheet extends StatefulWidget {
  const _GameFormatPickerSheet({this.initial});

  final GameFormat? initial;

  @override
  State<_GameFormatPickerSheet> createState() => _GameFormatPickerSheetState();
}

class _GameFormatPickerSheetState extends State<_GameFormatPickerSheet> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<GameFormat> get _filtered {
    final q = _query.trim().toLowerCase();
    final ordered = GameFormatDetails.lobbyPickerOrder;
    if (q.isEmpty) return ordered;
    return ordered.where((f) {
      return f.displayName.toLowerCase().contains(q) ||
          f.name.contains(q);
    }).toList();
  }

  void _pick(GameFormat format) {
    HapticFeedback.selectionClick();
    Navigator.pop(context, format);
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTokens.of(context);
    final maxH = MediaQuery.sizeOf(context).height * 0.72;

    return SizedBox(
      height: maxH,
      child: GameSheetBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const GameSheetHeader(title: 'Format'),
            SizedBox(height: LayoutTokens.gr2),
            TextField(
              controller: _searchCtrl,
              scrollPadding: const EdgeInsets.only(bottom: 120),
              decoration: InputDecoration(
                hintText: 'Search formats…',
                prefixIcon: const Icon(Icons.search_rounded),
                hintStyle: TextStyle(color: colors.textSecondary),
              ),
              style: TextStyle(color: colors.textPrimary),
              onChanged: (v) => setState(() => _query = v),
            ),
            SizedBox(height: LayoutTokens.gr2),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.only(bottom: LayoutTokens.gr2),
                itemCount: _filtered.length,
                separatorBuilder: (_, _) =>
                    SizedBox(height: LayoutTokens.gr1),
                itemBuilder: (context, i) {
                  final format = _filtered[i];
                  final isSelected = widget.initial == format;
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _pick(format),
                      borderRadius: RadiusTokens.radiusSm,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? colors.primaryAccent.withValues(alpha: 0.12)
                              : colors.surface,
                          borderRadius: RadiusTokens.radiusSm,
                          border: Border.all(
                            color: isSelected
                                ? colors.primaryAccent.withValues(alpha: 0.5)
                                : colors.borderSubtle.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(LayoutTokens.gr2),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      format.displayName,
                                      style: TextStyle(
                                        color: colors.textPrimary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: FontTokens.body,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    Icon(
                                      Icons.check_circle_rounded,
                                      color: colors.primaryAccent,
                                      size: 20,
                                    ),
                                ],
                              ),
                              SizedBox(height: LayoutTokens.gr0),
                              Text(
                                _formatPickerSubtitle(format),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: colors.textSecondary,
                                  fontSize: FontTokens.sm,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tappable row showing the chosen format (matches [DeckStylePickerField]).
class GameFormatPickerField extends StatelessWidget {
  const GameFormatPickerField({
    required this.selected,
    required this.onPick,
  });

  final GameFormat selected;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTokens.of(context);

    return InkWell(
      onTap: onPick,
      borderRadius: RadiusTokens.radiusSm,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Format',
          labelStyle: TextStyle(color: colors.textSecondary),
          suffixIcon: Icon(
            Icons.unfold_more_rounded,
            color: colors.textSecondary,
          ),
        ),
        child: Text(
          selected.displayName,
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
