import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/game/game_providers.dart';
import '../../../core/game/game_session_events.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/utils/game_haptics.dart';
import '../../../ui/tokens/font_tokens.dart';
import '../../../ui/tokens/layout_tokens.dart';
import '../../../ui/tokens/opacity_tokens.dart';
import '../../../ui/tokens/radius_tokens.dart';
import 'game_colors.dart';
import 'game_modal_chrome.dart';

/// Mid-match dice / coin tools — results are shared with the whole table.
Future<void> showTableToolsSheet(BuildContext context) {
  return showGameBottomSheet<void>(
    context: context,
    builder: (ctx) => const _TableToolsSheet(),
  );
}

enum _ToolKind { d6, d20, coin }

class _TableToolsSheet extends ConsumerStatefulWidget {
  const _TableToolsSheet();

  @override
  ConsumerState<_TableToolsSheet> createState() => _TableToolsSheetState();
}

class _TableToolsSheetState extends ConsumerState<_TableToolsSheet> {
  _ToolKind _kind = _ToolKind.d6;

  void _roll() {
    context.gameHapticMedium();
    final tool = switch (_kind) {
      _ToolKind.d6 => TableToolKind.d6,
      _ToolKind.d20 => TableToolKind.d20,
      _ToolKind.coin => TableToolKind.coin,
    };
    ref.read(gameProvider.notifier).announceTableToolRoll(tool);
    if (mounted) Navigator.of(context).maybePop();
  }

  void _select(_ToolKind kind) {
    if (_kind == kind) return;
    context.gameHapticSelection();
    setState(() => _kind = kind);
  }

  String _actionLabel(AppLocalizations l10n) => switch (_kind) {
        _ToolKind.d6 => l10n.tableToolsRollD6,
        _ToolKind.d20 => l10n.tableToolsRollD20,
        _ToolKind.coin => l10n.tableToolsFlipCoin,
      };

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    final l10n = AppLocalizations.of(context);
    return GameSheetBody(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GameSheetHeader(
            title: l10n.tableToolsTitle,
            subtitle: l10n.tableToolsSubtitle,
          ),
          SizedBox(height: LayoutTokens.gr3),
          Row(
            children: [
              Expanded(
                child: _ToolChip(
                  label: l10n.tableToolsD6,
                  selected: _kind == _ToolKind.d6,
                  onTap: () => _select(_ToolKind.d6),
                ),
              ),
              SizedBox(width: LayoutTokens.gr1),
              Expanded(
                child: _ToolChip(
                  label: l10n.tableToolsD20,
                  selected: _kind == _ToolKind.d20,
                  onTap: () => _select(_ToolKind.d20),
                ),
              ),
              SizedBox(width: LayoutTokens.gr1),
              Expanded(
                child: _ToolChip(
                  label: l10n.tableToolsCoin,
                  selected: _kind == _ToolKind.coin,
                  onTap: () => _select(_ToolKind.coin),
                ),
              ),
            ],
          ),
          SizedBox(height: LayoutTokens.gr4),
          SizedBox(
            height: 72,
            child: Center(
              child: Text(
                l10n.tableToolsResultHint,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: FontTokens.body,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          SizedBox(height: LayoutTokens.gr3),
          SizedBox(
            height: LayoutTokens.minTapTarget + 8,
            width: double.infinity,
            child: FilledButton(
              onPressed: _roll,
              style: FilledButton.styleFrom(
                backgroundColor: colors.primaryAccent,
                foregroundColor: colors.onAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: RadiusTokens.radiusControlSm,
                ),
              ),
              child: Text(
                _actionLabel(l10n),
                style: TextStyle(
                  fontSize: FontTokens.title,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          SizedBox(height: LayoutTokens.gr1),
        ],
      ),
    );
  }
}

class _ToolChip extends StatelessWidget {
  const _ToolChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    return Material(
      color: selected
          ? colors.primaryAccent.withValues(alpha: OpacityTokens.soft)
          : colors.backgroundSecondary.withValues(alpha: 0.55),
      borderRadius: RadiusTokens.radiusControlSm,
      child: InkWell(
        onTap: onTap,
        borderRadius: RadiusTokens.radiusControlSm,
        child: SizedBox(
          height: LayoutTokens.minTapTarget,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? colors.primaryAccent : colors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: FontTokens.body,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
