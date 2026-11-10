"""Neue Köpfe von vorne für die Frauen (Alpha 19–21, GRAFIK_AUFTRAG.md Teil K1).

Blatt tools/vorlagen/kopf_vorn_<figur>.png: zwei Köpfe auf Pink, links Augen offen, rechts Augen zu.
Der Kopf ersetzt assets/teile/koepfe/<figur>_vorn_normal.png (gleiche Höhe wie der alte Kopf), der zweite wird
<figur>_vorn_augen_zu.png. Die Halspunkte kommen in data/figurteile.json beim Körper, der den Kopf trägt.
Blatt mit mehreren Köpfen (BLAETTER): oben alle mit offenen Augen, unten dieselben mit geschlossenen.
Aufruf: python3 tools/koepfe_vorn.py [figur oder blatt …]   (ohne Angabe: alle Blätter kopf_vorn_*.png)
"""
import json
import sys
from pathlib import Path

import numpy as np
from scipy import ndimage
from PIL import Image

WURZEL = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(WURZEL / "tools"))
from figur_bilder import VORLAGEN  # noqa: E402
from kopf_koerper import hals, verkleinern  # noqa: E402
from monster_bilder import ausschneiden, bilder_finden, freistellen  # noqa: E402

KOEPFE = WURZEL / "assets" / "teile" / "koepfe"
FIGURTEILE = WURZEL / "data" / "figurteile.json"
## Köpfe werden so gespeichert, wie sie gemalt sind. Die Richtung regelt das Spiel (KOPF_VORN_LINKS und KOERPER_VORN_LINKS in scripts/kampf/figur_teile.gd).

## Blätter mit mehreren Köpfen (GRAFIK_AUFTRAG.md K1b): Reihenfolge von links nach rechts
BLAETTER = {"volk_frauen": ["v_w1", "v_w2", "v_w3", "a_w1", "a_w2", "k_w1"]}


def hals_vorn(kopf):
	"""Halspunkt wie hals(), aber blonde oder rote Haare zählen nicht als Haut (Haut hat deutlich mehr Blau als solche Haare).
	Sonst sitzt ein blonder Zopf als „Hals“ unten und der Kopf schwebt über dem Körper (v_w1, 10.11.2026)."""
	f = kopf[..., :3].astype(int)
	r, g, b = f[..., 0], f[..., 1], f[..., 2]
	haut = (kopf[..., 3] > 128) & (r > 200) & (g > r * 0.72) & (b > r * 0.55) & (b < g)
	haut = ndimage.binary_closing(haut, iterations=2) & (kopf[..., 3] > 128)
	lab, n = ndimage.label(haut)
	if n == 0:
		return hals(kopf)
	haut = lab == (int(np.argmax(ndimage.sum(haut, lab, range(1, n + 1)))) + 1)
	hy, hx = np.where(haut)
	unten = hy.max()
	return [round(float(hx[hy >= unten - 3].mean()), 1), int(unten + 1)]


def halspunkt(kopf):
	"""hals(), außer der Punkt liegt weit unter der sicheren Haut (dann hängt er an einem hellen Zopf): dann hals_vorn()."""
	normal, streng = hals(kopf), hals_vorn(kopf)
	return streng if normal[1] - streng[1] > 0.15 * kopf.shape[0] else normal


def hoehe(t):
	return float(np.ptp(np.where((t[..., 3] > 128).any(1))[0]))


def main():
	daten = json.loads(FIGURTEILE.read_text(encoding="utf-8"))
	namen = sys.argv[1:] or [p.stem.removeprefix("kopf_vorn_") for p in sorted(VORLAGEN.glob("kopf_vorn_*.png"))]
	for blatt in namen:
		a = freistellen(Image.open(VORLAGEN / f"kopf_vorn_{blatt}.png"))
		ziel, reihen = bilder_finden(a, [])
		figuren = BLAETTER.get(blatt, [blatt])
		if len(figuren) == 1:
			paare = [[i for r in reihen for i, _ in r]]
		else:
			# Blatt mit mehreren Köpfen: oben die offenen Augen, unten dieselben Köpfe mit geschlossenen Augen
			paare = [list(z) for z in zip([i for i, _ in reihen[0]], [i for i, _ in reihen[-1]])] if len(reihen) == 2 else []
		if len(paare) != len(figuren) or any(len(x) != 2 for x in paare):
			raise SystemExit(f"kopf_vorn_{blatt}: Köpfe passen nicht (Reihen {[len(r) for r in reihen]}, erwartet {len(figuren)} Paare)")
		for figur, stuecke in zip(figuren, paare):
			alt = np.array(Image.open(KOEPFE / f"{figur}_vorn_normal.png").convert("RGBA"))
			offen, zu = [ausschneiden(a, ziel, i) for i in stuecke]
			faktor = hoehe(alt) / hoehe(offen)
			offen, zu = verkleinern(offen, faktor), verkleinern(zu, faktor)
			Image.fromarray(offen).save(KOEPFE / f"{figur}_vorn_normal.png")
			Image.fromarray(zu).save(KOEPFE / f"{figur}_vorn_augen_zu.png")
			koerper = [k for k, v in daten.items() if isinstance(v, dict) and figur in v.get("_koepfe", {})]
			for k in koerper:
				punkte = daten[k]["_koepfe"][figur]["hals"]
				punkte["vorn_normal"] = halspunkt(offen)
				punkte["vorn_augen_zu"] = halspunkt(zu)
			print(f"{figur}: neuer Kopf von vorne (Faktor {faktor:.3f}, Körper {', '.join(koerper)})")
	FIGURTEILE.write_text(json.dumps(daten, ensure_ascii=False, indent="	", sort_keys=True), encoding="utf-8")

if __name__ == "__main__":
	main()
