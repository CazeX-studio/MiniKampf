"""Figuren-Baukasten (D19, NPC.md Abschnitt 3): acht Grundkörper und die Köpfe für das Volk.

- Körper: tools/vorlagen/grund_<art>.png (Auftrag GRAFIK_AUFTRAG.md Teil D „Figuren 3“), nur die Welt:
  Reihe 1 Stehen und Laufen schräg von vorne (je 4), Reihe 2 dasselbe schräg von hinten. Kopf als grünes Oval.
  Alle Körper werden so groß gemacht, dass das Oval so groß ist wie beim Novizen: Dann passen alle Köpfe, und das Kind
  bleibt kleiner. Danach wie bei tools/koerper_blatt.py: Oval heraus, Halspunkt und Neigung merken.
- Köpfe: tools/vorlagen/koepfe_erwachsene.png und koepfe_alte_kinder.png: je sechs Köpfe, oben schräg von vorne,
  darunter schräg von hinten. Gleiche Größe wie die Novizen-Köpfe (gemessen am Kopf-Blatt kofi_kopf.png).
Ergebnis: assets/figuren/grund_*, assets/teile/koerper/grund_*, assets/teile/koepfe/<kopf>_vorn_normal.png usw.,
data/figurteile.json (Körper mit _koepfe: Volks-Köpfe und Novizen-Köpfe).
Aufruf: python3 tools/baukasten_figuren.py [körper …]   (mit Körper, z. B. frau_korpulent: nur diesen schneiden; braucht numpy, scipy und Pillow)
"""
import json
import sys
from pathlib import Path

import numpy as np
from PIL import Image
from scipy import ndimage

WURZEL = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(WURZEL / "tools"))
from figur_bilder import VORLAGEN, blatt  # noqa: E402
from koerper_blatt import DATEN, KOPF_QUELLE, TEILE, gruen, neigung, skalieren  # noqa: E402
from kopf_koerper import hals, richtung_von, verkleinern  # noqa: E402
from monster_bilder import ausschneiden, bilder_finden, freistellen, speichern  # noqa: E402

## Grundkörper -> (Name, Standardkopf)
KOERPER = {
	"mann": ("Mann", "v_m1"), "frau": ("Frau", "v_w1"), "kind": ("Kind", "k_m1"), "alter_mensch": ("Alter Mensch", "a_m1"),
	"wache": ("Wache", "v_m2"), "haendler": ("Händler", "v_m3"), "handwerker": ("Handwerker", "v_m2"), "gelehrter": ("Gelehrter", "a_m2"),
	# GRAFIK_AUFTRAG.md K1c (10.11.2026): eigener Körper für Kräuterhändlerin Salbei
	"frau_korpulent": ("Frau, korpulent", "v_w2"),
}
REIHEN = [[("idle_vorn", 4), ("run_vorn", 4)], [("idle_hinten", 4), ("run_hinten", 4)]]
## Kopf-Blätter: Blatt -> Köpfe von links nach rechts (Kennung, Name, Geschlecht)
KOEPFE = {
	"koepfe_erwachsene": [("v_m1", "Mann, kurze braune Haare", "m"), ("v_m2", "Mann, Glatze mit Bart", "m"),
			("v_m3", "Mann, schwarze Locken", "m"), ("v_w1", "Frau, langer Zopf", "w"), ("v_w2", "Frau, Haarknoten", "w"),
			("v_w3", "Frau, offene rote Haare", "w")],
	"koepfe_alte_kinder": [("a_m1", "Alter Mann, weißer Bart", "m"), ("a_m2", "Alter Mann, Halbglatze", "m"),
			("a_w1", "Alte Frau, grauer Dutt", "w"), ("a_w2", "Alte Frau, Kopftuch", "w"), ("k_m1", "Junge", "m"),
			("k_w1", "Mädchen", "w")],
}


def oval_hoehe(bild):
	ys = np.where(gruen(bild).any(1))[0]
	return float(ys.max() - ys.min()) if len(ys) else 0.0


def kopf_faktor():
	"""Verkleinerung für Kopf-Blätter: wie beim Kopf-Blatt von Kofi (gleiche Zeichengröße laut Auftrag)."""
	a = freistellen(Image.open(VORLAGEN / "kofi_kopf.png"))
	ziel, reihen = bilder_finden(a, [])
	vorn_gross = ausschneiden(a, ziel, reihen[1][0][0])
	vorn_klein = np.array(Image.open(TEILE / "koepfe" / "m1_vorn_normal.png").convert("RGBA"))
	breite = lambda t: np.ptp(np.where((t[..., 3] > 128).any(0))[0])
	return breite(vorn_klein) / breite(vorn_gross), float(np.median([ausschneiden(a, ziel, i)[..., 3].shape[1] for i, _ in reihen[1]]))


def haut(kopf):
	"""Helle Haut (die Volks-Köpfe sind alle hell): deutlich heller und röter als Haare, auch als blondes Haar."""
	f = kopf[..., :3].astype(int)
	r, g, b = f[..., 0], f[..., 1], f[..., 2]
	return (kopf[..., 3] > 128) & (r > 200) & (g > 150) & (b > 120) & (r > g) & (g > b) & (r - b > 40)


def halspunkt(kopf, zeile):
	"""Halspunkt auf der gemeinsamen Halshöhe einer Reihe: Mitte der Haut dort, sonst Mitte des Kopfes."""
	y = int(round(zeile))
	h = haut(kopf)[max(0, y - 5):y + 1]
	xs = np.where(h.any(0))[0]
	if len(xs) >= 3:
		return [round(float(xs.mean()), 1), y]
	spalten = np.where((kopf[..., 3] > 128).any(0))[0]
	return [round(float(spalten.mean()), 1), y]


def koepfe_schneiden():
	faktor_kofi, _ = kopf_faktor()
	kofi = freistellen(Image.open(VORLAGEN / "kofi_kopf.png"))
	ziel_k, reihen_k = bilder_finden(kofi, [])
	breite = lambda t: float(np.ptp(np.where((t[..., 3] > 128).any(0))[0]))
	kofi_breite = np.median([breite(ausschneiden(kofi, ziel_k, i)) for i, _ in reihen_k[1]])
	alle = {}
	(TEILE / "koepfe").mkdir(parents=True, exist_ok=True)
	for blattname, liste in KOEPFE.items():
		a = freistellen(Image.open(VORLAGEN / f"{blattname}.png"))
		ziel, reihen = bilder_finden(a, [])
		if [len(r) for r in reihen] != [len(liste), len(liste)]:
			raise SystemExit(f"{blattname}: Reihen {[len(r) for r in reihen]}, erwartet {[len(liste)] * 2}")
		vorn = [ausschneiden(a, ziel, i) for i, _ in reihen[0]]
		# Gleiche Zeichengröße wie Kofis Kopf-Blatt: an der mittleren Breite der Köpfe von vorne messen
		faktor = faktor_kofi * kofi_breite / np.median([breite(t) for t in vorn])
		punkte = {k[0]: {} for k in liste}
		for richtung, reihe in [("vorn", reihen[0]), ("hinten", reihen[1])]:
			# Laut Auftrag liegt der Halsansatz aller Köpfe einer Reihe auf derselben Höhe: aus der Haut der
			# einzelnen Köpfe die gemeinsame Höhe bestimmen (Mittelwert, Ausreißer wie Zopf oder Knoten zählen kaum)
			koepfe, oben, hals_blatt = [], [], []
			for i, _ in reihe:
				kopf = verkleinern(ausschneiden(a, ziel, i), faktor)
				koepfe.append(kopf)
				top = float(np.where(ziel == i)[0].min())
				oben.append(top)
				hals_blatt.append(top + hals(kopf)[1] / faktor)
			linie = float(np.median(hals_blatt))
			for (kennung, _, _), kopf, top, eigen in zip(liste, koepfe, oben, hals_blatt):
				Image.fromarray(kopf).save(TEILE / "koepfe" / f"{kennung}_{richtung}_normal.png")
				if abs(eigen - linie) * faktor <= 3:
					punkte[kennung][f"{richtung}_normal"] = hals(kopf)
				else:
					punkte[kennung][f"{richtung}_normal"] = halspunkt(kopf, (linie - top) * faktor)
		for kennung, name, geschlecht in liste:
			alle[kennung] = {"name": name, "geschlecht": geschlecht, "hals": punkte[kennung]}
		print(f"{blattname}: {len(liste)} Köpfe, Faktor {faktor:.3f}")
	return alle


def koerper_schneiden(art, novize_oval, daten, volk):
	koerper = f"grund_{art}"
	anims = blatt("grund", art, REIHEN)
	# Größe nach dem Oval: so groß wie der Kopf des Novizen
	faktor = novize_oval / np.median([oval_hoehe(t) for t in anims["idle_vorn"]])
	anims = {anim: skalieren(bilder, faktor) for anim, bilder in anims.items()}
	speichern(koerper, anims, 1.0)
	(TEILE / "koerper").mkdir(parents=True, exist_ok=True)
	for alt in (TEILE / "koerper").glob(f"{koerper}_*.png"):
		alt.unlink()
	name, standard = KOERPER[art]
	eintrag = {"_nur_teile": True, "_name": f"{name} (Baukasten)", "_baukasten": True, "_eigener_kopf": standard,
			"_koepfe": dict(volk, **daten[KOPF_QUELLE]["_koepfe"])}
	for anim, bilder in anims.items():
		for n in range(len(bilder)):
			bild = np.array(Image.open(WURZEL / "assets" / "figuren" / f"{koerper}_{anim}_anim_f{n}.png").convert("RGBA"))
			platz = gruen(bild)
			bildname = f"{anim}_f{n}"
			if not platz.any():
				Image.fromarray(bild).save(TEILE / "koerper" / f"{koerper}_{bildname}.png")
				eintrag[bildname] = {"ganz": True}
				continue
			hals_punkt, winkel = neigung(bild, platz & (bild[..., 3] > 128))
			farbe = bild[..., :3].astype(int)
			gruenlich = farbe[..., 1] > np.maximum(farbe[..., 0], farbe[..., 2]) + 15
			platz |= ndimage.binary_dilation(platz, iterations=2) & gruenlich
			bild[platz, 3] = 0
			Image.fromarray(bild).save(TEILE / "koerper" / f"{koerper}_{bildname}.png")
			eintrag[bildname] = {"hals": hals_punkt, "winkel": winkel, "richtung": richtung_von(anim)}
	daten[koerper] = eintrag
	print(f"{koerper}: Faktor {faktor:.3f}, {sum(len(b) for b in anims.values())} Bilder")


def main():
	daten = json.loads(DATEN.read_text(encoding="utf-8"))
	if len(sys.argv) > 1:
		# Nur einzelne neue Körper schneiden: Köpfe und andere Körper bleiben, wie sie sind.
		# Die Köpfe kommen vom Frauen-Körper (dort stimmen die Halspunkte der neuen Köpfe von vorne), dazu fehlende von den anderen
		novize = np.array(Image.open(WURZEL / "assets" / "figuren" / "novize_m_idle_vorn_anim_f0.png").convert("RGBA"))
		for art in sys.argv[1:]:
			koerper_schneiden(art, oval_hoehe(novize), daten, {})
			koepfe = json.loads(json.dumps(daten["grund_frau"]["_koepfe"]))
			for k in KOERPER:
				for kopf, werte in daten.get(f"grund_{k}", {}).get("_koepfe", {}).items():
					koepfe.setdefault(kopf, json.loads(json.dumps(werte)))
			daten[f"grund_{art}"]["_koepfe"] = koepfe
		DATEN.write_text(json.dumps(daten, ensure_ascii=False, indent="\t", sort_keys=True), encoding="utf-8")
		return
	volk = koepfe_schneiden()
	novize = np.array(Image.open(WURZEL / "assets" / "figuren" / "novize_m_idle_vorn_anim_f0.png").convert("RGBA"))
	novize_oval = oval_hoehe(novize)
	for art in KOERPER:
		koerper_schneiden(art, novize_oval, daten, volk)
	DATEN.write_text(json.dumps(daten, ensure_ascii=False, indent="\t", sort_keys=True))


if __name__ == "__main__":
	main()
