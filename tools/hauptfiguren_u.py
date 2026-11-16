"""Hauptfiguren mit den sechs neuen Welt-Blättern (GRAFIK_AUFTRAG.md Teil U2b, 16.11.2026) ins Spiel bringen.

Eingang: tools/vorlagen/welt_u/<figur>_gehen_<richtung>.png (2 × 4 Bilder, Richtungen vorne, schraeg_vorne, seite,
schraeg_hinten, hinten) und <figur>_stehen_sitzen.png (2 × 5 Bilder: Reihe 1 Stehen, Reihe 2 Sitzen, je vorne, schräg
vorne, Seite, schräg hinten, hinten). Anders als bei den Klassen hat die Figur ihren echten Kopf (kein grünes Oval),
sie bleibt ein ganzes Bild.
Ausgang: assets/figuren/<figur>_<anim>_anim_f<n>.png für die Welt in fünf Richtungen:
  run_vorn, run_hinten, run_gerade_vorn, run_welt_seite, run_gerade_hinten (je 8 Bilder),
  idle_… und sitzen_… in denselben fünf Richtungen (je 1 Bild).
Die Bilder werden gespiegelt (gemalt nach links, das Spiel erwartet nach rechts) und so verkleinert, dass die Figur im
Stehen schräg von vorne so hoch ist wie ihr altes Bild (das Maß wird beim ersten Lauf gesichert).
Kampf-Bilder (<figur>_kampf_…) und Porträts bleiben, wie sie sind.
Aufruf: python3 tools/hauptfiguren_u.py [figur …]
"""
import sys
from pathlib import Path

import numpy as np
from PIL import Image

WURZEL = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(WURZEL / "tools"))
from monster_bilder import freistellen, fuss  # noqa: E402
from welt_u_blatt import felder  # noqa: E402

QUELLE = WURZEL / "tools" / "vorlagen" / "welt_u"
ZIEL = WURZEL / "assets" / "figuren"
## Richtung im Blatt -> Endung im Spiel
GEHEN = {"schraeg_vorne": "_vorn", "schraeg_hinten": "_hinten", "vorne": "_gerade_vorn", "seite": "_welt_seite",
		"hinten": "_gerade_hinten"}
## Platz im Stehen/Sitzen-Blatt -> Endung
STEHEN = ["_gerade_vorn", "_vorn", "_welt_seite", "_hinten", "_gerade_hinten"]


def hoehe(t):
	return t.shape[0]


def alpha(t):
	"""Feld mit pinkem Grund -> RGBA, Pink durchsichtig, gespiegelt."""
	# Rand aus Pink, damit freistellen den Grund erkennt (felder schneidet eng um die Figur)
	rand = np.stack([np.pad(t[..., k], 4, constant_values=v) for k, v in enumerate((255, 0, 255))], -1)
	a = freistellen(Image.fromarray(rand.astype(np.uint8)))
	return np.ascontiguousarray(a[:, ::-1])


def anpassen(t, faktor):
	b = Image.fromarray(t)
	return np.array(b.resize((max(1, round(b.width * faktor)), max(1, round(b.height * faktor))), Image.LANCZOS))


def speichern(figur, anim, stuecke):
	for alt in ZIEL.glob(f"{figur}_{anim}_anim_f*.png"):
		alt.unlink()
	messung = [fuss(t, False) for t in stuecke]
	links = max(m[0] for m in messung)
	rechts = max(t.shape[1] - m[0] for t, m in zip(stuecke, messung))
	h = max(m[1] for m in messung) + 1
	b = int(2 * max(links, rechts)) + 2
	for n, (t, (fx, unten, _)) in enumerate(zip(stuecke, messung)):
		leinwand = Image.new("RGBA", (b, h), (0, 0, 0, 0))
		leinwand.alpha_composite(Image.fromarray(t), (int(round(b / 2 - fx)), int(h - 1 - unten)))
		leinwand.save(ZIEL / f"{figur}_{anim}_anim_f{n}.png")


def main():
	main_fuer(sys.argv[1:] or ["kael"])


def main_fuer(figuren):
	for figur in figuren:
		mass_datei = QUELLE / f"{figur}_alt_idle_vorn.png"
		if not mass_datei.exists():
			mass_datei.write_bytes((ZIEL / f"{figur}_idle_vorn_anim_f0.png").read_bytes())
		alt = np.array(Image.open(mass_datei).convert("RGBA"))
		alt_h = fuss(alt, False)[2] + 1
		stehen_sitzen = [[alpha(t) for t in reihe] for reihe in felder(Image.open(QUELLE / f"{figur}_stehen_sitzen.png"), 2, 5)]
		gehen = {r: [alpha(t) for reihe in felder(Image.open(QUELLE / f"{figur}_gehen_{r}.png"), 2, 4) for t in reihe] for r in GEHEN}
		# Stehen/Sitzen ist oft kleiner gemalt als das Gehen: auf die Höhe der Laufbilder schräg von vorne bringen
		lauf_h = np.median([fuss(t, False)[2] for t in gehen["schraeg_vorne"]])
		steh_faktor = lauf_h / fuss(stehen_sitzen[0][1], False)[2]
		faktor = alt_h / lauf_h
		print(f"{figur}: Faktor {faktor:.3f}, Stehen/Sitzen zusätzlich {steh_faktor:.3f}")
		for r, endung in GEHEN.items():
			speichern(figur, "run" + endung, [anpassen(t, faktor) for t in gehen[r]])
		for i, endung in enumerate(STEHEN):
			speichern(figur, "idle" + endung, [anpassen(stehen_sitzen[0][i], faktor * steh_faktor)])
			speichern(figur, "sitzen" + endung, [anpassen(stehen_sitzen[1][i], faktor * steh_faktor)])


if __name__ == "__main__":
	main()
