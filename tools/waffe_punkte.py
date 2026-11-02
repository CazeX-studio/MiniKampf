"""Handpunkte der Novizen messen (Projekt 13, Schritt 3): Wo sitzt in jedem Bild das Schwert, wohin zeigt die Klinge?

Die alten Blätter <körper>_<blatt>.png zeigen die Klinge, die neuen _ohne_klinge nur noch den Griff. Aus den alten kommen
Richtung und Stelle der Klinge, im neuen Bild sitzt der Punkt auf dem Gold des Griffs. Ergebnis in data/figurteile.json:
griff (Punkt an der Parierstange) und waffe_winkel (Grad, 0 = Spitze nach oben, im Uhrzeigersinn). Bilder ohne sichtbare Klinge bekommen keine Werte, dort ist kein Schwert zu sehen.
Vorher tools/koerper_blatt.py laufen lassen.
Aufruf: python3 tools/waffe_punkte.py [körper …]   (braucht numpy, scipy und Pillow)
"""
import json
import sys
from pathlib import Path

import numpy as np
from PIL import Image
from scipy import ndimage

WURZEL = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(WURZEL / "tools"))
from figur_bilder import FIGUREN, blatt  # noqa: E402
from koerper_blatt import DATEN, KOERPER, KOPF_QUELLE, REIHEN, gruen  # noqa: E402

FIGUR = WURZEL / "assets" / "figuren"
## Kürzer als das (Pixel) gilt nicht als Klinge
MIN_LAENGE = 12
## Länglich genug (Länge / Breite der Fläche)
MIN_FORM = 2.4
## So nah (Pixel) muss das Gold der Parierstange am Ende der Klinge liegen
GOLD_ABSTAND = 8
## So weit (Pixel) darf der Griff im neuen Bild wandern, um auf das Gold zu kommen
FANG = 12
## Bewegungen ohne Schwert in der Hand (Hand auf der Brust)
OHNE = ["cast"]
## In diesen Bewegungen hängt die Klinge nach unten (Winkel von bis), so fallen Halstuch und Schnallen weg
NACH_UNTEN = {"idle": (80, 200), "run": (70, 200), "hit": (80, 200), "parry": (70, 200), "idle_vorn": (80, 200),
		"run_vorn": (70, 200), "idle_hinten": (100, 200), "run_hinten": (100, 200)}
## In diesen Ansichten ist die Waffenhand das äußerste Gold auf dieser Seite (dort ist vom Griff wenig zu sehen)
HAND_SEITE = {"idle_vorn": -1, "run_vorn": -1, "idle_hinten": 1, "run_hinten": 1}
## Richtung, falls in einer Ansicht keine Klinge zu erkennen ist
ERSATZ = {"idle_hinten": "run_hinten", "run_hinten": "idle_vorn"}
## Stiefel-Schnallen sind auch aus Gold: Das unterste Stück einer stehenden Figur zählt nicht
STIEFEL = 0.72


def ohne_stiefel(maske, a):
	ys, xs = np.where(a[..., 3] > 128)
	if ys.max() - ys.min() >= xs.max() - xs.min():
		maske = maske.copy()
		maske[int(ys.min() + (ys.max() - ys.min()) * STIEFEL):] = False
	return maske


def winkel_von(griff, spitze):
	richtung = spitze - griff
	return float(np.degrees(np.arctan2(richtung[0], -richtung[1]))) % 360


def gold(a):
	r, g, b = (a[..., i].astype(int) for i in range(3))
	return (a[..., 3] > 128) & (r > 175) & (g > 115) & (b < 105) & (r - b > 90) & (g - b > 35)


def schwerpunkt(maske):
	ys, xs = np.where(maske)
	return np.array([xs.mean(), ys.mean()])


def klinge(alt, anim):
	"""Längste helle, farblose und längliche Fläche des alten Bildes mit Gold an einem Ende: (Griff, Spitze) oder None."""
	farbe = alt[..., :3].astype(int)
	hell = (farbe.max(-1) - farbe.min(-1) < 40) & (farbe.min(-1) > 140) & (alt[..., 3] > 128)
	lab, n = ndimage.label(hell, structure=np.ones((3, 3)))
	metall = ohne_stiefel(gold(alt), alt)
	bereich = NACH_UNTEN.get(anim)
	beste = None
	for i in range(1, n + 1):
		ys, xs = np.where(lab == i)
		if len(xs) < 25:
			continue
		p = np.stack([xs, ys], 1).astype(float)
		mitte = p.mean(0)
		werte, vektoren = np.linalg.eigh(np.cov((p - mitte).T))
		achse = vektoren[:, 1]
		wege = (p - mitte) @ achse
		laenge = wege.max() - wege.min()
		if laenge < MIN_LAENGE or laenge / max(1.0, 4 * np.sqrt(max(werte[0], 0.01))) < MIN_FORM:
			continue
		a, b = mitte + achse * wege.min(), mitte + achse * wege.max()
		gy, gx = np.where(metall)
		if not len(gx):
			continue
		naehe = lambda q: np.hypot(gx - q[0], gy - q[1]).min()
		if bereich is not None:
			# Die Richtung steht fest, nur die Spitze nach unten zählt
			if not bereich[0] <= winkel_von(a, b) <= bereich[1]:
				a, b = b, a
			if not bereich[0] <= winkel_von(a, b) <= bereich[1]:
				continue
		elif naehe(a) > naehe(b):
			a, b = b, a
		if naehe(a) <= GOLD_ABSTAND and (beste is None or laenge > beste[0]):
			beste = (laenge, a, b)
	return beste


def main():
	daten = json.loads(DATEN.read_text())
	for koerper in sys.argv[1:] or list(KOERPER):
		eintrag = daten[koerper]
		laengen = []
		for name, reihen in FIGUREN[KOPF_QUELLE].items():
			teil = blatt(koerper, name, REIHEN.get(koerper, {}).get(name, reihen))
			faktor = None
			for anim, bilder in teil.items():
				for n, alt in enumerate(bilder):
					bild = eintrag.get(f"{anim}_f{n}", {})
					bild.pop("griff", None)
					bild.pop("waffe_winkel", None)
					neu = np.array(Image.open(FIGUR / f"{koerper}_{anim}_anim_f{n}.png").convert("RGBA"))
					if anim in OHNE or not gruen(neu).any() or not gruen(alt).any():
						continue
					if faktor is None:
						faktor = np.sqrt(gruen(neu).sum() / gruen(alt).sum())
					klein = np.array(Image.fromarray(alt).resize((round(alt.shape[1] * faktor), round(alt.shape[0] * faktor)), Image.LANCZOS))
					gefunden = klinge(klein, anim)
					if gefunden is None:
						continue
					laenge, griff, spitze = gefunden
					# Ins neue Bild übertragen: Beide richten sich am grünen Oval aus, dann zum nächsten Gold des Griffs
					griff = griff + schwerpunkt(gruen(neu)) - schwerpunkt(gruen(klein))
					gy, gx = np.where(ohne_stiefel(gold(neu), neu))
					if len(gx):
						naechster = np.argmin(np.hypot(gx - griff[0], gy - griff[1]))
						if np.hypot(gx[naechster] - griff[0], gy[naechster] - griff[1]) <= FANG:
							nah = np.hypot(gx - gx[naechster], gy - gy[naechster]) <= 6
							griff = np.array([gx[nah].mean(), gy[nah].mean()])
					laengen.append(laenge)
					winkel = winkel_von(gefunden[1], spitze)
					bild["griff"] = [round(float(griff[0]), 1), round(float(griff[1]), 1)]
					bild["waffe_winkel"] = round(winkel, 1)
		# Lücken: Stehen und Laufen nehmen Richtung und Griff vom Nachbarbild derselben Bewegung
		for anim, seite in HAND_SEITE.items():
			namen = [n for n in eintrag if n.startswith(f"{anim}_f")]
			mit = [n for n in namen if "waffe_winkel" in eintrag[n]]
			if not mit:
				ersatz = [eintrag[n]["waffe_winkel"] for n in eintrag if n.startswith(f"{ERSATZ[anim]}_f") and "waffe_winkel" in eintrag[n]]
				for n in namen:
					eintrag[n]["waffe_winkel"] = round(float(np.median(ersatz)), 1)
			for n in namen:
				bild, nummer = n.rsplit("_f", 1)
				neu = np.array(Image.open(FIGUR / f"{koerper}_{bild}_anim_f{nummer}.png").convert("RGBA"))
				gy, gx = np.where(ohne_stiefel(gold(neu), neu))
				rand = gx.max() if seite > 0 else gx.min()
				nah = np.abs(gx - rand) <= 5
				eintrag[n]["griff"] = [round(float(gx[nah].mean()), 1), round(float(gy[nah].mean()), 1)]
		for anim in NACH_UNTEN:
			namen = [n for n in eintrag if n.startswith(f"{anim}_f")]
			mit = [n for n in namen if "waffe_winkel" in eintrag[n]]
			if not mit:
				continue
			mitte = float(np.median([eintrag[n]["waffe_winkel"] for n in mit]))
			for n in namen:
				bild = eintrag[n]
				if "griff" not in bild or abs(bild.get("waffe_winkel", 999) - mitte) > 25:
					nachbar = min(mit, key=lambda m: abs(int(m.rsplit("_f", 1)[1]) - int(n.rsplit("_f", 1)[1])))
					bild.setdefault("griff", eintrag[nachbar]["griff"])
				bild["waffe_winkel"] = round(mitte, 1)
		eintrag["_waffe"] = "kurzschwert"
		eintrag["_klinge"] = round(float(np.median(laengen)), 1)
		print(f"{koerper}: {len(laengen)} Bilder mit Klinge, Länge {eintrag['_klinge']}")
	DATEN.write_text(json.dumps(daten, ensure_ascii=False, indent="\t", sort_keys=True))


if __name__ == "__main__":
	main()
