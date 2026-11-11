"""Schneidet Effekt-Blätter von ChatGPT in Einzelbilder (D9h).

Aufruf: python tools/effekt_bilder.py BLATT NAME [BILDER]
        python tools/effekt_bilder.py --alle ORDNER   (alle Blätter aus der Liste unten)
BLATT ist eine Reihe gleich breiter Bilder mit durchsichtigem Hintergrund (oder zwei Reihen, siehe REIHEN).
Ergebnis: assets/fx/NAME_f0.png, _f1.png ... in Spielgröße, mit klaren Pixeln und ohne Schleier.
Alle Bilder eines Effekts werden auf denselben Ausschnitt gekürzt, damit der Effekt beim Abspielen nicht springt.
"""
import sys
from pathlib import Path

import numpy as np
from PIL import Image

# So viele Blatt-Pixel ergeben ein Spiel-Pixel
TEILER = 4
# Fast durchsichtige Reste gehören nicht zum Effekt (auch ein mitgemaltes blasses Schachbrett)
SCHLEIER = 60
# Blatt -> Anzahl Bilder pro Reihe
BILDER = {
	"treffer_funken": 6, "staubwolke": 6, "heilung": 6, "schild_kuppel": 6, "schockwelle": 6, "lichtstrahl": 6,
	"glut": 6, "stern_flug": 4, "pfeil_flug": 4, "sternenmut_hieb": 6, "netz": 6, "fadenkreuz": 6, "pfeilregen": 6,
	"schneise": 6, "waldlicht": 6, "rote_funken": 6, "bruellen": 6, "wachstum": 6, "futter": 4, "hammer_funken": 6,
	"amboss": 4, "risse": 6, "kuehlung": 6, "goldregen": 6, "kreuzschnitt": 6, "wirbelkreis": 6, "sichel": 4,
	"klinge_flug": 4, "noten": 6, "mond": 4, "komet": 4,
	# Teil N (A10b): Geschosse der Monster je Element, Parade und Ausweichen
	"geschoss_feuer": 4, "geschoss_erde": 4, "geschoss_pflanze": 4, "geschoss_blitz": 4, "geschoss_wasser": 4,
	"geschoss_wind": 4, "geschoss_licht": 4, "geschoss_schatten": 4, "geschoss_sternenkraft": 4,
	"parade_perfekt": 6, "parade": 6, "ausweichen": 6, "blitz_einschlag": 8, "nachbild": 8,
	# Teil M (A9b): Effekte der Dungeons
	"kette_glied": 4, "kette_reisst": 6, "lava": 4, "lavaflut": 6, "nass": 6, "panzer_splitter": 6,
	"laterne": 4, "splitterlicht": 4, "giftwolke": 6, "heilsporen": 6, "wurzelgriff": 6, "leere": 6,
}
# Blätter mit zwei Reihen: Namen für die Reihen
REIHEN = {"bruellen": ["bruellen", "bruellen_rot"], "noten": ["noten", "noten_gold"], "lava": ["lava_warnung", "lava_oben"]}
# Blätter mit mitgemaltem Schachbrett im Schein: halb durchsichtiges fällt dort ganz weg
SCHLEIER_EXTRA = {"noten": 150}


def _schnitte(belegt: np.ndarray, bilder: int) -> list[int]:
	"""Trennstellen zwischen den Bildern: die leerste Spalte nahe der gleichmäßigen Teilung.
	ChatGPT setzt die Bilder nicht genau in gleich breite Fächer, darum wird gesucht statt stur geteilt."""
	breite = belegt.shape[1] / bilder
	spalten = belegt.sum(0)
	schnitte = [0]
	for i in range(1, bilder):
		mitte = int(i * breite)
		von, bis = mitte - int(breite * 0.3), mitte + int(breite * 0.3)
		# Bei mehreren leeren Spalten die Mitte der leeren Lücke nehmen
		bereich = spalten[von:bis]
		leer = np.where(bereich == bereich.min())[0]
		schnitte.append(von + int(leer[len(leer) // 2]))
	schnitte.append(belegt.shape[1])
	return schnitte


def schneiden(blatt: Path, name: str, bilder: int = 6) -> None:
	bild = np.array(Image.open(blatt).convert("RGBA"))
	namen = REIHEN.get(name, [name])
	hoehe = bild.shape[0] // len(namen)
	ziel = Path("assets/fx")
	ziel.mkdir(parents=True, exist_ok=True)
	schleier = SCHLEIER_EXTRA.get(name, SCHLEIER)
	for reihe, reihen_name in enumerate(namen):
		streifen = bild[reihe * hoehe:(reihe + 1) * hoehe].copy()
		streifen[..., 3] = np.where(streifen[..., 3] < schleier, 0, streifen[..., 3])
		belegt = streifen[..., 3] > 0
		schnitte = _schnitte(belegt, bilder)
		# Jedes Bild waagerecht auf die Mitte seines Inhalts setzen, senkrecht bleibt alles wie gemalt
		stuecke = []
		for i in range(bilder):
			fach = streifen[:, schnitte[i]:schnitte[i + 1]]
			spalten = np.where(fach[..., 3].any(0))[0]
			stuecke.append(fach[:, spalten[0]:spalten[-1] + 1] if len(spalten) else fach[:, :1])
		breite = max(s.shape[1] for s in stuecke)
		breite = -(-breite // TEILER) * TEILER
		zeilen = np.where(belegt.any(1))[0]
		oben = zeilen[0] // TEILER * TEILER
		unten = -(-(zeilen[-1] + 1) // TEILER) * TEILER
		for i, stueck in enumerate(stuecke):
			flaeche = np.zeros((unten - oben, breite, 4), np.uint8)
			links = (breite - stueck.shape[1]) // 2
			flaeche[:, links:links + stueck.shape[1]] = stueck[oben:unten]
			klein = Image.fromarray(flaeche).resize((breite // TEILER, (unten - oben) // TEILER), Image.BOX)
			daten = np.array(klein)
			daten[..., 3] = np.where(daten[..., 3] < SCHLEIER, 0, 255)
			Image.fromarray(daten).save(ziel / f"{reihen_name}_f{i}.png")
		print(f"{reihen_name}: {bilder} Bilder, {breite // TEILER} x {(unten - oben) // TEILER} Pixel")


if __name__ == "__main__":
	if sys.argv[1] == "--alle":
		ordner = Path(sys.argv[2])
		for name, anzahl in BILDER.items():
			schneiden(ordner / f"fx_{name}.png", name, anzahl)
	else:
		schneiden(Path(sys.argv[1]), sys.argv[2], int(sys.argv[3]) if len(sys.argv) > 3 else 6)
