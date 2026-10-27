# Baukasten: Bilder für die Welt

Die Welt wird in Rautenansicht aus Einzelbildern zusammengesetzt, wie aus Bausteinen.
Ausprobieren kannst du das im Startmenü unter **„Baukasten-Testfeld“**.
Alle Bilder liegen in `assets/baukasten/`. Im Moment sind das Platzhalter, die Claude gemalt hat
(`tools/baukasten_platzhalter.py`). **Ein echtes Bild ersetzt einfach den Platzhalter mit demselben Namen.**

## Regeln für neue Bilder

1. **Durchsichtiger Hintergrund** (PNG), ein Teil pro Bild, nichts ragt aus einem anderen Teil heraus.
2. **Gleiche Größe wie der Platzhalter.** Ein Feld (Raute) ist im Bild **32 × 16 Pixel** groß.
   Im Spiel wird alles doppelt so groß gezeigt, damit die Pixel scharf bleiben.
   Ein Haus auf 3 × 3 Feldern ist also etwa 96 Pixel breit.
   Ist ein KI-Bild größer, schneidet Claude es zu und verkleinert es (wie bei Vega).
3. **Licht von links oben**, bei allen Teilen gleich.
4. **Tageslicht ohne eingemaltes Leuchten.** Nacht, Laternenschein, Fackeln und Splitter-Glühen macht das Spiel.
   So reicht ein Satz Bilder für Tag, Festnacht und Sternenfall.
   (Ein hell gemaltes Laternenglas oder Fenster ist in Ordnung.)
5. **Fußpunkt unten in der Mitte.** Bei großen Teilen (Haus, Stand, Statue) ist die Grundfläche als Raute mit im Bild.
   Bei schmalen Teilen (Laterne, Baum, Banner) steht der Fuß am unteren Rand.

## Boden (`assets/baukasten/boden/`)

Jede Bodenart als Raute mit 32 × 16 Pixeln. Gibt es mehrere Bilder (`gras_1`, `gras_2`), wechselt das Spiel sie ab,
damit der Boden nicht wie ein Muster aussieht.

| Bild | Was |
|------|-----|
| gras_1, gras_2 | Wiese |
| pflaster_1, pflaster_2 | Straße |
| platz | Marktplatz (anderes Pflaster) |
| erde | Erdweg, Erdflecken |
| wasser_1, wasser_2 | Wasser (nicht begehbar) |

**Noch nicht da:** Übergänge (Gras zu Pflaster, Ufer). Das kommt in einem späteren Schritt.

## Gegenstände (`assets/baukasten/objekte/`)

| Bild | Grundfläche (Felder) | Was |
|------|----------------------|-----|
| haus_gross | 3 × 3 | Fachwerkhaus (Gilde, Wegrast) |
| haus_klein | 2 × 2 | Wohnhaus |
| marktstand_rot, marktstand_blau | 2 × 1 | Marktstand mit Plane |
| statue_der_fuenf | 2 × 2 | Statue der Fünf |
| torbogen | 3 × 1 | Torbogen, in der Mitte begehbar |
| bruecke | 1 × 3 | Brücke (flach, begehbar) |
| splitterkreis | 2 × 2 | leuchtender Kreis auf dem Platz (flach) |
| laterne, fackelschale | 1 | leuchten nachts |
| banner, wegweiser, bank, fass, kiste, zaun, mauer | 1 | Kleinkram |
| baum, tanne, busch | 1 | Pflanzen |
| blumen | 1 | flach, man läuft darüber |

## Die zwei Datendateien

- `data/baukasten_teile.json`: Welche Teile es gibt, wie groß sie sind, ob man darauf laufen kann, ob sie leuchten.
  - `flaeche`: Grundfläche in Feldern
  - `flach`: liegt auf dem Boden, Figuren laufen darüber
  - `begehbar` / `blockiert`: ob man darauf laufen kann
  - `frei`: Felder eines Teils, die begehbar bleiben (Torbogen)
  - `licht`: Lichtart und Höhe in Pixeln
  - `fuss_y`: wie viele Pixel über dem unteren Bildrand der Fuß steht
- `data/baukasten_testfeld.json`: Das Testfeld. Boden als Zeichen-Raster (`.` Gras, `#` Pflaster, `o` Platz, `e` Erde, `~` Wasser),
  dazu die Gegenstände mit ihrem Feld.

## Im Testfeld prüfen

- **G** (oder Knopf „Raster“): zeigt die Felder. Gesperrte Felder sind rot, Grundflächen gelb, deine Figur grün.
  So sieht man sofort, ob ein neues Bild auf seiner Grundfläche steht.
- **N** (oder Knopf „Tag/Nacht“): Tag und Nacht umschalten.
- Steht man hinter einem Haus oder Baum, wird es halb durchsichtig.
