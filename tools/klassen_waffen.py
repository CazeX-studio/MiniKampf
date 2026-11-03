"""Klassenwaffen an der Hand (D18b): Langbogen für den Bogenschützen, Schleuder für den Monster-Zähmer.

Die Klassen-Körper (tools/koerper_blatt.py) haben leere Fäuste. Dieses Werkzeug
1. schneidet die Waffen aus tools/vorlagen/klassen_waffen.png (Bogen mit Sehne, Schleuder) und
   klassen_bogen_gespannt.png (gespannter Bogen mit Pfeil) nach assets/teile/waffe/. Die Bilder zeigen nach links,
   im Spiel schauen die Figuren nach rechts: darum gespiegelt. Anker = Griff (Mitte des Bogens, Stiel der Schleuder).
2. sucht in jedem Bild der Körper die Waffenhand (die vordere Faust, in der Welt die äußere Hand, beim Zähmer
   mit erhobener Faust die oberste) und schreibt griff, waffe_winkel (0 = aufrecht) und bei Bedarf waffe_bild
   (z. B. der gespannte Bogen beim Schuss) nach data/figurteile.json.
In manchen Bewegungen ist keine Waffe zu sehen (Fallen, Sieg, Getroffen, beim Bogenschützen auch Ausweichen).
Vorher tools/koerper_blatt.py laufen lassen.
Aufruf: python3 tools/klassen_waffen.py   (braucht numpy, scipy und Pillow)
"""
import json
import sys
from pathlib import Path

import numpy as np
from PIL import Image
from scipy import ndimage

WURZEL = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(WURZEL / "tools"))
from aussehen_bilder import DATEN as SCHICHTEN, TEILE, klein, teile  # noqa: E402

FIGURTEILE = WURZEL / "data" / "figurteile.json"
KOERPER_BILD = TEILE / "koerper"

## Waffe -> (Blatt, Nummer von links, Name, Höhe im Spiel in Pixeln, Anker als Anteil der Höhe)
WAFFEN = {
	"langbogen": ("klassen_waffen", 1, "Langbogen", 80, 0.5),
	"langbogen_gespannt": ("klassen_bogen_gespannt", 1, "Langbogen (gespannt)", 80, 0.5),
	"schleuder": ("klassen_waffen", 2, "Schleuder", 34, 0.8),
}
## Körper -> Waffe, Bewegungen ohne Waffe, Bewegungen mit anderem Bild (Bewegung -> {Bild-Nummern oder None = alle: Waffe})
KLASSEN = {
	"bogen": {"waffe": "langbogen", "ohne": ["death", "victory", "hit", "parry"],
			"anders": {"attack": ([1, 2, 3], "langbogen_gespannt"), "cast": (None, "langbogen_gespannt")}},
	"zaehmer": {"waffe": "schleuder", "ohne": ["death", "victory", "hit"], "anders": {}},
}


def waffen_schneiden():
	ziel = TEILE / "waffe"
	ziel.mkdir(exist_ok=True)
	daten = {}
	hoehe_bogen = None
	for wid, (blatt, nummer, name, hoehe, anker_anteil) in WAFFEN.items():
		t = [s for r in teile(blatt) for s in r][nummer]
		bild = Image.fromarray(t).transpose(Image.FLIP_LEFT_RIGHT)
		# Gespannter und ungespannter Bogen gleich groß: gemessen an der Höhe des Bogens
		faktor = hoehe / bild.height
		bild = klein(np.array(bild), faktor)
		bild.save(ziel / f"{wid}.png")
		a = np.array(bild)[..., 3] > 128
		y = round(bild.height * anker_anteil)
		# Griff: Mitte des rechten Stücks in dieser Höhe (Bogen-Stab bzw. Stiel der Schleuder). Beim gespannten Bogen
		# eine Zeile über dem Pfeil messen, sonst träfe man die Pfeilspitze.
		mess_y = y - 7 if wid == "langbogen_gespannt" else y
		x = float(rechtes_stueck(a[mess_y]))
		daten[wid] = {"name": name, "anker": [round(x, 1), y], "auswahl": False}
		if wid == "langbogen":
			hoehe_bogen = bild.height
	return daten


def rechtes_stueck(zeile):
	"""Mitte des am weitesten rechts liegenden zusammenhängenden Stücks einer Bildzeile."""
	xs = np.where(zeile)[0]
	ende = xs.max()
	anfang = ende
	while anfang - 1 in set(xs.tolist()):
		anfang -= 1
	return (anfang + ende) / 2


def figur(a):
	"""Nur die Figur: die größte zusammenhängende Fläche (ohne feine Reste vom Kopf-Oval)."""
	m = ndimage.binary_opening(a[..., 3] > 128, iterations=1)
	lab, n = ndimage.label(m)
	if n > 1:
		groessen = ndimage.sum_labels(np.ones_like(lab), lab, range(1, n + 1))
		m = lab == (np.argmax(groessen) + 1)
	return m


def hand(a, info, art):
	"""Mitte der Waffenhand: vorne = vorderste Faust zwischen Hals und Knie, oben = erhobene Faust,
	links/rechts = äußere Hand auf Hüfthöhe (Welt von vorne bzw. hinten)."""
	m = figur(a)
	ys, _ = np.where(m)
	oben, unten = ys.min(), ys.max()
	h = unten - oben
	if art == "oben":
		cols = np.where(m[oben:oben + 4].any(0))[0]
		return [float(cols.mean()), float(oben + 5)]
	if art == "vorne":
		y0, y1 = int(info.get("hals", [0, oben + h * 0.35])[1] + 4), int(unten - h * 0.22)
		band = m[y0:y1]
		x = int(np.where(band.any(0))[0].max())
		zeilen = np.where(band[:, x - 3:x + 1].any(1))[0] + y0
		return [float(x - 5), float(zeilen.mean())]
	y0, y1 = int(oben + h * 0.5), int(oben + h * 0.82)
	band = m[y0:y1]
	spalten = np.where(band.any(0))[0]
	x = int(spalten.min() if art == "links" else spalten.max())
	zeilen = np.where(band[:, max(0, x - 1):x + 2].any(1))[0] + y0
	return [float(x + (5 if art == "links" else -5)), float(zeilen.mean())]


def art_fuer(klasse, anim, info, a):
	if anim in ("idle_vorn", "run_vorn"):
		return "links"
	if anim in ("idle_hinten", "run_hinten"):
		return "rechts"
	# Zähmer: Wurf und Anfeuern mit erhobener Faust
	if klasse == "zaehmer" and anim in ("parry", "attack") and np.where(figur(a))[0].min() < info["hals"][1] - 12:
		return "oben"
	return "vorne"


def main():
	schichten = json.loads(SCHICHTEN.read_text(encoding="utf-8"))
	schichten["waffe"].update(waffen_schneiden())
	SCHICHTEN.write_text(json.dumps(schichten, ensure_ascii=False, indent="\t"), encoding="utf-8")
	daten = json.loads(FIGURTEILE.read_text())
	for klasse, regeln in KLASSEN.items():
		for geschlecht in ["m", "w"]:
			koerper = f"{klasse}_{geschlecht}"
			if koerper not in daten:
				print(f"{koerper} fehlt (erst tools/koerper_blatt.py)")
				continue
			eintrag = daten[koerper]
			eintrag["_waffe"] = regeln["waffe"]
			eintrag["_klassenwaffe"] = True
			anzahl = 0
			for name, info in eintrag.items():
				if name.startswith("_") or info.get("ganz", False):
					continue
				anim, nummer = name.rsplit("_f", 1)
				for alt in ["griff", "waffe_winkel", "waffe_bild"]:
					info.pop(alt, None)
				if anim in regeln["ohne"] or "hals" not in info:
					continue
				a = np.array(Image.open(KOERPER_BILD / f"{koerper}_{name}.png").convert("RGBA"))
				punkt = hand(a, info, art_fuer(klasse, anim, info, a))
				info["griff"] = [round(punkt[0], 1), round(punkt[1], 1)]
				info["waffe_winkel"] = 0.0
				if anim in regeln["anders"]:
					bilder, waffe = regeln["anders"][anim]
					if bilder is None or int(nummer) in bilder:
						info["waffe_bild"] = waffe
				anzahl += 1
			print(f"{koerper}: {regeln['waffe']} in {anzahl} Bildern")
	FIGURTEILE.write_text(json.dumps(daten, ensure_ascii=False, indent="\t", sort_keys=True))


if __name__ == "__main__":
	main()
