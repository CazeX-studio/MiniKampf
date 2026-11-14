"""Übersicht für Marco: Köpfe und Körper der Novizen einzeln in den fünf Richtungen, beschriftet mit dem Blick laut Spiel.
Aufruf: python3 tools/richtungen_uebersicht.py tools/referenz/teil_u
"""
import sys
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont
W = Path("C:/GameDev/MiniKampf")
K = W / "assets/teile/koepfe"; B = W / "assets/teile/koerper"
LINKS = ["m2", "m3", "w2", "w3"]
RICHT = [("gerade_vorn", "1: gerade nach unten"), ("vorn", "2: nach unten rechts"), ("seite", "3: nach rechts"),
         ("hinten", "4: nach oben rechts"), ("gerade_hinten", "5: gerade nach oben")]
f = ImageFont.truetype("arial.ttf", 18); fk = ImageFont.truetype("arial.ttf", 22)
S = 3
def tafel(zeilen, titel, aus):
    zw, zh, lw = 230, 260, 150
    img = Image.new("RGB", (lw + zw * 5, 40 + zh * len(zeilen) + 30), (225, 225, 225))
    d = ImageDraw.Draw(img); d.text((10, 8), titel, font=fk, fill=(0, 0, 0))
    for i, (_, t) in enumerate(RICHT):
        d.text((lw + i * zw + 10, 40), t, font=f, fill=(0, 0, 120))
    for r, (name, bilder) in enumerate(zeilen):
        y = 70 + r * zh
        d.text((10, y + zh // 2 - 10), name, font=fk, fill=(0, 0, 0))
        for i, b in enumerate(bilder):
            if b is None: continue
            b = b.resize((b.width * S, b.height * S), Image.NEAREST)
            if b.height > zh - 10: b = b.resize((round(b.width * (zh - 10) / b.height), zh - 10), Image.LANCZOS)
            img.paste(b, (lw + i * zw + (zw - b.width) // 2, y + zh - 10 - b.height), b)
    img.save(aus)
koepfe = []
for k in ["m1", "m2", "m3", "w1", "w2", "w3"]:
    reihe = []
    for r, _ in RICHT:
        b = Image.open(K / f"{k}_{r}_normal.png").convert("RGBA")
        if r == "vorn" and k in LINKS: b = b.transpose(Image.FLIP_LEFT_RIGHT)
        reihe.append(b)
    koepfe.append((f"Kopf {k}", reihe))
tafel(koepfe, "Köpfe, so wie das Spiel sie einsetzt (Blick laut Spiel)", sys.argv[1] + "/uebersicht_koepfe.png")
koerper = []
END = {"gerade_vorn": "_gerade_vorn", "vorn": "_vorn", "seite": "_welt_seite", "hinten": "_hinten", "gerade_hinten": "_gerade_hinten"}
for k, n in [("novize_m", "Novize"), ("novize_w", "Novizin")]:
    for a, an in [("idle", "steht"), ("run", "läuft"), ("sitzen", "sitzt")]:
        koerper.append((f"{n}\n{an}", [Image.open(B / f"{k}_{a}{END[r]}_f{2 if a=='run' else 0}.png").convert("RGBA") for r, _ in RICHT]))
tafel(koerper, "Körper ohne Kopf (grünes Oval = Kopfplatz), Blick laut Spiel", sys.argv[1] + "/uebersicht_koerper.png")
