"""Schneidet Effekt-Blätter von ChatGPT in Einzelbilder (D9h).

Aufruf: python tools/effekt_bilder.py BLATT NAME [BILDER]
BLATT ist eine Reihe gleich breiter Bilder mit durchsichtigem Hintergrund.
Ergebnis: assets/fx/NAME_f0.png, _f1.png ... in Spielgröße, mit klaren Pixeln und ohne Schleier.
"""
import sys
from pathlib import Path

import numpy as np
from PIL import Image

# So viele Blatt-Pixel ergeben ein Spiel-Pixel
TEILER = 4
# Fast durchsichtige Reste gehören nicht zum Effekt
SCHLEIER = 60


def schneiden(blatt: Path, name: str, bilder: int = 6) -> None:
    bild = Image.open(blatt).convert("RGBA")
    breite = bild.width // bilder
    oben = (bild.height - breite) // 2
    ziel = Path("assets/fx")
    ziel.mkdir(parents=True, exist_ok=True)
    for i in range(bilder):
        zelle = bild.crop((i * breite, oben, (i + 1) * breite, oben + breite))
        klein = zelle.resize((breite // TEILER, breite // TEILER), Image.BOX)
        daten = np.array(klein)
        daten[..., 3] = np.where(daten[..., 3] < SCHLEIER, 0, 255)
        Image.fromarray(daten).save(ziel / f"{name}_f{i}.png")
    print(f"{name}: {bilder} Bilder, je {breite // TEILER} Pixel breit")


if __name__ == "__main__":
    schneiden(Path(sys.argv[1]), sys.argv[2], int(sys.argv[3]) if len(sys.argv) > 3 else 6)
