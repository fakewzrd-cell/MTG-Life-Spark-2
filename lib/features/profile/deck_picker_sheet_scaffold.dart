import 'package:flutter/material.dart';

import '../../ui/tokens/layout_tokens.dart';
import '../game/widgets/game_modal_chrome.dart';

/// Shared layout for Format / Deck style searchable pickers.
///
/// - Sheet hugs short lists (no forced empty band under the last row)
/// - Caps tall lists with [Flexible] + [FlexFit.loose] so chrome growth
///   (large text / long titles) cannot overflow the sheet
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

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final maxSheetH = media.size.height * maxSheetFraction;
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
              Flexible(
                fit: FlexFit.loose,
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  padding: EdgeInsets.only(bottom: LayoutTokens.gr2),
                  itemCount: itemCount,
                  separatorBuilder: (_, __) =>
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
