"""Schneidet Marcos Blatt mit den Werte-Symbolen (tools/vorlagen/werte_symbole.png, Auftrag V1, Bauauftrag P6).

Das Blatt hat 3 Reihen mit je 4 Symbolen auf pinkem Hintergrund. Jedes Feld wird freigestellt, auf das Symbol
zugeschnitten, quadratisch gemacht und auf 64 × 64 Pixel verkleinert.
Ergebnis: assets/ui/wert_<name>.png. Gibt es ein Bild, nimmt das Spiel es statt des Platzhalters (UiStil.wert_symbol).
Aufruf: python3 tools/werte_symbole.py [blatt.png]   (braucht numpy, scipy und Pillow)
"""
import sys
from pathlib import Path

import numpy as np
from PIL import Image

WURZEL = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(WURZEL / "tools"))
from monster_bilder import freistellen  # noqa: E402

ZIEL = WURZEL / "assets" / "ui"
GROESSE = 64
# Reihenfolge wie im Auftrag V1 (gleich wie UiStil.WERTE)
NAMEN = [
	["leben", "mana", "angriff", "waffenkraft"],
	["zauberkraft", "verteidigung", "widerstand", "tempo"],
	["krit", "ausweichen", "stufe", "erfahrung"],
]


def main():
	blatt = Path(sys.argv[1]) if len(sys.argv) > 1 else WURZEL / "tools" / "vorlagen" / "werte_symbole.png"
	if not blatt.exists():
		raise SystemExit(f"{blatt} fehlt noch")
	a = freistellen(Image.open(blatt))
	hoehe, breite = a.shape[:2]
	ZIEL.mkdir(parents=True, exist_ok=True)
	for r, reihe in enumerate(NAMEN):
		for s, name in enumerate(reihe):
			feld = a[r * hoehe // 3:(r + 1) * hoehe // 3, s * breite // 4:(s + 1) * breite // 4]
			ys, xs = np.where(feld[..., 3] > 40)
			if len(ys) == 0:
				raise SystemExit(f"Kein Symbol in Reihe {r + 1}, Platz {s + 1} ({name})")
			teil = feld[ys.min():ys.max() + 1, xs.min():xs.max() + 1]
			seite = max(teil.shape[:2]) + 4
			quadrat = Image.new("RGBA", (seite, seite), (0, 0, 0, 0))
			quadrat.alpha_composite(Image.fromarray(teil), ((seite - teil.shape[1]) // 2, (seite - teil.shape[0]) // 2))
			quadrat.resize((GROESSE, GROESSE), Image.LANCZOS).save(ZIEL / f"wert_{name}.png")
			print(f"wert_{name}.png")


if __name__ == "__main__":
	main()
