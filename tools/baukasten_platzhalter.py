"""Malt die Platzhalter-Bilder für den Baukasten (assets/baukasten/).

Jedes Bild hat schon die richtige Größe und den richtigen Fußpunkt. Später werden die Bilder einfach
durch echte Grafiken mit derselben Größe ersetzt (Regeln in data/BAUKASTEN.md).
Ein Feld (Raute) ist im Bild 32 x 16 Pixel groß und wird im Spiel doppelt so groß gezeigt.
Aufruf: python3 tools/baukasten_platzhalter.py
"""
from pathlib import Path
import random

from PIL import Image, ImageDraw

ZIEL = Path(__file__).resolve().parent.parent / "assets" / "baukasten"
TW, TH = 32, 16  # eine Raute im Bild
UMRISS = (28, 22, 30, 255)


def dunkler(farbe, f=0.75):
	return tuple(int(c * f) for c in farbe[:3]) + (255,)


def heller(farbe, f=1.2):
	return tuple(min(255, int(c * f)) for c in farbe[:3]) + (255,)


def leer(w, h):
	return Image.new("RGBA", (w, h), (0, 0, 0, 0))


def speichern(bild, name):
	pfad = ZIEL / name
	pfad.parent.mkdir(parents=True, exist_ok=True)
	bild.save(pfad)


# --- Boden ---------------------------------------------------------------------------

def raute(d, ox, oy, farbe):
	d.polygon([(ox + TW // 2, oy), (ox + TW - 1, oy + TH // 2), (ox + TW // 2, oy + TH - 1), (ox, oy + TH // 2)], fill=farbe)


def im_rhombus(x, y):
	return abs(x + 0.5 - TW / 2) / (TW / 2) + abs(y + 0.5 - TH / 2) / (TH / 2) <= 1.0


def boden(name, grund, flecken, menge, seed, fugen=False):
	rnd = random.Random(seed)
	bild = leer(TW, TH)
	d = ImageDraw.Draw(bild)
	raute(d, 0, 0, grund)
	px = bild.load()
	for _ in range(menge):
		x, y = rnd.randrange(TW), rnd.randrange(TH)
		if im_rhombus(x, y):
			px[x, y] = rnd.choice(flecken)
	if fugen:
		# Pflastersteine: schräge Fugen in beiden Richtungen
		fuge = dunkler(grund, 0.78)
		for x in range(TW):
			for y in range(TH):
				if im_rhombus(x, y) and ((x // 2 + y) % 6 == 0 or (x // 2 - y) % 6 == 0):
					px[x, y] = fuge
	speichern(bild, f"boden/{name}.png")


def alle_boeden():
	gras, gras2 = (74, 120, 62, 255), (66, 110, 56, 255)
	boden("gras_1", gras, [(92, 140, 70, 255), (58, 98, 50, 255)], 40, 1)
	boden("gras_2", gras2, [(92, 140, 70, 255), (58, 98, 50, 255), (180, 170, 220, 255)], 40, 2)
	stein = (150, 142, 128, 255)
	boden("pflaster_1", stein, [(165, 158, 142, 255)], 30, 3, fugen=True)
	boden("pflaster_2", (144, 136, 124, 255), [(160, 152, 138, 255)], 30, 4, fugen=True)
	boden("platz", (126, 120, 140, 255), [(140, 134, 156, 255)], 30, 5, fugen=True)
	boden("erde", (122, 94, 64, 255), [(104, 80, 54, 255), (138, 108, 74, 255)], 50, 6)
	boden("wasser_1", (46, 92, 140, 255), [(80, 130, 180, 255)], 14, 7)
	boden("wasser_2", (42, 86, 134, 255), [(90, 140, 190, 255)], 14, 8)


# --- Gegenstände ---------------------------------------------------------------------
# Fußpunkt: unten in der Mitte des Bildes. Das Bild ist so breit wie die Grundfläche ((breite + tiefe) * 16).

def grundriss(w, h, unten, cx):
	"""Ecken der Grundfläche (vorne, links, hinten, rechts) für w x h Felder; vorne liegt bei (vx, unten)."""
	vx = cx - (h - w) * TW // 4
	vorne = (vx, unten)
	links = (vx - w * TW // 2, unten - w * TH // 2)
	rechts = (vx + h * TW // 2, unten - h * TH // 2)
	hinten = (links[0] + h * TW // 2, links[1] - h * TH // 2)
	return vorne, links, hinten, rechts


def hoch(p, z):
	return (p[0], p[1] - z)


def kiste(d, w, h, z, unten, cx, farbe, sockel=0):
	"""Ein Quader mit zwei sichtbaren Wänden und Deckel."""
	v, l, hi, r = grundriss(w, h, unten - sockel, cx)
	d.polygon([l, v, hoch(v, z), hoch(l, z)], fill=dunkler(farbe, 0.85), outline=UMRISS)
	d.polygon([v, r, hoch(r, z), hoch(v, z)], fill=dunkler(farbe, 0.62), outline=UMRISS)
	d.polygon([hoch(l, z), hoch(v, z), hoch(r, z), hoch(hi, z)], fill=heller(farbe, 1.1), outline=UMRISS)
	return v, l, hi, r


def bild_fuer(w, h, hoehe):
	breite = (w + h) * TW // 2
	return leer(breite + 2, hoehe), breite // 2 + 1, hoehe - 1


def haus(name, w, h, wand_z, dach, wand=(196, 178, 146, 255)):
	dach_z = min(w, h) * 9 + 10
	bild, cx, unten = bild_fuer(w, h, wand_z + dach_z + (w + h) * TH // 2 + 14)
	d = ImageDraw.Draw(bild)
	v, l, hi, r = kiste(d, w, h, wand_z, unten, cx, wand)
	balken = (80, 56, 40, 255)
	for p in (l, v, r):
		d.line([p, hoch(p, wand_z)], fill=balken, width=2)
	d.line([hoch(l, wand_z // 2), hoch(v, wand_z // 2)], fill=balken)
	d.line([hoch(v, wand_z // 2), hoch(r, wand_z // 2)], fill=balken)
	# Tür und Fenster vorne links
	tx, ty = (l[0] + v[0]) // 2, (l[1] + v[1]) // 2
	d.polygon([(tx - 4, ty - 2), (tx + 4, ty + 2), (tx + 4, ty - 14), (tx - 4, ty - 18)], fill=(60, 40, 28, 255), outline=UMRISS)
	for t in (0.2, 0.8):
		fx = int(l[0] + (v[0] - l[0]) * t)
		fy = int(l[1] + (v[1] - l[1]) * t) - wand_z * 2 // 3
		d.polygon([(fx - 3, fy - 3), (fx + 3, fy), (fx + 3, fy + 5), (fx - 3, fy + 2)], fill=(232, 210, 150, 255), outline=UMRISS)
	# Satteldach: First läuft von links-hinten nach rechts-vorne
	a, b, c, e = hoch(l, wand_z), hoch(v, wand_z), hoch(r, wand_z), hoch(hi, wand_z)
	f1 = ((a[0] + e[0]) // 2, (a[1] + e[1]) // 2 - dach_z)
	f2 = ((b[0] + c[0]) // 2, (b[1] + c[1]) // 2 - dach_z)
	d.polygon([a, e, f1], fill=dunkler(wand, 0.7), outline=UMRISS)
	d.polygon([e, c, f2, f1], fill=dunkler(dach, 0.75), outline=UMRISS)
	d.polygon([b, c, f2], fill=dunkler(wand, 0.55), outline=UMRISS)
	d.polygon([a, b, f2, f1], fill=dach, outline=UMRISS)
	for t in (0.33, 0.66):
		p1 = (int(f1[0] + (a[0] - f1[0]) * t), int(f1[1] + (a[1] - f1[1]) * t))
		p2 = (int(f2[0] + (b[0] - f2[0]) * t), int(f2[1] + (b[1] - f2[1]) * t))
		d.line([p1, p2], fill=dunkler(dach, 0.8))
	# Schornstein
	sx, sy = (f1[0] * 3 + f2[0]) // 4, (f1[1] * 3 + f2[1]) // 4
	d.rectangle([sx - 3, sy - 10, sx + 3, sy + 4], fill=(110, 100, 96, 255), outline=UMRISS)
	speichern(bild, f"objekte/{name}.png")


def marktstand(name, plane):
	bild, cx, unten = bild_fuer(2, 1, 52)
	d = ImageDraw.Draw(bild)
	kiste(d, 2, 1, 10, unten, cx, (130, 96, 60, 255))
	v, l, hi, r = grundriss(2, 1, unten, cx)
	for p in (l, v, r, hi):
		d.line([p, hoch(p, 30)], fill=(70, 50, 34, 255), width=2)
	# Plane schräg nach vorne
	d.polygon([hoch(l, 26), hoch(v, 26), hoch(r, 34), hoch(hi, 36)], fill=plane, outline=UMRISS)
	for i in range(1, 4):
		t = i / 4
		p1 = (int(l[0] + (v[0] - l[0]) * t), int(l[1] + (v[1] - l[1]) * t) - 26)
		p2 = (int(hi[0] + (r[0] - hi[0]) * t), int(hi[1] + (r[1] - hi[1]) * t) - 35)
		d.line([p1, p2], fill=heller(plane, 1.35), width=2)
	# Waren
	for i, farbe in enumerate([(200, 80, 60, 255), (230, 190, 90, 255), (120, 170, 80, 255)]):
		x = l[0] + 6 + i * 7
		y = l[1] + 3 + i * 3 - 12
		d.ellipse([x - 2, y - 2, x + 2, y + 2], fill=farbe, outline=UMRISS)
	speichern(bild, f"objekte/{name}.png")


def statue():
	bild, cx, unten = bild_fuer(2, 2, 78)
	d = ImageDraw.Draw(bild)
	stein = (176, 172, 168, 255)
	kiste(d, 2, 2, 8, unten, cx, dunkler(stein, 0.9))
	v, l, hi, r = grundriss(2, 2, unten, cx)
	mitte = ((l[0] + r[0]) // 2, (v[1] + hi[1]) // 2 - 8)
	# Fünf Figuren im Halbkreis, Kapuzen
	for i, dx in enumerate((-12, -6, 0, 6, 12)):
		dy = -abs(dx) // 3 + (0 if i == 2 else 2)
		x, y = mitte[0] + dx, mitte[1] + dy
		hgt = 34 if i == 2 else 28
		farbe = stein if i % 2 == 0 else dunkler(stein, 0.85)
		d.polygon([(x - 4, y), (x + 4, y), (x + 3, y - hgt + 8), (x - 3, y - hgt + 8)], fill=farbe, outline=UMRISS)
		d.ellipse([x - 3, y - hgt + 1, x + 3, y - hgt + 8], fill=heller(farbe, 1.05), outline=UMRISS)
	# Der gesichtslose Schatten vorne am Boden
	d.ellipse([mitte[0] - 9, mitte[1] + 6, mitte[0] + 9, mitte[1] + 11], fill=(40, 34, 48, 255))
	speichern(bild, "objekte/statue_der_fuenf.png")


def torbogen():
	bild, cx, unten = bild_fuer(3, 1, 104)
	d = ImageDraw.Draw(bild)
	stein = (150, 146, 140, 255)
	v, l, hi, r = grundriss(3, 1, unten, cx)
	# Zwei Pfeiler (hinteres und vorderes Feld), in der Mitte kann man durchgehen, oben ein Querbalken
	hinten = (l[0] + TW // 2, l[1] + TH // 2)
	kiste(d, 1, 1, 52, hinten[1], hinten[0], stein)
	kiste(d, 1, 1, 52, v[1], v[0], stein)
	kiste(d, 3, 1, 12, unten, cx, dunkler(stein, 0.95), sockel=52)
	# Banner an den Pfeilern
	for p in (hinten, v):
		x, y = p[0] - 9, p[1] - 44
		d.rectangle([x, y, x + 6, y + 18], fill=(140, 30, 44, 255), outline=UMRISS)
		d.point((x + 3, y + 8), fill=(240, 220, 200, 255))
	speichern(bild, "objekte/torbogen.png")


def laterne():
	bild = leer(16, 52)
	d = ImageDraw.Draw(bild)
	d.ellipse([3, 47, 13, 51], fill=(60, 56, 60, 255))
	d.rectangle([7, 14, 9, 49], fill=(50, 44, 40, 255))
	d.polygon([(4, 6), (12, 6), (11, 15), (5, 15)], fill=(250, 214, 130, 255), outline=UMRISS)
	d.polygon([(3, 6), (8, 1), (13, 6)], fill=(50, 44, 40, 255), outline=UMRISS)
	speichern(bild, "objekte/laterne.png")


def fackelschale():
	bild = leer(18, 30)
	d = ImageDraw.Draw(bild)
	d.rectangle([4, 14, 13, 29], fill=(130, 126, 120, 255), outline=UMRISS)
	d.polygon([(2, 12), (15, 12), (13, 16), (4, 16)], fill=(90, 84, 80, 255), outline=UMRISS)
	d.polygon([(5, 12), (9, 1), (12, 12)], fill=(255, 160, 60, 255))
	d.polygon([(7, 12), (9, 5), (11, 12)], fill=(255, 230, 140, 255))
	speichern(bild, "objekte/fackelschale.png")


def banner():
	bild = leer(16, 58)
	d = ImageDraw.Draw(bild)
	d.rectangle([3, 4, 5, 57], fill=(70, 50, 34, 255))
	d.line([(3, 6), (14, 6)], fill=(70, 50, 34, 255), width=2)
	d.polygon([(6, 8), (14, 8), (14, 32), (10, 28), (6, 32)], fill=(140, 30, 44, 255), outline=UMRISS)
	d.point([(10, 16), (9, 17), (11, 17), (10, 18), (10, 15), (10, 19)], fill=(240, 220, 200, 255))
	speichern(bild, "objekte/banner.png")


def baum(name, tanne=False):
	bild = leer(34, 60 if tanne else 56)
	d = ImageDraw.Draw(bild)
	h = bild.height
	d.ellipse([7, h - 6, 27, h - 1], fill=(0, 0, 0, 70))
	d.rectangle([15, h - 18, 19, h - 3], fill=(92, 64, 40, 255), outline=UMRISS)
	if tanne:
		gruen = (40, 86, 58, 255)
		for i, (y, b) in enumerate([(h - 16, 15), (h - 28, 12), (h - 40, 9)]):
			d.polygon([(17 - b, y), (17 + b, y), (17, y - 18)], fill=gruen if i % 2 == 0 else heller(gruen, 1.15), outline=UMRISS)
	else:
		gruen = (62, 112, 52, 255)
		for x, y, rr in [(10, h - 26, 9), (24, h - 26, 9), (17, h - 36, 12), (17, h - 24, 10)]:
			d.ellipse([x - rr, y - rr, x + rr, y + rr], fill=gruen, outline=UMRISS)
		for x, y in [(13, h - 40), (21, h - 33), (9, h - 28)]:
			d.ellipse([x - 3, y - 3, x + 3, y + 3], fill=heller(gruen, 1.3))
	speichern(bild, f"objekte/{name}.png")


def klein(name, w, h, zeichnen):
	bild = leer(w, h)
	zeichnen(ImageDraw.Draw(bild), w, h)
	speichern(bild, f"objekte/{name}.png")


def bank(d, w, h):
	holz = (140, 100, 62, 255)
	d.polygon([(4, 14), (18, 7), (28, 12), (14, 19)], fill=holz, outline=UMRISS)
	d.polygon([(4, 14), (14, 19), (14, 21), (4, 16)], fill=dunkler(holz), outline=UMRISS)
	for x, y in [(6, 16), (13, 20), (26, 14)]:
		d.line([(x, y), (x, y + 4)], fill=UMRISS)
	d.polygon([(18, 7), (28, 12), (28, 4), (18, 0)], fill=heller(holz, 1.05), outline=UMRISS)


def fass(d, w, h):
	holz = (128, 88, 52, 255)
	d.rectangle([3, 6, 14, 21], fill=holz, outline=UMRISS)
	d.ellipse([3, 2, 14, 9], fill=heller(holz, 1.15), outline=UMRISS)
	for y in (10, 17):
		d.line([(3, y), (14, y)], fill=(70, 66, 64, 255))


def kistchen(d, w, h):
	kiste(d, 1, 1, 10, h - 3, w // 2, (152, 112, 66, 255))


def zaun(d, w, h):
	holz = (120, 84, 50, 255)
	for x, y in [(2, 22), (16, 15), (30, 8)]:
		d.rectangle([x - 1, y - 14, x + 1, y], fill=holz, outline=UMRISS)
	for dy in (11, 5):
		d.line([(2, 22 - dy), (30, 8 - dy)], fill=heller(holz, 1.1), width=2)


def mauer(d, w, h):
	kiste(d, 1, 1, 16, h - 1, w // 2, (138, 134, 128, 255))
	d.line([(4, h - 17), (14, h - 12)], fill=UMRISS)
	d.line([(20, h - 13), (28, h - 17)], fill=UMRISS)


def busch(d, w, h):
	gruen = (56, 104, 50, 255)
	for x, y, r in [(9, h - 8, 7), (19, h - 8, 7), (14, h - 13, 8)]:
		d.ellipse([x - r, y - r, x + r, y + r], fill=gruen, outline=UMRISS)
	for x, y in [(10, h - 14), (19, h - 11)]:
		d.point((x, y), fill=(200, 60, 70, 255))


def blumen(d, w, h):
	rnd = random.Random(9)
	for _ in range(9):
		x, y = rnd.randrange(4, w - 4), rnd.randrange(4, h - 2)
		d.line([(x, y), (x, y - 3)], fill=(60, 110, 50, 255))
		d.point((x, y - 4), fill=rnd.choice([(230, 220, 250, 255), (200, 70, 80, 255), (140, 150, 240, 255)]))


def wegweiser(d, w, h):
	holz = (128, 92, 56, 255)
	d.rectangle([9, 6, 11, h - 2], fill=dunkler(holz), outline=UMRISS)
	d.polygon([(2, 8), (16, 8), (19, 11), (16, 14), (2, 14)], fill=holz, outline=UMRISS)
	d.polygon([(18, 17), (4, 17), (1, 20), (4, 23), (18, 23)], fill=holz, outline=UMRISS)


def splitterkreis(d, w, h):
	# flacher, leuchtender Kreis auf dem Platz (hier schlägt der Splitter ein)
	d.ellipse([0, 0, w - 1, h - 1], fill=(70, 50, 120, 255), outline=(150, 120, 230, 255))
	d.ellipse([w // 4, h // 4, w * 3 // 4, h * 3 // 4], fill=(36, 24, 70, 255))
	d.ellipse([w // 2 - 2, h // 2 - 1, w // 2 + 2, h // 2 + 1], fill=(230, 220, 255, 255))


def bruecke(d, w, h):
	holz = (150, 112, 70, 255)
	v, l, hi, r = grundriss(1, 3, h - 1, w // 2)
	d.polygon([l, v, r, hi], fill=holz, outline=UMRISS)
	for i in range(1, 6):
		t = i / 6
		p1 = (int(l[0] + (hi[0] - l[0]) * t), int(l[1] + (hi[1] - l[1]) * t))
		p2 = (int(v[0] + (r[0] - v[0]) * t), int(v[1] + (r[1] - v[1]) * t))
		d.line([p1, p2], fill=dunkler(holz, 0.7))
	for a, b in [(l, hi), (v, r)]:
		d.line([hoch(a, 8), hoch(b, 8)], fill=dunkler(holz, 0.6), width=2)
		for t in (0.0, 0.5, 1.0):
			p = (int(a[0] + (b[0] - a[0]) * t), int(a[1] + (b[1] - a[1]) * t))
			d.line([p, hoch(p, 8)], fill=dunkler(holz, 0.6), width=2)


def alle_objekte():
	haus("haus_gross", 3, 3, 42, (150, 52, 48, 255))
	haus("haus_klein", 2, 2, 34, (88, 92, 128, 255), wand=(186, 172, 150, 255))
	marktstand("marktstand_rot", (156, 56, 56, 255))
	marktstand("marktstand_blau", (62, 80, 140, 255))
	statue()
	torbogen()
	laterne()
	fackelschale()
	banner()
	baum("baum")
	baum("tanne", tanne=True)
	klein("bank", 30, 24, bank)
	klein("fass", 18, 24, fass)
	klein("kiste", 34, 30, kistchen)
	klein("zaun", 32, 26, zaun)
	klein("mauer", 34, 36, mauer)
	klein("busch", 28, 22, busch)
	klein("blumen", 28, 14, blumen)
	klein("wegweiser", 20, 34, wegweiser)
	klein("splitterkreis", 48, 24, splitterkreis)
	klein("bruecke", 66, 44, bruecke)


if __name__ == "__main__":
	alle_boeden()
	alle_objekte()
	print("Fertig:", ZIEL)
