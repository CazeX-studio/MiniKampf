"""Körper-Blätter mit grünem Kopf-Platzhalter einbauen (Projekt 11, Auftrag B8 in Spieldesign/GRAFIK_AUFTRAG.md).

Blätter in tools/vorlagen/<körper>_kampf_a.png, _kampf_b.png, _welt.png (Aufbau wie Kofis Blätter, fehlende Blätter
werden übersprungen). Ablauf:
1. Zerlegen wie bei tools/figur_bilder.py: ganze Bilder (mit grünem Oval) nach assets/figuren/<körper>_<anim>_anim_f<n>.png.
2. Das grüne Oval wird herausgenommen: assets/teile/koerper/<körper>_<anim>_f<n>.png.
3. Halspunkt = Mitte des Ovals, knapp unter seiner sichtbaren Unterkante (dort, wo es im Halstuch verschwindet).
   Dort setzt das Spiel den gewählten Kopf ein (alle Köpfe aus tools/kopf_koerper.py passen).
data/figurteile.json: pro Bild hals und richtung, dazu _nur_teile (das Spiel setzt immer zusammen) und _koepfe.
Aufruf: python3 tools/koerper_blatt.py [körper …]   (braucht numpy, scipy und Pillow; vorher tools/kopf_koerper.py)
"""
import json
import sys
from pathlib import Path

import numpy as np
from PIL import Image
from scipy import ndimage

WURZEL = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(WURZEL / "tools"))
from figur_bilder import FIGUREN, VORLAGEN, blatt  # noqa: E402
from kopf_koerper import richtung_von  # noqa: E402
from monster_bilder import speichern  # noqa: E402

TEILE = WURZEL / "assets" / "teile"
DATEN = WURZEL / "data" / "figurteile.json"

## Körper -> Name im Editor. Die Blätter sind aufgebaut wie Kofis (siehe FIGUREN["kofi"] in figur_bilder.py).
KOERPER = {"novize_m": "Novize (m)"}
## Von dieser Figur kommen die Köpfe (alle Köpfe sind auf ihre Größe gebracht)
KOPF_QUELLE = "kofi"
## So weit unter der sichtbaren Unterkante des Ovals sitzt der Hals (Pixel)
HALS_TIEFE = 2


def gruen(a):
	r, g, b = (a[..., i].astype(int) for i in range(3))
	return (a[..., 3] > 20) & (g > r + 60) & (g > b + 60)


def main():
	daten = json.loads(DATEN.read_text()) if DATEN.exists() else {}
	for koerper in sys.argv[1:] or list(KOERPER):
		anims = {}
		for name, reihen in FIGUREN[KOPF_QUELLE].items():
			if (VORLAGEN / f"{koerper}_{name}.png").exists():
				anims.update(blatt(koerper, name, reihen))
			else:
				print(f"{koerper}: Blatt {name} fehlt noch")
		speichern(koerper, anims, 1.0)
		(TEILE / "koerper").mkdir(parents=True, exist_ok=True)
		for alt in (TEILE / "koerper").glob(f"{koerper}_*.png"):
			alt.unlink()
		eintrag = {"_nur_teile": True, "_name": KOERPER[koerper], "_koepfe": daten[KOPF_QUELLE]["_koepfe"]}
		for anim, bilder in anims.items():
			for n in range(len(bilder)):
				bild = np.array(Image.open(WURZEL / "assets" / "figuren" / f"{koerper}_{anim}_anim_f{n}.png").convert("RGBA"))
				platz = gruen(bild)
				name = f"{anim}_f{n}"
				if not platz.any():
					Image.fromarray(bild).save(TEILE / "koerper" / f"{koerper}_{name}.png")
					eintrag[name] = {"ganz": True}
					continue
				ys, xs = np.where(platz & (bild[..., 3] > 128))
				# Grünliche Ränder des Ovals mit wegnehmen
				farbe = bild[..., :3].astype(int)
				gruenlich = farbe[..., 1] > np.maximum(farbe[..., 0], farbe[..., 2]) + 15
				platz |= ndimage.binary_dilation(platz, iterations=2) & gruenlich
				bild[platz, 3] = 0
				Image.fromarray(bild).save(TEILE / "koerper" / f"{koerper}_{name}.png")
				eintrag[name] = {"hals": [round((xs.min() + xs.max()) / 2, 1), int(ys.max()) + HALS_TIEFE],
						"richtung": richtung_von(anim)}
		daten[koerper] = eintrag
		print(f"{koerper}: {sum(len(b) for b in anims.values())} Bilder")
	DATEN.write_text(json.dumps(daten, ensure_ascii=False, indent="\t", sort_keys=True))


if __name__ == "__main__":
	main()
