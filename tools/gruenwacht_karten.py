"""Baut den Weg nach Grünwacht, den Waldboden, Tiefwurzel, Wipfelheim und die Pilzhöhle aus dem Baukasten (data/karte_<karte>.json).

Das Raster in data/karten.json bleibt, wie es ist: Es bestimmt weiter die Größe der Karte und wo man laufen kann. Jede Zahl
von dort (Figuren, Orte, Monster, Ausgänge) stimmt also weiter. Dieses Werkzeug legt nur Boden und Teile darüber. Zufällige
Bäume sind immer gleich (fester Startwert), und das Werkzeug prüft, dass alle wichtigen Felder erreichbar bleiben.
Aufruf: python3 tools/gruenwacht_karten.py [karte …]   (ohne Angabe alle)
"""
import json
import random
from collections import deque
from pathlib import Path

WURZEL = Path(__file__).resolve().parent.parent
DATEN = WURZEL / "data"
KARTEN = json.loads((DATEN / "karten.json").read_text(encoding="utf-8"))
TEILE = json.loads((DATEN / "baukasten_teile.json").read_text(encoding="utf-8"))["objekte"]
NAH = [(dx, dy) for dx in (-1, 0, 1) for dy in (-1, 0, 1)]


class Karte:
	def __init__(self, karte):
		self.id = karte
		self.d = KARTEN[karte]
		self.raster = self.d["raster"]
		self.h, self.b = len(self.raster), max(len(z) for z in self.raster)
		self.objekte = []
		self.belegt = set()
		self.gesperrt = self._raster_gesperrt()
		self.frei_halten = self._wichtige_felder()

	def zeichen(self, x, y):
		z = self.raster[y]
		return z[x] if x < len(z) else ","

	def _raster_gesperrt(self):
		g = set()
		for y in range(self.h):
			for x in range(self.b):
				if KARTEN["zeichen"].get(self.zeichen(x, y), {}).get("gesperrt"):
					g.add((x, y))
		for h in self.d.get("haeuser", []):
			x, y, b, t = h["feld"]
			g |= {(x + i, y + j) for i in range(b) for j in range(t)}
		g |= {tuple(s["feld"]) for s in self.d.get("staende", [])}
		g |= {tuple(n["feld"]) for n in self.d.get("npcs", {}).values()}
		return g

	def _wichtige_felder(self):
		w = {tuple(self.d["start"])}
		w |= {tuple(int(v) for v in n["feld"]) for liste in ("orte", "monster", "deko") for n in self.d.get(liste, [])}
		w |= {tuple(n["feld"]) for n in self.d.get("npcs", {}).values()}
		for a in self.d.get("ausgaenge", []):
			x, y, b, t = a["bereich"]
			w |= {(x + i, y + j) for i in range(b) for j in range(t)}
		for k in KARTEN.values():
			if isinstance(k, dict):
				for a in k.get("ausgaenge", []):
					if a["karte"] == self.id:
						w.add(tuple(a["feld"]))
				for o in k.get("orte", []):
					for ak in o.get("aktionen", []):
						if ak.get("reisen") == self.id:
							w.add(tuple(ak["feld"]))
		return w

	def flaeche(self, teil, feld, gespiegelt):
		b, t = TEILE[teil].get("flaeche", [1, 1])
		if gespiegelt:
			b, t = t, b
		return {(feld[0] + i, feld[1] + j) for i in range(b) for j in range(t)}

	def setzen(self, teil, x, y, name="", gespiegelt=False, muss=True):
		"""Stellt ein Teil auf. muss=True: Stört es etwas Wichtiges, bricht das Werkzeug ab."""
		f = self.flaeche(teil, (x, y), gespiegelt)
		platz = not (f & self.belegt or (f & self.frei_halten and not TEILE[teil].get("flach")))
		if not platz:
			if muss:
				raise SystemExit(f"{self.id}: {teil} bei {x},{y} stört {sorted(f & (self.belegt | self.frei_halten))}")
			return False
		self.belegt |= f
		if not TEILE[teil].get("flach"):
			self.gesperrt |= f
		o = {"teil": teil, "feld": [x, y]}
		if name:
			o["name"] = name
		if gespiegelt:
			o["gespiegelt"] = True
		self.objekte.append(o)
		return True

	def erreichbar(self):
		"""Alle wichtigen Felder (oder ein Nachbarfeld) müssen von der Ankunft aus erreichbar sein."""
		start = tuple(self.d["start"])
		gesehen, wf = {start}, deque([start])
		while wf:
			x, y = wf.popleft()
			for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
				n = (x + dx, y + dy)
				if 0 <= n[0] < self.b and 0 <= n[1] < self.h and n not in gesehen and n not in self.gesperrt:
					gesehen.add(n)
					wf.append(n)
		fehlt = [w for w in self.frei_halten if not any((w[0] + a, w[1] + b) in gesehen for a, b in NAH)]
		# Fackeln und Bosse in den Felsen, Ausgangsstreifen außerhalb zählen nicht
		if fehlt:
			raise SystemExit(f"{self.id}: nicht erreichbar: {sorted(fehlt)}")

	def speichern(self, boden):
		datei = DATEN / f"karte_{self.id}.json"
		datei.write_text(json.dumps({"boden": boden, "objekte": self.objekte}, ensure_ascii=False, indent="\t"), encoding="utf-8")
		print(f"{self.id}: {len(self.objekte)} Teile")


def waldboden_zeichen(x, y, r):
	"""Waldboden mit größeren Flecken Moos und Laub."""
	f = (x // 5 * 7 + y // 4 * 13 + (x // 5) * (y // 4)) % 11
	if f in (0, 1):
		return "m"
	if f == 2:
		return "l"
	return "r" if r.random() < 0.06 else "w"


def wald_fuellen(k, r, anteil, baeume, abstand_zu):
	"""Zusätzliche Bäume dort, wo nichts ist: nie neben Wegen, Figuren, Orten oder Monstern."""
	for y in range(k.h):
		for x in range(k.b):
			if r.random() >= anteil or k.zeichen(x, y) not in (",", "."):
				continue
			umgebung = {(x + i, y + j) for i in range(-2, 3) for j in range(-2, 3)}
			if umgebung & k.frei_halten or umgebung & k.belegt:
				continue
			if any(k.zeichen(a, c) in abstand_zu for a, c in umgebung if 0 <= a < k.b and 0 <= c < k.h):
				continue
			k.setzen(r.choice(baeume), x, y, muss=False)


def weg_gruenwacht():
	k, r = Karte("weg_gruenwacht"), random.Random(11)
	boden = ["".join({",": waldboden_zeichen(x, y, r), ".": ".", "=": "e"}.get(k.zeichen(x, y), ".") if k.zeichen(x, y) in ",.=" else
		("." if k.zeichen(x, y) in "TfsL" else "w") for x in range(k.b)) for y in range(k.h)]
	k.setzen("zelt", 33, 0)
	k.setzen("holzbank", 26, 3)
	k.setzen("jaegerhuette", 10, 13)
	k.setzen("baumstamm", 22, 12, muss=False)
	k.setzen("waldrand", 2, 0, muss=False)
	for y in range(k.h):
		for x in range(k.b):
			z = k.zeichen(x, y)
			teil = {"T": "baum", "t": r.choice(["gw_laubbaum", "tanne", "gw_laubbaum"]), "b": r.choice(["busch", "dornengebuesch"]),
				"f": "blumen", "p": "gw_leuchtpilze_klein", "s": "mauerruine", "L": "lagerfeuer"}.get(z)
			if teil:
				k.setzen(teil, x, y, muss=False)
	wald_fuellen(k, r, 0.1, ["gw_laubbaum", "baum", "tanne", "baum_herbst"], "=")
	k.erreichbar()
	k.speichern(boden)


def waldboden():
	k, r = Karte("waldboden"), random.Random(12)
	boden = ["".join("e" if k.zeichen(x, y) == "=" else waldboden_zeichen(x, y, r) for x in range(k.b)) for y in range(k.h)]
	k.setzen("gw_urbaum", 18, 24, "Der Urbaum")
	k.setzen("gw_hoehleneingang", 14, 24)
	k.setzen("gw_seilaufzug", 20, 16)
	k.setzen("gw_rowans_grab", 5, 2)
	k.setzen("gw_bienenstock", 41, 35)
	k.setzen("gw_hochsitz", 34, 25, muss=False)
	k.setzen("gw_steinkreis", 34, 8, muss=False)
	k.setzen("gw_lichtung", 6, 30, muss=False)
	for y in range(k.h):
		for x in range(k.b):
			z = k.zeichen(x, y)
			teil = {"t": r.choice(["gw_laubbaum", "gw_laubbaum", "gw_dunkler_baum", "tanne"]), "b": r.choice(["busch", "gw_farn"]),
				"p": r.choice(["gw_leuchtpilze_klein", "gw_leuchtpilze_mittel"]), "R": "tanne_gross"}.get(z)
			if teil:
				k.setzen(teil, x, y, muss=False)
	wald_fuellen(k, r, 0.1, ["gw_laubbaum", "baum_herbst", "gw_dunkler_baum", "tanne"], "=")
	# Pfad hinunter nach Tiefwurzel (D22b, Ausgang im Süden)
	k.setzen("gw_pfad_tiefwurzel", 24, 37, "Nach Tiefwurzel", muss=False)
	k.erreichbar()
	k.speichern(boden)


def tiefwurzel():
	"""Tiefwurzel (D22b): dunkler Wald südlich vom Waldboden, Wildes Land von Grünwacht (Stufe 20). Mehr Moos und Laub,
	dunkle und verdorrte Bäume, große Wurzeln, Splitterkristalle und Nebel am Boden."""
	k, r = Karte("tiefwurzel"), random.Random(21)
	boden = ["".join("e" if k.zeichen(x, y) == "=" else ("l" if (x * 7 + y * 3) % 9 == 0 else waldboden_zeichen(x, y, r))
		for x in range(k.b)) for y in range(k.h)]
	k.setzen("gw_pfad_tiefwurzel", 17, 1, "Pfad nach oben", muss=False)
	for teil, x, y in [("gw_wurzelhoehle", 3, 18), ("gw_grosse_wurzel", 24, 6), ("gw_grosse_wurzel", 14, 19), ("gw_verdorrter_baum", 34, 4),
			("gw_verdorrter_baum", 5, 6), ("gw_verdorrter_baum", 24, 26), ("gw_splitterkristall_gross", 33, 24), ("gw_splitterkristall_gross", 10, 8),
			("gw_wurzelsplitter", 16, 26), ("gw_wurzelsplitter", 35, 15), ("gw_leuchtpilze_gross", 27, 3), ("gw_splitterkristall_klein", 23, 22),
			("gw_nebelboden", 6, 12), ("gw_nebelboden", 24, 17), ("gw_nebelboden", 15, 22), ("gw_nebelboden", 32, 19), ("gw_nebelboden", 26, 9)]:
		k.setzen(teil, x, y, muss=False)
	for y in range(k.h):
		for x in range(k.b):
			teil = {"t": r.choice(["gw_dunkler_baum", "gw_dunkler_baum", "tanne", "tanne_gross"]), "b": r.choice(["gw_farn", "dornengebuesch"]),
				"p": r.choice(["gw_leuchtpilze_klein", "gw_leuchtpilze_mittel"])}.get(k.zeichen(x, y))
			if teil:
				k.setzen(teil, x, y, muss=False)
	wald_fuellen(k, r, 0.08, ["gw_dunkler_baum", "gw_dunkler_baum", "tanne", "baum_herbst"], "=")
	k.erreichbar()
	k.speichern(boden)


def gelaender(k):
	"""Seil-Geländer außen um Plattformen und Brücken."""
	begehbar = lambda x, y: 0 <= x < k.b and 0 <= y < k.h and k.zeichen(x, y) in "#-OZ"
	for y in range(k.h):
		x = 0
		while x < k.b - 1:
			if k.zeichen(x, y) == "~" and k.zeichen(x + 1, y) == "~" and begehbar(x, y + 1) and begehbar(x + 1, y + 1):
				k.setzen("gw_gelaender", x, y, muss=False)
				x += 2
			else:
				x += 1
	for x in range(k.b):
		y = 0
		while y < k.h - 1:
			if k.zeichen(x, y) == "~" and k.zeichen(x, y + 1) == "~" and begehbar(x + 1, y) and begehbar(x + 1, y + 1):
				k.setzen("gw_gelaender", x, y, gespiegelt=True, muss=False)
				y += 2
			else:
				y += 1


def wipfelheim():
	k, r = Karte("wipfelheim"), random.Random(13)
	boden = ["".join("p" if k.zeichen(x, y) in "#-OZ" else "m" for x in range(k.b)) for y in range(k.h)]
	k.setzen("gw_gasthaus", 9, 17, "Baumhaus-Gasthaus")
	k.setzen("gw_dornfeders_halle", 22, 15, "Dornfeders Halle")
	k.setzen("gw_bank", 28, 18, "Bank")
	k.setzen("gw_esches_huette", 26, 33, "Esches Labor")
	k.setzen("gw_tildas_stall", 42, 16, "Monster-Stall")
	k.setzen("gw_wohnbaumhaus", 39, 15)
	k.setzen("gw_seilaufzug", 5, 24)
	# Kräuterhändlerin Salbei: Stand auf dem Hauptplatz neben der Bank (D13)
	k.setzen("gw_stand_salbei", 30, 23, "Salbeis Kräuter")
	k.setzen("gw_kraeuterkisten", 29, 24, muss=False)
	for y in range(k.h):
		for x in range(k.b):
			z = k.zeichen(x, y)
			teil = {"Z": "gw_zielscheibe", "O": "gw_baumstumpf"}.get(z)
			if teil:
				k.setzen(teil, x, y, muss=False)
	gelaender(k)
	# Baumkronen um die Plattformen
	for y in range(k.h):
		for x in range(k.b):
			if k.zeichen(x, y) == "~" and r.random() < 0.09:
				nah = {(x + i, y + j) for i in range(-2, 3) for j in range(-2, 3)}
				if not any(0 <= a < k.b and 0 <= c < k.h and k.zeichen(a, c) in "#-OZ" for a, c in nah):
					k.setzen(r.choice(["gw_laubbaum", "baum", "gw_laubbaum"]), x, y, muss=False)
	k.erreichbar()
	k.speichern(boden)


def pilzhoehle():
	k, r = Karte("pilzhoehle"), random.Random(14)
	offen = lambda x, y: 0 <= x < k.b and 0 <= y < k.h and k.zeichen(x, y) in "hPW"
	boden = ["".join(("r" if r.random() < 0.7 else "w") if offen(x, y) else " " for x in range(k.b)) for y in range(k.h)]
	k.frei_halten = {f for f in k.frei_halten if offen(*f)}
	for y in range(k.h):
		for x in range(k.b):
			z = k.zeichen(x, y)
			teil = {"P": "gw_leuchtpilze_gross", "W": "gw_wurzelsplitter"}.get(z)
			if teil:
				k.setzen(teil, x, y, muss=False)
	# Wurzelwände an den hinteren Rändern der Gänge
	for y in range(k.h):
		x = 0
		while x < k.b - 3:
			if all(not offen(x + i, y) and offen(x + i, y + 1) for i in range(4)):
				k.setzen("gw_wurzelwand", x, y, muss=False)
				x += 4
			else:
				x += 1
	for x in range(k.b):
		y = 0
		while y < k.h - 3:
			if all(not offen(x, y + i) and offen(x + 1, y + i) for i in range(4)):
				k.setzen("gw_wurzelwand", x, y, gespiegelt=True, muss=False)
				y += 4
			else:
				y += 1
	for y in range(k.h):
		for x in range(k.b):
			if k.zeichen(x, y) == "F":
				k.setzen("gw_lichtlaterne", x, y, muss=False)
	k.erreichbar()
	k.speichern(boden)


if __name__ == "__main__":
	import sys
	alle = {"weg_gruenwacht": weg_gruenwacht, "waldboden": waldboden, "tiefwurzel": tiefwurzel, "wipfelheim": wipfelheim, "pilzhoehle": pilzhoehle}
	for name in sys.argv[1:] or list(alle):
		alle[name]()
