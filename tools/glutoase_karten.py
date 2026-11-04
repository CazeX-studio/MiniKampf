"""Karten der Glutoase aus dem Baukasten (D23): die Aschensteppe (Straße von Kreuzweg nach Süden) und die Palmenrast.

Grasland, das nach Süden zur Wüste wird (MONSTER.md, design.md „Glutoase im Detail“). In der Mitte der Rastplatz der
Karawanen mit Lagerfeuer, Zelt, Wagen und der ersten Wegelaterne der Straße: Dort greifen keine Monster an
(„sicher“ in data/karten.json). Das Werkzeug schreibt Raster, Orte und Monster nach data/karten.json und die Teile nach
data/karte_aschensteppe.json; es prüft wie tools/gruenwacht_karten.py, dass alles erreichbar bleibt.
Palmenrast (D23b): Wüste mit Palmen, Dünen und Wasserstellen, Heimat-Gebiet der Glutoase (Stufe 12–19), mit Xavinas
Sternendüne. Bis die Stadt steht (D24), führt die Aschensteppe direkt hinein.
Aufruf: python3 tools/glutoase_karten.py [karte …]   (ohne Angabe alle)
"""
import json
import random
import sys
from pathlib import Path

WURZEL = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(WURZEL / "tools"))
import gruenwacht_karten as gk  # noqa: E402

B, H = 28, 60
## Rastplatz der Karawanen (x, y, Breite, Höhe): dort greifen keine Monster an
RASTPLATZ = [6, 26, 17, 10]


def raster_bauen(r):
	g = [["."] * B for _ in range(H)]
	for y in range(H):
		for x in range(B):
			rand = x in (0, B - 1) or ((x in (1, B - 2)) and r.random() < 0.5)
			if rand or r.random() < 0.035:
				g[y][x] = "s" if r.random() < 0.6 else "T"
	# Karawanenweg von Norden nach Süden, leicht geschwungen
	x = 14
	for y in range(H):
		for dx in (0, 1):
			g[y][x + dx] = "="
		if y % 6 == 5:
			x = max(10, min(16, x + r.choice([-1, 1])))
	# Der Rastplatz bleibt frei (Teile stellt das Werkzeug selbst hin)
	rx, ry, rb, rh = RASTPLATZ
	for y in range(ry, ry + rh):
		for x2 in range(rx, rx + rb):
			if g[y][x2] in "sT":
				g[y][x2] = "."
	return g


def monster():
	M = lambda feld, gegner, stufe, **kw: dict({"feld": feld, "gegner": gegner, "stufe": stufe}, **kw)
	return [
		M([6, 8], ["steppenroller"], 9), M([21, 10], ["steppenhyaene"], 10), M([8, 17], ["kaktusling", "steppenroller"], 10),
		M([20, 19], ["funkenechse"], 11), M([7, 43], ["steppenhyaene", "funkenechse"], 11), M([21, 45], ["kaktusling", "steppenhyaene"], 12),
		M([9, 52], ["funkenechse", "steppenroller", "kaktusling"], 12), M([22, 54], ["sonnenloewe"], 12),
		M([21, 10], ["aschefuchs"], 10, zeit="nacht"), M([8, 17], ["schattenskarabaeus"], 10, zeit="nacht"),
		M([7, 43], ["aschefuchs", "schattenskarabaeus"], 11, zeit="nacht"), M([21, 45], ["aschefuchs", "aschefuchs"], 12, zeit="nacht"),
	]


def aschensteppe():
	r = random.Random(31)
	g = raster_bauen(r)
	for m in monster():
		x, y = m["feld"]
		for dx in (-1, 0, 1):
			for dy in (-1, 0, 1):
				if g[y + dy][x + dx] in "sT":
					g[y + dy][x + dx] = "."
	karten = json.loads((gk.DATEN / "karten.json").read_text(encoding="utf-8"))
	karten["aschensteppe"] = {
		"name": "Aschensteppe", "musik": "wald", "grund": "wiese", "licht": "fff0d8", "start": [14, 1],
		"raster": ["".join(z) for z in g],
		"ausgaenge": [{"bereich": [12, 0, 6, 1], "karte": "kreuzweg", "feld": [31, 63]},
			{"bereich": [11, H - 1, 7, 1], "karte": "palmenrast", "feld": [20, 1]}],
		"kampf_hintergrund": "wiese", "sicher": RASTPLATZ,
		"orte": [{"art": "wegelaterne", "feld": [11, 28], "dialog": "wegelaterne_aschensteppe", "zeichen": "laterne"}],
		"monster": monster(), "baukasten": "karte_aschensteppe",
	}
	(gk.DATEN / "karten.json").write_text(json.dumps(karten, ensure_ascii=False, indent="\t") + "\n", encoding="utf-8")
	gk.KARTEN.clear()
	gk.KARTEN.update(karten)
	k = gk.Karte("aschensteppe")
	# Boden: oben Gras, nach Süden immer mehr Sand, der Weg aus Erde
	boden = []
	for y in range(H):
		zeile = ""
		for x in range(B):
			if g[y][x] == "=":
				zeile += "e"
			else:
				# Flecken aus 3x3 Feldern statt einzelner Felder, damit der Übergang nicht wie ein Schachbrett aussieht
				fleck = ((x // 3) * 37 + (y // 3) * 61 + (x // 3) * (y // 3) * 13) % 100 / 100.0
				sand = (y - 18) / 22.0 + (fleck - 0.5) * 0.6
				zeile += "s" if sand > 0.5 else "."
		boden.append(zeile)
	# Rastplatz der Karawanen
	k.setzen("go_tor_steppe", 11, 0, muss=False)
	k.setzen("lagerfeuer", 14, 30, muss=False)
	k.setzen("zelt", 17, 26, muss=False)
	k.setzen("go_sonnensegel", 7, 27, muss=False)
	k.setzen("holzbank", 8, 31, muss=False)
	k.setzen("go_verlassener_wagen", 18, 33, muss=False)
	k.setzen("wegelaterne", 11, 28, "Rastplatz der Karawanen", muss=False)
	k.setzen("go_tonkruege", 20, 30, muss=False)
	k.setzen("go_tonkruege", 7, 34, muss=False)
	k.setzen("go_karawanenspur", 9, 24, muss=False)
	# Landschaft: im Norden Steppengras und Felsen, im Süden Dünen, Kakteen und eine Ruine
	for teil, x, y in [("go_ruine", 3, 47), ("go_duene", 20, 50), ("go_duene", 2, 56), ("go_duenenkamm", 19, 40),
			("go_wasserstelle", 2, 20), ("go_felsbrocken", 23, 22), ("go_felsbrocken", 4, 38)]:
		k.setzen(teil, x, y, muss=False)
	for y in range(H):
		for x in range(B):
			z = g[y][x]
			if z == "s":
				k.setzen("go_felsbrocken" if r.random() < 0.3 else "go_trockenbusch", x, y, muss=False)
			elif z == "T":
				k.setzen("go_kakteen" if y > 30 else "go_trockenbusch", x, y, muss=False)
			elif z == "." and r.random() < 0.05:
				k.setzen("go_steppengras" if y < 30 else "go_gras_zu_sand", x, y, muss=False)
	k.erreichbar()
	k.speichern(boden)


PB, PH = 40, 34


def palmenrast_monster():
	M = lambda feld, gegner, stufe, **kw: dict({"feld": feld, "gegner": gegner, "stufe": stufe}, **kw)
	return [
		M([8, 8], ["feuerechse"], 12), M([30, 7], ["oasenkroete", "feuerechse"], 13), M([10, 18], ["glasskorpion"], 14),
		M([32, 18], ["sandwurm"], 15), M([20, 25], ["glasskorpion", "feuerechse"], 16), M([8, 28], ["sandwurm", "oasenkroete"], 17),
		M([12, 24], ["sandwurm", "glasskorpion"], 18), M([36, 12], ["stachelflitzer"], 18),
		M([30, 7], ["staubgeist"], 15, zeit="nacht"), M([10, 18], ["mondschakal"], 16, zeit="nacht"),
		M([32, 18], ["staubgeist", "mondschakal"], 17, zeit="nacht"), M([20, 25], ["mondschakal"], 18, zeit="nacht"),
		M([8, 28], ["staubgeist", "staubgeist"], 19, zeit="nacht"),
	]


def palmenrast():
	r = random.Random(32)
	g = [["."] * PB for _ in range(PH)]
	for y in range(PH):
		for x in range(PB):
			if x in (0, PB - 1) or y == PH - 1 or ((x in (1, PB - 2) or y == PH - 2) and r.random() < 0.5) or r.random() < 0.03:
				g[y][x] = "s" if r.random() < 0.5 else "T"
	for x in range(17, 24):
		g[0][x] = "."
	# Oasenteich in der Mitte (nicht begehbar), drumherum Oasengras
	teich = {(x, y) for y in range(13, 19) for x in range(17, 25) if ((x - 20.5) / 4.2) ** 2 + ((y - 15.5) / 3.2) ** 2 < 1}
	for x, y in teich:
		g[y][x] = "~"
	# Karawanenspur vom Norden um den Teich herum nach Süden
	for y in range(0, PH - 2):
		x = 20 if y < 10 or y > 21 else (14 if y < 16 else 14)
		g[y][x] = "="
	for x in range(14, 21):
		g[10][x] = "="
		g[21][x] = "="
	for y in range(10, 22):
		g[y][14] = "="
	for m in palmenrast_monster():
		x, y = m["feld"]
		for dx in (-1, 0, 1):
			for dy in (-1, 0, 1):
				if g[y + dy][x + dx] in "sT":
					g[y + dy][x + dx] = "."
	karten = json.loads((gk.DATEN / "karten.json").read_text(encoding="utf-8"))
	karten["palmenrast"] = {
		"name": "Palmenrast", "musik": "wald", "grund": "wiese", "licht": "fff4e0", "start": [20, 1],
		"raster": ["".join(z) for z in g],
		"ausgaenge": [{"bereich": [17, 0, 7, 1], "karte": "aschensteppe", "feld": [14, H - 2]}],
		"kampf_hintergrund": "wiese", "monster": palmenrast_monster(), "baukasten": "karte_palmenrast",
	}
	(gk.DATEN / "karten.json").write_text(json.dumps(karten, ensure_ascii=False, indent="\t") + "\n", encoding="utf-8")
	gk.KARTEN.clear()
	gk.KARTEN.update(karten)
	k = gk.Karte("palmenrast")
	boden = []
	for y in range(PH):
		zeile = ""
		for x in range(PB):
			if (x, y) in teich:
				zeile += "t"
			elif g[y][x] == "=":
				zeile += "e"
			elif min(abs(x - 20.5) / 6.5, 1) ** 2 + min(abs(y - 15.5) / 5.0, 1) ** 2 < 1:
				zeile += "g"
			else:
				zeile += "s"
		boden.append(zeile)
	# Palmen rund um den Teich, Wasserstellen, Dünen, Xavinas Sternendüne im Südosten
	for x, y in [(15, 12), (25, 13), (16, 19), (25, 18), (22, 12), (18, 20)]:
		k.setzen("go_palme_gross", x, y, muss=False)
	for x, y in [(13, 14), (26, 16), (19, 11), (23, 20), (12, 18), (27, 14)]:
		k.setzen("go_palme_klein", x, y, muss=False)
	k.setzen("go_sternenduene", 28, 23, "Sternendüne", muss=False)
	for teil, x, y in [("go_wasserstelle", 3, 3), ("go_wasserstelle", 33, 2), ("go_duene", 3, 12), ("go_duene", 34, 23), ("go_duene", 12, 30),
			("go_duenenkamm", 24, 31), ("go_ruine", 3, 21), ("go_felsbrocken", 26, 4), ("go_felsbrocken", 14, 26), ("go_sonnensegel", 22, 2)]:
		k.setzen(teil, x, y, muss=False)
	for y in range(PH):
		for x in range(PB):
			z = g[y][x]
			if z == "s":
				k.setzen("go_felsbrocken" if r.random() < 0.3 else "go_kakteen", x, y, muss=False)
			elif z == "T":
				k.setzen(r.choice(["go_palme_klein", "go_trockenbusch", "go_kakteen"]), x, y, muss=False)
			elif z == "." and r.random() < 0.03:
				k.setzen("go_gras_zu_sand", x, y, muss=False)
	k.erreichbar()
	k.speichern(boden)


if __name__ == "__main__":
	alle = {"aschensteppe": aschensteppe, "palmenrast": palmenrast}
	for name in sys.argv[1:] or list(alle):
		alle[name]()
