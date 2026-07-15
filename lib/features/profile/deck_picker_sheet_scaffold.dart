import 'package:flutter/material.dart';

import '../../ui/tokens/layout_tokens.dart';
import '../game/widgets/game_modal_chrome.dart';

/// Shared layout for Format / Deck style searchable pickers.
///
/// - Sheet hugs short lists (no forced 72% empty band)
/// - Caps tall lists and scrolls inside [LimitedBox]
/// - Avoids `Column(mainAxisSize: min)` + `Flexible`, which collapses the
///   list viewport and clips bottom rows
class DeckPickerSheetScaffold extends StatelessWidget {
  const DeckPickerSheetScaffold({
    super.key,
    required this.title,
    required this.searchField,
    required this.itemCount,
    required this.itemBuilder,
    this.separatorHeight = LayoutTokens.gr1,
  });

  final String title;
  final Widget searchField;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final double separatorHeight;

  /// Max fraction of screen height for the whole sheet.
  static const double maxSheetFraction = 0.72;

  /// Approx chrome above the list (handle, title, search, gaps, padding).
  static const double _chromeReserve = 188;

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.sizeOf(context).height;
    final maxSheetH = screenH * maxSheetFraction;
    final maxListH =
        (maxSheetH - _chromeReserve).clamp(140.0, maxSheetH * 0.68);

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxSheetH),
      child: GameSheetBody(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GameSheetHeader(title: title),
            SizedBox(height: LayoutTokens.gr2),
            searchField,
            SizedBox(height: LayoutTokens.gr2),
            LimitedBox(
              maxHeight: maxListH,
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.only(bottom: LayoutTokens.gr2),
                itemCount: itemCount,
                separatorBuilder: (_, _) =>
                    SizedBox(height: separatorHeight),
                itemBuilder: itemBuilder,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
