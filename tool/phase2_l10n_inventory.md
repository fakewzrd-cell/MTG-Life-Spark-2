# Phase 2 l10n inventory — hardcoded English UI strings

Inventory of **user-facing** English strings under `lib/features/` and `lib/shared/widgets/` that are **not** yet wired to `AppLocalizations`.

**Scope**
- Focus: requested game/profile/settings/shared surfaces
- Skip: `lib/l10n/`, `*.g.dart`, pure debug/`appLog` messages, technical IDs / enum wire values, dynamic usernames/card names (keep as interpolations)
- Reuse existing ARB where noted (`commonCancel`, `commonClose`, `commonSave`, `commonAdd`, `backupSaved`, `settingsBeta`, forfeit\* already done)
- Official MTG product/terms stay English values but still get keys: Planechase, Archenemy, Monarch, Initiative, Scryfall, Bounty (product mode)

**Estimated new keys: ~420** (≈395 unique UI copy + ≈25 shared/product/rank keys; ±15 depending on whether ordinals / rank band titles are batched)

Placeholders use Flutter ARB style: `{name}`, `{count}`, `{max}`, etc.

---

## 1. End game screen

**File:** `lib/features/end_game/end_game_screen.dart`

| Suggested key | English value |
|---|---|
| `endGameSavingResults` | Saving match results… |
| `endGameSaveFailedTitle` | Could not save match results. |
| `endGameSaveFailedBody` | Your stats may not have updated. Try again. |
| `endGameRetry` | Retry |
| `endGameContinueWithoutSaving` | Continue without saving |
| `endGameFinalStandings` | Final Standings |
| `endGameOverNoWinner` | Game Over — No Winner |
| `endGamePracticeEnded` | Practice ended |
| `endGameYouWin` | You Win! |
| `endGameWinner` | Winner |
| `endGameRankUp` | RANK UP! |
| `endGameRankTransition` | Rank {oldLevel} → {newLevel} |
| `endGameXpGained` | +{xp} XP |
| `endGameWinBonusIncluded` | Win bonus included |
| `endGameParticipationXp` | Participation XP |
| `endGameRankLevel` | Rank {level} |
| `endGameFeedbackThanks` | Thanks! Your feedback has been recorded. |
| `endGameRateOpponents` | Rate Your Opponents |
| `endGameSubmitFeedback` | Submit Feedback |
| `endGameYouSuffix` | (you) |
| `endGameElimReasonLife` | Life depleted |
| `endGameElimReasonPoison` | 10 poison |
| `endGameElimReasonCommanderDmg` | Commander dmg |
| `endGameElimReasonConcede` | Conceded |
| `endGameElimReasonDisconnect` | Left game |
| `endGameElimReasonDefault` | Eliminated |
| `endGameBackToHome` | Back to Home |

**Notes:** Rank title strings come from `wizardRankTitle` — see §23 / ranks section. Life display `{life} ❤` can stay numeric + symbol or use `endGameLifeWithHeart`.

**Subtotal: ~27**

---

## 2. Feedback screen

**File:** `lib/features/feedback/feedback_screen.dart`

| Suggested key | English value |
|---|---|
| `feedbackTitle` | Feedback |
| `feedbackHeadline` | Help us improve |
| `feedbackBody` | Found a bug? Have a feature idea? We read every message. |
| `feedbackMessageLabel` | Your message |
| `feedbackMessageHint` | Tell us what you think... |
| `feedbackSend` | Send Feedback |
| `feedbackOrDivider` | or |
| `feedbackRatePlayStore` | Rate on Play Store |
| `feedbackMailSubject` | Life Spark Feedback |
| `feedbackOpeningMail` | Opening your mail app… |
| `feedbackNoMailAppCopied` | No mail app — message copied. Paste into an email to {email} |
| `feedbackClipboardFallback` | To: {email}\nSubject: Life Spark Feedback\n\n{message} |

**Subtotal: ~12**

---

## 3. Stack tracker tab + stack help + card picker

### 3a. Stack tracker

**File:** `lib/features/game/widgets/stack_tracker_tab.dart`

| Suggested key | English value |
|---|---|
| `stackSortOrderOnStack` | Order on stack |
| `stackSortByPlayer` | By player |
| `stackAddSpellOrAbility` | Add spell or ability |
| `stackHowItWorksTooltip` | How the stack works |
| `stackFilterResolvedCountered` | Resolved / countered |
| `stackApnapHint` | Who added what (active player first) |
| `stackClearAll` | Clear all |
| `stackClearConfirmTitle` | Clear stack? |
| `stackClearConfirmBody` | Remove every spell and ability on the stack. This cannot be undone. |
| `stackActivePlayerLabel` | {username} · Active player |
| `stackTurnOrderLabel` | {username} · Turn order: {position} |
| `stackPutOnStack` | Put on stack |
| `stackInResponseToEllipsis` | In response to… |
| `stackEmptyTitle` | Nothing on the stack |
| `stackEmptyBullet1` | Put spells and abilities here before they resolve. |
| `stackEmptyBullet2` | The last one added resolves first. |
| `stackAddSpell` | Add spell |
| `stackStatusResolved` | Resolved |
| `stackStatusCountered` | Countered |
| `stackStatusFizzled` | Fizzled |
| `stackYouSuffix` | (you) |
| `stackUndoFizzle` | Undo fizzle |
| `stackFizzle` | Fizzle |
| `stackUndoFizzleSubtitle` | Put this spell back on the stack as active |
| `stackFizzleSubtitle` | Target illegal or spell left the stack (rules counter) |
| `stackMarkCountered` | Mark countered |
| `stackRename` | Rename |
| `stackOnStack` | On stack |
| `stackResolvesNext` | Resolves next |
| `stackResolvesAfterAbove` | Resolves after items above |
| `stackTargetNoLongerOnStack` | Target is no longer on the stack |
| `stackCardRulesTooltip` | Card rules |
| `stackInResponseToNamed` | In response to {name} |
| `stackResolve` | Resolve |
| `stackRespond` | Respond |
| `stackFizzledButton` | Fizzled |

### 3b. Stack help sheet

**File:** `lib/features/game/widgets/stack_help_sheet.dart`

| Suggested key | English value |
|---|---|
| `stackHelpTitle` | How the stack works |
| `stackHelpBullet1` | When someone casts a spell or uses an ability, it goes on the stack — a waiting line before it happens. |
| `stackHelpBullet2` | The last thing added resolves first (like a stack of plates). That is why the top entry says Resolves next. |
| `stackHelpBullet3` | When you add a spell, search Scryfall and pick the card from the list so we store the correct name and rules text. |
| `stackHelpBullet4` | To answer something, tap Respond or use In response to… — your spell goes on top and resolves before the one under it. |
| `stackHelpBullet5` | When an effect finishes, tap Resolve — the card stays on the stack and turns green. To answer it, tap Respond. If a counterspell worked, Mark countered (use the Countered filter to view). If a spell lost its target, tap Fizzle — it stays greyed; tap Fizzled again to undo. |
| `stackHelpBullet6` | At the table you still say “pass” out loud for priority; this screen helps everyone remember what is waiting and in what order. |
| `stackHelpExample` | Example: You cast a pump spell on your creature. Your opponent casts Lightning Bolt in response. Bolt resolves first, then your pump spell (if its target is still legal). |
| `stackHelpReadMore` | Read more on Magic.com |
| `stackHelpCouldNotOpenLink` | Could not open link |

### 3c. Stack card picker

**File:** `lib/features/game/widgets/stack_card_picker_dialog.dart`

| Suggested key | English value |
|---|---|
| `stackPickerIntro` | Search Scryfall so we store the correct card name and rules text. |
| `stackPickerCardNameLabel` | Card name |
| `stackPickerCardNameHint` | e.g. Lightning Bolt |
| `stackPickerClearSearch` | Clear search |
| `stackPickerAdd` | Add |
| `stackPickerNoCards` | No cards found. Try a different spelling. |
| `stackPickerNetworkError` | Could not reach Scryfall. Check your internet connection. |
| `stackPickerNeedSelection` | Pick a card from the list, or type a name Scryfall recognizes. |
| `stackPickerTypeToSearch` | Type to search cards |

**Subtotal: ~55**

---

## 4. Alliances overlay / sheets

**Files:** `lib/features/game/widgets/alliance_overview_ui.dart`, `lib/core/game/alliance.dart` (label helpers used by UI)

| Suggested key | English value |
|---|---|
| `allianceAPlayer` | A player |
| `allianceYourAllyFallback` | your ally |
| `allianceOfferDeclined` | Secret alliance offer declined |
| `allianceEnded` | Secret alliance ended |
| `allianceProposeTitle` | Secret alliance |
| `allianceProposeSubtitle` | Invite {username} — only they will know. |
| `allianceDurationSection` | Duration |
| `allianceDurationEndOfTurn` | Until end of turn |
| `allianceDurationEndOfRound` | Until end of round |
| `allianceDurationUntilBroken` | Until broken |
| `allianceWhenToDeliver` | When to deliver |
| `allianceDeliverNow` | Deliver now |
| `allianceDeliverInSeconds` | Deliver in {seconds}s |
| `allianceDeliverEndOfYourTurn` | Deliver at end of your turn |
| `allianceDeliverNextRound` | Deliver next round |
| `allianceSecondsShort` | {seconds}s |
| `allianceSend` | Send |
| `allianceWhisperSent` | Whisper sent to {username} |
| `allianceWhisperScheduled` | Whisper scheduled for {username} |
| `allianceInviteTitle` | Secret offer |
| `allianceInviteBody` | {username} proposes a secret alliance.\n\nDuration: {duration}\n\nOnly you can see this. |
| `allianceAccept` | Accept |
| `allianceDecline` | Decline |
| `allianceFormedTitle` | Alliance formed |
| `allianceFormedBody` | You and {username} are now secretly allied ({duration}).\n\nThe table does not know — unless you reveal or betray. |
| `allianceFormedBodyNoDuration` | You and {username} are now secretly allied.\n\nThe table does not know — unless you reveal or betray. |
| `allianceUnderstood` | Understood |
| `allianceRevealedTitle` | Alliance revealed |
| `allianceRevealedBody` | {playerA} and {playerB} have revealed their secret alliance to the table. |
| `allianceOk` | OK |
| `allianceBetrayalTitle` | Betrayal! |
| `allianceBetrayalBody` | The secret alliance between {playerA} and {playerB} has been broken by betrayal. |
| `allianceBadgeAllied` | Allied |
| `allianceBadgeSecretAlly` | Secret ally |
| `allianceWhisperPending` | Whisper pending → {username} |
| `allianceAwaiting` | Awaiting {username} |

**Subtotal: ~36**

---

## 5. Commander damage panel + commander info bar

### 5a. Commander damage

**File:** `lib/features/game/widgets/commander_damage_panel.dart`

| Suggested key | English value |
|---|---|
| `cmdDmgSheetTitle` | Commander damage |
| `cmdDmgSheetSubtitle` | Threats to you first. Open Dealt to log damage you dealt. |
| `cmdDmgBarA11y` | Commander damage life {remaining} of {ko} remaining, {taken} taken on worst track, tap to manage |
| `cmdDmgLeft` | left |
| `cmdDmgHideDealt` | Hide dealt |
| `cmdDmgDealtTotal` | Dealt {total} |
| `cmdDmgDefaultCommander` | Commander |
| `cmdDmgDefaultPartner` | Partner |
| `cmdDmgDefaultPartnerCommander` | Partner commander |
| `cmdDmgYouDealtTitle` | You → {name} |
| `cmdDmgYouDealtSubtitle` | Damage you dealt |
| `cmdDmgLethalTooltip` | Lethal commander damage! |
| `cmdDmgIncreaseA11y` | Increase commander damage |
| `cmdDmgDecreaseA11y` | Decrease commander damage |

### 5b. Commander info bar

**File:** `lib/features/game/widgets/commander_info_bar.dart`

| Suggested key | English value |
|---|---|
| `cmdBarCastCommander` | Cast commander |
| `cmdBarEliminated` | Eliminated |
| `cmdBarNoTaxYet` | No tax yet |
| `cmdBarRemoveLastCast` | Remove last commander cast |
| `cmdBarCommanderTax` | Commander tax |
| `cmdBarTapToRemoveLastCast` | Tap to remove last cast |
| `cmdBarTaxPlus` | Tax +{tax} |

**Subtotal: ~21**

---

## 6. Counter adjust sheet

**File:** `lib/features/game/widgets/counter_adjust_sheet.dart`

| Suggested key | English value |
|---|---|
| `counterResetConfirmTitle` | Reset to 0? |
| `counterResetConfirmBody` | Set this counter to zero. |
| `counterResetConfirmAction` | Reset |
| `counterResetToZero` | Reset to 0 |
| `counterDone` | Done |

**Subtotal: ~5** (consider adding `commonDone` for reuse)

---

## 7. First player roll overlay

**File:** `lib/features/game/widgets/game_first_player_roll_overlay.dart`

| Suggested key | English value |
|---|---|
| `firstPlayerRollTitle` | Roll for First Player |
| `firstPlayerRollSubtitle` | Highest roll goes first. Tap the die to roll! |
| `firstPlayerRollDieA11y` | Roll die |
| `firstPlayerRollingA11y` | Rolling |
| `firstPlayerRolledA11y` | Rolled {value} |
| `firstPlayerNotRolledA11y` | Not rolled |
| `firstPlayerYouRolled` | You rolled {value}! |
| `firstPlayerYouRolledA11y` | You rolled {value} |
| `firstPlayerRolling` | Rolling… |
| `firstPlayerTapToRoll` | Tap to roll |
| `firstPlayerHostProgressA11y` | {rolled} of {total} players have rolled |
| `firstPlayerWaitingOthersA11y` | Waiting for other players to roll |
| `firstPlayerRollToContinueA11y` | Roll die to continue |
| `firstPlayerHostProgress` | {rolled} / {total} players have rolled |
| `firstPlayerWaitingOthers` | Waiting for others to roll… |
| `firstPlayerTapDieAbove` | Tap the die above to roll |
| `firstPlayerYouSuffix` | {username} (you) |
| `firstPlayerTurnOrderTitle` | Turn Order |
| `firstPlayerTurnOrderSubtitle` | Highest roll leads — play proceeds in this order. |
| `firstPlayerStartGame` | Start game |
| `firstPlayerOrdinal1` | 1st |
| `firstPlayerOrdinal2` | 2nd |
| `firstPlayerOrdinal3` | 3rd |
| `firstPlayerOrdinal4` | 4th |
| `firstPlayerOrdinal5` | 5th |
| `firstPlayerOrdinal6` | 6th |
| `firstPlayerSlotA11y` | {place}, {name}, {rollDetail} |
| `firstPlayerSlotYou` | {username}, you |
| `firstPlayerRollUnavailable` | roll unavailable |
| `firstPlayerRolledDetail` | rolled {value} |
| `firstPlayerGoesFirst` | goes first |

**Subtotal: ~31**

---

## 8. Game history tab / sheet

**File:** `lib/features/game/widgets/game_history_tab.dart`

| Suggested key | English value |
|---|---|
| `historyTitle` | History |
| `historySubtitle` | Life, counters, and other table actions. |
| `historyEmptyTitle` | No actions yet |
| `historyEmptyBody` | Life changes, counters, and other table actions will show up here as the game goes on. |
| `historyTurn` | Turn {turn} |

**Note:** `e.message` entries are generated elsewhere (session log). Migrating those is a separate pass if still English.

**Subtotal: ~5**

---

## 9. Game overview — remaining (skip forfeit)

**File:** `lib/features/game/widgets/game_overview_view.dart`

Skip already-localized forfeit\* keys.

| Suggested key | English value |
|---|---|
| `overviewElimReasonLife` | Life loss |
| `overviewElimReasonPoison` | Poison |
| `overviewElimReasonCommanderDmg` | Commander dmg |
| `overviewElimReasonConcede` | Conceded |
| `overviewElimReasonDisconnect` | Disconnected |
| `overviewRound` | Round {round} |
| `overviewClose` | Close overview |
| `overviewTools` | Tools |
| `overviewHistory` | History |
| `overviewPlayers` | Players |
| `overviewHoldDragReorder` | Hold & drag to reorder turns |
| `overviewDecreaseLife` | Decrease life |
| `overviewIncreaseLife` | Increase life |
| `overviewCommanderTaxPlus` | Commander tax plus {tax} |
| `overviewTaxPlus` | Tax +{tax} |
| `overviewMonarchA11y` | Monarch |
| `overviewInitiativeA11y` | Initiative |
| `overviewNowPlaying` | NOW PLAYING |
| `overviewSendWhisper` | Send whisper |
| `overviewAssignTeamColor` | Assign team color |
| `overviewProposeSecretAlliance` | Propose secret alliance |
| `overviewRevealAlliance` | Reveal alliance to table |
| `overviewBreakAlliance` | Break secret alliance |
| `overviewAssignTeamTitle` | Assign team |
| `overviewTeamNone` | None |
| `overviewTeamN` | Team {index} |

**Subtotal: ~26**

---

## 10. Gameplay dials strip

**File:** `lib/features/game/widgets/gameplay_dials_strip_widget.dart`

| Suggested key | English value |
|---|---|
| `dialsStripLimitSnack` | Your strip holds up to {max} counters. Remove one to add another. |
| `dialsLabelPoison` | Poison |
| `dialsLabelEnergy` | Energy |
| `dialsLabelExp` | Exp |
| `dialsLabelRad` | Rad |
| `dialsLabelBlood` | Blood |
| `dialsLabelClue` | Clue |
| `dialsLabelMap` | Map |
| `dialsLabelTreasure` | Treasure |
| `dialsLabelDevotion` | Devotion |
| `dialsLabelCreatures` | Creatures |
| `dialsLabelEnchant` | Enchant |
| `dialsLabelArtifacts` | Artifacts |
| `dialsLabelGy` | GY |
| `dialsLabelExile` | Exile |
| `dialsAddCounterTitle` | Add counter |
| `dialsAddCounterBody` | Pick trackers for your strip (max {max}). Tap the X on a counter to remove it from the strip. |
| `dialsSectionCommon` | Common |
| `dialsSectionTokensZones` | Tokens & zones |
| `dialsAllBuiltInsOnStrip` | Every built-in counter is already on your strip. Remove one to free a slot. |
| `dialsAddCounterTooltip` | Add counter |
| `dialsRemoveFromStrip` | Remove from strip |

**Subtotal: ~22**

---

## 11. Hub guide sheet

**File:** `lib/features/game/widgets/hub_guide_sheet.dart`

| Suggested key | English value |
|---|---|
| `hubGuideTitle` | Quick tour |
| `hubGuideSkip` | Skip |
| `hubGuideNext` | Next |
| `hubGuideGotIt` | Got it |
| `hubGuideSlidePlayTitle` | Play |
| `hubGuideSlidePlayBody` | Track life and counters here. End turn sits under the phase bar — or leave Phase tracker off in the lobby for a large End turn control. |
| `hubGuideSlideStackTitle` | Stack & Lookup |
| `hubGuideSlideStackBody` | Stack is for Hold Priority and resolving effects. Lookup opens Scryfall without leaving your seat — oracle text and rulings. |
| `hubGuideSlideTableTitle` | Table overview |
| `hubGuideSlideTableBody` | Open Table for the whole pod. Tools has dice and coin flips that everyone sees; History is in the header. End turn stays pinned; Forfeit sits below it. |
| `hubGuideSlideCommanderTitle` | Your turn & commander |
| `hubGuideSlideCommanderBody` | When the seat becomes yours, tap the Your turn cue to dismiss it. The heart tracks commander damage toward 21. |

**Subtotal: ~12**

---

## 12. Life counter a11y labels

**File:** `lib/features/game/widgets/life_counter_widget.dart`

| Suggested key | English value |
|---|---|
| `lifeA11yEliminatedAt` | Eliminated at {life} life |
| `lifeA11yLifeTotal` | {life} life total |
| `lifeA11yDecrease` | Decrease life |
| `lifeA11yIncrease` | Increase life |
| `lifeSetTotalTitle` | Set Life Total |

**Subtotal: ~5**

---

## 13. Opponent glance strip

**File:** `lib/features/game/widgets/opponent_glance_strip.dart`

| Suggested key | English value |
|---|---|
| `glanceOpenTableA11y` | Open table overview, turn order |
| `glanceYou` | You |

**Subtotal: ~2**

---

## 14. Phase picker sheet

**File:** `lib/features/game/widgets/phase_picker_sheet.dart`

| Suggested key | English value |
|---|---|
| `phasePickerTitle` | Select phase |
| `phasePickerSubtitle` | Scroll and tap a phase, or use Set phase for the highlighted step. |
| `phasePickerCancel` | Cancel *(reuse `commonCancel`)* |
| `phasePickerSetPhase` | Set {phase} |

**Subtotal: ~3 new** (+ reuse cancel)

---

## 15. Player whisper overlay / sheet

**Files:** `lib/features/game/widgets/player_whisper_sheet.dart`, `player_whisper_overlay.dart`

| Suggested key | English value |
|---|---|
| `whisperPresetTeamUp` | Team up? |
| `whisperPresetDontAttack` | Don't attack me |
| `whisperPresetHaveRemoval` | I have removal |
| `whisperPresetAllGood` | All good |
| `whisperSentSnack` | Whisper sent to {username} |
| `whisperSendFailed` | Could not send — wait a moment or check your connection. |
| `whisperSheetTitle` | Whisper to {username} |
| `whisperSheetSubtitle` | Only they see this — it fades away. Not saved to match history. |
| `whisperCustomLabel` | Custom message |
| `whisperCustomHint` | Short note… |
| `whisperSend` | Send whisper |
| `whisperOverlayA11y` | Whisper from {username}: {text} |
| `whisperOverlayHeader` | Whisper from {username} |

**Subtotal: ~13**

---

## 16. Political row widget

**File:** `lib/features/game/widgets/political_row_widget.dart`

| Suggested key | English value |
|---|---|
| `politicsTapToAssignA11y` | Table politics. Tap to assign. |
| `politicsStatusEmpty` | No monarch · No initiative · — |
| `politicsDay` | Day |
| `politicsNight` | Night |
| `politicsAssignSheetTitle` | Assign table politics |
| `politicsMonarch` | Monarch |
| `politicsInitiative` | Initiative |
| `politicsAssignMonarch` | Assign Monarch |
| `politicsAssignInitiative` | Assign Initiative |
| `politicsNone` | None |
| `politicsDayNight` | Day/Night |

**Subtotal: ~11**

---

## 17. Table tool result / tools sheets

**Files:** `lib/features/game/widgets/table_tools_sheet.dart`, `table_tool_result_overlay.dart`, `lib/core/game/game_session_events.dart`

| Suggested key | English value |
|---|---|
| `tableToolsTitle` | Tools |
| `tableToolsSubtitle` | Everyone at the table sees the result. |
| `tableToolsD6` | d6 |
| `tableToolsD20` | d20 |
| `tableToolsCoin` | Coin |
| `tableToolsResultHint` | Result pops up for the whole table |
| `tableToolsRollD6` | Roll d6 |
| `tableToolsRollD20` | Roll d20 |
| `tableToolsFlipCoin` | Flip coin |
| `tableToolHeads` | Heads |
| `tableToolTails` | Tails |
| `tableToolRolledHeadline` | {username} rolled a {result} |
| `tableToolFlippedHeadline` | {username} flipped {result} |
| `tableToolTapToDismiss` | Tap to dismiss |
| `tableToolDismissA11y` | {headline}. Tap to dismiss. |
| `tableToolPlayerFallback` | Player |

**Subtotal: ~16**

---

## 18. Variant card panel

**File:** `lib/features/game/widgets/variant_card_panel.dart`

| Suggested key | English value |
|---|---|
| `variantDeckSingular` | Variant deck |
| `variantDeckPlural` | Variant decks |
| `variantDeckA11y` | {label}, tap to view |
| `variantDecksSheetTitle` | Variant decks |
| `variantLoading` | Loading variant decks… |
| `variantLoadFailed` | Could not load decks (internet required) |
| `variantPlanechase` | Planechase |
| `variantArchenemy` | Archenemy |
| `variantBounty` | Bounty |
| `variantNextCard` | Next card |

**Subtotal: ~10**

---

## 19. Commander select screen

**File:** `lib/features/commander/commander_select_screen.dart`

| Suggested key | English value |
|---|---|
| `commanderSelectNoCommanders` | No commanders found for "{query}" |
| `commanderSelectNoCards` | No cards found for "{query}" |
| `commanderSelectSearchFailed` | Unable to search. Check your internet connection and try again. |
| `commanderSelectEditCommanders` | Edit commanders |
| `commanderSelectEditCover` | Edit cover card |
| `commanderSelectStep2Commander` | Step 2 of 2 — commander |
| `commanderSelectStep2Cover` | Step 2 of 2 — cover card |
| `commanderSelectPartnerTitle` | Select Partner |
| `commanderSelectCommanderTitle` | Select Commander |
| `commanderSelectCoverHint` | Pick any card for deck art — not your full deck list. |
| `commanderSelectSearchPartnerHint` | Search for partner commander… |
| `commanderSelectSearchCommanderHint` | Search for a commander… |
| `commanderSelectSearchCardHint` | Search for a card… |
| `commanderSelectConfirm` | Confirm |
| `commanderSelectScryfallCommanderHelp` | Type a commander name to search the Scryfall database. |
| `commanderSelectScryfallCardHelp` | Type a card name to search the Scryfall database. |
| `commanderSelectLabelCommander` | Commander |
| `commanderSelectLabelPartner` | Partner |
| `commanderSelectOptional` | optional |

**Subtotal: ~19**

---

## 20. Deck options / new deck / format / style sheets

### Deck options

**File:** `lib/features/profile/deck_options_sheet.dart`

| Suggested key | English value |
|---|---|
| `deckOptionsDeleteTitle` | Delete deck? |
| `deckOptionsDeleteBody` | Remove “{name}” from your library? Match history stays, but this deck will no longer appear in the lobby picker. |
| `deckOptionsDeleteConfirm` | Delete |
| `deckOptionsStyleNotSet` | Style not set *(may overlap `decksStyleNotSet`)* |
| `deckOptionsEditCommanders` | Edit commanders |
| `deckOptionsEditCover` | Edit cover card |
| `deckOptionsNoGamesYet` | No games yet |
| `deckOptionsWinRate` | {rate}% win rate |
| `deckOptionsUnpin` | Unpin from top |
| `deckOptionsPin` | Pin to top |
| `deckOptionsChangeFormat` | Change format |
| `deckOptionsChangeStyle` | Change style |
| `deckOptionsStyleRequired` | Required — not set |
| `deckOptionsRename` | Rename |
| `deckOptionsDuplicate` | Duplicate |
| `deckOptionsDelete` | Delete deck |
| `deckOptionsRenameTitle` | Rename deck |
| `deckOptionsRenameSave` | Save *(reuse `commonSave`)* |
| `deckOptionsNameLabel` | Deck name |
| `deckOptionsNameHint` | e.g. Raffine Tempo |

### New deck

**File:** `lib/features/profile/new_deck_sheet.dart`

| Suggested key | English value |
|---|---|
| `newDeckChooseStyleError` | Choose a deck style to continue |
| `newDeckTitle` | New deck |
| `newDeckSubtitle` | Step 1 of 2 — details |
| `newDeckIntro` | Name your deck, pick a format and playstyle. Next you’ll choose your commander or cover card. |
| `newDeckNameLabel` | Deck name |
| `newDeckNameHint` | e.g. Raffine Tempo |
| `newDeckNext` | Next |

### Format picker

**File:** `lib/features/profile/game_format_picker_sheet.dart`

| Suggested key | English value |
|---|---|
| `formatPickerTitle` | Format |
| `formatPickerSearchHint` | Search formats… |
| `formatPickerFieldLabel` | Format |
| `formatPickerMultiplayerLife` | Multiplayer · {life} starting life |
| `formatPickerConstructedLife` | Constructed · {life} starting life |

### Style picker

**File:** `lib/features/profile/deck_style_picker_sheet.dart`

| Suggested key | English value |
|---|---|
| `stylePickerTitle` | Deck style |
| `stylePickerSearchHint` | Search styles… |
| `stylePickerChoose` | Choose deck style |
| `stylePickerFieldLabel` | Deck style |

**Subtotal: ~36**

---

## 21. Profile options, picture picker, ranks info, player stats remaining

### Profile options

**File:** `lib/features/profile/profile_options_sheet.dart`

| Suggested key | English value |
|---|---|
| `profileOptionsTitle` | Profile |
| `profileOptionsEdit` | Edit profile |
| `profileOptionsEditSubtitle` | Change your name or avatar |
| `profileOptionsBackup` | Back up profile |
| `profileOptionsBackupSubtitle` | Save profile, decks, games, and feedback on this phone |

### Profile picture picker

**File:** `lib/features/profile/profile_picture_picker_screen.dart`

| Suggested key | English value |
|---|---|
| `profilePicTitle` | Profile picture |
| `profilePicNoCards` | No cards found for "{query}" |
| `profilePicSearchFailed` | Unable to search. Check your internet connection and try again. |
| `profilePicPhotoFailed` | Could not use that photo. Try another image. |
| `profilePicCommander` | Commander |
| `profilePicDefault` | Default |
| `profilePicRemove` | Remove |
| `profilePicUpload` | Upload photo |
| `profilePicTake` | Take photo |
| `profilePicOrSearch` | Or search MTG card art |
| `profilePicSearchHint` | Search MTG cards for profile picture… |
| `profilePicHelp` | Upload a photo, take one, or search for a card—its art becomes your profile picture. |

### Ranks info

**File:** `lib/features/profile/ranks_info_sheet.dart`

| Suggested key | English value |
|---|---|
| `ranksInfoTitle` | Ranks & levels |
| `ranksInfoBody` | Level is your exact progress. Rank is the title for your current level band. Metal tiers group those ranks. |
| `ranksInfoLevelRange` | Lv {min}–{max} |

### Player stats remaining

**File:** `lib/features/profile/profile_player_stats_section.dart`

| Suggested key | English value |
|---|---|
| `statsPlayerBehaviour` | Player behaviour |
| `statsMostPlayed` | Most played |
| `statsNoDeckStatsYet` | No deck stats yet. |
| `statsToughRecord` | Tough record |
| `statsNoLossesOnDeck` | No losses on a saved deck yet. |
| `statsPlayerStats` | Player stats |
| `statsSingularUnit` | stat |
| `statsPluralUnit` | stats |
| `statsLeaningGood` | leaning good |
| `statsLeaningSalty` | leaning salty |
| `statsLeaningNeutral` | neutral |
| `statsBehaviourA11y` | Behaviour spectrum, {leaning} |
| `statsRecord` | Record |
| `statsWinRate` | Win rate |
| `statsRecordFooter` | {wins}W–{losses}L  ·  {games} games |
| `statsWinStreak` | Win streak |
| `statsWinToStartStreak` | Win to start a streak |
| `statsPersonalBest` | Personal best |
| `statsBestStreak` | Best: {best} |
| `statsNoActiveStreak` | No active streak |
| `statsCurrent` | Current |
| `statsLevelShort` | Lv {level} |
| `statsLevelProgress` | Level progress |
| `statsLevelProgressA11y` | Level progress. View all ranks. |
| `statsGood` | Good |
| `statsNeutral` | Neutral |
| `statsSalty` | Salty |

### Profile screen leftovers

**File:** `lib/features/profile/profile_screen.dart`

| Suggested key | English value |
|---|---|
| `profileBackupSaved` | Backup saved. *(reuse `backupSaved`)* |
| `profileBackupSaveFailed` | Could not save backup. *(check settings `backupSaveFailed`)* |
| `profileUsernameLabel` | Username |
| `profileUsernameHint` | e.g. The Archduke |
| `profileUsernameRequired` | Enter a username |
| `profileUsernameTooShort` | Must be at least 2 characters |

### Profile setup leftover

**File:** `lib/features/profile/profile_setup_screen.dart`

| Suggested key | English value |
|---|---|
| `profileSetupUsernameHint` | e.g. The Archduke |

### Carousel leftovers

**File:** `lib/features/profile/profile_carousel_sections.dart`

| Suggested key | English value |
|---|---|
| `carouselFilterTooltip` | Filter: {label} |
| `carouselRecentMatchA11y` | Recent match, {result}, {format} |
| `carouselCloseReturnsSummary` | Close button returns to summary |
| `carouselShowMoreDetails` | Show more for full match details, or tap the card |

### Decks manage leftover

**File:** `lib/features/profile/decks_manage_screen.dart`

| Suggested key | English value |
|---|---|
| `decksClearSearchTooltip` | Clear *(or reuse a shared `commonClear`)* |

**Subtotal: ~55**

---

## 22. Settings remaining (beta / disclaimer)

**File:** `lib/features/settings/settings_screen.dart`  
Most settings rows already use l10n. Remaining:

| Suggested key | English value |
|---|---|
| `settingsDefaultFormatSheetTitle` | Default format |
| `settingsDefaultStartingLifeSheetTitle` | Default starting life |
| `settingsAboutVersionBeta` | Life Spark v{version} · Beta |
| `settingsAboutByAuthor` | by Federick Vidot |
| `settingsAboutCardDataPoweredBy` | Card data powered by |
| `settingsAboutScryfall` | Scryfall |
| `settingsAboutDisclaimer` | Life Spark is unofficial Fan Content permitted under the Fan Content Policy. Not approved/endorsed by Wizards. Portions of the materials used are property of Wizards of the Coast. ©Wizards of the Coast LLC. |

**Subtotal: ~7** (`settingsBeta` already exists for the badge)

---

## 23. Shared player feedback widget + tier badge (+ ranks)

### Player feedback

**File:** `lib/shared/widgets/player_feedback_widgets.dart`

| Suggested key | English value |
|---|---|
| `feedbackLike` | Like |
| `feedbackClearLike` | Clear like |
| `feedbackDislike` | Dislike |
| `feedbackClearDislike` | Clear dislike |
| `feedbackSparkOfTheGame` | Spark of the game |
| `feedbackSparkHint` | Optional — pick one player |
| `feedbackNoneOption` | — None — |

### Tier badge

**File:** `lib/shared/widgets/tier_badge.dart`

| Suggested key | English value |
|---|---|
| `tierBadgeLabel` | {rank} · Lv {level} |
| `tierBadgeA11y` | Rank {label}. View all ranks. |
| `tierBronze` | Bronze |
| `tierSilver` | Silver |
| `tierGold` | Gold |
| `tierPlatinum` | Platinum |
| `tierDiamond` | Diamond |

### Wizard rank band titles

**File:** `lib/shared/utils/wizard_rank_titles.dart` (user-facing via badges / end game / stats)

| Suggested key | English value |
|---|---|
| `rankApprentice` | Apprentice |
| `rankNeophyte` | Neophyte |
| `rankAdept` | Adept |
| `rankEvoker` | Evoker |
| `rankThaumaturge` | Thaumaturge |
| `rankEnchanter` | Enchanter |
| `rankSummoner` | Summoner |
| `rankArcanist` | Arcanist |
| `rankMagus` | Magus |
| `rankWarWizard` | War Wizard |
| `rankHighMagus` | High Magus |
| `rankSpellbinder` | Spellbinder |
| `rankArchmage` | Archmage |
| `rankHighArchmage` | High Archmage |
| `rankPlanewright` | Planewright |
| `rankGrandArchmage` | Grand Archmage |
| `rankVoidcaller` | Voidcaller |
| `rankArchwizard` | Archwizard |
| `rankSpireLegend` | Spire Legend |
| `rankAscendantArchon` | Ascendant Archon |

### Deck tile abbreviations (optional but user-visible)

**File:** `lib/shared/widgets/deck_tile_visual.dart`

| Suggested key | English value |
|---|---|
| `deckTileWinRateAbbr` | WR |
| `deckTileWinsAbbr` | W |
| `deckTileLossesAbbr` | L |
| `deckTileGamesAbbr` | GP |

### Brand logo a11y

**File:** `lib/shared/widgets/brand_logo.dart`

| Suggested key | English value |
|---|---|
| `brandLifeSpark` | Life Spark |

**Subtotal: ~39**

---

## 24. Other screens with remaining `Text('...')` / user copy

Already largely localized; leftovers:

### Lobby host toggles (product names only)

**File:** `lib/features/lobby/lobby_screen.dart`

| Suggested key | English value |
|---|---|
| `hostTogglePlanechase` | Planechase |
| `hostToggleArchenemy` | Archenemy |
| `hostToggleBounty` | Bounty |

*(Reuse same keys as `variantPlanechase` / `variantArchenemy` / `variantBounty` if preferred.)*

### Card lookup leftover

**File:** `lib/features/game/widgets/card_lookup_sheet.dart`

| Suggested key | English value |
|---|---|
| `lookupClearTooltip` | Clear |

### Game modal chrome

**File:** `lib/features/game/widgets/game_modal_chrome.dart`

| Suggested key | English value |
|---|---|
| `gameModalClose` | Close *(reuse `commonClose`)* |

### Phase nav a11y (if still hardcoded)

**File:** `lib/features/game/widgets/phase_nav_cluster.dart`

| Suggested key | English value |
|---|---|
| `phaseNavCurrentA11y` | Current phase, {phase} |

**Subtotal: ~6 new** (after reuse)

---

## Implementation notes

1. **Shared commons to add once:** `commonDone`, `commonNext`, `commonRetry`, `commonOk`, `commonSend`, `commonClear`, `commonConfirm`, `commonNone` — many sheets duplicate Cancel/Done/OK/None.
2. **Product-term keys** (English values forever): `Planechase`, `Archenemy`, `Bounty`, `Monarch`, `Initiative`, `Scryfall`, `Commander`, `Partner`.
3. **Helpers outside widgets** still emit UI copy — migrate with the feature that consumes them:
   - `allianceDurationLabel` / `allianceDeliveryLabel` (`lib/core/game/alliance.dart`)
   - `TableToolAnnouncement` labels (`lib/core/game/game_session_events.dart`)
   - `wizardRankTitle` / `tierForLevel` (`lib/shared/utils/wizard_rank_titles.dart`)
4. **Session action log messages** (`GameLogEntry.message`) are **not** fully inventoried here; treat as a Phase 2b if history still shows English after UI chrome is migrated.
5. **Skip / already done:** forfeit dialogs (`forfeit*`), most lobby/join/settings list rows, card lookup body, decks manage chrome, onboarding/welcome/profile setup titles.

---

## Key count estimate

| Area | Approx. new keys |
|---|---|
| 1 End game | 27 |
| 2 Feedback | 12 |
| 3 Stack + help + picker | 55 |
| 4 Alliances | 36 |
| 5 Commander dmg + info bar | 21 |
| 6 Counter adjust | 5 |
| 7 First player roll | 31 |
| 8 History | 5 |
| 9 Overview remaining | 26 |
| 10 Gameplay dials | 22 |
| 11 Hub guide | 12 |
| 12 Life counter | 5 |
| 13 Opponent glance | 2 |
| 14 Phase picker | 3 |
| 15 Whisper | 13 |
| 16 Politics | 11 |
| 17 Table tools | 16 |
| 18 Variant decks | 10 |
| 19 Commander select | 19 |
| 20 Deck sheets | 36 |
| 21 Profile / stats / ranks UI | 55 |
| 22 Settings leftovers | 7 |
| 23 Shared + tier + rank bands | 39 |
| 24 Other leftovers | 6 |
| **Gross sum** | **~474** |
| Less overlaps / common reuse / shared product keys | **≈ −50–55** |
| **Net estimate for Phase 2 ARB** | **~420** |

**Practical migration target: ~400–430 new ARB keys** (plus wiring `common*` reuse), enough to implement without re-auditing each file from scratch.
