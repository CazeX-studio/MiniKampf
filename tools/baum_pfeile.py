"""Schneidet Marcos Blatt mit Pfeilen und Rahmen für den Fähigkeitenbaum (tools/vorlagen/faehigkeiten_baum_pfeile.png,
Auftrag V4, Bauauftrag P12).

Reihe 1 Pfeile gold, Reihe 2 dieselben grau: gerades Stück senkrecht, Spitze nach unten, gerades Stück waagerecht,
Ecke von links nach unten, Ecke von rechts nach unten, Spitze nach rechts. Reihe 3: Rahmen gelernt, lernbar, gesperrt
und das runde Stufen-Schild.
Die geraden Stücke werden auf ihre Mitte gekürzt (ohne Umriss an den Enden), damit sie sich beliebig strecken lassen;
die Ecken werden kurz um den Knick geschnitten (Arme je ECKE Rohrbreiten), die Spitzen auf Spitze und ein kurzes
Stück Schaft.
Ergebnis: assets/ui/baum_<teil>_<gold|grau>.png und assets/ui/baum_rahmen_<art>.png, baum_stufe.png.
Aufruf: python3 tools/baum_pfeile.py   (braucht numpy, scipy und Pillow)
"""
import sys
from pathlib import Path

import numpy as np
from PIL import Image
from scipy import ndimage

WURZEL = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(WURZEL / "tools"))
from monster_bilder import freistellen  # noqa: E402

ZIEL = WURZEL / "assets" / "ui"
PFEILE = ["senkrecht", "spitze_unten", "waagerecht", "ecke_links", "ecke_rechts", "spitze_rechts"]
RAHMEN = ["rahmen_gelernt", "rahmen_lernbar", "rahmen_gesperrt", "stufe"]
## Breite der Pfeile im Blatt (Pixel, mit Umriss)
ROHR = 54
## So lang bleiben die Arme der Ecken (in Rohrbreiten ab der Mitte des Knicks); das Spiel rechnet mit demselben Wert
ECKE = 1.2
## Alles auf die Hälfte verkleinern (das Spiel zeigt es noch kleiner)
FAKTOR = 0.5


def teile(a):
	lab, _ = ndimage.label(a[..., 3] > 40)
	stuecke = []
	for s in ndimage.find_objects(lab):
		if (lab[s] > 0).sum() > 500:
			stuecke.append((s[0].start, s[0].stop, s[1].start, s[1].stop))
	# nach Reihen (grob) und dann von links nach rechts
	stuecke.sort(key=lambda t: (round((t[0] + t[1]) / 2 / (a.shape[0] / 3) - 0.5), t[2]))
	return stuecke


def speichern(t, name):
	b = Image.fromarray(np.ascontiguousarray(t))
	b.resize((max(1, round(b.width * FAKTOR)), max(1, round(b.height * FAKTOR))), Image.LANCZOS).save(ZIEL / f"baum_{name}.png")
	print(f"baum_{name}.png {b.size}")


def main():
	a = freistellen(Image.open(WURZEL / "tools" / "vorlagen" / "faehigkeiten_baum_pfeile.png"))
	stuecke = teile(a)
	if len(stuecke) != 16:
		raise SystemExit(f"{len(stuecke)} Teile gefunden, erwartet 16")
	for reihe, farbe in enumerate(["gold", "grau"]):
		for i, name in enumerate(PFEILE):
			y0, y1, x0, x1 = stuecke[reihe * 6 + i]
			t = a[y0:y1, x0:x1]
			h, w = t.shape[:2]
			if name == "senkrecht":
				t = t[round(h * 0.3):round(h * 0.7)]
			elif name == "waagerecht":
				t = t[:, round(w * 0.3):round(w * 0.7)]
			elif name == "spitze_unten":
				# nur die Spitze mit einem kurzen Stück Schaft
				breit = np.where((t[..., 3] > 40).sum(1) > ROHR * 1.5)[0]
				t = t[max(0, breit[0] - round(ROHR * 0.3)):]
			elif name == "spitze_rechts":
				breit = np.where((t[..., 3] > 40).sum(0) > ROHR * 1.5)[0]
				t = t[:, max(0, breit[0] - round(ROHR * 0.3)):]
			elif name == "ecke_links":
				# Knick oben rechts: Mitte des Rohrs bei (w - ROHR/2, ROHR/2), Arme je ECKE Rohrbreiten lang
				vx, vy = w - ROHR / 2, ROHR / 2
				t = t[:round(vy + ECKE * ROHR), round(vx - ECKE * ROHR):]
			elif name == "ecke_rechts":
				vx, vy = ROHR / 2, ROHR / 2
				t = t[:round(vy + ECKE * ROHR), :round(vx + ECKE * ROHR)]
			speichern(t, f"{name}_{farbe}")
	for i, name in enumerate(RAHMEN):
		y0, y1, x0, x1 = stuecke[12 + i]
		speichern(a[y0:y1, x0:x1], name)


if __name__ == "__main__":
	main()
