import 'package:flutter/material.dart';

import '../../ui/tokens/layout_tokens.dart';
import '../game/widgets/game_modal_chrome.dart';

/// Shared layout for Format / Deck style searchable pickers.
///
/// - Sheet hugs short lists (no forced empty band under the last row)
/// - Caps tall lists with a real [ConstrainedBox] so they scroll inside
/// - Uses [ConstrainedBox], not [LimitedBox] — LimitedBox is a no-op when the
///   parent already passes a finite max height (as bottom sheets do)
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
    final media = MediaQuery.of(context);
    final maxSheetH = media.size.height * maxSheetFraction;
    final maxListH =
        (maxSheetH - _chromeReserve).clamp(140.0, maxSheetH * 0.68);
    final keyboardInset = media.viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: keyboardInset),
      child: ConstrainedBox(
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
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: maxListH),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
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
      ),
    );
  }
}
