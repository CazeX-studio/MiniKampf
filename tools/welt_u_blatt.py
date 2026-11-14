"""Neue Welt-Blätter nach Teil U6 (Novize/Novizin, 14.11.2026) in ein Blatt wie die alten Welt-Blätter umbauen.

Eingang: tools/vorlagen/welt_u/<körper>_gehen_<richtung>.png (2 × 4 Bilder) und <körper>_stehen_sitzen.png (2 × 5 Bilder,
Reihe 1 Stehen, Reihe 2 Sitzen, Richtungen vorne, schräg vorne, Seite, schräg hinten, hinten).
Ausgang: tools/vorlagen/<körper>_welt_u.png mit
  Reihe 1: run_vorn (8 Bilder, schräg von vorne)
  Reihe 2: run_hinten (8 Bilder, schräg von hinten)
  Reihe 3: idle_vorn, idle_hinten, sitzen_vorn, sitzen_hinten (je 1 Bild)
  Reihe 4 bis 6: run_gerade_vorn, run_welt_seite, run_gerade_hinten (je 8 Bilder, seit Teil U7)
  Reihe 7: idle_gerade_vorn, idle_welt_seite, idle_gerade_hinten, sitzen_gerade_vorn, sitzen_welt_seite, sitzen_gerade_hinten
Die neuen Figuren schauen nach links, die alten Körper nach rechts: jedes Bild wird gespiegelt (das Spiel spiegelt ohnehin für die andere Seite).
Das Stehen/Sitzen-Blatt wird auf die Größe der Laufbilder gebracht (Oberkante des grünen Ovals bis zu den Füßen).
Danach: tools/koerper_blatt.py novize_m novize_w und tools/novize_welt2.py alt.json (siehe dort).
Aufruf: python3 tools/welt_u_blatt.py [körper …]
"""
import sys
from pathlib import Path

import numpy as np
from PIL import Image

WURZEL = Path(__file__).resolve().parent.parent
QUELLE = WURZEL / "tools" / "vorlagen" / "welt_u"
ZIEL = WURZEL / "tools" / "vorlagen"
PINK = (255, 0, 255)
## Platz je Bild im neuen Blatt (genug Abstand, damit die Bilder getrennt erkannt werden)
FELD_B, FELD_H = 420, 560


def felder(bild, reihen, spalten):
	"""Ein Blatt im Raster zerlegen, jedes Feld eng um die Figur zugeschnitten (RGB mit pinkem Grund)."""
	a = np.array(bild.convert("RGB")).astype(int)
	h, b = a.shape[0] // reihen, a.shape[1] // spalten
	aus = []
	for r in range(reihen):
		zeile = []
		for s in range(spalten):
			t = a[r * h:(r + 1) * h, s * b:(s + 1) * b]
			figur = ~((t[..., 0] > 170) & (t[..., 2] > 170) & (t[..., 1] < 110))
			ys, xs = np.where(figur)
			zeile.append(t[ys.min():ys.max() + 1, xs.min():xs.max() + 1].astype(np.uint8))
		aus.append(zeile)
	return aus


def oval_bis_fuss(t):
	gruen = (t[..., 1] > t[..., 0] + 60) & (t[..., 1] > t[..., 2] + 60)
	return t.shape[0] - np.where(gruen.any(1))[0].min()


def main():
	for koerper in sys.argv[1:] or ["novize_m", "novize_w"]:
		gehen = {r: felder(Image.open(QUELLE / f"{koerper}_gehen_{r}.png"), 2, 4)
				for r in ["vorne", "schraeg_vorne", "seite", "schraeg_hinten", "hinten"]}
		vorn, hinten = gehen["schraeg_vorne"], gehen["schraeg_hinten"]
		stehen_sitzen = felder(Image.open(QUELLE / f"{koerper}_stehen_sitzen.png"), 2, 5)
		lauf = vorn[0] + vorn[1]
		faktor = np.median([oval_bis_fuss(t) for t in lauf]) / np.median([oval_bis_fuss(stehen_sitzen[0][i]) for i in (1, 3)])
		print(f"{koerper}: Stehen/Sitzen mit Faktor {faktor:.3f}")

		def gross(t):
			bild = Image.fromarray(t)
			return np.array(bild.resize((round(bild.width * faktor), round(bild.height * faktor)), Image.LANCZOS))

		reihen = [lauf, hinten[0] + hinten[1],
				[gross(stehen_sitzen[0][1]), gross(stehen_sitzen[0][3]), gross(stehen_sitzen[1][1]), gross(stehen_sitzen[1][3])]]
		reihen += [gehen[r][0] + gehen[r][1] for r in ["vorne", "seite", "hinten"]]
		reihen.append([gross(stehen_sitzen[z][s]) for z in (0, 1) for s in (0, 2, 4)])
		blatt = Image.new("RGB", (FELD_B * 8, FELD_H * len(reihen)), PINK)
		for r, reihe in enumerate(reihen):
			for s, t in enumerate(reihe):
				bild = Image.fromarray(t).transpose(Image.FLIP_LEFT_RIGHT)
				# Füße unten im Feld, waagrecht in der Mitte
				blatt.paste(bild, (s * FELD_B + (FELD_B - bild.width) // 2, r * FELD_H + FELD_H - 20 - bild.height))
		blatt.save(ZIEL / f"{koerper}_welt_u.png")
		print(f"{koerper}: {ZIEL / f'{koerper}_welt_u.png'}")


if __name__ == "__main__":
	main()
