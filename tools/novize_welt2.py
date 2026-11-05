"""Schwert-Punkte für die neuen Welt-Blätter der Novizen (E3g, Blätter tools/vorlagen/novize_*_welt2.png).

Die neuen Blätter haben keine Klinge, an der tools/waffe_punkte.py die Richtung messen könnte. Darum:
- Kampf-Bilder: Griff und Winkel bleiben wie vorher (aus der gespeicherten alten data/figurteile.json, Argument 1).
- Welt-Bilder: Der Winkel kommt aus dem alten Bild derselben Bewegung an der gleichen Stelle des Schritts
  (8 neue Laufbilder auf die alten verteilt), der Griff ist das äußerste Gold auf der Seite der Schwerthand.
Ablauf: alte Datei sichern (git show HEAD:data/figurteile.json > alt.json), python3 tools/koerper_blatt.py novize_m novize_w,
dann python3 tools/novize_welt2.py alt.json
"""
import json
import sys
from pathlib import Path

import numpy as np
from PIL import Image
from scipy import ndimage

WURZEL = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(WURZEL / "tools"))
from koerper_blatt import DATEN  # noqa: E402
from waffe_punkte import HAND_SEITE, gold, ohne_stiefel  # noqa: E402

FIGUR = WURZEL / "assets" / "figuren"
WELT = ["idle_vorn", "run_vorn", "idle_hinten", "run_hinten"]


def griff_von(bild, anim):
	"""Mitte des äußersten Gold-Stücks auf der Seite der Schwerthand."""
	maske = ohne_stiefel(gold(bild), bild)
	lab, n = ndimage.label(maske, structure=np.ones((3, 3)))
	stuecke = []
	for i in range(1, n + 1):
		ys, xs = np.where(lab == i)
		if len(xs) >= 6:
			stuecke.append((xs.mean(), ys.mean()))
	if not stuecke:
		return None
	seite = HAND_SEITE[anim]
	x, y = max(stuecke, key=lambda p: p[0] * seite)
	return [round(float(x), 1), round(float(y), 1)]


def main():
	alt = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
	daten = json.loads(DATEN.read_text(encoding="utf-8"))
	for koerper in ["novize_m", "novize_w"]:
		neu = daten[koerper]
		# Grundeinstellungen des Körpers (z. B. _waffe: das Kurzschwert), die koerper_blatt.py nicht kennt
		for feld, wert in alt[koerper].items():
			if feld.startswith("_") and feld not in neu:
				neu[feld] = wert
		for name, eintrag in neu.items():
			if name.startswith("_"):
				continue
			anim = name.rsplit("_f", 1)[0]
			if anim not in WELT and name in alt[koerper]:
				for feld in ["griff", "waffe_winkel"]:
					if feld in alt[koerper][name]:
						eintrag[feld] = alt[koerper][name][feld]
		for anim in WELT:
			alte = sorted((k for k in alt[koerper] if k.rsplit("_f", 1)[0] == anim and "waffe_winkel" in alt[koerper][k]),
					key=lambda k: int(k.rsplit("_f", 1)[1]))
			neue = sorted((k for k in neu if k.rsplit("_f", 1)[0] == anim), key=lambda k: int(k.rsplit("_f", 1)[1]))
			for i, name in enumerate(neue):
				if not alte:
					break
				vorbild = alt[koerper][alte[round(i * len(alte) / len(neue)) % len(alte)]]
				bild = np.array(Image.open(FIGUR / f"{koerper}_{name.replace('_f', '_anim_f')}.png").convert("RGBA"))
				griff = griff_von(bild, anim)
				if griff is None:
					continue
				neu[name]["griff"] = griff
				neu[name]["waffe_winkel"] = vorbild["waffe_winkel"]
			print(koerper, anim, len(neue), "Bilder")
	DATEN.write_text(json.dumps(daten, ensure_ascii=False, indent="\t", sort_keys=True), encoding="utf-8")


if __name__ == "__main__":
	main()
