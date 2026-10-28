"""Zerlegt Monster-Blätter (tools/vorlagen/<monster>.png) in Einzelbilder für den Kampf und die Welt.

Die Blätter kommen von ChatGPT (Aufträge in Spieldesign/GRAFIK_AUFTRAG.md, Teil B2): Reihen mit Stehen, Angriff(en),
Getroffen und Fallen, seitlich nach rechts. Das mitgemalte Karomuster wird entfernt, die Bilder werden Reihe für Reihe
erkannt, an den Füßen ausgerichtet und in dreifacher Auflösung gespeichert (das Spiel zeigt sie mit Größe 1.0 weich
verkleinert, siehe FighterView.fein_faktor). Kleine Teile wie Spritzer oder Splitter gehören zum nächsten Bild.
Ergebnis: assets/figuren/<monster>_<anim>_anim_f<n>.png
Aufruf: python3 tools/monster_bilder.py [monster …]   (ohne Angabe alle; braucht numpy, scipy und Pillow)
"""
import sys
from pathlib import Path

import numpy as np
from PIL import Image
from scipy import ndimage

WURZEL = Path(__file__).resolve().parent.parent
VORLAGEN = WURZEL / "tools" / "vorlagen"
ZIEL = WURZEL / "assets" / "figuren"

# Monster -> Höhe im Kampf (Pixel, Stehen) und Reihen von oben nach unten: (Animation, Anzahl Bilder).
# Eine Reihe kann auf zwei Animationen verteilt werden: ("hit+death", 1) = erstes Bild hit, der Rest death.
# "schnitte": senkrechte Linien (x, y von, y bis), wo sich zwei Bilder berühren; die Linie gehört zum linken Bild.
MONSTER = {
	"feldschleim": {"hoehe": 52, "reihen": [("idle", 4), ("attack", 6), ("hit", 1), ("death", 4)]},
	"wiesenkobold": {"hoehe": 86, "reihen": [("idle", 4), ("attack", 6), ("wurf", 6), ("hit+death", 5)]},
	"kieselkobold": {"vorlage": "wiesenkobold_b", "hoehe": 80, "reihen": [("idle", 7), ("attack", 6), ("wurf", 6),
		("hit+death", 6)]},
	"ruepelkobold": {"hoehe": 140, "schnitte": [(772, 280, 570)], "reihen": [("idle", 4), ("attack", 6), ("hit", 1), ("death", 5)]},
	"sternenfresser": {"hoehe": 170, "reihen": [("idle", 4), ("attack", 6), ("attack2", 5), ("spezial", 5), ("hit", 1),
		("death", 7)]},
}
## Diese Animationen werden an der Rückseite (links unten) ausgerichtet, weil sich das Monster nach vorne streckt
AN_DER_RUECKSEITE = ["attack", "attack2", "wurf", "spezial", "death"]


def freistellen(bild):
	"""Hintergrund (helles Grau/Weiß, auch als Karomuster, mit dem Rand verbunden) wird ganz durchsichtig."""
	a = np.array(bild.convert("RGBA")).astype(np.int16)
	if bild.mode == "RGBA" and a[..., 3].min() == 0:
		return a.astype(np.uint8)
	rgb = a[..., :3]
	hoch, tief = rgb.max(-1), rgb.min(-1)
	grau = (hoch - tief < 22) & (tief > 150)
	lab, _ = ndimage.label(grau)
	rand = set(np.unique(np.concatenate([lab[0], lab[-1], lab[:, 0], lab[:, -1]]))) - {0}
	a[np.isin(lab, list(rand)), 3] = 0
	return a.astype(np.uint8)


def bilder_finden(a, schnitte):
	"""Große Bilder (nach Reihen sortiert) und eine Karte, welcher Pixel zu welchem Bild gehört."""
	fest = a[..., 3] > 40
	trenn = ndimage.binary_dilation(fest, iterations=2)
	for x, y0, y1 in schnitte:
		trenn[y0:y1, x - 2:x + 3] = False
	lab, _ = ndimage.label(trenn)
	for x, y0, y1 in schnitte:
		for dx in range(-2, 3):
			lab[y0:y1, x + dx] = lab[y0:y1, x - 3]
	lab[~fest] = 0
	gross, klein = [], []
	for i, sl in enumerate(ndimage.find_objects(lab)):
		if sl is None:
			continue
		(gross if (lab[sl] == i + 1).sum() >= 2500 else klein).append((i + 1, sl))
	zuordnung = {i: i for i, _ in gross}
	for i, sl in klein:
		cy, cx = (sl[0].start + sl[0].stop) / 2, (sl[1].start + sl[1].stop) / 2

		def abstand(g):
			s = g[1]
			return max(s[1].start - cx, 0, cx - s[1].stop) ** 2 + max(s[0].start - cy, 0, cy - s[0].stop) ** 2
		naechst = min(gross, key=abstand)
		if abstand(naechst) < 60 ** 2:
			zuordnung[i] = naechst[0]
	ziel = np.zeros_like(lab)
	for i, j in zuordnung.items():
		ziel[lab == i] = j
	# Reihen: nach der Unterkante (Füße) gruppieren
	gross.sort(key=lambda g: g[1][0].stop)
	reihen = []
	for g in gross:
		if reihen and g[1][0].stop - reihen[-1][-1][1][0].stop < 70:
			reihen[-1].append(g)
		else:
			reihen.append([g])
	return ziel, [sorted(r, key=lambda g: g[1][1].start) for r in reihen]


def ausschneiden(a, ziel, i):
	ys, xs = np.where(ziel == i)
	teil = a[ys.min():ys.max() + 1, xs.min():xs.max() + 1].copy()
	teil[ziel[ys.min():ys.max() + 1, xs.min():xs.max() + 1] != i, 3] = 0
	return teil


def fuss(teil, rueckseite):
	"""x-Stelle zum Ausrichten (Mitte unten oder Rückseite unten), untere Kante, Höhe."""
	fest = teil[..., 3] > 128
	ys = np.where(fest.any(1))[0]
	unten = ys.max()
	streifen = fest[max(0, unten - max(6, int((unten - ys.min()) * 0.2))):unten + 1].sum(0)
	spalten = np.where(streifen >= 3)[0]
	x = float(spalten.min()) if rueckseite else float(spalten.mean())
	return x, unten, unten - ys.min()


def zerlegen(name, info):
	a = freistellen(Image.open(VORLAGEN / f"{info.get('vorlage', name)}.png"))
	ziel, reihen = bilder_finden(a, info.get("schnitte", []))
	erwartet = [n for _, n in info["reihen"]]
	if [len(r) for r in reihen] != erwartet:
		raise SystemExit(f"{name}: Reihen {[len(r) for r in reihen]}, erwartet {erwartet}")
	anims = {}
	for (anim, _), reihe in zip(info["reihen"], reihen):
		stuecke = [ausschneiden(a, ziel, i) for i, _ in reihe]
		if anim == "hit+death":
			anims["hit"] = stuecke[:1]
			anims["death"] = stuecke[1:]
		else:
			anims[anim] = stuecke
	stehen = np.median([fuss(t, False)[2] for t in anims["idle"]])
	massstab = info["hoehe"] * 3 / stehen
	for alt in ZIEL.glob(f"{name}_*_anim_f*.png"):
		alt.unlink()
	for anim, stuecke in anims.items():
		rueck = anim in AN_DER_RUECKSEITE
		messung = [fuss(t, rueck) for t in stuecke]
		if rueck:
			# Rückseite so weit vom Bildrand wie im Stehen die Mitte von der Rückseite
			mitte = fuss(anims["idle"][0], False)[0] - fuss(anims["idle"][0], True)[0]
			messung = [(x + mitte, u, h) for x, u, h in messung]
		links = max(m[0] for m in messung)
		rechts = max(t.shape[1] - m[0] for t, m in zip(stuecke, messung))
		hoehe = max(m[1] for m in messung) + 1
		breite = int(2 * max(links, rechts)) + 2
		for n, (teil, (fx, unten, _)) in enumerate(zip(stuecke, messung)):
			leinwand = Image.new("RGBA", (breite, hoehe), (0, 0, 0, 0))
			leinwand.alpha_composite(Image.fromarray(teil), (int(round(breite / 2 - fx)), int(hoehe - 1 - unten)))
			klein = (max(1, round(breite * massstab)), max(1, round(hoehe * massstab)))
			leinwand.resize(klein, Image.LANCZOS).save(ZIEL / f"{name}_{anim}_anim_f{n}.png")
	print(f"{name}: " + ", ".join(f"{k} {len(v)}" for k, v in anims.items()))


def main():
	namen = sys.argv[1:] or list(MONSTER)
	for name in namen:
		zerlegen(name, MONSTER[name])


if __name__ == "__main__":
	main()
