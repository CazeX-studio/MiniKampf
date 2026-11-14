"""Köpfe in allen fünf Richtungen (GRAFIK_AUFTRAG.md Teil U7, 14.11.2026) ins Spiel bringen.

Eingang: tools/vorlagen/welt_u/kopf_<kopf>.png (Reihe 1: gerade von vorne, schräg von vorne, Seite, schräg von hinten,
gerade von hinten, alle nach LINKS; Reihe 2: dieselben ersten drei mit geschlossenen Augen).
Neu ins Spiel kommen nur die Richtungen, die es bisher nicht gab:
  assets/teile/koepfe/<kopf>_gerade_vorn_normal.png, _gerade_vorn_augen_zu.png, _gerade_hinten_normal.png
Schräg und seitlich bleiben die alten Köpfe (dort gibt es alle Gesichter für den Kampf).
Jeder Kopf wird gespiegelt wie die Körper (tools/welt_u_blatt.py) und so verkleinert, dass sein Kopf schräg von vorne
genauso hoch ist wie der alte Kopf schräg von vorne. Die Halspunkte kommen in data/figurteile.json zu jedem Körper,
der diesen Kopf kennt (_koepfe.<kopf>.hals).
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


def hoehe(bild):
	ys = np.where((bild[..., 3] > 128).any(1))[0]
	return ys.max() - ys.min() + 1


def eng(bild):
	ys, xs = np.where(bild[..., 3] > 20)
	return bild[ys.min():ys.max() + 1, xs.min():xs.max() + 1]


def halspunkt(bild, name):
	"""Hals wie bei den alten Köpfen (unterste Hautreihen); von hinten ist kaum Haut zu sehen: Mitte der Unterkante."""
	if "hinten" not in name:
		try:
			return hals(bild)
		except (ValueError, IndexError):
			pass
	fest = bild[..., 3] > 128
	unten = int(np.where(fest.any(1))[0].max())
	xs = np.where(fest[unten - 2:unten + 1].any(0))[0]
	return [round(float(xs.mean()), 1), unten + 1]


def main():
	daten = json.loads(DATEN.read_text(encoding="utf-8"))
	for kopf in sys.argv[1:] or ["w1", "w2", "w3", "m1", "m2", "m3"]:
		a = freistellen(Image.open(QUELLE / f"kopf_{kopf}.png"))
		ziel, reihen = bilder_finden(a, [])
		if [len(r) for r in reihen] != [5, 3]:
			raise SystemExit(f"kopf_{kopf}: Reihen {[len(r) for r in reihen]}, erwartet [5, 3]")
		stuecke = [[eng(np.ascontiguousarray(ausschneiden(a, ziel, i)[:, ::-1])) for i, _ in r] for r in reihen]
		alt = np.array(Image.open(KOEPFE / f"{kopf}_vorn_normal.png").convert("RGBA"))
		faktor = hoehe(alt) / hoehe(stuecke[0][1])
		punkte = {}
		groessen = {}
		for plaetze, reihe in zip(PLAETZE, stuecke):
			for name, t in zip(plaetze, reihe):
				if name is None:
					continue
				bild = Image.fromarray(t)
				bild = bild.resize((max(1, round(bild.width * faktor)), max(1, round(bild.height * faktor))), Image.LANCZOS)
				bild = np.array(bild)
				Image.fromarray(bild).save(KOEPFE / f"{kopf}_{name}.png")
				punkte[name] = halspunkt(bild, name)
				groessen[name] = bild.shape[1]
		# Von hinten: Zopf oder lange Haare reichen unter den Hals. Der Hals sitzt dort, wo er von vorne sitzt
		# (gleiche Höhe ab Scheitel, gleicher Abstand zur Mitte, gespiegelt)
		vorn = punkte["gerade_vorn_normal"]
		punkte["gerade_hinten_normal"] = [round(groessen["gerade_hinten_normal"] / 2 - (vorn[0] - groessen["gerade_vorn_normal"] / 2), 1), vorn[1]]
		n = 0
		for koerper, eintrag in daten.items():
			if isinstance(eintrag, dict) and kopf in eintrag.get("_koepfe", {}):
				eintrag["_koepfe"][kopf]["hals"].update(punkte)
				n += 1
		print(f"{kopf}: Faktor {faktor:.3f}, Halspunkte {punkte}, bei {n} Körpern eingetragen")
	DATEN.write_text(json.dumps(daten, ensure_ascii=False, indent="\t", sort_keys=True), encoding="utf-8")


if __name__ == "__main__":
	main()
