"""Zerlegt die fertigen Bilder einer Figur in Kopf und Körper (Projekt 11, Figuren wie bei Ragnarok).

Grundlage ist das Kopf-Blatt der Figur (tools/vorlagen/<figur>_kopf.png, Auftrag B7 in Spieldesign/GRAFIK_AUFTRAG.md):
1. Die Köpfe des Blatts werden ausgeschnitten, auf Spielgröße gebracht und gespeichert:
   assets/teile/koepfe/<figur>_<richtung>_<ausdruck>.png (richtung: seite, vorn, hinten).
2. In jedem fertigen Bild assets/figuren/<figur>_<anim>_anim_f<n>.png wird gesucht, wo der Kopf sitzt
   (der normale Kopf der passenden Richtung wird so lange verschoben, bis er am besten passt).
3. Der alte Kopf wird dort herausgenommen: assets/teile/koerper/<figur>_<anim>_f<n>.png (Körper ohne Kopf,
   gleiche Bildgröße) und assets/teile/kopf/<figur>_<anim>_f<n>.png (der alte Kopf, eng zugeschnitten).
data/figurteile.json merkt sich pro Bild: alt = Ecke des alten Kopfes, kopf = Ecke des neuen Kopfes, richtung.
Bilder, in denen der Kopf nicht sicher gefunden wird (z. B. liegend), bleiben ganz („ganz“: true).
Aufruf: python3 tools/kopf_koerper.py [figur …]   (braucht numpy, scipy und Pillow)
"""
import json
import re
import sys
from pathlib import Path

import numpy as np
from PIL import Image
from scipy import ndimage

WURZEL = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(WURZEL / "tools"))
from monster_bilder import bilder_finden, ausschneiden, freistellen  # noqa: E402

FIGUREN_ORDNER = WURZEL / "assets" / "figuren"
VORLAGEN = WURZEL / "tools" / "vorlagen"
TEILE = WURZEL / "assets" / "teile"
DATEN = WURZEL / "data" / "figurteile.json"

## Reihen des Kopf-Blatts (wie im Auftrag B7)
KOPF_BLATT = [
	("seite", ["normal", "schmerz", "freude", "augen_zu", "entschlossen"]),
	("vorn", ["normal", "schmerz", "freude", "augen_zu"]),
	("hinten", ["normal", "geneigt"]),
]
## Mit diesen Bildern wird die Größe der Köpfe bestimmt (Stehen in jeder Richtung)
VORBILD = {"seite": "idle_f0", "vorn": "idle_vorn_f0", "hinten": "idle_hinten_f0"}
## Figur -> Erkennungsfarbe des Halstuchs (bleibt immer beim Körper)
TUCH = {
	"kofi": lambda r, g, b: (r > 120) & (g > r * 0.55) & (b < r * 0.3),
}
## Diese Animationen schauen eher nach vorne als zur Seite (Sieg, Fähigkeit mit der Hand auf der Brust)
RICHTUNG = {"victory": "vorn", "cast": "vorn"}
## Diese Bilder bleiben immer ganz (liegend: ein aufrechter Kopf passt dort nicht)
GANZ = {"kofi": ["death_f4", "death_f5"]}
## Köpfe sind namenlos und nach Geschlecht nummeriert (m1, m2 … / w1, w2 …), den Namen gibt der Spieler.
## Der eigene Kopf der Figur (aus ihrem Kopf-Blatt <figur>_kopf.png) bekommt diese Kennung:
EIGENER_KOPF = {"kofi": "m1"}
## Weitere Köpfe aus Kopf-Blättern (tools/vorlagen/<kennung>_kopf.png), die auf den Körper der Figur passen.
## Sie werden mit derselben Größe wie die Köpfe der Figur verkleinert.
WEITERE_KOEPFE = {"kofi": ["w1", "m2", "m3", "w2", "w3"]}


def kopf_name(kennung):
	"""Anzeigename eines Kopfes: „Novize m1“ bzw. „Novizin w1“."""
	return ("Novizin " if kennung.startswith("w") else "Novize ") + kennung


## Passt ein Kopf so viel schlechter als im Vorbild, gilt er als nicht gefunden
SCHLECHTER = 2.6


def koepfe_schneiden(kopf_id):
	"""Köpfe des Blatts tools/vorlagen/<kopf_id>_kopf.png in voller Größe."""
	a = freistellen(Image.open(VORLAGEN / f"{kopf_id}_kopf.png"))
	ziel, reihen = bilder_finden(a, [])
	erwartet = [len(namen) for _, namen in KOPF_BLATT]
	if [len(r) for r in reihen] != erwartet:
		raise SystemExit(f"{kopf_id}_kopf: Reihen {[len(r) for r in reihen]}, erwartet {erwartet}")
	koepfe = {}
	for (richtung, namen), reihe in zip(KOPF_BLATT, reihen):
		for name, (i, _) in zip(namen, reihe):
			koepfe[f"{richtung}_{name}"] = ausschneiden(a, ziel, i)
	return koepfe


def kinn(kopf):
	"""Unterste Reihe, die noch mindestens halb so breit ist wie der Kopf (darunter: schmaler Halsansatz)."""
	breite = (kopf[..., 3] > 128).sum(1)
	return int(np.where(breite > breite.max() * 0.5)[0].max())


def hals(kopf):
	"""Halspunkt eines Kopfes: Mitte der untersten Hautreihen (Haut = deutlich anders als die Haarfarbe oben,
	warm und hell genug, kein Haarband). So sitzen Köpfe mit Zopf oder langen Haaren trotzdem richtig auf dem Hals."""
	fest = kopf[..., 3] > 128
	farbe = kopf[..., :3].astype(int)
	ys = np.where(fest.any(1))[0]
	oben = fest.copy()
	oben[ys.min() + max(2, (ys.max() - ys.min()) // 5):] = False
	haar = np.median(farbe[oben], 0)
	r, g, b = farbe[..., 0], farbe[..., 1], farbe[..., 2]
	haut = fest & (np.abs(farbe - haar).sum(-1) > 110) & (r > 110) & (g >= r * 0.52) & (b < g) & (r > b + 55)
	# Nur das größte Hautstück (Gesicht mit Hals, Mund und Augen geschlossen), kleine Flecken wie ein Haarband zählen nicht
	haut = ndimage.binary_closing(haut, iterations=3) & fest
	lab, n = ndimage.label(haut)
	haut = lab == (int(np.argmax(ndimage.sum(haut, lab, range(1, n + 1)))) + 1)
	hy, hx = np.where(haut)
	unten = hy.max()
	return [round(float(hx[hy >= unten - 3].mean()), 1), int(unten + 1)]


def verkleinern(kopf, faktor):
	bild = Image.fromarray(kopf)
	return np.array(bild.resize((max(1, round(bild.width * faktor)), max(1, round(bild.height * faktor))), Image.LANCZOS))


def vormultipliziert(a):
	a = a.astype(np.float32)
	return np.concatenate([a[..., :3] * a[..., 3:4] / 255.0, a[..., 3:4]], -1)


def suchen(bild, kopf):
	"""Beste Stelle (x, y) für den Kopf im Bild und wie gut er passt (kleiner = besser). Verglichen wird nur
	oberhalb des Kinns, der Halsansatz steckt im Original unter dem Halstuch."""
	vorlage = vormultipliziert(kopf[:kinn(kopf) + 1])
	hoehe, breite = vorlage.shape[:2]
	rand = max(hoehe, breite)
	b = np.pad(vormultipliziert(bild), ((rand, rand), (rand, rand), (0, 0)))
	beste = (1e18, 0, 0)
	for y in range(-hoehe // 3, bild.shape[0] - hoehe // 2):
		for x in range(-breite // 2, bild.shape[1] - breite // 2):
			wert = float(np.abs(b[y + rand:y + rand + hoehe, x + rand:x + rand + breite] - vorlage).mean())
			if wert < beste[0]:
				beste = (wert, x, y)
	return beste


def richtung_von(anim):
	if anim in RICHTUNG:
		return RICHTUNG[anim]
	if anim.endswith("_vorn"):
		return "vorn"
	if anim.endswith("_hinten"):
		return "hinten"
	return "seite"


def main():
	daten = json.loads(DATEN.read_text()) if DATEN.exists() else {}
	for figur in sys.argv[1:] or list(TUCH):
		gross = koepfe_schneiden(figur)
		bilder = {}
		for pfad in sorted(FIGUREN_ORDNER.glob(f"{figur}_*_anim_f*.png")):
			m = re.match(rf"{figur}_(.+)_anim_f(\d+)\.png", pfad.name)
			bilder[f"{m.group(1)}_f{int(m.group(2))}"] = np.array(Image.open(pfad).convert("RGBA"))
		# Größe je Richtung: der Faktor, mit dem der normale Kopf am besten auf das Stehbild passt
		koepfe, guete, faktoren = {}, {}, {}
		for richtung, vorbild in VORBILD.items():
			beste = None
			for faktor in np.arange(0.20, 0.36, 0.01):
				wert = suchen(bilder[vorbild], verkleinern(gross[f"{richtung}_normal"], faktor))[0]
				if beste is None or wert < beste[0]:
					beste = (wert, faktor)
			guete[richtung] = beste[0]
			faktoren[richtung] = beste[1]
			for name, kopf in gross.items():
				if name.startswith(richtung + "_"):
					koepfe[name] = verkleinern(kopf, beste[1])
			print(f"{figur} {richtung}: Faktor {beste[1]:.3f}, Abweichung {beste[0]:.1f}")
		for ordner in ["kopf", "koerper", "koepfe"]:
			(TEILE / ordner).mkdir(parents=True, exist_ok=True)
			for alt in (TEILE / ordner).glob(f"{figur}_*.png"):
				alt.unlink()
		alle_koepfe = {}
		eigener = EIGENER_KOPF.get(figur, figur)
		for kopf_id in [eigener] + WEITERE_KOEPFE.get(figur, []):
			for alt in (TEILE / "koepfe").glob(f"{kopf_id}_*.png"):
				alt.unlink()
			teile = koepfe if kopf_id == eigener else {
				name: verkleinern(k, faktoren[name.split("_")[0]]) for name, k in koepfe_schneiden(kopf_id).items()}
			punkte = {}
			for name, kopf in teile.items():
				Image.fromarray(kopf).save(TEILE / "koepfe" / f"{kopf_id}_{name}.png")
				# Halspunkt am normalen Kopf der Richtung messen, die anderen Gesichter daran ausrichten
				# (sie sind fast gleich, nur das Gesicht ändert sich), damit der Kopf beim Gesichtswechsel nicht springt
				normal = teile[name.split("_")[0] + "_normal"]
				punkt = hals(normal)
				_, dx, dy = suchen(normal, kopf)
				punkte[name] = [round(punkt[0] - dx, 1), int(punkt[1] - dy)]
			alle_koepfe[kopf_id] = {"name": kopf_name(kopf_id), "geschlecht": kopf_id[0], "hals": punkte}
		eintrag = {"_koepfe": alle_koepfe, "_eigener_kopf": eigener}
		for name, bild in bilder.items():
			richtung = richtung_von(name.rsplit("_f", 1)[0])
			kopf = koepfe[f"{richtung}_normal"]
			wert, x, y = suchen(bild, kopf)
			if wert > guete[richtung] * SCHLECHTER or name in GANZ.get(figur, []):
				Image.fromarray(bild).save(TEILE / "koerper" / f"{figur}_{name}.png")
				eintrag[name] = {"ganz": True}
				print(f"  {name}: ganz (Abweichung {wert:.1f})")
				continue
			# Alter Kopf: alles in der (etwas vergrößerten) Fläche des neuen Kopfes oberhalb des Kinns,
			# außer Halstuch und Metall (das Schwert bleibt vor dem Kopf)
			k = kinn(kopf)
			maske = kopf[:k + 1, :, 3] > 60
			flaeche = np.zeros(bild.shape[:2], bool)
			y0, x0 = max(y, 0), max(x, 0)
			y1, x1 = min(y + maske.shape[0], bild.shape[0]), min(x + maske.shape[1], bild.shape[1])
			flaeche[y0:y1, x0:x1] = maske[y0 - y:y1 - y, x0 - x:x1 - x]
			flaeche = ndimage.binary_dilation(flaeche, iterations=3)
			flaeche[max(0, min(y + k + 1, bild.shape[0])):] = False
			farbe = bild[..., :3].astype(int)
			r, g, b = farbe[..., 0], farbe[..., 1], farbe[..., 2]
			hoch, tief = farbe.max(-1), farbe.min(-1)
			# Halstuch: nur das größte zusammenhängende Stück in Tuchfarbe (Hautglanz im Gesicht zählt nicht)
			tuch = TUCH[figur](r, g, b) & (bild[..., 3] > 60)
			lab, n = ndimage.label(tuch, structure=np.ones((3, 3)))
			if n > 0:
				tuch = lab == (int(np.argmax(ndimage.sum(tuch, lab, range(1, n + 1)))) + 1)
			flaeche &= ~tuch & ~((hoch - tief < 35) & (hoch > 120)) & (bild[..., 3] > 0)
			alt = bild.copy()
			alt[~flaeche, 3] = 0
			koerper = bild.copy()
			koerper[flaeche, 3] = 0
			ys, xs = np.where(flaeche)
			Image.fromarray(koerper).save(TEILE / "koerper" / f"{figur}_{name}.png")
			Image.fromarray(alt[ys.min():ys.max() + 1, xs.min():xs.max() + 1]).save(TEILE / "kopf" / f"{figur}_{name}.png")
			punkt = alle_koepfe[eigener]["hals"][f"{richtung}_normal"]
			eintrag[name] = {"alt": [int(xs.min()), int(ys.min())], "hals": [round(x + punkt[0], 1), y + punkt[1]],
					"richtung": richtung}
		daten[figur] = eintrag
		ganz = [k for k, v in eintrag.items() if isinstance(v, dict) and v.get("ganz")]
		print(f"{figur}: Köpfe {list(alle_koepfe)}; {len(bilder)} Bilder, {len(bilder) - len(ganz)} getrennt, ganz geblieben: {ganz}")
	daten["_hinweis"] = ("Kopf und Körper der Figuren (Projekt 11), erzeugt mit tools/kopf_koerper.py. Pro Bild: alt = linke obere "
			"Ecke des alten Kopfes (assets/teile/kopf), hals = Halspunkt im Bild, auf den jeder Kopf gesetzt wird, "
			"richtung = seite/vorn/hinten; ganz = Bild nicht getrennt (z. B. liegend). _koepfe = alle Köpfe (m1, w1 …), "
			"die auf diesen Körper passen (assets/teile/koepfe), mit Geschlecht und Halspunkt je Richtung und Gesicht; "
			"_eigener_kopf = der Kopf, mit dem die Figur gezeichnet wurde.")
	DATEN.write_text(json.dumps(daten, ensure_ascii=False, indent="\t", sort_keys=True))


if __name__ == "__main__":
	main()
