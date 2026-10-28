"""Zerlegt die drei Blätter einer spielbaren Figur (z. B. Kofi) in Einzelbilder für Welt und Kampf.

Blätter in tools/vorlagen/ (Aufträge in Spieldesign/GRAFIK_AUFTRAG.md, „Spielbare Figuren“):
- <figur>_welt.png: Stehen und Laufen schräg nach vorne, Stehen und Laufen schräg nach hinten
- <figur>_kampf_a.png: Stehen, Laufen, Getroffen, Parade (seitlich, schaut nach rechts)
- <figur>_kampf_b.png: Angriff (Treffer im 4. Bild), Fallen, Sieg, Fähigkeit wirken
Die Reihen werden erkannt (pinker oder durchsichtiger Hintergrund), an den Füßen ausgerichtet und in dreifacher
Auflösung gespeichert wie Vega (das Spiel verkleinert weich). Ergebnis: assets/figuren/<figur>_<anim>_anim_f<n>.png
Aufruf: python3 tools/figur_bilder.py [figur …]   (braucht numpy, scipy und Pillow)
"""
import sys
from pathlib import Path

import numpy as np
from PIL import Image

WURZEL = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(WURZEL / "tools"))
from monster_bilder import bilder_finden, ausschneiden, freistellen, fuss, speichern  # noqa: E402

VORLAGEN = WURZEL / "tools" / "vorlagen"
## So hoch steht eine Figur im Stehen (Pixel) mal 3, wie Vega
ZIEL_HOEHE = 42 * 3

# Figur -> Blatt -> Reihen von oben nach unten: Liste von (Animation, Anzahl Bilder); mehrere Einträge = eine Reihe
# wird der Reihe nach auf mehrere Animationen verteilt. Das erste Blatt mit "idle" gibt die Größe vor.
FIGUREN = {
	"kofi": {
		"kampf_a": [[("idle", 4)], [("run", 4)], [("hit", 1), ("parry", 4)]],
		"kampf_b": [[("attack", 6)], [("death", 6)], [("victory", 4), ("cast", 4)]],
		"welt": [[("idle_vorn", 4), ("run_vorn", 4)], [("idle_hinten", 4), ("run_hinten", 4)]],
	},
}


def blatt(figur, name, reihen):
	"""Animationen eines Blatts, jedes Bild schon auf ZIEL_HOEHE gebracht (gemessen am ersten Bild der ersten Reihe)."""
	a = freistellen(Image.open(VORLAGEN / f"{figur}_{name}.png"))
	ziel, gefunden = bilder_finden(a, [])
	erwartet = [sum(n for _, n in r) for r in reihen]
	if [len(r) for r in gefunden] != erwartet:
		raise SystemExit(f"{figur}_{name}: Reihen {[len(r) for r in gefunden]}, erwartet {erwartet}")
	stuecke_reihen = [[ausschneiden(a, ziel, i) for i, _ in r] for r in gefunden]
	# Größe: Stehen der ersten Reihe
	stehen = np.median([fuss(t, False)[2] for t in stuecke_reihen[0][:reihen[0][0][1]]])
	faktor = ZIEL_HOEHE / stehen
	anims = {}
	for spec, stuecke in zip(reihen, stuecke_reihen):
		pos = 0
		for anim, n in spec:
			bilder = []
			for t in stuecke[pos:pos + n]:
				bild = Image.fromarray(t)
				bild = bild.resize((max(1, round(bild.width * faktor)), max(1, round(bild.height * faktor))), Image.LANCZOS)
				bilder.append(np.array(bild))
			anims[anim] = bilder
			pos += n
	return anims


def main():
	for figur in sys.argv[1:] or list(FIGUREN):
		anims = {}
		for name, reihen in FIGUREN[figur].items():
			anims.update(blatt(figur, name, reihen))
		speichern(figur, anims, 1.0)


if __name__ == "__main__":
	main()
