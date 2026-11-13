# LOOK.md – wie Asterfall aussieht

> **Die einzige Quelle für den Look.** Alles, was gezeichnet, bestellt oder eingebaut wird, richtet sich nur nach
> dieser Datei. Beschlossen am 29.10.2026 (Sitzung 26, „Im Stil bleiben“), angelegt am 01.11.2026 (Projekt 13, Schritt 0).
> Ändern darf sie nur, wer einen Beschluss von Marco hat. Wo sie und `design.md` (Repo Spieldesign) sich
> widersprechen, gilt design.md, und die Abweichung wird Marco gemeldet.
>
> Zugehörige Dateien: `data/look_palette.json` (Farbpalette und Grenzwerte), `tools/look_pruefen.py` (Prüfung,
> Nachbearbeitung, Vergleichsbild), `tools/referenz/` (Referenzbilder). Für Monster gilt zusätzlich `MONSTER.md`,
> für Figuren der Welt `NPC.md`. Die Bildaufträge stehen in `Spieldesign/GRAFIK_AUFTRAG.md`.
>
> Ältere Entwürfe: `Spieldesign/art/STYLE_GUIDE.md` (Version 0.4, „zur Prüfung“) bleibt als Sammlung stehen. Wo er
> etwas anderes sagt, gilt LOOK.md.

---

## 1. Die sechs Regeln (beschlossen 29.10.)

1. **Eine Look-Datei als einzige Quelle:** diese Datei.
2. **Feste Farbpalette als Datei mit automatischer Prüfung:** `data/look_palette.json`. Claude Code prüft jedes neue
   Bild mit `python3 tools/look_pruefen.py pruefen BILD`. Farben außerhalb der Palette werden gemeldet oder bei der
   Nachbearbeitung auf die nächste Palettenfarbe gesetzt.
3. **Referenzbilder** („so soll es aussehen“): zwei bis drei Bilder, die Marco abgenommen hat, in `tools/referenz/`.
   Sie kommen bei jedem neuen Bild-Prompt mit.
4. **Fester Stil-Block** in jedem Prompt, wörtlich gleich, nie umformuliert (Abschnitt 9). Nur Marco ändert ihn.
5. **Gleiche Nachbearbeitung** aller KI-Bilder: `python3 tools/look_pruefen.py nachbearbeiten BILD --art ART`
   (Hintergrund sauber durchsichtig, eng zuschneiden, auf Spielgröße bringen, fremde Farben auf die Palette setzen).
6. **Abnahme durch Marco per Vergleichsbild:** `python3 tools/look_pruefen.py vergleich BILD --art ART` legt das
   neue Bild in Spielgröße neben die Referenzbilder, auf hellem und dunklem Grund. **Ohne Marcos Ja kommt kein Bild
   ins Spiel.**

### Ablauf für jedes neue Bild

1. Bildauftrag aus GRAFIK_AUFTRAG.md nehmen (Stil-Block wörtlich, Referenzbilder anhängen).
2. Fertiges Bild nach `tools/vorlagen/` legen, zuschneiden wie bisher (Werkzeuge in `tools/`).
3. `nachbearbeiten`, dann `pruefen`. Meldet die Prüfung etwas, das Bild neu bestellen oder Marco die Abweichung zeigen.
4. `vergleich` bauen und Marco zeigen. Erst nach seinem Ja einbauen.

---

## 2. Grundstil

- **Entschieden 01.11.: Wir bleiben beim jetzigen Stil** („A: so wie jetzt“): fein gemalte Bilder im Pixel-Look,
  im Spiel weich verkleinert. Keine Umstellung auf grobe, echte Pixel-Art (Probe B und C: Gesichter und Farben
  leiden, und alle vorhandenen Bilder müssten neu bestellt werden). Die Mischung ist: Figuren und Monster niedlich
  wie in Ragnarok, Häuser detailreich wie in Octopath, Licht und Stimmung macht das Spiel.
- **Pixel-Art** wie Octopath Traveler und Ragnarok Online: warm, detailreich, klare dunkle Umrisse, leicht
  düster-episch, mittelalterliche Fantasy.
- **Figuren im Chibi-Verhältnis:** großer Kopf, etwa 3 Kopflängen hoch, freundliche, ausdrucksstarke Gesichter.
  Muster ist Vega (Referenzbild), dazu passen die sechs Novizen-Köpfe und Kofi.
- **Klassen-Körper im Novizen-Stil:** gleiche niedliche Proportionen, warme Farben, klare Umrisse (der erste
  Bogenschützen-Versuch war zu düster und zu realistisch).
- **Tageslicht und neutrale Farben** in jedem Bild. Kein eingemaltes Glühen, kein Lichtschein, keine Lichtkegel.
  Nacht, Leuchten und Zauber-Effekte macht das Spiel (Licht wie bei Octopath: Glühen, Fackeln, Tiefe).
  Ausnahme seit D9h (06.11.2026): die Effekte der Fähigkeiten sind eigene, ausdrücklich bestellte Effekt-Blätter
  (Bildfolgen, `GRAFIK_AUFTRAG.md` Teil E). In Figuren- und Umgebungsbildern bleibt es bei „keine Effekte“.
- **Durchsichtiger Hintergrund**, kein gemaltes Karomuster, kein Farbverlauf, keine Schatten-Wolke dahinter.
- **Keine Texte, Zahlen, Rahmen oder Beschriftungen** im Bild.

## 3. Blickwinkel

| Wo | Blickwinkel |
|---|---|
| **Welt** | Rautenansicht von schräg oben (2:1, ein Feld ist eine Raute **64 × 32 Pixel**). Figuren schräg von vorne rechts oder schräg von hinten rechts (nach links spiegelt das Spiel). Gebäude von der Ecke gesehen. |
| **Kampf** | Seitlich wie in Final Fantasy 6. Jede Figur und jedes Monster schaut nach **rechts** (das Spiel spiegelt die Gegner). |

## 4. Licht und Schatten

- **Licht immer von links oben.**
- **Schattenstufen:** höchstens fünf Stufen pro Farbfläche: zwei dunklere (Schatten), die Grundfarbe, zwei hellere
  (Licht). So baut auch die Palette ihre Farbstufen (Abschnitt 6).
- Bodenschatten unter Figuren und Monstern macht das Spiel, nicht das Bild.

## 5. Größen in Pixeln (gemessen an den Bildern im Spiel, 01.11.)

Die Bilddateien sind fein gezeichnet und größer als auf dem Bildschirm; das Spiel verkleinert sie weich.
Bildschirm heißt hier: bei 1280 × 720.

| Art | In der Bilddatei | Kampf | Welt |
|---|---|---|---|
| **Spielfigur** (Kopf und Körper zusammen, Stehen) | etwa **127 Pixel** hoch (je nach Bewegung 90 bis 170) | gleich groß (127) | zwei Drittel (etwa 85), im Baukasten-Testfeld davon 80 % (etwa 68) |
| **Kopf** (Projekt 11) | **54 bis 66 Pixel**, alle Köpfe gleich groß und an derselben Stelle | wie die Figur | wie die Figur |
| **Monster** | dreimal so groß wie auf dem Bildschirm | ein Drittel der Datei | – |
| **Baukasten-Teile** | Spielgröße, ein Feld 64 × 32; Maßstab pro Blatt im Werkzeug (Häuser 0,6, Kleinkram 0,38, Bäume 0,44) | – | gleich groß |

**Monster-Größen auf dem Bildschirm (Kampf), nach MONSTER.md:**

| Größe | Höhe auf dem Bildschirm | Höhe in der Datei | Beispiele |
|---|---|---|---|
| klein | etwa 50–65 | etwa 150–200 | Schleim, Käfer, Hase, Moosling (57) |
| mittel | etwa 80–100 | etwa 240–300 | Wolf, Echse, Fuchs, Wiesenkobold (86) |
| groß | etwa 120–150 | etwa 360–450 | Bär, Golem, Sandwurm |
| Boss | ab etwa 170 | ab etwa 510 | Sternenfresser (172) |

Die Werte für „mittel“ und „groß“ sind Startwerte (es gibt erst wenige Monster in diesen Größen) und werden beim
ersten Blatt jeder Größe per Vergleichsbild mit Marco festgelegt.

## 6. Farben

- **Palette:** `data/look_palette.json`, Feld `farben`. Sie besteht aus
  - den Farben der Referenzbilder (64 Farben, gebaut mit `python3 tools/look_pruefen.py palette`),
  - je fünf Farbstufen für jedes Element, jede Region, Hauttöne und Metall (Feld `farbstufen`),
  - Schwarz und Weiß.
- **Grenzwerte der Prüfung** (Feld `grenzen`): Eine Farbe gilt als „passend“, wenn sie höchstens 40 vom nächsten
  Palettenton entfernt ist (Abstand im Farbraum). Höchstens 10 % der Pixel eines Bildes dürfen außerhalb liegen.
  Die Bilder im Spiel sind verkleinerte KI-Bilder mit weichen Übergängen, deshalb gibt es diesen Spielraum.
- **Farben der Regionen** (aus design.md, Grundfarben in `farbstufen`):

  | Ort | Farben |
  |---|---|
  | Kreuzweg | warmes Fachwerk (Braun), rote Ziegel, heller Putz, graues Pflaster, Banner in Dunkelrot |
  | Grünwacht | Grüntöne, Erdbraun, Rinde, Moos |
  | Glutoase | Sandgelb, Orange, Glutrot, Lehm |
  | Messinghafen | Messing, Kupfer, Braun |
  | Arkanum | Blau, Violett, Silber |
  | Nebelinseln | Rosa, Weiß, Nebelgrau, Rot |
  | Immernacht | tiefes Blau, Laternen-Gold (später) |

- **Akzentfarben der Elemente** (für Monster, siehe MONSTER.md): Feuer rot-orange, Erde braun, Pflanze grün,
  Blitz gelb, Wasser blau, Wind hell-türkis, Licht gold-weiß, Schatten dunkles Indigo, Sternenkraft (Splitter) lila.
  Blau in der Anzeige bleibt trotzdem nur für Nebenaufträge, die Akzentfarbe gilt nur am Monster selbst.
- **Feste Farbflächen für Variante C** (Klassen-Körper und Figuren-Baukasten): **Hauptfarbe, Zweitfarbe, Metall,
  Leder, Haut.** Jede Fläche nur aus wenigen festen Farbtönen, damit das Spiel sie sauber umfärben kann
  (Rüstungs-Sets, später Färbemittel, Kleidung pro Region).
- **Novizen werden nicht umgefärbt.** Umfärben gibt es erst mit Rüstung und Klasse (Beschluss 28./29.10.).

## 7. Umrisslinie

- **Farbe:** fast schwarz (#000000 bis etwa #1d1714), bei warmen Teilen darf sie ins Dunkelbraune gehen.
- **Dicke in der Bilddatei:** Figuren und Monster etwa **4 bis 5 Pixel**, Baukasten-Teile etwa **2 Pixel**.
- **Prüfung:** Mindestens die Hälfte der Randpixel eines Bildes muss dunkel sein (Helligkeit höchstens 70 von 255).
  Flache Bodenteile (Rauten) brauchen keinen Umriss.

## 8. Aussehen nach Variante C „Ragnarok plus“ (beschlossen 29.10.)

- Der **Körper zeigt die Klasse.** Sichtbar und tauschbar sind **Kopfbedeckung**, **Rückenteil** (Umhang, Köcher,
  Flügel) und **Waffe**. Rüstung und Sets zeigen sich über **Umfärben des Körpers**. Ganze Outfits im Shop nur selten.
- **Regeln für Bilder:**
  - Körper werden **ohne Waffe** gezeichnet, die Hand greift ins Leere (die Waffe kommt als eigenes Teil dazu,
    pro Bild ein Handpunkt). Ausnahme: Der Schild der Novizen bleibt am Körper, und bei ihrem Kurzschwert bleibt der Griff in der Hand, die Waffe liegt im Spiel darüber (01.11., ChatGPT entfernt Griffe nicht sauber).
  - **Köpfe ohne Hut**, alle Köpfe gleich groß und an derselben Stelle.
  - **Feste Farbflächen** (Abschnitt 6).
  - **Platz am Rücken** frei lassen, damit Umhang, Köcher oder Flügel dahinter passen.
- **Aussehen-Plätze** sind getrennt von den Werten.
- **Waffen-Familien** mit je einer Grundhaltung: Stab, Hammer, Klinge, Bogen, Instrument, Laterne. Der Novize trägt
  ein Kurzschwert als eigenes Teil.
- **Reihenfolge:** Regeln und Prüfen, Probe am Novizen (Hut, Umhang, Umfärbung), Testtag Aussehen, erst dann
  Klassen-Körper.

## 9. Der feste Stil-Block

Dieser Text kommt **wörtlich** in jeden Bild-Prompt (in ChatGPT als Projekt-Anweisung, siehe
`Spieldesign/GRAFIK_AUFTRAG.md`, Teil A). Er wird nie umformuliert. Ändern darf ihn nur Marco; dann wird er hier und
in GRAFIK_AUFTRAG.md gleichzeitig geändert. Stand: GRAFIK_AUFTRAG.md Teil A vom 13.11.2026 (Zusatz „Blätter mit Bewegung“, von Marco freigegeben).

```
Du malst Grafiken für „Asterfall“, ein düster-episches 2D-Fantasy-Rollenspiel (MMO) von CazeX Studio. Halte dich bei JEDEM Bild an diese Regeln, auch wenn ich sie in einer Nachricht nicht wiederhole.

STIL
- Hochwertige Pixel-Art wie Octopath Traveler und Ragnarok Online: warm, detailreich, klare dunkle Umrisse, leicht düster-episch, mittelalterliche Fantasy.
- Figuren im Chibi-Verhältnis wie die angehängte Vega (großer Kopf, etwa 3 Kopflängen hoch), freundliche, ausdrucksstarke Gesichter.
- Licht immer von links oben.
- TAGESLICHT und neutrale Farben. KEIN Glühen, KEIN Lichtschein um Figuren oder Dinge, keine Lichtkegel auf dem Boden. Nacht, Leuchten und Zauber-Effekte macht das Spiel. (Ausnahme: wenn ich ausdrücklich einen Effekt im Bild verlange, z. B. ein Geschoss.)

AUFBAU JEDES BILDES
- Echter durchsichtiger Hintergrund (PNG mit Transparenz). KEIN gemaltes Karomuster, kein Farbverlauf, keine Schatten-Wolke dahinter.
- Sprite-Sheet: mehrere Bilder in Reihen, mit viel Abstand. Nichts berührt oder überlappt sich.
- Keine Texte, Zahlen, Rahmen oder Beschriftungen.
- In einer Reihe sind alle Bilder gleich groß, die Figur hat in jedem Bild dieselbe Größe und die Füße stehen immer auf derselben Höhe.
- Animationen sind in sich geschlossen: Das letzte Bild geht nahtlos ins erste über (außer bei Angriff, Getroffen und Fallen).

ZWEI ANSICHTEN
1. WELT: isometrisch von schräg oben (2:1, Bodenfelder sind Rauten, doppelt so breit wie hoch). Figuren sieht man schräg von vorne rechts oder schräg von hinten rechts. Gebäude sieht man von der Ecke.
2. KAMPF: seitlich wie in Final Fantasy 6. Jede Figur und jedes Monster schaut nach RECHTS.

FARBWELTEN DER REGIONEN
- Kreuzweg (Startstadt): warmes Fachwerk, rote Ziegel, graues Pflaster, Banner in Dunkelrot.
- Messinghafen: Messing, Kupfer, Braun, Zahnräder, Dampf, Hafen.
- Glutoase: Sandgelb, Orange, Glutrot, Wüste und Vulkan, Schmieden.
- Grünwacht: Grüntöne, Erdbraun, Urwald, Dorf in Baumkronen.
- Arkanum: Blau, Violett, Silber, Türme auf schwebenden Felsen.
- Nebelinseln: Rosa, Weiß, Nebelgrau, Rot, japanisch inspiriert, Schreine.
- Immernacht (geheim, später): dunkles Blau, Laternen statt Sterne.

FIGUREN (Spieler und Figuren der Welt)
- Körper OHNE Waffe malen: Die Waffenhand bleibt halb geschlossen und greift ins Leere, so als hielte sie einen Griff. Keine Waffe, kein Schwert, kein Stab, kein Bogen im Bild. (Ausnahme nur, wenn ich ausdrücklich eine Waffe verlange.)
- Köpfe OHNE Hut, Helm, Kapuze oder Krone. Alle Köpfe gleich groß und an derselben Stelle über dem Halsansatz.
- Den Rücken frei lassen: kein Umhang, kein Köcher, keine Flügel, kein Rucksack. Dort kommt später ein eigenes Teil hin.
- Kleidung aus wenigen klaren Farbflächen: eine Hauptfarbe, eine Zweitfarbe, Metall, Leder und Haut. Jede Fläche nur in 3 bis 4 Tönen (hell, mittel, dunkel, Schatten), keine Muster, keine Verläufe, keine Stickerei.
- Keine Effekte im Figurenbild: keine Funken, Blitze, Schwungbögen oder Sterne. Die macht das Spiel.

BLÄTTER MIT BEWEGUNG (Sprite-Sheets)
- Liegt eine Posen-Vorlage mit Gliederpuppen bei, gilt sie Feld für Feld für Aufteilung, Platz, Größe, Blickrichtung und Beinstellung. Rot ist die rechte Körperseite der Figur, Blau die linke. Jeder Fuß steht dort, wo der Fuß der Puppe steht. Die Puppen und ihre Farben kommen nie ins Bild.
- Liegt ein Figuren-Blatt bei, ist es die einzige Quelle für Aussehen und Malstil. Nichts dazuerfinden, nichts weglassen.
- Die Figur ist in jedem Feld dieselbe: gleiche Größe, gleiche Farben, gleiche Kleidung. Nur die Pose ändert sich.
- Gehen ist ruhiges Gehen (aufrecht, kleine Schritte, immer ein Fuß am Boden), kein Rennen, außer ich verlange es.
- Hintergrund bei Blättern mit Bewegung: einfarbig reines Pink (#FF00FF) statt durchsichtig, ohne Verlauf und ohne Bodenschatten.
- Vor der Abgabe selbst prüfen: Anzahl der Reihen und Felder stimmt, kein Feld leer oder doppelt, nichts abgeschnitten, nichts berührt sich. Stimmt etwas nicht, neu malen statt abgeben.

Wenn ich ein Vorbild-Bild anhänge, übernimm Gesicht, Haare, Kleidung, Waffe und Farben exakt und ändere nur die Pose.
```

Hinweis: Projekt 13, Schritt 1 erweitert den Stil-Block um die Regeln von Variante C (Abschnitt 8). Das passiert erst
mit Marcos Ja zum neuen Wortlaut.

### 9a. Zusatz „FIGUREN“ (Projekt 13, Schritt 1, von Marco bestätigt am 02.11.2026)

Der Block steht jetzt im Stil-Block oben, in `Spieldesign/GRAFIK_AUFTRAG.md` Teil A und in Marcos ChatGPT-Projekt.
Damit sind die Bilder gleich aufgebaut, das Spiel kann Waffe, Hut und Rückenteil darüberlegen und die Kleidung sauber
umfärben. Für die Novizen gilt weiter die Ausnahme aus Abschnitt 8 (Schild am Körper, Griff in der Hand).

## 10. Referenzbilder

Liegen in `tools/referenz/` und in `data/look_palette.json` (Feld `referenzbilder`).

| Datei | Was | Status |
|---|---|---|
| `figur_vega.png` | Vega, Stehen im Kampf (Muster für Figuren) | **abgenommen** von Marco (01.11.) |
| `baukasten_gilde.png` | Abenteurergilde in Kreuzweg (Muster für Gebäude) | **abgenommen** von Marco (01.11.) |
| `monster_moosling.png` | Moosling, Stehen im Kampf (Muster für Monster) | **abgenommen** von Marco (01.11.) |

Hinweis zu Vega: Sie hat ihren Stab eingemalt. Sie ist das Muster für den **Stil** (Gesicht, Farben, Umriss,
Proportionen), nicht für den Aufbau eines Körpers; dort gilt „Körper ohne Waffe“ (Abschnitt 8).

Marco hat die drei am 01.11. abgenommen (`"referenzen_abgenommen": true` in `data/look_palette.json`). Sollen später
andere Bilder Muster werden: nur mit Marcos Ja die Dateien tauschen und `python3 tools/look_pruefen.py palette`
laufen lassen (baut die Palette neu).

## 11. Stand der Bilder im Spiel (Prüfung vom 01.11.)

Erste Bestandsaufnahme mit `tools/look_pruefen.py`. Die genaue Liste, was neu gezeichnet oder angepasst werden muss,
ist Projekt 13, Schritt 2.

- **Passen fast ganz:** Kofi und die Novizen-Körper, Moosling, die drei Kobolde, Vega, die meisten Baukasten-Teile.
- **Markierfarbe:** Die ganzen Novizen-Bilder in `assets/figuren/novize_*` enthalten reines Grün (#00f000) als
  Markierfarbe und fallen deshalb durch. Die Körper-Teile in `assets/teile/koerper/`, aus denen das Spiel die Novizen
  zusammensetzt, passen.
- **Weichen in den Farben deutlich ab:** Sternenfresser (kräftiges Pink und Lila), Feldschleim, Glutwelpe (sehr
  kräftiges Orange).
- **Erwartete Ausnahmen:** Bilder mit eingemaltem Effekt (Wasserstrahl und Welle des Bachotters, Vegas Parade) und
  die leuchtenden Story-Teile im Baukasten (Splitterkreis, Krater, Sternsplitter) haben fremde Farben oder einen
  hellen Rand. Effekte sind laut Stil-Block erlaubt, wenn sie ausdrücklich bestellt sind.
- **Kleinere Abweichungen:** Kopf m3 hat einen helleren Umriss als die anderen Köpfe; einige Köpfe von w2 und w3
  sind 71–73 statt höchstens 70 Pixel hoch; einzelne Angriffsbilder der Kobolde haben einen etwas helleren Rand.
- Ob Kofis und die Novizen-Bilder Schwert und Schild eingemalt haben (Regel „Körper ohne Waffe“), prüft Schritt 2
  (Ergebnis in Abschnitt 12).

## 12. Was neu gezeichnet oder angepasst werden muss (Projekt 13, Schritt 2, Prüfung vom 02.11.2026)

Geprüft: alle Körper-Teile in `assets/teile/koerper/` (Kofi 49, Novize männlich 52, Novize weiblich 54 Bilder), mit
`tools/look_pruefen.py` und mit Blick auf jedes Bild.

**Farben:** Alle Novizen-Bilder passen zur Palette. Bei Kofi passen 45 von 49; die vier anderen (Angriff Bild 4 und 5,
Fallen Bild 5 und 6) sind nur zu breit, weil Schwert oder liegender Körper weit hinausragen. Das erledigt sich mit
der Waffe als eigenem Teil.

**Waffe eingemalt (Regel „Körper ohne Waffe“):**

| Bilder | Kurzschwert | Schild | Was zu tun ist |
|---|---|---|---|
| Novize männlich und weiblich, alle Reihen | ganz eingemalt (Griff und Klinge) | am Körper | **neu:** Blätter mit Griff ohne Klinge (Teil D in GRAFIK_AUFTRAG.md). Blatt 1 männlich liegt schon vor (`tools/vorlagen/novize_m_kampf_a_ohne_klinge.png`), es fehlen männlich Blatt 2 und 3 und alle drei weiblichen. |
| Novize, Fähigkeit wirken (je 3 Bilder) | nicht zu sehen | am Körper | Schwert fehlt ganz. Beim Einbauen dort das Schwert ausblenden oder am Gürtel zeigen. |
| Kofi, alle Reihen | ganz eingemalt | am Körper | **nicht neu zeichnen:** Kofis Bilder sind die Vorlage aus der Zeit vor dem gemeinsamen Novizen-Körper. Kofi ist Novize m1 (design.md, 28.10.) und bekommt mit Schritt 3 den Novizen-Körper ohne Klinge. Die Kofi-Blätter bleiben nur als Vorlage für neue Bildaufträge. |

**Weitere Fehler in den Bildern:**

- **Eingemalte Effekte:** Novizen haben gelbe Funken bei Getroffen, Parade (Bild 2 und 3) und Sieg, dazu einen
  rosa Schwungbogen im Angriff Bild 4. Kofi ebenso, dazu ein Treffer-Stern im Angriff Bild 4. Im neuen Blatt
  `novize_m_kampf_a_ohne_klinge.png` sind die gelben Funken auch drin. → Claude entfernt sie beim Zuschneiden, das
  Spiel zeigt eigene Effekte.
- **Reste vom Kopf:** Bei beiden Novizen ist um den Kopfplatz ein dünner grauer Ring geblieben (Rand des grünen
  Platzhalters). Bei Kofi stehen Haarsträhnen und dunkle Umrissreste über dem Hals, und in **Fallen Bild 5 und 6 ist
  sein ganzer Kopf noch eingemalt**. → Claude räumt die Reste beim Zuschneiden der neuen Blätter mit auf. Kofis Reste
  stören nicht mehr, sobald er den Novizen-Körper trägt.
- **Farbflächen:** Die Novizen bestehen aus Leder, hellem Hemd, dunkler Hose und den grauen Flächen (Halstuch,
  Schildrand), die das Spiel einfärbt. Das passt, denn Novizen werden nicht umgefärbt. Für das Umfärben (Projekt 13,
  Schritt 5) taugen sie nicht: Die Töne gehen weich ineinander über. Die Klassen-Körper brauchen deshalb die
  Regel „wenige klare Farbflächen“ aus Abschnitt 9a.
- **Rücken:** Frei bei beiden Novizen und bei Kofi, nur das Halstuch weht nach hinten. Ein Umhang passt dahinter.

**Kurz:** Neu zeichnen musst nur du die fehlenden fünf Novizen-Blätter ohne Klinge. Alles andere räumt Claude beim
Einbauen auf.
