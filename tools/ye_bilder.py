"""Ausbilder Ye mit Regenschirm (D20b).

- tools/vorlagen/haupt_ye_welt.png: Reihe 1 Stehen und Laufen schräg von vorne (je 4, Schirm zu), Reihe 2 dasselbe
  schräg von hinten, Reihe 3 Stehen schräg von vorne mit offenem Schirm (Parier-Training).
  Ergebnis: assets/figuren/ye_<anim>_anim_f<n>.png (idle_vorn, run_vorn, idle_hinten, run_hinten, schirm_vorn).
- tools/vorlagen/haupt_ye_portraets.png: fünf Porträts (ruhig, lächelnd, wütend, traurig, überrascht).
  Ergebnis: assets/portraets/ye_<stimmung>.png, gezeigt neben dem Gesprächsfenster.
- tools/vorlagen/haupt_ye_kampf.png: von der Seite, schaut nach rechts. Reihe 1 Stehen 4, Reihe 2 Angriff mit dem
  Schirm 6 (Treffer im 4. Bild), Reihe 3 Getroffen 1 und Parade mit offenem Schirm 4.
  Ergebnis: assets/figuren/ye_kampf_<anim>_anim_f<n>.png (eigener Name, damit Ye in der Welt die Schräg-Ansichten behält).
Aufruf: python3 tools/ye_bilder.py   (braucht numpy, scipy und Pillow)
"""
import sys
from pathlib import Path

import numpy as np
from PIL import Image

WURZEL = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(WURZEL / "tools"))
from figur_bilder import VORLAGEN, blatt  # noqa: E402
from monster_bilder import ausschneiden, bilder_finden, freistellen, speichern  # noqa: E402

KAMPF = [[("idle", 4)], [("attack", 6)], [("hit", 1), ("parry", 4)]]
REIHEN = [[("idle_vorn", 4), ("run_vorn", 4)], [("idle_hinten", 4), ("run_hinten", 4)], [("schirm_vorn", 4)]]
STIMMUNGEN = ["ruhig", "laechelnd", "wuetend", "traurig", "ueberrascht"]
## Ye ist ein Erwachsener: etwas größer als die Novizen
GROESSE = 1.08
## So hoch sind die Porträts (Pixel)
PORTRAET_HOEHE = 200


def welt(blattname="welt", reihen=REIHEN, name="ye"):
	# Achtung: speichern("ye") löscht auch ye_kampf_*, darum zuerst die Welt, dann der Kampf (siehe unten)
	anims = blatt("haupt_ye", blattname, reihen)
	groesser = lambda t: np.array(Image.fromarray(t).resize((round(t.shape[1] * GROESSE), round(t.shape[0] * GROESSE)), Image.LANCZOS))
	anims = {k: [groesser(t) for t in v] for k, v in anims.items()}
	speichern(name, anims, 1.0)


def portraets():
	a = freistellen(Image.open(VORLAGEN / "haupt_ye_portraets.png"))
	ziel, reihen = bilder_finden(a, [])
	if [len(r) for r in reihen] != [len(STIMMUNGEN)]:
		raise SystemExit(f"haupt_ye_portraets: Reihen {[len(r) for r in reihen]}, erwartet [{len(STIMMUNGEN)}]")
	ordner = WURZEL / "assets" / "portraets"
	ordner.mkdir(exist_ok=True)
	for stimmung, (i, _) in zip(STIMMUNGEN, reihen[0]):
		bild = Image.fromarray(ausschneiden(a, ziel, i))
		faktor = PORTRAET_HOEHE / bild.height
		bild.resize((round(bild.width * faktor), PORTRAET_HOEHE), Image.LANCZOS).save(ordner / f"ye_{stimmung}.png")
	print(f"Ye: {len(STIMMUNGEN)} Porträts")


if __name__ == "__main__":
	welt()
	welt("kampf", KAMPF, "ye_kampf")
	portraets()
