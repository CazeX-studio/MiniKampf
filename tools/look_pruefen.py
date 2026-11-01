"""Im Stil bleiben (Projekt 13, Schritt 0): prüft neue Bilder gegen LOOK.md, bearbeitet KI-Bilder immer gleich nach
und baut das Vergleichsbild für Marcos Abnahme.

Die Regeln und Zahlen stehen in LOOK.md (einzige Quelle für den Look). Die Farbpalette und die Grenzwerte stehen in
data/look_palette.json. Ohne Marcos Ja kommt kein neues Bild ins Spiel.

Aufrufe (braucht numpy und Pillow):
  python3 tools/look_pruefen.py pruefen BILD [BILD …] [--art figur|kopf|monster|baukasten]
      Prüft Hintergrund, Farben (Palette), Umriss und Größe. Meldet jede Abweichung. Rückgabe 1, wenn etwas nicht passt.
  python3 tools/look_pruefen.py nachbearbeiten BILD --art ART [-o AUSGABE] [--hoehe PIXEL]
      Immer gleiche Nachbearbeitung: Hintergrund sauber durchsichtig, eng zuschneiden, auf Spielgröße bringen
      (nur mit --hoehe, bei Animationen für alle Bilder dieselbe Zahl), fremde Farben auf die nächste Palettenfarbe setzen.
  python3 tools/look_pruefen.py vergleich BILD [--art ART]
      Baut tools/vergleich/<name>_vergleich.png: das neue Bild neben den Referenzbildern in Spielgröße,
      auf hellem und dunklem Grund. Dieses Bild zeigt Claude Code Marco vor dem Einbauen.
  python3 tools/look_pruefen.py palette
      Baut die Startpalette neu aus den Referenzbildern (tools/referenz/). Nur nach Marcos Ja zu den Referenzbildern.
"""
import argparse
import json
import sys
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw

WURZEL = Path(__file__).resolve().parent.parent
PALETTE_DATEI = WURZEL / "data" / "look_palette.json"
REFERENZ = WURZEL / "tools" / "referenz"
VERGLEICH = WURZEL / "tools" / "vergleich"
ARTEN = ["figur", "kopf", "monster", "baukasten"]


def lade_regeln() -> dict:
	return json.loads(PALETTE_DATEI.read_text(encoding="utf-8"))


def hex_zu_rgb(text: str) -> tuple:
	text = text.lstrip("#")
	return tuple(int(text[i:i + 2], 16) for i in (0, 2, 4))


def palette_feld(regeln: dict) -> np.ndarray:
	return np.array([hex_zu_rgb(f) for f in regeln["farben"]], dtype=np.float32)


def naechste_farbe(rgb: np.ndarray, palette: np.ndarray) -> tuple:
	"""Für jede Farbe (N×3) Abstand zur nächsten Palettenfarbe und deren Nummer."""
	abstand = np.full(len(rgb), np.inf, dtype=np.float32)
	nummer = np.zeros(len(rgb), dtype=np.int32)
	for i, farbe in enumerate(palette):
		d = np.sqrt(((rgb - farbe) ** 2).sum(axis=1))
		besser = d < abstand
		abstand[besser] = d[besser]
		nummer[besser] = i
	return abstand, nummer


def art_raten(pfad: Path) -> str:
	name = pfad.name
	teile = set(pfad.parts)
	if "koepfe" in teile or "_kopf" in name:
		return "kopf"
	if "baukasten" in teile:
		return "baukasten"
	if "figuren" in teile or "koerper" in teile:
		monster = lade_regeln()["monster_namen"]
		return "monster" if name.split("_")[0] in monster else "figur"
	return "figur"


def pruefen(pfad: Path, art: str, regeln: dict) -> list:
	"""Gibt eine Liste von Meldungen zurück; leer heißt: passt."""
	meldungen = []
	bild = Image.open(pfad)
	if bild.mode not in ("RGBA", "LA", "P") or (bild.mode == "P" and "transparency" not in bild.info):
		meldungen.append("Kein durchsichtiger Hintergrund (Bild hat keinen Alpha-Kanal).")
	bild = bild.convert("RGBA")
	feld = np.asarray(bild).astype(np.float32)
	alpha = feld[:, :, 3]
	deckend = alpha >= 200
	if deckend.sum() == 0:
		return ["Bild ist ganz durchsichtig."]
	# Hintergrund: Die Ecken müssen durchsichtig sein (sonst gemalter Hintergrund oder Karomuster).
	h, w = alpha.shape
	ecken = [alpha[0, 0], alpha[0, w - 1], alpha[h - 1, 0], alpha[h - 1, w - 1]]
	if sum(1 for e in ecken if e > 20) >= 3:
		meldungen.append("Hintergrund nicht durchsichtig (die Ecken sind gefüllt).")
	halb = ((alpha > 20) & (alpha < 200)).sum() / max(1, (alpha > 20).sum())
	if halb > regeln["grenzen"]["halbdurchsichtig_hoechstens"]:
		meldungen.append(f"Zu viele halb durchsichtige Pixel ({halb:.0%}), Rand weich oder Schleier im Bild.")
	# Farben
	rgb = feld[:, :, :3][deckend]
	abstand, _ = naechste_farbe(rgb, palette_feld(regeln))
	toleranz = regeln["grenzen"]["farbabstand"]
	fremd = abstand > toleranz
	anteil = fremd.mean()
	erlaubt = regeln["grenzen"]["fremde_farben_hoechstens"]
	if anteil > erlaubt:
		werte, anzahl = np.unique((rgb[fremd] // 16 * 16).astype(np.int32), axis=0, return_counts=True)
		reihenfolge = np.argsort(-anzahl)[:5]
		beispiele = ", ".join("#%02x%02x%02x" % tuple(werte[i]) for i in reihenfolge)
		meldungen.append(f"Farben passen nicht zur Palette: {anteil:.0%} der Pixel liegen außerhalb "
			f"(erlaubt {erlaubt:.0%}). Häufigste fremde Farben: {beispiele}.")
	# Umriss: Randpixel (neben Durchsichtigem) sollen dunkel sein.
	if art != "baukasten" or not regeln["grenzen"].get("baukasten_boden_ohne_umriss", True) or h > 40:
		innen = deckend.copy()
		rand = deckend & ~(np.roll(innen, 1, 0) & np.roll(innen, -1, 0) & np.roll(innen, 1, 1) & np.roll(innen, -1, 1))
		if rand.sum() > 0:
			hell = (feld[:, :, :3][rand] * [0.299, 0.587, 0.114]).sum(axis=1)
			dunkel = (hell <= regeln["umriss"]["hoechste_helligkeit"]).mean()
			if dunkel < regeln["grenzen"]["dunkler_umriss_mindestens"]:
				meldungen.append(f"Umriss zu hell: nur {dunkel:.0%} der Randpixel sind dunkel "
					f"(nötig {regeln['grenzen']['dunkler_umriss_mindestens']:.0%}).")
	# Größe
	groesse = regeln["groessen"].get(art)
	if groesse:
		box = bild.getbbox()
		hoehe = box[3] - box[1]
		if art in ("figur", "monster"):
			# Liegende Bilder (Fallen) sind flach und breit: dort zählt die längere Seite.
			hoehe = max(hoehe, box[2] - box[0])
		if not groesse["datei_hoehe_min"] <= hoehe <= groesse["datei_hoehe_max"]:
			meldungen.append(f"Größe passt nicht: Inhalt ist {hoehe} Pixel groß, für „{art}“ sind "
				f"{groesse['datei_hoehe_min']}–{groesse['datei_hoehe_max']} Pixel vorgesehen (siehe LOOK.md).")
	return meldungen


def nachbearbeiten(pfad: Path, art: str, ausgabe: Path, hoehe: int | None, regeln: dict) -> Path:
	bild = Image.open(pfad).convert("RGBA")
	feld = np.asarray(bild).copy()
	# 1. Hintergrund: fast durchsichtig wird ganz durchsichtig, fast deckend ganz deckend.
	a = feld[:, :, 3]
	a[a < 40] = 0
	a[a > 215] = 255
	feld[:, :, 3] = a
	bild = Image.fromarray(feld)
	# 2. Eng zuschneiden, 2 Pixel Rand.
	box = bild.getbbox()
	if box:
		bild = bild.crop((max(0, box[0] - 2), max(0, box[1] - 2), min(bild.width, box[2] + 2), min(bild.height, box[3] + 2)))
	# 3. Auf Spielgröße bringen (nur wenn eine Zielhöhe feststeht).
	ziel = hoehe
	if ziel and bild.height != ziel:
		faktor = ziel / bild.height
		bild = bild.resize((max(1, round(bild.width * faktor)), ziel), Image.LANCZOS)
	# 4. Fremde Farben auf die nächste Palettenfarbe setzen (Farben in der Toleranz bleiben, wie sie sind).
	feld = np.asarray(bild).copy()
	deckend = feld[:, :, 3] > 0
	rgb = feld[:, :, :3][deckend].astype(np.float32)
	palette = palette_feld(regeln)
	abstand, nummer = naechste_farbe(rgb, palette)
	fremd = abstand > regeln["grenzen"]["farbabstand"]
	rgb[fremd] = palette[nummer[fremd]]
	feld[:, :, :3][deckend] = rgb.astype(np.uint8)
	ausgabe.parent.mkdir(parents=True, exist_ok=True)
	Image.fromarray(feld).save(ausgabe)
	print(f"Nachbearbeitet: {ausgabe} ({fremd.sum()} Pixel auf die Palette gesetzt)")
	return ausgabe


def spielgroesse(bild: Image.Image, art: str, ansicht: str, regeln: dict) -> Image.Image:
	faktor = regeln["groessen"].get(art, {}).get(ansicht, 1.0)
	if faktor == 1.0:
		return bild
	return bild.resize((max(1, round(bild.width * faktor)), max(1, round(bild.height * faktor))), Image.LANCZOS)


def vergleich(pfad: Path, art: str, regeln: dict) -> Path:
	# Gebäude und Boden vergleicht man in der Welt, Figuren und Monster im Kampf.
	ansicht = "welt" if art == "baukasten" else "kampf"
	referenzen = []
	for eintrag in regeln["referenzbilder"]:
		datei = REFERENZ / eintrag["datei"]
		if ansicht == "kampf" and eintrag["art"] == "baukasten":
			continue  # Häuser gibt es im Kampf nicht, daneben würden die Größen täuschen
		if datei.exists():
			referenzen.append((eintrag, spielgroesse(Image.open(datei).convert("RGBA"), eintrag["art"], ansicht, regeln)))
	neu = spielgroesse(Image.open(pfad).convert("RGBA"), art, ansicht, regeln)
	bilder = [b for _, b in referenzen] + [neu]
	abstand = 24
	breite = sum(b.width for b in bilder) + abstand * (len(bilder) + 1)
	hoehe_reihe = max(b.height for b in bilder) + abstand * 2
	blatt = Image.new("RGBA", (breite, hoehe_reihe * 2), (0, 0, 0, 255))
	zeichnen = ImageDraw.Draw(blatt)
	# oben heller Grund (wie Tageslicht), unten dunkler Grund (wie Nacht im Spiel)
	zeichnen.rectangle((0, 0, breite, hoehe_reihe), fill=(206, 196, 170, 255))
	zeichnen.rectangle((0, hoehe_reihe, breite, hoehe_reihe * 2), fill=(34, 32, 48, 255))
	for reihe in range(2):
		x = abstand
		boden = reihe * hoehe_reihe + hoehe_reihe - abstand
		for i, b in enumerate(bilder):
			blatt.alpha_composite(b, (x, boden - b.height))
			if i == len(bilder) - 1:
				farbe = (230, 60, 60, 255)
				zeichnen.rectangle((x - 4, boden - b.height - 4, x + b.width + 3, boden + 3), outline=farbe, width=2)
			x += b.width + abstand
	VERGLEICH.mkdir(parents=True, exist_ok=True)
	ziel = VERGLEICH / f"{pfad.stem}_vergleich.png"
	blatt.convert("RGB").save(ziel)
	namen = ", ".join(e["name"] for e, _ in referenzen) or "keine Referenzbilder gefunden"
	print(f"Vergleichsbild: {ziel}\n  links die Referenzbilder ({namen}), rechts rot umrandet das neue Bild, alles in Spielgröße ({ansicht}).")
	if not regeln.get("referenzen_abgenommen"):
		print("  Hinweis: Die Referenzbilder sind noch ein Vorschlag und warten auf Marcos Ja (LOOK.md).")
	return ziel


def farbstufen(rgb: tuple) -> list:
	"""Fünf Stufen einer Grundfarbe: zwei dunklere (Schatten), die Grundfarbe, zwei hellere (Licht)."""
	stufen = []
	for faktor in (0.35, 0.6, 1.0):
		stufen.append(tuple(round(c * faktor) for c in rgb))
	for anteil in (0.3, 0.6):
		stufen.append(tuple(round(c + (255 - c) * anteil) for c in rgb))
	return ["#%02x%02x%02x" % s for s in stufen]


def palette_bauen(regeln: dict) -> None:
	stapel = []
	for eintrag in regeln["referenzbilder"]:
		feld = np.asarray(Image.open(REFERENZ / eintrag["datei"]).convert("RGBA"))
		stapel.append(feld[:, :, :3][feld[:, :, 3] >= 200])
	alle = np.concatenate(stapel).astype(np.uint8)
	streifen = Image.fromarray(alle.reshape(1, -1, 3), "RGB")
	anzahl = regeln["palette_groesse"]
	klein = streifen.quantize(colors=anzahl, method=Image.Quantize.MEDIANCUT)
	roh = klein.getpalette()[: anzahl * 3]
	farben = ["#%02x%02x%02x" % tuple(roh[i:i + 3]) for i in range(0, len(roh), 3)]
	farben.sort(key=lambda f: sum(hex_zu_rgb(f)))
	# Dazu die Farbstufen der Elemente und Regionen (LOOK.md, Abschnitt Farben): je Grundfarbe fünf Stufen
	# von dunkel (Schatten) bis hell (Licht).
	for grundfarbe in regeln.get("farbstufen", {}).values():
		farben += farbstufen(hex_zu_rgb(grundfarbe))
	regeln["farben"] = sorted(set(farben + regeln.get("feste_farben", [])), key=lambda f: sum(hex_zu_rgb(f)))
	PALETTE_DATEI.write_text(json.dumps(regeln, ensure_ascii=False, indent="\t") + "\n", encoding="utf-8")
	print(f"Palette neu gebaut: {len(regeln['farben'])} Farben in {PALETTE_DATEI}")


def main() -> int:
	parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
	parser.add_argument("befehl", choices=["pruefen", "nachbearbeiten", "vergleich", "palette"])
	parser.add_argument("bilder", nargs="*", type=Path)
	parser.add_argument("--art", choices=ARTEN)
	parser.add_argument("-o", "--ausgabe", type=Path)
	parser.add_argument("--hoehe", type=int)
	args = parser.parse_args()
	regeln = lade_regeln()
	if args.befehl == "palette":
		palette_bauen(regeln)
		return 0
	if not args.bilder:
		parser.error("Bitte mindestens ein Bild angeben.")
	fehler = 0
	for pfad in args.bilder:
		art = args.art or art_raten(pfad)
		if args.befehl == "pruefen":
			meldungen = pruefen(pfad, art, regeln)
			if meldungen:
				fehler += 1
				print(f"PASST NICHT  {pfad} ({art})")
				for m in meldungen:
					print(f"  - {m}")
			else:
				print(f"passt        {pfad} ({art})")
		elif args.befehl == "nachbearbeiten":
			ziel = args.ausgabe or pfad.with_name(pfad.stem + "_look.png")
			nachbearbeiten(pfad, art, ziel, args.hoehe, regeln)
		else:
			vergleich(pfad, art, regeln)
	if args.befehl == "pruefen" and len(args.bilder) > 1:
		print(f"\n{len(args.bilder) - fehler} von {len(args.bilder)} Bildern passen.")
	return 1 if fehler else 0


if __name__ == "__main__":
	sys.exit(main())
