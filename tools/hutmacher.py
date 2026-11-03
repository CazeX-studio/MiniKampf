"""Hutmacher Hatta und die Hüte der Regionen (D20a), dazu die Zeichen über den Diensten.

- tools/vorlagen/huete_regionen.png: acht Hüte, Reihe 1 seitlich, Reihe 2 schräg von vorne, Reihe 3 schräg von hinten
  (Auftrag GRAFIK_AUFTRAG.md Teil D „Hüte der Regionen“). Ergebnis: assets/teile/hut/<hut>_<richtung>.png und Einträge in
  data/aussehen_teile.json. Sie sind erst wählbar, wenn man sie bei Hatta eingetauscht hat ("belohnung": true).
- tools/vorlagen/zeichen_dienste.png: Münze, Truhe, Hut, Laterne -> assets/ui/zeichen_<name>.png (über Händler, Bank,
  Hutmacher und Wegelaterne).
- tools/vorlagen/neben_hatta.png: Reihe 1 Kopf schräg von vorne und von hinten, Reihe 2 Porträts, Reihe 3 Zubehör
  (Zylinder vorne und hinten, Maßband vorne und hinten). Kopf und Zylinder kommen ins Spiel: Kopf „hatta“ auf dem
  Grundkörper Händler, Zylinder „hatta_zylinder“ als Hut (nur für Hatta).
Aufruf: python3 tools/hutmacher.py   (braucht numpy, scipy und Pillow; vorher tools/baukasten_figuren.py)
"""
import json
import sys
from pathlib import Path

import numpy as np
from PIL import Image

WURZEL = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(WURZEL / "tools"))
from aussehen_bilder import DATEN as SCHICHTEN, HUT_ANKER, HUT_BREITE, klein, teile  # noqa: E402
from baukasten_figuren import haut, kopf_faktor  # noqa: E402
from figur_bilder import VORLAGEN  # noqa: E402
from kopf_koerper import hals, verkleinern  # noqa: E402
from monster_bilder import ausschneiden, bilder_finden, freistellen  # noqa: E402

TEILE = WURZEL / "assets" / "teile"
FIGURTEILE = WURZEL / "data" / "figurteile.json"
UI = WURZEL / "assets" / "ui"

HUETE = [("gruene_kapuze", "Grüne Kapuze"), ("filzhut", "Filzhut mit Feder"), ("kopftuch", "Kopftuch der Glutoase"),
		("schmiedekappe", "Schmiedekappe"), ("wachhelm", "Wachhelm"), ("kochmuetze", "Kochmütze"),
		("stoffmuetze", "Stoffmütze"), ("gelehrtenhut", "Gelehrtenhut")]
RICHTUNGEN = ["seite", "vorn", "hinten"]
ZEICHEN = ["muenze", "truhe", "hut", "laterne"]
## So groß sind die Zeichen im Spiel (Pixel)
ZEICHEN_GROESSE = 40
## Hattas Haare stehen wild ab: sein Kopf ist so viel höher als ein Volks-Kopf
WILDES_HAAR = 1.15
## So weit unter dem Scheitel sitzen die Hüte (wie der Wanderhut)
SITZ = 0.34


def huete():
	reihen = teile("huete_regionen")
	if [len(r) for r in reihen] != [len(HUETE)] * 3:
		raise SystemExit(f"huete_regionen: Reihen {[len(r) for r in reihen]}, erwartet {[len(HUETE)] * 3}")
	# Ein Maßstab für das ganze Blatt: die Hüte sind gleich groß gezeichnet, ihre mittlere Breite von vorne wie der Wanderhut
	faktor = HUT_BREITE / np.median([t.shape[1] for t in reihen[1]])
	daten = {}
	for nummer, (hut_id, name) in enumerate(HUETE):
		eintrag = {"name": name, "belohnung": True}
		for richtung, reihe in zip(RICHTUNGEN, reihen):
			bild = klein(reihe[nummer], faktor)
			bild.save(TEILE / "hut" / f"{hut_id}_{richtung}.png")
			eintrag[richtung] = {"anker": [round(bild.width / 2), round(bild.height * HUT_ANKER)], "sitz": SITZ}
		daten[hut_id] = eintrag
	print(f"{len(daten)} Hüte, Faktor {faktor:.3f}")
	return daten


def zeichen():
	stuecke = [s for r in teile("zeichen_dienste") for s in r]
	if len(stuecke) != len(ZEICHEN):
		raise SystemExit(f"zeichen_dienste: {len(stuecke)} Zeichen, erwartet {len(ZEICHEN)}")
	for name, t in zip(ZEICHEN, stuecke):
		bild = Image.fromarray(t)
		faktor = ZEICHEN_GROESSE / max(bild.size)
		klein(t, faktor).save(UI / f"zeichen_{name}.png")
	print(f"{len(ZEICHEN)} Zeichen")


def hatta(schichten, daten):
	a = freistellen(Image.open(VORLAGEN / "neben_hatta.png"))
	ziel, reihen = bilder_finden(a, [])
	if [len(r) for r in reihen] != [2, 2, 4]:
		raise SystemExit(f"neben_hatta: Reihen {[len(r) for r in reihen]}, erwartet [2, 2, 4]")
	faktor_kofi, _ = kopf_faktor()
	kofi = freistellen(Image.open(VORLAGEN / "kofi_kopf.png"))
	ziel_k, reihen_k = bilder_finden(kofi, [])
	breite = lambda t: float(np.ptp(np.where((t[..., 3] > 128).any(0))[0]))
	kofi_breite = np.median([breite(ausschneiden(kofi, ziel_k, i)) for i, _ in reihen_k[1]])
	vorn = ausschneiden(a, ziel, reihen[0][0][0])
	# Gemessen an der Kopfhöhe eines Volks-Kopfes; Hattas wilde Haare machen den Kopf etwas höher (WILDES_HAAR)
	hoehe = lambda t: float(np.ptp(np.where((t[..., 3] > 128).any(1))[0]))
	volk = np.array(Image.open(TEILE / "koepfe" / "v_m1_vorn_normal.png").convert("RGBA"))
	faktor = hoehe(volk) * WILDES_HAAR / hoehe(vorn)
	punkte = {}
	for richtung, (i, _) in zip(["vorn", "hinten"], reihen[0]):
		kopf = verkleinern(ausschneiden(a, ziel, i), faktor)
		Image.fromarray(kopf).save(TEILE / "koepfe" / f"hatta_{richtung}_normal.png")
		punkte[f"{richtung}_normal"] = hals(kopf)
	kopf = {"name": "Hutmacher Hatta", "geschlecht": "m", "hals": punkte}
	daten["grund_haendler"]["_koepfe"]["hatta"] = kopf
	# Zylinder im selben Maßstab wie der Kopf (beide im selben Blatt gezeichnet)
	eintrag = {"name": "Hattas Zylinder", "belohnung": True}
	for richtung, (i, _) in zip(["vorn", "hinten"], reihen[2][:2]):
		bild = Image.fromarray(verkleinern(ausschneiden(a, ziel, i), faktor))
		bild.save(TEILE / "hut" / f"hatta_zylinder_{richtung}.png")
		eintrag[richtung] = {"anker": [round(bild.width / 2), round(bild.height * HUT_ANKER)], "sitz": SITZ}
	schichten["hut"]["hatta_zylinder"] = eintrag
	print(f"Hatta: Kopf und Zylinder, Faktor {faktor:.3f}")


def main():
	schichten = json.loads(SCHICHTEN.read_text(encoding="utf-8"))
	daten = json.loads(FIGURTEILE.read_text())
	schichten["hut"].update(huete())
	zeichen()
	hatta(schichten, daten)
	SCHICHTEN.write_text(json.dumps(schichten, ensure_ascii=False, indent="\t"), encoding="utf-8")
	FIGURTEILE.write_text(json.dumps(daten, ensure_ascii=False, indent="\t", sort_keys=True))


if __name__ == "__main__":
	main()
