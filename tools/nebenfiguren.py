"""Nebenfiguren von Kreuzweg nach Steckbrief (D20c): eigene Köpfe auf den Baukasten-Körpern, dazu Porträts.

Blätter tools/vorlagen/neben_<figur>.png (Auftrag GRAFIK_AUFTRAG.md Teil D „Figuren 4“): Reihe 1 Kopf schräg von vorne
und schräg von hinten, Reihe 2 Porträts (Stimmungen je Figur, siehe FIGUREN), Reihe 3 Zubehör je von vorne und von
hinten (D20c2, siehe ZUBEHOER und HUETE): Teile am Körper -> assets/teile/zubehoer/, Helm und Krone als Hut ->
assets/teile/hut/, beides mit Eintrag in data/aussehen_teile.json.
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
from aussehen_bilder import DATEN as SCHICHTEN  # noqa: E402
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
	# Mitschüler auf den Novizen-Körpern (D20c2): kämpfen auch, darum gilt der Kopf von vorne auch von der Seite
	"tessa": ("novize_w", "Tessa", "w", ["laechelnd", "ueberrascht", "wuetend"]),
	"gorm": ("novize_m", "Gorm", "m", ["ruhig", "traurig", "ueberrascht"]),
	# Grünwacht (D21)
	"salbei": ("grund_haendler", "Kräuterhändlerin Salbei", "w", ["laechelnd", "ueberrascht"]),
	"borko": ("grund_mann", "Wirt Borko", "m", ["laechelnd", "wuetend"]),
	"hagebutte": ("grund_alter_mensch", "Oma Hagebutte", "w", ["laechelnd", "ueberrascht"]),
	"tamm": ("grund_alter_mensch", "Bankhüter Tamm", "m", ["ruhig", "laechelnd"]),
	# Kobalt kämpft hinter seinem Monster: Zähmer-Körper, Kopf von vorne gilt auch von der Seite
	"kobalt": ("zaehmer_m", "Kobalt", "m", ["laechelnd", "wuetend", "ueberrascht"]),
	# Glutoase (D27)
	"nadia": ("grund_frau", "Brunnenhüterin Nadia", "w", ["ruhig", "traurig", "ueberrascht"]),
	"zaid": ("grund_haendler", "Karawanenführer Zaid", "m", ["laechelnd", "ueberrascht"]),
	"rashid": ("grund_alter_mensch", "Bankhüter Rashid", "m", ["ruhig", "laechelnd"]),
	"tarek": ("grund_haendler", "Händler Tarek", "m", ["laechelnd", "ueberrascht"]),
	"layla": ("grund_frau", "Wirtin Layla", "w", ["laechelnd", "wuetend"]),
}
## Der Maßstab für alle Köpfe kommt von diesen Blättern (fest, damit neue Blätter die alten Köpfe nicht verändern)
MASSSTAB = ["lene", "hanne", "ilse", "edmar", "brom", "quill", "pip", "lotte"]
## Sprecher im Gespräch, wenn er anders heißt als die Figur (für die Porträts)
SPRECHER = {"hagebutte": "oma_hagebutte"}

## Zubehör am Körper: Figur -> Liste (Nummer des Paars in Reihe 3, Kennung, Name, Größe im Spiel, Höhe am Körper, x).
## Größe: ("breite"|"hoehe", Pixel). Höhe am Körper: 0 = am Hals, 1 = an den Füßen; x: nach rechts (von hinten gespiegelt).
## Gehängt wird jedes Teil an seiner oberen Mitte. Ilses Ärmelschoner und Edmars Festschärpen fehlen noch (Arme, Fest), ebenso Zaids Reiseumhang (Rückenteil).
ZUBEHOER = {
	"hanne": [(0, "schuerze", "Hannes Schürze", ("breite", 28), 0.30, 0), (1, "kochloeffel", "Kochlöffel", ("hoehe", 20), 0.28, 13)],
	"ilse": [(1, "schluesselbund", "Schlüsselbund", ("hoehe", 15), 0.36, 12)],
	"edmar": [(0, "amtskette", "Amtskette", ("breite", 22), 0.0, 0)],
	"quill": [(0, "meissel", "Meißel", ("hoehe", 14), 0.36, 13)],
	"pip": [(0, "holzschwert", "Holzschwert", ("hoehe", 20), 0.34, 11)],
	"salbei": [(0, "kraeuterbuendel", "Kräuterbündel", ("hoehe", 16), 0.34, -12), (1, "korb", "Salbeis Korb", ("breite", 16), 0.40, 13)],
	"borko": [(1, "schoepfkelle", "Schöpfkelle", ("hoehe", 20), 0.30, 13)],
	"hagebutte": [(1, "kartenstapel", "Kartenstapel", ("hoehe", 10), 0.40, 12)],
	"nadia": [(1, "wasserkrug", "Nadias Wasserkrug", ("hoehe", 16), 0.30, 13)],
	"rashid": [(1, "bankschluessel", "Rashids Schlüssel", ("hoehe", 14), 0.36, 12)],
	"tarek": [(0, "schaerpe", "Tareks Schärpe", ("breite", 26), 0.22, 0), (1, "guertelklinge", "Klinge am Gürtel", ("hoehe", 22), 0.32, -12)],
	"layla": [(0, "schuerze_layla", "Laylas Schürze", ("breite", 28), 0.30, 0), (1, "tablett", "Tablett", ("breite", 18), 0.28, 14)],
}
## Hüte aus Reihe 3: Figur -> (Nummer des Paars, Kennung, Name, Größe zum Kopf, Anteil der Hut-Höhe, an dem der Kopf
## steckt, Sitz unter dem Scheitel). Hagebuttes Strickjacke fehlt noch (müsste den ganzen Körper bedecken).
HUETE = {
	"brom": (0, "brom_helm", "Broms alter Helm", 0.82, 0.95, 0.36),
	"lotte": (0, "lotte_krone", "Lottes Papierkrone", 0.5, 0.85, 0.10),
	"borko": (0, "borko_kochmuetze", "Borkos Kochmütze", 0.8, 0.85, 0.15),
	"tamm": (0, "tamm_moos_hut", "Tamms Hut mit Moos", 0.85, 0.85, 0.25),
	# Nadias Kopftuch und Zaids Turban sind schon im Kopf-Bild gezeichnet
	"rashid": (0, "rashid_kopftuch", "Rashids Kopftuch", 0.9, 0.85, 0.42),
}

## Köpfe, die im Blatt größer gezeichnet sind als die anderen (Lenes Dutt und Brille): so viel kleiner machen
KLEINER = {"lene": 0.82, "nadia": 0.88}


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
	gezeichnet = np.median([hoehe(ausschneiden(a, z, r[0][0][0])) for figur, (a, z, r) in blaetter.items() if figur in MASSSTAB])
	faktor = hoehe(volk) / gezeichnet
	PORTRAETS.mkdir(exist_ok=True)
	for figur, (koerper, name, geschlecht, stimmungen) in FIGUREN.items():
		a, ziel, reihen = blaetter[figur]
		vorn, hinten = [verkleinern(ausschneiden(a, ziel, i), faktor * KLEINER.get(figur, 1.0)) for i, _ in reihen[0]]
		Image.fromarray(vorn).save(TEILE / "koepfe" / f"{figur}_vorn_normal.png")
		Image.fromarray(hinten).save(TEILE / "koepfe" / f"{figur}_hinten_normal.png")
		punkte = {"vorn_normal": hals(vorn), "hinten_normal": hals_hinten(hinten, vorn)}
		if not koerper.startswith("grund_"):
			# Der Kopf schräg von vorne schaut nach rechts wie die Kampf-Körper: er dient auch als Seitenansicht
			Image.fromarray(vorn).save(TEILE / "koepfe" / f"{figur}_seite_normal.png")
			punkte["seite_normal"] = punkte["vorn_normal"]
		daten[koerper]["_koepfe"][figur] = {"name": name, "geschlecht": geschlecht, "hals": punkte}
		if not koerper.startswith("grund_"):
			# Nicht bei „Figur erstellen“ wählbar
			daten[koerper]["_koepfe"][figur]["nur_figur"] = True
		for stimmung, (i, _) in zip(stimmungen, reihen[1]):
			bild = Image.fromarray(ausschneiden(a, ziel, i))
			f = PORTRAET_HOEHE / bild.height
			bild.resize((round(bild.width * f), PORTRAET_HOEHE), Image.LANCZOS).save(PORTRAETS / f"{SPRECHER.get(figur, figur)}_{stimmung}.png")
	FIGURTEILE.write_text(json.dumps(daten, ensure_ascii=False, indent="\t", sort_keys=True))
	print(f"{len(FIGUREN)} Nebenfiguren, Faktor {faktor:.3f}")
	zubehoer(blaetter, faktor)


def zubehoer(blaetter, faktor):
	schichten = json.loads(SCHICHTEN.read_text(encoding="utf-8"))
	schichten.setdefault("zubehoer", {})
	(TEILE / "zubehoer").mkdir(exist_ok=True)
	for figur, liste in ZUBEHOER.items():
		a, ziel, reihen = blaetter[figur]
		for paar, kennung, name, (mass, groesse), hoehe_am_koerper, x in liste:
			eintrag = {"name": name}
			for richtung, (i, _) in zip(["vorn", "hinten"], reihen[2][2 * paar:2 * paar + 2]):
				bild = Image.fromarray(ausschneiden(a, ziel, i))
				f = groesse / (bild.width if mass == "breite" else bild.height)
				bild = bild.resize((max(1, round(bild.width * f)), max(1, round(bild.height * f))), Image.LANCZOS)
				bild.save(TEILE / "zubehoer" / f"{kennung}_{richtung}.png")
				eintrag[richtung] = {"anker": [round(bild.width / 2), 0], "hoehe": hoehe_am_koerper,
						"x": x if richtung == "vorn" else -x}
			schichten["zubehoer"][kennung] = eintrag
	for figur, (paar, kennung, name, groesse, anker, sitz) in HUETE.items():
		a, ziel, reihen = blaetter[figur]
		eintrag = {"name": name, "belohnung": True}
		for richtung, (i, _) in zip(["vorn", "hinten"], reihen[2][2 * paar:2 * paar + 2]):
			bild = Image.fromarray(verkleinern(ausschneiden(a, ziel, i), faktor * groesse))
			bild.save(TEILE / "hut" / f"{kennung}_{richtung}.png")
			eintrag[richtung] = {"anker": [round(bild.width / 2), round(bild.height * anker)], "sitz": sitz}
		schichten["hut"][kennung] = eintrag
	SCHICHTEN.write_text(json.dumps(schichten, ensure_ascii=False, indent="\t"), encoding="utf-8")
	print(f"Zubehör: {sum(len(v) for v in ZUBEHOER.values())} Teile, {len(HUETE)} Hüte")


if __name__ == "__main__":
	main()
