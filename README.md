# Mini-Kampf

Lernprojekt von CazeX Studio: ein kleiner rundenbasierter Kampf mit dem
**Holy-Trinity-System** – erster Schritt Richtung 2D-Story-MMO.

## Starten

1. Godot 4.7 öffnen (`C:\GameDev\Godot\Godot_v4.7.2-stable_win64.exe`)
2. **Importieren** → `C:\GameDev\MiniKampf\project.godot` wählen
3. **F5** startet das Spiel

## Spielprinzip

Drei Helden kämpfen gegen einen Höhlentroll. Jede Runde wählt jeder lebende
Held eine Fähigkeit, danach schlägt der Troll zu.

| Held | Rolle | Fähigkeiten |
|------|-------|-------------|
| Brom | Tank | Hieb (doppelte Bedrohung), Spott, Schildblock |
| Lira | Heiler | Heilen, Gruppenheilung, Heiliges Licht |
| Kael | Schaden | Feuerball, Verblassen (Bedrohung halbieren) |

- **Bedrohung (Aggro):** Der Troll greift immer den Helden mit der höchsten
  Bedrohung an. Schaden und Heilung erzeugen Bedrohung – der Tank muss sie halten.
- **Erdstampfer:** Jede 4. Runde trifft der Troll alle Helden (eine Runde vorher gewarnt).
- **Wut:** Unter 25 % LP macht der Troll 30 % mehr Schaden.

## Werte anpassen

Alle Zahlen für den Boss stehen oben in `scripts/battle.gd` (Konstanten),
die LP der Helden in `_start_battle()`.

## Aufbau

- `scenes/main.tscn` – Hauptszene (nur ein Knoten, die Oberfläche baut das Skript)
- `scripts/battle.gd` – Kampfablauf, Fähigkeiten und Oberfläche
- `scripts/combatant.gd` – ein Kampfteilnehmer (LP, Bedrohung, Rolle)
