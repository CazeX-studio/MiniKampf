# Credits

Alle fremden Grafiken in diesem Projekt sind kostenlos und unter freier Lizenz.
Sie sind Platzhalter, bis eigene Grafiken (oder ein Pixel-Künstler) da sind.

| Paket | Von | Quelle | Lizenz | Benutzt für |
|-------|-----|--------|--------|-------------|
| 16x16 DungeonTileset II (Version 1.3) | Robert (0x72) | https://0x72.itch.io/dungeontileset-ii | [CC0 1.0](https://creativecommons.org/publicdomain/zero/1.0/) (gemeinfrei, Nennung freiwillig) | Helden, Gegner, Wände, Boden, Banner, Säulen, Lava-Brunnen |

**Eigene Figuren** (von CazeX Studio, keine fremde Lizenz) liegen in `assets/figuren/`:

| Figur | Herkunft | Benutzt für |
|-------|----------|-------------|
| Vega (`vega_*`) | Von Marco mit KI-Hilfe erstellt (26.10.2026, zwei Bildblätter), von Claude Code zugeschnitten, verkleinert und gesäubert | Eigene Spielfigur (Welt und Kampf als Novize, mit Angriff, Parade, Fallen und Sieg), wählbar beim Zusammenspielen. Dazu Laufbilder nach vorne und hinten (27.10., `tools/vorlagen/vega_laufen.png`) und neue, fein gezeichnete Kampfbilder (27.10., `tools/vorlagen/vega_kampf_a.png` und `vega_kampf_b.png`, zerlegt mit `tools/vega_kampfbilder.py`) |
| Mira (Novizin, Kopf, `assets/teile/koepfe/mira_*`) | Von Marco mit KI-Hilfe erstellt (28.10.2026, Kopf-Blatt `tools/vorlagen/mira_kopf.png`), eingebaut mit `tools/kopf_koerper.py` | Zweiter Novizen-Kopf, im Editor auf Kofis Körper wählbar |
| Novizen-Körper männlich und weiblich (`novize_m_*`, `novize_w_*`) | Von Marco mit KI-Hilfe erstellt (28.10.2026, Blätter `tools/vorlagen/novize_m_kampf_a.png` und `novize_w_kampf_a.png`, Kopf als grünes Oval), eingebaut mit `tools/koerper_blatt.py` | Gemeinsamer Körper der Novizen je Geschlecht, Köpfe wählbar |
| Kofi (`kofi_*`) | Von Marco mit KI-Hilfe erstellt (28.10.2026, drei Bildblätter in `tools/vorlagen/`), zerlegt mit `tools/figur_bilder.py`; dazu ein Kopf-Blatt (28.10., `tools/vorlagen/kofi_kopf.png`, Köpfe getauscht mit `tools/kopf_koerper.py`) | Erster der sechs Novizen, als Figur und Begleiter wählbar |
| Asterfall-UI-Set (`assets/ui/`) | Von Marco mit KI-Hilfe erstellt (27.10.2026, zwei Bildblätter in `tools/vorlagen/ui/`), von Claude Code zugeschnitten, freigestellt und verkleinert (`tools/ui_zuschneiden.gd`) | Fenster, Knöpfe, Balken, Häkchen, Reiter, Taschen-Felder, Symbole im ganzen Spiel |

Die Einzelbilder liegen in `assets/0x72_dungeontileset_ii/`. Da itch.io automatische
Downloads blockiert, stammen die Dateien aus einer unveränderten Kopie der Einzelbilder
im öffentlichen Repository https://github.com/benc-uk/super-dungeon-delve
(Ordner `etc/0x72_DungeonTilesetII_v1.3/frames`).

**Welche Figur ist wer (Platzhalter, teils eingefärbt):**

| Im Spiel | Bild aus dem Paket |
|----------|--------------------|
| Magier-Tank, Mechaniker | knight_m |
| Rüstungsschmied | knight_f |
| Bogenschütze | elf_m |
| Sternensängerin (Vega), Kunoichi | elf_f |
| Ritualist | wizzard_f |
| Zwielicht-Wandler, Quartiermeister | wizzard_m |
| Klingentänzerin | lizard_f |
| Monster-Zähmer | lizard_m |
| Roboter Zahnrad | big_zombie |
| Moosling / Glutwelpe / Bachotter | swampy / imp / wogol |
| Glutkobold / Sumpfschleim / Dornling | chort / swampy / orc_shaman |
| Sturmkobold / Funkenwicht / Schattenhexe | ice_zombie / skelet / necromancer |
| Steinwächter (Boss) | ogre |

**Eigene Monster** (von Marco mit KI-Hilfe erstellt, 27.10.2026, Blätter in `tools/vorlagen/`, zerlegt mit `tools/monster_bilder.py`):
Feldschleim, Wiesenkobold, Kieselkobold, Rüpelkobold, Der Sternenfresser (27./28.10.) sowie die Start-Monster Moosling, Glutwelpe und Bachotter (28.10.). Sie ersetzen die Platzhalter swampy, goblin, imp und wogol.

**Gegenstands-Symbole** (von Marco mit KI-Hilfe erstellt, 28.10.2026, Blätter `tools/vorlagen/gegenstaende.png` und `gegenstaende_2.png` (Münzen, Tränke, Gürtel), zerlegt mit `tools/gegenstand_bilder.py`): alle Bilder in `assets/gegenstaende/`.

**Baukasten (eigene Grafiken von CazeX Studio):** Alle Bilder in `assets/baukasten/` hat Marco mit KI-Hilfe (ChatGPT) erstellt (27.10.2026, sieben Bildblätter in `tools/vorlagen/`), Claude Code hat sie mit `tools/baukasten_zuschneiden.py` freigestellt, ausgeschnitten und verkleinert. Dazu ein achtes Blatt mit Splitterkreis, Kratern und Sternsplitter (roter Schimmer am Rand entfernt).

Selbst gemacht (im Code gezeichnet): Fackeln, Licht- und Leuchteffekte, Staub,
Randabdunklung, Reaktions-Ring und Zeitleiste.

## Musik

Die Platzhalter-Musik (`assets/musik/`: Stadt, Nacht, Kampf, Boss) ist selbst erzeugt mit `tools/musik_erzeugen.gd`
(einfache Retro-Klänge, keine fremden Quellen, keine Lizenzfragen). Sie wird später durch richtige Musik ersetzt.

## Geräusche

Die Kampf-Geräusche (`assets/sfx/`: Schlag, Wurf, Treffer, Kritisch, Parade, Perfekt, Zauber, Heilung) sind ebenfalls
selbst erzeugt, mit `tools/sounds_erzeugen.gd`. Platzhalter, keine Lizenzfragen.
