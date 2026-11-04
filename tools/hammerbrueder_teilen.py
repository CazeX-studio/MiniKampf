"""Hammerbrüder (D33): Das Bildblatt zeigt beide Brüder zusammen. Für den Kampf braucht jeder ein eigenes Bild.

Jedes Bild von assets/figuren/hammerbrueder_<anim>_anim_f<n>.png wird an der leersten Spalte in der Mitte geteilt:
links der Bruder mit dem Hammer, rechts der mit der Zange. Zusammenhängende Teile (Rauch, Werkzeug) kommen ganz zu dem
Bruder, auf dessen Seite ihr Schwerpunkt liegt; nur was beide berührt, wird an der Spalte geschnitten.
Der gemeinsame Doppelschlag (spezial) zeigt beide am Amboss: Für die Einzelfiguren nimmt das Werkzeug dort die
Angriffsbilder.
Ergebnis: assets/figuren/hammerbruder_hammer_<anim>_anim_f<n>.png und hammerbruder_zange_<anim>_anim_f<n>.png
Aufruf: python3 tools/hammerbrueder_teilen.py   (braucht numpy, scipy und Pillow)
"""
import re
from pathlib import Path

import numpy as np
from PIL import Image
from scipy import ndimage

FIGUREN = Path(__file__).resolve().parent.parent / "assets" / "figuren"


def teilen(a):
	alpha = a[..., 3] > 20
	spalten = alpha.sum(0)
	xs = np.where(spalten > 0)[0]
	x0, w = xs.min(), xs.max() - xs.min()
	schnitt = min(range(int(x0 + w * 0.35), int(x0 + w * 0.65)), key=lambda x: spalten[x])
	marken, anzahl = ndimage.label(alpha)
	teile = [marken == i for i in range(1, anzahl + 1)]
	groesse = max(t.sum() for t in teile)
	# Erst die großen Teile (die Körper): ganz auf eine Seite oder, wenn sie beide berühren, an der Spalte geschnitten
	links = np.zeros(alpha.shape, bool)
	rechts = np.zeros(alpha.shape, bool)
	kleine = []
	# Stehen beide Körper getrennt (zwei große Teile), kommt jeder ganz auf seine Seite, auch wenn ein erhobener
	# Hammer über die Spalte ragt
	getrennt = sum(t.sum() >= groesse * 0.2 for t in teile) >= 2
	for teil in teile:
		xs = np.where(teil)[1]
		if teil.sum() < groesse * 0.2 and (xs.max() < schnitt or xs.min() >= schnitt):
			kleine.append(teil)
		elif teil.sum() < groesse * 0.2 and getrennt:
			kleine.append(teil)
		elif getrennt:
			(links if xs.mean() < schnitt else rechts)[teil] = True
		elif xs.max() < schnitt:
			links |= teil
		elif xs.min() >= schnitt:
			rechts |= teil
		else:
			# An der Spalte schneiden; kleine Stücke jenseits der Spalte (ein Hammerkopf über dem anderen Bruder)
			# bleiben bei dem Körper, aus dem sie herüberragen
			for seite, ziel, anderes in ((np.s_[:, :schnitt], links, rechts), (np.s_[:, schnitt:], rechts, links)):
				stueck = np.zeros(alpha.shape, bool)
				stueck[seite] = teil[seite]
				m, k = ndimage.label(stueck)
				flaechen = [(m == j).sum() for j in range(1, k + 1)]
				for j in range(1, k + 1):
					(ziel if flaechen[j - 1] >= max(flaechen) * 0.3 else anderes)[m == j] = True
	# Kleine Teile (Rauch, ein Hammerkopf in der Luft) gehören zu dem Körper, der am nächsten ist
	abstand_links = ndimage.distance_transform_edt(~links)
	abstand_rechts = ndimage.distance_transform_edt(~rechts)
	for teil in kleine:
		if abstand_links[teil].min() <= abstand_rechts[teil].min():
			links |= teil
	rechts = alpha & ~links
	ergebnis = []
	for maske in (links, rechts):
		bild = a.copy()
		bild[..., 3] = np.where(maske, a[..., 3], 0)
		ys, xs = np.where(maske)
		ergebnis.append(bild[:, max(xs.min() - 4, 0):xs.max() + 5] if len(xs) else bild)
	return ergebnis


def main():
	for alt in FIGUREN.glob("hammerbruder_*_anim_f*.png"):
		alt.unlink()
	quellen = sorted(FIGUREN.glob("hammerbrueder_*_anim_f*.png"))
	for datei in quellen:
		anim, n = re.match(r"hammerbrueder_(\w+)_anim_f(\d+)\.png", datei.name).groups()
		if anim == "spezial":
			continue
		ziele = [anim] + (["spezial"] if anim == "attack" else [])
		links, rechts = teilen(np.array(Image.open(datei).convert("RGBA")))
		for name, bild in (("hammer", links), ("zange", rechts)):
			for z in ziele:
				Image.fromarray(bild).save(FIGUREN / f"hammerbruder_{name}_{z}_anim_f{n}.png")
	print(f"{len(quellen)} Bilder geteilt")


if __name__ == "__main__":
	main()
