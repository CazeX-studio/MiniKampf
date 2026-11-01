"""Baut die Monster einer Familie aus zwei Blättern (MONSTER.md, Abschnitt 7; GRAFIK_AUFTRAG.md, Teil C).

Blatt 1 (tools/vorlagen/familie_<familie>_1.png) hat den Grundkörper mit Stehen, Angriff, Getroffen und Fallen.
Die weiteren Blätter haben je Art das Zusatzteil, die Art im Stehen und die besondere Bewegung.
Der Grundkörper wird selbst gespeichert. Jede Art bekommt: den umgefärbten Grundkörper mit aufgesetztem Zusatzteil (idle, attack, hit, death) und ihre
besondere Bewegung (spezial). Ergebnis wie bei monster_bilder.py: assets/figuren/<art>_<anim>_anim_f<n>.png
Aufruf: python3 tools/familien_bilder.py [art …]   (ohne Angabe alle; braucht numpy, scipy und Pillow)
"""
import colorsys
import sys
from pathlib import Path

import numpy as np
from PIL import Image
from scipy import ndimage

import monster_bilder as mb

VORLAGEN = mb.VORLAGEN
HOEHE = 56

# Art -> Familie, Blatt, Reihe mit Zusatzteil und Art im Stehen, Reihe mit besonderer Bewegung.
# "zusatz": Stelle im Bild als Anteil von Breite und Höhe (Mitte des Zusatzteils). "faerben": (von, bis) Farbton in
# Grad, ab welcher Sättigung, neuer Farbton, Faktor Sättigung, Faktor Helligkeit, optional Mindest-Sättigung. "zusatz_mass", "bewegung_mass": Zusatzteil oder Bewegung in anderer Größe.
ARTEN = {
	"tauschleim": {"familie": "schleime", "blatt": 2, "stehen": 0, "bewegung": 1, "zusatz": (0.55, 0.08),
		"faerben": (150, 190, 0.1, 197, 1.0, 1.05)},
	"kronenschleim": {"familie": "schleime", "blatt": 2, "stehen": 2, "bewegung": 3, "hoehe": 84, "zusatz": (0.55, 0.0),
		"faerben": (150, 190, 0.1, 197, 1.0, 1.05)},
	"wiesenhoppler": {"familie": "hasen", "blatt": 2, "stehen": 0, "bewegung": 1, "zusatz": (0.52, 0.42), "zusatz_mass": 0.5,
		"faerben": (15, 42, 0.3, 165, 0.45, 1.05)},
	"knollenkaefer": {"familie": "kaefer", "blatt": 2, "stehen": 0, "bewegung": 1, "zusatz": (0.34, 0.36)},
	"schattenskarabaeus": {"familie": "kaefer", "blatt": 4, "stehen": 0, "bewegung": 1, "bewegung_mass": 1.35,
		"faerben": (0, 60, 0.3, 262, 0.45, 0.36)},
	"glimmerkaefer": {"familie": "kaefer", "blatt": 3, "stehen": 0, "bewegung": 1, "zusatz": (0.34, 0.36)},
	"loewenzahnling": {"familie": "bluetenwesen", "blatt": 2, "stehen": 0, "bewegung": 1, "zusatz": (0.55, 0.12)},
	"kaktusling": {"familie": "bluetenwesen", "blatt": 2, "stehen": 2, "bewegung": 3, "zusatz": (0.55, 0.2)},
	"stachelflitzer": {"familie": "bluetenwesen", "blatt": 3, "stehen": 0, "bewegung": 1, "zusatz": (0.55, 0.2)},
	"funkenflirr": {"familie": "schwaerme", "blatt": 2, "stehen": 0, "bewegung": 1,
		"faerben": (25, 60, 0.3, 46, 1.1, 1.18)},
	"glutigel": {"familie": "igel", "blatt": 2, "stehen": 0, "bewegung": 1, "faerben": (10, 40, 0.3, 12, 1.5, 0.95)},
	# Hirschtal
	"borstenkeiler": {"familie": "wildschweine", "blatt": 2, "stehen": 0, "bewegung": 1, "zusatz": (0.42, 0.1)},
	"dornenranke": {"familie": "ranken", "blatt": 2, "stehen": 0, "bewegung": 1, "zusatz": (0.45, 0.1)},
	"rankenschlinger": {"familie": "ranken", "blatt": 2, "stehen": 2, "bewegung": 3, "hoehe": 96, "zusatz": (0.45, 0.12)},
	"steppenroller": {"familie": "ranken", "blatt": 3, "stehen": 0, "bewegung": 1,
		"faerben": (60, 140, 0.2, 46, 0.7, 1.05)},
	"bachkrebs": {"familie": "krabben", "blatt": 2, "stehen": 0, "bewegung": 1, "bewegung_mass": 1.35, "zusatz": (0.45, 0.14),
		"faerben": (0, 40, 0.3, 208, 0.7, 0.95)},
	"geysirkrabbe": {"familie": "krabben", "blatt": 2, "stehen": 2, "bewegung": 3, "bewegung_mass": 1.35, "zusatz": (0.45, 0.14),
		"faerben": (0, 40, 0.3, 200, 0.6, 1.05)},
	"zankelster": {"familie": "voegel", "blatt": 2, "stehen": 0, "bewegung": 1, "zusatz": (0.9, 0.34),
		"faerben": (0, 70, 0.05, 215, 0.6, 0.72)},
	"windfalke": {"familie": "voegel", "blatt": 2, "stehen": 2, "bewegung": 3, "zusatz": (0.72, 0.24),
		"faerben": (0, 70, 0.05, 40, 1.0, 1.0)},
	"rauchgeier": {"familie": "voegel", "blatt": 3, "stehen": 0, "bewegung": 1, "zusatz": (0.32, 0.3),
		"faerben": (0, 70, 0.05, 18, 0.7, 0.6)},
	"nachtuhu": {"familie": "voegel", "blatt": 3, "stehen": 2, "bewegung": 3, "zusatz": (0.72, 0.22),
		"faerben": (0, 70, 0.05, 256, 0.9, 0.62)},
	"heulwolf": {"familie": "woelfe", "blatt": 2, "stehen": 0, "bewegung": 1, "zusatz": (0.6, 0.3),
		"faerben": (0, 360, 0, 195, 1, 1.02, 0.13)},
	"splitterwolf": {"familie": "woelfe", "blatt": 2, "stehen": 2, "bewegung": 3, "zusatz": (0.4, 0.14),
		"faerben": (0, 360, 0, 268, 1, 0.92, 0.16)},
	"mondschakal": {"familie": "woelfe", "blatt": 3, "stehen": 0, "bewegung": 1, "zusatz": (0.4, 0.2),
		"faerben": (0, 360, 0, 250, 1, 0.68, 0.3)},
	"sporenwolf": {"familie": "woelfe", "blatt": 3, "stehen": 2, "bewegung": 3, "zusatz": (0.4, 0.14),
		"faerben": (0, 360, 0, 38, 1, 1.0, 0.25)},
	"irrlicht": {"familie": "geister", "blatt": 2, "stehen": 0, "bewegung": 1, "bewegung_mass": 1.2, "zusatz": (0.55, 0.02),
		"faerben": (0, 360, 0, 46, 1, 1.02, 0.28)},
	"staubgeist": {"familie": "geister", "blatt": 2, "stehen": 2, "bewegung": 3,
		"faerben": (0, 360, 0, 150, 1, 0.98, 0.14)},
	"glutgeist": {"familie": "geister", "blatt": 3, "stehen": 0, "bewegung": 1,
		"faerben": (0, 360, 0, 16, 1, 0.82, 0.8)},
	"donnerhirsch": {"familie": "hirsche", "blatt": 2, "stehen": 0, "bewegung": 1, "bewegung_mass": 1.6, "zusatz": (0.72, 0.1),
		"faerben": (10, 48, 0.15, 44, 1.2, 1.08)},
	"kronhirsch": {"familie": "hirsche", "blatt": 2, "stehen": 2, "bewegung": 3, "bewegung_mass": 1.6, "zusatz": (0.72, 0.08),
		"faerben": (10, 48, 0.15, 165, 0.3, 1.2)},
}
# Familien ohne Angabe sind klein (HOEHE)
FAMILIEN_HOEHE = {"ranken": 84, "voegel": 84, "woelfe": 84, "geister": 84, "wildschweine": 84, "hirsche": 140}
# Der Grundkörper jeder Familie ist selbst ein Monster
GRUNDKOERPER = {"schleim": "schleime", "hase": "hasen", "kaefer": "kaefer", "bluetenwesen": "bluetenwesen",
	"schwarm": "schwaerme", "igel": "igel", "wildschwein": "wildschweine", "ranke": "ranken", "krabbe": "krabben",
	"vogel": "voegel", "wolf": "woelfe", "geist": "geister", "hirsch": "hirsche"}
# Eingemalte Bewegungslinien fallen weg (Auftrag: ohne Effekte): Blatt -> kleinste Teilgröße, ab welcher Höhe im Blatt
KRUMEN = {"igel_1": (500, 0), "bluetenwesen_2": (300, 740), "bluetenwesen_3": (300, 0), "ranken_1": (300, 0)}


def holen(blatt):
	bild = Image.open(VORLAGEN / f"familie_{blatt}.png")
	if bild.mode == "RGBA":
		# Dunkler Schein ums Motiv: nur der feste Kern bleibt
		a = np.array(bild).copy()
		kern = a[..., 3] >= 128
		if blatt == "geister_1":
			# Der Körper ist halb durchsichtig gemalt: innen füllen
			kern = ndimage.binary_fill_holes(kern)
		a[..., 3] = np.where(kern, 255, 0)
		return a
	a = mb.freistellen(bild).copy()
	if blatt == "schwaerme_2":
		# Eingeschlossene Karo-Löcher im Ring des Schwarmtanzes
		r = a[..., :3].astype(np.int16)
		hoch, tief = r.max(-1), r.min(-1)
		loch = (hoch - tief < 16) & (tief > 205) & (a[..., 3] > 0)
		ll, ln = ndimage.label(loch)
		if ln:
			g = ndimage.sum(loch, ll, range(1, ln + 1))
			w = ndimage.sum(loch & (tief > 244), ll, range(1, ln + 1))
			a[np.isin(ll, [i + 1 for i in range(ln) if g[i] >= 25 and w[i] > 0.2 * g[i]]), 3] = 0
	if blatt in KRUMEN:
		schwelle, ab = KRUMEN[blatt]
		ll, ln = ndimage.label(a[..., 3] > 40)
		g = ndimage.sum(a[..., 3] > 40, ll, range(1, ln + 1))
		for i, sl in enumerate(ndimage.find_objects(ll)):
			if g[i] < schwelle and sl[0].start >= ab:
				a[sl][ll[sl] == i + 1, 3] = 0
	return a


def mitte_x(g):
	return (g[1][1].start + g[1][1].stop) / 2


def reihen(blatt):
	a = holen(blatt)
	ziel, rr = mb.bilder_finden(a, [])
	if blatt == "schwaerme_2":
		# Die einzelne Biene über Bild 4 gehört zu Bild 4
		einzel = rr.pop(1)[0]
		ziel[ziel == einzel[0]] = min(rr[1], key=lambda g: abs(mitte_x(g) - mitte_x(einzel)))[0]
	if blatt == "schleime_2":
		# Die fliegenden Kronen gehören zum Schleim darunter
		for einzel in rr.pop(3):
			ziel[ziel == einzel[0]] = min(rr[3], key=lambda g: abs(mitte_x(g) - mitte_x(einzel)))[0]
	if blatt == "igel_2":
		# Die Glut-Häufchen gehören zum Bild links daneben
		neu = []
		for g in rr[1]:
			if g[1][0].stop - g[1][0].start < 90:
				ziel[ziel == g[0]] = neu[-1][0]
			else:
				neu.append(g)
		rr[1] = neu
	if blatt == "kaefer_4":
		# Die Mistkugel gehört zum Käfer links daneben, die besondere Bewegung geht über zwei Reihen
		for r in rr[1:]:
			r.sort(key=mitte_x)
			neu = []
			for g in r:
				if g[1][1].stop - g[1][1].start < 230 and neu:
					ziel[ziel == g[0]] = neu[-1][0]
				else:
					neu.append(g)
			r[:] = neu
		rr = [rr[0], rr[1] + rr[2]]
	if blatt == "voegel_3":
		# Die beiden Eulenaugen sind ein Zusatzteil
		rr[2].sort(key=mitte_x)
		ziel[ziel == rr[2][1][0]] = rr[2][0][0]
		rr[2].pop(1)
	if blatt == "geister_3":
		# Klumpen und Funken liegen verstreut: oben Zusatzteil und Art, unten sechs gleich breite Spalten
		alle = [g for r in rr for g in r]
		oben = [g for g in alle if g[1][0].stop < a.shape[0] * 0.5]
		art = max(oben, key=lambda g: g[1][0].stop - g[1][0].start)
		klumpen = [g for g in oben if g is not art]
		for g in klumpen[1:]:
			ziel[ziel == g[0]] = klumpen[0][0]
		spalten = {}
		for g in alle:
			if g[1][0].stop >= a.shape[0] * 0.5:
				spalten.setdefault(int(mitte_x(g) * 6 / a.shape[1]), []).append(g)
		unten = []
		for k in sorted(spalten):
			for g in spalten[k][1:]:
				ziel[ziel == g[0]] = spalten[k][0][0]
			unten.append(spalten[k][0])
		rr = [[klumpen[0], art], unten]
	return [[mb.ausschneiden(a, ziel, g[0]) for g in r] for r in rr]


def faerben(teil, regel):
	von, bis, satt, ton, f_s, f_v, *rest = regel
	mindest = rest[0] if rest else 0
	f = teil.astype(np.float32) / 255
	r, g, b = f[..., 0], f[..., 1], f[..., 2]
	hoch, tief = f[..., :3].max(-1), f[..., :3].min(-1)
	d = np.where(hoch > tief, hoch - tief, 1)
	h = np.where(hoch == r, ((g - b) / d) % 6, np.where(hoch == g, (b - r) / d + 2, (r - g) / d + 4)) * 60
	s = np.where(hoch > 0, (hoch - tief) / np.maximum(hoch, 1e-6), 0)
	maske = (h >= von) & (h <= bis) & (s >= satt) & (hoch > 0.2) & (teil[..., 3] > 0)
	aus = teil.copy()
	for y, x in zip(*np.where(maske)):
		rgb = colorsys.hsv_to_rgb(ton / 360, min(1, max(mindest, s[y, x] * f_s)), min(1, hoch[y, x] * f_v))
		aus[y, x, :3] = [round(c * 255) for c in rgb]
	return aus


def aufsetzen(teil, zusatz, stelle):
	"""Setzt das Zusatzteil auf die Stelle im Bild; das Bild wächst nach oben, wenn es nötig ist (Füße bleiben unten)."""
	h, w = teil.shape[:2]
	zh, zw = zusatz.shape[:2]
	x = round(w * stelle[0] - zw / 2)
	y = round(h * stelle[1] - zh / 2)
	oben, links = max(0, -y), max(0, -x)
	rechts = max(0, x + zw - w)
	unten = max(0, y + zh - h)
	leinwand = Image.new("RGBA", (w + links + rechts, h + oben + unten), (0, 0, 0, 0))
	leinwand.alpha_composite(Image.fromarray(teil), (links, oben))
	leinwand.alpha_composite(Image.fromarray(zusatz), (x + links, y + oben))
	return np.array(leinwand)


def skaliert(teil, f):
	b = Image.fromarray(teil)
	return np.array(b.resize((max(1, round(b.width * f)), max(1, round(b.height * f))), Image.LANCZOS))


def art_bauen(name, info):
	grund = reihen(f"{info['familie']}_1")
	bl = reihen(f"{info['familie']}_{info['blatt']}")
	stehen = np.median([mb.fuss(t, False)[2] for t in grund[0]])
	art_h = mb.fuss(bl[info["stehen"]][1], False)[2]
	f = stehen / art_h
	anims = dict(zip(["idle", "attack", "hit", "death"], grund))
	for anim, stuecke in anims.items():
		neu = []
		for t in stuecke:
			if info.get("faerben"):
				t = faerben(t, info["faerben"])
			if info.get("zusatz"):
				t = aufsetzen(t, skaliert(bl[info["stehen"]][0], f * info.get("zusatz_mass", 1)), info["zusatz"])
			neu.append(t)
		anims[anim] = neu
	anims["spezial"] = [skaliert(t, f * info.get("bewegung_mass", 1)) for t in bl[info["bewegung"]]]
	mb.speichern(name, anims, info.get("hoehe", FAMILIEN_HOEHE.get(info["familie"], HOEHE)) * 3 / stehen)


def grund_bauen(name, familie):
	grund = reihen(f"{familie}_1")
	stehen = np.median([mb.fuss(t, False)[2] for t in grund[0]])
	mb.speichern(name, dict(zip(["idle", "attack", "hit", "death"], grund)), FAMILIEN_HOEHE.get(familie, HOEHE) * 3 / stehen)


def main():
	for name in sys.argv[1:] or list(GRUNDKOERPER) + list(ARTEN):
		if name in GRUNDKOERPER:
			grund_bauen(name, GRUNDKOERPER[name])
		else:
			art_bauen(name, ARTEN[name])


if __name__ == "__main__":
	main()
