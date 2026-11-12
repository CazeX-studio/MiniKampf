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

Ausgabe je Zeile: Siege in %, Leben der Gruppe am Ende (nur Siege), Züge je Sieg.

Aufruf (Godot auf dem PC: `C:/GameDev/Godot/Godot_v4.7.2-stable_win64_console.exe`, in der Cloud: `~/godot/godot`):

```
<Godot> --headless --path . -s tests/klassen_messen.gd -- [anzahl] [stufe] [monster_stufe] [monster,…] [klasse] [allein] [ohne] [rudel] [wachstum]
```

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
- **Schilde wachsen nicht mit der Stufe** (ein Schild von 24 bleibt 24, Gegner auf Stufe 20 treffen etwa doppelt so
  hart). Das trifft Mondschild, Rüstung verstärken, Gemeinsame Härte und Meisterstück. In `design.md` steht seit
  11.11. ausdrücklich, dass Schilde feste Werte sind: Marco entscheidet, ob das so bleibt.
- Vor Änderungen an den drei offenen Klassen erst die Boss-Messung unten bauen: Die meisten schwachen Fähigkeiten zielen
  auf einen einzelnen Gegner.

## Idee: Boss-Messung je Fähigkeit (noch nicht gebaut)

Ziel: zeigen, was Fähigkeiten gegen **ein starkes Einzelziel** wert sind (Aufgeladener Schuss, Netzpfeil, Schwachstelle
markieren, Klingenkäfig, Klingensturm, Dissonanz, Polarstern, Abfangen, Amboss aufstellen).

So könnte sie aussehen:

1. `tests/klassen_messen.gd` bekommt eine zweite Art von Gegner: statt freier Monster ein **Kampf aus dem Spiel**
   (wie `tests/boss_messen.gd`: `a.art = "spiel"`, `a.kampf = "<kennung>"`). Vorschlag für den Aufruf: als viertes Wort
   `kampf:kettenschmied` statt der Monster-Liste.
2. Dieselben Zeilen wie bisher: nur Grundangriff, jede Fähigkeit einzeln, alles, Gegenprobe.
3. Drei Gegner-Arten, damit nichts einseitig ist:
   - **ein Boss mit Mechanik** (Kettenschmied, Sporenkönigin, Wurzelmutter, Hammerbrüder; die Mechaniken spielt der
     Computer schon richtig),
   - **ein dicker Einzelgegner ohne Mechanik** (z. B. `obsidiangolem` allein; dafür `gegner_leben` hochsetzen statt nur
     die Stufe, auf Stufe 44 war er noch zu leicht),
   - **gemischte Gruppe** mit Nahkampf, Fernkampf und Magie (damit der Schmied nicht mit einer Rüstung alles abdeckt).
4. Zusätzlich zur Siegquote **Schaden je Zug** ausgeben. Bei Bossen liegen die Siegquoten oft nahe 100 %, dann zeigt nur
   die Zahl der Züge je Sieg den Unterschied.
5. Damit Schutz-Fähigkeiten fair gemessen werden, einen **klügeren Computer** als zweite Spielweise: Schutz nur drücken,
   wenn gerade keiner wirkt, Bedrohung nur, wenn ein Verbündeter wenig Leben hat, Aufladen immer vor dem Schuss. Beide
   Spielweisen nebeneinander ausgeben („wahllos“ und „klug“).
6. Ergebnis wie oben als Tabelle hier eintragen, dann entscheidet Marco je Fähigkeit.
