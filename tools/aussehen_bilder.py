"""Aussehen-Teile aus Marcos Blättern schneiden (Projekt 13, Schritte 3 und 4; Aufträge in GRAFIK_AUFTRAG.md Teil D).

- waffe_kurzschwert.png, klassen_waffen.png: Klinge und Parierstange, senkrecht, Spitze oben (assets/teile/waffe/).
  Der Griff bleibt weg, bei den Novizen ist er in die Hand gemalt.
- probe_hut.png: Hut seitlich, schräg von vorne, schräg von hinten (assets/teile/hut/).
- hut_sternreif.png, hut_geweihband.png: Stirnbänder des Kartenalbums (D17), gleiche drei Ansichten.
- probe_umhang.png: je Richtung 2 Bilder Stehen und 4 Bilder Laufen (assets/teile/ruecken/).
Anker und feste Farbtöne stehen danach in data/aussehen_teile.json.
Aufruf: python3 tools/aussehen_bilder.py   (braucht numpy, scipy und Pillow)
"""
import json
from pathlib import Path

import numpy as np
from PIL import Image
from scipy import ndimage
from scipy.cluster.vq import kmeans2

WURZEL = Path(__file__).resolve().parent.parent
VORLAGEN = WURZEL / "tools" / "vorlagen"
TEILE = WURZEL / "assets" / "teile"
DATEN = WURZEL / "data" / "aussehen_teile.json"

## So lang ist eine Klinge samt Parierstange im Spiel (Pixel, wie das alte Schwert am Novizen)
WAFFE_LAENGE = 50
## So breit ist die Hutkrempe im Spiel (Pixel, Köpfe sind etwa 64 breit)
HUT_BREITE = 84
## So hoch ist der stehende Umhang im Spiel (Pixel, vom Hals bis zum Knie)
UMHANG_HOEHE = 72
## Anteil der Hut-Höhe, an dem der Kopf im Hut steckt
HUT_ANKER = 0.72
RICHTUNGEN = ["seite", "vorn", "hinten"]

## Waffe -> Blatt, Nummer von links, Name, Anteil der Höhe (von oben) bis zur Unterkante der Parierstange
WAFFEN = {
	"kurzschwert": ("waffe_kurzschwert", 0, "Kurzschwert", 0.75),
	"krummklinge": ("klassen_waffen", 5, "Krummklinge", 0.70),
}


def teile(blatt):
	"""Die Bilder eines Blatts von links oben nach rechts unten (Reihen getrennt)."""
	a = np.array(Image.open(VORLAGEN / f"{blatt}.png").convert("RGBA"))
	lab, _ = ndimage.label(ndimage.binary_dilation(a[..., 3] > 40, iterations=4))
	stuecke = [s for s in ndimage.find_objects(lab) if (s[0].stop - s[0].start) * (s[1].stop - s[1].start) > 2500]
	stuecke.sort(key=lambda s: (s[0].start, s[1].start))
	reihen, jetzt = [], []
	for s in stuecke:
		if jetzt and s[0].start > jetzt[0][0].start + (jetzt[0][0].stop - jetzt[0][0].start) * 0.6:
			reihen.append(sorted(jetzt, key=lambda t: t[1].start))
			jetzt = []
		jetzt.append(s)
	reihen.append(sorted(jetzt, key=lambda t: t[1].start))
	return [[a[s].copy() for s in r] for r in reihen]


def klein(t, faktor):
	bild = Image.fromarray(t)
	return bild.resize((max(1, round(bild.width * faktor)), max(1, round(bild.height * faktor))), Image.LANCZOS)


def toene(bilder):
	"""Vier feste Töne (hell bis Schatten) eines Teils, damit das Spiel es umfärben kann."""
	punkte = np.concatenate([np.array(b)[np.array(b)[..., 3] > 200][:, :3] for b in bilder]).astype(float)
	mitten, _ = kmeans2(punkte, 4, seed=1, minit="++")
	mitten = sorted(mitten, key=lambda m: -m.sum())
	return ["#%02x%02x%02x" % tuple(int(round(w)) for w in m) for m in mitten]


def waffen():
	ziel = TEILE / "waffe"
	ziel.mkdir(exist_ok=True)
	daten = {}
	for wid, (blatt, nummer, name, griffkante) in WAFFEN.items():
		t = [s for r in teile(blatt) for s in r][nummer]
		kante = round(t.shape[0] * griffkante)
		faktor = WAFFE_LAENGE / kante
		bild = klein(t[:kante], faktor)
		bild.save(ziel / f"{wid}.png")
		# Anker: Mitte der Parierstange, der kommt auf den Griff in der Hand
		daten[wid] = {"name": name, "anker": [round(bild.width / 2, 1), bild.height - 5]}
	return daten


def hut():
	(TEILE / "hut").mkdir(exist_ok=True)
	bilder = [s for r in teile("probe_hut") for s in r]
	faktor = HUT_BREITE / bilder[1].shape[1]
	eintrag = {"name": "Wanderhut"}
	fertig = []
	for richtung, t in zip(RICHTUNGEN, bilder):
		bild = klein(t, faktor)
		bild.save(TEILE / "hut" / f"wanderhut_{richtung}.png")
		fertig.append(bild)
		eintrag[richtung] = {"anker": [round(bild.width / 2), round(bild.height * HUT_ANKER)], "sitz": 0.34}
	eintrag["flaechen"] = {"leder": toene(fertig)}
	huete = {"wanderhut": eintrag}
	huete.update(stirnbaender())
	return huete


## Kopfbedeckungen des Kartenalbums (D17, Auftrag B6d): Stirnbänder, die um die Stirn sitzen
BAENDER = {"sternreif": "Sternenreif", "geweihband": "Geweih-Band"}
## So breit ist ein Stirnband von vorne im Spiel (Pixel, etwas breiter als der Kopf)
BAND_BREITE = 72
## So weit unter dem Scheitel sitzt das Band (Anteil der Kopfhöhe)
BAND_SITZ = 0.4


def stirnbaender():
	"""tools/vorlagen/hut_<id>.png: seitlich, schräg von vorne, schräg von hinten in einer Reihe."""
	ergebnis = {}
	for hut_id, name in BAENDER.items():
		bilder = [s for r in teile(f"hut_{hut_id}") for s in r]
		faktor = BAND_BREITE / bilder[1].shape[1]
		eintrag = {"name": name, "belohnung": True}
		for richtung, t in zip(RICHTUNGEN, bilder):
			bild = klein(t, faktor)
			bild.save(TEILE / "hut" / f"{hut_id}_{richtung}.png")
			# Anker: Mitte des Rings (die Zeilen, in denen das Band am breitesten ist), nicht die Geweihe oder der Stern
			a = np.array(bild)[..., 3] > 60
			breiten = a.sum(axis=1)
			zeilen = np.where(breiten >= breiten.max() * 0.85)[0]
			mitte = int(round(zeilen.mean()))
			eintrag[richtung] = {"anker": [round(bild.width / 2), mitte], "sitz": BAND_SITZ}
			# Von vorne und hinten: Die obere Hälfte des Rings liegt hinter dem Kopf
			if richtung != "seite":
				eintrag[richtung]["hinten_bis"] = mitte
		ergebnis[hut_id] = eintrag
	return ergebnis


def umhang():
	(TEILE / "ruecken").mkdir(exist_ok=True)
	for alt in (TEILE / "ruecken").glob("reiseumhang_*.png*"):
		alt.unlink()
	reihen = teile("probe_umhang")
	faktor = UMHANG_HOEHE / reihen[0][0].shape[0]
	eintrag = {"name": "Reiseumhang"}
	fertig = []
	versatz = {"seite": [-4, 4], "vorn": [-6, 4], "hinten": [0, 4]}
	for richtung, reihe in zip(RICHTUNGEN, reihen):
		anker = []
		for n, t in enumerate(reihe):
			bild = klein(t, faktor)
			bild.save(TEILE / "ruecken" / f"reiseumhang_{richtung}_f{n}.png")
			fertig.append(bild)
			oben = np.array(bild)[:8, :, 3] > 128
			anker.append([round(float(np.where(oben.any(0))[0].mean()), 1), 2])
		eintrag[richtung] = {"anker": anker, "versatz": versatz[richtung]}
	eintrag["flaechen"] = {"hauptfarbe": toene(fertig)}
	return {"reiseumhang": eintrag}


def main():
	daten = json.loads(DATEN.read_text(encoding="utf-8"))
	daten["waffe"] = waffen()
	daten["hut"] = hut()
	daten["ruecken"] = umhang()
	daten["_hinweis"] = ("Aussehen-Teile, erzeugt von tools/aussehen_bilder.py. waffe: anker = Punkt auf der Parierstange, kommt auf griff des "
			"Bildes (data/figurteile.json), Spitze oben, wird um waffe_winkel gedreht. hut: anker = Punkt im Hutbild, der auf die Kopfmitte kommt, "
			"sitz = so weit (Anteil der Kopfhöhe) unter dem Scheitel. ruecken: je Richtung 6 Bilder (Stehen 2, Laufen 4) mit anker an der Schulterkante, "
			"kommt auf den Halspunkt des Körpers plus versatz. flaechen: die festen Farbtöne des Bildes je Farbfläche (hell, mittel, dunkel, Schatten), "
			"damit das Spiel sie umfärben kann (data/farbpaletten.json).")
	DATEN.write_text(json.dumps(daten, ensure_ascii=False, indent="\t"), encoding="utf-8")
	print("Waffen, Hut und Umhang geschnitten.")


if __name__ == "__main__":
	import sys
	if "--nur-baender" in sys.argv:
		# Nur die Stirnbänder neu schneiden, alles andere bleibt, wie es ist
		daten = json.loads(DATEN.read_text(encoding="utf-8"))
		daten["hut"].update(stirnbaender())
		DATEN.write_text(json.dumps(daten, ensure_ascii=False, indent="\t"), encoding="utf-8")
		print("Stirnbänder geschnitten.")
	else:
		main()
