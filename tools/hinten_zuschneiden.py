"""Schneidet ein Blatt mit Gebäuden VON HINTEN (GRAFIK_AUFTRAG.md Teil J) in einzelne Bilder.

Jedes Teil wird auf die Breite seiner Vorderansicht (assets/baukasten/objekte/<teil>.png) gebracht, damit es
genauso groß ist. Mit „:m“ hinter dem Namen nimmt es den Mittelwert aus Breite und Höhe (für Teile, deren
Vorderansicht durch Schilder oder Vordächer breiter ist). Der Fuß (Mitte der Grundfläche) wird aus der Vorderansicht
übernommen und waagrecht gespiegelt. Schreibt bild_hinten, fuss_hinten und lichter_hinten (leer, wenn nicht anders
angegeben) nach data/baukasten_teile.json.

Aufruf: python tools/hinten_zuschneiden.py <blatt.png> <teil>[:m]=<x>,<y> ...
  x,y: ungefährer Punkt im Blatt, der im Teil liegt.
Danach: Bilder importieren, tools/web_bilder.py, Foto tests/haeuser_hinten_foto.tscn ansehen.
"""
import json
import sys
from pathlib import Path

import numpy as np
from PIL import Image
from scipy import ndimage

WURZEL = Path(__file__).resolve().parent.parent
OBJEKTE = WURZEL / "assets" / "baukasten" / "objekte"
DATEN = WURZEL / "data" / "baukasten_teile.json"


def freistellen(blatt: Image.Image) -> Image.Image:
	"""Gemaltes Karomuster oder Weiß am Rand durchsichtig machen, falls das Blatt keinen echten durchsichtigen Grund hat."""
	a = np.array(blatt.convert("RGBA")).astype(int)
	if (a[:, :, 3] == 0).mean() > 0.2:
		return blatt.convert("RGBA")
	rgb = a[:, :, :3]
	mn = rgb.min(axis=2)
	hell = (mn >= 232) & ((rgb.max(axis=2) - mn) <= 10)
	lab, _ = ndimage.label(hell)
	rand = set(np.unique(np.concatenate([lab[0], lab[-1], lab[:, 0], lab[:, -1]]))) - {0}
	bg = np.isin(lab, list(rand))
	for _ in range(2):
		bg |= ndimage.binary_dilation(bg) & ~bg & (mn >= 200) & ((rgb.max(axis=2) - mn) <= 25)
	a[:, :, 3] = np.where(bg, 0, 255)
	return Image.fromarray(a.astype(np.uint8), "RGBA")


def main() -> None:
	blatt = freistellen(Image.open(sys.argv[1]))
	alpha = np.array(blatt)[:, :, 3] > 20
	lab, n = ndimage.label(ndimage.binary_dilation(alpha, iterations=6))
	stuecke = ndimage.find_objects(lab)
	groesse = ndimage.sum(alpha, lab, range(1, n + 1))
	daten = json.loads(DATEN.read_text(encoding="utf-8"))
	for arg in sys.argv[2:]:
		name, punkt = arg.split("=")
		mittel = name.endswith(":m")
		name = name.removesuffix(":m")
		px, py = (int(v) for v in punkt.split(","))
		nr = lab[py, px]
		if nr == 0:
			# Punkt liegt in einer Lücke: das größte Stück in der Nähe nehmen
			kandidaten = [i for i, s in enumerate(stuecke) if s[0].start - 40 <= py < s[0].stop + 40 and s[1].start - 40 <= px < s[1].stop + 40]
			nr = max(kandidaten, key=lambda i: groesse[i]) + 1
		s = stuecke[nr - 1]
		teil = blatt.crop((s[1].start, s[0].start, s[1].stop, s[0].stop))
		maske = Image.fromarray(((lab[s] == nr) * 255).astype(np.uint8))
		leer = Image.new("RGBA", teil.size, (0, 0, 0, 0))
		teil = Image.composite(teil, leer, maske)
		teil = teil.crop(teil.getbbox())
		vorne = Image.open(OBJEKTE / f"{name}.png")
		vb = vorne.getbbox()
		kb = (vb[2] - vb[0]) / teil.width
		kh = (vb[3] - vb[1]) / teil.height
		k = (kb * kh) ** 0.5 if mittel else kb
		hinten = teil.resize((round(teil.width * k), round(teil.height * k)), Image.LANCZOS)
		hinten.save(OBJEKTE / f"{name}_hinten.png")
		d = daten["objekte"][name]
		fx, fy = d.get("fuss", [vorne.width / 2, vorne.height - 8 * sum(d.get("flaeche", [1, 1]))])
		unten = (vb[3] - fy) * k / kb
		fuss = [round(hinten.width - (fx - vb[0]) * k / kb), round(hinten.height - unten)]
		d["bild_hinten"] = f"objekte/{name}_hinten.png"
		d["fuss_hinten"] = fuss
		d.setdefault("lichter_hinten", [])
		print(f"{name}: {hinten.size} (vorne {vorne.size}), Maßstab Breite {kb:.3f} Höhe {kh:.3f}, fuss_hinten {fuss}")
	DATEN.write_text(json.dumps(daten, ensure_ascii=False, indent="\t") + "\n", encoding="utf-8", newline="\n")


if __name__ == "__main__":
	main()
