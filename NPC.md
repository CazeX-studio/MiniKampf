# NPC.md – Regelblatt für alle Figuren der Welt

> Beschlossen am 01.11.2026 (Sitzung 30, „Kreuzweg im neuen Look und die NPCs“). Angelegt am 01.11.2026 als eigene
> Datei wie `LOOK.md` und `MONSTER.md`. Quelle: Brainstorm-Doc „CazeX MMO – Brainstorming“, Sitzung 30.
> Wo diese Datei und `design.md` (Repo Spieldesign) sich widersprechen, gilt design.md.
> Für das Aussehen gilt zusätzlich `LOOK.md` (Palette, Prüfung, Abnahme per Vergleichsbild).

## Regel für Claude Code

- Eine neue Figur wird **nur mit vollem Steckbrief** gebaut (Teil 2) und **gegen dieses Regelblatt geprüft**.
- **Abweichungen meldet Claude Code an Marco**, statt sie selbst zu entscheiden.

---

## Teil 1: Die Regeln

### 1. Was schon vorher feststand

- **Figuren wie bei Ragnarok:** Körper getrennt vom Kopf, alle Köpfe gleich groß. **Variante C:** Hut und Rückenteil
  als eigene Schicht, Waffe als eigenes Teil, Umfärben über feste Farbflächen (LOOK.md, Abschnitt 8).
- **Porträts mit Stimmungen:** ruhig, lächelnd, wütend, traurig, überrascht.
- **Sprach-Leitfaden** (design.md, „Sprache der Figuren“): höchstens drei Zeilen pro Textfeld, Sprache pro Region,
  ein Merkmal pro Figur, Humor nur bei Nebenfiguren, nie Humor und Düsteres im selben Satz.
- **Zeichen über dem Kopf:** gelbes „!“ und „?“ für die Hauptgeschichte, **blaue** für Nebenaufträge.

### 2. Drei Stufen von Figuren

| Stufe | Wer (Beispiele) | Körper | Kopf | Porträt | Bewegungen |
|---|---|---|---|---|---|
| **Hauptfigur** | Ye, Marv, Bingo, Mira, Kael, Ren, die Fünf, alle Lehrmeister, Esche, Tilda | eigener | eigener | alle fünf Stimmungen | eigene für ihre großen Szenen |
| **Nebenfigur** | Hanne, Edmar, Brom, Quill, Pip, Lotte, Ilse, Tamm, Hatta, Nadia, Zaid | aus dem Figuren-Baukasten | eigener | zwei bis drei Stimmungen | Baukasten |
| **Volk** | Bürger, Wachen, Marktleute | ganz aus dem Baukasten | Baukasten | keins | Baukasten; nur ein bis zwei kurze Sätze |

### 3. Figuren-Baukasten (für den Anfang, darf wachsen)

- **Acht Grundkörper:** Mann, Frau, Kind, alter Mensch, Wache, Händler, Handwerker, Gelehrter. Gleiche Regeln wie für
  die Spielerfiguren (Kopf getrennt, Hut-Schicht, feste Farbflächen).
- Dazu ein Satz **Köpfe, Frisuren und Hüte.** Die Hüte des Hutmachers passen so auch auf die Figuren der Welt.
- **Umfärben nach der Palette der Region:** Aus einem Körper wird ein Bürger in Kreuzweg und einer in der Glutoase.

### 4. Kleidung pro Region (vorläufig, Marco beurteilt es im Spiel)

Ein typisches Teil pro Region auf dem Körper, damit man sofort sieht, woher jemand kommt.

| Region | Farben | Typisches Teil |
|---|---|---|
| Kreuzweg | warme Alltagsfarben | Halstuch in einer der fünf Farben zum Fest |
| Grünwacht | Grün und Braun | Kapuzen und Federn |
| Glutoase | Sand und Rot | Kopftücher und Schmiedeschürzen |

### 5. Steckbrief pro Figur

**Name · Stufe** (Haupt, Neben, Volk) **· Ort am Tag / Ort in der Nacht · Aufgabe** (Händler, Auftrag, Lehrmeister,
Dienst, Stimmung) **· Sprach-Merkmal** in einem Satz **· Porträt-Stimmungen · Aussehen** (Körper, Kopf, Hut, Farben).

### 6. Leben in der Stadt

- Das **Volk** geht kleine Runden oder steht an seinem Platz. **Nachts** sind weniger Leute unterwegs.
- **Nachts sind die Marktstände zu, Läden und Dienste bleiben offen** (wer nachts spielt, kann alles erledigen),
  dafür ist das Gasthaus voll.
- **Feste Zeichen über Diensten**, damit man sie schnell findet (wie die Kafra in Ragnarok):

  | Dienst | Zeichen |
  |---|---|
  | Händler | Münze |
  | Bank | Truhe |
  | Hutmacher | Hut |
  | Wegelaterne | Laterne |

### Prüfliste vor dem Einbau

1. Steckbrief vollständig (alle Punkte aus 5.)?
2. Stufe richtig, und passen Körper, Kopf, Porträt und Stimmungen zur Stufe (Tabelle in 2.)?
3. Kleidung und Farben passen zur Region (4.) und zur Palette (LOOK.md)?
4. Ort am Tag und in der Nacht eingebaut, Zeichen über dem Dienst (6.)?
5. Sätze nach dem Sprach-Leitfaden (höchstens drei Zeilen, Sprache der Region, Merkmal der Figur)?
6. Bild mit `tools/look_pruefen.py` geprüft und Vergleichsbild von Marco abgenommen?

---

## Teil 2: Steckbriefe (beschlossen 01.11.)

Aufbau jeder Zeile: Stufe · Ort am Tag / in der Nacht · Aufgabe · Sprache · Porträt-Stimmungen · Aussehen.

### Kreuzweg

Sprache: freundlich, alltäglich, Sprichwörter über die Fünf („So wahr die fünf Wege!“). Kleidung: warme
Alltagsfarben, zum Fest ein Halstuch in einer der fünf Farben.

**Hauptfiguren**

- **Ye:** Haupt · Tag Trainingsplatz im Hinterhof der Gilde / Nacht in der Gilde am Kamin unter der alten Laterne ·
  Lehrmeister des Novizen (Grundausbildung, Parieren), Hauptgeschichte, Empfehlungsschreiben · knapp, trocken, leicht
  gelangweilt, lobt selten und dann ehrlich · alle fünf Stimmungen · eigener Körper, schlichte, abgetragene Kleidung,
  wirkt gelangweilt. **Kein Schild, sondern ein Regenschirm** (Anspielung auf Ye Xiu aus The King's Avatar): Beim
  Training pariert er mit dem aufgespannten Schirm, sonst trägt er ihn geschlossen in der Hand.
  - **Sprüche (beschlossen 01.11.), ersetzen „Schild hoch, Schild runter“:**
    - Beim Parieren: „Nicht nachdenken. Deine Hände wissen es vor dir.“
    - Wenn man es nicht schafft: „Zu langsam. Noch mal.“
    - Seltenes Lob: „Nicht schlecht. Für einen Anfänger.“
    - Hinweis auf den Klassenlosen: „Jede Klasse hat eine Schwäche. Wer alle kennt, hat keine.“
    - Nachts in der Gilde: „Nachtschicht. Irgendwer muss ja auf die Laterne aufpassen.“
    - Frech zu Marv: „Du redest schneller, als du kämpfst. Das ist eine Leistung.“
  - **Kleine Szene:** Beim Parier-Training wird der Schirm für einen Augenblick zu einer anderen Waffe und gleich
    wieder zum Schirm. Ye tut so, als wäre nichts gewesen.
- **Marv:** Haupt · Tag Gilde am Auftragsbrett / Nacht im Wegrast beim Kartenspielen · Gegner bei Kreuzweg-Karten,
  kommentiert neue Karten, Humor · überdreht, redet zu schnell, viele Ausrufezeichen („Hast du's schon? Das Brett!
  Die Tafel!“) · alle fünf Stimmungen · eigener Körper wie im Spiel.
- **Bingo:** Haupt (Lehrmeister des Quartiermeisters) · Tag und Nacht in seiner Zweigstelle am Markt, nachts zählt er
  Münzen · Händler mit eigener Ware (Sternentafel), kauft doppelte Karten · charmant, rechnet in jedem Satz, nennt alle
  „Kundschaft“ („Gold ist ehrlich. Menschen nicht.“) · alle fünf Stimmungen · eigener Körper wie im Spiel.
- **Mira:** Haupt · wie in der Kreuzweg-Demo, Begegnung nachts am sechsten Tor nach dem Auftrag „Essen für Brom“ ·
  Hauptgeschichte, Hinweis auf das Summen · leise, bricht Sätze ab („Hörst du sie auch? Nein … natürlich nicht.“) ·
  alle fünf Stimmungen · eigener Körper wie im Spiel.
- **Die fünf Gesandten:** Haupt (für die Probestunden) · Tag in ihrem Pavillon im Gesandten-Hof / Nacht zum Fest auf
  dem Marktplatz, sonst im Pavillon · Probestunden, kleine Aufträge auf ihrer Straße · Sprache ihrer Region · alle fünf
  Stimmungen · Kleidung und Farben ihrer Region. Namen wie im Spiel.

**Nebenfiguren**

- **Lene:** Neben · Tag und Nacht am Empfang der Gilde (Dienst) · Aufträge, Empfehlungsschreiben, später Briefe in die
  Regionen · freundlich und ordentlich, hat für alles ein Formular · ruhig, lächelnd, überrascht · Körper Gelehrter,
  Brille, Feder hinter dem Ohr.
- **Wirtin Hanne:** Neben · Tag und Nacht im Wegrast, nachts ist es voll · erster Auftrag (Hannes Kater), Festschüssel
  für Brom, Gerüchte, Feuerstelle zum Kochen im Hof · herzlich, laut, weiß jedes Gerücht · lächelnd, überrascht,
  wütend · Körper Frau, Schürze, Kochlöffel, rote Wangen.
- **Bankhüterin Ilse:** Neben · Tag und Nacht in der Bank (Dienst) · Bank · ruhig und genau, zählt alles zweimal ·
  ruhig, lächelnd · Körper alter Mensch, Ärmelschoner, Schlüsselbund am Gürtel.
- **Vogt Edmar:** Neben · Tag an der Festbühne / Nacht nur zum Fest, sonst nicht zu sehen · organisiert das Fest der
  fünf Wege, Vogt-Auftrag · feierlich, glaubt jedes Wort der Legende („So wahr die fünf Wege!“) · lächelnd,
  überrascht, traurig (für Akt 3) · Körper Mann, Amtskette, Festschärpe in den fünf Farben.
- **Torwache Brom:** Neben · Tag und Nacht am sechsten Tor · Wache, Auftrag „Essen für Brom“, erzählt vom Summen ·
  „Da geht's nirgendwohin. Befehl ist Befehl.“, weiß selbst nicht, warum er dort steht · ruhig, überrascht · Körper
  Wache, alter Helm, gähnt.
- **Steinmetz Quill:** Neben · Tag an der Statue / Nacht zu Hause, nicht zu sehen · Auftrag „Glanz für die Fünf“,
  leiser erster Hinweis · nachdenklich, findet, die Gesichter sehen „nicht nach Sieg aus“ · ruhig, traurig · Körper
  Handwerker, Schürze voller Steinstaub, Meißel.
- **Pip und Lotte:** Neben · Tag am Brunnen / Nacht zu Hause, zum Fest auf dem Markt · Auftrag „Die Dunkelheit
  spielen“, in Akt 3 spielen sie es anders herum · kindlich, streiten sich, niemand will die Dunkelheit sein ·
  lächelnd, wütend, überrascht · Körper Kind, Pip mit Holzschwert, Lotte mit Papierkrone.
- **Tessa und Gorm:** Neben, kämpfen aber mit · Tag Trainingsplatz / Nacht im Wegrast · Mitschüler, füllen die Gruppe
  auf, wenn man allein spielt (erster Gruppenkampf, Sternenfresser) · Tessa übereifrig, Gorm ängstlich · Tessa
  lächelnd, überrascht, wütend, Gorm ruhig, traurig, überrascht · Novizen-Körper (wie alle Novizen gleich), eigene Köpfe.
- **Hutmacher Hatta:** Neben · Tag und Nacht im Laden neben Bingo (Dienst) · tauscht Monster-Beute gegen Hüte ·
  schwärmt von Hüten und sieht jedem zuerst auf den Kopf („Ein Kopf ohne Hut. Was für eine Verschwendung.“) ·
  lächelnd, überrascht · Körper Händler, riesiger verrückter Hut, Maßband um den Hals. Name als Anspielung auf den
  Hutmacher aus „Hinter den Spiegeln“ von Lewis Carroll.

**Volk**

- Wachen an den drei Toren nach Messinghafen, zu den Nebelinseln und nach Arkanum: Körper Wache · „Die Straße ist noch
  gesperrt.“
- Marktleute (zwei bis drei) am Marktplatz, nur am Tag: Körper Händler · rufen ihre Waren aus.
- Bürger (drei bis vier) auf der Ringstraße, tags mehr, nachts weniger: Körper Mann, Frau, alter Mensch · ein Satz über
  das Fest oder die Fünf.
- Gäste im Wegrast (drei), vor allem nachts: Körper Mann, Frau, Handwerker · Gerüchte.
- Nach Akt 1 dazu: Splitter-Sucher am Krater (Körper Gelehrter und Handwerker).

### Grünwacht (Wipfelheim)

Sprache: wenige Worte, Vergleiche aus der Natur, lange Pausen. Kleidung: Grün und Braun, Kapuzen und Federn.

**Hauptfiguren**

- **Ysolde Dornfeder:** Haupt (eine der Fünf) · Tag auf der Hauptplattform / Nacht heimlich am leeren Grab ihres
  Bruders Rowan · Hauptgeschichte (Splitter im Wald, Kael, das leere Grab, das Ende) · beherrscht, beschützend,
  verschließt sich bei jeder Frage nach früher · alle fünf Stimmungen · eigener Körper, Jägerin mit Langbogen und
  Federumhang als Rückenteil.
- **Pfadmeister Fenn:** Haupt (Lehrmeister Bogenschütze) · Tag auf seinem Schießplatz / Nacht am Rand einer Plattform,
  schaut in den Wald · Prüfung der drei Ziele · wortkarg („Ein Jäger weiß, wann er nicht schießt.“) · alle fünf
  Stimmungen · eigener Körper, Kapuze, Köcher als Rückenteil.
- **Rudelmeisterin Tilda:** Haupt (Lehrmeisterin Monster-Zähmer) · Tag und Nacht am Monster-Stall (Dienst) · lehrt das
  Zähmen, führt den Stall, schickt einen zu Esche · rau und herzlich · alle fünf Stimmungen · eigener Körper, kräftig,
  Fellweste, Hirtenstab, ein altes Monster an ihrer Seite.
- **Professor Esche:** Haupt · Tag in seiner Forscherhütte / Nacht schläft er dort über seinen Büchern · gibt das erste
  Monster zur Wahl (Glutwelpe, Moosling, Bachotter), freut sich später über neue Einträge im Kartenalbum · zerstreut,
  vergisst mitten im Satz, was er sagen wollte · alle fünf Stimmungen · eigener Körper, Notizbuch, Lupe, Blätter im
  Haar. Anspielung auf den Professor bei Pokémon, aber eigenes Aussehen.
- **Kael:** Haupt · wie im Spiel, kommt auf einer anderen Plattform angelaufen · Rivale, will Ysolde zum Geständnis
  zwingen · hart, kurz, spöttisch, nennt einen „Novize“ · alle fünf Stimmungen · eigener Körper wie im Spiel.
- **Marv:** wie in Kreuzweg; hängt in Grünwacht an einer Hängebrücke („Sorry, ich muss gerade Eichhörnchen zählen.“),
  wenn man schon mit ihm gespielt hat.

**Nebenfiguren**

- **Kobalt:** Neben, kämpft aber mit · Tag vor Esches Hütte / Nacht nicht zu sehen · Esches Neffe, Rivale des Zähmers,
  wählt immer das Gegenstück-Monster, zweiter Kampf erst nach dem Dungeon · frech und selbstsicher · lächelnd, wütend,
  überrascht · Körper aus dem Baukasten, eigener Kopf, Halstuch, Schleuder. Steht im Kampf hinter seinem Monster.
- **Bankhüter Tamm:** Neben · Tag und Nacht im Bank-Baumhaus (Dienst) · Bank · bedächtig, spricht so langsam, wie ein
  Baum wächst · ruhig, lächelnd · Körper alter Mensch, Moos auf dem Hut.
- **Kräuterhändlerin Salbei:** Neben · Tag und Nacht an ihrem Stand auf einer Plattform (Dienst) · Händlerin mit
  eigener Ware (Kochzutaten aus dem Wald), Heiltränke und Grundmaterialien · sanft, riecht an allem, bevor sie es
  verkauft · lächelnd, überrascht · Körper Händler, Kräuterbündel am Gürtel, Korb.
- **Wirt und Koch Borko:** Neben · Tag und Nacht im Baumhaus-Gasthaus, nachts ist es voll · lehrt den Beruf Kochen,
  Gruppen-Topf an der Feuerstelle · brummig, aber großzügig mit den Portionen · lächelnd, wütend · Körper Mann,
  Kochmütze, Schöpfkelle.
- **Oma Hagebutte:** Neben · Tag auf einer Bank vor ihrem Baumhaus / Nacht im Gasthaus · erste richtige Gegnerin bei
  Kreuzweg-Karten · wirkt lieb, spielt gnadenlos („Na, Kindchen. Noch eine Runde?“) · lächelnd, überrascht · Körper
  alter Mensch, Strickjacke, Kartenstapel.

**Volk**

- Jäger (zwei) auf den Plattformen und am Weg nach Hirschtal: Körper Mann und Frau mit Kapuze · ein Satz über
  veränderte Tiere.
- Sammlerinnen (zwei) mit Körben, nur am Tag: Körper Frau · reden über Pilze und Kräuter.
- Kinder (zwei) an den Hängebrücken, nur am Tag: Körper Kind · spielen Jäger und Hirsch.
- Gäste im Gasthaus (zwei bis drei), vor allem nachts: Gerüchte über die Pilzhöhle.
- Kein Mensch, aber ein Ort für einen Nebenauftrag: der verrückte Bienenstock (Hinweis auf die spätere Bienenhüterin).
  Für den Baukasten fehlen noch das leere Grab von Rowan und der Bienenstock (Blatt G6).

### Glutoase (Terrassenstadt)

Sprache: blumig und bildhaft, Bilder von Feuer und Sternen („Möge deine Glut nie erkalten.“). Kleidung: Sand und Rot,
Kopftücher und Schmiedeschürzen.

**Hauptfiguren**

- **Hadrak Glutherz:** Haupt (einer der Fünf) · Tag in seiner Schmiede auf der oberen Terrasse / Nacht im Gasthaus, wo
  er trinkt · Hauptgeschichte (kochende Brunnen, Rivalenkampf mit Kael in seiner Schmiede, Vulkanschmiede), wer sein
  Vertrauen hat, hört betrunken „Wir sind gerannt.“ · fast nur Einwortsätze, betrunken plötzlich lange, gebrochene
  Sätze · alle fünf Stimmungen · eigener Körper, breit, verbrannte Lederschürze, schwerer Hammer, Kettenglied um den Hals.
- **Essenmeister Brakkus:** Haupt (Lehrmeister Rüstungsschmied) · Tag und Nacht in seiner Werkstatt im Schmiedeviertel
  (Dienst) · lehrt den Rüstungsschmied, Schmiede-Aufgabe öffnet Hadraks Vertrauen, ahnt, dass die Ketten nachgeben ·
  brummig · alle fünf Stimmungen · eigener Körper, Rußgesicht, Handschuhe, Hammer.
- **Tanzmeisterin Samira:** Haupt (Lehrmeisterin Klingentänzerin) · Tag am Tanzplatz / Nacht beim Tanz am Feuer auf dem
  Tanzplatz · Prüfung: ihre Schrittfolge im Takt nachtanzen, als kleiner Kampf; der Tanz mit der Pause beim Fest ·
  streng und warm · alle fünf Stimmungen · eigener Körper, Tanzgewand mit Glöckchen, Zwillingsklingen.
- **Hohe Sängerin Xavina:** Haupt (Lehrmeisterin Sternensängerin) · Tag in ihrem Zelt an der Sternendüne / Nacht auf
  dem Steinkreis der Sternendüne in der Palmenrast (die Lern-Szene ist immer Nacht) · lehrt die Sternensängerin,
  Nebenauftrag Sternbilder nachzeichnen · feierlich · alle fünf Stimmungen · eigener Körper, langes Gewand mit
  Sternenmuster, Harfe.
- **Mira:** Haupt · Tag und Nacht im Krankenzelt auf der unteren Terrasse · Miras Lied (fünf Töne aufschreiben, der
  sechste fehlt), am Ende die Entscheidung um ihren Splitter · leise, bricht Sätze ab, summt im Fieber · alle fünf
  Stimmungen · eigener Körper wie im Spiel, hier krank im Bett.
- **Kael:** Haupt · taucht beim Fest auf und provoziert Hadrak, Rivalenkampf in der Schmiede · wie in Grünwacht.

**Nebenfiguren**

- **Brunnenhüterin Nadia:** Neben · Tag und Nacht am großen Brunnen, misst das Wasser · Auftrag „Kochende Brunnen“ ·
  besorgt und blumig („Das Wasser fiebert wie ein Kind.“) · ruhig, traurig, überrascht · Körper Frau, Kopftuch,
  Wasserkrug.
- **Karawanenführer Zaid:** Neben · Tag am Karawanenplatz / Nacht am Lagerfeuer dort, erzählt Geschichten · Auftrag
  „Karawane durch die Dünen begleiten“, später die Kutsche nach Kreuzweg · weitgereist, prahlt gern · lächelnd,
  überrascht · Körper Händler, Turban, Reiseumhang.
- **Bankhüter Rashid:** Neben · Tag und Nacht in der Bank (Dienst) · Bank · höflich, spricht von Gold wie von Sternen ·
  ruhig, lächelnd · Körper alter Mensch, Kopftuch, Schlüssel am Gürtel.
- **Händler Tarek:** Neben · Tag und Nacht im Basar-Laden (Dienst) · Händler mit eigener Ware (Grundwaffen aus den
  Schmieden), dazu Heiltränke und Grundmaterialien · laut und begeistert, jede Klinge ist „die beste der Oase“ ·
  lächelnd, überrascht · Körper Händler, Schärpe, Klinge am Gürtel.
- **Wirtin Layla:** Neben · Tag und Nacht im Gasthaus mit Lagerfeuer im Innenhof, nachts voll und laut · Lagerfeuer zum
  Kochen, Gerüchte, schenkt Hadrak nach · fröhlich und schlagfertig · lächelnd, wütend · Körper Frau, Schürze, Tablett.

**Volk**

- Schmiede der Clans (drei) im Schmiedeviertel: Körper Handwerker mit Schmiedeschürze · reden über Hadrak und die Glut.
- Tänzer (zwei), nur nachts am Feuer auf dem Tanzplatz: Körper Mann und Frau im Tanzgewand.
- Basar-Leute (zwei bis drei), nur am Tag: Körper Händler · rufen Waren aus.
- Karawanenleute (zwei) am Karawanenplatz: Körper Mann und Frau mit Reiseumhang.
- Aufzugwärter am Lastenaufzug: Körper Handwerker · „Festhalten, es ruckelt.“
- Gäste im Gasthaus (drei), vor allem nachts: Gerüchte über die kochenden Brunnen.

### Überall gleich

- **Rastplatz-Händler** an jedem Rastplatz der Straßen (zuerst Aschensteppe): Körper Händler, eine Figur, die überall
  gleich aussieht und dieselben Waren hat (Heiltränke, Grundmaterialien).

---

## Teil 3: Abweichungen zum Spiel (gemeldet an Marco, 01.11.)

Beim Anlegen gegen das Spiel geprüft. Nichts davon ist geändert; das Einbauen gehört zu den Fahrplan-Schritten
1.2 (Projekt 12), 1.9, 1.10 und 2.13.

1. **Ye:** Im Spiel sagt er noch „Schild hoch, Schild runter“ (in `data/dialoge.json`, `data/erfolge.json` und
   `data/kaempfe.json`) und hat keinen Regenschirm.
2. **Zähmer-Start:** Im Spiel gibt Esche zuerst das Monster und Tilda lehrt danach; beschlossen ist: erst Tilda, dann
   Esche (Projekt 12, Schritt 1).
3. **Noch nicht im Spiel:** Hutmacher Hatta, Kräuterhändlerin Salbei, Wirt Borko und alle Figuren der Glutoase.
4. **Figuren-Baukasten** mit den acht Grundkörpern gibt es noch nicht; Nebenfiguren und Volk nutzen bisher Platzhalter.
5. **Tag-und-Nacht-Orte** der Figuren und die **Zeichen über Diensten** sind noch nicht gebaut (Projekt 7 und
   Schritt 1.9).
