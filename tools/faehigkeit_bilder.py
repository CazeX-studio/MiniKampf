"""Schneidet die Blätter mit den Fähigkeits-Bildern (tools/vorlagen/faehigkeiten_<klasse>.png) in einzelne Bilder (A8a).

Gleiches Verfahren wie bei den Gegenständen (tools/gegenstand_bilder.py): pinker Hintergrund, jedes Bild freigestellt und
quadratisch zugeschnitten, hier 128 × 128 Pixel. Ergebnis: assets/faehigkeiten/<klasse>_<fähigkeit>.png, Kennungen wie in
data/faehigkeiten.json („_grund“ = Grundreihe). Die Bildaufträge stehen in Spieldesign/GRAFIK_AUFTRAG.md Teil L.
Aufruf: python3 tools/faehigkeit_bilder.py [klasse …]   (ohne Angabe alle, deren Blatt schon da ist)
"""
import sys
from pathlib import Path

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


def main():
	gb.ZIEL = WURZEL / "assets" / "faehigkeiten"
	gb.GROESSE = 128
	for klasse in sys.argv[1:] or BLAETTER:
		blatt = f"faehigkeiten_{klasse}"
		if not (WURZEL / "tools" / "vorlagen" / f"{blatt}.png").exists():
			print(f"{blatt}.png fehlt noch, übersprungen")
			continue
		gb.zerlegen(blatt, [[f"{klasse}_{i}" for i in reihe] for reihe in BLAETTER[klasse]])


if __name__ == "__main__":
	main()
