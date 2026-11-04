"""Marktstände nachts zu (D20d): Marcos Blatt tools/vorlagen/marktstaende_zu.png (links rot, rechts blau, Auftrag B6e).

Jeder geschlossene Stand wird so groß gemacht wie der offene (gleiche Breite der sichtbaren Fläche) und bekommt denselben
Fußpunkt relativ zu seiner Unterkante, damit er genau auf dem Platz des offenen Stands steht.
Ergebnis: assets/baukasten/objekte/marktstand_rot_zu.png, marktstand_blau_zu.png und die Fußpunkte in
data/baukasten_teile.json.
Aufruf: python3 tools/marktstand_zu.py   (braucht numpy, scipy und Pillow)
"""
import json
import sys
from pathlib import Path

import numpy as np
from PIL import Image

WURZEL = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(WURZEL / "tools"))
from aussehen_bilder import teile  # noqa: E402

OBJEKTE = WURZEL / "assets" / "baukasten" / "objekte"
TEILE = WURZEL / "data" / "baukasten_teile.json"
STAENDE = ["marktstand_rot", "marktstand_blau"]


def rahmen(a):
	ys, xs = np.where(a[..., 3] > 128)
	return xs.min(), ys.min(), xs.max(), ys.max()


def main():
	stuecke = [t for reihe in teile("marktstaende_zu") for t in reihe]
	if len(stuecke) != len(STAENDE):
		raise SystemExit(f"marktstaende_zu: {len(stuecke)} Stände, erwartet {len(STAENDE)}")
	daten = json.loads(TEILE.read_text(encoding="utf-8"))
	for name, stueck in zip(STAENDE, stuecke):
		offen = np.array(Image.open(OBJEKTE / f"{name}.png").convert("RGBA"))
		x0, y0, x1, y1 = rahmen(offen)
		fuss = daten["objekte"][name]["fuss"]
		faktor = (x1 - x0) / (rahmen(stueck)[2] - rahmen(stueck)[0])
		bild = Image.fromarray(stueck)
		bild = bild.resize((round(bild.width * faktor), round(bild.height * faktor)), Image.LANCZOS)
		zx0, _, zx1, zy1 = rahmen(np.array(bild))
		# Fußpunkt: gleicher Abstand zur linken und zur unteren Kante wie beim offenen Stand
		daten["objekte"][f"{name}_zu"]["fuss"] = [round(zx0 + fuss[0] - x0), round(zy1 - (y1 - fuss[1]))]
		bild.save(OBJEKTE / f"{name}_zu.png")
		print(f"{name}_zu: {bild.size}, Fuß {daten['objekte'][f'{name}_zu']['fuss']}")
	TEILE.write_text(json.dumps(daten, ensure_ascii=False, indent="\t"), encoding="utf-8")


if __name__ == "__main__":
	main()
