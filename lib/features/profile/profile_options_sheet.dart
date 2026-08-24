import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/app_localizations.dart';
import '../../ui/theme/app_color_tokens.dart';
import '../../ui/tokens/font_tokens.dart';
import '../../ui/tokens/layout_tokens.dart';
import '../game/widgets/game_modal_chrome.dart';

/// Actions from the profile hero overflow sheet.
enum ProfileSheetAction {
  editProfile,
  backupProfile,
}

/// Quiet listing: Edit profile + Back up profile.
Future<ProfileSheetAction?> showProfileOptionsSheet(BuildContext context) {
  return showGameBottomSheet<ProfileSheetAction>(
    context: context,
    showDragHandle: true,
    builder: (ctx) => const _ProfileOptionsSheet(),
  );
}

class _ProfileOptionsSheet extends StatelessWidget {
  const _ProfileOptionsSheet();

  void _pick(BuildContext context, ProfileSheetAction action) {
    HapticFeedback.selectionClick();
    Navigator.pop(context, action);
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTokens.of(context);
    final l10n = AppLocalizations.of(context);
    return GameSheetBody(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GameSheetHeader(
            title: l10n.profileOptionsTitle,
            showHandle: false,
          ),
          SizedBox(height: LayoutTokens.gr2),
          _ProfileOptionTile(
            colors: colors,
            icon: Icons.edit_rounded,
            title: l10n.profileOptionsEdit,
            subtitle: l10n.profileOptionsEditSubtitle,
            onTap: () => _pick(context, ProfileSheetAction.editProfile),
          ),
          _ProfileOptionTile(
            colors: colors,
            icon: Icons.ios_share_rounded,
            title: l10n.profileOptionsBackup,
            subtitle: l10n.profileOptionsBackupSubtitle,
            onTap: () => _pick(context, ProfileSheetAction.backupProfile),
          ),
        ],
      ),
    );
  }
}

class _ProfileOptionTile extends StatelessWidget {
  const _ProfileOptionTile({
    required this.colors,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final AppColorTokens colors;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: colors.textSecondary, size: 22),
      title: Text(
        title,
        style: TextStyle(
          color: colors.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: FontTokens.body,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: colors.textSecondary,
          fontSize: FontTokens.sm,
        ),
      ),
      onTap: onTap,
    );
  }
}
