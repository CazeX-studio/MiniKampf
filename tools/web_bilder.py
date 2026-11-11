"""Bilder für das Web kleiner machen (D36), ohne ihre Größe im Spiel zu ändern.

Gemalte Bilder (Figuren, Porträts, Figurteile, Baukasten-Objekte, Kampf-Hintergründe) werden beim Import verlustbehaftet gespeichert
(WebP, Qualität 0,8, Figuren und Figurteile 0,7) statt verlustfrei. Das macht sie etwa viermal kleiner, man sieht keinen Unterschied.
Pixel-Grafik, Oberfläche, Effekte und Bodenkacheln bleiben verlustfrei (dort würden Ränder und Nähte unscharf),
ebenso kleine Bilder unter KLEIN Punkten und die Probe-Figur Kofi (sparen kaum etwas, dort sieht man die Abweichung eher).
Das Werkzeug ändert nur die .import-Dateien; Godot importiert danach neu. Der Web-Export auf GitHub ruft es vor dem
Import auf, damit auch neue Bilder klein werden.
Aufruf: python3 tools/web_bilder.py [--pruefen]   (--pruefen: nur zählen, nichts ändern; Fehlercode, wenn etwas fehlt)
"""
import struct
import sys
from pathlib import Path

WURZEL = Path(__file__).resolve().parent.parent
ORDNER = ["assets/figuren", "assets/portraets", "assets/teile", "assets/baukasten/objekte", "assets/kampf_hintergruende", "assets/klassenbilder"]
QUALITAET = "0.8"
## Figuren und Figurteile zeigt das Spiel auf ein Drittel verkleinert: Dort reicht 0,7 (11 % kleiner, die Farben weichen
## im Spiel im Schnitt um 2,4 statt 2,1 von 255 ab, das sieht man nicht; gemessen 11.11.2026)
QUALITAET_ORDNER = {"assets/figuren": "0.7", "assets/teile": "0.7"}
## Bilder, deren längere Seite kleiner ist, bleiben verlustfrei
KLEIN = 100
## Bilder, die verlustfrei bleiben müssen: Kofi ist die Probe-Figur, an der figurteile_test Kopf und Körper Punkt für Punkt
## mit dem fertigen Bild vergleicht
AUSNAHMEN = ["kofi"]


def groesse(png):
	"""Breite und Höhe aus dem Kopf der PNG-Datei (ohne Zusatzpakete, läuft auch beim Web-Export auf GitHub)."""
	with open(png, "rb") as f:
		kopf = f.read(24)
	return struct.unpack(">II", kopf[16:24])


def main():
	pruefen = "--pruefen" in sys.argv
	offen = 0
	geaendert = 0
	for ordner in ORDNER:
		for imp in sorted((WURZEL / ordner).rglob("*.png.import")):
			text = imp.read_text(encoding="utf-8")
			png = imp.with_name(imp.name[:-len(".import")])
			if not png.exists():
				continue
			if max(groesse(png)) < KLEIN or any(png.name.startswith(a) for a in AUSNAHMEN):
				neu = text.replace("compress/mode=1", "compress/mode=0")
			else:
				neu = text.replace("compress/mode=0", "compress/mode=1")
			qualitaet = QUALITAET_ORDNER.get(ordner, QUALITAET)
			neu = "\n".join(f"compress/lossy_quality={qualitaet}" if z.startswith("compress/lossy_quality=") else z for z in neu.split("\n"))
			if neu != text:
				offen += 1
				if not pruefen:
					imp.write_text(neu, encoding="utf-8")
					geaendert += 1
	# PNG-Bilder ohne .import (ganz neu, noch nie importiert) bekommen ihre Einstellung beim ersten Import von Godot
	print(f"{'zu ändern' if pruefen else 'geändert'}: {offen if pruefen else geaendert} Bilder")
	if pruefen and offen:
		sys.exit(1)


if __name__ == "__main__":
	main()
