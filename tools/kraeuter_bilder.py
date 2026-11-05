"""Kräuter zum Sammeln in der Welt (E3f): Marcos Blatt tools/vorlagen/kraeuter_welt.png.

Eine Reihe mit vier Bildern: Silberkraut, Wiesenkraut, dann beide noch einmal im Wind gebogen.
Ergebnis: assets/sammeln/<kraut>_f0.png und _f1.png (kraut = Silberkraut, wiesenkraut = Wiesenkraut), so groß,
dass sie in der Welt etwa 44 Bildpunkte hoch sind (das Spiel zeichnet sie selbst in dieser Größe).
Aufruf: python3 tools/kraeuter_bilder.py   (braucht numpy, scipy und Pillow)
"""
import sys
from pathlib import Path

import numpy as np
from PIL import Image

WURZEL = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(WURZEL / "tools"))
from monster_bilder import freistellen  # noqa: E402

REIHENFOLGE = [("kraut", 0), ("wiesenkraut", 0), ("kraut", 1), ("wiesenkraut", 1)]
## Höhe der fertigen Bilder (doppelt so groß wie in der Welt gezeigt, damit sie scharf bleiben)
HOEHE = 88


def main():
	a = freistellen(Image.open(WURZEL / "tools" / "vorlagen" / "kraeuter_welt.png"))
	breite = a.shape[1] / len(REIHENFOLGE)
	ziel = WURZEL / "assets" / "sammeln"
	ziel.mkdir(exist_ok=True)
	for n, (name, bild_nr) in enumerate(REIHENFOLGE):
		streifen = a[:, round(n * breite):round((n + 1) * breite)]
		ys, xs = np.where(streifen[..., 3] > 20)
		stueck = Image.fromarray(streifen[ys.min():ys.max() + 1, xs.min():xs.max() + 1])
		faktor = HOEHE / stueck.height
		stueck.resize((round(stueck.width * faktor), HOEHE), Image.LANCZOS).save(ziel / f"{name}_f{bild_nr}.png")
		print(f"{name}_f{bild_nr}: {stueck.size}")


if __name__ == "__main__":
	main()
