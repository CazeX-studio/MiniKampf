# Prüfung des Projekts (Stand 2026-10-19)

Geprüft: Code im Repo MiniKampf gegen `design.md` aus CazeX-studio/Spieldesign, Code-Aufbau,
Probelauf ohne Fenster, Web-Export.

## 1. Vergleich mit design.md

### Kampfsystem – passt

| Thema | design.md | Gebaut |
|---|---|---|
| Zugreihenfolge nach Tempo mit Leiste | ja | ja (8 Züge voraus) |
| Parieren / Ausweichen per Timing | ja | ja (Ring + Zeitleiste), Klassen ohne Reaktion haben keine |
| Zwei Reihen, hinten weniger Nahkampf, Wechsel kostet den Zug | ja | ja (60 %) |
| Ult-Leiste nur durch klassentypische Aktion, keine Aufladung über Zeit | ja | ja, bei allen 11 Klassen |
| Mana und Abklingzeiten | ja | ja |
| Bis 4 Spieler + Begleiter | ja | ja (Roboter, Monster) |
| Boss mit Ankündigung und Wutphase | ja | ja (Steinwächter) |

**Abweichungen:**
- **Zeitlimit pro Zug in der Gruppe** (20–30 s) fehlt. Ist erst mit mehreren Spielern nötig.
- **Bedrohung (Aggro):** In der Sandbox gibt es nur „Bedrohung erzwingen“ (Bann-Zeichen, Amboss usw.), keinen Bedrohungswert wie im ersten Mini-Kampf.

### Klassen – fast vollständig

Alle 11 Klassen sind spielbar, mit Mechanik, Reaktion, Ult und Ult-Aufladung wie in der Tabelle von design.md.
Alle sechs Duette sind drin, auch der Sternentanz mit Sternenkraft.

**Abweichungen (Fähigkeiten fehlen oder sind vereinfacht):**
- **Bogenschütze:** „Schnellfeuer“ fehlt.
- **Sternensängerin:** „Polarstern“ fehlt.
- **Monster-Zähmer:** „Zähmen“ fehlt, und große Monster, die mehrere Plätze brauchen, gibt es noch nicht. Er hat immer die drei Start-Monster.
- **Magier-Tank:** Die „Barriere (evtl. mit Nachteil)“ hat keinen Nachteil.
- **Kunoichi:** Die Ult lädt auch durch einzelne Siegel (+12), nicht nur durch Kombinationen (+35). design.md sagt „ausgelöste Siegel-Kombinationen“.
- **Passiven:** Wo design.md keine Passive nennt (Mechaniker, Rüstungsschmied, Zwielicht-Wandler), habe ich selbst eine gewählt, z. B. „Wartung“ beim Roboter. Die stehen nicht in design.md.
- **Spezialisierungen und Der Klassenlose:** noch nicht gebaut (war auch nicht geplant).
- **Name:** Die Sternensängerin hieß in der Sandbox „Lyra“. Erledigt: Sie heißt jetzt „Vega“ (Lyra ist Kaels Schwester).

### Elemente – passt

Sechseck mit 1,5- und 0,5-fachem Schaden, Licht und Schatten gegenseitig stark, Sternenkraft ohne Stärken
und Schwächen und ohne Resistenzen. Monster haben genau ein Element, Helden keins. Die fünf Siegel der Kunoichi stimmen.
**Abweichung:** Resistenzen über Rüstung und Karten gibt es noch nicht (es gibt noch keine Ausrüstung).

### Dungeon-Regeln und Pilzhöhle – passt, mit Lücken

Zwischenboss mit zwei Mechaniken (zufällig eine), Endboss mit zwei Phasen, je eine Wipe- und eine
Zusammenspiel-Mechanik, eigene Monster, nichts davon braucht eine bestimmte Klasse. Die Helfer der Königin
heißen wie in design.md „Sporenknospen“.

**Abweichungen:**
- Die **Entscheidung nach dem Dungeon** (Baum fällen oder Splitter herausschneiden) fehlt.
- Dungeon-Monster sind noch **nicht zähmbar** und lassen **keine Monsterkarten** fallen.
- Einige Regeln habe ich selbst festgelegt (z. B. „Giftwolke vertreiben“, wie stark das Splitterlicht brennt). Sie stehen als Fragen in FORTSCHRITT.md.

### Kreuzweg-Demo – passt zum geplanten Gerüst

Stadt schräg von oben, Statue der Fünf, sechs Straßen (die sechste zugewachsen), Ausbilder Ye mit
„Schild hoch, Schild runter“ und der Laterne an der Wand. Marv, Bingo, Aufträge usw. fehlen noch
(gehören zu den nächsten Schritten von Lernprojekt 3).

## 2. Code-Aufbau: Ist die Spiellogik von der Anzeige getrennt?

- **Kreuzweg-Demo: ja.** `world_state.gd` enthält nur Regeln und Daten (Karte, Spieler, Wege, Gespräche)
  und nimmt Befehle wie „laufe zu Feld X“ an. `kreuzweg.gd` zeichnet nur. Der Testgefährte wird schon über
  dieselben Befehle gesteuert. Gute Grundlage für mehrere Spieler.
  Kleinigkeit für später: Die Welt wird noch von der Anzeige „angetrieben“ (`state.tick()` im Anzeige-Skript),
  und der Testgefährte steckt im Anzeige-Skript. Mit einem Server wandern beide dorthin.
- **Kampf: nein, noch nicht.** Die Werte der Teilnehmer (`fighter.gd`) und die Daten (`sandbox.gd`, `elements.gd`)
  sind sauber getrennt, aber Regeln und Anzeige sind in `combat.gd`, `skills.gd` und `pilzhoehle.gd` vermischt:
  Die Regeln warten auf Animationen und rufen direkt Schwebetexte und Effekte auf. Für gemeinsame Kämpfe
  (Lernprojekt 4) muss das getrennt werden: ein Kampf-Zustand, der Befehle annimmt und Ereignisse
  („Treffer 12 auf Arkon“) meldet, und eine Anzeige, die diese Ereignisse abspielt.
- Der erste Mini-Kampf (`scenes/main.tscn`, `battle.gd`, `combatant.gd`) liegt noch im Projekt,
  ist aber über das Menü nicht mehr erreichbar.

## 3. Probelauf ohne Fenster

- **Alle Skripte:** keine Fehler beim Laden.
- **Alle Szenen** (Menü, Auswahl, Kampf, Kreuzweg, alter Mini-Kampf) starten ohne Fehlermeldung.
- **36 automatisch gespielte Kämpfe** (Monster, Boss, Pilzhöhle, viele Teams): keine Fehler.
- **Gefunden und repariert:** ein **Speicherleck**. Mechaniker und Roboter sowie Zähmer und Monster haben
  sich gegenseitig festgehalten und blieben nach jedem Kampf im Speicher. Beim Verlassen des Kampfes werden
  diese Verweise jetzt gelöst. Danach meldet Godot keine liegengebliebenen Objekte mehr.
- **Warnungen:** Godot zeigt Warnungen (z. B. unbenutzte Variablen) nur im Editor an, nicht ohne Fenster.
  Das konnte ich nicht prüfen. Tipp: In Godot unten im Skript-Editor auf das gelbe Warn-Symbol achten.

## 4. Web-Export

Aktuell. Der letzte Stand wurde gebaut und auf GitHub Pages veröffentlicht (Actions „Web-Export“ erfolgreich,
die Veröffentlichung gehört zum neuesten Commit). Die Seite selbst kann ich von hier aus nicht öffnen
(Netzwerk gesperrt), deshalb bitte einmal im Browser prüfen.

## Zusammenfassung in einfachen Worten

**Was gut ist**
- Alle 11 Klassen, das Element-System, die Duette und die Pilzhöhle sind spielbar und folgen design.md sehr genau.
- Es gibt keine Abstürze oder Fehlermeldungen, auch nicht nach vielen automatisch gespielten Kämpfen.
- Die Kreuzweg-Demo ist von Anfang an so gebaut, dass später mehrere Spieler dazukommen können.
- Jede Änderung landet automatisch im Browser.

**Was verbessert werden sollte**
1. **Kampf in Regeln und Anzeige trennen.** Ohne das geht gemeinsames Kämpfen (Lernprojekt 4) nicht.
   Am besten bevor der Kampf noch größer wird.
2. **Fehlende Kleinigkeiten aus design.md** nachziehen: Schnellfeuer, Polarstern, Zähmen,
   Entscheidung nach der Pilzhöhle, Kunoichi-Ult nur durch Kombinationen.
3. **Offene Fragen** aus FORTSCHRITT.md beantworten (Pilzhöhle-Regeln), dann die Werte nachjustieren.
4. Den alten ersten Mini-Kampf ins Menü aufnehmen oder als „Archiv“ kennzeichnen.

**Was zuerst?**
Zuerst testest du selbst (Sandbox und Pilzhöhle) und beantwortest die offenen Fragen. Danach empfehle ich,
den Kampf in Regeln und Anzeige zu trennen, solange er noch überschaubar ist. Danach geht es mit
der Kreuzweg-Demo weiter (Marv, Bingo, Aufträge, Probestunden).
