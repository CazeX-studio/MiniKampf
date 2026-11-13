# Balancing: Messungen zum Nachstellen

Gehört zu Bauauftrag E4 (`BAUAUFTRAEGE.md`). Hier steht, wie die Klassen gemessen werden, was am 12.11.2026 herauskam
und was noch offen ist. Nach jeder Änderung an einer Klasse dieselben Befehle wieder laufen lassen und vergleichen.

## So wird gemessen

`tests/klassen_messen.gd` spielt Kämpfe ohne Grafik durch: die Klasse auf einer Stufe, dazu zwei Novizen vom Computer,
gegen frei gewählte Monster. Je Klasse:

1. **nur Grundangriff** (Stufe 3),
2. **jede Fähigkeit einzeln dazu** (Stufe 3, auf der Leiste, samt dem, was sie braucht),
3. **alles auf Stufe 2**,
4. mit dem Wort `ohne` die **Gegenprobe**: alles gelernt, nur je eine Fähigkeit fehlt.

Ausgabe je Zeile: Siege in %, Leben der Gruppe am Ende (nur Siege), Züge je Sieg, Schaden der Klasse je 10 Züge.

Aufruf (Godot auf dem PC: `C:/GameDev/Godot/Godot_v4.7.2-stable_win64_console.exe`, in der Cloud: `~/godot/godot`):

```
<Godot> --headless --path . -s tests/klassen_messen.gd -- [anzahl] [stufe] [monster_stufe] [monster,…] [klasse] [allein] [ohne] [rudel] [wachstum]
```

Dazu an beliebiger Stelle (seit 12.11., Boss-Messung): `leben=3` (Leben der Gegner mal 3), `spielweise=wahllos|klug|beide`,
`nur=partner,kaefig` (nur diese Fähigkeiten messen, spart Zeit). Statt der Monster-Liste geht `kampf:<kennung>` für einen
Kampf aus dem Spiel (`kettenschmied`, `pilz_koenigin`, `pilz_urbaum`, `hammerbrueder`).

| Wort | Bedeutung | Beispiel |
|---|---|---|
| anzahl | Kämpfe je Zeile | `300` |
| stufe | Stufe der Gruppe | `20` |
| monster_stufe | Stufe der Gegner | `27` |
| monster | bis zu vier Monster, mit Komma | `steppenhyaene,feuerechse,sandwurm,glutkobold` |
| klasse | `archer`, `tamer`, `smith`, `blade`, `singer` oder `alle`; `liste` zeigt alle Monster-Namen | `alle` |
| allein | `allein` = ohne die zwei Novizen, sonst irgendein anderes Wort | `gruppe` |
| ohne | `ohne` = mit Gegenprobe | `ohne` |
| rudel | Monster des Zähmers, mit `+` (sonst alle drei Start-Monster) | `glutwelpe+moosling` oder `alle` |
| wachstum | Wachstum der Zähmer-Monster zum Ausprobieren (im Spiel: 0.1) | `1.0` |

## Die Standard-Messungen

Immer dieselbe Gegnergruppe, damit die Zahlen vergleichbar bleiben (`M=steppenhyaene,feuerechse,sandwurm,glutkobold`):

```
# 1. Alle Klassen, jede Fähigkeit einzeln und mit Gegenprobe (dauert einige Minuten)
<Godot> --headless --path . -s tests/klassen_messen.gd -- 300 20 27 steppenhyaene,feuerechse,sandwurm,glutkobold alle gruppe ohne

# 2. Dasselbe gegen stärkere Gegner (zeigt, welche Klasse vorne liegt, wenn Stufe 27 für alle zu leicht ist)
<Godot> --headless --path . -s tests/klassen_messen.gd -- 200 20 31 steppenhyaene,feuerechse,sandwurm,glutkobold alle

# 3. Zähmer mit kleinem Rudel (ein Monster)
<Godot> --headless --path . -s tests/klassen_messen.gd -- 200 20 27 steppenhyaene,feuerechse,sandwurm,glutkobold tamer gruppe nein glutwelpe

# 4. Jede Klasse allein
<Godot> --headless --path . -s tests/klassen_messen.gd -- 200 20 22 steppenhyaene,feuerechse,sandwurm alle allein

# 5. Bosse (vorhandene Messung, jede Klasse mit zwei Novizen)
<Godot> --headless --path . -s tests/boss_messen.gd -- kettenschmied 30 20
```

Unterschiede unter etwa 8 Punkten sind bei 200 bis 300 Kämpfen Zufall.

## Grenzen der Messung

- **Der Computer drückt zufällig** unter dem, was auf der Leiste liegt (`scripts/kampf/kampf_ki.gd`). Ein Mensch setzt
  einen Schutz im richtigen Moment. „Bringt nichts“ heißt: wahllos gedrückt ist es nicht besser als angreifen.
- **Nur eine Gegnergruppe**, vier Monster, alle Nahkampf. Fähigkeiten gegen ein einzelnes Ziel kommen schlecht weg,
  der Schmied (eine Rüstung reicht) kommt zu gut weg.
- **Elementpfeil** braucht besondere Munition und wird gar nicht benutzt.
- **Passive Fähigkeiten, die zu einer anderen gehören** (Sternenglanz, Nachhall, Rhythmus, Band), zeigen einzeln keinen
  Wert; dafür ist die Gegenprobe da.
- Der Computer-Schmied trägt seit 12.11. die Rüstung, die zu den meisten Gegnern passt, und drückt allein keine
  sinnlosen Schutz-Knöpfe. Davor wechselte er wahllos und verlor jedes Mal die Härte: Schmied-Zahlen von vor dem 12.11.
  (auch „gewinnt zu dritt selten“) gelten nicht mehr.

## Ergebnisse vom 12.11.2026

Gruppe Stufe 20 gegen die Standard-Gegner auf Stufe 27, Siege in %:

| Klasse | nur Grundangriff | alles auf Stufe 2 | alles, Gegner Stufe 31 |
|---|---|---|---|
| Bogenschütze | 31 | 81 | 58 |
| Rüstungsschmied (nach den Änderungen) | 60 | 100 | 98 |
| Klingentänzerin | 54 | 81 | 53 |
| Sternensängerin | 32 | 90 | 72 |
| Monster-Zähmer (vorher 99 / 100) | 84 | 90 | 73 |

Jede Fähigkeit einzeln zum Grundangriff dazu (Siege in %, Gegner Stufe 27):

| Klasse | Trägt die Klasse | Bringt nichts oder schadet |
|---|---|---|
| Bogenschütze (31) | Pfeilhagel 89, Durchschlag 82, Schnellfeuer 70, Jagdinstinkt 58 | Aufgeladener Schuss 35, Netzpfeil 41, Schwachstelle markieren 33 |
| Rüstungsschmied (60) | Funkenflug 99, Ambossschlag 98, Glühende Rüstung 77, Abfangen 77, Gehärtet 76 | Amboss aufstellen 59 |
| Klingentänzerin (54) | Sturmschritte 89, Fächerschnitt 87, Ausfallschritt 87, Wirbel 80 | Partnertanz 40, Klingenkäfig 39, Klingensturm 56 |
| Sternensängerin (32) | Mondwiegenlied 81, Sternschnuppenregen 73, Kometenlied 51 | Mondschild 24, Dissonanz 31 |
| Monster-Zähmer (84) | Zweites Leben 92, Wechsel 90, Rudelinstinkt 89 | Pflege 84, Gemeinsamer Angriff 83 |

Gegenprobe (voller Baum ohne eine Fähigkeit): Ohne Funkenflug fällt der Schmied von 100 auf 93, ohne Mondwiegenlied die
Sängerin von 90 auf 60, ohne Pfeilhagel der Bogenschütze von 82 auf 70. **Ohne Partnertanz steigt die Klingentänzerin
von 80 auf 90**, ohne Dissonanz die Sängerin von 90 auf 95.

Kettenschmied (Boss, mit Mechanik, 30 Kämpfe je Klasse): Bogenschütze 30, Sängerin 30, Klingentänzerin 27, Zähmer 25,
Schmied 20.

## Was am 12.11.2026 geändert wurde

- **Monster-Zähmer:** Seine Monster wachsen in Kämpfen der Welt nur noch zu einem Zehntel mit der Stufe des Helden
  (`Sandbox.zaehmer_monster_wachstum = 0.1`, Schaden und Leben), außer gegen einen anderen Zähmer (Kobalt). Vorher
  brauchte er Gegner auf Stufe 40 für 50 % Siege, die anderen Klassen Stufe 27.
- **Rüstungsschmied:** Härten sprüht zusätzlich Funken auf alle Gegner (`Skills.HAERTEN_FUNKEN = 5`), einzeln gemessen
  23 → 66 %. Abfangen fängt jeden Treffer bis zum nächsten Zug des Schmieds ab, 52 → 77 %.
- **Marco, 12.11.:** Den Schmied gegen Gruppen nicht bremsen, so lassen.

## Offen

- **Klingentänzerin:** Partnertanz und Klingenkäfig schaden der Gruppe (sie verbrauchen Klingen, die sonst Schaden
  machen), Klingensturm bringt nichts.
- **Sternensängerin:** Mondschild und Dissonanz bringen nichts; die Klasse hängt am Mondwiegenlied.
- **Bogenschütze:** Aufgeladener Schuss, Netzpfeil, Schwachstelle markieren bringen gegen Gruppen nichts.
- **Rüstungsschmied:** Amboss aufstellen bringt nichts Messbares.
- Schilde wuchsen bis 13.11. nicht mit der Stufe; seitdem wachsen sie mit (siehe „Geändert am 13.11.2026“).
- Seit der Boss-Messung (unten) ist klarer, was davon wirklich schwach ist: siehe „Was die Boss-Messung zeigt“.

## Boss-Messung je Fähigkeit (gebaut 12.11.2026)

Zeigt, was Fähigkeiten gegen **starke Einzelziele** wert sind. Dieselben Zeilen wie oben (nur Grundangriff, jede
Fähigkeit einzeln, alles, Gegenprobe), aber gegen sechs Gegner-Arten und in **zwei Spielweisen** nebeneinander:

- **wahllos:** Der Computer drückt zufällig (wie bisher).
- **klug** (`KampfKI.klug`, nur für Messungen): Schutz nur, wenn keiner wirkt; Bedrohung und Abfangen nur, wenn ein
  Verbündeter wenig Leben hat; Bogen spannen vor dem Schuss; Klingensturm erst mit fünf Klingen; Lieder, die Resonanz
  verbrauchen, erst ab drei; Schwächen auf den stärksten Gegner, der sie noch nicht hat.

Die sechs Messungen (Gruppe Stufe 20 mit zwei Novizen, je 100 Kämpfe; die Bosse bekommen mehr Leben, weil sie sonst fast
immer fallen und man keinen Unterschied sieht). `<K>` ist die Klasse; alle 30 Läufe dauern auf vier Kernen rund 20 Minuten:

```
<Godot> --headless --path . -s tests/klassen_messen.gd -- 100 20 20 kampf:kettenschmied <K> gruppe ohne leben=1.6 spielweise=beide
<Godot> --headless --path . -s tests/klassen_messen.gd -- 100 20 20 kampf:pilz_koenigin <K> gruppe ohne spielweise=beide
<Godot> --headless --path . -s tests/klassen_messen.gd -- 100 20 20 kampf:pilz_urbaum <K> gruppe ohne leben=1.6 spielweise=beide
<Godot> --headless --path . -s tests/klassen_messen.gd -- 100 20 20 kampf:hammerbrueder <K> gruppe ohne leben=2 spielweise=beide
<Godot> --headless --path . -s tests/klassen_messen.gd -- 100 20 55 obsidiangolem <K> gruppe ohne leben=3 spielweise=beide
<Godot> --headless --path . -s tests/klassen_messen.gd -- 100 20 24 steppenhyaene,dornling,schattenhexe,sturmkobold <K> gruppe ohne spielweise=beide
```

Der Golem fällt immer (dort zählen die Züge je Sieg), die gemischte Gruppe hat Nahkampf, Fernkampf und Magie.
Unterschiede unter etwa 12 Punkten sind bei 100 Kämpfen Zufall.

### Ergebnisse vom 12.11.2026 (Siege in %, wahllos / klug)

| Klasse | Zeile | Kettenschmied | Sporenkönigin | Wurzelmutter | Hammerbrüder | Golem (Züge) | Gemischt |
|---|---|---|---|---|---|---|---|
| Bogenschütze | nur Grundangriff | 58 / 60 | 68 / 68 | 47 / 47 | 61 / 61 | 121 | 57 / 57 |
| | alles auf Stufe 2 | 86 / 87 | 90 / 88 | 92 / 78 | 97 / 100 | 97 | 83 / 86 |
| Klingentänzerin | nur Grundangriff | 70 / 67 | 80 / 80 | 81 / 81 | 86 / 86 | 110 | 64 / 64 |
| | alles auf Stufe 2 | 64 / 52 | 87 / 86 | 91 / 93 | 97 / 93 | 115 | 83 / 88 |
| Sternensängerin | nur Grundangriff | 40 / 38 | 71 / 71 | 50 / 50 | 65 / 65 | 119 | 49 / 49 |
| | alles auf Stufe 2 | 96 / 100 | 80 / 86 | 50 / 63 | 100 / 100 | 130 / 114 | 84 / 95 |
| Rüstungsschmied | nur Grundangriff | 31 / 39 | 71 / 71 | 33 / 33 | 84 / 84 | 125 | 49 / 49 |
| | alles auf Stufe 2 | 27 / 40 | 38 / 41 | 18 / 31 | 100 / 100 | 142 / 139 | 98 / 95 |
| Monster-Zähmer | nur Grundangriff | 28 / 24 | 28 / 28 | 89 / 89 | 93 / 93 | 100 | 75 / 75 |
| | alles auf Stufe 2 | 42 / 55 | 31 / 35 | 60 / 64 | 95 / 89 | 132 / 128 | 49 / 52 |

Die einzelnen Fähigkeiten, die vorher „bringt nichts“ hießen (einzeln zum Grundangriff, wahllos / klug):

| Fähigkeit (Grundangriff) | Kettenschmied | Sporenkönigin | Wurzelmutter | Hammerbrüder | Urteil |
|---|---|---|---|---|---|
| Netzpfeil (58 / 68 / 47 / 61) | 87 / 88 | 73 / 76 | 72 / 78 | 80 / 78 | **gut gegen Bosse**, bleibt |
| Aufgeladener Schuss | 36 / 37 | 76 / 84 | 31 / 44 | 81 / 75 | mal besser, mal schlechter; offen |
| Schwachstelle markieren, vorher | 61 / 53 | 76 / 82 | 55 / 39 | 76 / 77 | brachte nichts |
| Schwachstelle markieren, **jetzt** | 83 / 83 | 79 / 75 | 67 / 40 | 87 / 89 | lohnt sich |
| Klingensturm (70 / 80 / 81 / 86) | 57 / 79 | 84 / 83 | 70 / 81 | 89 / 98 | klug gespielt gut, bleibt |
| Partnertanz, vorher | 24 / 26 | 68 / 71 | 33 / 33 | 33 / 41 | schadete stark |
| Partnertanz, **jetzt** | 67 / 61 | 78 / 78 | 53 / 53 | 65 / 82 | etwa gleichauf (Partner sind hier Novizen) |
| Klingenkäfig, vorher | 48 / 41 | 67 / 71 | 40 / 48 | 64 / 57 | schadete |
| Klingenkäfig, **jetzt** | 71 / 70 | 73 / 76 | 45 / 60 | 90 / 88 | gleichauf, gegen die Wurzelmutter schwach |
| Dissonanz (40 / 71 / 50 / 65) | 84 / 78 | 84 / 78 | 70 / 75 | 77 / 73 | **gut gegen Bosse**, bleibt |
| Mondschild | 41 / 53 | 71 / 70 | 55 / 50 | 75 / 73 | bringt nichts (Schild wächst nicht mit) |
| Polarstern | 34 / 41 | 74 / 74 | 41 / 51 | 64 / 68 | bringt nichts |
| Amboss aufstellen (31 / 71 / 33 / 84) | 33 / 29 | 74 / 70 | 21 / 32 | 91 / 89 | bringt nichts |
| Abfangen | 15 / 21 | 64 / 73 | 14 / 31 | 78 / 86 | wahllos schädlich, klug gleichauf |
| Rüstung verstärken | 44 / 60 | 69 / 70 | 12 / 27 | 94 / 100 | klug gegen zwei Bosse gut |
| Härten | 6 / 11 | 42 / 42 | 26 / 26 | 83 / 83 | gegen Bosse schädlich (Funken zu schwach für ein Ziel) |
| Pflege (28 / 28 / 89 / 93) | 8 / 24 | 22 / 28 | 77 / 89 | 92 / 93 | wahllos schädlich, klug gleichauf |
| Wechsel | 38 / 26 | 22 / 22 | 56 / 56 | 88 / 88 | kostet gegen Bosse Züge |

### Was die Boss-Messung zeigt

- **Netzpfeil und Dissonanz sind keine schwachen Fähigkeiten:** Gegen Bosse gehören sie zu den besten. Nicht ändern.
- **Klingensturm ist in Ordnung**, wenn man ihn mit vollen Klingen einsetzt.
- **Kluges Spielen hilft der Sängerin am meisten** (Kometenlied 59 → 78, voller Baum gemischt 84 → 95), dem Schmied bei
  Rüstung verstärken und Abfangen. Bei Bogenschütze und Zähmer macht es kaum einen Unterschied.
- **Der Rüstungsschmied ist gegen Bosse die schwächste Klasse:** voller Baum 27 bis 40 % gegen Kettenschmied,
  Sporenkönigin und Wurzelmutter, teils schlechter als nur mit dem Hammer (er macht mit Schutz-Knöpfen zu wenig Schaden,
  Schaden je 10 Züge 13 bis 24, die anderen 50 bis 100). Gegen Gruppen bleibt er der Stärkste.
- **Der Monster-Zähmer ist seit der Abschwächung gegen Bosse schwach** (Kettenschmied und Sporenkönigin um 30 %), und
  sein voller Baum ist gegen Wurzelmutter und gemischte Gruppe schlechter als nur der Grundangriff (89 → 60, 75 → 49).
- **Die Klingentänzerin verliert mit vollem Baum gegen den Kettenschmied** (70 → 64 / 52), ohne Partnertanz 71 bis 82.
- **Die Sängerin** hängt weiter am Mondwiegenlied; gegen die Wurzelmutter singt sie zu viel und trifft zu wenig (50 / 63).

### Geändert am 12.11.2026 nach der Boss-Messung

- **Schwachstelle markieren:** 10 statt 4 Schaden, 4 statt 3 Runden. Gegen Gruppen (Standard-Messung) 33 → 42 %.
- **Partnertanz:** Der Partner ist sofort dran und 3 statt 2 Runden stärker, kostet 4 statt 8 Mana. Gruppen 40 → 53 %.
- **Klingenkäfig:** schneidet 3 statt 2 Runden mit 14 statt 8 (`Skills.KAEFIG_SCHNITT`). Gruppen 39 → 59 %.

### Geändert am 13.11.2026 (Marcos Entscheidungen zur Liste)

- **Rüstungsschmied:** Nach dem Härten trifft der nächste Hammerschlag doppelt (`Skills.HAERTEN_SCHLAG`), beim Amboss
  aufstellen schlägt er einmal zu. Er bleibt Tank und hängt gegen Bosse an den Mitstreitern (Marco).
- **Monster-Zähmer:** Monster wachsen zu drei Zehnteln mit (`Sandbox.zaehmer_monster_wachstum = 0.3`). Die eigenen
  Monster-Stufen kommen später.
- **Schilde wachsen mit** Stufe, Ausrüstung und Fähigkeitsstufe wie Heilung (`BattleState.give_shield`), in den
  Beschreibungen farbig. Betrifft Rüstung verstärken, Gemeinsame Härte, Meisterstück, Mondschild und die Schilde der
  anderen Klassen (nicht den Novizen).
- **Aufgeladener Schuss:** 300 % vom Schnellen Schuss statt 250 % (`Skills.LADESCHUSS_MAL`), ein Treffer unterbricht
  weiterhin. Marco: Werte künftig als Anteil vom Angriff angeben statt als feste Zahl.

Nachgemessen (Siege in %, wahllos / klug; in Klammern vorher):

| Zeile | Kettenschmied | Sporenkönigin | Wurzelmutter | Hammerbrüder | Gemischt | Standard-Gruppe |
|---|---|---|---|---|---|---|
| Schmied, alles | 61 / 64 (27 / 40) | 40 / 51 (38 / 41) | 21 / 47 (18 / 31) | 100 / 100 | 100 / 97 | 100 |
| Schmied, Rüstung verstärken | 83 / 91 (44 / 60) | 70 / 66 | 19 / 44 (12 / 27) | 100 / 100 | 77 / 86 (46 / 59) | |
| Schmied, Härten | 22 / 24 (6 / 11) | 46 / 46 | 38 / 38 (26 / 26) | 99 / 99 | 67 / 67 (40 / 40) | 85 (66) |
| Schmied, Amboss aufstellen | 44 / 39 (33 / 29) | 75 / 68 | 32 / 35 (21 / 32) | 100 / 97 | 64 / 58 | 87 (59) |
| Zähmer, nur Grundangriff | 49 / 49 (28 / 24) | 34 / 34 (28 / 28) | 93 / 93 | 99 / 99 | 79 / 79 | 91 (84) |
| Zähmer, alles | 62 / 73 (42 / 55) | 33 / 37 (31 / 35) | 67 / 65 (60 / 64) | 99 / 96 | 55 / 68 (49 / 52) | 97 (90) |
| Sängerin, Mondschild | 64 / 53 (41 / 53) | 73 / 70 | 60 / 51 | 95 / 81 (75 / 73) | 73 / 68 (57 / 63) | 33 (24) |
| Bogenschütze, Aufgeladener Schuss | 47 / 31 (36 / 37) | 76 / 79 | 32 / 45 | 83 / 87 | 44 / 45 | 41 (35) |

### Offen (Stand 13.11.2026)

1. **Aufgeladener Schuss** lohnt sich gegen Sporenkönigin und Hammerbrüder (Schaden je 10 Züge 76 bis 96 statt 61 bis
   72), gegen Kettenschmied und Wurzelmutter nicht: Dort wird der Bogenschütze zu oft getroffen und verliert das Spannen.
2. **Sporenkönigin** bleibt für Schmied (40 / 51) und Zähmer (33 / 37) schwer, die **Wurzelmutter** für den Schmied.
3. **Zähmer gegen Gruppen** ist mit 0,3 wieder vorn (97 %), aber weit weg von früher (Gegner Stufe 40 nötig).
4. **Polarstern** bringt weiter nichts Messbares (Abwehr+ ist schon ein Anteil, daran liegt es nicht).
5. **Partnertanz** mit einem echten Schadens-Partner messen (bisher nur mit Novizen).

### Werte als Anteil vom Angriff (13.11.2026, Marco)

Alle Schadens-, Heil- und Schildwerte der fünf Demo-Klassen sind jetzt ein **Prozentsatz vom normalen Angriff** der Klasse
(`Skills.GRUNDANGRIFF`: Hammerschlag 15, Schneller Schuss 12, Klingenschritt 9, Sternenfunke 14, Schleuder 8), im Code
`an(f, 200)` für Schaden und `wert(f, 160)` für Heilung, Schilde und Beschreibungen. Beispiele: Durchschlag 200 %,
Pfeilhagel 75 %, Jägerpfeil 583 %, Ambossschlag 80 %, Fächerschnitt 200 %, Rüstung verstärken Schild 160 %.
Wer den normalen Angriff einer Klasse ändert, ändert damit alle ihre Fähigkeiten im selben Verhältnis.

Die Stärke ist gleich geblieben (gegengemessen, Standard-Gruppe, 200 Kämpfe: Bogenschütze 31 / 83, Klingentänzerin
54 / 87, Sängerin 32 / 92, Schmied 71 / 100, wie vorher). In den Beschreibungen steht weiter der fertige, farbige Wert;
mit Einzelheiten (Taste D) steht dahinter z. B. „24 = 200 % vom Angriff · Stufe 20 +… %“. Die Monster des Zähmers
behalten ihre eigenen Angriffswerte.
