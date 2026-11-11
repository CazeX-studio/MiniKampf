"""Schneidet die Blätter mit den Fähigkeits-Bildern (tools/vorlagen/faehigkeiten_<klasse>.png) in einzelne Bilder (A8a).

Gleiches Verfahren wie bei den Gegenständen (tools/gegenstand_bilder.py): pinker Hintergrund, jedes Bild freigestellt und
quadratisch zugeschnitten, hier 128 × 128 Pixel. Ergebnis: assets/faehigkeiten/<klasse>_<fähigkeit>.png, Kennungen wie in
data/faehigkeiten.json („_grund“ = Grundreihe). Die Bildaufträge stehen in Spieldesign/GRAFIK_AUFTRAG.md Teil L (Demo-Klassen) und Teil R (die sechs späteren).
Aufruf: python3 tools/faehigkeit_bilder.py [klasse …]   (ohne Angabe alle, deren Blatt schon da ist)
"""
import sys
from pathlib import Path

import numpy as np
from PIL import Image

WURZEL = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(WURZEL / "tools"))
import gegenstand_bilder as gb  # noqa: E402

# Reihen von oben nach unten, je von links nach rechts (wie im Prompt)
BLAETTER = {
	"archer": [
		[
			"_grund",
			"shot",
			"charge",
			"ruhige_hand"
		],
		[
			"net",
			"volley",
			"adlerauge",
			"rapid"
		],
		[
			"durchschlag",
			"jagdinstinkt",
			"schwachstelle",
			"elementpfeil"
		]
	],
	"tamer": [
		[
			"_grund",
			"sling",
			"switch",
			"cheer"
		],
		[
			"band",
			"care",
			"lockfutter",
			"rudelinstinkt"
		],
		[
			"gemeinsam",
			"wachstum",
			"auftritt",
			"einschuechtern"
		],
		[
			"zweites_leben"
		]
	],
	"smith": [
		[
			"_grund",
			"hammer",
			"reinforce",
			"gehaertet"
		],
		[
			"anvil",
			"abfangen",
			"meisterhand",
			"haerten"
		],
		[
			"gluehend",
			"funkenflug",
			"ambossschlag",
			"gemeinsame_haerte"
		]
	],
	"blade": [
		[
			"_grund",
			"step",
			"storm",
			"kranz"
		],
		[
			"whirl",
			"lunge",
			"rhythmus",
			"sturmschritte"
		],
		[
			"faecher",
			"festhalten",
			"partner",
			"kaefig"
		]
	],
	"singer": [
		[
			"_grund",
			"spark",
			"lullaby",
			"sternenglanz"
		],
		[
			"polar",
			"comet",
			"nachhall",
			"mondschild"
		],
		[
			"meteor",
			"verblassen",
			"rueckkehr",
			"dissonanz"
		]
	],
	# Teil R (die sechs späteren Klassen, noch ohne Baum): Kennungen wie in scripts/kampf/skills.gd; „@…“ = voller Name
	# (die Fähigkeiten des Roboters Zahnrad liegen auf dem Blatt des Mechanikers)
	"tank": [["arcane_strike", "ban", "barrier", "condense"], ["ult"]],
	"mechanic": [["wrench", "hook", "guard", "repair"], ["ult", "@robot_drill", "@robot_guardmode"]],
	"twilight": [["light", "shadow", "blind", "veil"], ["turn", "ult"]],
	"ritualist": [["bite", "gift", "circle", "pact"], ["ult"]],
	"quartermaster": [["ware", "delivery", "appraise", "coins"], ["ult"]],
	"kunoichi": [["kunai", "talisman", "release", "smoke"], ["ult"]],
	"novize": [
		[
			"schlag",
			"schildstoss",
			"doppelschlag",
			"erste_hilfe"
		],
		[
			"deckung"
		]
	]
}

## Blätter, deren Bilder dicht beieinander stehen: nur kleine Lücken überbrücken (sonst wachsen Nachbarn zusammen)
ENG = {"tamer": 6, "smith": 6, "blade": 9, "novize": 10}

## Bilder mit gewollt lila oder pinken Flächen (Monster, Zielkreuz): dort kein Pink herausrechnen
LILA = {"archer_durchschlag", "archer_schwachstelle"}


def entrosen(datei):
	"""Rosa Schimmer vom pinken Hintergrund in Leuchtspuren und Rändern herausrechnen (Farbe Richtung Grün angleichen)."""
	a = np.array(Image.open(datei).convert("RGBA")).astype(int)
	zu = np.clip(np.minimum(a[..., 0], a[..., 2]) - a[..., 1], 0, None)
	a[..., 0] -= zu
	a[..., 2] -= zu
	Image.fromarray(a.astype(np.uint8)).save(datei)


def main():
	gb.ZIEL = WURZEL / "assets" / "faehigkeiten"
	gb.GROESSE = 128
	for klasse in sys.argv[1:] or BLAETTER:
		blatt = f"faehigkeiten_{klasse}"
		if not (WURZEL / "tools" / "vorlagen" / f"{blatt}.png").exists():
			print(f"{blatt}.png fehlt noch, übersprungen")
			continue
		# Fähigkeits-Bilder haben oft lose Teile (Wirbel, Funken, Staub): nahe Teile gehören zum selben Bild
		gb.VERBINDEN.setdefault(blatt, ENG.get(klasse, 15))
		gb.zerlegen(blatt, [[i[1:] if i.startswith("@") else f"{klasse}_{i}" for i in reihe] for reihe in BLAETTER[klasse]])
		for reihe in BLAETTER[klasse]:
			for i in reihe:
				name = i[1:] if i.startswith("@") else f"{klasse}_{i}"
				if name not in LILA:
					entrosen(gb.ZIEL / f"{name}.png")


if __name__ == "__main__":
	main()
