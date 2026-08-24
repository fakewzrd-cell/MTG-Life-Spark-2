import json
from pathlib import Path

root = Path(r"c:\Users\Federick Vidot\MTG-Life-Spark")
data = json.loads((root / "tool" / "phase1_l10n_new.json").read_text(encoding="utf-8"))
meta = data["meta"]
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

for loc, fname in locale_files.items():
    path = l10n / fname
    arb = json.loads(path.read_text(encoding="utf-8"))
    for k, v in data[loc].items():
        arb[k] = v
        if loc == "en" and k in meta:
            arb["@" + k] = meta[k]
    path.write_text(json.dumps(arb, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    n = sum(1 for x in arb if not x.startswith("@"))
    print(f"{fname}: {n} string keys")
