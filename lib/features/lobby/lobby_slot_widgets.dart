import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/models/player_slot.dart';
import '../../ui/theme/app_color_tokens.dart';
import '../../ui/tokens/color_tokens.dart';
import '../../ui/tokens/font_tokens.dart';
import '../../ui/tokens/layout_tokens.dart';
import '../../ui/tokens/opacity_tokens.dart';
import '../../ui/tokens/radius_tokens.dart';

/// Shared surface chrome for host/join lobby player cards — tonal, borderless.
class LobbySlotCardShell extends StatelessWidget {
  const LobbySlotCardShell({
    super.key,
    required this.child,
    this.emphasized = false,
    this.emphasizeColor,
    this.compact = false,
  });

  final bool emphasized;
  final Color? emphasizeColor;
  final bool compact;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTokens.of(context);
    final fill = emphasized
        ? (emphasizeColor ?? colors.primaryAccent)
            .withValues(alpha: OpacityTokens.subtle)
        : colors.surface;
    return Container(
      margin: EdgeInsets.only(bottom: LayoutTokens.gr2),
      padding: EdgeInsets.all(compact ? LayoutTokens.gr2 : LayoutTokens.gr3),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: RadiusTokens.radiusMd,
      ),
      child: child,
    );
  }
}

/// Color dot + player username.
class LobbyPlayerIdentityRow extends StatelessWidget {
  const LobbyPlayerIdentityRow({
    super.key,
    required this.username,
    required this.playerColor,
  });

  final String username;
  final Color playerColor;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTokens.of(context);
    return Row(
      children: [
        Container(
          width: LayoutTokens.gr1,
          height: LayoutTokens.gr1,
          decoration: BoxDecoration(
            color: playerColor,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: LayoutTokens.gr1),
        Expanded(
          child: Text(
            username,
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: FontTokens.title,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}

/// Commander art or color fallback for lobby slots.
class LobbySlotAvatar extends StatelessWidget {
  const LobbySlotAvatar({
    super.key,
    required this.slot,
    this.size,
  });

  final PlayerSlot slot;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final resolved =
        size ?? LayoutTokens.gr6 + LayoutTokens.gr0;
    if (slot.commanderImageUrl != null) {
      return ClipRRect(
        borderRadius: RadiusTokens.radiusControlMd,
        child: CachedNetworkImage(
          imageUrl: slot.commanderImageUrl!,
          width: resolved,
          height: resolved,
          fit: BoxFit.cover,
          errorWidget: (_, _, _) =>
              _LobbyColorDot(color: slot.playerColor, size: resolved),
        ),
      );
    }
    return _LobbyColorDot(color: slot.playerColor, size: resolved);
  }
}

class _LobbyColorDot extends StatelessWidget {
  const _LobbyColorDot({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.25),
        borderRadius: RadiusTokens.radiusControlMd,
      ),
      child: Icon(Icons.person, color: color, size: size * 0.56),
    );
  }
}

/// Ready / Waiting status pill for remote players.
class LobbyReadyBadge extends StatelessWidget {
  const LobbyReadyBadge({super.key, required this.isReady});

  final bool isReady;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTokens.of(context);
    final tone = isReady ? colors.primaryAccent : colors.textSecondary;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: LayoutTokens.gr1,
        vertical: LayoutTokens.gr0,
      ),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: OpacityTokens.soft),
        borderRadius: RadiusTokens.radiusXs,
      ),
      child: Text(
        isReady ? 'Ready' : 'Waiting',
        style: TextStyle(
          color: tone,
          fontSize: FontTokens.sm,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Shared lobby action button (Deck / Commander / Mark ready).
class LobbyActionButton extends StatelessWidget {
  const LobbyActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.highlighted = false,
    this.filled = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool highlighted;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTokens.of(context);
    final accent = colors.primaryAccent;

    late final Color? bg;
    late final Color fg;

    if (filled && highlighted) {
      bg = accent;
      fg = ColorTokens.onAccent;
    } else if (highlighted) {
      bg = accent.withValues(alpha: OpacityTokens.soft);
      fg = colors.textPrimary;
    } else {
      bg = colors.surface;
      fg = colors.textPrimary;
    }

    return TextButton(
      style: TextButton.styleFrom(
        minimumSize: const Size(0, LayoutTokens.minTapTarget),
        padding: EdgeInsets.symmetric(
          horizontal: LayoutTokens.gr2,
          vertical: LayoutTokens.gr1,
        ),
        backgroundColor: bg,
        foregroundColor: fg,
        shape: RoundedRectangleBorder(
          borderRadius: RadiusTokens.radiusControlSm,
        ),
        textStyle: TextStyle(
          fontSize: FontTokens.sm,
          fontWeight: FontWeight.w600,
        ),
      ),
      onPressed: onPressed,
      child: Text(
        label,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
