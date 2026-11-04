"""Hauptfiguren mit eigenen Bildblättern (D20b Ye, D20c Bingo, Marv, Mira, D21 Ysolde, Fenn, Tilda, Esche, Kael).

- tools/vorlagen/haupt_<figur>_welt.png: Reihe 1 Stehen und Laufen schräg von vorne (je 4), Reihe 2 dasselbe schräg von
  hinten, dazu je Figur eine dritte Reihe (siehe FIGUREN): Ye mit offenem Schirm (Parier-Training), Mira krank liegend.
  Ergebnis: assets/figuren/<figur>_<anim>_anim_f<n>.png (idle_vorn, run_vorn, idle_hinten, run_hinten, …).
- tools/vorlagen/haupt_<figur>_portraets.png: fünf Porträts (ruhig, lächelnd, wütend, traurig, überrascht).
  Ergebnis: assets/portraets/<figur>_<stimmung>.png, gezeigt über dem Gesprächsfenster.
- tools/vorlagen/haupt_ye_kampf.png: von der Seite, schaut nach rechts. Reihe 1 Stehen 4, Reihe 2 Angriff mit dem
  Schirm 6 (Treffer im 4. Bild), Reihe 3 Getroffen 1 und Parade mit offenem Schirm 4.
  Ergebnis: assets/figuren/ye_kampf_<anim>_anim_f<n>.png (eigener Name, damit Ye in der Welt die Schräg-Ansichten behält).
Aufruf: python3 tools/hauptfiguren.py [figur …]   (braucht numpy, scipy und Pillow)
"""
import sys
from pathlib import Path

import numpy as np
from PIL import Image

WURZEL = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(WURZEL / "tools"))
from figur_bilder import VORLAGEN, blatt  # noqa: E402
from monster_bilder import ausschneiden, bilder_finden, freistellen, speichern  # noqa: E402

WELT = [[("idle_vorn", 4), ("run_vorn", 4)], [("idle_hinten", 4), ("run_hinten", 4)]]
## Figur -> (Größe im Verhältnis zu den Novizen, zusätzliche Reihen im Welt-Blatt)
FIGUREN = {
	"ye": (1.08, [[("schirm_vorn", 4)]]),
	"bingo": (1.08, []),
	"marv": (1.04, []),
	"mira": (1.0, [[("liegen", 2)]]),
	# Grünwacht (D21)
	"ysolde": (1.06, []),
	"fenn": (1.08, []),
	"tilda": (1.08, []),
	"esche": (1.06, []),
	"kael": (1.06, []),
	# Glutoase (D26)
	"hadrak": (1.12, []),
	"brakkus": (1.1, []),
	"samira": (1.04, []),
	"xavina": (1.04, []),
}
KAMPF = {"ye": [[("idle", 4)], [("attack", 6)], [("hit", 1), ("parry", 4)]]}
STIMMUNGEN = ["ruhig", "laechelnd", "wuetend", "traurig", "ueberrascht"]
## So hoch sind die Porträts (Pixel)
PORTRAET_HOEHE = 200


def bilder(figur, blattname, reihen, name, groesse):
	anims = blatt(f"haupt_{figur}", blattname, reihen)
	groesser = lambda t: np.array(Image.fromarray(t).resize((round(t.shape[1] * groesse), round(t.shape[0] * groesse)), Image.LANCZOS))
	speichern(name, {k: [groesser(t) for t in v] for k, v in anims.items()}, 1.0)


def portraets(figur):
	a = freistellen(Image.open(VORLAGEN / f"haupt_{figur}_portraets.png"))
	ziel, reihen = bilder_finden(a, [])
	if [len(r) for r in reihen] == [len(STIMMUNGEN)]:
		stuecke = [ausschneiden(a, ziel, i) for i, _ in reihen[0]]
	else:
		# Berühren sich die Porträts (z. B. Xavinas Haare), das Blatt in gleich breite Streifen teilen
		print(f"haupt_{figur}_portraets: {[len(r) for r in reihen]} Stücke erkannt, teile in {len(STIMMUNGEN)} gleiche Streifen")
		breite = a.shape[1] / len(STIMMUNGEN)
		stuecke = []
		for n in range(len(STIMMUNGEN)):
			streifen = a[:, round(n * breite):round((n + 1) * breite)]
			ys, xs = np.where(streifen[..., 3] > 20)
			stuecke.append(streifen[ys.min():ys.max() + 1, xs.min():xs.max() + 1])
	ordner = WURZEL / "assets" / "portraets"
	ordner.mkdir(exist_ok=True)
	for stimmung, stueck in zip(STIMMUNGEN, stuecke):
		bild = Image.fromarray(stueck)
		faktor = PORTRAET_HOEHE / bild.height
		bild.resize((round(bild.width * faktor), PORTRAET_HOEHE), Image.LANCZOS).save(ordner / f"{figur}_{stimmung}.png")
	print(f"{figur}: {len(STIMMUNGEN)} Porträts")


def main():
	for figur in sys.argv[1:] or list(FIGUREN):
		groesse, extra = FIGUREN[figur]
		# Achtung: speichern("ye") löscht auch ye_kampf_*, darum zuerst die Welt, dann der Kampf
		bilder(figur, "welt", WELT + extra, figur, groesse)
		if figur in KAMPF:
			bilder(figur, "kampf", KAMPF[figur], f"{figur}_kampf", groesse)
		portraets(figur)


if __name__ == "__main__":
	main()
