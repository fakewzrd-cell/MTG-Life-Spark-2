/// Commander deck playstyle / archetype tag for saved decks.
enum DeckStyle {
  battlecruiser(
    'battlecruiser',
    'Battlecruiser',
    'Large creatures and face damage; light interaction, often newer-player tables.',
  ),
  stax(
    'stax',
    'Stax',
    'Slows or stops opponents, then wins while others cannot respond.',
  ),
  spellslinger(
    'spellslinger',
    'Spellslinger',
    'Mostly instants and sorceries; storm-style copy effects for burst wins.',
  ),
  control(
    'control',
    'Control',
    'Answers and board management until the game is fully under control.',
  ),
  pillowfort(
    'pillowfort',
    'Pillowfort',
    'Taxes and deterrents that make attacking you costly; alt win conditions.',
  ),
  voltron(
    'voltron',
    'Voltron',
    'Stacks equipment and auras on one protected commander threat.',
  ),
  groupHug(
    'group_hug',
    'Group Hug',
    'Table-wide small bonuses that still set up a hidden win line.',
  ),
  groupSlug(
    'group_slug',
    'Group Slug',
    'Equal life loss or discard for everyone until the table is drained.',
  ),
  reanimator(
    'reanimator',
    'Reanimator',
    'Fills the graveyard, then cheats huge creatures back cheaply.',
  ),
  mill(
    'mill',
    'Mill',
    'Empties libraries into exile or graveyard for the draw-loss win.',
  ),
  stealTheft(
    'steal_theft',
    'Steal / Theft',
    'Takes opponents\' permanents and rides the strongest thing at the table.',
  ),
  tribal(
    'tribal',
    'Tribal',
    'Creature type synergy with lords and shared tribal payoffs.',
  ),
  sliver(
    'sliver',
    'Sliver',
    'Sliver hive that buffs every other sliver on the board.',
  ),
  tokens(
    'tokens',
    'Tokens',
    'Mass token generation plus anthems for sudden combat kills.',
  ),
  aristocrats(
    'aristocrats',
    'Aristocrats',
    'Sacrifice loops with death and ETB triggers plus recursion.',
  ),
  weenie(
    'weenie',
    'Weenie',
    'Many small creatures that buff each other for wide attacks.',
  ),
  lands(
    'lands',
    'Lands',
    'Landfall and land-centric engines; hard to interact with.',
  ),
  superfriends(
    'superfriends',
    'Superfriends',
    'Planeswalker chains with extra loyalty and activations.',
  ),
  artifact(
    'artifact',
    'Artifact',
    'Artifact synergies and machines, often with blue support.',
  ),
  infect(
    'infect',
    'Infect',
    'Poison counters instead of life; strong in small pods.',
  ),
  counters(
    'counters',
    'Counters',
    '+1/+1 counter payoffs and counter-matters abilities.',
  ),
  chaos(
    'chaos',
    'Chaos',
    'Random or disruptive effects that warp normal game plans.',
  ),
  political(
    'political',
    'Political',
    'Votes, deals, and table politics to steer outcomes.',
  );

  const DeckStyle(this.id, this.displayName, this.description);

  final String id;
  final String displayName;
  final String description;

  static DeckStyle? fromId(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    for (final s in DeckStyle.values) {
      if (s.id == raw) return s;
    }
    return null;
  }

  static bool isValidId(String? raw) => fromId(raw) != null;

  static const unsetLabel = 'Style required';
}
