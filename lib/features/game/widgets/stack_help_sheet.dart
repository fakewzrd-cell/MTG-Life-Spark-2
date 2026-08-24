import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../l10n/app_localizations.dart';
import '../../../ui/components/ui_snack_bar.dart';
import '../../../ui/tokens/font_tokens.dart';
import '../../../ui/tokens/layout_tokens.dart';
import 'game_colors.dart';
import 'game_modal_chrome.dart';

const _kStackArticleUrl =
    'https://magic.wizards.com/en/news/feature/stack-and-its-tricks-2017-11-30';

/// Beginner-oriented explanation of the stack (shown from the Stack tab).
class StackHelpSheet extends StatelessWidget {
  const StackHelpSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showGameBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => const StackHelpSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.gameColors;
    return GameSheetBody(
      scrollable: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GameSheetHeader(title: l10n.stackHelpTitle),
          SizedBox(height: LayoutTokens.gr3),
          _Bullet(l10n.stackHelpBullet1),
          _Bullet(l10n.stackHelpBullet2),
          _Bullet(l10n.stackHelpBullet3),
          _Bullet(l10n.stackHelpBullet4),
          _Bullet(l10n.stackHelpBullet5),
          _Bullet(l10n.stackHelpBullet6),
          SizedBox(height: LayoutTokens.gr3),
          Text(
            l10n.stackHelpExample,
            style: TextStyle(
              fontSize: FontTokens.hudSm,
              color: colors.textSecondary.withValues(alpha: 0.95),
              height: 1.4,
            ),
          ),
          SizedBox(height: LayoutTokens.gr4),
          FilledButton.icon(
            onPressed: () => _openArticle(context),
            icon: Icon(Icons.open_in_new_rounded, size: 18),
            label: Text(l10n.stackHelpReadMore),
          ),
        ],
      ),
    );
  }

  Future<void> _openArticle(BuildContext context) async {
    final uri = Uri.parse(_kStackArticleUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        showUiSnackBar(
          context,
          AppLocalizations.of(context).stackHelpCouldNotOpenLink,
          isError: true,
        );
      }
    }
  }
}

class _Bullet extends StatelessWidget {
  final String text;

  const _Bullet(this.text);

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    return Padding(
      padding: EdgeInsets.only(bottom: LayoutTokens.gr2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 6, right: LayoutTokens.gr2),
            child: Icon(
              Icons.circle,
              size: 6,
              color: colors.primaryAccent,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: FontTokens.hudSm,
                color: colors.textPrimary.withValues(alpha: 0.92),
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
