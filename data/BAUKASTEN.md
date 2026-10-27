# Baukasten: Bilder für die Welt

Die Welt wird in Rautenansicht aus Einzelbildern zusammengesetzt, wie aus Bausteinen.
Ausprobieren kannst du das im Startmenü unter **„Baukasten-Testfeld“**.

## Woher die Bilder kommen

1. Marco lässt Bildblätter von ChatGPT malen (Stil-Vorgabe und Prompts: siehe Chat vom 27.10.,
   kurz: Pixel-Art wie Octopath, isometrisch, Licht von links oben, Tageslicht, durchsichtiger Hintergrund,
   ein Teil pro Platz, keine Texte).
2. Die Blätter liegen unverändert in `tools/vorlagen/` (gebaeude, markt, besonderes, pavillons, kleinkram, pflanzen, boden, splitter).
3. `tools/baukasten_zuschneiden.py` stellt die Teile frei (auch ein mitgemaltes Karomuster), schneidet sie aus,
   verkleinert sie auf Spielgröße und legt sie in `assets/baukasten/objekte/` und `assets/baukasten/boden/`.
   Es misst auch die ungefähre Grundfläche und den Fußpunkt (`tools/vorlagen/messung.json`).
4. In `data/baukasten_teile.json` stehen pro Teil Grundfläche, Fußpunkt, Licht usw. (von Claude geprüft und angepasst).

Ein neues Blatt oder ein besseres Bild: Datei in `tools/vorlagen/` ersetzen, Werkzeug laufen lassen, im Testfeld mit **G** prüfen.

## Größen

- Ein Feld (Raute) ist im Spiel **64 × 32 Pixel**. Die Bilder haben schon Spielgröße.
- Jedes Blatt hat einen eigenen Maßstab im Werkzeug, damit die Blätter zueinander passen
  (z. B. Häuser 0,6, Kleinkram 0,38, Bäume 0,44).
- Die Spielfigur steht im Testfeld auf 80 % (Marcos Wahl vom 27.10.). Mit **+** und **−** lässt sich ausprobieren, welche Größe zur Welt passt.

## Die Teile

| Gruppe | Teile |
|--------|-------|
| Boden | gras_1, gras_2, pflaster_1, pflaster_2, platz, erde, wasser_1, wasser_2 |
| Gebäude | gilde (7×7 Felder), wegrast (5×6), haus_klein (3×4), haus_mittel (4×4) |
| Markt | marktstand_rot, marktstand_blau (3×2), bingos_stand (7×3), brunnen (4×4) |
| Besonderes | statue_der_fuenf (6×6), torbogen (6×1, Mitte begehbar), sechstes_tor (6×1), bruecke (flach, begehbar), mauer (8×1) |
| Gesandten-Hof | pavillon_messinghafen, _glutoase, _gruenwacht, _arkanum, _nebelinseln (je 4×4) |
| Kleinkram | laterne, fackelschale (leuchten nachts), banner, bank, fass, kiste, zaun, wegweiser, auftragsbrett, mauerruine |
| Pflanzen | baum, baum_herbst, tanne, tanne_gross, busch, busch_bluete, blumen und grasbueschel (flach) |
| Sternenfall | splitterkreis (3×3, vor dem Fest), krater_frisch (4×4, Festnacht), krater_spaet (4×4, umzäunt, Wochen danach), sternsplitter (1×1, leuchtet) |

**Übergänge:** Das Spiel macht sie selbst, es braucht keine eigenen Bilder. Jede Bodenart hat in `data/baukasten_teile.json`
einen `vorrang` (Gras 4, Erde 3, Pflaster 2, Platz 1, Wasser 0). Der Boden mit mehr Vorrang ragt mit einem ausgefransten,
weichen Rand ins Nachbarfeld (Gras wächst über das Pflaster), am Wasser liegt zusätzlich ein dunkler Uferschatten.
Weite, Fransen und Weichheit stehen oben in `scripts/welt/baukasten_test.gd` (RAND_WEITE, RAND_FRANSEN, RAND_WEICH).

**Vega in vier Richtungen:** Das Blatt `tools/vorlagen/vega_laufen.png` zerlegt `tools/vega_laufbilder.py` in
`assets/figuren/vega_<idle|run>_<vorn|hinten>_anim_f0–5.png`. Nach links spiegelt das Spiel die Bilder.

## Die zwei Datendateien

- `data/baukasten_teile.json`: Welche Teile es gibt.
  - `flaeche`: Grundfläche in Feldern (darauf kann man nicht laufen)
  - `fuss`: die Mitte der Grundfläche im Bild (Pixel von links oben)
  - `flach`: liegt auf dem Boden, Figuren laufen darüber
  - `begehbar` / `blockiert`: ob man darauf laufen kann
  - `frei`: Felder eines Teils, die begehbar bleiben (Torbogen)
  - `licht` (Höhe über dem Boden) oder `lichter` (Stellen im Bild, z. B. Laternen an der Hauswand)
  - `massstab`: nur für die alten Pixel-Platzhalter (2)
- `data/baukasten_testfeld.json`: Das Testfeld. Boden als Zeichen-Raster (`.` Gras, `#` Pflaster, `o` Platz, `e` Erde, `~` Wasser),
  dazu die Gegenstände mit ihrem Feld. `"gespiegelt": true` stellt ein Teil quer (z. B. das sechste Tor am Weg nach links).
  `"nur_stufe"`: das Teil gibt es nur in diesen Stufen der Geschichte (0 vor dem Fest, 1 Nacht des Sternenfalls, 2 Wochen danach).

## Im Testfeld prüfen

- **G** (oder Knopf „Raster“): zeigt die Felder. Gesperrte Felder sind rot, Grundflächen gelb, deine Figur grün.
- **N** (oder Knopf „Tag/Nacht“): Tag und Nacht umschalten.
- **+ / −**: Größe der Spielfigur.
- **K** (oder Knopf „Geschichte“): Stand der Geschichte umschalten (Splitterkreis → frischer Krater mit Splitter, immer Nacht → umzäunter Krater).
- Steht man hinter einem Haus oder Baum, wird es halb durchsichtig.
