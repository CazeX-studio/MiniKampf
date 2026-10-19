# Mini-Kampf

Lernprojekt von CazeX Studio: ein rundenbasierter **Kampf-Prototyp** nach dem
Kampfsystem aus `design.md` (Abschnitt 4 und 5), erster Schritt Richtung 2D-Story-MMO.

## Im Handy-Browser spielen

**https://cazex-studio.github.io/MiniKampf/**

Handy quer halten. Jeder Push auf `main` baut die Web-Version automatisch neu
(GitHub → Reiter **Actions** → „Web-Export“; nach ca. 2–3 Minuten ist sie online).

## Am PC starten

1. Godot 4.7 öffnen (`C:\GameDev\Godot\Godot_v4.7.2-stable_win64.exe`)
2. **Importieren** → `C:\GameDev\MiniKampf\project.godot` wählen
3. **F5** startet das Spiel

Das Spiel startet mit einem **Menü**: Kampf-Sandbox oder Kreuzweg-Demo.

## Kreuzweg-Demo (Lernprojekt 3, Gerüst)

Die Stadt Kreuzweg schräg von oben (Platzhalter-Grafik): Marktplatz mit der Statue der Fünf,
Abenteurergilde, Bingos Laden, sechs Straßen (die sechste nach Südosten ist zugewachsen).

- **Laufen:** Boden antippen oder anklicken.
- **Reden:** Ausbilder Ye antippen – man läuft hin, dann startet das Gespräch („Weiter“ blättert).
- **Testgefährte:** Ein zweiter Spieler läuft zur Probe herum.

**Für später mehrere Spieler gebaut:** Die Spiellogik (`scripts/welt/world_state.gd`) kennt keine Grafik.
Jeder Spieler schickt nur Befehle wie „laufe zu Feld X“ oder „rede mit Ye“. Die Anzeige
(`scripts/welt/kreuzweg.gd`) zeichnet nur, was in der Logik steht. Der Testgefährte wird schon über
dieselben Befehle gesteuert wie ein echter Mitspieler. Später kann ein Server die Logik übernehmen.

## Kampf-Sandbox (Lernprojekt 2)

Alle 11 Startklassen aus `design.md` zum Ausprobieren und Vergleichen.

1. **Auswahl-Bildschirm:** bis zu 4 Klassen antippen (oder „Zufallsteam“),
   Gegner wählen (Monstergruppe, Boss oder beides nacheinander),
   beim Monster-Zähmer das Start-Monster wählen. Dann „Kampf starten!“.
2. **Kampf:** Fähigkeit antippen, dann das Ziel. Bei Gegner-Angriffen tippen, wenn sich der Ring schließt.
3. **Auswertung am Ende:** Schaden, Heilung, abgewehrter und erlittener Schaden, perfekte Reaktionen
   und Ults pro Klasse. „Nochmal“ spielt mit demselben Team, „Team ändern“ geht zurück zur Auswahl.
   Oben rechts im Kampf führt „Auswahl“ jederzeit zurück.

### Grundregeln

- **Zugleiste oben:** Wer schneller ist (Tempo), ist öfter dran.
- **Zwei Reihen:** Hinten bekommt und macht man nur 60 % Nahkampf-Schaden. Reihe wechseln kostet den Zug.
- **Perfekte Reaktion:** Parieren / Ausweichen wehrt den Treffer ab und löst die Klassen-Reaktion aus.
- **Element-Sechseck:** stark = 1,5× Schaden, schwach = 0,5×. Die Farbe am Gegner-Namen zeigt sein Element.
  Licht und Schatten sind gegenseitig stark. Sternenkraft (Ult der Sternensängerin) ignoriert Resistenzen.
- **Duette:** Stehen beide Partner im Team, hat jeder einen rosa „DUETT“-Knopf.

| Klasse | Besondere Mechanik im Prototyp |
|--------|--------------------------------|
| Magier-Tank | Halber Schaden geht auf Mana. Ult Arkane Festung |
| Mechaniker | Roboter Zahnrad mit eigenem Zug (Bohrer, Schutzmodus), beschützt einen Verbündeten, explodiert beim Tod |
| Rüstungsschmied | Drei Rüstungen (Nahkampf/Magie/Fernkampf), passende Treffer geben „Gehärtet“ (bis 5) |
| Bogenschütze | Bogen spannen → ×2,5, hinten öfter kritisch, Schnellfeuer (3 Pfeile auf zufällige Gegner) |
| Klingentänzerin | Bis 5 Klingen, Schritt + Wirbel + Ausfall = Tanzfolge |
| Zwielicht-Wandler | Leiste Licht/Schatten, am Rand überladen (×1,6, Rückstoß), Mitte überqueren lädt die Ult |
| Monster-Zähmer | Moosling, Glutwelpe, Bachotter; eines kämpft mit eigenem Zug, Wechsel per Fähigkeit. Zähmen: geschwächte Monster (unter 50 % LP, auch aus der Pilzhöhle) fangen, bis 5 Monster |
| Ritualist | Heilen kostet Blut, dann Leben |
| Quartiermeister | Gold und Karren mit Waren (Heiltrank, Manatrank, Bombe, Kraftkraut) |
| Kunoichi | Element-Siegel kleben und lösen, zwei Siegel = Kombination |
| Sternensängerin (Vega) | Zwei Sternbilder, Verblassen, Sternenglanz, Polarstern (Abwehr+ und früher dran) |

Duette: Treibjagd (Bogenschütze + Zähmer), Blutsiegel (Kunoichi + Ritualist), Nachschub (Mechaniker +
Quartiermeister), Glühende Klingen (Rüstungsschmied + Klingentänzerin), Zwielicht-Barriere
(Magier-Tank + Zwielicht-Wandler), Sternentanz (Sternensängerin + Klingentänzerin).

### Test-Dungeon Pilzhöhle

Auf dem Auswahl-Bildschirm unter „Gegner“: **Pilzhöhle** (ganzer Dungeon, 4 Wellen) oder
**Pilzhöhle: nur Bosse** (zum schnellen Testen). Die Regeln stehen im Kampf-Log.
Nach dem Sieg über den Vorboten entscheidet die Gruppe: Baum fällen und den großen Splitter mitnehmen
oder den Splitter herausschneiden und den Baum retten.

- **Eigene Monster:** Leuchtmotte (Licht, blendet), Wurzelkriecher (Erde, hält fest),
  Sporenwolf (Pflanze, stärker im Rudel), Glimmerkäfer (Blitz, lädt sich auf und entlädt sich auf alle).
- **Zwischenboss Sporenkönigin:** Sporenknospen heilen sie. Pro Kampf zufällig eine Mechanik:
  *Sporenblüte* (Feuer erzeugt Giftwolken, bei 5 Wolken stirbt die Gruppe; Wind und „Giftwolke vertreiben“
  helfen) oder *Sporen-Zwillinge* (beide Sporenknospen vor dem nächsten Zug des Überlebenden besiegen).
- **Endboss Phase 1 – Wurzelmutter:** Treffer auf die Rinde heilen sie. Knoten vorne und hinten
  vor ihrem nächsten Zug zerstören (sonst wachsen sie nach); jedes Knotenpaar kostet sie ein Viertel ihres Lebens.
  *Verschlingen*: Kommt in 3 ihrer Züge kein Knotenpaar kaputt, stirbt die Gruppe. Wurzelzug zieht nach vorne.
- **Endboss Phase 2 – Vorbote:** Das Feld wird dunkler, die Zugleiste verschwindet. Bei völliger Dunkelheit
  (*Lichtfraß*) stirbt die Gruppe. Jeder kann „Laterne entzünden“, Licht-Treffer helfen zusätzlich.
  *Das letzte Licht*: Wer das Splitterlicht hält, wird vom Vorboten nicht angegriffen, brennt aber
  immer stärker. „Licht weiterreichen“ gibt es an einen anderen Helden.

**Boss Steinwächter (Erde):** Steinfaust → kündigt **Felsregen auf die hintere Reihe** an (Magie) →
Felsregen → **Kettenzug** (reißt jemanden von hinten nach vorne). Unter 30 % LP wird er wütend.

## Werte anpassen

- Leben, Mana, Tempo der Klassen, Gegner und Kämpfe: `scripts/kampf/sandbox.gd`
- Fähigkeiten, Passiven, Reaktionen und Duette: `scripts/kampf/skills.gd`
- Allgemeine Regeln (Reihen, Krit, Stärkungen, Boss): Konstanten oben in `scripts/kampf/battle_state.gd`
- Element-Tabelle: `scripts/kampf/elements.gd`

## Aufbau

- `scenes/menu.tscn` + `scripts/menu.gd` – Startmenü (Startszene)
- `scenes/kreuzweg.tscn` + `scripts/welt/` – Kreuzweg-Demo: `world_state.gd` (Logik), `player_state.gd`,
  `dialogs.gd` (Gesprächstexte), `kreuzweg.gd` (Anzeige und Eingabe), `world_character.gd` (Figur)
- `scenes/auswahl.tscn` + `scripts/kampf/auswahl.gd` – Auswahl-Bildschirm der Kampf-Sandbox
- `scripts/kampf/pilzhoehle.gd` – Test-Dungeon Pilzhöhle (Abläufe und Mechaniken)
- `scripts/kampf/battle_state.gd` – Kampf-Regeln ohne Grafik: Zugreihenfolge, Schaden, Gegner, Wellen. Nimmt Befehle an und meldet Ereignisse
- `scenes/kampf.tscn` + `scripts/kampf/combat.gd` – Kampf-Anzeige: spielt die Ereignisse ab, Knöpfe, Reaktions-Ring, Auswertung
- `tests/` – automatische Testkämpfe (`vergleich.gd`), Element-Test, `anzeige_auto.tscn` (Computer spielt mit echter Anzeige)
- `scripts/kampf/skills.gd` – Fähigkeiten aller Klassen, Begleiter und Duette
- `scripts/kampf/sandbox.gd` – Daten: Klassen, Duette, Monster, Gegner, Kämpfe
- `scripts/kampf/elements.gd` – Element-Sechseck, Licht/Schatten, Sternenkraft
- `scripts/kampf/fighter.gd` – ein Kampfteilnehmer mit allen Werten
- `scripts/kampf/fighter_view.gd` – Pixel-Figur eines Teilnehmers mit Animationen und Namensschild
- `scripts/kampf/backdrop.gd` – Hintergrund (Gewölbe, Fackeln, Licht, Staub)
- `scripts/kampf/fx.gd` – Leuchteffekte (Glühen, Hieb, Funken, Ring)
- `shaders/` – Treffer-Blitz, leuchtender Umriss, Randabdunklung
- `assets/` – Pixel-Art (Quellen und Lizenzen in `CREDITS.md`)
- `export_presets.cfg` + `.github/workflows/web-export.yml` – Web-Export und Veröffentlichung
- `scenes/main.tscn` + `scripts/battle.gd` – der erste Mini-Kampf (Holy Trinity, Bedrohung)
