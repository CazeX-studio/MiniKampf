"""Übersicht für Marco vor dem Einbauen (Teil U10): Körper aus tools/vorlagen/<körper>_welt_u.png in fünf Richtungen,
so ausgerichtet wie im Spiel (gespiegelt wie die Novizen), Stehen, Laufen (Bild 3) und Sitzen. Darunter ein Vergleichskörper.
Aufruf: python3 tools/welt_u_uebersicht.py <körper> [vergleich]   (Standard-Vergleich: novize_m bzw. novize_w)
Ergebnis: tools/referenz/teil_u/uebersicht_<körper>.png
"""
import sys
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFont

W = Path(__file__).resolve().parent.parent
FB, FH = 420, 560  # wie in tools/welt_u_blatt.py
RICHT = ["1: gerade nach unten", "2: nach unten rechts", "3: nach rechts", "4: nach oben rechts", "5: gerade nach oben"]
## (Reihe, Platz) im Blatt je Richtung
POS = {"steht": [(6, 0), (2, 0), (6, 1), (2, 1), (6, 2)], "läuft": [(3, 2), (0, 2), (4, 2), (1, 2), (5, 2)],
		"sitzt": [(6, 3), (2, 2), (6, 4), (2, 3), (6, 5)]}


def feld(bl, r, s):
	a = np.array(bl.crop((s * FB, r * FH, (s + 1) * FB, (r + 1) * FH)).convert("RGB")).astype(int)
	m = (a[..., 0] > 170) & (a[..., 2] > 170) & (a[..., 1] < 110)
	im = Image.fromarray(np.dstack([a, np.where(m, 0, 255)]).astype(np.uint8), "RGBA")
	return im.crop(im.getbbox())


def main():
	koerper = sys.argv[1]
	vergleich = sys.argv[2] if len(sys.argv) > 2 else ("novize_w" if koerper.endswith("_w") else "novize_m")
	f = ImageFont.truetype("arial.ttf", 20); fk = ImageFont.truetype("arial.ttf", 24)
	zeilen = []
	for k in [koerper, vergleich]:
		bl = Image.open(W / "tools" / "vorlagen" / f"{k}_welt_u.png")
		for a in POS:
			zeilen.append((f"{k}\n{a}", [feld(bl, r, s) for r, s in POS[a]]))
	zw, zh, lw = 250, 280, 190
	img = Image.new("RGB", (lw + zw * 5, 80 + zh * len(zeilen)), (225, 225, 225)); d = ImageDraw.Draw(img)
	d.text((10, 8), f"{koerper}: Körper ohne Kopf, Blick so wie im Spiel; unten {vergleich} zum Vergleich", font=fk, fill=(0, 0, 0))
	for i, t in enumerate(RICHT):
		d.text((lw + i * zw + 10, 45), t, font=f, fill=(0, 0, 120))
	for r, (name, bilder) in enumerate(zeilen):
		y = 80 + r * zh
		if r == 3:
			d.line((0, y - 2, img.width, y - 2), fill=(0, 0, 0), width=3)
		d.multiline_text((10, y + zh // 2 - 20), name, font=fk, fill=(0, 0, 0))
		for i, b in enumerate(bilder):
			s = min((zh - 20) / b.height, (zw - 10) / b.width)
			b = b.resize((round(b.width * s), round(b.height * s)), Image.LANCZOS)
			img.paste(b, (lw + i * zw + (zw - b.width) // 2, y + zh - 10 - b.height), b)
	aus = W / "tools" / "referenz" / "teil_u" / f"uebersicht_{koerper}.png"
	img.save(aus)
	print(aus)


if __name__ == "__main__":
	main()
