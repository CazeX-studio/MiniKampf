"""Köpfe in allen fünf Richtungen (GRAFIK_AUFTRAG.md Teil U7, 14.11.2026) ins Spiel bringen.

Eingang: tools/vorlagen/welt_u/kopf_<kopf>.png (Reihe 1: gerade von vorne, schräg von vorne, Seite, schräg von hinten,
gerade von hinten, alle nach LINKS; Reihe 2: dieselben ersten drei mit geschlossenen Augen).
Neu ins Spiel kommen nur die Richtungen, die es bisher nicht gab:
  assets/teile/koepfe/<kopf>_gerade_vorn_normal.png, _gerade_vorn_augen_zu.png, _gerade_hinten_normal.png
Schräg und seitlich bleiben die alten Köpfe (dort gibt es alle Gesichter für den Kampf).
Jeder Kopf wird gespiegelt wie die Körper (tools/welt_u_blatt.py) und so verkleinert, dass sein Kopf schräg von vorne
genauso hoch ist wie der alte Kopf schräg von vorne. Die Halspunkte kommen in data/figurteile.json zu jedem Körper,
der diesen Kopf kennt (_koepfe.<kopf>.hals).
Köpfe der Leute (Teil U12, 15.11.2026: v_*, a_*, k_*) und der Nebenfiguren (Teil U2, z. B. borko, hanne): Sie hatten nur schräg von vorne und hinten, keine Seite und keine
Gesichter. Bei ihnen ersetzt das neue Blatt alle Ansichten (auch schräg, damit alles gleich gemalt ist), dazu Seite und Augen zu.
Größe: Der alte Kopf schräg von vorne wird beim ersten Lauf nach tools/vorlagen/welt_u/kopf_<kopf>_alt_vorn.png gesichert
und bleibt das Maß.
Aufruf: python3 tools/koepfe_u.py [kopf …]
"""
import json
import sys
from pathlib import Path

import numpy as np
from PIL import Image

WURZEL = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(WURZEL / "tools"))
from monster_bilder import ausschneiden, bilder_finden, freistellen  # noqa: E402
from kopf_koerper import hals  # noqa: E402

QUELLE = WURZEL / "tools" / "vorlagen" / "welt_u"
KOEPFE = WURZEL / "assets" / "teile" / "koepfe"
DATEN = WURZEL / "data" / "figurteile.json"
## Reihe, Platz im Blatt -> Name im Spiel (None = gibt es schon, bleibt der alte Kopf)
PLAETZE = [
	["gerade_vorn_normal", None, None, None, "gerade_hinten_normal"],
	["gerade_vorn_augen_zu", None, None],
]
PLAETZE_LEUTE = [
	["gerade_vorn_normal", "vorn_normal", "seite_normal", "hinten_normal", "gerade_hinten_normal"],
	["gerade_vorn_augen_zu", "vorn_augen_zu", "seite_augen_zu"],
]


## Blätter, auf denen ChatGPT den Kopf schräg von vorne andersherum gemalt hat als die Seite (a_w2, Marco 15.11.2026):
## dort wird schräg von vorne nicht gespiegelt
SCHRAEG_ANDERS = ["a_w2", "brom", "layla"]


## Halspunkte von Hand (16.11.2026): Langer heller Bart oder Zopf sieht für die Suche wie Haut aus, der Punkt landete
## an der Bartspitze oder am Kinn. Hier steht, wo der Hals wirklich ist (im fertigen, verkleinerten Bild)
HALS_VON_HAND = {
	"tamm": {"seite_normal": [27, 53], "seite_augen_zu": [27, 53]},
	"rashid": {"seite_normal": [27, 50], "seite_augen_zu": [27, 50], "hinten_normal": [28, 50]},
	"lotte": {"seite_normal": [36, 54], "seite_augen_zu": [36, 54]},
	"borko": {"seite_normal": [27, 59], "seite_augen_zu": [27, 59]},
}


## Novizen-Köpfe behalten schräg und seitlich ihre alten Bilder (dort gibt es alle Gesichter für den Kampf). Alle anderen
## (Leute U12, Nebenfiguren U2) bekommen alle Ansichten aus dem neuen Blatt
NOVIZEN_KOEPFE = ["m1", "m2", "m3", "w1", "w2", "w3"]


def leute(kopf):
	return kopf not in NOVIZEN_KOEPFE


def hoehe(bild):
	ys = np.where((bild[..., 3] > 128).any(1))[0]
	return ys.max() - ys.min() + 1


def eng(bild):
	ys, xs = np.where(bild[..., 3] > 20)
	return bild[ys.min():ys.max() + 1, xs.min():xs.max() + 1]


def halspunkt(bild, name):
	"""Hals wie bei den alten Köpfen (unterste Hautreihen); von hinten ist kaum Haut zu sehen: Mitte der Unterkante."""
	if "hinten" not in name or name == "hinten_normal":
		try:
			return hals(bild)
		except (ValueError, IndexError):
			pass
	fest = bild[..., 3] > 128
	unten = int(np.where(fest.any(1))[0].max())
	xs = np.where(fest[unten - 2:unten + 1].any(0))[0]
	return [round(float(xs.mean()), 1), unten + 1]


def haut_hals(bild, haut):
	"""Köpfe der Leute: Hals = unterste Reihe mit mehreren hautfarbenen Punkten (Zopf, Bart und lange Haare zählen nicht)."""
	fest = bild[..., 3] > 128
	nah = fest & (np.abs(bild[..., :3].astype(int) - haut).sum(-1) < 75)
	reihen = np.where(nah.sum(1) >= max(3, bild.shape[1] // 12))[0]
	if len(reihen) == 0:
		reihen = np.where(nah.sum(1) >= 2)[0]
	if len(reihen) == 0:
		return None
	unten = int(reihen.max())
	return [round(float(np.where(nah[unten - 2:unten + 1].any(0))[0].mean()), 1), unten + 1]


def hautfarbe(bild):
	h, b = bild.shape[:2]
	feld = bild[int(h * 0.55):int(h * 0.8), int(b * 0.35):int(b * 0.65)].reshape(-1, 4)
	feld = feld[feld[:, 3] > 200, :3].astype(int)
	hell = feld[feld.sum(1) > np.percentile(feld.sum(1), 50)]
	return np.median(hell, axis=0)


def main():
	daten = json.loads(DATEN.read_text(encoding="utf-8"))
	for kopf in sys.argv[1:] or ["w1", "w2", "w3", "m1", "m2", "m3"]:
		a = freistellen(Image.open(QUELLE / f"kopf_{kopf}.png"))
		ziel, reihen = bilder_finden(a, [])
		if [len(r) for r in reihen] != [5, 3]:
			raise SystemExit(f"kopf_{kopf}: Reihen {[len(r) for r in reihen]}, erwartet [5, 3]")
		stuecke = [[eng(np.ascontiguousarray(ausschneiden(a, ziel, i)[:, ::-1])) for i, _ in r] for r in reihen]
		mass = KOEPFE / f"{kopf}_vorn_normal.png"
		if leute(kopf):
			gesichert = QUELLE / f"kopf_{kopf}_alt_vorn.png"
			if not gesichert.exists():
				gesichert.write_bytes(mass.read_bytes())
			mass = gesichert
		alt = np.array(Image.open(mass).convert("RGBA"))
		faktor = hoehe(alt) / hoehe(stuecke[0][1])
		punkte = {}
		groessen = {}
		for plaetze, reihe in zip(PLAETZE_LEUTE if leute(kopf) else PLAETZE, stuecke):
			for name, t in zip(plaetze, reihe):
				if name is None:
					continue
				if kopf in SCHRAEG_ANDERS and name.startswith("vorn_"):
					t = np.ascontiguousarray(t[:, ::-1])
				bild = Image.fromarray(t)
				bild = bild.resize((max(1, round(bild.width * faktor)), max(1, round(bild.height * faktor))), Image.LANCZOS)
				bild = np.array(bild)
				Image.fromarray(bild).save(KOEPFE / f"{kopf}_{name}.png")
				if leute(kopf):
					if name == "gerade_vorn_normal":
						haut = hautfarbe(bild)
					punkte[name] = haut_hals(bild, haut)
					if punkte[name] is None:
						print(f"{kopf} {name}: kein Hals gefunden, Mitte der Unterkante")
						punkte[name] = halspunkt(bild, "hinten")
				else:
					punkte[name] = halspunkt(bild, name)
				groessen[name] = bild.shape[1]
		# Von hinten: Zopf oder lange Haare reichen unter den Hals. Der Hals sitzt dort, wo er von vorne sitzt
		# (gleiche Höhe ab Scheitel, gleicher Abstand zur Mitte, gespiegelt)
		vorn = punkte["gerade_vorn_normal"]
		if leute(kopf):
			# Von hinten verdecken Zopf oder lange Haare den Hals: liegt der gefundene Hals nicht auf der Höhe wie von vorne
			# (im Blatt sitzen alle Hälse gleich hoch), gilt die Ansicht von vorne gespiegelt
			for hinten, von in [("gerade_hinten_normal", "gerade_vorn_normal"), ("hinten_normal", "vorn_normal")]:
				if abs(punkte[hinten][1] - punkte[von][1]) > 4:
					print(f"{kopf} {hinten}: Hals von vorne übernommen")
					punkte[hinten] = [round(groessen[hinten] / 2 - (punkte[von][0] - groessen[von] / 2), 1), punkte[von][1]]
		if not leute(kopf):
			punkte["gerade_hinten_normal"] = [round(groessen["gerade_hinten_normal"] / 2 - (vorn[0] - groessen["gerade_vorn_normal"] / 2), 1), vorn[1]]
		for name, punkt in HALS_VON_HAND.get(kopf, {}).items():
			punkte[name] = punkt
		n = 0
		for koerper, eintrag in daten.items():
			if isinstance(eintrag, dict) and kopf in eintrag.get("_koepfe", {}):
				eintrag["_koepfe"][kopf]["hals"].update(punkte)
				n += 1
		print(f"{kopf}: Faktor {faktor:.3f}, Halspunkte {punkte}, bei {n} Körpern eingetragen")
	DATEN.write_text(json.dumps(daten, ensure_ascii=False, indent="\t", sort_keys=True), encoding="utf-8")


if __name__ == "__main__":
	main()
