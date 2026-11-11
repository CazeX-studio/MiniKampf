"""Kreuzwegfelder (A14): die Wiesen vor der Stadt, eigenes Gebiet zwischen Kreuzweg und der Aschensteppe.

design.md: Durch das Südtor geht es auf die Kreuzwegfelder und weiter in die Aschensteppe; vom Trainingsplatz der Gilde
führt ein Seitentor auf die Felder. MONSTER.md: Stufe 1–8, Tauschleim, Wiesenhoppler, Knollenkäfer, Löwenzahnling,
nachts Funkenflirr und Glutigel, selten der Kronenschleim. Nahe der Stadt die schwachen, weiter südlich die stärkeren.
Oben in der Mitte kommt man durch das Südtor herein, oben links durch das Seitentor; unten geht es in die Aschensteppe
(erst nach der Klassenwahl, wie bisher das Südtor). Ein Bach mit Steg, Heuballen, Zäune und ein Wegweiser.
Das Werkzeug schreibt Raster, Ausgänge und Monster nach data/karten.json und die Teile nach data/karte_kreuzwegfelder.json;
es prüft wie tools/gruenwacht_karten.py, dass alles erreichbar bleibt.
Aufruf: python3 tools/kreuzwegfelder_karte.py
"""
import json
import random
import sys
from pathlib import Path

WURZEL = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(WURZEL / "tools"))
import gruenwacht_karten as gk  # noqa: E402

B, H = 40, 36
## Eingänge oben: vom Südtor (Mitte) und vom Seitentor (links); unten der Weg in die Aschensteppe
SUEDTOR_X = 20
SEITENTOR_X = 4
STEPPE_X = 20
## Der Bach fließt quer über die Felder, über ihn führt der Steg
BACH_Y = 21


def monster():
	M = lambda feld, gegner, stufe, **kw: dict({"feld": feld, "gegner": gegner, "stufe": stufe, "hintergrund": "kreuzwegfelder"}, **kw)
	return [
		# Nahe der Stadt: Tauschleime und Wiesenhoppler
		M([10, 7], ["tauschleim"], 1), M([30, 6], ["tauschleim", "tauschleim"], 2), M([14, 13], ["wiesenhoppler"], 3),
		M([31, 14], ["wiesenhoppler", "tauschleim"], 4),
		# Hinter dem Bach: Knollenkäfer und Löwenzahnlinge
		M([8, 27], ["knollenkaefer"], 5), M([32, 26], ["loewenzahnling", "knollenkaefer"], 6), M([13, 31], ["knollenkaefer", "wiesenhoppler"], 6),
		M([28, 31], ["loewenzahnling", "knollenkaefer", "tauschleim"], 7),
		# Nachts: Funkenflirr und Glutigel
		M([30, 6], ["funkenflirr"], 4, zeit="nacht"), M([14, 13], ["funkenflirr", "funkenflirr"], 5, zeit="nacht"),
		M([32, 26], ["glutigel"], 6, zeit="nacht"), M([28, 31], ["glutigel", "funkenflirr"], 7, zeit="nacht"),
		# Selten: der Kronenschleim, König der Schleime, ganz hinten auf der Wiese
		M([36, 33], ["kronenschleim"], 8),
	]


def raster_bauen(r):
	g = [["."] * B for _ in range(H)]
	for y in range(H):
		for x in range(B):
			rand = x in (0, B - 1) or y in (0, H - 1) or ((x in (1, B - 2) or y in (1, H - 2)) and r.random() < 0.5)
			if rand or r.random() < 0.03:
				g[y][x] = "T"
	# Feldwege: vom Südtor nach unten in die Steppe, vom Seitentor quer herüber
	for y in range(H):
		for dx in (0, 1):
			g[y][SUEDTOR_X + dx] = "="
	for y in range(0, 9):
		for dx in (0, 1):
			g[y][SEITENTOR_X + dx] = "="
	for x in range(SEITENTOR_X, SUEDTOR_X + 2):
		for dy in (0, 1):
			g[8 + dy][x] = "="
	# Der Bach (nur über den Steg zu überqueren)
	for x in range(B):
		if g[BACH_Y][x] != "=":
			g[BACH_Y][x] = "~"
	# Plätze der Monster frei lassen
	for m in monster():
		mx, my = m["feld"]
		for dx in (-1, 0, 1):
			for dy in (-1, 0, 1):
				if g[my + dy][mx + dx] == "T":
					g[my + dy][mx + dx] = "."
	# Oben und unten die Eingänge offen
	for x, y in [(SUEDTOR_X, 0), (SUEDTOR_X + 1, 0), (SEITENTOR_X, 0), (SEITENTOR_X + 1, 0), (STEPPE_X, H - 1), (STEPPE_X + 1, H - 1)]:
		g[y][x] = "="
	return g


def kreuzwegfelder():
	r = random.Random(14)
	g = raster_bauen(r)
	karten = json.loads((gk.DATEN / "karten.json").read_text(encoding="utf-8"))
	# Im Raster gesperrt: Bäume ("T") und der Bach ("s")
	raster = ["".join("s" if z == "~" else z for z in zeile) for zeile in g]
	karten["kreuzwegfelder"] = {
		"name": "Kreuzwegfelder", "musik": "wald", "grund": "wiese", "licht": "fff8e8", "start": [SUEDTOR_X, 2],
		"raster": raster,
		"ausgaenge": [
			{"bereich": [SUEDTOR_X, 0, 2, 1], "karte": "kreuzweg", "feld": [31, 63]},
			{"bereich": [SEITENTOR_X, 0, 2, 1], "karte": "kreuzweg", "feld": [2, 45]},
			{"bereich": [STEPPE_X, H - 1, 2, 1], "karte": "aschensteppe", "feld": [14, 1], "wenn": {"gemerkt": "klasse_bestaetigt"}},
		],
		"kampf_hintergrund": "kreuzwegfelder", "monster": monster(), "baukasten": "karte_kreuzwegfelder",
	}
	(gk.DATEN / "karten.json").write_text(json.dumps(karten, ensure_ascii=False, indent="\t") + "\n", encoding="utf-8")
	gk.KARTEN.clear()
	gk.KARTEN.update(karten)
	k = gk.Karte("kreuzwegfelder")
	# Boden: Gras, Blumenwiese in Flecken, Feldwege aus Erde, der Bach
	boden = []
	for y in range(H):
		zeile = ""
		for x in range(B):
			z = g[y][x]
			if z == "=":
				zeile += "e"
			elif z == "~":
				zeile += "~"
			else:
				fleck = ((x // 3) * 37 + (y // 3) * 61 + (x // 3) * (y // 3) * 13) % 100
				zeile += ":" if fleck < 22 else "."
		boden.append(zeile)
	# Steg über den Bach, Wegweiser an der Kreuzung, Heuballen und Zäune an den Feldern
	k.setzen("steg", SUEDTOR_X, BACH_Y - 1, muss=False)
	k.setzen("wegweiser", SUEDTOR_X + 2, 10, "Kreuzweg · Aschensteppe", muss=False)
	for x, y in [(26, 11), (27, 11), (11, 17), (34, 29), (6, 33)]:
		k.setzen("heuballen", x, y, muss=False)
	for x, y in [(24, 3), (24, 5), (16, 15), (16, 17), (25, 24), (25, 26)]:
		k.setzen("zaun", x, y, muss=False)
	for y in range(H):
		for x in range(B):
			z = g[y][x]
			if z == "T":
				k.setzen(r.choice(["baum", "baum", "busch", "busch_bluete", "tanne"]), x, y, muss=False)
			elif z == "." and r.random() < 0.035:
				k.setzen(r.choice(["blumen", "grasbueschel"]), x, y, muss=False)
	k.erreichbar()
	k.speichern(boden)


if __name__ == "__main__":
	kreuzwegfelder()
