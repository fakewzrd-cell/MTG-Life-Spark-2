import json
import re
from pathlib import Path

root = Path(r"c:\Users\Federick Vidot\MTG-Life-Spark\lib\l10n")
out = Path(r"c:\Users\Federick Vidot\MTG-Life-Spark\tool\l10n_audit_report.txt")

locales = ["en", "es", "pt", "pt_BR", "fr", "de", "ja"]
arbs = {}
for loc in locales:
    name = "app_pt_BR.arb" if loc == "pt_BR" else f"app_{loc}.arb"
    arbs[loc] = json.loads((root / name).read_text(encoding="utf-8"))

en = {k: v for k, v in arbs["en"].items() if not k.startswith("@")}
lines: list[str] = []

lines.append("=== COMPLETENESS ===")
lines.append(f"EN string keys: {len(en)}")
for loc in locales[1:]:
    keys = {k for k in arbs[loc] if not k.startswith("@")}
    missing = set(en) - keys
    extra = keys - set(en)
    lines.append(f"{loc}: keys={len(keys)} missing={len(missing)} extra={len(extra)}")

ph = re.compile(r"\{(\w+)\}")
lines.append("\n=== PLACEHOLDER MISMATCHES ===")
mismatches = 0
for loc in locales[1:]:
    for k, ev in en.items():
        if not isinstance(ev, str):
            continue
        ep = set(ph.findall(ev))
        lv = arbs[loc].get(k)
        if not isinstance(lv, str):
            continue
        lp = set(ph.findall(lv))
        if ep != lp:
            mismatches += 1
            lines.append(f"{loc}.{k}: en={ep} {loc}={lp}")
if mismatches == 0:
    lines.append("none")

# intentional English / native-script language names
ok_identical = {
    "appTitle",
    "settingsLanguageSubtitle",
    "languageEnglish",
    "languageSpanish",
    "languagePortugueseBrazil",
    "languageFrench",
    "languageGerman",
    "languageJapanese",
    "settingsBeta",
    "hostTurnLimitOff",
    "hostToggleAutoKo",
    "profileStatSparks",
    "navLobby",  # often kept as Lobby in DE/PT
    "lobbyTitle",
    "lookupRulings",
    "lookupOracleText",
}

lines.append("\n=== IDENTICAL TO ENGLISH (need judgment) ===")
for loc in locales[1:]:
    same = []
    for k, ev in en.items():
        if not isinstance(ev, str):
            continue
        if arbs[loc].get(k) == ev:
            same.append((k, ev))
    review = [(k, v) for k, v in same if k not in ok_identical]
    ok = [(k, v) for k, v in same if k in ok_identical]
    lines.append(f"\n[{loc}] total identical={len(same)} review={len(review)} ok_brand={len(ok)}")
    for k, ev in review:
        lines.append(f"  REVIEW {k}: {ev}")

lines.append("\n=== LENGTH RATIO vs EN (top blowups) ===")
for loc in ["de", "es", "fr", "pt_BR", "ja"]:
    ratios = []
    for k, ev in en.items():
        lv = arbs[loc].get(k, "")
        if isinstance(ev, str) and isinstance(lv, str) and len(ev) >= 10:
            ratios.append((len(lv) / len(ev), k, len(ev), len(lv), lv))
    ratios.sort(reverse=True)
    lines.append(f"\n[{loc}]")
    for r, k, le, ll, s in ratios[:15]:
        if r < 1.35 and loc != "ja":
            continue
        lines.append(f"  {r:.2f}x {k} ({le}->{ll}): {s}")

# suspicious patterns: English leftovers in long body strings
english_needles = [
    "tap ",
    "Tap ",
    "Retry",
    "Settings",
    "Home",
    "Leave",
    "Waiting for",
    "Could not",
    "Need at least",
    "Everyone must",
]
lines.append("\n=== ENGLISH FRAGMENTS IN NON-EN LONG STRINGS ===")
for loc in locales[1:]:
    hits = []
    for k, ev in en.items():
        lv = arbs[loc].get(k)
        if not isinstance(lv, str) or lv == ev:
            continue
        if len(lv) < 25:
            continue
        for n in english_needles:
            if n in lv and n not in ("Life Spark",):
                # allow intentional product words
                if n in lv:
                    hits.append((k, n, lv[:100]))
                    break
    lines.append(f"[{loc}] hits={len(hits)}")
    for k, n, s in hits[:20]:
        lines.append(f"  '{n}' in {k}: {s}")

# spot check matrix
spot = [
    "lobbyHostGame",
    "lobbyJoinGame",
    "hostStartGame",
    "joinTitle",
    "welcomeTagline",
    "onboardingSlide1Title",
    "sessionLeaveTitle",
    "gameEndTurn",
    "forfeitTitle",
    "timeoutBanner",
    "reconnectToTable",
    "profileEmptyRecentGames",
    "decksEmptyTitle",
    "lookupTitle",
    "gameBarTimeout",
    "hostEveryoneMustBeReady",
    "joinConnectTimeout",
    "forfeitStaySpectateBody",
    "onboardingSlide3Body",
    "settingsLanguage",
    "navProfile",
    "navDecks",
    "commonCancel",
    "commonTryAgain",
]
lines.append("\n=== SPOT CHECK MATRIX ===")
for k in spot:
    lines.append(f"\n## {k}")
    for loc in locales:
        lines.append(f"  {loc}: {arbs[loc].get(k)}")

# pt vs pt_BR drift
lines.append("\n=== pt vs pt_BR DIFFS ===")
diffs = []
for k in en:
    a, b = arbs["pt"].get(k), arbs["pt_BR"].get(k)
    if a != b:
        diffs.append(k)
lines.append(f"diff count: {len(diffs)}")
for k in diffs[:40]:
    lines.append(f"  {k}")
    lines.append(f"    pt:    {arbs['pt'].get(k)}")
    lines.append(f"    pt_BR: {arbs['pt_BR'].get(k)}")

out.write_text("\n".join(lines) + "\n", encoding="utf-8")
print(f"wrote {out} ({len(lines)} lines)")
