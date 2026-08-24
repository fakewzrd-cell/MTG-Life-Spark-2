import '../../core/models/deck_style.dart';
import '../../l10n/app_localizations.dart';

/// Localized display name for a [DeckStyle] archetype.
String localizedDeckStyleName(AppLocalizations l10n, DeckStyle style) {
  return switch (style) {
    DeckStyle.battlecruiser => l10n.deckStyleBattlecruiser,
    DeckStyle.stax => l10n.deckStyleStax,
    DeckStyle.spellslinger => l10n.deckStyleSpellslinger,
    DeckStyle.control => l10n.deckStyleControl,
    DeckStyle.pillowfort => l10n.deckStylePillowfort,
    DeckStyle.voltron => l10n.deckStyleVoltron,
    DeckStyle.groupHug => l10n.deckStyleGroupHug,
    DeckStyle.groupSlug => l10n.deckStyleGroupSlug,
    DeckStyle.reanimator => l10n.deckStyleReanimator,
    DeckStyle.mill => l10n.deckStyleMill,
    DeckStyle.stealTheft => l10n.deckStyleStealTheft,
    DeckStyle.tribal => l10n.deckStyleTribal,
    DeckStyle.sliver => l10n.deckStyleSliver,
    DeckStyle.tokens => l10n.deckStyleTokens,
    DeckStyle.aristocrats => l10n.deckStyleAristocrats,
    DeckStyle.weenie => l10n.deckStyleWeenie,
    DeckStyle.lands => l10n.deckStyleLands,
    DeckStyle.superfriends => l10n.deckStyleSuperfriends,
    DeckStyle.artifact => l10n.deckStyleArtifact,
    DeckStyle.infect => l10n.deckStyleInfect,
    DeckStyle.counters => l10n.deckStyleCounters,
    DeckStyle.chaos => l10n.deckStyleChaos,
    DeckStyle.political => l10n.deckStylePolitical,
  };
}

/// Localized short description for a [DeckStyle] archetype.
String localizedDeckStyleDescription(AppLocalizations l10n, DeckStyle style) {
  return switch (style) {
    DeckStyle.battlecruiser => l10n.deckStyleBattlecruiserDesc,
    DeckStyle.stax => l10n.deckStyleStaxDesc,
    DeckStyle.spellslinger => l10n.deckStyleSpellslingerDesc,
    DeckStyle.control => l10n.deckStyleControlDesc,
    DeckStyle.pillowfort => l10n.deckStylePillowfortDesc,
    DeckStyle.voltron => l10n.deckStyleVoltronDesc,
    DeckStyle.groupHug => l10n.deckStyleGroupHugDesc,
    DeckStyle.groupSlug => l10n.deckStyleGroupSlugDesc,
    DeckStyle.reanimator => l10n.deckStyleReanimatorDesc,
    DeckStyle.mill => l10n.deckStyleMillDesc,
    DeckStyle.stealTheft => l10n.deckStyleStealTheftDesc,
    DeckStyle.tribal => l10n.deckStyleTribalDesc,
    DeckStyle.sliver => l10n.deckStyleSliverDesc,
    DeckStyle.tokens => l10n.deckStyleTokensDesc,
    DeckStyle.aristocrats => l10n.deckStyleAristocratsDesc,
    DeckStyle.weenie => l10n.deckStyleWeenieDesc,
    DeckStyle.lands => l10n.deckStyleLandsDesc,
    DeckStyle.superfriends => l10n.deckStyleSuperfriendsDesc,
    DeckStyle.artifact => l10n.deckStyleArtifactDesc,
    DeckStyle.infect => l10n.deckStyleInfectDesc,
    DeckStyle.counters => l10n.deckStyleCountersDesc,
    DeckStyle.chaos => l10n.deckStyleChaosDesc,
    DeckStyle.political => l10n.deckStylePoliticalDesc,
  };
}

/// Localized style label for a deck, or [AppLocalizations.decksStyleNotSet].
String localizedDeckStyleLabel(AppLocalizations l10n, DeckStyle? style) {
  if (style == null) return l10n.decksStyleNotSet;
  return localizedDeckStyleName(l10n, style);
}
