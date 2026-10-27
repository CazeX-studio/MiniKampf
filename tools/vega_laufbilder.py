"""Zerlegt Vegas Laufbilder-Blatt (tools/vorlagen/vega_laufen.png) in Einzelbilder für das Spiel.

Das Blatt hat 4 Reihen mit je 6 Bildern: Stehen nach vorne, Laufen nach vorne, Stehen nach hinten, Laufen nach hinten
(jeweils schräg nach rechts; nach links spiegelt das Spiel). Jedes Bild wird freigestellt (der weiche Schein fällt weg),
an den Füßen ausgerichtet und in dreifacher Auflösung der bisherigen Vega-Bilder gespeichert (das Spiel zeigt sie
weich verkleinert in derselben Größe, dadurch bleiben die Einzelheiten aus Marcos Bildern erhalten).
Ergebnis: assets/figuren/vega_<idle|run>_<vorn|hinten>_anim_f<0-5>.png
Aufruf: python3 tools/vega_laufbilder.py   (braucht numpy, scipy und Pillow)
"""
from pathlib import Path

import numpy as np
from PIL import Image
from scipy import ndimage

WURZEL = Path(__file__).resolve().parent.parent
BLATT = WURZEL / "tools" / "vorlagen" / "vega_laufen.png"
ZIEL = WURZEL / "assets" / "figuren"
REIHEN = ["idle_vorn", "run_vorn", "idle_hinten", "run_hinten"]
## So hoch ist Vega in den bisherigen Bildern (Pixel, ohne Rand) mal 3: gleiche Größe im Spiel, aber feiner
ZIEL_HOEHE = 42 * 3


def main():
	a = np.array(Image.open(BLATT).convert("RGBA"))
	# Weicher Schein um die Figur: fast durchsichtig, fällt weg
	a[a[..., 3] < 40, 3] = 0
	fest = a[..., 3] > 0
	lab, _ = ndimage.label(ndimage.binary_dilation(fest, iterations=3))
	lab[~fest] = 0
	stuecke = []
	for i, sl in enumerate(ndimage.find_objects(lab)):
		if sl is not None and (lab[sl] == i + 1).sum() >= 3000:
			stuecke.append((i + 1, sl))
	if len(stuecke) != 24:
		raise SystemExit(f"Erwartet 24 Bilder, gefunden {len(stuecke)}")
	# In 4 Reihen zu je 6 sortieren (oben nach unten, links nach rechts)
	stuecke.sort(key=lambda s: (s[1][0].start + s[1][0].stop) / 2)
	reihen = [sorted(stuecke[r * 6:(r + 1) * 6], key=lambda s: s[1][1].start) for r in range(4)]

	bilder = []
	for reihe in reihen:
		zeile = []
		for i, sl in reihe:
			teil = a[sl].copy()
			teil[lab[sl] != i, 3] = 0
			maske = teil[..., 3] > 128
			ys = np.where(maske.any(1))[0]
			unten = ys.max()
			# Fußpunkt: Mitte der festen Pixel in den untersten Zeilen
			fuss_x = np.where(maske[max(0, unten - int((unten - ys.min()) * 0.12)):unten + 1].any(0))[0].mean()
			zeile.append((Image.fromarray(teil), fuss_x, unten, unten - ys.min()))
		bilder.append(zeile)

	# Gemeinsame Leinwand: alle Bilder an den Füßen ausgerichtet
	links = max(f for z in bilder for _, f, _, _ in z)
	rechts = max(b.width - f for z in bilder for b, f, _, _ in z)
	hoehe = max(u for z in bilder for _, _, u, _ in z) + 1
	breite = int(2 * max(links, rechts)) + 2
	stehen_hoehe = np.median([h for _, _, _, h in bilder[0]])
	massstab = ZIEL_HOEHE / stehen_hoehe
	klein = (max(1, round(breite * massstab)), max(1, round(hoehe * massstab)))
	for name, zeile in zip(REIHEN, bilder):
		for n, (bild, fuss_x, unten, _) in enumerate(zeile):
			leinwand = Image.new("RGBA", (breite, hoehe), (0, 0, 0, 0))
			leinwand.alpha_composite(bild, (int(round(breite / 2 - fuss_x)), int(hoehe - 1 - unten)))
			leinwand.resize(klein, Image.LANCZOS).save(ZIEL / f"vega_{name}_anim_f{n}.png")
	print("Fertig:", klein, "Pixel pro Bild, Maßstab", round(massstab, 3))


if __name__ == "__main__":
	main()
