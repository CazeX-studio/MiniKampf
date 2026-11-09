"""Stadt-Editor (S4): Eine Datei aus dem Stadt-Editor (stadt_<karte>.json, im Browser heruntergeladen) in die
Kartendaten übernehmen. Dasselbe macht der Editor im Godot-Editor selbst (StadtEditor.uebernehmen).

Aufruf: python3 tools/stadt_editor_uebernehmen.py <stadt_karte.json>
"""
import json
import re
import sys
from pathlib import Path

DATA = Path(__file__).resolve().parent.parent / "data"


def schreiben(pfad: Path, daten, vorher: str) -> None:
    text = json.dumps(daten, indent="\t", ensure_ascii=False)
    pfad.write_text(text + ("\n" if vorher.endswith("\n") else ""), encoding="utf-8")


def main() -> None:
    paket = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
    karte_pfad = DATA / f"{paket['datei']}.json"
    vorher = karte_pfad.read_text(encoding="utf-8")
    daten = json.loads(vorher)
    daten["objekte"] = paket["objekte"]
    schreiben(karte_pfad, daten, vorher)
    if paket["karte"] == "kreuzweg":
        pfad = DATA / "kreuzweg.json"
        zeilen = pfad.read_text(encoding="utf-8").split("\n")
        for i, zeile in enumerate(zeilen):
            for npc_id, figur in paket["npcs"].items():
                if zeile.startswith(f'\t\t"{npc_id}": {{'):
                    zeile = re.sub(r'"feld": \[-?\d+, -?\d+\]', '"feld": [%d, %d]' % tuple(figur["feld"]), zeile)
                    if "nachts" in figur:
                        zeile = re.sub(r'"nachts": \[-?\d+, -?\d+\]', '"nachts": [%d, %d]' % tuple(figur["nachts"]), zeile)
                    zeilen[i] = zeile
        pfad.write_text("\n".join(zeilen), encoding="utf-8")
    else:
        pfad = DATA / "karten.json"
        text = pfad.read_text(encoding="utf-8")
        alle = json.loads(text)
        npcs = alle[paket["karte"]].get("npcs", {})
        for npc_id, figur in paket["npcs"].items():
            if npc_id in npcs:
                npcs[npc_id]["feld"] = figur["feld"]
                if "nachts" in figur:
                    npcs[npc_id]["nachts"] = figur["nachts"]
        schreiben(pfad, alle, text)
    print(f"Übernommen: {paket['karte']} ({len(paket['objekte'])} Teile, {len(paket['npcs'])} Figuren)")


if __name__ == "__main__":
    main()
