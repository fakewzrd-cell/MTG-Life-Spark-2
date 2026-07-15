/// Wizard-themed display title for each band of 5 ranks (levels 1–100).
String wizardRankTitle(int level) {
  final i = ((level.clamp(1, 100) - 1) ~/ 5).clamp(0, kWizardRankBands.length - 1);
  return kWizardRankBands[i].title;
}

/// Metal tier for a level (matches [ProfileRepository] progression bands).
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
