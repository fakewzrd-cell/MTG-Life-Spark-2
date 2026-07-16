import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/persistence/providers.dart';
import '../../../ui/theme/app_color_tokens.dart';
import '../../../ui/tokens/font_tokens.dart';
import '../../../ui/tokens/layout_tokens.dart';
import '../../../ui/tokens/opacity_tokens.dart';
import '../../../ui/tokens/radius_tokens.dart';

/// One-time tip under the life counter — dismiss and it stays gone.
class LifeGestureHintBanner extends ConsumerWidget {
  const LifeGestureHintBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(settingsRevisionProvider);
    final settings = ref.read(settingsRepositoryProvider).settings;
    if (settings.lifeGestureHintDismissed) {
      return const SizedBox.shrink();
    }

    final colors = AppColorTokens.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: LayoutTokens.gr1),
      child: Material(
        color: colors.surface.withValues(alpha: OpacityTokens.nearOpaque),
        borderRadius: RadiusTokens.radiusControlSm,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            LayoutTokens.gr2,
            LayoutTokens.gr1,
            LayoutTokens.gr0,
            LayoutTokens.gr1,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Hold ±5 · drag to adjust · double-tap to set',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: FontTokens.caption,
                    fontWeight: FontWeight.w500,
                    height: 1.25,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Dismiss tip',
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: LayoutTokens.minTapTarget,
                  minHeight: LayoutTokens.minTapTarget,
                ),
                icon: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: colors.textSecondary,
                ),
                onPressed: () async {
                  settings.lifeGestureHintDismissed = true;
                  await ref.read(settingsRepositoryProvider).update(settings);
                  bumpSettingsRevision(ref);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
