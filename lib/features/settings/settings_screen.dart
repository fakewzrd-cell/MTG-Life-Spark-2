import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter/material.dart';

import '../../ui/theme/app_color_tokens.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/debug/app_log.dart';
import '../../core/game/game_format.dart';
import '../../core/models/app_settings.dart';
import '../../core/persistence/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/theme/theme_provider.dart';
import '../../shared/utils/app_locale.dart';
import '../../shared/utils/app_router.dart';
import '../../shared/widgets/brand_logo.dart';
import '../../ui/components/shell_destructive_dialog.dart';
import '../../ui/components/ui_app_bar.dart';
import '../../ui/components/ui_snack_bar.dart';
import '../../ui/components/ui_surface.dart';
import '../../ui/tokens/app_color_palettes.dart';
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
    final l10n = AppLocalizations.of(context);
    final languageCode = _settings.localeCode.trim().isEmpty
        ? kLocaleSystem
        : _settings.localeCode;
    return Scaffold(
      appBar: UiAppBar(title: l10n.settingsTitle),
      backgroundColor: colors.backgroundPrimary,
      body: ListView(
        padding: LayoutTokens.shellListPadding(context, top: LayoutTokens.gr4),
        children: [
          _SectionHeader(l10n.settingsSectionGameplay),
          _SettingTile(
            title: l10n.settingsDefaultFormat,
            subtitle: l10n.settingsDefaultFormatSubtitle(_settings.defaultFormat),
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
            title: l10n.settingsDefaultStartingLife,
            subtitle: l10n.settingsDefaultStartingLifeSubtitle(
              _settings.defaultStartingLife,
            ),
            onTap: () async {
              final picked = await _pickStartingLife(context);
              if (picked != null && mounted) {
                _settings.defaultStartingLife = picked;
                await _save();
              }
            },
          ),
          SizedBox(height: LayoutTokens.shellSectionGap),
          _SectionHeader(l10n.settingsSectionMisc),
          _SwitchTile(
            title: l10n.settingsKeepDisplayAwake,
            subtitle: l10n.settingsKeepDisplayAwakeSubtitle,
            value: _settings.keepDisplayAwake,
            onChanged: (v) {
              _settings.keepDisplayAwake = v;
              _save();
            },
            icon: Icons.brightness_5_outlined,
          ),
          _SwitchTile(
            title: l10n.settingsHideSystemBars,
            subtitle: l10n.settingsHideSystemBarsSubtitle,
            value: _settings.hideSystemBars,
            onChanged: (v) {
              _settings.hideSystemBars = v;
              _save();
            },
            icon: Icons.fullscreen,
          ),
          SizedBox(height: LayoutTokens.shellSectionGap),
          _SectionHeader(l10n.settingsSectionAppearance),
          _SwitchTile(
            title: l10n.settingsDarkAppearance,
            subtitle: l10n.settingsDarkAppearanceSubtitle,
            value: _settings.useDarkTheme,
            onChanged: (v) {
              _settings.useDarkTheme = v;
              _save();
            },
            icon: Icons.dark_mode_outlined,
          ),
          _SettingTile(
            title: l10n.settingsLanguage,
            subtitle: l10n.settingsLanguageSubtitle(
              languageLabel(l10n, languageCode),
            ),
            onTap: () async {
              final picked = await _pickLanguage(context, languageCode);
              if (picked != null && mounted) {
                _settings.localeCode = picked;
                await _save();
              }
            },
          ),
          _ColorSchemePicker(
            selected: ref.watch(colorSchemePreferenceProvider),
            onSelected: (id) {
              ref.read(colorSchemePreferenceProvider.notifier).setColorScheme(id);
            },
          ),
          SizedBox(height: LayoutTokens.shellSectionGap),
          _SectionHeader(l10n.settingsSectionFeel),
          _SwitchTile(
            title: l10n.settingsHapticFeedback,
            subtitle: l10n.settingsHapticFeedbackSubtitle,
            value: _settings.hapticEnabled,
            onChanged: (v) {
              _settings.hapticEnabled = v;
              _save();
            },
          ),
          _SwitchTile(
            title: l10n.settingsShakeToUndo,
            subtitle: l10n.settingsShakeToUndoSubtitle,
            value: _settings.shakeToUndoEnabled,
            onChanged: (v) {
              _settings.shakeToUndoEnabled = v;
              _save();
            },
          ),
          SizedBox(height: LayoutTokens.shellSectionGap),
          _SectionHeader(l10n.settingsSectionData),
          _SwitchTile(
            title: l10n.settingsCacheCommanderImages,
            subtitle: l10n.settingsCacheCommanderImagesSubtitle,
            value: _settings.scryfallCacheEnabled,
            onChanged: (v) {
              _settings.scryfallCacheEnabled = v;
              _save();
            },
          ),
          _SettingTile(
            title: l10n.settingsClearImageCache,
            subtitle: l10n.settingsClearImageCacheSubtitle,
            onTap: _clearCache,
            isDestructive: true,
          ),
          _SettingTile(
            title: l10n.settingsSaveBackup,
            subtitle: l10n.settingsSaveBackupSubtitle,
            onTap: _exportBackup,
          ),
          _SettingTile(
            title: l10n.settingsRestoreBackup,
            subtitle: l10n.settingsRestoreBackupSubtitle,
            onTap: _restoreBackup,
          ),
          SizedBox(height: LayoutTokens.shellSectionGap),
          _SectionHeader(l10n.settingsSectionHelp),
          _SettingTile(
            title: l10n.settingsFeedback,
            subtitle: l10n.settingsFeedbackSubtitle,
            onTap: () => context.push(AppRoutes.feedback),
          ),
          _SettingTile(
            title: l10n.settingsViewHubGuide,
            subtitle: l10n.settingsViewHubGuideSubtitle,
            onTap: () => showHubGuideSheet(context),
          ),
          _SettingTile(
            title: l10n.settingsViewTutorialAgain,
            subtitle: l10n.settingsViewTutorialAgainSubtitle,
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
              l10n.settingsBeta,
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

  Future<String?> _pickLanguage(BuildContext context, String current) {
    final l10n = AppLocalizations.of(context);
    final options = <String>[
      kLocaleSystem,
      ...kSupportedLocaleCodes,
    ];
    return showModalBottomSheet<String>(
      context: context,
      useRootNavigator: true,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final code in options)
                ListTile(
                  title: Text(languageLabel(l10n, code)),
                  trailing: code == current
                      ? Icon(
                          Icons.check_rounded,
                          color: AppColorTokens.of(ctx).primaryAccent,
                        )
                      : null,
                  onTap: () => Navigator.of(ctx).pop(code),
                ),
            ],
          ),
        );
      },
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
              GameSheetHeader(title: AppLocalizations.of(sheetContext).settingsDefaultFormatSheetTitle),
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
              GameSheetHeader(title: AppLocalizations.of(sheetContext).settingsDefaultStartingLifeSheetTitle),
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
    final l10n = AppLocalizations.of(context);
    try {
      await DefaultCacheManager().emptyCache();
      if (!mounted) return;
      showUiSnackBar(context, l10n.cacheCleared);
    } catch (e, st) {
      appLog('Settings: clear image cache failed', error: e, stackTrace: st);
      if (!mounted) return;
      showUiSnackBar(context, l10n.cacheClearFailed, isError: true);
    }
  }

  Future<void> _exportBackup() async {
    final l10n = AppLocalizations.of(context);
    try {
      final saved = await ref.read(backupServiceProvider).exportToFile();
      if (!mounted) return;
      if (saved) {
        showUiSnackBar(context, l10n.backupSaved);
      }
    } catch (e, st) {
      appLog('Settings: export backup failed', error: e, stackTrace: st);
      if (!mounted) return;
      showUiSnackBar(context, l10n.backupSaveFailed, isError: true);
    }
  }

  Future<void> _restoreBackup() async {
    final l10n = AppLocalizations.of(context);
    try {
      final pending = await ref.read(backupServiceProvider).pickBackupFile();
      if (!mounted) return;
      if (pending == null) return;

      final confirmed = await showShellDestructiveConfirm(
        context: context,
        title: l10n.backupRestoreTitle(pending.profile.username),
        message: l10n.backupRestoreMessage,
        confirmLabel: l10n.backupRestoreConfirm,
        cancelLabel: l10n.commonCancel,
      );
      if (!confirmed || !mounted) return;

      final backup =
          await ref.read(backupServiceProvider).restoreBackup(pending);
      if (!mounted) return;

      _settings = ref.read(settingsRepositoryProvider).settings;
      ref
          .read(colorSchemePreferenceProvider.notifier)
          .hydrateFromRepository();
      bumpSettingsRevision(ref);
      bumpProfileRevision(ref);
      bumpDeckListRevision(ref);
      setState(() {});
      showUiSnackBar(
        context,
        l10n.backupRestored(backup.profile.username),
      );
    } catch (e, st) {
      appLog('Settings: restore backup failed', error: e, stackTrace: st);
      if (!mounted) return;
      showUiSnackBar(
        context,
        l10n.backupRestoreFailed,
        isError: true,
      );
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
    final palettes = AppColorPalettes.all;
    const crossAxisCount = 3;
    const crossSpacing = LayoutTokens.gr2;
    const mainSpacing = LayoutTokens.gr1;
    const tileHeight = LayoutTokens.minTapTarget;
    final rowCount = (palettes.length / crossAxisCount).ceil();

    return Padding(
      padding: EdgeInsets.only(bottom: LayoutTokens.gr1),
      child: UiSurface(
        padding: EdgeInsets.all(LayoutTokens.gr2),
        borderRadius: RadiusTokens.radiusMd,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var row = 0; row < rowCount; row++) ...[
              if (row > 0) const SizedBox(height: mainSpacing),
              SizedBox(
                height: tileHeight,
                child: Row(
                  children: [
                    for (var col = 0; col < crossAxisCount; col++) ...[
                      if (col > 0) const SizedBox(width: crossSpacing),
                      Expanded(
                        child: _swatchAt(
                          palettes,
                          row * crossAxisCount + col,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _swatchAt(List<AppColorPalette> palettes, int index) {
    if (index >= palettes.length) return const SizedBox.shrink();
    final palette = palettes[index];
    return _ColorSwatchButton(
      palette: palette,
      selected: palette.id == selected,
      onTap: () => onSelected(palette.id),
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
    final l10n = AppLocalizations.of(context);
    final label = switch (palette.id) {
      AppColorSchemeId.violet => l10n.paletteViolet,
      AppColorSchemeId.crimson => l10n.paletteCrimson,
      AppColorSchemeId.slate => l10n.paletteSlate,
      AppColorSchemeId.forest => l10n.paletteForest,
      AppColorSchemeId.obsidian => l10n.paletteObsidian,
      AppColorSchemeId.fog => l10n.paletteFog,
    };
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: RadiusTokens.radiusSm,
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
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: palette.previewAccent,
                  shape: BoxShape.circle,
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
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodyMedium,
        maxLines: 3,
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
    final colors = AppColorTokens.of(context);
    final color = isDestructive ? colors.error : colors.textSecondary;
    return ListTile(
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: isDestructive ? colors.error : null,
            ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodyMedium,
        maxLines: 3,
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
    final l10n = AppLocalizations.of(context);
    final baseStyle = TextStyle(
      color: colors.textMuted,
      fontSize: FontTokens.caption,
      height: 1.4,
    );
    final versionLabel = _version == null ? '…' : _version!;
    return Column(
      children: [
        Text(
          l10n.settingsAboutVersionBeta(versionLabel),
          textAlign: TextAlign.center,
          style: baseStyle.copyWith(
            color: colors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: LayoutTokens.gr0),
        Text(
          l10n.settingsAboutByAuthor,
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
                  TextSpan(text: '${l10n.settingsAboutCardDataPoweredBy} '),
                  TextSpan(
                    text: l10n.settingsAboutScryfall,
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
          l10n.settingsAboutDisclaimer,
          textAlign: TextAlign.center,
          style: baseStyle.copyWith(height: 1.45),
        ),
      ],
    );
  }
}
