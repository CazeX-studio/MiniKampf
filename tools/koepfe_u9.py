"""w1 und m1 neu im Muster von m2, m3, w2, w3 (GRAFIK_AUFTRAG.md Teil U9, 14.11.2026).

w1 und m1 waren die ersten Köpfe: kleiner und anders aufgebaut als die übrigen vier. Ihr neues Blatt
tools/vorlagen/<kopf>_kopf.png hat genau die Aufteilung von B7 (Seite 5 Gesichter nach rechts, schräg von vorne
4 Gesichter nach LINKS, schräg von hinten 2). Damit alles einheitlich ist:
- Jede Richtung wird mit demselben Faktor verkleinert wie beim Musterkopf (w1 wie w2, m1 wie m2): Faktor =
  Höhe des Musterkopfs im Spiel / Höhe im Musterblatt.
- Die Köpfe werden so gespeichert, wie sie gemalt sind; w1 und m1 stehen darum wie m2, m3, w2, w3 in KOPF_VORN_LINKS
  (scripts/kampf/figur_teile.gd).
- Halspunkte wie in tools/kopf_koerper.py (am normalen Kopf der Richtung gemessen, die anderen Gesichter daran
  ausgerichtet), eingetragen bei jedem Körper, der den Kopf kennt.
Danach: tools/koepfe_u.py w1 m1 (gerade von vorne/hinten passend zur neuen Größe) und tools/haar_hinten.py w1.
Aufruf: python3 tools/koepfe_u9.py [kopf …]
"""
import json
import sys
from pathlib import Path

import numpy as np
from PIL import Image

WURZEL = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(WURZEL / "tools"))
from kopf_koerper import hals, koepfe_schneiden, suchen, verkleinern  # noqa: E402

KOEPFE = WURZEL / "assets" / "teile" / "koepfe"
DATEN = WURZEL / "data" / "figurteile.json"
MUSTER = {"w1": "w2", "m1": "m2"}


def hoehe(bild):
	ys = np.where((bild[..., 3] > 128).any(1))[0]
	return ys.max() - ys.min() + 1


def main():
	daten = json.loads(DATEN.read_text(encoding="utf-8"))
	for kopf in sys.argv[1:] or list(MUSTER):
		muster = MUSTER[kopf]
		gross_muster = koepfe_schneiden(muster)
		faktoren = {}
		for richtung in ["seite", "vorn", "hinten"]:
			spiel = np.array(Image.open(KOEPFE / f"{muster}_{richtung}_normal.png").convert("RGBA"))
			faktoren[richtung] = hoehe(spiel) / hoehe(gross_muster[f"{richtung}_normal"])
		teile = {name: verkleinern(k, faktoren[name.split("_")[0]]) for name, k in koepfe_schneiden(kopf).items()}
		punkte = {}
		for name, bild in teile.items():
			Image.fromarray(bild).save(KOEPFE / f"{kopf}_{name}.png")
			normal = teile[name.split("_")[0] + "_normal"]
			punkt = hals(normal)
			_, dx, dy = suchen(normal, bild)
			punkte[name] = [round(punkt[0] - dx, 1), int(punkt[1] - dy)]
		n = 0
		for eintrag in daten.values():
			if isinstance(eintrag, dict) and kopf in eintrag.get("_koepfe", {}):
				eintrag["_koepfe"][kopf]["hals"].update(punkte)
				n += 1
		print(f"{kopf}: wie {muster}, Faktoren { {r: round(f, 3) for r, f in faktoren.items()} }, bei {n} Körpern eingetragen")
	DATEN.write_text(json.dumps(daten, ensure_ascii=False, indent="\t", sort_keys=True), encoding="utf-8")


if __name__ == "__main__":
	main()
