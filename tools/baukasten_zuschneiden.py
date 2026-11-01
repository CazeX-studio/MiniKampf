"""Schneidet die KI-Bildblätter (tools/vorlagen/) in einzelne Baukasten-Teile (assets/baukasten/).

Was das Werkzeug macht:
- stellt die Teile frei (auch wenn das Karomuster für „durchsichtig“ nur mitgemalt ist),
- schneidet jedes Teil einzeln aus und benennt es (Zuordnung über einen ungefähren Punkt im Blatt),
- verkleinert es auf Spielgröße (ein Feld ist im Spiel 64 x 32 Pixel),
- misst die Grundfläche (wie viele Felder breit und tief) und den Fußpunkt und schreibt beides
  nach tools/vorlagen/messung.json (Claude überträgt die Werte nach data/baukasten_teile.json).
Aufruf: python3 tools/baukasten_zuschneiden.py [BLATT …]   (braucht numpy, scipy und Pillow; ohne Angabe alle Blätter)
"""
import json
import sys
from pathlib import Path

import numpy as np
from PIL import Image
from scipy import ndimage

import look_pruefen

WURZEL = Path(__file__).resolve().parent.parent
VORLAGEN = WURZEL / "tools" / "vorlagen"
ZIEL = WURZEL / "assets" / "baukasten"
TW, TH = 64, 32
## Bodenrauten: so viel vom Rand weglassen (Anteil), damit der dunkle Rand der gemalten Kacheln verschwindet
BODEN_RAND = 0.07

# Blatt -> Maßstab (Spielpixel pro Bildpixel) und Teile mit ungefährer Mitte im Blatt.
# Die Maßstäbe sind so gewählt, dass die Blätter zueinander passen (Häuser, Stände, Kleinkram, Bäume).
BLAETTER = {
	"gebaeude": {"massstab": 0.6, "schnitt": [(800, 1440, 487)], "teile": {
		"gilde": (400, 440), "wegrast": (1120, 240), "haus_klein": (1020, 660), "haus_mittel": (1560, 600)}},
	"markt": {"massstab": 0.45, "teile": {
		"marktstand_rot": (360, 260), "marktstand_blau": (940, 220), "bingos_stand": (600, 660), "brunnen": (1460, 540)}},
	"besonderes": {"massstab": 0.6, "teile": {
		"statue_der_fuenf": (360, 340), "torbogen": (880, 330), "sechstes_tor": (1310, 340),
		"bruecke": (540, 800), "mauer": (1190, 800)}},
	"pavillons": {"massstab": 0.55, "teile": {
		"pavillon_messinghafen": (280, 270), "pavillon_glutoase": (780, 270), "pavillon_gruenwacht": (1280, 270),
		"pavillon_arkanum": (510, 680), "pavillon_nebelinseln": (1040, 680)}},
	"kleinkram": {"massstab": 0.38, "teile": {
		"laterne": (190, 250), "fackelschale": (530, 300), "banner": (810, 250), "bank": (1210, 350), "fass": (1600, 370),
		"kiste": (180, 730), "zaun": (510, 730), "wegweiser": (800, 670), "auftragsbrett": (1140, 680), "mauerruine": (1550, 710)}},
	"pflanzen": {"massstab": 0.44, "teile": {
		"baum": (230, 340), "baum_herbst": (670, 340), "tanne": (1100, 360), "tanne_gross": (1520, 300),
		"busch": (230, 740), "busch_bluete": (680, 740), "blumen": (1100, 760), "grasbueschel": (1540, 760)}},
	"splitter": {"massstab": 0.41, "roter_rand": True, "teile": {
		"splitterkreis": (440, 230), "krater_frisch": (1320, 260), "krater_spaet": (680, 650), "sternsplitter": (1460, 690)}},
	"boden": {"boden": True, "teile": {
		"gras_1": (274, 190), "gras_2": (820, 190), "pflaster_1": (1360, 190), "pflaster_2": (1896, 190),
		"platz": (274, 510), "erde": (820, 510), "wasser_1": (1360, 510), "wasser_2": (1896, 510)}},
	# Kreuzweg und Kreuzwegfelder (GRAFIK_AUFTRAG.md, Teil C). "massstaebe": Maßstab einzelner Teile, weil die Motive
	# auf diesen Blättern unterschiedlich groß gemalt sind. "saum": durchsichtig gespeichertes Blatt mit rotem Saum.
	"kreuzweg_k1": {"massstab": 0.38, "saum": True, "look": True, "teile": {
		"mauer_kurve": (467, 348), "mauer_ende": (1178, 380), "mauer_treppe": (1846, 358)}},
	"kreuzweg_k1b": {"massstab": 0.33, "stein": (0.86, 0.86, 0.9), "look": True, "teile": {
		"mauer_gerade_a": (540, 330), "mauer_gerade_b": (1450, 330)}},
	"kreuzweg_k2": {"massstab": 0.32, "look": True, "massstaebe": {"seitentor": 0.38, "wachhaeuschen": 0.4}, "teile": {
		"banner_messinghafen": (438, 147), "banner_glutoase": (749, 147), "banner_gruenwacht": (1070, 147),
		"banner_arkanum": (1387, 147), "banner_nebelinseln": (1708, 147), "seitentor": (717, 516), "wachhaeuschen": (1390, 489)}},
	"kreuzweg_k3": {"massstab": 0.38, "saum": True, "look": True, "massstaebe": {"bankhaus": 0.36, "hutmacher": 0.42}, "teile": {
		"bankhaus": (418, 358), "bingos_laden": (1195, 348), "hutmacher": (1846, 358)}},
	"kreuzweg_k4": {"massstab": 0.38, "look": True, "massstaebe": {"eckhaus": 0.34}, "teile": {
		"haus_gross": (489, 434), "eckhaus": (1542, 456)}},
	"kreuzweg_k5": {"massstab": 0.26, "look": True, "massstaebe": {"wegelaterne": 0.25}, "teile": {
		"wegelaterne": (424, 413), "festbuehne": (1401, 413)}},
	"kreuzweg_k7": {"massstab": 0.2, "saum": True, "look": True, "teile": {
		"strohpuppe": (282, 380), "zielscheibe": (695, 402), "waffenstaender": (1184, 380), "feuerstelle": (1825, 380)}},
	"kreuzweg_k8": {"massstab": 0.19, "look": True, "massstaebe": {"festlaternen": 0.3, "dornenranken": 0.22}, "teile": {
		"blumenkasten": (239, 489), "festlaternen": (983, 348), "dornenranken": (1835, 445)}},
	"kreuzwegfelder_z1a": {"boden": True, "teile": {"blumenwiese_1": (545, 355), "blumenwiese_2": (1630, 355)}},
	"kreuzwegfelder_z1b": {"massstab": 0.2, "look": True, "massstaebe": {"heuballen": 0.17}, "teile": {
		"steg": (711, 391), "heuballen": (1683, 391)}},
	# Rastplatz und Hirschtal. "kern": durchsichtig gespeichertes Blatt mit farbigem Saum, nur der feste Kern bleibt.
	"weg_r1": {"massstab": 0.3, "kern": True, "look": True, "massstaebe": {"holzbank": 0.4}, "teile": {
		"lagerfeuer": (480, 270), "haendlerstand": (1120, 210), "holzbank": (455, 690), "zelt": (1170, 620)}},
	"weg_z2": {"massstab": 0.3, "look": True, "massstaebe": {"waldrand": 0.42, "jaegerhuette": 0.33, "baumstamm": 0.35,
		"geweih_wegweiser": 0.45}, "teile": {
		"waldrand": (450, 190), "bach_steine": (275, 515), "holzbruecke": (755, 510), "jaegerhuette": (1380, 280),
		"baumstamm": (335, 760), "dornengebuesch": (850, 760), "geweih_wegweiser": (1225, 710)}},
}


def freistellen(bild, roter_rand=False):
	"""RGBA-Feld mit echtem Hintergrund; ein mitgemaltes Karomuster wird entfernt, graue Schatten darauf halb durchsichtig."""
	a = np.array(bild.convert("RGBA")).astype(np.int16)
	if bild.mode == "RGBA" and a[..., 3].min() == 0:
		if roter_rand:
			# Nur bei Blättern mit rotem Schimmer am Rand: halbdurchsichtige, stark rote Pixel entfernen
			r, g, b, alpha = a[..., 0], a[..., 1], a[..., 2], a[..., 3]
			a[(r > g + 80) & (r > b + 40) & (alpha < 255), 3] = 0
		return a.astype(np.uint8)
	rgb = a[..., :3]
	hoch, tief = rgb.max(-1), rgb.min(-1)
	# Hintergrund: helle, graue Flächen, die mit dem Rand verbunden sind
	grau = (hoch - tief < 22) & (tief > 150)
	lab, _ = ndimage.label(grau)
	rand = set(np.unique(np.concatenate([lab[0], lab[-1], lab[:, 0], lab[:, -1]]))) - {0}
	hinten = np.isin(lab, list(rand))
	# Eingeschlossene Karo-Löcher (zwischen Ästen, unter Planen): grau-weiß und mit vielen fast weißen Pixeln
	loch = (hoch - tief < 16) & (tief > 205) & ~hinten
	ll, ln = ndimage.label(loch)
	if ln:
		groesse = ndimage.sum(loch, ll, range(1, ln + 1))
		weiss = ndimage.sum(loch & (tief > 244), ll, range(1, ln + 1))
		hinten |= np.isin(ll, [i + 1 for i in range(ln) if groesse[i] >= 25 and weiss[i] > 0.2 * groesse[i]])
	aus = a.copy()
	aus[..., 3] = 255
	hell = hinten & (tief > 214)
	aus[hell, 3] = 0
	schatten = hinten & ~hell
	aus[schatten, 3] = np.clip((235 - tief[schatten]) * 2.2, 0, 255)
	aus[schatten, :3] = 0
	return aus.astype(np.uint8)


def saum_entfernen(bild):
	"""Durchsichtig gespeichertes Blatt: der weiche rote Saum außen fliegt raus, das Innere der Teile wird ganz deckend."""
	a = np.array(bild.convert("RGBA")).astype(np.int16)
	r, g, b, alpha = a[..., 0], a[..., 1], a[..., 2], a[..., 3]
	a[(alpha < 128) & (r > g + 80) & (r > b + 40), 3] = 0
	a[ndimage.binary_fill_holes(a[..., 3] >= 128), 3] = 255
	return a.astype(np.uint8)


def kern_behalten(bild):
	"""Durchsichtig gespeichertes Blatt: alles Halbdurchsichtige außen fliegt raus, das Innere wird ganz deckend."""
	a = np.array(bild.convert("RGBA")).copy()
	a[..., 3] = np.where(ndimage.binary_fill_holes(a[..., 3] >= 128), 255, 0)
	return a


def stein_angleichen(a, faktor):
	"""Färbt nur steinfarbene Pixel um; Banner, Blätter und Umriss bleiben."""
	f = a.astype(np.float32)
	r, g, b = f[..., 0], f[..., 1], f[..., 2]
	maske = (abs(r - b) < 75) & (r > 70) & (g > b - 5) & (r - g < 45) & (g - r < 5)
	f[..., :3][maske] = np.clip(f[..., :3][maske] * np.array(faktor, dtype=np.float32), 0, 255)
	return f.astype(np.uint8)


def teile_finden(a, schnitte):
	"""Zusammenhängende Teile (Labels) im Blatt; kleine Krümel fallen weg."""
	m = a[..., 3] > 40
	ml, mn = ndimage.label(m)
	groesse = ndimage.sum(m, ml, range(1, mn + 1))
	m = np.isin(ml, [i + 1 for i, g in enumerate(groesse) if g >= 150])
	for x0, x1, y in schnitte:
		m[y - 4:y + 5, x0:x1] = False
	lab, n = ndimage.label(ndimage.binary_dilation(m, iterations=2))
	lab[~m] = 0
	stuecke = []
	for i, sl in enumerate(ndimage.find_objects(lab)):
		if sl is not None and (lab[sl] == i + 1).sum() >= 1500:
			stuecke.append((i + 1, sl))
	return lab, stuecke


def naechstes(stuecke, punkt):
	def abstand(st):
		sl = st[1]
		cy, cx = (sl[0].start + sl[0].stop) / 2, (sl[1].start + sl[1].stop) / 2
		return (cx - punkt[0]) ** 2 + (cy - punkt[1]) ** 2
	return min(stuecke, key=abstand)


def messen(teil):
	"""Grundfläche und Fußpunkt (Mitte der Grundfläche) aus der unteren Spitze und der Breite unten."""
	alpha = np.array(teil)[..., 3]
	fest = alpha > 200
	zeilen = np.where(fest.any(1))[0]
	unten = zeilen.max()
	spitze_x = float(np.where(fest[unten])[0].mean())
	# Breite der Grundfläche: unteres Drittel des Bildes
	bereich = fest[max(0, int(unten - (unten - zeilen.min()) * 0.3)):unten + 1]
	spalten = np.where(bereich.any(0))[0]
	links, rechts = spalten.min(), spalten.max()
	w = max(1, round((spitze_x - links) / (TW / 2)))
	h = max(1, round((rechts - spitze_x) / (TW / 2)))
	# Mitte der Grundfläche (wie im Spiel: von der vorderen Spitze aus)
	fuss = [round(spitze_x + (h - w) * TW / 4), round(unten - (w + h) * TH / 4)]
	return [w, h], fuss


def boden_teil(a, sl, lab, i):
	"""Bodenraute: nur die Oberseite (ohne Dicke und ohne dunklen Rand), genau 64 x 32, mit Rautenmaske."""
	stueck = a[sl].copy()
	stueck[lab[sl] != i, 3] = 0
	bild = Image.fromarray(stueck)
	breite = bild.width
	rx, ry = breite * BODEN_RAND, breite / 2 * BODEN_RAND
	oben = bild.crop((round(rx), round(ry), round(breite - rx), round(breite / 2 - ry))).resize((TW, TH), Image.LANCZOS)
	maske = Image.new("L", (TW, TH), 0)
	from PIL import ImageDraw
	ImageDraw.Draw(maske).polygon([(TW / 2, 0), (TW, TH / 2), (TW / 2, TH), (0, TH / 2)], fill=255)
	ergebnis = Image.new("RGBA", (TW, TH), (0, 0, 0, 0))
	ergebnis.paste(oben.convert("RGB"), (0, 0), maske)
	return ergebnis


def main():
	namen = sys.argv[1:] or list(BLAETTER)
	datei = VORLAGEN / "messung.json"
	messung = json.loads(datei.read_text(encoding="utf-8"))
	regeln = look_pruefen.lade_regeln()
	for blatt in namen:
		info = BLAETTER[blatt]
		bild = Image.open(VORLAGEN / f"{blatt}.png")
		if info.get("kern"):
			a = kern_behalten(bild)
		else:
			a = saum_entfernen(bild) if info.get("saum") else freistellen(bild, info.get("roter_rand", False))
		if info.get("stein"):
			a = stein_angleichen(a, info["stein"])
		lab, stuecke = teile_finden(a, info.get("schnitt", []))
		for name, punkt in info["teile"].items():
			i, sl = naechstes(stuecke, punkt)
			if info.get("boden"):
				boden_teil(a, sl, lab, i).save(ZIEL / "boden" / f"{name}.png")
				continue
			stueck = a[sl].copy()
			stueck[lab[sl] != i, 3] = 0
			bild = Image.fromarray(stueck)
			s = info.get("massstaebe", {}).get(name, info["massstab"])
			bild = bild.resize((max(1, round(bild.width * s)), max(1, round(bild.height * s))), Image.LANCZOS)
			pfad = ZIEL / "objekte" / f"{name}.png"
			bild.save(pfad)
			if info.get("look"):
				look_pruefen.nachbearbeiten(pfad, "baukasten", pfad, None, regeln)
				bild = Image.open(pfad)
			flaeche, fuss = messen(bild)
			messung[name] = {"groesse": [bild.width, bild.height], "flaeche": flaeche, "fuss": fuss}
			print(f"{name:24s} {bild.width:4d} x {bild.height:4d}  Felder {flaeche}  Fuß {fuss}")
	datei.write_text(json.dumps(messung, ensure_ascii=False, indent="	"))


if __name__ == "__main__":
	main()
