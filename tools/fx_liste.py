"""Liste aller Effekte für den Bewegungs- und Effekt-Editor (S3a): gezeichnete Abläufe aus
scripts/kampf/faehigkeit_fx.gd und gemalte Bildfolgen aus assets/fx/. Schreibt data/fx_namen.json.
Aufruf: python3 tools/fx_liste.py   (tests/bewegung_editor_test.gd prüft, dass die Liste aktuell ist)
"""
import json
import os
import re
from pathlib import Path

WURZEL = Path(__file__).resolve().parent.parent


def ablaeufe():
	s = (WURZEL / "scripts/kampf/faehigkeit_fx.gd").read_text(encoding="utf-8")
	namen = []
	for m in re.finditer(r'^\t\t("[a-z_0-9]+"(?:, "[a-z_0-9]+")*):\s*$', s, re.M):
		namen += re.findall(r'"([a-z_0-9]+)"', m.group(1))
	return namen


def bilder():
	return sorted({re.sub(r"_f\d+\.png$", "", f) for f in os.listdir(WURZEL / "assets/fx") if re.search(r"_f\d+\.png$", f)})


def main():
	daten = {"hinweis": "Erzeugt von tools/fx_liste.py: ablaeufe = Effekte der Fähigkeiten (FaehigkeitFx.spielen), bilder = gemalte Bildfolgen (assets/fx, FxBild).",
			"ablaeufe": ablaeufe(), "bilder": bilder()}
	(WURZEL / "data/fx_namen.json").write_text(json.dumps(daten, indent="\t", ensure_ascii=False) + "\n", encoding="utf-8")
	print("%d Abläufe, %d Bildfolgen" % (len(daten["ablaeufe"]), len(daten["bilder"])))


if __name__ == "__main__":
	main()
