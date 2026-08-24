#!/usr/bin/env python3
"""Merge phase2_l10n_new.json into lib/l10n app_*.arb files."""

import json
from pathlib import Path

root = Path(r"c:\Users\Federick Vidot\MTG-Life-Spark")
data = json.loads((root / "tool" / "phase2_l10n_new.json").read_text(encoding="utf-8"))
meta = data.get("meta", {})
l10n = root / "lib" / "l10n"

locale_files = {
    "en": "app_en.arb",
    "es": "app_es.arb",
    "pt": "app_pt.arb",
    "pt_BR": "app_pt_BR.arb",
    "fr": "app_fr.arb",
    "de": "app_de.arb",
    "ja": "app_ja.arb",
}

# Validate sync
en_keys = set(data["en"])
for loc in locale_files:
    if loc == "en":
        continue
    keys = set(data[loc])
    if keys != en_keys:
        missing = en_keys - keys
        extra = keys - en_keys
        raise SystemExit(f"{loc}: missing={len(missing)} extra={len(extra)} sample_missing={list(missing)[:5]}")

for loc, fname in locale_files.items():
    path = l10n / fname
    arb = json.loads(path.read_text(encoding="utf-8"))
    added = 0
    for k, v in data[loc].items():
        if k not in arb:
            added += 1
        arb[k] = v
        if loc == "en" and k in meta:
            arb["@" + k] = meta[k]
    path.write_text(json.dumps(arb, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    n = sum(1 for x in arb if not x.startswith("@"))
    print(f"{fname}: {n} string keys (+{added} new)")
