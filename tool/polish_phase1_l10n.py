#!/usr/bin/env python3
"""Apply Phase 1 l10n polish fixes to ARB files."""

from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(r"c:\Users\Federick Vidot\MTG-Life-Spark\lib\l10n")

FIXES: dict[str, dict[str, str]] = {
    "es": {
        "gameBarTimeout": "Pausa",
        "timeoutStartTitle": "Iniciar pausa",
        "timeoutBanner": "PAUSA",
        "timeoutEnd": "Terminar pausa",
        "timeoutMinimized": "Pausa — {time}",
        "forfeitStaySpectateBody": (
            "Los demás pueden seguir jugando. Quédate en este dispositivo "
            "para ver hasta que termine la mesa. Volver al perfil ahora "
            "guarda tu rendición y te desconecta de la partida en vivo."
        ),
        "profileEmptyRecentGames": (
            "Juega tu primera partida para desbloquear estadísticas e historial."
        ),
        "profileResultConcede": "Rendición",
    },
    "pt": {
        "gameBarTimeout": "Pausa",
        "timeoutStartTitle": "Iniciar pausa",
        "timeoutBanner": "PAUSA",
        "timeoutEnd": "Encerrar pausa",
        "timeoutMinimized": "Pausa — {time}",
        "timeoutMinimizeTooltip": "Minimizar temporizador",
        "forfeitStaySpectateBody": (
            "Os outros podem continuar jogando. Fique neste dispositivo "
            "para assistir até a mesa terminar. Voltar ao perfil agora "
            "salva sua desistência e desconecta da partida ao vivo."
        ),
        "profileEmptyRecentGames": (
            "Jogue sua primeira partida para liberar estatísticas e histórico."
        ),
        "profileResultConcede": "Desistência",
    },
    "pt_BR": {
        "gameBarTimeout": "Pausa",
        "timeoutStartTitle": "Iniciar pausa",
        "timeoutBanner": "PAUSA",
        "timeoutEnd": "Encerrar pausa",
        "timeoutMinimized": "Pausa — {time}",
        "timeoutMinimizeTooltip": "Minimizar temporizador",
        "forfeitStaySpectateBody": (
            "Os outros podem continuar jogando. Fique neste dispositivo "
            "para assistir até a mesa terminar. Voltar ao perfil agora "
            "salva sua desistência e desconecta da partida ao vivo."
        ),
        "profileEmptyRecentGames": (
            "Jogue sua primeira partida para liberar estatísticas e histórico."
        ),
        "profileResultConcede": "Desistência",
    },
    "fr": {
        "hostGameplay": "Jeu",
        "gameBarTimeout": "Pause",
        "timeoutStartTitle": "Démarrer la pause",
        "timeoutBanner": "PAUSE",
        "timeoutEnd": "Fin de la pause",
        "timeoutMinimized": "Pause — {time}",
        "forfeitStaySpectateBody": (
            "Les autres peuvent continuer. Restez sur cet appareil pour "
            "regarder jusqu’à la fin. Retourner au profil maintenant "
            "enregistre votre abandon et vous déconnecte de la partie en direct."
        ),
        "profileEmptyRecentGames": (
            "Jouez votre première partie pour débloquer les statistiques et l’historique."
        ),
        "profileResultConcede": "Abandon",
    },
    "de": {
        "hostMatchLabel": "Bezeichnung",
        "hostGameplay": "Spielablauf",
        "hostToggleTeams": "Teamspiel",
        "hostTrackingDeck": "Erfasst: {name}",
        "gameBarTimeout": "Pause",
        "timeoutStartTitle": "Pause starten",
        "timeoutBanner": "PAUSE",
        "timeoutEnd": "Pause beenden",
        "timeoutMinimized": "Pause — {time}",
        "forfeitStaySpectateBody": (
            "Andere können weiterspielen. Bleib zum Zuschauen, bis der Tisch "
            "fertig ist. Wenn du jetzt zum Profil zurückkehrst, wird deine "
            "Aufgabe gespeichert und die Verbindung zum Live-Spiel getrennt."
        ),
        "profileEmptyRecentGames": (
            "Erstes Spiel spielen, um Statistiken und Verlauf freizuschalten."
        ),
        "profileResultConcede": "Aufgabe",
    },
    "ja": {
        "gameBarTimeout": "一時停止",
        "timeoutStartTitle": "一時停止を開始",
        "timeoutBanner": "一時停止",
        "timeoutEnd": "一時停止を終了",
        "timeoutMinimized": "一時停止 — {time}",
    },
}


def arb_path(loc: str) -> Path:
    return ROOT / ("app_pt_BR.arb" if loc == "pt_BR" else f"app_{loc}.arb")


def main() -> None:
    for loc, fixes in FIXES.items():
        path = arb_path(loc)
        data = json.loads(path.read_text(encoding="utf-8"))
        changed = []
        for key, value in fixes.items():
            if key not in data:
                raise SystemExit(f"missing key {key} in {path.name}")
            if data[key] != value:
                data[key] = value
                changed.append(key)
            else:
                data[key] = value  # ensure written
                if key not in changed:
                    pass
        path.write_text(
            json.dumps(data, ensure_ascii=False, indent=2) + "\n",
            encoding="utf-8",
        )
        print(f"{path.name}: {len(fixes)} polish keys applied ({len(changed)} changed)")


if __name__ == "__main__":
    main()
