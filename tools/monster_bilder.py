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
# Monster mit festen Ausschnitten (wenn sich Bilder berühren oder aus mehreren Blättern stammen):
# Animation -> Liste von Ausschnitten (x0, y0, x1, y1) im Blatt. Ein Ausschnitt kann auch (Blatt, x0, y0, x1, y1, Faktor)
# sein: Bild aus einem anderen Blatt, Faktor gleicht die Größe an. "stehen_boxen" je Blatt: Stehen dort (zum Angleichen).
B = "glutwelpe_bachotter"
BOX_MONSTER = {
	"moosling": {"hoehe": 56, "blatt": "moosling", "anims": {
		"idle": [(75, 40, 240, 190), (270, 40, 440, 190), (460, 40, 620, 190), (640, 40, 830, 190)],
		"attack": [(34, 220, 200, 380), (220, 220, 410, 380), (410, 220, 700, 380), (700, 220, 1118, 380),
			(1132, 220, 1318, 380), (1334, 220, 1512, 380)],
		"attack2": [(34, 418, 232, 562), (248, 418, 432, 562), (438, 418, 624, 562), (624, 418, 1164, 562),
			(1176, 418, 1342, 562), (1352, 418, 1512, 562)],
		"hit": [(54, 606, 260, 752)],
		"death": [(365, 606, 540, 752), (552, 606, 700, 752), (706, 606, 900, 752), (914, 606, 1216, 752)],
		"victory": [(72, 768, 240, 982), (284, 768, 460, 982), (492, 768, 692, 982), (726, 768, 910, 982)]}},
	"glutwelpe": {"hoehe": 60, "blatt": "glutwelpe", "stehen_boxen": {B: [(36, 40, 192, 200), (206, 40, 345, 200),
			(355, 40, 516, 200), (531, 40, 690, 200)]}, "anims": {
		"idle": [(38, 40, 218, 200), (234, 40, 400, 200), (412, 40, 584, 200), (604, 40, 780, 200)],
		# Glutbiss aus dem gemeinsamen Blatt (Marcos Wahl): ducken, Sprung, Sprung, Biss, landen, stehen
		"attack": [(B, 20, 230, 180, 392), (B, 180, 230, 368, 392), (B, 180, 230, 368, 392), (B, 368, 230, 560, 392),
			(B, 562, 230, 740, 392), (B, 562, 230, 740, 392)],
		"spezial": [(32, 418, 230, 598), (240, 418, 470, 598), (470, 418, 760, 598), (760, 418, 1040, 598),
			(1062, 418, 1256, 598), (1288, 418, 1468, 598)],
		"hit": [(40, 640, 226, 758)],
		"death": [(304, 640, 480, 758), (552, 640, 732, 758), (790, 640, 974, 758), (1038, 640, 1216, 758)],
		"victory": [(34, 800, 236, 970), (282, 800, 480, 970), (530, 800, 714, 970), (750, 800, 928, 970)]}},
	"bachotter": {"hoehe": 64, "blatt": "bachotter", "stehen_boxen": {B: [(836, 50, 978, 210), (978, 50, 1103, 210),
			(1103, 50, 1236, 210), (1243, 50, 1362, 210)]}, "anims": {
		"idle": [(58, 30, 190, 195), (218, 30, 373, 195), (409, 30, 553, 195), (580, 30, 738, 195)],
		"attack": [(34, 225, 186, 385), (186, 225, 364, 385), (378, 225, 550, 385), (574, 225, 1136, 385),
			(1145, 225, 1314, 385), (1319, 225, 1490, 385)],
		"wurf": [(34, 225, 186, 385), (186, 225, 364, 385), (378, 225, 550, 385), (574, 225, 1136, 385),
			(1145, 225, 1314, 385), (1319, 225, 1490, 385)],
		"spezial": [(43, 412, 200, 582), (221, 412, 378, 582), (398, 412, 551, 582), (575, 412, 1178, 582),
			(1182, 412, 1333, 582), (1347, 412, 1503, 582)],
		"hit": [(52, 600, 213, 772)],
		# Fallen aus dem gemeinsamen Blatt, das dritte Bild als Einzelbild (Marcos Wahl)
		"death": [(B, 788, 620, 908, 782), (B, 919, 620, 1045, 782),
			("bachotter_fallen_einzeln", 380, 430, 1190, 770, 0.31), (B, 1324, 620, 1526, 782)],
		"victory": [(50, 800, 175, 975), (221, 800, 368, 975), (394, 800, 541, 975), (594, 800, 737, 975),
			(773, 800, 927, 975)]}},
}
## Diese Animationen werden an der Rückseite (links unten) ausgerichtet, weil sich das Monster nach vorne streckt
AN_DER_RUECKSEITE = ["attack", "attack2", "wurf", "spezial", "death"]


def freistellen(bild):
	"""Hintergrund (helles Grau/Weiß, auch als Karomuster, oder Pink, mit dem Rand verbunden) wird ganz durchsichtig."""
	a = np.array(bild.convert("RGBA")).astype(np.int16)
	r, g, b = a[..., 0], a[..., 1], a[..., 2]
	if r[2, 2] > 200 and b[2, 2] > 200 and g[2, 2] < 60:
		# Pinker Hintergrund: Pink weg, rosa Ränder (Mischfarbe mit dem Hintergrund) werden entfärbt
		pink = (r > 170) & (b > 170) & (g < 110) & (np.abs(r - b) < 70)
		# Schatten unter den Füßen (dunkles Lila) fallen auch weg, das Spiel malt eigene
		pink |= (r > 80) & (b > 80) & (g < 50) & (np.abs(r - b) < 60) & (r > g + 60)
		a[pink, 3] = 0
		rand = ndimage.binary_dilation(pink, iterations=2) & ~pink & (r > g + 40) & (b > g + 40)
		a[rand, 3] = 0
		return a.astype(np.uint8)
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
	speichern(name, anims, info["hoehe"] * 3 / stehen)


def speichern(name, anims, massstab):
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


def box_hoehe(a, box):
	x0, y0, x1, y1 = box
	return fuss(a[y0:y1, x0:x1], False)[2]


def zerlegen_boxen(name, info):
	blaetter = {}

	def blatt(n):
		if n not in blaetter:
			blaetter[n] = freistellen(Image.open(VORLAGEN / f"{n}.png"))
		return blaetter[n]
	haupt = info["blatt"]
	stehen = np.median([box_hoehe(blatt(haupt), b) for b in info["anims"]["idle"]])
	# Andere Blätter: Faktor aus dem Stehen dort
	angleich = {n: stehen / np.median([box_hoehe(blatt(n), b) for b in boxen])
		for n, boxen in info.get("stehen_boxen", {}).items()}
	anims = {}
	for anim, boxen in info["anims"].items():
		stuecke = []
		for b in boxen:
			n, faktor = haupt, 1.0
			if isinstance(b[0], str):
				n, b, faktor = b[0], b[1:5], (b[5] if len(b) > 5 else angleich.get(b[0], 1.0))
			x0, y0, x1, y1 = b
			teil = blatt(n)[y0:y1, x0:x1].copy()
			if faktor != 1.0:
				bild = Image.fromarray(teil)
				teil = np.array(bild.resize((round(bild.width * faktor), round(bild.height * faktor)), Image.LANCZOS))
			stuecke.append(teil)
		anims[anim] = stuecke
	speichern(name, anims, info["hoehe"] * 3 / stehen)


def main():
	namen = sys.argv[1:] or list(MONSTER) + list(BOX_MONSTER)
	for name in namen:
		if name in BOX_MONSTER:
			zerlegen_boxen(name, BOX_MONSTER[name])
		else:
			zerlegen(name, MONSTER[name])


if __name__ == "__main__":
	main()
