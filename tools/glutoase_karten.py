"""Karten der Glutoase aus dem Baukasten (D23): die Aschensteppe (Straße von Kreuzweg nach Süden) und die Palmenrast.

Grasland, das nach Süden zur Wüste wird (MONSTER.md, design.md „Glutoase im Detail“). In der Mitte der Rastplatz der
Karawanen mit Lagerfeuer, Zelt, Wagen und der ersten Wegelaterne der Straße: Dort greifen keine Monster an
(„sicher“ in data/karten.json). Das Werkzeug schreibt Raster, Orte und Monster nach data/karten.json und die Teile nach
data/karte_aschensteppe.json; es prüft wie tools/gruenwacht_karten.py, dass alles erreichbar bleibt.
Palmenrast (D23b): Wüste mit Palmen, Dünen und Wasserstellen, Heimat-Gebiet der Glutoase (Stufe 12–19), mit Xavinas
Sternendüne; man erreicht sie durch das Osttor der Stadt.
Glutoase (D24): die Terrassenstadt. Die Aschensteppe endet an ihrem Nordtor.
Glutgrat (D30): Wildes Land der Glutoase (Stufe 15–20) über dem Bergpfad am Schmiedeviertel: erkaltete Lava, Lavarinnen,
Felsgrate, heiße Quellen, Obsidian und oben der Kraterrand.
Vulkanschmiede der Ketten (D32): Dungeon hinter Hadraks Schmiede (Stufe 15–20) mit drei Abschnitten: Schmiedehallen,
Kettengänge (Brücken über dem Abgrund) und Ankerkammer.
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
			{"bereich": [11, H - 1, 7, 1], "karte": "glutoase", "feld": [23, 1]}],
		"kampf_hintergrund": "wiese", "sicher": RASTPLATZ,
		"orte": [{"art": "wegelaterne", "feld": [11, 28], "dialog": "wegelaterne_aschensteppe", "zeichen": "laterne"}],
		# Rastplatz-Händler (D27, NPC.md „Überall gleich“): an jedem Rastplatz dieselbe Figur
		"npcs": {"rastplatz_haendler": {"name": "Rastplatz-Händler", "feld": [19, 29], "aussehen": "grund_haendler+v_m2#hut=filzhut",
			"dialog": "rastplatz_haendler", "zeichen": "muenze"}},
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
GB, GH = 46, 46


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
		"ausgaenge": [{"bereich": [17, 0, 7, 1], "karte": "glutoase", "feld": [GB - 3, 11]}],
		"kampf_hintergrund": "wiese", "monster": palmenrast_monster(), "baukasten": "karte_palmenrast",
		"npcs": {"xavina": {"name": "Hohe Sängerin Xavina", "feld": [30, 28], "aussehen": "xavina", "dialog": "xavina"}},
		# Kochende Brunnen (D28): zwei Wasserstellen, an denen man das Wasser prüft
		"orte": [{"art": "wasserstelle", "feld": [5, 7], "dialog": "wasserstelle_nordwest"},
			{"art": "wasserstelle", "feld": [34, 6], "dialog": "wasserstelle_nordost"}],
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


## Die drei Stufen der Terrassenstadt (Zeilen): unten die Oase, in der Mitte das Schmiedeviertel, oben Hadraks Schmiede
OASE, SCHMIEDEVIERTEL, HADRAK = (0, 17), (20, 33), (36, 45)
## Terrassenkanten (Mauern zwischen den Stufen) mit einer Treppe in der Mitte
KANTEN = [18, 34]
TREPPE_X = 22
## Gebäude und Plätze der Stadt: (Teil, x, y, Name). Ihre Fläche ist gesperrt (außer flachen Teilen wie dem Tanzplatz).
GEBAEUDE = [
	# Unten: die Oase
	("go_karawanenplatz", 4, 3, "Karawanenplatz"), ("go_brunnen", 21, 8, "Großer Brunnen"), ("go_tanzplatz", 30, 9, "Tanzplatz"),
	("go_basar_a", 7, 9, "Basar"), ("go_basar_b", 11, 9, ""), ("go_tareks_laden", 5, 13, "Tareks Laden"), ("go_bank", 37, 2, "Bank"),
	("go_gasthaus", 28, 1, "Gasthaus Glutstube"), ("go_krankenzelt", 38, 10, "Krankenzelt"), ("lagerfeuer", 26, 7, ""),
	("go_aufzug_unten", 40, 14, "Lastenaufzug"), ("go_tor_duerrewald", 0, 16, "Tor zum Dürrewald"), ("go_sonnensegel", 15, 3, ""),
	# Mitte: das Schmiedeviertel
	("go_clan_werkstatt", 3, 21, "Werkstatt der Schmiedeclans"), ("go_clan_werkstatt", 10, 21, ""), ("go_brakkus_werkstatt", 30, 21, "Brakkus' Werkstatt"),
	("go_schmiede_offen", 6, 29, "Schmiede-Werkstatt"), ("go_esse", 19, 24, ""), ("go_esse", 25, 29, ""), ("go_lehmhaus_gross", 36, 27, ""),
	("go_lehmhaus_klein", 14, 29, ""), ("go_wassertrog", 23, 25, ""), ("go_werkzeugwand", 17, 22, ""), ("go_bergpfad", 43, 24, "Bergpfad zum Glutgrat"),
	# Oben: Hadraks Schmiede
	("go_hadraks_schmiede", 19, 37, "Hadraks Schmiede"), ("go_kettenamboss", 29, 40, ""), ("go_aufzug_oben", 40, 36, "Lastenaufzug"),
	("go_kraterrand", 8, 43, ""), ("go_kraterrand", 32, 43, ""), ("go_lavarinne", 12, 39, ""), ("go_lavarinne", 33, 38, ""),
]


def glutoase_orte():
	return [
		{"art": "wegelaterne", "feld": [19, 4], "dialog": "wegelaterne_glutoase", "zeichen": "laterne"},
		# Lastenaufzug der Schmiede: Abkürzung zwischen der Oase und Hadraks Schmiede
		{"art": "aufzug", "feld": [41, 17], "meldung": "Der Lastenaufzug rattert nach oben zu Hadraks Schmiede.", "aktionen": [{"reisen": "glutoase", "feld": [41, 40]}]},
		{"art": "aufzug", "feld": [41, 39], "meldung": "Der Lastenaufzug rattert hinunter zur Oase.", "aktionen": [{"reisen": "glutoase", "feld": [41, 18 - 1]}]},
		{"art": "tor", "feld": [3, 15], "dialog": "tor_duerrewald"},
		{"art": "bergpfad", "feld": [42, 25], "meldung": "Du steigst den Bergpfad hinauf auf den Glutgrat.",
			"aktionen": [{"reisen": "glutgrat", "feld": [GGB // 2, GGH - 3]}]},
		# Vulkanschmiede der Ketten (D32): Das Gespräch am Eingang lässt hinein, sobald Kael besiegt ist
		{"art": "schmiede_eingang", "feld": [22, 44], "dialog": "eingang_vulkanschmiede"},
	]


def glutoase():
	"""Die Stadt Glutoase als Terrassenstadt (D24, design.md „Glutoase im Detail“, beschlossen 29.10.)."""
	r = random.Random(33)
	tk = gk.TEILE
	g = [["."] * GB for _ in range(GH)]
	for y in range(GH):
		for x in range(GB):
			if x in (0, GB - 1) or y == GH - 1:
				g[y][x] = "X"
	for y in KANTEN:
		for x in range(GB):
			if x not in (TREPPE_X, TREPPE_X + 1):
				g[y][x] = "X"
	for teil, x, y, _ in GEBAEUDE:
		if tk[teil].get("flach"):
			continue
		b, t = tk[teil]["flaeche"]
		for i in range(b):
			for j in range(t):
				if 0 <= y + j < GH and 0 <= x + i < GB:
					g[y + j][x + i] = "X"
	for x in range(20, 27):
		g[0][x] = "."
	for y in range(9, 14):
		g[y][GB - 1] = "."
	karten = json.loads((gk.DATEN / "karten.json").read_text(encoding="utf-8"))
	karten["glutoase"] = {
		"name": "Glutoase", "musik": "stadt", "grund": "wiese", "licht": "fff0dc", "start": [23, 1],
		"raster": ["".join(z) for z in g],
		"ausgaenge": [{"bereich": [20, 0, 7, 1], "karte": "aschensteppe", "feld": [14, H - 2]},
			{"bereich": [GB - 1, 9, 1, 5], "karte": "palmenrast", "feld": [20, 1]}],
		"kampf_hintergrund": "wiese", "orte": glutoase_orte(), "baukasten": "karte_glutoase",
		# Oberhaupt und Lehrmeister (D26); die übrigen Figuren kommen mit D27
		"npcs": {
			"hadrak": {"name": "Hadrak Glutherz", "feld": [26, 43], "nachts": [31, 7], "aussehen": "hadrak", "dialog": "hadrak"},
			"brakkus": {"name": "Essenmeister Brakkus", "feld": [32, 26], "aussehen": "brakkus", "dialog": "brakkus"},
			"samira": {"name": "Tanzmeisterin Samira", "feld": [32, 11], "aussehen": "samira", "dialog": "samira"},
			# Figuren nach Steckbrief (D27, NPC.md)
			"nadia": {"name": "Brunnenhüterin Nadia", "feld": [25, 12], "aussehen": "grund_frau+nadia#zubehoer=wasserkrug", "dialog": "nadia"},
			"zaid": {"name": "Karawanenführer Zaid", "feld": [6, 7], "aussehen": "grund_haendler+zaid", "dialog": "zaid"},
			"bank_glutoase": {"name": "Bankhüter Rashid", "feld": [38, 6], "aussehen": "grund_alter_mensch+rashid#hut=rashid_kopftuch,zubehoer=bankschluessel",
				"dialog": "rashid", "zeichen": "truhe"},
			"tarek": {"name": "Händler Tarek", "feld": [7, 16], "aussehen": "grund_haendler+tarek#zubehoer=schaerpe&guertelklinge", "dialog": "tarek",
				"zeichen": "muenze"},
			"layla": {"name": "Wirtin Layla", "feld": [29, 6], "aussehen": "grund_frau+layla#zubehoer=schuerze_layla&tablett", "dialog": "layla"},
			"mira_glutoase": {"name": "Mira", "feld": [40, 13], "aussehen": "mira", "dialog": "mira_glutoase", "liegt": True},
			# Kael wartet nach dem Fest in Hadraks Schmiede (D29, Rivalenkampf)
			"kael_glutoase": {"name": "Kael", "feld": [24, 43], "aussehen": "kael", "dialog": "kael_glutoase",
				"wenn": {"oder": [{"auftrag": "rivale_kael", "stand": "aktiv"}, {"auftrag": "rivale_kael", "stand": "fertig"}]}},
			# Volk: Schmiede, Tänzer (nachts), Basar- und Karawanenleute, Aufzugwärter, Gäste (vor allem nachts)
			"schmied_1": {"name": "Schmied", "feld": [8, 26], "aussehen": "grund_handwerker+v_m2#zubehoer=schuerze", "dialog": "volk_go_schmied_1"},
			"schmied_2": {"name": "Schmied", "feld": [12, 26], "aussehen": "grund_handwerker+v_m3#zubehoer=schuerze", "dialog": "volk_go_schmied_2"},
			"schmied_3": {"name": "Schmiedin", "feld": [27, 26], "aussehen": "grund_frau+v_w2#zubehoer=schuerze", "dialog": "volk_go_schmied_3"},
			"taenzer_1": {"name": "Tänzer", "feld": [30, 9], "aussehen": "klingentaenzer_m+m3", "dialog": "volk_go_taenzer", "wenn": {"nacht": True}},
			"taenzer_2": {"name": "Tänzerin", "feld": [34, 13], "aussehen": "klingentaenzer_w+w3", "dialog": "volk_go_taenzer", "wenn": {"nacht": True}},
			"basar_1": {"name": "Basarhändlerin", "feld": [8, 11], "aussehen": "grund_haendler+v_w3", "dialog": "volk_go_basar_1", "wenn": {"nacht": False}},
			"basar_2": {"name": "Basarhändler", "feld": [12, 11], "aussehen": "grund_haendler+v_m1", "dialog": "volk_go_basar_2", "wenn": {"nacht": False}},
			"karawane_1": {"name": "Karawanenmann", "feld": [10, 4], "aussehen": "grund_mann+v_m3", "dialog": "volk_go_karawane_1"},
			"karawane_2": {"name": "Karawanenfrau", "feld": [3, 7], "aussehen": "grund_frau+v_w1", "dialog": "volk_go_karawane_2"},
			"aufzugwaerter": {"name": "Aufzugwärter", "feld": [39, 17], "aussehen": "grund_handwerker+a_m2", "dialog": "volk_go_aufzug"},
			"gast_go_1": {"name": "Gast", "feld": [33, 6], "aussehen": "grund_mann+v_m1", "dialog": "volk_go_gast_1"},
			"gast_go_2": {"name": "Gast", "feld": [35, 6], "aussehen": "grund_frau+v_w3", "dialog": "volk_go_gast_2", "wenn": {"nacht": True}},
			"gast_go_3": {"name": "Gast", "feld": [28, 9], "aussehen": "grund_handwerker+v_m2", "dialog": "volk_go_gast_3", "wenn": {"nacht": True}},
		},
	}
	(gk.DATEN / "karten.json").write_text(json.dumps(karten, ensure_ascii=False, indent="\t") + "\n", encoding="utf-8")
	gk.KARTEN.clear()
	gk.KARTEN.update(karten)
	k = gk.Karte("glutoase")
	boden = []
	for y in range(GH):
		zeile = ""
		for x in range(GB):
			if y <= OASE[1]:
				# Oase: Lehmpflaster auf den Wegen, Oasengras um den Brunnen, sonst Sand
				if abs(x - 23) <= 1 or y in (6, 7) or (abs(x - 23) < 8 and abs(y - 10) < 5 and (x * 3 + y) % 7 != 0):
					zeile += "L" if abs(x - 23) <= 1 or y in (6, 7) else "g"
				else:
					zeile += "s"
			elif y <= SCHMIEDEVIERTEL[1] + 1:
				zeile += "L" if abs(x - 23) <= 1 or y == 27 else "i"
			else:
				zeile += "i"
		boden.append(zeile)
	for teil, x, y, name in GEBAEUDE:
		k.setzen(teil, x, y, name, muss=False)
	# Terrassenkanten aus Lehmziegeln, in der Mitte die Treppen
	for y in KANTEN:
		for x in range(0, GB, 4):
			if not (x <= TREPPE_X + 1 and x + 3 >= TREPPE_X):
				k.setzen("go_terrassenkante", x, y, muss=False)
		k.setzen("go_treppe", TREPPE_X, y, muss=False)
		k.gesperrt -= {(TREPPE_X + i, y + j) for i in range(2) for j in range(2)}
	# Palmen, Krüge, Teppiche und Fackeln
	for x, y in [(3, 1), (18, 6), (27, 12), (35, 8), (16, 14), (43, 5), (2, 9), (25, 15)]:
		k.setzen("go_palme_gross" if (x + y) % 2 else "go_palme_klein", x, y, muss=False)
	for x, y in [(14, 12), (10, 13), (34, 3), (38, 17)]:
		k.setzen("go_tonkruege", x, y, muss=False)
	for x, y in [(9, 12), (13, 12)]:
		k.setzen("go_teppiche", x, y, muss=False)
	for x, y in [(29, 14), (35, 14), (29, 8), (35, 8)]:
		k.setzen("go_tanzlaterne", x, y, muss=False)
	for x, y in [(18, 36), (27, 36), (21, 20), (26, 20), (21, 35), (26, 35), (2, 30), (40, 30)]:
		k.setzen("go_fackel", x, y, muss=False)
	for x, y in [(18, 28), (27, 23), (9, 27), (35, 25)]:
		k.setzen(r.choice(["go_kohlesaecke", "go_amboss", "go_tonkruege"]), x, y, muss=False)
	k.erreichbar()
	k.speichern(boden)


GGB, GGH = 40, 36


def glutgrat_monster():
	M = lambda feld, gegner, stufe, **kw: dict({"feld": feld, "gegner": gegner, "stufe": stufe}, **kw)
	return [
		M([8, 28], ["glutsalamander"], 15), M([30, 29], ["schlackenbock"], 16), M([33, 20], ["rauchgeier"], 16),
		M([7, 18], ["geysirkrabbe", "glutsalamander"], 17), M([22, 16], ["schlackenbock", "rauchgeier"], 18),
		M([9, 9], ["glutsalamander", "geysirkrabbe", "rauchgeier"], 19), M([30, 9], ["schlackenbock", "schlackenbock"], 20),
		M([30, 29], ["glutfledermaus"], 17, zeit="nacht"), M([7, 18], ["obsidiangolem"], 18, zeit="nacht"),
		M([22, 16], ["glutfledermaus", "glutfledermaus"], 19, zeit="nacht"), M([9, 9], ["obsidiangolem", "glutfledermaus"], 20, zeit="nacht"),
		# Selten (Brocken): die Gewitterwyvern kreist oben am Kraterrand, Tag und Nacht
		M([20, 5], ["gewitterwyvern"], 20), M([20, 5], ["gewitterwyvern"], 20, zeit="nacht"),
	]


def glutgrat():
	"""Glutgrat (D30, design.md „Glutoase im Detail“): freier Bergpfad vom Schmiedeviertel, man kann hier frei leveln."""
	r = random.Random(34)
	g = [["."] * GGB for _ in range(GGH)]
	for y in range(GGH):
		for x in range(GGB):
			if x in (0, GGB - 1) or y in (0, GGH - 1) or ((x in (1, GGB - 2) or y == 1) and r.random() < 0.5) or r.random() < 0.035:
				g[y][x] = "s"
	# Unten der Einstieg vom Bergpfad
	for x in range(GGB // 2 - 3, GGB // 2 + 4):
		g[GGH - 1][x] = "."
	# Serpentinen-Pfad von unten bis zum Kraterrand
	pfad = [(20, GGH - 1), (20, 30), (10, 30), (10, 23), (28, 23), (28, 13), (14, 13), (14, 8), (20, 8), (20, 6)]
	for (x0, y0), (x1, y1) in zip(pfad, pfad[1:]):
		for y in range(min(y0, y1), max(y0, y1) + 1):
			for x in range(min(x0, x1), max(x0, x1) + 1):
				g[y][x] = "="
	for m in glutgrat_monster():
		x, y = m["feld"]
		for dx in (-1, 0, 1):
			for dy in (-1, 0, 1):
				if g[y + dy][x + dx] == "s":
					g[y + dy][x + dx] = "."
	karten = json.loads((gk.DATEN / "karten.json").read_text(encoding="utf-8"))
	karten["glutgrat"] = {
		"name": "Glutgrat", "musik": "wald", "grund": "wiese", "licht": "ffd8c0", "start": [GGB // 2, GGH - 2],
		"raster": ["".join(z) for z in g],
		"ausgaenge": [{"bereich": [GGB // 2 - 3, GGH - 1, 7, 1], "karte": "glutoase", "feld": [41, 25]}],
		"kampf_hintergrund": "wiese", "monster": glutgrat_monster(), "baukasten": "karte_glutgrat",
	}
	(gk.DATEN / "karten.json").write_text(json.dumps(karten, ensure_ascii=False, indent="\t") + "\n", encoding="utf-8")
	gk.KARTEN.clear()
	gk.KARTEN.update(karten)
	k = gk.Karte("glutgrat")
	# Boden: dunkler Stein, der Pfad aus Erde
	boden = ["".join("e" if g[y][x] == "=" else "i" for x in range(GGB)) for y in range(GGH)]
	# Oben der Kraterrand, quer über den Berg Lavarinnen und Felsgrate, heiße Quellen und Obsidian
	for teil, x, y in [("go_kraterrand", 9, 2), ("go_kraterrand", 26, 2), ("go_kraterrand", 15, 1), ("go_kraterrand", 21, 1),
			("go_lavarinne", 3, 26), ("go_lavarinne", 14, 27), ("go_lavarinne", 31, 25), ("go_lavarinne", 3, 15), ("go_lavarinne", 33, 16),
			("go_lavarinne", 18, 10), ("go_felsgrat", 23, 32), ("go_felsgrat", 32, 33), ("go_felsgrat", 2, 33), ("go_felsgrat", 17, 19),
			("go_felsgrat", 32, 5), ("go_felsgrat", 3, 4), ("go_heisse_quelle", 14, 32), ("go_heisse_quelle", 34, 12), ("go_heisse_quelle", 4, 11),
			("go_heisse_quelle", 23, 9), ("go_erkaltete_lava", 24, 27), ("go_erkaltete_lava", 5, 21), ("go_erkaltete_lava", 35, 22),
			("go_erkaltete_lava", 18, 4), ("go_erkaltete_lava", 31, 15)]:
		k.setzen(teil, x, y, muss=False)
	for y in range(GGH):
		for x in range(GGB):
			z = g[y][x]
			if z == "s":
				k.setzen(r.choice(["go_obsidian", "go_obsidian", "go_obsidian", "go_trockenbusch"]), x, y, muss=False)
			elif z == "." and r.random() < 0.02:
				k.setzen(r.choice(["go_obsidian", "go_erkaltete_lava"]), x, y, muss=False)
	k.erreichbar()
	k.speichern(boden)


VB, VH = 46, 30
## Abschnitte der Vulkanschmiede (x, y, Breite, Höhe): begehbarer Steinboden, dazwischen der Abgrund
SCHMIEDEHALLEN = (2, 4, 14, 23)
ANKERKAMMER = (31, 4, 14, 23)
## Plattformen in den Kettengängen und die Kettenbrücken dazwischen (x, y, gespiegelt = quer)
PLATTFORMEN = [(21, 8, 5, 5), (21, 18, 5, 6)]
BRUECKEN = [(16, 10, False), (26, 10, False), (16, 21, False), (26, 21, False), (23, 13, True)]


def vulkanschmiede_monster():
	M = lambda feld, gegner, stufe: {"feld": feld, "gegner": gegner, "stufe": stufe}
	return [
		# Schmiedehallen
		M([6, 20], ["schlackenkriecher", "glutgeist"], 15), M([12, 15], ["ambossknecht"], 16), M([6, 11], ["aschefalter", "glutgeist"], 16),
		M([12, 7], ["magmaschnecke", "schlackenkriecher"], 17),
		# Kettengänge
		M([23, 10], ["glutgeist", "glutgeist", "aschefalter"], 18), M([23, 21], ["ambossknecht", "magmaschnecke"], 18),
		# Ankerkammer
		M([37, 10], ["schlackenkriecher", "aschefalter", "glutgeist"], 19), M([37, 21], ["ambossknecht", "magmaschnecke", "glutgeist"], 20),
		# Selten: der Messingwächter, Hadraks Probe-Automat, in einer Ecke der Schmiedehallen
		M([4, 5], ["messingwaechter"], 20),
	]


def vulkanschmiede():
	"""Vulkanschmiede der Ketten (D32, design.md „Glutoase im Detail“, Sitzung 24)."""
	r = random.Random(35)
	g = [["X"] * VB for _ in range(VH)]
	offen = set()
	for x0, y0, b, h in [SCHMIEDEHALLEN, ANKERKAMMER] + PLATTFORMEN:
		offen |= {(x0 + i, y0 + j) for i in range(b) for j in range(h)}
	for x, y, quer in BRUECKEN:
		offen |= {(x, y + i) for i in range(5)} if quer else {(x + i, y) for i in range(5)}
	# Eingang: ein Gang von unten in die Schmiedehallen
	ex = VB // 2 - 15
	offen |= {(ex + i, y) for i in range(-1, 2) for y in range(SCHMIEDEHALLEN[1] + SCHMIEDEHALLEN[3], VH)}
	for x, y in offen:
		g[y][x] = "h"
	karten = json.loads((gk.DATEN / "karten.json").read_text(encoding="utf-8"))
	karten["vulkanschmiede"] = {
		"name": "Vulkanschmiede der Ketten", "musik": "wald_nacht", "grund": "hoehle", "licht": "b07a64", "dungeon": "vulkanschmiede",
		"kampf_hintergrund": "vulkanschmiede", "start": [ex, VH - 2],
		"raster": ["".join(z) for z in g],
		"ausgaenge": [{"bereich": [ex - 1, VH - 1, 3, 1], "karte": "glutoase", "feld": [22, 43]}],
		"monster": vulkanschmiede_monster(), "baukasten": "karte_vulkanschmiede",
	}
	(gk.DATEN / "karten.json").write_text(json.dumps(karten, ensure_ascii=False, indent="\t") + "\n", encoding="utf-8")
	gk.KARTEN.clear()
	gk.KARTEN.update(karten)
	k = gk.Karte("vulkanschmiede")
	brueckenfelder = {(x, y + i) if quer else (x + i, y) for x, y, quer in BRUECKEN for i in range(5)}
	# Boden: Schmiedestein; unter den Brücken und um alles herum der dunkle Abgrund
	boden = ["".join("i" if (x, y) in offen and (x, y) not in brueckenfelder else " " for x in range(VB)) for y in range(VH)]
	for x, y, quer in BRUECKEN:
		k.setzen("vs_kettenbruecke", x, y, gespiegelt=quer)
	# Schmiedehallen: verlassene Werkstätten mit Essen, Eisenwänden, Ambossen und einem Kühlbecken
	for teil, x, y, name in [("vs_esse", 2, 13, "Verlassene Esse"), ("vs_esse", 9, 4, ""), ("vs_eisenwand", 8, 18, ""), ("vs_eisenwand", 2, 9, ""),
			("vs_kuehlbecken", 13, 24, ""), ("go_amboss", 9, 12, ""), ("go_amboss", 4, 23, ""), ("go_kohlesaecke", 14, 11, ""),
			("go_kohlesaecke", 2, 17, ""), ("go_werkzeugwand", 6, 4, ""), ("go_fackel", 15, 4, ""), ("go_fackel", 2, 26, ""),
			("go_kettenamboss", 9, 22, "")]:
		k.setzen(teil, x, y, name, muss=False)
	# Kettengänge: Winden auf den Plattformen
	for x, y in [(21, 8), (24, 23 - 1)]:
		k.setzen("vs_kettenwinde", x, y, muss=False)
	# Ankerkammer: drei Anker an den Wänden, in der Mitte frei für den Kettenschmied, am Rand ein Kühlbecken
	for x, y, name in [(32, 4, "Anker"), (43, 4, ""), (43, 24, "")]:
		k.setzen("vs_anker", x, y, name, muss=False)
	for teil, x, y in [("vs_kuehlbecken", 32, 24), ("go_fackel", 38, 4), ("go_fackel", 44, 14), ("go_kohlesaecke", 34, 15),
			("go_lavarinne", 40, 4)]:
		k.setzen(teil, x, y, muss=False)
	for y in range(VH):
		for x in range(VB):
			if (x, y) in offen and (x, y) not in brueckenfelder and r.random() < 0.025:
				k.setzen(r.choice(["go_obsidian", "go_erkaltete_lava", "go_kohlesaecke"]), x, y, muss=False)
	k.erreichbar()
	k.speichern(boden)


if __name__ == "__main__":
	alle = {"aschensteppe": aschensteppe, "palmenrast": palmenrast, "glutoase": glutoase, "glutgrat": glutgrat, "vulkanschmiede": vulkanschmiede}
	for name in sys.argv[1:] or list(alle):
		alle[name]()
