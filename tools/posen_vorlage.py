"""Posen-Vorlage für Welt-Blätter (Teil U in Spieldesign/GRAFIK_AUFTRAG.md).

Malt ein Blatt mit Strichfiguren in den Posen und an den Plätzen, die ChatGPT übernehmen soll:
Reihe 1 Laufen schräg von vorne (8 Bilder), Reihe 2 Laufen schräg von hinten (8 Bilder),
Reihe 3 Stehen vorne/hinten und Sitzen vorne/hinten (je 2 Bilder, ruhiges Atmen).
Alle Figuren schauen nach LINKS, das Spiel spiegelt selbst.

Farben der Strichfigur: Kopf grün (wie das Kopf-Oval), Rumpf grau, rechter Arm/rechtes Bein rot,
linker Arm/linkes Bein blau. So bleibt klar, welches Bein vorne ist.

Aufruf: python tools/posen_vorlage.py [Zieldatei]
"""
import math
import sys
from PIL import Image, ImageDraw

BREIT, HOCH = 1536, 1024
SPALTEN, REIHEN = 8, 3
ZELLE_B, ZELLE_H = BREIT // SPALTEN, HOCH // REIHEN
MASS = 100.0         # Pixel je Einheit (eine Kopfhöhe ist etwa 1,05 Einheiten)
NEIGUNG = math.radians(30)   # Blick von schräg oben
PINK = (255, 0, 255)
GRUEN = (0, 255, 0)
GRAU = (120, 120, 120)
ROT, ROT_HINTEN = (220, 40, 40), (150, 30, 30)
BLAU, BLAU_HINTEN = (40, 90, 230), (30, 60, 150)

# Körpermaße (Chibi, rund 3 Kopflängen)
HUEFTE_H, SCHULTER_H, KOPF_H = 0.95, 1.80, 2.42
HUEFTE_B, SCHULTER_B = 0.27, 0.48
OBERSCHENKEL, UNTERSCHENKEL = 0.46, 0.49
OBERARM, UNTERARM = 0.40, 0.36


def glied(start, winkel_vor, laenge):
	"""Punkt am Ende eines Gliedes, das von start nach unten hängt und um winkel_vor nach vorne schwingt."""
	x, y, z = start
	return (x, y - laenge * math.cos(winkel_vor), z + laenge * math.sin(winkel_vor))


def skelett(pose: str, t: float):
	"""Gelenke in Körper-Koordinaten: x = rechts der Figur, y = oben, z = vorne."""
	p = {}
	huepfen = 0.0
	if pose == "laufen":
		phase = 2 * math.pi * t
		huepfen = 0.035 * math.cos(2 * phase)
		for seite, vz, name in ((1, 1, "r"), (-1, -1, "l")):
			schwung = 0.50 * math.sin(phase) * vz
			# Knie beugt sich, während das Bein nach vorne schwingt
			knie = 0.75 * max(0.0, math.cos(phase) * vz) + 0.10
			huefte = (seite * HUEFTE_B, HUEFTE_H + huepfen, 0)
			k = glied(huefte, schwung, OBERSCHENKEL)
			f = glied(k, schwung - knie, UNTERSCHENKEL)
			p["huefte_" + name], p["knie_" + name], p["fuss_" + name] = huefte, k, f
			arm = -0.45 * math.sin(phase) * vz
			schulter = (seite * SCHULTER_B, SCHULTER_H + huepfen, 0)
			e = glied(schulter, arm, OBERARM)
			h = glied(e, arm + 0.35, UNTERARM)
			p["schulter_" + name], p["ellbogen_" + name], p["hand_" + name] = schulter, e, h
	elif pose == "stehen":
		huepfen = 0.02 * t
		for seite, name in ((1, "r"), (-1, "l")):
			huefte = (seite * HUEFTE_B, HUEFTE_H, 0)
			p["huefte_" + name] = huefte
			p["knie_" + name] = (seite * (HUEFTE_B + 0.03), HUEFTE_H - OBERSCHENKEL, 0.02)
			p["fuss_" + name] = (seite * (HUEFTE_B + 0.06), 0, 0)
			schulter = (seite * SCHULTER_B, SCHULTER_H + huepfen, 0)
			p["schulter_" + name] = schulter
			p["ellbogen_" + name] = (seite * (SCHULTER_B + 0.08), SCHULTER_H + huepfen - OBERARM, 0)
			p["hand_" + name] = (seite * (SCHULTER_B + 0.10), SCHULTER_H + huepfen - OBERARM - UNTERARM, 0.06)
	else:  # sitzen: am Boden, Knie angezogen, Hände auf den Knien
		huepfen = 0.02 * t
		runter = HUEFTE_H - 0.16
		for seite, name in ((1, "r"), (-1, "l")):
			huefte = (seite * HUEFTE_B, HUEFTE_H - runter, 0)
			knie = (seite * (HUEFTE_B + 0.08), HUEFTE_H - runter + 0.20, 0.44)
			fuss = (seite * (HUEFTE_B + 0.12), 0.03, 0.86)
			p["huefte_" + name], p["knie_" + name], p["fuss_" + name] = huefte, knie, fuss
			schulter = (seite * SCHULTER_B, SCHULTER_H - runter + huepfen, 0.05)
			p["schulter_" + name] = schulter
			p["ellbogen_" + name] = (seite * (SCHULTER_B + 0.10), SCHULTER_H - runter + huepfen - 0.34, 0.18)
			p["hand_" + name] = (knie[0], knie[1] + 0.06, knie[2] + 0.02)
		p["_runter"] = runter
	runter = p.pop("_runter", 0.0)
	vor = 0.05 if pose == "sitzen" else 0.0
	p["becken"] = (0, HUEFTE_H - runter + (huepfen if pose == "laufen" else 0), 0)
	p["hals"] = (0, SCHULTER_H - runter + huepfen + 0.06, vor)
	p["kopf"] = (0, KOPF_H - runter + huepfen, vor + 0.03)
	return p


def bild(punkt, drehung, mitte_x, boden_y):
	"""Körper-Punkt auf das Blatt: Figur um die Hochachse drehen, dann von schräg oben ansehen."""
	x, y, z = punkt
	c, s = math.cos(drehung), math.sin(drehung)
	wx = x * c + z * s
	wz = -x * s + z * c          # wz > 0 heißt: näher am Betrachter
	sx = mitte_x + wx * MASS
	sy = boden_y - y * MASS * math.cos(NEIGUNG) + wz * MASS * math.sin(NEIGUNG)
	return (sx, sy), wz


def figur(zeichnung: ImageDraw.ImageDraw, pose: str, t: float, von_hinten: bool, mitte_x: float, boden_y: float):
	# Vorwärts zeigt nach links unten (von vorne) oder nach links oben (von hinten)
	drehung = math.radians(-135 if von_hinten else -45)
	p = skelett(pose, t)
	pkt = {name: bild(wert, drehung, mitte_x, boden_y) for name, wert in p.items()}
	teile = []
	for name, farbe_vorn, farbe_hinten in (("r", ROT, ROT_HINTEN), ("l", BLAU, BLAU_HINTEN)):
		tiefe = pkt["huefte_" + name][1]
		farbe = farbe_vorn if tiefe >= 0 else farbe_hinten
		teile.append((tiefe - 0.01, "linie", [pkt["huefte_" + name][0], pkt["knie_" + name][0], pkt["fuss_" + name][0]], farbe, 28))
		tiefe_arm = pkt["schulter_" + name][1]
		teile.append((tiefe_arm, "linie", [pkt["schulter_" + name][0], pkt["ellbogen_" + name][0], pkt["hand_" + name][0]], farbe, 22))
	rumpf = [pkt["schulter_r"][0], pkt["schulter_l"][0], pkt["huefte_l"][0], pkt["huefte_r"][0]]
	teile.append((0.0, "flaeche", rumpf, GRAU, 0))
	teile.sort(key=lambda teil: teil[0])
	for _, art, punkte, farbe, dicke in teile:
		if art == "linie":
			zeichnung.line(punkte, fill=farbe, width=dicke, joint="curve")
			for punkt in punkte:
				r = dicke / 2
				zeichnung.ellipse([punkt[0] - r, punkt[1] - r, punkt[0] + r, punkt[1] + r], fill=farbe)
			# Fuß bzw. Hand als dickerer Punkt
			ende = punkte[-1]
			r = dicke * 0.7
			zeichnung.ellipse([ende[0] - r, ende[1] - r, ende[0] + r, ende[1] + r], fill=farbe)
		else:
			zeichnung.polygon(punkte, fill=farbe)
			zeichnung.line(punkte + [punkte[0]], fill=farbe, width=26, joint="curve")
	# Kopf-Oval, etwas höher als breit, immer zuoberst
	(kx, ky), _ = pkt["kopf"]
	zeichnung.ellipse([kx - 44, ky - 52, kx + 44, ky + 52], fill=GRUEN)


def blatt() -> Image.Image:
	bild_ = Image.new("RGB", (BREIT, HOCH), PINK)
	zeichnung = ImageDraw.Draw(bild_)
	for reihe in range(REIHEN):
		boden_y = reihe * ZELLE_H + ZELLE_H - 40
		for spalte in range(SPALTEN):
			mitte_x = spalte * ZELLE_B + ZELLE_B / 2 + 10
			if reihe < 2:
				figur(zeichnung, "laufen", spalte / 8.0, reihe == 1, mitte_x, boden_y)
			else:
				pose = "stehen" if spalte < 4 else "sitzen"
				von_hinten = spalte in (2, 3, 6, 7)
				figur(zeichnung, pose, float(spalte % 2), von_hinten, mitte_x, boden_y - (45 if pose == "sitzen" else 0))
	return bild_


if __name__ == "__main__":
	ziel = sys.argv[1] if len(sys.argv) > 1 else "tools/referenz/teil_u/posen_vorlage_welt.png"
	blatt().save(ziel)
	print("gespeichert:", ziel)
