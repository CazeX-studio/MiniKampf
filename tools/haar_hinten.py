"""Haare von hinten über den Körper legen (Marco, 14.11.2026): Von hinten verschwanden Zopf und lange Haare hinter Halstuch und Rücken.

Für jeden Kopf entsteht aus den Ansichten von hinten ein zweites Bild ohne Haut (kein Hals, keine Ohren):
  assets/teile/koepfe/<kopf>_<hinten_normal|hinten_geneigt|gerade_hinten_normal>_haar.png
Das Spiel (scripts/kampf/figur_teile.gd) legt es nach dem Körper noch einmal genau auf den Kopf, so liegen die Haare
über dem Körper, der Hals bleibt dahinter. Die Hautfarbe wird aus dem Gesicht der Ansicht gerade von vorne genommen, die Haarfarbe aus dem oberen Teil des Kopfes;
jeder Punkt gehört zu der Farbe, der er näher ist. Nur Köpfe mit langen Haaren (bei kurzen verdeckt der Körper ohnehin kein Haar).
Aufruf: python3 tools/haar_hinten.py [kopf …]
"""
import sys
from pathlib import Path

import numpy as np
from PIL import Image
from scipy import ndimage

WURZEL = Path(__file__).resolve().parent.parent
KOEPFE = WURZEL / "assets" / "teile" / "koepfe"
LANGE_HAARE = ["w1", "w2", "w3"]
ANSICHTEN = ["hinten_normal", "hinten_geneigt", "gerade_hinten_normal"]


def hautfarbe(kopf):
	a = np.array(Image.open(KOEPFE / f"{kopf}_gerade_vorn_normal.png").convert("RGBA")).astype(int)
	h, b = a.shape[:2]
	feld = a[int(h * 0.62):int(h * 0.82), int(b * 0.35):int(b * 0.65)].reshape(-1, 4)
	feld = feld[feld[:, 3] > 200, :3]
	hell = feld[feld.sum(1) > np.percentile(feld.sum(1), 40)]
	return np.median(hell, axis=0)


def haarfarbe(a):
	h = a.shape[0]
	feld = a[:int(h * 0.4)].reshape(-1, 4)
	return np.median(feld[feld[:, 3] > 200, :3].astype(int), axis=0)


def main():
	for kopf in sys.argv[1:] or LANGE_HAARE:
		haut = hautfarbe(kopf)
		for ansicht in ANSICHTEN:
			pfad = KOEPFE / f"{kopf}_{ansicht}.png"
			if not pfad.exists():
				continue
			a = np.array(Image.open(pfad).convert("RGBA"))
			farbe = a[..., :3].astype(int)
			haar = haarfarbe(a)
			hautig = (np.abs(farbe - haut).sum(-1) < np.abs(farbe - haar).sum(-1)) & (a[..., 3] > 0) & (farbe.sum(-1) > 150)
			hautig = ndimage.binary_fill_holes(ndimage.binary_closing(hautig, iterations=2)) & (a[..., 3] > 0)
			# Haut-Flecken, die groß genug sind (Hals, Ohren), samt dunklem Rand drumherum weg; einzelne Pixel im Haar bleiben
			flecken, n = ndimage.label(hautig)
			groesse = ndimage.sum(hautig, flecken, range(1, n + 1))
			weg = np.isin(flecken, np.where(groesse >= 12)[0] + 1)
			rand = ndimage.binary_dilation(weg, iterations=2) & (farbe.sum(-1) < 220)
			weg |= rand
			b = a.copy()
			b[weg, 3] = 0
			Image.fromarray(b).save(KOEPFE / f"{kopf}_{ansicht}_haar.png")
			print(f"{kopf}_{ansicht}: Haut {haut.round()}, {int(weg.sum())} Pixel weg")


if __name__ == "__main__":
	main()
