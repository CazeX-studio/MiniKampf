"""Zerlegt die fertigen Bilder einer Figur in Kopf und Körper (Projekt 11, Figuren wie bei Ragnarok).

Für jedes Bild assets/figuren/<figur>_<anim>_anim_f<n>.png:
- Halslinie: die oberste Reihe des Halstuchs (gelb bei Kofi, Farbe in FIGUREN).
- Kopf: alles über der Halslinie, das zum größten zusammenhängenden Stück gehört; Schwert und Metall bleiben beim Körper.
- Ankerpunkt: Mitte der Kopf-Unterkante (dort sitzt der Kopf auf dem Hals).
Ergebnis: assets/teile/koerper/<figur>_<anim>_f<n>.png (Körper ohne Kopf, gleiche Bildgröße),
assets/teile/kopf/<figur>_<anim>_f<n>.png (nur der Kopf, eng zugeschnitten) und data/figurteile.json mit den Ankerpunkten.
Bilder, in denen sich kein Hals findet (z. B. liegend), bleiben ganz beim Körper („ganz“: true).
Aufruf: python3 tools/kopf_koerper.py [figur …]
"""
import json
import re
import sys
from pathlib import Path

import numpy as np
from PIL import Image
from scipy import ndimage

WURZEL = Path(__file__).resolve().parent.parent
FIGUREN_ORDNER = WURZEL / "assets" / "figuren"
TEILE = WURZEL / "assets" / "teile"
DATEN = WURZEL / "data" / "figurteile.json"

# Figur -> Erkennungsfarbe des Halstuchs (Bedingung auf r, g, b)
FIGUREN = {
	"kofi": lambda r, g, b: (r > 190) & (g > 130) & (b < 90) & (r - b > 110),
}
## Ab so vielen Halstuch-Pixeln in einer Reihe gilt die Reihe als Halslinie
MIN_TUCH = 4


def zerlegen(bild, ist_tuch):
	a = np.array(bild.convert("RGBA")).astype(int)
	r, g, b, alpha = a[..., 0], a[..., 1], a[..., 2], a[..., 3]
	fest = alpha > 60
	tuch = ist_tuch(r, g, b) & fest
	reihen = np.where(tuch.sum(1) >= MIN_TUCH)[0]
	oben = np.where(fest.any(1))[0].min()
	if len(reihen) == 0 or reihen[0] - oben < 15:
		return None
	hals = int(reihen[0])
	# Metall (Schwert, Beschläge: hell und kaum farbig) gehört zum Körper
	hoch, tief = a[..., :3].max(-1), a[..., :3].min(-1)
	metall = (hoch - tief < 35) & (hoch > 120)
	kandidat = fest.copy()
	kandidat[hals:] = False
	kandidat &= ~metall
	lab, n = ndimage.label(kandidat)
	if n == 0:
		return None
	groessen = ndimage.sum(kandidat, lab, range(1, n + 1))
	kopf = lab == (int(np.argmax(groessen)) + 1)
	# Halbdurchsichtige Ränder des Kopfes mitnehmen
	kopf = ndimage.binary_dilation(kopf, iterations=1) & (alpha > 0)
	kopf[hals:] = False
	ys, xs = np.where(kopf)
	unten = ys.max()
	anker_x = float(xs[ys >= unten - 6].mean())
	kopf_bild = a.copy()
	kopf_bild[~kopf, 3] = 0
	koerper_bild = a.copy()
	koerper_bild[kopf, 3] = 0
	x0, y0, x1, y1 = xs.min(), ys.min(), xs.max() + 1, ys.max() + 1
	return {
		"kopf": Image.fromarray(kopf_bild[y0:y1, x0:x1].astype(np.uint8)),
		"koerper": Image.fromarray(koerper_bild.astype(np.uint8)),
		"pos": [int(x0), int(y0)],
		"anker": [round(anker_x - x0, 1), int(unten + 1 - y0)],
		"hals": [round(anker_x, 1), int(unten + 1)],
	}


def main():
	daten = json.loads(DATEN.read_text()) if DATEN.exists() else {}
	for figur in sys.argv[1:] or list(FIGUREN):
		eintrag = {}
		(TEILE / "kopf").mkdir(parents=True, exist_ok=True)
		(TEILE / "koerper").mkdir(parents=True, exist_ok=True)
		for alt in list((TEILE / "kopf").glob(f"{figur}_*.png")) + list((TEILE / "koerper").glob(f"{figur}_*.png")):
			alt.unlink()
		for pfad in sorted(FIGUREN_ORDNER.glob(f"{figur}_*_anim_f*.png")):
			m = re.match(rf"{figur}_(.+)_anim_f(\d+)\.png", pfad.name)
			anim, n = m.group(1), int(m.group(2))
			name = f"{anim}_f{n}"
			bild = Image.open(pfad)
			teile = zerlegen(bild, FIGUREN[figur])
			if teile is None:
				bild.save(TEILE / "koerper" / f"{figur}_{name}.png")
				eintrag[name] = {"ganz": True}
				continue
			teile["koerper"].save(TEILE / "koerper" / f"{figur}_{name}.png")
			teile["kopf"].save(TEILE / "kopf" / f"{figur}_{name}.png")
			eintrag[name] = {"hals": teile["hals"], "anker": teile["anker"]}
		daten[figur] = eintrag
		ganz = [k for k, v in eintrag.items() if v.get("ganz")]
		print(f"{figur}: {len(eintrag)} Bilder, {len(eintrag) - len(ganz)} getrennt, ganz geblieben: {ganz}")
	daten["_hinweis"] = ("Kopf und Körper der Figuren (Projekt 11), erzeugt mit tools/kopf_koerper.py. Pro Bild: hals = Punkt im "
			"Körperbild, auf dem der Kopf sitzt; anker = derselbe Punkt im Kopfbild; ganz = Bild nicht getrennt (z. B. liegend).")
	DATEN.write_text(json.dumps(daten, ensure_ascii=False, indent="\t", sort_keys=True))


if __name__ == "__main__":
	main()
