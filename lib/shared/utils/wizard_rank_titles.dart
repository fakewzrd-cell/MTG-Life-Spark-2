/// Wizard-themed display title for each band of 5 ranks (levels 1–100).
String wizardRankTitle(int level) {
  final i = ((level.clamp(1, 100) - 1) ~/ 5).clamp(0, _wizardRankTitles.length - 1);
  return _wizardRankTitles[i];
}

const _wizardRankTitles = <String>[
  'Apprentice', // 1–5
  'Neophyte', // 6–10
  'Adept', // 11–15
  'Evoker', // 16–20
  'Thaumaturge', // 21–25
  'Enchanter', // 26–30
  'Summoner', // 31–35
  'Arcanist', // 36–40
  'Magus', // 41–45
  'War Wizard', // 46–50
  'High Magus', // 51–55
  'Spellbinder', // 56–60
  'Archmage', // 61–65
  'High Archmage', // 66–70
  'Planewright', // 71–75
  'Grand Archmage', // 76–80
  'Voidcaller', // 81–85
  'Archwizard', // 86–90
  'Spire Legend', // 91–95
  'Ascendant Archon', // 96–100
];
