"""Schneidet das Blatt mit den Gegenstands-Symbolen (tools/vorlagen/gegenstaende.png) in einzelne Bilder.

Das Blatt hat pinken Hintergrund (Auftrag B6 in Spieldesign/GRAFIK_AUFTRAG.md). Jedes Symbol wird freigestellt,
quadratisch zugeschnitten und auf 96 × 96 Pixel verkleinert (das Spiel zeigt es weich verkleinert im Taschen-Kästchen).
Ergebnis: assets/gegenstaende/<gegenstand>.png, die Kennungen wie in data/gegenstaende.json.
Aufruf: python3 tools/gegenstand_bilder.py   (braucht numpy, scipy und Pillow)
"""
import sys
from pathlib import Path

import numpy as np
from PIL import Image
from scipy import ndimage

WURZEL = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(WURZEL / "tools"))
from monster_bilder import freistellen  # noqa: E402

BLATT = WURZEL / "tools" / "vorlagen" / "gegenstaende.png"
ZIEL = WURZEL / "assets" / "gegenstaende"
GROESSE = 96
# Reihen von oben nach unten, je von links nach rechts
REIHEN = [
	["heiltrank", "kraut", "wiesenkraut", "wildfleisch", "honigwabe"],
	["sternensplitter", "schleuder", "buerste", "essenskorb", "festschuessel"],
	["festlaterne_arkanum", "festlaterne_messinghafen", "festlaterne_glutoase", "festlaterne_gruenwacht",
		"festlaterne_nebelinseln", "sternentafel", "monsterkarte"],
]


def main():
	a = freistellen(Image.open(BLATT))
	fest = a[..., 3] > 40
	lab, _ = ndimage.label(ndimage.binary_dilation(fest, iterations=2))
	lab[~fest] = 0
	gross, klein = [], []
	for i, sl in enumerate(ndimage.find_objects(lab)):
		if sl is not None:
			(gross if (lab[sl] == i + 1).sum() >= 3000 else klein).append((i + 1, sl))
	# Kleine Teile (Kristallsplitter, Honigtropfen) gehören zum nächsten großen Symbol
	ziel = np.zeros_like(lab)
	for i, _ in gross:
		ziel[lab == i] = i
	for i, sl in klein:
		cy, cx = (sl[0].start + sl[0].stop) / 2, (sl[1].start + sl[1].stop) / 2

		def abstand(g):
			s = g[1]
			return max(s[1].start - cx, 0, cx - s[1].stop) ** 2 + max(s[0].start - cy, 0, cy - s[0].stop) ** 2
		naechst = min(gross, key=abstand)
		if abstand(naechst) < 50 ** 2:
			ziel[lab == i] = naechst[0]
	gross.sort(key=lambda g: (g[1][0].start + g[1][0].stop) / 2)
	reihen, start = [], 0
	for namen in REIHEN:
		reihe = sorted(gross[start:start + len(namen)], key=lambda g: g[1][1].start)
		reihen.append(list(zip(namen, reihe)))
		start += len(namen)
	if start != len(gross):
		raise SystemExit(f"Erwartet {start} Symbole, gefunden {len(gross)}")
	ZIEL.mkdir(parents=True, exist_ok=True)
	for reihe in reihen:
		for name, (i, _) in reihe:
			ys, xs = np.where(ziel == i)
			teil = a[ys.min():ys.max() + 1, xs.min():xs.max() + 1].copy()
			teil[ziel[ys.min():ys.max() + 1, xs.min():xs.max() + 1] != i, 3] = 0
			seite = max(teil.shape[:2]) + 4
			quadrat = Image.new("RGBA", (seite, seite), (0, 0, 0, 0))
			quadrat.alpha_composite(Image.fromarray(teil), ((seite - teil.shape[1]) // 2, (seite - teil.shape[0]) // 2))
			quadrat.resize((GROESSE, GROESSE), Image.LANCZOS).save(ZIEL / f"{name}.png")
			print(name)


if __name__ == "__main__":
	main()
