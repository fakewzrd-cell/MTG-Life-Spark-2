#!/usr/bin/env python3
"""Inventory likely user-facing hardcoded English in lib/."""

from __future__ import annotations

import re
from pathlib import Path

lib = Path(r"c:\Users\Federick Vidot\MTG-Life-Spark\lib")
out = Path(r"c:\Users\Federick Vidot\MTG-Life-Spark\tool\hardcoded_en_scan.txt")

# Single- and double-quoted string literals assigned to common UI params
pat = re.compile(
    r"""(?:Text|title|label|subtitle|hintText|tooltip|message|confirmLabel|"""
    r"""cancelLabel|semanticsLabel|helperText|content|header|body|"""
    r"""SnackBar\([^)]*?content:\s*Text)\s*[:(]\s*(['"])([A-ZÀ-ÖØ-Þ][^'"]{2,})\1""",
    re.M,
)
# Also catch show* dialogs and simple const Text("...")
pat2 = re.compile(r"""(?:const\s+)?Text\(\s*(['"])([A-ZÀ-ÖØ-Þ][^'"]{2,})\1""")
pat3 = re.compile(
    r"""(?:title|label|subtitle|hintText|tooltip|message|confirmLabel|cancelLabel|"""
    r"""semanticsLabel|helperText)\s*:\s*(['"])([A-ZÀ-ÖØ-Þ][^'"]{2,})\1"""
)

skip_parts = {"l10n"}
hits: dict[str, list[str]] = {}

for p in lib.rglob("*.dart"):
    if any(s in p.parts for s in skip_parts) or p.name.endswith(".g.dart"):
        continue
    text = p.read_text(encoding="utf-8")
    found: set[str] = set()
    for rx in (pat, pat2, pat3):
        for m in rx.finditer(text):
            s = m.group(2) if m.lastindex and m.lastindex >= 2 else m.group(1)
            if s.startswith(("http", "assets/", "package:", "file:")):
                continue
            if "${" in s or "$" in s:
                # keep template shells as inventory hints
                pass
            found.add(s)
    if found:
        hits[str(p.relative_to(lib)).replace("\\", "/")] = sorted(found)

lines = [f"files_with_hardcoded_EN={len(hits)}", f"total_strings={sum(len(v) for v in hits.values())}"]
for f, ss in sorted(hits.items()):
    lines.append(f"\n{f} ({len(ss)})")
    for s in ss:
        lines.append(f"  - {s}")

out.write_text("\n".join(lines) + "\n", encoding="utf-8")
print(f"wrote {out} files={len(hits)} strings={sum(len(v) for v in hits.values())}")
