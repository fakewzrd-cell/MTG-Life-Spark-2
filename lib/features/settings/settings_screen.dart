import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/debug/app_log.dart';
import '../../core/game/game_format.dart';
import '../../core/models/app_settings.dart';
import '../../core/persistence/providers.dart';
import '../../shared/theme/theme_provider.dart';
import '../../shared/utils/app_router.dart';
import '../../shared/widgets/brand_logo.dart';
import '../../ui/components/ui_app_bar.dart';
import '../../ui/components/ui_snack_bar.dart';
import '../../ui/components/ui_surface.dart';
import '../../ui/theme/app_color_tokens.dart';
import '../../ui/tokens/app_color_palettes.dart';
import '../../ui/tokens/color_tokens.dart';
import '../../ui/tokens/font_tokens.dart';
import '../../ui/tokens/layout_tokens.dart';
import '../../ui/tokens/radius_tokens.dart';
import '../../ui/tokens/typography_tokens.dart';
import '../game/widgets/game_modal_chrome.dart';
import '../game/widgets/hub_guide_sheet.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late AppSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = ref.read(settingsRepositoryProvider).settings;
  }

  Future<void> _save() async {
    await ref.read(settingsRepositoryProvider).update(_settings);
    bumpSettingsRevision(ref);
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(settingsRevisionProvider, (_, __) {
      if (!mounted) return;
      setState(() {
        _settings = ref.read(settingsRepositoryProvider).settings;
      });
    });
    final colors = AppColorTokens.of(context);
    return Scaffold(
      appBar: const UiAppBar(title: 'Settings'),
      backgroundColor: colors.backgroundPrimary,
      body: ListView(
        padding: LayoutTokens.shellListPadding(context, top: LayoutTokens.gr4),
        children: [
          _SectionHeader('Gameplay'),
          _SettingTile(
            title: 'Default Format',
            subtitle: '${_settings.defaultFormat} · used when you host',
            onTap: () async {
              final picked = await _pickFormat(context);
              if (picked != null && mounted) {
                _settings.defaultFormat = picked;
                final fmt = GameFormatDetails.fromDisplayName(picked);
                if (fmt != null) {
                  _settings.defaultStartingLife = fmt.defaultStartingLife;
                }
                await _save();
              }
            },
          ),
          _SettingTile(
            title: 'Default Starting Life',
            subtitle:
                '${_settings.defaultStartingLife} life · used when you host',
            onTap: () async {
              final picked = await _pickStartingLife(context);
              if (picked != null && mounted) {
                _settings.defaultStartingLife = picked;
                await _save();
              }
            },
          ),
          SizedBox(height: LayoutTokens.shellSectionGap),
          _SectionHeader('Misc'),
          _SwitchTile(
            title: 'Keep display awake',
            subtitle: 'Prevent screen from sleeping during a game',
            value: _settings.keepDisplayAwake,
            onChanged: (v) {
              _settings.keepDisplayAwake = v;
              _save();
            },
            icon: Icons.brightness_5_outlined,
          ),
          _SwitchTile(
            title: 'Hide navigation and status bars',
            subtitle: 'Fullscreen mode during gameplay',
            value: _settings.hideSystemBars,
            onChanged: (v) {
              _settings.hideSystemBars = v;
              _save();
            },
            icon: Icons.fullscreen,
          ),
          SizedBox(height: LayoutTokens.shellSectionGap),
          _SectionHeader('Appearance'),
          _ColorSchemePicker(
            selected: ref.watch(colorSchemePreferenceProvider),
            onSelected: (id) {
              ref.read(colorSchemePreferenceProvider.notifier).setColorScheme(id);
            },
          ),
          SizedBox(height: LayoutTokens.shellSectionGap),
          _SectionHeader('Feel'),
          _SwitchTile(
            title: 'Haptic Feedback',
            subtitle: 'Vibrate on life changes and rank ups',
            value: _settings.hapticEnabled,
            onChanged: (v) {
              _settings.hapticEnabled = v;
              _save();
            },
          ),
          _SwitchTile(
            title: 'Shake to Undo',
            subtitle: 'Shake phone to undo last life change',
            value: _settings.shakeToUndoEnabled,
            onChanged: (v) {
              _settings.shakeToUndoEnabled = v;
              _save();
            },
          ),
          SizedBox(height: LayoutTokens.shellSectionGap),
          _SectionHeader('Data'),
          _SwitchTile(
            title: 'Cache Commander Images',
            subtitle: 'Store Scryfall images locally for offline use',
            value: _settings.scryfallCacheEnabled,
            onChanged: (v) {
              _settings.scryfallCacheEnabled = v;
              _save();
            },
          ),
          _SettingTile(
            title: 'Clear Image Cache',
            subtitle: 'Free up storage from cached card images',
            onTap: _clearCache,
            isDestructive: true,
          ),
          SizedBox(height: LayoutTokens.shellSectionGap),
          _SectionHeader('Help'),
          _SettingTile(
            title: 'Feedback',
            subtitle: 'Send us your thoughts and suggestions',
            onTap: () => context.push(AppRoutes.feedback),
          ),
          _SettingTile(
            title: 'View hub guide',
            subtitle: 'How Play, Stack, Lookup, and Table work in a match',
            onTap: () => showHubGuideSheet(context),
          ),
          _SettingTile(
            title: 'View Tutorial Again',
            subtitle: 'Re-launch the onboarding walkthrough',
            onTap: () {
              _settings.onboardingCompleted = false;
              _save().then((_) {
                if (context.mounted) context.go(AppRoutes.onboarding);
              });
            },
          ),
          SizedBox(height: LayoutTokens.gr6),
          const Center(
            child: BrandLogo(
              layout: BrandLogoLayout.horizontal,
              height: 28,
            ),
          ),
          SizedBox(height: LayoutTokens.gr1),
          Center(
            child: Text(
              'Beta',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colors.textMuted,
                fontWeight: FontWeight.w600,
                letterSpacing: 2.0,
              ),
            ),
          ),
          SizedBox(height: LayoutTokens.gr3),
          const _AppCredits(),
          SizedBox(height: LayoutTokens.gr4),
        ],
      ),
    );
  }

  Future<String?> _pickFormat(BuildContext context) {
    // isScrollControlled lets the content-sized column grow past the default
    // half-screen sheet cap (formats + header overflow otherwise).
    return showGameBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        final colors = AppColorTokens.of(sheetContext);
        final formats = GameFormatDetails.lobbyPickerOrder;
        return GameSheetBody(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const GameSheetHeader(title: 'Default format'),
              SizedBox(height: LayoutTokens.gr2),
              ...formats.map((f) {
                final label = f.displayName;
                final selected = label == _settings.defaultFormat;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    label,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontWeight:
                          selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  trailing: selected
                      ? Icon(Icons.check_circle_rounded,
                          color: colors.primaryAccent)
                      : null,
                  onTap: () => Navigator.pop(sheetContext, label),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Future<int?> _pickStartingLife(BuildContext context) {
    return showGameBottomSheet<int>(
      context: context,
      builder: (sheetContext) {
        final colors = AppColorTokens.of(sheetContext);
        return GameSheetBody(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const GameSheetHeader(title: 'Default starting life'),
              SizedBox(height: LayoutTokens.gr2),
              ...[20, 25, 30, 40, 60].map((l) {
                final selected = l == _settings.defaultStartingLife;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    '$l life',
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontWeight:
                          selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  trailing: selected
                      ? Icon(Icons.check_circle_rounded,
                          color: colors.primaryAccent)
                      : null,
                  onTap: () => Navigator.pop(sheetContext, l),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Future<void> _clearCache() async {
    try {
      await DefaultCacheManager().emptyCache();
      if (!mounted) return;
      showUiSnackBar(context, 'Image cache cleared.');
    } catch (e, st) {
      appLog('Settings: clear image cache failed', error: e, stackTrace: st);
      if (!mounted) return;
      showUiSnackBar(context, 'Could not clear image cache.', isError: true);
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTokens.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: LayoutTokens.gr2),
      child: Text(
        title,
        style: TypographyTokens.sectionTitle(colors.textPrimary),
      ),
    );
  }
}

class _ColorSchemePicker extends StatelessWidget {
  const _ColorSchemePicker({
    required this.selected,
    required this.onSelected,
  });

  final AppColorSchemeId selected;
  final ValueChanged<AppColorSchemeId> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: LayoutTokens.gr2),
      child: UiSurface(
        padding: EdgeInsets.all(LayoutTokens.gr3),
        borderRadius: RadiusTokens.radiusMd,
        child: Row(
          children: [
            for (var i = 0; i < AppColorPalettes.all.length; i++) ...[
              if (i > 0) SizedBox(width: LayoutTokens.gr2),
              Expanded(
                child: _ColorSwatchButton(
                  palette: AppColorPalettes.all[i],
                  selected: AppColorPalettes.all[i].id == selected,
                  onTap: () => onSelected(AppColorPalettes.all[i].id),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ColorSwatchButton extends StatelessWidget {
  const _ColorSwatchButton({
    required this.palette,
    required this.selected,
    required this.onTap,
  });

  final AppColorPalette palette;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: palette.label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: RadiusTokens.radiusSm,
          child: AspectRatio(
            aspectRatio: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: palette.previewBackground,
                borderRadius: RadiusTokens.radiusSm,
                border: Border.all(
                  color: selected
                      ? palette.previewAccent
                      : Colors.transparent,
                  width: 2.5,
                ),
              ),
              child: Center(
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: palette.previewAccent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final IconData? icon;

  const _SwitchTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: icon != null
          ? Icon(
              icon,
              size: 22,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            )
          : null,
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodyMedium,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.symmetric(
        horizontal: LayoutTokens.gr1,
        vertical: LayoutTokens.gr0,
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  const _SettingTile({
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = isDestructive ? ColorTokens.danger : scheme.onSurfaceVariant;
    return ListTile(
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: isDestructive ? ColorTokens.danger : null,
            ),
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodyMedium,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Icon(Icons.chevron_right_rounded, color: color),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(
        horizontal: LayoutTokens.gr1,
        vertical: LayoutTokens.gr0,
      ),
    );
  }
}

/// Quiet app credits — version, maker, Scryfall, and Wizards Fan Content notice.
class _AppCredits extends StatefulWidget {
  const _AppCredits();

  @override
  State<_AppCredits> createState() => _AppCreditsState();
}

class _AppCreditsState extends State<_AppCredits> {
  static final Uri _scryfallUri = Uri.parse('https://scryfall.com');

  String? _version;

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (!mounted) return;
      setState(() => _version = info.version);
    } catch (e, st) {
      appLog('Failed to read app version', error: e, stackTrace: st);
    }
  }

  Future<void> _openScryfall() async {
    try {
      await launchUrl(_scryfallUri, mode: LaunchMode.externalApplication);
    } catch (e, st) {
      appLog('Failed to open Scryfall', error: e, stackTrace: st);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTokens.of(context);
    final baseStyle = TextStyle(
      color: colors.textMuted,
      fontSize: FontTokens.caption,
      height: 1.4,
    );
    final versionLabel = _version == null ? '…' : _version!;
    return Column(
      children: [
        Text(
          'Life Spark v$versionLabel · Beta',
          textAlign: TextAlign.center,
          style: baseStyle.copyWith(
            color: colors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: LayoutTokens.gr0),
        Text(
          'by Federick Vidot',
          textAlign: TextAlign.center,
          style: baseStyle,
        ),
        SizedBox(height: LayoutTokens.gr1),
        InkWell(
          onTap: _openScryfall,
          borderRadius: RadiusTokens.radiusSm,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: LayoutTokens.gr2,
              vertical: LayoutTokens.gr0,
            ),
            child: Text.rich(
              TextSpan(
                style: baseStyle,
                children: [
                  const TextSpan(text: 'Card data powered by '),
                  TextSpan(
                    text: 'Scryfall',
                    style: baseStyle.copyWith(
                      color: colors.textSecondary,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                      decorationColor: colors.textMuted,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        SizedBox(height: LayoutTokens.gr3),
        Text(
          'Life Spark is unofficial Fan Content permitted under the Fan '
          'Content Policy. Not approved/endorsed by Wizards. Portions of the '
          'materials used are property of Wizards of the Coast. '
          '©Wizards of the Coast LLC.',
          textAlign: TextAlign.center,
          style: baseStyle.copyWith(height: 1.45),
        ),
      ],
    );
  }
}
