import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/models/deck_style.dart';
import '../../ui/theme/app_color_tokens.dart';
import '../../ui/tokens/font_tokens.dart';
import '../../ui/tokens/layout_tokens.dart';
import '../../ui/tokens/radius_tokens.dart';
import '../game/widgets/game_modal_chrome.dart';
import 'deck_picker_sheet_scaffold.dart';

/// Searchable list of [DeckStyle] values for create/edit deck flows.
Future<DeckStyle?> showDeckStylePickerSheet(
  BuildContext context, {
  DeckStyle? selected,
}) {
  return showGameBottomSheet<DeckStyle>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => _DeckStylePickerSheet(initial: selected),
  );
}

class _DeckStylePickerSheet extends StatefulWidget {
  const _DeckStylePickerSheet({this.initial});

  final DeckStyle? initial;

  @override
  State<_DeckStylePickerSheet> createState() => _DeckStylePickerSheetState();
}

class _DeckStylePickerSheetState extends State<_DeckStylePickerSheet> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<DeckStyle> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return DeckStyle.values;
    return DeckStyle.values.where((s) {
      return s.displayName.toLowerCase().contains(q) ||
          s.description.toLowerCase().contains(q) ||
          s.id.contains(q);
    }).toList();
  }

  void _pick(DeckStyle style) {
    HapticFeedback.selectionClick();
    Navigator.pop(context, style);
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTokens.of(context);

    return DeckPickerSheetScaffold(
      title: 'Deck style',
      searchField: TextField(
        controller: _searchCtrl,
        scrollPadding: const EdgeInsets.only(bottom: 120),
        decoration: InputDecoration(
          hintText: 'Search styles…',
          prefixIcon: const Icon(Icons.search_rounded),
          hintStyle: TextStyle(color: colors.textSecondary),
        ),
        style: TextStyle(color: colors.textPrimary),
        onChanged: (v) => setState(() => _query = v),
      ),
      itemCount: _filtered.length,
      itemBuilder: (context, i) {
        final style = _filtered[i];
        final isSelected = widget.initial == style;
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _pick(style),
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
                            style.displayName,
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
                      style.description,
                      maxLines: 3,
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
    );
  }
}

/// Tappable row showing the chosen style (or placeholder).
class DeckStylePickerField extends StatelessWidget {
  const DeckStylePickerField({
    required this.selected,
    required this.onPick,
    this.errorText,
  });

  final DeckStyle? selected;
  final VoidCallback onPick;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTokens.of(context);
    final label = selected?.displayName ?? 'Choose deck style';
    final hasError = errorText != null && errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: onPick,
          borderRadius: RadiusTokens.radiusSm,
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: 'Deck style',
              labelStyle: TextStyle(color: colors.textSecondary),
              errorText: hasError ? errorText : null,
              suffixIcon: Icon(
                Icons.unfold_more_rounded,
                color: colors.textSecondary,
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: selected != null
                    ? colors.textPrimary
                    : colors.textSecondary,
                fontWeight:
                    selected != null ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
