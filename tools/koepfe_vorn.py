"""Neue Köpfe von vorne für die Frauen (Alpha 19–21, GRAFIK_AUFTRAG.md Teil K1).

Blatt tools/vorlagen/kopf_vorn_<figur>.png: zwei Köpfe auf Pink, links Augen offen, rechts Augen zu.
Der Kopf ersetzt assets/teile/koepfe/<figur>_vorn_normal.png (gleiche Höhe wie der alte Kopf), der zweite wird
<figur>_vorn_augen_zu.png. Die Halspunkte kommen in data/figurteile.json beim Körper, der den Kopf trägt.
Aufruf: python3 tools/koepfe_vorn.py [figur …]   (ohne Angabe: alle Blätter kopf_vorn_*.png)
"""
import json
import sys
from pathlib import Path

import numpy as np
from PIL import Image

WURZEL = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(WURZEL / "tools"))
from figur_bilder import VORLAGEN  # noqa: E402
from kopf_koerper import hals, verkleinern  # noqa: E402
from monster_bilder import ausschneiden, bilder_finden, freistellen  # noqa: E402

KOEPFE = WURZEL / "assets" / "teile" / "koepfe"
FIGURTEILE = WURZEL / "data" / "figurteile.json"
## Blätter, deren Kopf falsch herum gemalt ist: gespiegelt, damit er wie der Körper schaut (grund_frau nach vorne links, grund_gelehrter nach vorne rechts)
SPIEGELN = {"hanne"}


def hoehe(t):
	return float(np.ptp(np.where((t[..., 3] > 128).any(1))[0]))


def main():
	daten = json.loads(FIGURTEILE.read_text(encoding="utf-8"))
	namen = sys.argv[1:] or [p.stem.removeprefix("kopf_vorn_") for p in sorted(VORLAGEN.glob("kopf_vorn_*.png"))]
	for figur in namen:
		a = freistellen(Image.open(VORLAGEN / f"kopf_vorn_{figur}.png"))
		ziel, reihen = bilder_finden(a, [])
		stuecke = [i for r in reihen for i, _ in r]
		if len(stuecke) != 2:
			raise SystemExit(f"kopf_vorn_{figur}: {len(stuecke)} Köpfe erkannt, erwartet 2")
		alt = np.array(Image.open(KOEPFE / f"{figur}_vorn_normal.png").convert("RGBA"))
		offen, zu = [ausschneiden(a, ziel, i) for i in stuecke]
		if figur in SPIEGELN:
			offen, zu = offen[:, ::-1].copy(), zu[:, ::-1].copy()
		faktor = hoehe(alt) / hoehe(offen)
		offen, zu = verkleinern(offen, faktor), verkleinern(zu, faktor)
		Image.fromarray(offen).save(KOEPFE / f"{figur}_vorn_normal.png")
		Image.fromarray(zu).save(KOEPFE / f"{figur}_vorn_augen_zu.png")
		koerper = [k for k, v in daten.items() if isinstance(v, dict) and figur in v.get("_koepfe", {})]
		for k in koerper:
			punkte = daten[k]["_koepfe"][figur]["hals"]
			punkte["vorn_normal"] = hals(offen)
			punkte["vorn_augen_zu"] = hals(zu)
		print(f"{figur}: neuer Kopf von vorne (Faktor {faktor:.3f}, Körper {', '.join(koerper)})")
	FIGURTEILE.write_text(json.dumps(daten, ensure_ascii=False, indent="\t", sort_keys=True), encoding="utf-8")


if __name__ == "__main__":
	main()
