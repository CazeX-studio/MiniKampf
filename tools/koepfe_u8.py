"""Schräg von vorne neu für w1 und m1 (GRAFIK_AUFTRAG.md Teil U8, 14.11.2026).

Die ersten Köpfe (w1, m1) sahen schräg von vorne fast aus wie von der Seite. Eingang:
tools/vorlagen/welt_u/u8_kopf_<kopf>.png, eine Reihe mit vier Köpfen schräg von vorne nach LINKS:
normal, Schmerz, Freude, Augen zu. Sie ersetzen assets/teile/koepfe/<kopf>_vorn_<gesicht>.png.
Jeder Kopf wird gespiegelt (w1 und m1 schauen im Spiel schräg nach rechts, sie stehen nicht in KOPF_VORN_LINKS)
und so verkleinert, dass er so hoch ist wie der bisherige Kopf schräg von vorne. Die Halspunkte kommen in
data/figurteile.json zu jedem Körper, der diesen Kopf kennt (_koepfe.<kopf>.hals.vorn_<gesicht>).
Aufruf: python3 tools/koepfe_u8.py [kopf …]
Ersetzt seit 14.11.2026 durch tools/koepfe_u9.py (w1 und m1 im Muster von m2/w2). Nicht mehr ausführen.
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
from koepfe_u import eng, hoehe  # noqa: E402

QUELLE = WURZEL / "tools" / "vorlagen" / "welt_u"
KOEPFE = WURZEL / "assets" / "teile" / "koepfe"
DATEN = WURZEL / "data" / "figurteile.json"
GESICHTER = ["vorn_normal", "vorn_schmerz", "vorn_freude", "vorn_augen_zu"]


def main():
	daten = json.loads(DATEN.read_text(encoding="utf-8"))
	for kopf in sys.argv[1:] or ["w1", "m1"]:
		a = freistellen(Image.open(QUELLE / f"u8_kopf_{kopf}.png"))
		ziel, reihen = bilder_finden(a, [])
		if [len(r) for r in reihen] != [4]:
			raise SystemExit(f"u8_kopf_{kopf}: Reihen {[len(r) for r in reihen]}, erwartet [4]")
		stuecke = [eng(np.ascontiguousarray(ausschneiden(a, ziel, i)[:, ::-1])) for i, _ in reihen[0]]
		alt = np.array(Image.open(KOEPFE / f"{kopf}_vorn_normal.png").convert("RGBA"))
		faktor = hoehe(alt) / hoehe(stuecke[0])
		punkte = {}
		for name, t in zip(GESICHTER, stuecke):
			bild = Image.fromarray(t)
			bild = np.array(bild.resize((max(1, round(bild.width * faktor)), max(1, round(bild.height * faktor))), Image.LANCZOS))
			Image.fromarray(bild).save(KOEPFE / f"{kopf}_{name}.png")
			punkte[name] = hals(bild)
		n = 0
		for eintrag in daten.values():
			if isinstance(eintrag, dict) and kopf in eintrag.get("_koepfe", {}):
				eintrag["_koepfe"][kopf]["hals"].update(punkte)
				n += 1
		print(f"{kopf}: Faktor {faktor:.3f}, Halspunkte {punkte}, bei {n} Körpern eingetragen")
	DATEN.write_text(json.dumps(daten, ensure_ascii=False, indent="\t", sort_keys=True), encoding="utf-8")


if __name__ == "__main__":
	main()
