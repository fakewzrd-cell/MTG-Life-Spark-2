import '../../l10n/app_localizations.dart';

/// Maps stored English session-log lines to the active locale for display.
///
/// History entries remain English on the wire / in state so multiplayer and
/// `_entryAffectsLocalPlayer` heuristics stay stable; only the UI is localized.
String localizeGameLogMessage(AppLocalizations l10n, String message) {
  final m = message;

  var match = RegExp(r'^(.+): Life ([+-]?\d+)$').firstMatch(m);
  if (match != null) {
    return l10n.logLifeChange(match[1]!, match[2]!);
  }

  match = RegExp(
    r'^(.+): (.+) ([+-]?\d+) \(→ (\d+)\)$',
  ).firstMatch(m);
  if (match != null) {
    return l10n.logCounterChange(
      match[1]!,
      _localizeCounter(l10n, match[2]!),
      match[3]!,
      match[4]!,
    );
  }

  match = RegExp(r'^(.+): (.+) ([+-]?\d+)$').firstMatch(m);
  if (match != null && match[2] != 'Life') {
    return l10n.logCounterChangeSimple(
      match[1]!,
      _localizeCounter(l10n, match[2]!),
      match[3]!,
    );
  }

  match = RegExp(r'^(.+) changed your life ([+-]?\d+)$').firstMatch(m);
  if (match != null) {
    return l10n.logLifeChangedYours(match[1]!, match[2]!);
  }

  match = RegExp(r'^(.+) changed your (.+) ([+-]?\d+)$').firstMatch(m);
  if (match != null) {
    return l10n.logCounterChangedYours(
      match[1]!,
      _localizeCounter(l10n, match[2]!),
      match[3]!,
    );
  }

  match = RegExp(r'^(.+) ends turn$').firstMatch(m);
  if (match != null) {
    return l10n.logEndsTurn(match[1]!);
  }

  match = RegExp(
    r'^(.+) dealt you ([+-]?\d+) commander damage$',
  ).firstMatch(m);
  if (match != null) {
    return l10n.logCmdDmgDealtYou(match[1]!, match[2]!);
  }

  match = RegExp(
    r'^You dealt (.+) ([+-]?\d+) commander damage$',
  ).firstMatch(m);
  if (match != null) {
    return l10n.logCmdDmgYouDealt(match[1]!, match[2]!);
  }

  match = RegExp(
    r'^(.+) → (.+): Commander damage ([+-]?\d+)$',
  ).firstMatch(m);
  if (match != null) {
    return l10n.logCmdDmgOther(match[1]!, match[2]!, match[3]!);
  }

  if (m == 'Turn order updated by host') {
    return l10n.logTurnOrderUpdated;
  }
  if (m == 'Proliferate: all players') {
    return l10n.logProliferate;
  }
  if (m == 'Alliance broken') {
    return l10n.logAllianceBroken;
  }
  if (m == 'Cleared stack') {
    return l10n.logClearedStack;
  }

  match = RegExp(r'^Alliance revealed: (.+) & (.+)$').firstMatch(m);
  if (match != null) {
    return l10n.logAllianceRevealed(match[1]!, match[2]!);
  }

  match = RegExp(
    r'^Alliance broken — betrayal: (.+) & (.+)$',
  ).firstMatch(m);
  if (match != null) {
    return l10n.logAllianceBetrayal(match[1]!, match[2]!);
  }

  match = RegExp(
    r'^Secret alliance formed: (.+) & (.+) \((.+)\)$',
  ).firstMatch(m);
  if (match != null) {
    return l10n.logAllianceFormed(
      match[1]!,
      match[2]!,
      _localizeDuration(l10n, match[3]!),
    );
  }

  match = RegExp(r'^(.+) left the game$').firstMatch(m);
  if (match != null) {
    return l10n.logPlayerLeft(match[1]!);
  }

  match = RegExp(r'^(.+) rolled a (.+)$').firstMatch(m);
  if (match != null) {
    return l10n.logRolled(match[1]!, match[2]!);
  }

  match = RegExp(r'^(.+) flipped (Heads|Tails)$').firstMatch(m);
  if (match != null) {
    final side = match[2] == 'Heads' ? l10n.logHeads : l10n.logTails;
    return l10n.logFlipped(match[1]!, side);
  }

  match = RegExp(r'^(.+) added “(.+)” \(response\)$').firstMatch(m);
  if (match != null) {
    return l10n.logStackAddedResponse(match[1]!, match[2]!);
  }

  match = RegExp(r'^(.+) added “(.+)”$').firstMatch(m);
  if (match != null) {
    return l10n.logStackAdded(match[1]!, match[2]!);
  }

  match = RegExp(
    r'^(.+) renamed stack item to “(.+)”$',
  ).firstMatch(m);
  if (match != null) {
    return l10n.logStackRenamed(match[1]!, match[2]!);
  }

  match = RegExp(
    r'^(.+)’s “(.+)” (fizzled|countered|resolved|reactivated)$',
  ).firstMatch(m);
  if (match != null) {
    return l10n.logStackStatus(
      match[1]!,
      match[2]!,
      _localizeStackStatus(l10n, match[3]!),
    );
  }

  return message;
}

String _localizeCounter(AppLocalizations l10n, String counter) {
  switch (counter) {
    case 'Poison':
      return l10n.logCounterPoison;
    case 'Energy':
      return l10n.logCounterEnergy;
    case 'Experience':
      return l10n.logCounterExperience;
    case 'Rad':
      return l10n.logCounterRad;
    case 'Blood':
      return l10n.logCounterBlood;
    case 'Clue':
      return l10n.logCounterClue;
    case 'Map':
      return l10n.logCounterMap;
    case 'Treasure':
      return l10n.logCounterTreasure;
    case 'Devotion':
      return l10n.logCounterDevotion;
    case 'Creatures':
      return l10n.logCounterCreatures;
    case 'Enchantments':
      return l10n.logCounterEnchantments;
    case 'Artifacts':
      return l10n.logCounterArtifacts;
    case 'GY creatures':
      return l10n.logCounterGyCreatures;
    case 'Exile':
      return l10n.logCounterExile;
    default:
      return counter;
  }
}

String _localizeDuration(AppLocalizations l10n, String duration) {
  switch (duration) {
    case 'Until end of turn':
      return l10n.logDurationEndOfTurn;
    case 'Until end of round':
      return l10n.logDurationEndOfRound;
    case 'Until broken':
      return l10n.logDurationUntilBroken;
    default:
      return duration;
  }
}

String _localizeStackStatus(AppLocalizations l10n, String status) {
  switch (status) {
    case 'fizzled':
      return l10n.logStackStatusFizzled;
    case 'countered':
      return l10n.logStackStatusCountered;
    case 'resolved':
      return l10n.logStackStatusResolved;
    case 'reactivated':
      return l10n.logStackStatusReactivated;
    default:
      return status;
  }
}
