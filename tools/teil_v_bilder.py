"""Schneidet Marcos Bilder V5 und V6 aus Teil V (Playtest 16.11.2026) für das Spiel zu.

- tools/vorlagen/splitter_rindenbaer_welt.png (V5, Bauauftrag P13): 4 Bilder nebeneinander, Splitter-Rindenbär in der
  Welt (Stehen und Brüllen als Schleife). Ergebnis: assets/figuren/splitterbaer_welt_idle_anim_f0..f3.png, so hoch wie
  das Bild aus dem Kampf (die Welt zeigt ihn mit derselben Größe wie bisher).
- tools/vorlagen/knoten_zerstoert.png (V6, Bauauftrag P19): 4 Bilder, der Kristall des Splitter-Knotens zerspringt,
  Bild 4 bleibt liegen. Ergebnis: assets/figuren/knoten_death_anim_f0..f3.png (ersetzt die alte Tod-Bewegung), gleich
  breit wie der Knoten beim Stehen.
Alle vier Bilder eines Blatts werden mit demselben Rahmen ausgeschnitten, damit die Füße an derselben Stelle bleiben.
Aufruf: python3 tools/teil_v_bilder.py   (braucht numpy, scipy und Pillow)
"""
import sys
from pathlib import Path

import numpy as np
from PIL import Image

WURZEL = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(WURZEL / "tools"))
from monster_bilder import freistellen  # noqa: E402

VORLAGEN = WURZEL / "tools" / "vorlagen"
FIGUREN = WURZEL / "assets" / "figuren"


def spalten(blatt, anzahl=4):
	"""Freigestellte Bilder in gleich breiten Spalten, alle mit demselben Rahmen (Vereinigung der Umrisse)."""
	a = freistellen(Image.open(VORLAGEN / blatt))
	b = a.shape[1] / anzahl
	felder = [a[:, round(i * b):round((i + 1) * b)] for i in range(anzahl)]
	breite = min(f.shape[1] for f in felder)
	felder = [f[:, :breite] for f in felder]
	ys, xs = np.where(np.any([f[..., 3] > 40 for f in felder], axis=0))
	return [f[ys.min():ys.max() + 1, xs.min():xs.max() + 1] for f in felder]


def breite_von(t):
	xs = np.where((t[..., 3] > 40).any(0))[0]
	return xs.max() - xs.min() + 1


def speichern(stuecke, name, anim, faktor):
	for alt in FIGUREN.glob(f"{name}_{anim}_anim_f*.png"):
		alt.unlink()
	for n, t in enumerate(stuecke):
		b = Image.fromarray(np.ascontiguousarray(t))
		b = b.resize((round(b.width * faktor), round(b.height * faktor)), Image.LANCZOS)
		b.save(FIGUREN / f"{name}_{anim}_anim_f{n}.png")
	print(f"{name}_{anim}: {len(stuecke)} Bilder, Faktor {faktor:.3f}, {b.size}")


def main():
	# V5: Bär so hoch wie im Kampf
	baer = spalten("splitter_rindenbaer_welt.png")
	kampf_h = Image.open(FIGUREN / "splitterbaer_idle_anim_f0.png").height
	speichern(baer, "splitterbaer_welt", "idle", kampf_h / baer[0].shape[0])
	# V6: Knoten so breit wie beim Stehen (gemessen am ersten Bild, das noch heil ist)
	knoten = spalten("knoten_zerstoert.png")
	steht = np.array(Image.open(FIGUREN / "knoten_idle_anim_f0.png").convert("RGBA"))
	speichern(knoten, "knoten", "death", breite_von(steht) / breite_von(knoten[0]))


if __name__ == "__main__":
	main()
