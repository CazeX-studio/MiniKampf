"""Nebenfiguren von Kreuzweg nach Steckbrief (D20c): eigene Köpfe auf den Baukasten-Körpern, dazu Porträts.

Blätter tools/vorlagen/neben_<figur>.png (Auftrag GRAFIK_AUFTRAG.md Teil D „Figuren 4“): Reihe 1 Kopf schräg von vorne
und schräg von hinten, Reihe 2 Porträts (Stimmungen je Figur, siehe FIGUREN), Reihe 3 Zubehör (kommt später).
Ergebnis: assets/teile/koepfe/<figur>_<richtung>_normal.png, Eintrag in data/figurteile.json beim Körper (_koepfe) und
assets/portraets/<sprecher>_<stimmung>.png (Sprecher = Name im Gespräch, klein geschrieben).
Aufruf: python3 tools/nebenfiguren.py   (braucht numpy, scipy und Pillow; nach tools/baukasten_figuren.py)
"""
import json
import sys
from pathlib import Path

import numpy as np
from PIL import Image

WURZEL = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(WURZEL / "tools"))
from figur_bilder import VORLAGEN  # noqa: E402
from kopf_koerper import hals, verkleinern  # noqa: E402
from monster_bilder import ausschneiden, bilder_finden, freistellen  # noqa: E402

TEILE = WURZEL / "assets" / "teile"
FIGURTEILE = WURZEL / "data" / "figurteile.json"
PORTRAETS = WURZEL / "assets" / "portraets"
## So hoch sind die Porträts (Pixel), wie bei Ye
PORTRAET_HOEHE = 200

## Figur -> (Körper, Name, Geschlecht, Stimmungen der Porträts von links nach rechts)
FIGUREN = {
	"lene": ("grund_gelehrter", "Schreiberin Lene", "w", ["ruhig", "laechelnd", "ueberrascht"]),
	"hanne": ("grund_frau", "Wirtin Hanne", "w", ["laechelnd", "ueberrascht", "wuetend"]),
	"ilse": ("grund_alter_mensch", "Bankhüterin Ilse", "w", ["ruhig", "laechelnd"]),
	"edmar": ("grund_mann", "Vogt Edmar", "m", ["laechelnd", "ueberrascht", "traurig"]),
	"brom": ("grund_wache", "Torwache Brom", "m", ["ruhig", "ueberrascht"]),
	"quill": ("grund_handwerker", "Steinmetz Quill", "m", ["ruhig", "traurig"]),
	"pip": ("grund_kind", "Pip", "m", ["laechelnd", "wuetend", "ueberrascht"]),
	"lotte": ("grund_kind", "Lotte", "w", ["laechelnd", "wuetend", "ueberrascht"]),
}

## Köpfe, die im Blatt größer gezeichnet sind als die anderen (Lenes Dutt und Brille): so viel kleiner machen
KLEINER = {"lene": 0.82}


def hoehe(t):
	return float(np.ptp(np.where((t[..., 3] > 128).any(1))[0]))


def hals_hinten(hinten, vorn):
	"""Von hinten ist kaum Haut zu sehen (Haare, Kragen): Der Hals liegt so weit über der Unterkante wie von vorne,
	waagerecht in der Mitte des Kopfes auf dieser Höhe."""
	y_vorn = hals(vorn)[1]
	unten_vorn = np.where((vorn[..., 3] > 128).any(1))[0].max()
	fest = hinten[..., 3] > 128
	y = int(np.where(fest.any(1))[0].max() - (unten_vorn - y_vorn))
	xs = np.where(fest[max(0, y - 8):y + 1].any(0))[0]
	return [round(float(xs.mean()), 1), y]


def main():
	daten = json.loads(FIGURTEILE.read_text())
	blaetter = {}
	for figur, (_, _, _, stimmungen) in FIGUREN.items():
		a = freistellen(Image.open(VORLAGEN / f"neben_{figur}.png"))
		ziel, reihen = bilder_finden(a, [])
		if [len(r) for r in reihen[:2]] != [2, len(stimmungen)]:
			raise SystemExit(f"neben_{figur}: Reihen {[len(r) for r in reihen]}, erwartet [2, {len(stimmungen)}, …]")
		blaetter[figur] = (a, ziel, reihen)
	# Ein Maßstab für alle Blätter (gleich groß gezeichnet): mittlere Kopfhöhe von vorne wie ein Volks-Kopf.
	# Einzelne Frisuren (Dutt, Krone) bleiben so größer, statt das Gesicht zu verkleinern.
	volk = np.array(Image.open(TEILE / "koepfe" / "v_m1_vorn_normal.png").convert("RGBA"))
	gezeichnet = np.median([hoehe(ausschneiden(a, z, r[0][0][0])) for a, z, r in blaetter.values()])
	faktor = hoehe(volk) / gezeichnet
	PORTRAETS.mkdir(exist_ok=True)
	for figur, (koerper, name, geschlecht, stimmungen) in FIGUREN.items():
		a, ziel, reihen = blaetter[figur]
		vorn, hinten = [verkleinern(ausschneiden(a, ziel, i), faktor * KLEINER.get(figur, 1.0)) for i, _ in reihen[0]]
		Image.fromarray(vorn).save(TEILE / "koepfe" / f"{figur}_vorn_normal.png")
		Image.fromarray(hinten).save(TEILE / "koepfe" / f"{figur}_hinten_normal.png")
		punkte = {"vorn_normal": hals(vorn), "hinten_normal": hals_hinten(hinten, vorn)}
		daten[koerper]["_koepfe"][figur] = {"name": name, "geschlecht": geschlecht, "hals": punkte}
		for stimmung, (i, _) in zip(stimmungen, reihen[1]):
			bild = Image.fromarray(ausschneiden(a, ziel, i))
			f = PORTRAET_HOEHE / bild.height
			bild.resize((round(bild.width * f), PORTRAET_HOEHE), Image.LANCZOS).save(PORTRAETS / f"{figur}_{stimmung}.png")
	FIGURTEILE.write_text(json.dumps(daten, ensure_ascii=False, indent="\t", sort_keys=True))
	print(f"{len(FIGUREN)} Nebenfiguren, Faktor {faktor:.3f}")


if __name__ == "__main__":
	main()
