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

## Spielprinzip

Vier Helden gegen Grubenkobold, Schleimling und den Boss Steinwächter.
Kampfbildschirm seitlich wie Final Fantasy 6: Gegner links, Helden rechts (vorne/hinten).

- **Zugleiste oben:** Wer schneller ist (Tempo), ist öfter dran. Die Leiste zeigt die nächsten 9 Züge.
- **Zwei Reihen:** Hinten bekommt und macht man nur 60 % Nahkampf-Schaden.
  Fernkampf und Magie ignorieren die Reihe. „Nach vorne“/„Nach hinten“ kostet den Zug.
- **Perfekte Reaktion:** Greift ein Gegner an, schließt sich ein goldener Ring.
  Genau dann tippen (oder Leertaste), wenn er den weißen Kreis erreicht
  (oben zeigt zusätzlich eine Zeitleiste den Moment: Der Strich muss im grünen Feld sein):
  Magier-Tank pariert (+15 Mana), Bogenschütze und Sternensängerin weichen aus.
  Der Ritualist hat keine Reaktion.
- **Ult-Leiste:** lädt nur durch die klassentypische Aktion.

| Held | Klasse | Besonderheit | Ult lädt durch … |
|------|--------|--------------|------------------|
| Arkon | Magier-Tank (vorne) | Umwandlung: halber Schaden geht auf Mana | Schaden, den er mit Mana auffängt |
| Wren | Bogenschütze (hinten) | Bogen spannen → nächster Schuss ×2,5; Treffer unterbricht. Hinten öfter kritisch | Aufgeladene Schüsse, kritische Treffer |
| Vesna | Ritualist (hinten) | Heilen kostet Blutvorrat, dann Leben. Biss füllt den Vorrat | Für andere geopfertes Leben |
| Lyra | Sternensängerin (hinten) | Zwei Sternbilder (orange = Angriff, blau = Schutz), Verblassen, Sternenglanz | Durch Lieder verbrauchte Resonanz |

**Boss Steinwächter:** Steinfaust → kündigt **Felsregen auf die hintere Reihe** an →
Felsregen → **Kettenzug** (reißt jemanden von hinten nach vorne). Unter 30 % LP wird er wütend.

## Werte anpassen

Die meisten Zahlen stehen oben in `scripts/kampf/combat.gd` (Konstanten),
die Werte der Teilnehmer in `_create_fighters()`, die Fähigkeiten in `_abilities()`.

## Aufbau

- `scenes/kampf.tscn` – Kampf-Prototyp (Startszene)
- `scripts/kampf/combat.gd` – Kampfablauf, Fähigkeiten, Gegner, Oberfläche
- `scripts/kampf/fighter.gd` – ein Kampfteilnehmer mit allen Werten
- `scripts/kampf/fighter_view.gd` – Pixel-Figur eines Teilnehmers mit Animationen und Namensschild
- `scripts/kampf/backdrop.gd` – Hintergrund (Gewölbe, Fackeln, Licht, Staub)
- `scripts/kampf/fx.gd` – Leuchteffekte (Glühen, Hieb, Funken, Ring)
- `shaders/` – Treffer-Blitz, leuchtender Umriss, Randabdunklung
- `assets/` – Pixel-Art (Quellen und Lizenzen in `CREDITS.md`)
- `export_presets.cfg` + `.github/workflows/web-export.yml` – Web-Export und Veröffentlichung
- `scenes/main.tscn` + `scripts/battle.gd` – der erste Mini-Kampf (Holy Trinity, Bedrohung)
