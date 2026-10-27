"""Zerlegt Vegas Kampfbilder-Blätter (tools/vorlagen/vega_kampf_a.png und vega_kampf_b.png) in Einzelbilder.

Blatt A: Stehen (4), Laufen (4), Getroffen (1), Parade (4). Blatt B: Angriff (6, im 4. Bild das Geschoss), Fallen (6), Sieg (4).
Vega schaut nach rechts (im Kampf spiegelt das Spiel sie). Jedes Bild wird freigestellt (weicher Schein und roter
Rand fallen weg), an den Stiefeln ausgerichtet und in dreifacher Auflösung der alten Pixel-Bilder gespeichert
(das Spiel verkleinert sie weich, siehe FighterView.fein_faktor).
Ergebnis: assets/figuren/vega_<anim>_anim_f<n>.png (ersetzt die alten Bilder)
Aufruf: python3 tools/vega_kampfbilder.py   (braucht numpy, scipy und Pillow)
"""
from pathlib import Path

import numpy as np
from PIL import Image
from scipy import ndimage

WURZEL = Path(__file__).resolve().parent.parent
VORLAGEN = WURZEL / "tools" / "vorlagen"
ZIEL = WURZEL / "assets" / "figuren"
## So hoch ist Vega im Stehen (Pixel, ohne Rand): 42 wie die alten Bilder, mal 3 für die feine Darstellung
ZIEL_HOEHE = 42 * 3

# Blatt -> Reihen (Name, Bereich der Bildmitte von oben nach unten, Anzahl) und Schnitte (x0, x1, y), wo sich Bilder berühren
BLAETTER = {
	"vega_kampf_a": {"schnitte": [(40, 430, 772)], "reihen": [
		("idle", (0, 280), 4), ("run", (280, 545), 4), ("hit", (545, 772), 1), ("parry", (772, 1024), 4)]},
	"vega_kampf_b": {"schnitte": [], "reihen": [
		("attack", (0, 330), 6), ("death", (330, 590), 6), ("victory", (590, 887), 4)]},
}


def freistellen(bild):
	a = np.array(bild.convert("RGBA")).astype(np.int16)
	# Weicher Schein: fast durchsichtig, fällt weg
	a[a[..., 3] < 40, 3] = 0
	# Roter Schimmer am Rand (halbdurchsichtig, stark rot)
	r, g, b, alpha = a[..., 0], a[..., 1], a[..., 2], a[..., 3]
	a[(r > g + 90) & (r > b + 60) & (alpha < 200), 3] = 0
	return a.astype(np.uint8)


def bilder_finden(a, info):
	fest = a[..., 3] > 0
	trenn = fest.copy()
	for x0, x1, y in info["schnitte"]:
		trenn[y - 3:y + 4, x0:x1] = False
	lab, n = ndimage.label(ndimage.binary_dilation(trenn, iterations=3))
	lab[~fest] = 0
	gross, klein = [], []
	for i, sl in enumerate(ndimage.find_objects(lab)):
		if sl is None:
			continue
		(gross if (lab[sl] == i + 1).sum() >= 3000 else klein).append((i + 1, sl))
	# Funkeln und kleine Sterne gehören zum nächsten großen Bild (wenn nah genug)
	zuordnung = {i: i for i, _ in gross}
	for i, sl in klein:
		cy, cx = (sl[0].start + sl[0].stop) / 2, (sl[1].start + sl[1].stop) / 2
		def abstand(g):
			s = g[1]
			dx = max(s[1].start - cx, 0, cx - s[1].stop)
			dy = max(s[0].start - cy, 0, cy - s[0].stop)
			return dx * dx + dy * dy
		naechst = min(gross, key=abstand)
		if abstand(naechst) < 50 ** 2:
			zuordnung[i] = naechst[0]
	ziel = np.zeros_like(lab)
	for i, j in zuordnung.items():
		ziel[lab == i] = j
	reihen = {}
	for name, (y0, y1), anzahl in info["reihen"]:
		drin = [g for g in gross if y0 <= (g[1][0].start + g[1][0].stop) / 2 < y1]
		if len(drin) != anzahl:
			raise SystemExit(f"{name}: erwartet {anzahl} Bilder, gefunden {len(drin)}")
		reihen[name] = sorted(drin, key=lambda g: g[1][1].start)
	return ziel, reihen


def ausschneiden(a, ziel, i):
	ys, xs = np.where(ziel == i)
	teil = a[ys.min():ys.max() + 1, xs.min():xs.max() + 1].copy()
	teil[ziel[ys.min():ys.max() + 1, xs.min():xs.max() + 1] != i, 3] = 0
	return teil


def stiefel_x(teil):
	"""Mitte der Stiefel (dunkelbraune Pixel ganz unten), sonst Mitte der untersten Pixel."""
	fest = teil[..., 3] > 128
	ys = np.where(fest.any(1))[0]
	unten = ys.max()
	oben = max(0, unten - int((unten - ys.min()) * 0.15))
	r, g, b = (teil[oben:unten + 1, :, k].astype(int) for k in range(3))
	braun = fest[oben:unten + 1] & (r > g) & (g > b) & (r - b > 35) & (np.maximum(r, np.maximum(g, b)) < 180)
	spalten = np.where(braun.any(0))[0] if braun.sum() > 20 else np.where(fest[oben:unten + 1].any(0))[0]
	return float(spalten.mean()), unten, unten - ys.min()


def links_unten(teil):
	"""Linkes Ende der Figur ganz unten (einzelne Funken zählen nicht)."""
	fest = teil[..., 3] > 128
	unten = np.where(fest.any(1))[0].max()
	spalten = fest[max(0, unten - 20):unten + 1].sum(0)
	return float(np.where(spalten >= 4)[0].min())


def main():
	alle = {}
	massstab = {}
	for blatt, info in BLAETTER.items():
		a = freistellen(Image.open(VORLAGEN / f"{blatt}.png"))
		ziel, reihen = bilder_finden(a, info)
		for name, teile in reihen.items():
			stuecke = [ausschneiden(a, ziel, i) for i, _ in teile]
			messung = [stiefel_x(t) for t in stuecke]
			if name == "death":
				# Beim Fallen liegt sie am Ende: ausrichten am linken Fuß, mit demselben Abstand wie im ersten Bild
				d0 = messung[0][0] - links_unten(stuecke[0])
				messung = [(links_unten(t) + d0, m[1], m[2]) for t, m in zip(stuecke, messung)]
			alle[name] = list(zip(stuecke, messung))
		# Maßstab je Blatt: das erste Bild der ersten Reihe ist ein Stehen
		erste = alle[info["reihen"][0][0]]
		massstab[blatt] = ZIEL_HOEHE / np.median([m[2] for _, m in erste[:4]])
		for name, _, _ in info["reihen"]:
			alle[name] = (alle[name], massstab[blatt])

	for name, (bilder, s) in alle.items():
		links = max(m[0] for _, m in bilder)
		rechts = max(t.shape[1] - m[0] for t, m in bilder)
		hoehe = max(m[1] for _, m in bilder) + 1
		breite = int(2 * max(links, rechts)) + 2
		for alt in ZIEL.glob(f"vega_{name}_anim_f*.png"):
			alt.unlink()
		for n, (teil, (fuss_x, unten, _)) in enumerate(bilder):
			leinwand = Image.new("RGBA", (breite, hoehe), (0, 0, 0, 0))
			leinwand.alpha_composite(Image.fromarray(teil), (int(round(breite / 2 - fuss_x)), int(hoehe - 1 - unten)))
			klein = (max(1, round(breite * s)), max(1, round(hoehe * s)))
			leinwand.resize(klein, Image.LANCZOS).save(ZIEL / f"vega_{name}_anim_f{n}.png")
		print(f"{name:8s} {len(bilder)} Bilder, je {klein[0]} x {klein[1]}")


if __name__ == "__main__":
	main()
