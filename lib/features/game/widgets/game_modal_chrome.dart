import 'package:flutter/material.dart';

import '../../../ui/tokens/color_tokens.dart';
import '../../../ui/tokens/font_tokens.dart';
import '../../../ui/tokens/layout_tokens.dart';
import '../../../ui/tokens/motion_tokens.dart';
import '../../../ui/tokens/opacity_tokens.dart';
import '../../../ui/tokens/radius_tokens.dart';
import 'game_colors.dart';

/// Shared dialog and bottom-sheet chrome for in-game modals.
abstract final class GameModalChrome {
  static double horizontalInset(BuildContext context) =>
      LayoutTokens.shellPageInset;

  static TextStyle dialogTitleStyle(BuildContext context) {
    final colors = context.gameColors;
    return TextStyle(
      color: colors.textPrimary,
      fontSize: FontTokens.title,
      fontWeight: FontWeight.w700,
    );
  }

  static TextStyle dialogBodyStyle(BuildContext context) {
    final colors = context.gameColors;
    return TextStyle(
      color: colors.textSecondary.withValues(alpha: OpacityTokens.strong),
      fontSize: FontTokens.hudSm,
      height: 1.4,
    );
  }

  static TextStyle sheetTitleStyle(BuildContext context) {
    final colors = context.gameColors;
    return TextStyle(
      color: colors.textPrimary,
      fontSize: FontTokens.title,
      fontWeight: FontWeight.w700,
    );
  }

  static EdgeInsets sheetPadding(BuildContext context) {
    final h = horizontalInset(context);
    final bottom = MediaQuery.paddingOf(context).bottom;
    return EdgeInsets.fromLTRB(h, LayoutTokens.gr2, h, bottom + LayoutTokens.gr3);
  }
}

/// Rounded X for game [AlertDialog] title rows.
class GameDialogCloseButton extends StatelessWidget {
  const GameDialogCloseButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    return Semantics(
      button: true,
      label: 'Close',
      child: Material(
        color: colors.backgroundSecondary.withValues(alpha: 0.92),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: IconButton(
          onPressed: onPressed,
          icon: Icon(
            Icons.close_rounded,
            size: 20,
            color: colors.textSecondary.withValues(alpha: 0.9),
          ),
          tooltip: 'Close',
          padding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
          constraints: const BoxConstraints(
            minWidth: LayoutTokens.minTapTarget,
            minHeight: LayoutTokens.minTapTarget,
          ),
        ),
      ),
    );
  }
}

/// Title row: [title] or [titleWidget] + close button.
class GameDialogTitleRow extends StatelessWidget {
  const GameDialogTitleRow({
    super.key,
    this.title,
    this.titleWidget,
    required this.onClose,
  }) : assert(title != null || titleWidget != null);

  final String? title;
  final Widget? titleWidget;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: titleWidget ??
              Text(title!, style: GameModalChrome.dialogTitleStyle(context)),
        ),
        GameDialogCloseButton(onPressed: onClose),
      ],
    );
  }
}

/// Drag pill used at the top of game bottom sheets.
class GameSheetHandle extends StatelessWidget {
  const GameSheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: colors.textSecondary.withValues(alpha: 0.22),
          borderRadius: RadiusTokens.radiusPill,
        ),
      ),
    );
  }
}

/// Standard sheet header: handle, title, optional subtitle.
class GameSheetHeader extends StatelessWidget {
  const GameSheetHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.showHandle = true,
  });

  final String title;
  final String? subtitle;
  final bool showHandle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showHandle) ...[
          const GameSheetHandle(),
          SizedBox(height: LayoutTokens.gr2),
        ],
        Text(title, style: GameModalChrome.sheetTitleStyle(context)),
        if (subtitle != null) ...[
          SizedBox(height: LayoutTokens.gr1),
          Text(subtitle!, style: GameModalChrome.dialogBodyStyle(context)),
        ],
      ],
    );
  }
}

/// Wraps sheet body with standard padding and optional scroll.
class GameSheetBody extends StatelessWidget {
  const GameSheetBody({
    super.key,
    required this.child,
    this.scrollable = false,
  });

  final Widget child;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final pad = GameModalChrome.sheetPadding(context);
    final content = scrollable
        ? SingleChildScrollView(padding: pad, child: child)
        : Padding(padding: pad, child: child);
    return SafeArea(top: false, child: content);
  }
}

Future<T?> showGameBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = false,
  bool showDragHandle = false,
  bool enableDrag = true,
  Color? backgroundColor,
}) {
  final sheetColor = backgroundColor ?? context.gameColors.surface;
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: sheetColor,
    isScrollControlled: isScrollControlled,
    showDragHandle: showDragHandle,
    enableDrag: enableDrag,
    sheetAnimationStyle: AnimationStyle(
      duration: MotionTokens.slow,
      reverseDuration: MotionTokens.standard,
      curve: MotionTokens.easeOut,
      reverseCurve: MotionTokens.exit,
    ),
    shape: const RoundedRectangleBorder(
      borderRadius: RadiusTokens.radiusSheetTop,
    ),
    builder: builder,
  );
}

/// Confirm dialog: title, body, single primary action; dismiss via X.
Future<bool?> showGameConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  required String confirmLabel,
  bool destructive = false,
  bool barrierDismissible = true,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (ctx) {
      final colors = ctx.gameColors;
      return AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: RadiusTokens.radiusMd,
          side: BorderSide(color: colors.backgroundSecondary),
        ),
        title: GameDialogTitleRow(
          title: title,
          onClose: () => Navigator.pop(ctx, false),
        ),
        content: Text(message, style: GameModalChrome.dialogBodyStyle(ctx)),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: destructive
                ? FilledButton.styleFrom(backgroundColor: ColorTokens.danger)
                : FilledButton.styleFrom(backgroundColor: colors.primaryAccent),
            child: Text(confirmLabel),
          ),
        ],
      );
    },
  );
}

/// Two-action dialog: X to cancel, [secondaryLabel] + [primaryLabel].
Future<bool?> showGameChoiceDialog({
  required BuildContext context,
  required String title,
  required Widget content,
  required String primaryLabel,
  String? secondaryLabel,
  bool primaryDestructive = false,
  bool barrierDismissible = true,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (ctx) {
      final colors = ctx.gameColors;
      return AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: RadiusTokens.radiusMd,
          side: BorderSide(color: colors.backgroundSecondary),
        ),
        title: GameDialogTitleRow(
          title: title,
          onClose: () => Navigator.pop(ctx, false),
        ),
        content: content,
        actions: [
          if (secondaryLabel != null)
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(
                secondaryLabel,
                style: TextStyle(color: colors.textSecondary),
              ),
            ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: primaryDestructive
                ? FilledButton.styleFrom(backgroundColor: ColorTokens.danger)
                : FilledButton.styleFrom(backgroundColor: colors.primaryAccent),
            child: Text(primaryLabel),
          ),
        ],
      );
    },
  );
}
