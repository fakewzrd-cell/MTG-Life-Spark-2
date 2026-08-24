import '../../l10n/app_localizations.dart';

/// Wizard-themed display title for each band of 5 ranks (levels 1–100).
String wizardRankTitle(AppLocalizations l10n, int level) {
  final i =
      ((level.clamp(1, 100) - 1) ~/ 5).clamp(0, kWizardRankBands.length - 1);
  return wizardRankTitleForBandIndex(l10n, i);
}

/// Localized title for [kWizardRankBands] index `0..19`.
String wizardRankTitleForBandIndex(AppLocalizations l10n, int index) {
  switch (index.clamp(0, kWizardRankBands.length - 1)) {
    case 0:
      return l10n.rankApprentice;
    case 1:
      return l10n.rankNeophyte;
    case 2:
      return l10n.rankAdept;
    case 3:
      return l10n.rankEvoker;
    case 4:
      return l10n.rankThaumaturge;
    case 5:
      return l10n.rankEnchanter;
    case 6:
      return l10n.rankSummoner;
    case 7:
      return l10n.rankArcanist;
    case 8:
      return l10n.rankMagus;
    case 9:
      return l10n.rankWarWizard;
    case 10:
      return l10n.rankHighMagus;
    case 11:
      return l10n.rankSpellbinder;
    case 12:
      return l10n.rankArchmage;
    case 13:
      return l10n.rankHighArchmage;
    case 14:
      return l10n.rankPlanewright;
    case 15:
      return l10n.rankGrandArchmage;
    case 16:
      return l10n.rankVoidcaller;
    case 17:
      return l10n.rankArchwizard;
    case 18:
      return l10n.rankSpireLegend;
    default:
      return l10n.rankAscendantArchon;
  }
}

/// Localized display name for a metal [tier] id (`Bronze`…`Diamond`).
String wizardTierTitle(AppLocalizations l10n, String tier) {
  switch (tier) {
    case 'Silver':
      return l10n.tierSilver;
    case 'Gold':
      return l10n.tierGold;
    case 'Platinum':
      return l10n.tierPlatinum;
    case 'Diamond':
      return l10n.tierDiamond;
    default:
      return l10n.tierBronze;
  }
}

/// Metal tier id for a level (matches [ProfileRepository] progression bands).
///
/// Returns English ids used for persistence and [wizardTierColor] matching —
/// localize for display with [wizardTierTitle].
String tierForLevel(int level) {
  final lv = level.clamp(1, 100);
  if (lv <= 10) return 'Bronze';
  if (lv <= 25) return 'Silver';
  if (lv <= 50) return 'Gold';
  if (lv <= 75) return 'Platinum';
  return 'Diamond';
}

class WizardRankBand {
  const WizardRankBand({
    required this.title,
    required this.minLevel,
    required this.maxLevel,
  });

  /// English band id (stable; not for UI — use [wizardRankTitle]).
  final String title;
  final int minLevel;
  final int maxLevel;
}

class WizardTierBand {
  const WizardTierBand({
    required this.tier,
    required this.minLevel,
    required this.maxLevel,
  });

  /// English metal tier id (stable; not for UI — use [wizardTierTitle]).
  final String tier;
  final int minLevel;
  final int maxLevel;
}

/// Named ranks — one title per 5 levels.
const kWizardRankBands = <WizardRankBand>[
  WizardRankBand(title: 'Apprentice', minLevel: 1, maxLevel: 5),
  WizardRankBand(title: 'Neophyte', minLevel: 6, maxLevel: 10),
  WizardRankBand(title: 'Adept', minLevel: 11, maxLevel: 15),
  WizardRankBand(title: 'Evoker', minLevel: 16, maxLevel: 20),
  WizardRankBand(title: 'Thaumaturge', minLevel: 21, maxLevel: 25),
  WizardRankBand(title: 'Enchanter', minLevel: 26, maxLevel: 30),
  WizardRankBand(title: 'Summoner', minLevel: 31, maxLevel: 35),
  WizardRankBand(title: 'Arcanist', minLevel: 36, maxLevel: 40),
  WizardRankBand(title: 'Magus', minLevel: 41, maxLevel: 45),
  WizardRankBand(title: 'War Wizard', minLevel: 46, maxLevel: 50),
  WizardRankBand(title: 'High Magus', minLevel: 51, maxLevel: 55),
  WizardRankBand(title: 'Spellbinder', minLevel: 56, maxLevel: 60),
  WizardRankBand(title: 'Archmage', minLevel: 61, maxLevel: 65),
  WizardRankBand(title: 'High Archmage', minLevel: 66, maxLevel: 70),
  WizardRankBand(title: 'Planewright', minLevel: 71, maxLevel: 75),
  WizardRankBand(title: 'Grand Archmage', minLevel: 76, maxLevel: 80),
  WizardRankBand(title: 'Voidcaller', minLevel: 81, maxLevel: 85),
  WizardRankBand(title: 'Archwizard', minLevel: 86, maxLevel: 90),
  WizardRankBand(title: 'Spire Legend', minLevel: 91, maxLevel: 95),
  WizardRankBand(title: 'Ascendant Archon', minLevel: 96, maxLevel: 100),
];

/// Metal tiers that group ranks by progression band.
const kWizardTierBands = <WizardTierBand>[
  WizardTierBand(tier: 'Bronze', minLevel: 1, maxLevel: 10),
  WizardTierBand(tier: 'Silver', minLevel: 11, maxLevel: 25),
  WizardTierBand(tier: 'Gold', minLevel: 26, maxLevel: 50),
  WizardTierBand(tier: 'Platinum', minLevel: 51, maxLevel: 75),
  WizardTierBand(tier: 'Diamond', minLevel: 76, maxLevel: 100),
];
