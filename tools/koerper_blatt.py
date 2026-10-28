"""Körper-Blätter mit grünem Kopf-Platzhalter einbauen (Projekt 11, Auftrag B8 in Spieldesign/GRAFIK_AUFTRAG.md).

Blätter in tools/vorlagen/<körper>_kampf_a.png, _kampf_b.png, _welt.png (Aufbau wie Kofis Blätter, fehlende Blätter
werden übersprungen). Ablauf:
1. Zerlegen wie bei tools/figur_bilder.py: ganze Bilder (mit grünem Oval) nach assets/figuren/<körper>_<anim>_anim_f<n>.png.
2. Das grüne Oval wird herausgenommen: assets/teile/koerper/<körper>_<anim>_f<n>.png.
3. Halspunkt = Mitte des Ovals, knapp unter seiner sichtbaren Unterkante (dort, wo es im Halstuch verschwindet).
   Dort setzt das Spiel den gewählten Kopf ein (alle Köpfe aus tools/kopf_koerper.py passen).
data/figurteile.json: pro Bild hals, winkel (Neigung des Kopfes aus der Längsachse des Ovals) und richtung, dazu _nur_teile (das Spiel setzt immer zusammen) und _koepfe.
Aufruf: python3 tools/koerper_blatt.py [körper …]   (braucht numpy, scipy und Pillow; vorher tools/kopf_koerper.py)
"""
import json
import sys
from pathlib import Path

import numpy as np
from PIL import Image
from scipy import ndimage

WURZEL = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(WURZEL / "tools"))
from figur_bilder import FIGUREN, VORLAGEN, blatt  # noqa: E402
from kopf_koerper import richtung_von  # noqa: E402
from monster_bilder import speichern  # noqa: E402

TEILE = WURZEL / "assets" / "teile"
DATEN = WURZEL / "data" / "figurteile.json"

## Körper -> Name im Editor. Die Blätter sind aufgebaut wie Kofis (siehe FIGUREN["kofi"] in figur_bilder.py).
KOERPER = {"novize_m": "Novize (m)", "novize_w": "Novizin (w)"}
## Abweichende Reihen einzelner Blätter (sonst wie Kofi): Körper -> Blatt -> Reihen
REIHEN = {
	"novize_m": {
		"kampf_b": [[("attack", 6)], [("death", 6)], [("victory", 4), ("cast", 3)]],
		"welt": [[("idle_vorn", 5), ("run_vorn", 5)], [("idle_hinten", 5), ("run_hinten", 5)]],
	},
}
## Mit dieser Animation wird jedes weitere Blatt auf die Größe von Blatt 1 gebracht (aufrecht stehend, Kopf frei)
GROESSE_VON = {"kampf_a": "idle", "kampf_b": "cast", "welt": "idle_vorn"}
## Blätter mit runden Kreisen statt länglicher Ovale (gezeichnet vor dem Hinweis vom 28.10.): Kopf bleibt dort gerade
RUND = {"novize_m": ["kampf_a"], "novize_w": ["kampf_a"]}
## Ab diesem Verhältnis Höhe/Breite gilt das Oval als länglich; dann wird der Kopf mit dem Oval geneigt
LAENGLICH = 1.12
## Von dieser Figur kommen die Köpfe (alle Köpfe sind auf ihre Größe gebracht)
KOPF_QUELLE = "kofi"
## So weit unter der sichtbaren Unterkante des Ovals sitzt der Hals (Pixel)
HALS_TIEFE = 2


def gruen(a):
	r, g, b = (a[..., i].astype(int) for i in range(3))
	return (a[..., 3] > 20) & (g > r + 60) & (g > b + 60)


def kopf_hoehe(bilder):
	"""Mittlere Höhe von der Oberkante des Ovals bis zu den Füßen."""
	werte = []
	for t in bilder:
		ys = np.where(gruen(t).any(1))[0]
		fuesse = np.where((t[..., 3] > 128).any(1))[0].max()
		if len(ys):
			werte.append(fuesse - ys.min())
	return float(np.median(werte))


def skalieren(bilder, faktor):
	return [np.array(Image.fromarray(t).resize((max(1, round(t.shape[1] * faktor)), max(1, round(t.shape[0] * faktor))),
			Image.LANCZOS)) for t in bilder]


def ellipse(xs, ys):
	"""Ellipse durch Randpunkte (direkte Anpassung nach Fitzgibbon): Mitte, Halbachsen (lang, kurz), Richtung der langen Achse."""
	d = np.stack([xs * xs, xs * ys, ys * ys, xs, ys, np.ones_like(xs)], 1)
	s = d.T @ d
	c = np.zeros((6, 6))
	c[0, 2] = c[2, 0] = 2
	c[1, 1] = -1
	werte, vektoren = np.linalg.eig(np.linalg.solve(s, c))
	werte, vektoren = np.real(werte), np.real(vektoren)
	a = vektoren[:, np.argmax(werte)]
	m = np.array([[a[0], a[1] / 2], [a[1] / 2, a[2]]])
	mitte = np.linalg.solve(2 * m, -a[3:5])
	k = mitte @ m @ mitte - a[5]
	ew, ev = np.linalg.eigh(m / k)
	halb = 1 / np.sqrt(np.abs(ew))
	lang = int(np.argmax(halb))
	return mitte, halb[lang], halb[1 - lang], ev[:, lang]


def neigung(bild, platz, rund=False):
	"""Halspunkt und Neigung des Kopfes (Grad, im Uhrzeigersinn) aus dem grünen Oval. Gemessen wird nur am freien Rand
	(wo das Oval an den Hintergrund grenzt), denn unten verdeckt das Halstuch einen Teil. Die lange Achse zeigt die
	Neigung, „unten“ ist die Richtung zum Körper. Der Hals liegt auf dieser Achse, knapp hinter dem sichtbaren Rand des
	Ovals (dort verschwindet es im Halstuch). Runde Ovale (Blatt 1) gelten als gerade."""
	frei = platz & ndimage.binary_dilation(bild[..., 3] < 30, iterations=2)
	ys, xs = np.where(frei)
	mitte, lang, kurz, achse = ellipse(xs.astype(float), ys.astype(float))
	unten = achse / np.linalg.norm(achse)
	if rund or lang / kurz < LAENGLICH:
		unten = np.array([0.0, 1.0])
	# „Unten“ zeigt zum Körper (Schwerpunkt der übrigen Bildpunkte)
	ky, kx = np.where((bild[..., 3] > 128) & ~platz)
	if np.dot(np.array([kx.mean(), ky.mean()]) - mitte, unten) < 0:
		unten = -unten
	punkt = mitte.copy()
	for _ in range(400):
		weiter = punkt + unten * 0.5
		x, y = int(round(weiter[0])), int(round(weiter[1]))
		if not (0 <= y < platz.shape[0] and 0 <= x < platz.shape[1]) or not platz[y, x]:
			break
		punkt = weiter
	punkt = punkt + unten * HALS_TIEFE
	winkel = float(np.degrees(np.arctan2(-unten[0], unten[1])))
	return [round(float(punkt[0]), 1), round(float(punkt[1]), 1)], round(winkel, 1)


def main():
	daten = json.loads(DATEN.read_text()) if DATEN.exists() else {}
	for koerper in sys.argv[1:] or list(KOERPER):
		anims = {}
		ziel = None
		runde = set()
		for name, reihen in FIGUREN[KOPF_QUELLE].items():
			if not (VORLAGEN / f"{koerper}_{name}.png").exists():
				print(f"{koerper}: Blatt {name} fehlt noch")
				continue
			teil = blatt(koerper, name, REIHEN.get(koerper, {}).get(name, reihen))
			# Alle Blätter gleich groß wie Blatt 1 (gemessen von der Oberkante des Ovals bis zu den Füßen)
			hoehe = kopf_hoehe(teil[GROESSE_VON[name]])
			if ziel is None:
				ziel = hoehe
			else:
				teil = {anim: skalieren(bilder, ziel / hoehe) for anim, bilder in teil.items()}
				print(f"{koerper}: Blatt {name} angepasst mit Faktor {ziel / hoehe:.3f}")
			anims.update(teil)
			for anim in teil:
				if name in RUND.get(koerper, []):
					runde.add(anim)
		speichern(koerper, anims, 1.0)
		(TEILE / "koerper").mkdir(parents=True, exist_ok=True)
		for alt in (TEILE / "koerper").glob(f"{koerper}_*.png"):
			alt.unlink()
		eintrag = {"_nur_teile": True, "_name": KOERPER[koerper], "_koepfe": daten[KOPF_QUELLE]["_koepfe"]}
		for anim, bilder in anims.items():
			for n in range(len(bilder)):
				bild = np.array(Image.open(WURZEL / "assets" / "figuren" / f"{koerper}_{anim}_anim_f{n}.png").convert("RGBA"))
				platz = gruen(bild)
				name = f"{anim}_f{n}"
				if not platz.any():
					Image.fromarray(bild).save(TEILE / "koerper" / f"{koerper}_{name}.png")
					eintrag[name] = {"ganz": True}
					continue
				hals, winkel = neigung(bild, platz & (bild[..., 3] > 128), anim in runde)
				# Grünliche Ränder des Ovals mit wegnehmen
				farbe = bild[..., :3].astype(int)
				gruenlich = farbe[..., 1] > np.maximum(farbe[..., 0], farbe[..., 2]) + 15
				platz |= ndimage.binary_dilation(platz, iterations=2) & gruenlich
				bild[platz, 3] = 0
				Image.fromarray(bild).save(TEILE / "koerper" / f"{koerper}_{name}.png")
				eintrag[name] = {"hals": hals, "winkel": winkel, "richtung": richtung_von(anim)}
		daten[koerper] = eintrag
		print(f"{koerper}: {sum(len(b) for b in anims.values())} Bilder")
	DATEN.write_text(json.dumps(daten, ensure_ascii=False, indent="\t", sort_keys=True))


if __name__ == "__main__":
	main()
