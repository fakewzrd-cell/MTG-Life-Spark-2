#!/usr/bin/env python3
"""Add leftover Phase 2 polish keys missed by inventory wiring."""

import json
from pathlib import Path

root = Path(r"c:\Users\Federick Vidot\MTG-Life-Spark")
l10n = root / "lib" / "l10n"

KEYS = {
    "en": {
        "cmdDmgThreatHelp": "Damage each commander has dealt you — {ko} eliminates.",
        "cmdDmgEmptyPod": "Opponents will appear here when others join the pod.",
        "statusOut": "OUT",
        "infoBarAlly": "Ally · {name}",
        "infoBarAllySecret": "secret",
        "gamePlayerDataUnavailable": "Player data unavailable",
        "startupErrorTitle": "Startup Error",
        "startupStackTrace": "Stack trace:",
    },
    "es": {
        "cmdDmgThreatHelp": "Daño que cada comandante te ha hecho — {ko} elimina.",
        "cmdDmgEmptyPod": "Los rivales aparecerán aquí cuando otros se unan a la mesa.",
        "statusOut": "FUERA",
        "infoBarAlly": "Aliado · {name}",
        "infoBarAllySecret": "secreto",
        "gamePlayerDataUnavailable": "Datos del jugador no disponibles",
        "startupErrorTitle": "Error de inicio",
        "startupStackTrace": "Rastreo de pila:",
    },
    "pt": {
        "cmdDmgThreatHelp": "Dano que cada comandante causou a você — {ko} elimina.",
        "cmdDmgEmptyPod": "Os oponentes aparecerão aqui quando outros entrarem na mesa.",
        "statusOut": "FORA",
        "infoBarAlly": "Aliado · {name}",
        "infoBarAllySecret": "secreto",
        "gamePlayerDataUnavailable": "Dados do jogador indisponíveis",
        "startupErrorTitle": "Erro na inicialização",
        "startupStackTrace": "Rastreamento de pilha:",
    },
    "pt_BR": {
        "cmdDmgThreatHelp": "Dano que cada comandante causou a você — {ko} elimina.",
        "cmdDmgEmptyPod": "Os oponentes aparecerão aqui quando outros entrarem na mesa.",
        "statusOut": "FORA",
        "infoBarAlly": "Aliado · {name}",
        "infoBarAllySecret": "secreto",
        "gamePlayerDataUnavailable": "Dados do jogador indisponíveis",
        "startupErrorTitle": "Erro na inicialização",
        "startupStackTrace": "Rastreamento de pilha:",
    },
    "fr": {
        "cmdDmgThreatHelp": "Dégâts que chaque commandant vous a infligés — {ko} élimine.",
        "cmdDmgEmptyPod": "Les adversaires apparaîtront ici quand d’autres rejoindront la table.",
        "statusOut": "HORS JEU",
        "infoBarAlly": "Allié · {name}",
        "infoBarAllySecret": "secret",
        "gamePlayerDataUnavailable": "Données du joueur indisponibles",
        "startupErrorTitle": "Erreur au démarrage",
        "startupStackTrace": "Trace de pile :",
    },
    "de": {
        "cmdDmgThreatHelp": "Schaden, den jeder Commander dir zugefügt hat — {ko} eliminiert.",
        "cmdDmgEmptyPod": "Gegner erscheinen hier, wenn andere dem Tisch beitreten.",
        "statusOut": "RAUS",
        "infoBarAlly": "Verbündeter · {name}",
        "infoBarAllySecret": "geheim",
        "gamePlayerDataUnavailable": "Spielerdaten nicht verfügbar",
        "startupErrorTitle": "Startfehler",
        "startupStackTrace": "Stacktrace:",
    },
    "ja": {
        "cmdDmgThreatHelp": "各統率者が与えたダメージ — {ko}で敗北。",
        "cmdDmgEmptyPod": "他のプレイヤーが参加すると、ここに対戦相手が表示されます。",
        "statusOut": "脱落",
        "infoBarAlly": "同盟 · {name}",
        "infoBarAllySecret": "秘密",
        "gamePlayerDataUnavailable": "プレイヤーデータを読み込めません",
        "startupErrorTitle": "起動エラー",
        "startupStackTrace": "スタックトレース:",
    },
}

META = {
    "cmdDmgThreatHelp": {"placeholders": {"ko": {"type": "int"}}},
    "infoBarAlly": {"placeholders": {"name": {"type": "String"}}},
}

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
    for k, v in KEYS[loc].items():
        arb[k] = v
        if loc == "en" and k in META:
            arb["@" + k] = META[k]
    path.write_text(json.dumps(arb, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(fname, "ok")
