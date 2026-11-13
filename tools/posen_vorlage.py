"""Posen-Vorlagen für Welt-Blätter (Teil U in Spieldesign/GRAFIK_AUFTRAG.md).

Malt Blätter mit Gliederpuppen in den Posen und an den Plätzen, die ChatGPT übernehmen soll.
Aufbau wie bei den Spieler-Figuren in Ragnarok Online: fünf gemalte Richtungen (von vorne,
schräg von vorne, von der Seite, schräg von hinten, von hinten), die drei übrigen spiegelt das
Spiel. Gehen hat 8 Bilder je Richtung, Stehen und Sitzen je 1 Bild je Richtung.
Die Puppen sind selbst gerechnet, es werden keine fremden Bilder benutzt.

Drei Blätter je Geschlecht (alle 1536 x 1024, Hintergrund Pink), m = männlich, w = weiblich:
  posen_<m|w>_gehen_1.png   3 Reihen x 8: Gehen von vorne, schräg von vorne, von der Seite
  posen_<m|w>_gehen_2.png   2 Reihen x 8: Gehen schräg von hinten, von hinten
  posen_<m|w>_stehen_sitzen.png  2 Reihen x 5: Stehen und Sitzen in den fünf Richtungen
  posen_<m|w>_gehen_<richtung>.png  2 Reihen x 4: Gehen in einer Richtung, groß (seit 14.11.2026)

Farben der Puppe: Kopf grün (wie das Kopf-Oval), Rumpf grau, rechter Arm und rechtes Bein rot,
linker Arm und linkes Bein blau. Alle Figuren schauen nach LINKS (oder gerade zum Betrachter
bzw. von ihm weg).

Gehen, Bild für Bild (ein Doppelschritt):
  1 rechtes Bein setzt vorne auf   2 Gewicht geht aufs rechte Bein   3 linkes Bein schwingt durch
  4 linkes Bein kommt nach vorne   5 linkes Bein setzt vorne auf     6 Gewicht geht aufs linke Bein
  7 rechtes Bein schwingt durch    8 rechtes Bein kommt nach vorne

Weiblich (Marco, 13.11.2026: deutlich femininer): schmalere Schultern, Taille, breitere Hüfte,
schlankere Glieder, Füße enger beieinander, die Hüfte wiegt beim Gehen leicht mit, beim Sitzen
liegen die Beine seitlich angewinkelt.

Aufruf: python tools/posen_vorlage.py [Zielordner]
"""
import math
import sys
from PIL import Image, ImageDraw

BREIT, HOCH = 1536, 1024
NEIGUNG = math.radians(30)   # Blick von schräg oben
PINK = (255, 0, 255)
GRUEN = (0, 255, 0)
GRAU = (130, 130, 130)
RAND = (30, 24, 24)
ROT, ROT_FERN = (225, 45, 45), (150, 35, 35)
BLAU, BLAU_FERN = (50, 100, 235), (35, 65, 150)

# Richtungen: Drehung um die Hochachse. 0 = schaut zum Betrachter, -90 = schaut nach links.
RICHTUNGEN = {"vorne": 0, "schraeg_vorne": -45, "seite": -90, "schraeg_hinten": -135, "hinten": 180}

# Körpermaße (Chibi, rund 3 Kopflängen), in Einheiten
HUEFTE_H, SCHULTER_H, KOPF_H = 0.95, 1.80, 2.42
OBERSCHENKEL, UNTERSCHENKEL, FUSS = 0.46, 0.49, 0.26
OBERARM, UNTERARM = 0.40, 0.36
KOERPER = {
	"m": {"huefte": 0.24, "schulter": 0.46, "taille": 0.34, "bein": 30, "arm": 24, "spur": 1.0, "wiegen": 0.0},
	"w": {"huefte": 0.29, "schulter": 0.36, "taille": 0.20, "bein": 24, "arm": 18, "spur": 0.55, "wiegen": 0.05},
}


def glied(start, winkel_vor, laenge):
	"""Ende eines Gliedes, das von start nach unten hängt und um winkel_vor nach vorne schwingt."""
	x, y, z = start
	return (x, y - laenge * math.cos(winkel_vor), z + laenge * math.sin(winkel_vor))


def skelett(pose: str, bild_nr: int, geschlecht: str):
	"""Gelenke in Körper-Koordinaten: x = rechts der Figur, y = oben, z = vorne."""
	k = KOERPER[geschlecht]
	hb, sb, spur = k["huefte"], k["schulter"], k["spur"]
	p = {}
	runter = 0.0
	heben = 0.0
	seitlich = 0.0
	if pose == "gehen":
		phase = 2 * math.pi * bild_nr / 8.0
		heben = -0.03 * math.cos(2 * phase)      # am tiefsten beim Aufsetzen, am höchsten beim Durchschwingen
		seitlich = k["wiegen"] * math.sin(phase)  # Hüfte wiegt zum tragenden Bein
		for seite, vz, name in ((1, 1, "r"), (-1, -1, "l")):
			schwung = 0.48 * math.cos(phase) * vz          # Bild 1: rechtes Bein vorne
			knie = 0.95 * max(0.0, -math.sin(phase) * vz)  # das Bein, das nach vorne schwingt, ist gebeugt
			knie += 0.12 * max(0.0, math.sin(phase) * vz)  # das tragende Bein federt leicht
			huefte = (seite * hb + seitlich, HUEFTE_H + heben, 0)
			kn = glied(huefte, schwung + knie * 0.45, OBERSCHENKEL)
			f = glied(kn, schwung - knie * 0.75, UNTERSCHENKEL)
			# Füße setzen näher an der Mitte auf (bei der Frau fast auf einer Linie)
			kn = (seite * hb * (0.5 + 0.5 * spur) + seitlich, kn[1], kn[2])
			f = (seite * hb * spur, max(0.04, f[1]), f[2])
			p["huefte_" + name], p["knie_" + name], p["fuss_" + name] = huefte, kn, f
			p["zehe_" + name] = (f[0], max(0.02, f[1] - 0.03), f[2] + FUSS)
			arm = -0.42 * math.cos(phase) * vz
			schulter = (seite * sb, SCHULTER_H + heben, 0)
			e = glied(schulter, arm, OBERARM)
			h = glied(e, arm + 0.40, UNTERARM)
			p["schulter_" + name], p["ellbogen_" + name], p["hand_" + name] = schulter, e, h
	elif pose == "stehen":
		for seite, name in ((1, "r"), (-1, "l")):
			p["huefte_" + name] = (seite * hb, HUEFTE_H, 0)
			p["knie_" + name] = (seite * hb * (0.55 + 0.5 * spur), HUEFTE_H - OBERSCHENKEL, 0.02)
			p["fuss_" + name] = (seite * (hb * spur + 0.04), 0.04, 0)
			p["zehe_" + name] = (seite * (hb * spur + 0.09), 0.02, FUSS)
			p["schulter_" + name] = (seite * sb, SCHULTER_H, 0)
			p["ellbogen_" + name] = (seite * (sb + 0.07), SCHULTER_H - OBERARM, 0)
			p["hand_" + name] = (seite * (sb + 0.08), SCHULTER_H - OBERARM - UNTERARM, 0.08)
	elif geschlecht == "w":  # sitzen, weiblich: Beine seitlich angewinkelt, Hände im Schoß
		runter = HUEFTE_H - 0.15
		for seite, name in ((1, "r"), (-1, "l")):
			p["huefte_" + name] = (seite * hb, 0.15, 0)
			knie = (seite * 0.10 + 0.20, 0.22, 0.46)
			p["knie_" + name] = knie
			p["fuss_" + name] = (seite * 0.08 + 0.62, 0.05, 0.12)
			p["zehe_" + name] = (seite * 0.08 + 0.84, 0.05, 0.02)
			p["schulter_" + name] = (seite * sb, SCHULTER_H - runter, 0.04)
			p["ellbogen_" + name] = (seite * (sb + 0.08), SCHULTER_H - runter - 0.34, 0.14)
			p["hand_" + name] = (seite * 0.10, 0.34, 0.30)
	else:  # sitzen, männlich: Gesäß am Boden, Beine locker nach vorne, Knie leicht angezogen, Hände auf den Knien
		runter = HUEFTE_H - 0.15
		for seite, name in ((1, "r"), (-1, "l")):
			p["huefte_" + name] = (seite * hb, 0.15, 0)
			knie = (seite * (hb + 0.10), 0.36, 0.42)
			p["knie_" + name] = knie
			p["fuss_" + name] = (seite * (hb + 0.16), 0.05, 0.84)
			p["zehe_" + name] = (seite * (hb + 0.20), 0.20, 0.98)
			p["schulter_" + name] = (seite * sb, SCHULTER_H - runter, 0.06)
			p["ellbogen_" + name] = (seite * (sb + 0.10), SCHULTER_H - runter - 0.33, 0.20)
			p["hand_" + name] = (knie[0], knie[1] + 0.07, knie[2])
	vor = 0.06 if pose == "sitzen" else 0.0
	mitte_h = (HUEFTE_H + SCHULTER_H) / 2 - runter + heben
	p["taille_r"] = (k["taille"] + seitlich * 0.5, mitte_h, vor / 2)
	p["taille_l"] = (-k["taille"] + seitlich * 0.5, mitte_h, vor / 2)
	p["kopf"] = (0, KOPF_H - runter + heben, vor + 0.03)
	return p


def aufs_blatt(punkt, drehung, mitte_x, boden_y, mass):
	"""Körper-Punkt auf das Blatt: Figur um die Hochachse drehen, dann von schräg oben ansehen."""
	x, y, z = punkt
	x = -x   # Blick auf die Figur: ihre rechte Seite liegt von vorne gesehen links im Bild (bis 14.11. vertauscht)
	c, s = math.cos(drehung), math.sin(drehung)
	wx = x * c + z * s
	wz = -x * s + z * c          # wz > 0 heißt: näher am Betrachter
	sx = mitte_x + wx * mass
	sy = boden_y - y * mass * math.cos(NEIGUNG) + wz * mass * math.sin(NEIGUNG)
	return (sx, sy), wz


def kapsel(zeichnung, punkte, farbe, dicke):
	"""Dickes Glied mit dunklem Rand, damit sich übereinanderliegende Glieder abheben."""
	for breite, ton in ((dicke + 8, RAND), (dicke, farbe)):
		zeichnung.line(punkte, fill=ton, width=int(breite), joint="curve")
		r = breite / 2
		for px, py in punkte:
			zeichnung.ellipse([px - r, py - r, px + r, py + r], fill=ton)


def figur(zeichnung, pose: str, bild_nr: int, richtung: str, mitte_x: float, boden_y: float, mass: float, geschlecht: str):
	drehung = math.radians(RICHTUNGEN[richtung])
	k = KOERPER[geschlecht]
	p = skelett(pose, bild_nr, geschlecht)
	pkt = {name: aufs_blatt(wert, drehung, mitte_x, boden_y, mass) for name, wert in p.items()}
	d = mass / 100.0
	teile = []
	for name, nah, fern in (("r", ROT, ROT_FERN), ("l", BLAU, BLAU_FERN)):
		tiefe_bein = (pkt["huefte_" + name][1] + pkt["fuss_" + name][1]) / 2
		tiefe_arm = (pkt["schulter_" + name][1] + pkt["hand_" + name][1]) / 2
		farbe = nah if pkt["huefte_" + name][1] >= -0.01 else fern
		bein = [pkt["huefte_" + name][0], pkt["knie_" + name][0], pkt["fuss_" + name][0]]
		fuss = [pkt["fuss_" + name][0], pkt["zehe_" + name][0]]
		arm = [pkt["schulter_" + name][0], pkt["ellbogen_" + name][0], pkt["hand_" + name][0]]
		teile.append((tiefe_bein - 0.02, bein, farbe, k["bein"] * d))
		teile.append((tiefe_bein - 0.01, fuss, farbe, (k["bein"] + 4) * d))
		teile.append((tiefe_arm + (0.05 if tiefe_arm >= 0 else -0.05), arm, farbe, k["arm"] * d))
	rumpf = [pkt[n][0] for n in ("schulter_r", "taille_r", "huefte_r", "huefte_l", "taille_l", "schulter_l")]
	teile.append((0.0, rumpf, GRAU, 0))
	teile.sort(key=lambda teil: teil[0])
	rand_rumpf = 36 if geschlecht == "m" else 26
	for _, punkte, farbe, dicke in teile:
		if dicke:
			kapsel(zeichnung, punkte, farbe, dicke)
		else:
			geschlossen = punkte + [punkte[0]]
			zeichnung.line(geschlossen, fill=RAND, width=int((rand_rumpf + 8) * d), joint="curve")
			zeichnung.polygon(punkte, fill=GRAU)
			zeichnung.line(geschlossen, fill=GRAU, width=int(rand_rumpf * d), joint="curve")
	# Kopf-Oval, etwas höher als breit, immer zuoberst
	(kx, ky), _ = pkt["kopf"]
	zeichnung.ellipse([kx - 46 * d, ky - 54 * d, kx + 46 * d, ky + 54 * d], fill=GRUEN)


def blatt(reihen: list, spalten: int, mass: float, geschlecht: str, boden_anteil: float = 0.16) -> Image.Image:
	"""reihen: je Reihe eine Liste von (pose, bild_nr, richtung)."""
	bild = Image.new("RGB", (BREIT, HOCH), PINK)
	zeichnung = ImageDraw.Draw(bild)
	zelle_b, zelle_h = BREIT / spalten, HOCH / len(reihen)
	for r, reihe in enumerate(reihen):
		for s, (pose, bild_nr, richtung) in enumerate(reihe):
			boden_y = r * zelle_h + zelle_h - boden_anteil * zelle_h - (0.10 * zelle_h if pose == "sitzen" else 0)
			# Sitzende, die nach links schauen, etwas nach rechts rücken (die Beine ragen nach links)
			versatz = 0.08 * zelle_b if pose == "sitzen" and richtung in ("schraeg_vorne", "seite", "schraeg_hinten") else 0
			figur(zeichnung, pose, bild_nr, richtung, s * zelle_b + zelle_b / 2 + versatz, boden_y, mass, geschlecht)
	return bild


def gehen(richtung: str) -> list:
	return [("gehen", nr, richtung) for nr in range(8)]


if __name__ == "__main__":
	ordner = sys.argv[1] if len(sys.argv) > 1 else "tools/referenz/teil_u"
	for g in ("m", "w"):
		blaetter = {
			f"posen_{g}_gehen_1.png": blatt([gehen("vorne"), gehen("schraeg_vorne"), gehen("seite")], 8, 96, g),
			f"posen_{g}_gehen_2.png": blatt([gehen("schraeg_hinten"), gehen("hinten")], 8, 118, g),
			f"posen_{g}_stehen_sitzen.png": blatt([[("stehen", 0, r) for r in RICHTUNGEN], [("sitzen", 0, r) for r in RICHTUNGEN]], 5, 150, g),
		}
		# Seit 14.11.: ein Blatt je Richtung, 2 Reihen x 4 (Bild 1-4 oben, 5-8 unten), große Puppen,
		# damit ChatGPT die Beinstellung genauer trifft.
		for r in RICHTUNGEN:
			bilder = gehen(r)
			blaetter[f"posen_{g}_gehen_{r}.png"] = blatt([bilder[:4], bilder[4:]], 4, 125, g, 0.12)
		for name, bild in blaetter.items():
			bild.save(f"{ordner}/{name}")
			print("gespeichert:", f"{ordner}/{name}")
