"""Baut die freien Klänge (CC0, OpenGameArt) ins Spiel ein (Bauauftrag P8, 16.11.2026).

Jeder Klang wird in Mono-Ogg umgewandelt und auf eine feste mittlere Lautstärke gebracht (Spitze höchstens -1 dB),
damit alle gleich laut wirken. Kampf-Klänge sind am lautesten, Schritte und Klicks leiser.
Ergebnis: assets/sfx/<name>.ogg (das Spiel nimmt .ogg vor .wav, scripts/geraeusche.gd).

Die Pakete (alle CC0, Quellen in CREDITS.md) erst laden und entpacken, jedes in seinen eigenen Ordner:
  https://opengameart.org/sites/default/files/80-CC0-RPG-SFX_0.zip   -> 80-CC0-RPG-SFX_0/
  https://opengameart.org/sites/default/files/100-CC0-SFX_0.zip      -> 100-CC0-SFX_0/
  https://opengameart.org/sites/default/files/RPGsounds_Kenney.zip   -> RPGsounds_Kenney/
  https://opengameart.org/sites/default/files/UI_SFX_Set.zip         -> UI_SFX_Set/
  https://opengameart.org/sites/default/files/SoundPack01.zip        -> SoundPack01/
Aufruf: python3 tools/klaenge_einbauen.py <Ordner mit den entpackten Paketen>   (braucht ffmpeg)
"""
import re
import subprocess
import sys
from pathlib import Path

WURZEL = Path(__file__).resolve().parent.parent
ZIEL = WURZEL / "assets" / "sfx"

# Name im Spiel: (Paket, Datei, mittlere Lautstärke in dB)
KLAENGE = {
	# Kampf (ersetzen die selbst erzeugten Platzhalter)
	"schlag": ("80-CC0-RPG-SFX_0", "blade_02.ogg", -19),
	"wurf": ("80-CC0-RPG-SFX_0", "blade_03.ogg", -21),
	"treffer": ("100-CC0-SFX_0", "hit_03.ogg", -19),
	"kritisch": ("100-CC0-SFX_0", "slam_01.ogg", -18),
	"parade": ("80-CC0-RPG-SFX_0", "metal_03.ogg", -19),
	"perfekt": ("80-CC0-RPG-SFX_0", "item_gem_04.ogg", -20),
	"zauber": ("80-CC0-RPG-SFX_0", "spell_01.ogg", -20),
	"heilung": ("80-CC0-RPG-SFX_0", "spell_02.ogg", -21),
	"stufe": ("SoundPack01", "Rise02.aif", -21),
	# Neu: Welt und Menüs
	"klick": ("UI_SFX_Set", "click1.wav", -27),
	"fenster": ("RPGsounds_Kenney", "bookFlip1.ogg", -27),
	"muenzen": ("80-CC0-RPG-SFX_0", "item_coins_02.ogg", -24),
	"aufheben": ("RPGsounds_Kenney", "handleSmallLeather.ogg", -25),
	"anlegen": ("RPGsounds_Kenney", "cloth1.ogg", -25),
	"auftrag": ("SoundPack01", "Rise03.aif", -23),
	"schritt_0": ("RPGsounds_Kenney", "footstep00.ogg", -31),
	"schritt_1": ("RPGsounds_Kenney", "footstep01.ogg", -31),
	"schritt_2": ("RPGsounds_Kenney", "footstep02.ogg", -31),
	"schritt_3": ("RPGsounds_Kenney", "footstep03.ogg", -31),
}


def messen(datei: Path) -> tuple[float, float]:
	aus = subprocess.run(["ffmpeg", "-nostats", "-i", str(datei), "-af", "volumedetect", "-f", "null", "-"],
			capture_output=True, text=True).stderr
	mittel = float(re.search(r"mean_volume: (-?[\d.]+)", aus).group(1))
	spitze = float(re.search(r"max_volume: (-?[\d.]+)", aus).group(1))
	return mittel, spitze


def main():
	if len(sys.argv) < 2:
		raise SystemExit(__doc__)
	quelle = Path(sys.argv[1])
	ZIEL.mkdir(parents=True, exist_ok=True)
	for name, (paket, datei, ziel_db) in KLAENGE.items():
		treffer = list((quelle / paket).rglob(datei))
		if not treffer:
			raise SystemExit(f"{paket}/{datei} fehlt")
		# Erst in Mono umwandeln und dann messen (beim Zusammenlegen der Kanäle ändert sich die Lautstärke)
		mono = ZIEL / f"_{name}_mono.wav"
		subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-i", str(treffer[0]), "-ac", "1", "-ar", "44100",
				str(mono)], check=True)
		mittel, spitze = messen(mono)
		# So viel lauter oder leiser, dass die Mitte stimmt. Ein sanfter Begrenzer fängt einzelne Spitzen ab
		# (höchstens 6 dB, damit Schläge nicht platt klingen), die Spitze bleibt unter -1 dB.
		gewinn = min(ziel_db - mittel, -1.5 - spitze + 6.0)
		ausgabe = ZIEL / f"{name}.ogg"
		for _versuch in range(4):
			subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-i", str(mono), "-af",
					f"volume={gewinn:.1f}dB,alimiter=limit=0.8:level=false:attack=2:release=40",
					"-c:a", "libvorbis", "-q:a", "5", str(ausgabe)], check=True)
			neu_mittel, neu_spitze = messen(ausgabe)
			# Das Packen ins Ogg-Format kann die Spitze etwas anheben: dann noch etwas leiser
			if neu_spitze <= -1.0:
				break
			gewinn -= neu_spitze + 1.5
		mono.unlink()
		print(f"{name:10} <- {paket}/{datei:24} mittel {neu_mittel:6.1f} dB, Spitze {neu_spitze:5.1f} dB")
		# Den alten selbst erzeugten Platzhalter weglassen
		for alt in (ZIEL / f"{name}.wav", ZIEL / f"{name}.wav.import"):
			if alt.exists():
				alt.unlink()


if __name__ == "__main__":
	main()
