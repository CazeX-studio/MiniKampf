"""Stadt-Editor (S4): Eine Datei aus dem Stadt-Editor (stadt_<karte>.json, im Browser heruntergeladen) in die
Kartendaten übernehmen. Dasselbe macht der Editor im Godot-Editor selbst (StadtEditor.uebernehmen).

Aufruf: python3 tools/stadt_editor_uebernehmen.py <stadt_karte.json>
"""
import json
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
    # Figuren: Kreuzweg in kreuzweg.json, alle anderen Karten in karten.json
    pfad = DATA / ("kreuzweg.json" if paket["karte"] == "kreuzweg" else "karten.json")
    text = pfad.read_text(encoding="utf-8")
    alle = json.loads(text)
    ort = alle if paket["karte"] == "kreuzweg" else alle[paket["karte"]]
    npcs = ort.setdefault("npcs", {})
    for npc_id in paket.get("geloescht", []):
        npcs.pop(npc_id, None)
    for npc_id, figur in paket["npcs"].items():
        if figur.get("neu") and npc_id not in npcs:
            npcs[npc_id] = {"name": figur["name"], "feld": figur["feld"], "aussehen": figur["aussehen"], "dialog": figur["dialog"]}
            if "wenn" in figur:
                npcs[npc_id]["wenn"] = figur["wenn"]
        elif npc_id in npcs:
            npcs[npc_id]["feld"] = figur["feld"]
            if "nachts" in figur:
                npcs[npc_id]["nachts"] = figur["nachts"]
    schreiben(pfad, alle, text)
    print(f"Übernommen: {paket['karte']} ({len(paket['objekte'])} Teile, {len(paket['npcs'])} Figuren)")


if __name__ == "__main__":
    main()
