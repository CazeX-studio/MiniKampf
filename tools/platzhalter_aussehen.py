"""Platzhalter für die Aussehen-Schichten (Projekt 13, Schritt 4): Wanderhut und Reiseumhang.

Einfach gezeichnete Bilder, bis Marcos Blätter „Probe-Hut“ und „Probe-Umhang“ (GRAFIK_AUFTRAG.md Teil D) da sind.
Je Richtung (seite, vorn, hinten) ein Bild. Die Ankerpunkte stehen in data/aussehen_teile.json.
Aufruf: python3 tools/platzhalter_aussehen.py
"""
from PIL import Image, ImageDraw

UMRISS = (43, 28, 20, 255)
# Leder-Braun in vier Stufen (hell, mittel, dunkel, Schatten), Licht von links oben
HUT = [(168, 118, 74, 255), (133, 88, 52, 255), (100, 64, 38, 255), (72, 45, 28, 255)]
BAND = (92, 40, 36, 255)
# Umhang in Dunkelrot (Kreuzweg-Banner)
UMHANG = [(160, 62, 52, 255), (128, 44, 40, 255), (96, 32, 32, 255), (68, 22, 24, 255)]


def _umriss(bild: Image.Image) -> Image.Image:
	"""Einen Pixel breiten dunklen Umriss um alles Sichtbare legen."""
	w, h = bild.size
	aus = Image.new("RGBA", (w, h))
	px = bild.load()
	ax = aus.load()
	for y in range(h):
		for x in range(w):
			if px[x, y][3] > 0:
				continue
			for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
				nx, ny = x + dx, y + dy
				if 0 <= nx < w and 0 <= ny < h and px[nx, ny][3] > 0:
					ax[x, y] = UMRISS
					break
	aus.alpha_composite(bild)
	return aus


def hut(richtung: str) -> Image.Image:
	w, h = 92, 44
	b = Image.new("RGBA", (w, h))
	d = ImageDraw.Draw(b)
	# Krone: seitlich etwas nach hinten (links) versetzt, von vorne/hinten mittig
	versatz = -4 if richtung == "seite" else 0
	cx = w // 2 + versatz
	d.rounded_rectangle((cx - 22, 3, cx + 22, 32), radius=10, fill=HUT[1])
	d.rounded_rectangle((cx - 22, 3, cx - 8, 30), radius=8, fill=HUT[0])
	d.rectangle((cx + 12, 8, cx + 22, 32), fill=HUT[2])
	d.line((cx - 12, 6, cx - 12, 20), fill=HUT[2])  # Delle oben
	# Hutband
	d.rectangle((cx - 22, 24, cx + 22, 30), fill=BAND)
	# Krempe: flache Ellipse
	d.ellipse((2, 27, w - 3, 41), fill=HUT[2])
	d.ellipse((2, 27, w - 3, 37), fill=HUT[1])
	d.ellipse((6, 28, w // 2, 34), fill=HUT[0])
	if richtung == "hinten":
		d.rectangle((cx - 22, 24, cx + 22, 30), fill=HUT[2])  # Band verdeckt von hinten dunkler
		d.line((cx - 20, 27, cx + 20, 27), fill=BAND)
	return _umriss(b)


def umhang(richtung: str) -> Image.Image:
	w, h = 70, 78
	b = Image.new("RGBA", (w, h))
	d = ImageDraw.Draw(b)
	if richtung == "hinten":
		# ganzer Umhang von hinten: oben schmal an den Schultern, unten weiter
		d.polygon([(18, 1), (52, 1), (64, 74), (6, 74)], fill=UMHANG[1])
		d.polygon([(18, 1), (30, 1), (22, 74), (6, 74)], fill=UMHANG[0])
		d.polygon([(44, 1), (52, 1), (64, 74), (50, 74)], fill=UMHANG[2])
		for x in (24, 36, 46):
			d.line((x, 18, x + (x - 35) // 4, 72), fill=UMHANG[2])
		d.rectangle((18, 1, 52, 4), fill=UMHANG[3])
	else:
		# seitlich und schräg von vorne: hängt hinter dem Rücken (links) herab und weht etwas nach hinten
		breit = 1.0 if richtung == "seite" else 0.8
		x0 = int(w - 8)
		d.polygon([(x0, 1), (x0 - 20, 1), (int(x0 - 58 * breit), 74), (x0 - 4, 74)], fill=UMHANG[1])
		d.polygon([(x0 - 20, 1), (x0 - 12, 1), (int(x0 - 40 * breit), 74), (int(x0 - 58 * breit), 74)], fill=UMHANG[0])
		d.polygon([(x0 - 4, 1), (x0, 1), (x0 - 2, 74), (x0 - 10, 74)], fill=UMHANG[2])
		d.line((x0 - 14, 20, int(x0 - 30 * breit), 72), fill=UMHANG[2])
		d.rectangle((x0 - 20, 1, x0, 4), fill=UMHANG[3])
	return _umriss(b)


if __name__ == "__main__":
	for r in ("seite", "vorn", "hinten"):
		hut(r).save(f"assets/teile/hut/wanderhut_{r}.png")
		umhang(r).save(f"assets/teile/ruecken/reiseumhang_{r}.png")
	print("Platzhalter für Wanderhut und Reiseumhang gespeichert.")
