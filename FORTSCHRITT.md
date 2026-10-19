# Fortschritt

Hier steht, was fertig ist, was als Nächstes kommt und welche Fragen offen sind.
Wird nach jedem Arbeitsschritt aktualisiert.

## Aufgaben dieser Runde (Runde 2)

| Nr. | Aufgabe | Stand |
|-----|---------|-------|
| 1 | Sternensängerin heißt jetzt „Vega“ | erledigt |
| 2 | Schnellfeuer, Polarstern, Zähmen, Entscheidung nach der Pilzhöhle | erledigt |
| 3 | Kunoichi-Ult lädt nur durch Siegel-Kombinationen | erledigt |
| 4 | Elemente absichern (unbekanntes Element = normaler Schaden) | erledigt |
| 5 | Selbst gewählte Werte als „vorläufig“ markieren | erledigt |
| 6 | Kampf in Regeln und Anzeige trennen | offen |

## Aufgaben der Runde 1

| Nr. | Aufgabe | Stand |
|-----|---------|-------|
| 1 | Kampf-Sandbox prüfen und fertigstellen | erledigt |
| 2 | Pilzhöhle als spielbarer Test-Dungeon | erledigt |
| 3 | Gerüst für die Kreuzweg-Demo (Lernprojekt 3) | erledigt |
| 4 | Web-Export aktualisieren | erledigt |

## Fertig in Runde 2

- **Schritt 1 – Name:** Die Sternensängerin heißt jetzt überall **Vega** (Lyra ist Kaels Schwester).

- **Schritt 2 – Fehlende Fähigkeiten und Entscheidung:**
  - **Schnellfeuer** (Bogenschütze): 3 schnelle Pfeile à 7 auf zufällige Gegner, 12 Mana. Kritische Treffer laden wie immer die Ult.
  - **Polarstern** (Sternensängerin): Ein Verbündeter bekommt Abwehr+ und ist früher dran, +1 Schutz-Sternbild, 10 Mana.
    Mit vollem Schutz-Sternbild (Sternenglanz) wirkt er auf die ganze Gruppe.
  - **Zähmen** (Monster-Zähmer): Ein Monster unter 50 % Leben kann gefangen werden. Je schwächer, desto sicherer
    (bei 50 % halbe Chance). Es kommt mit halbem Leben auf die Bank und kann per „Wechsel“ kämpfen, mit seinem
    eigenen Angriff und „Beschützen“. Zähmbar sind alle normalen Monster, auch die der Pilzhöhle (nicht Bosse,
    Sporenknospen und Knoten). Höchstens 5 Monster.
  - **Entscheidung nach der Pilzhöhle:** Nach dem Sieg über den Vorboten zwei Knöpfe: „Baum fällen, großen Splitter
    mitnehmen“ oder „Splitter herausschneiden, Baum retten“. Das Ergebnis steht im Log und in der Auswertung.
  - Neu: **automatische Testkämpfe** (Ordner `tests`): 75 Kämpfe, alle Klassen, alle Gegner, der Computer spielt.
    Alle laufen ohne Fehler durch, Zähmen, Polarstern und die Entscheidung kommen darin vor.

- **Schritt 3 – Kunoichi-Ult:** lädt jetzt nur noch durch ausgelöste Siegel-Kombinationen (+35 je Kombination,
  also nach drei Kombinationen voll). Ein einzelnes gelöstes Siegel lädt nichts mehr.

- **Schritt 4 – Elemente absichern:** Ein unbekanntes Element (z. B. Tippfehler oder ein neues Element ohne Eintrag)
  macht jetzt normalen Schaden, statt das Spiel abstürzen zu lassen. Dazu ein kleiner automatischer Test (10 von 10 richtig).
  Im Spiel ändert sich dadurch nichts Sichtbares.

- **Schritt 5 – Vorläufige Werte:** Die selbst gewählten Passiven und alle Pilzhöhlen-Zahlen stehen jetzt gesammelt
  im Abschnitt „Vorläufige Werte (Feinschliff am Ende)“.

## Fertig in Runde 1

- **Schritt 1 – Kampf-Sandbox:** Alle 11 Klassen, Element-Sechseck, Zähmer mit Monster-Wechsel,
  Mechaniker mit Roboter, sechs Duette und die Kampfauswertung waren schon fertig.
  Angeglichen an design.md: Das Duett **Sternentanz** lässt Zaras Klingen jetzt eine Runde lang
  mit **Sternenkraft** treffen (ignoriert Resistenzen) und gibt +2 Klingen und Resonanz.

- **Schritt 2 – Pilzhöhle:** spielbar in der Sandbox (Auswahl → Gegner „Pilzhöhle“ oder „Pilzhöhle: nur Bosse“).
  Eigene Monster (Leuchtmotte, Wurzelkriecher, Sporenwolf, Glimmerkäfer), Zwischenboss Sporenkönigin
  (pro Kampf zufällig Sporenblüte ODER Sporen-Zwillinge), Wurzelmutter (Rinde heilt, Zwillingsknoten,
  Verschlingen, Wurzelzug) und Vorbote (Dunkelheit, keine Zugleiste, Lichtfraß, Das letzte Licht).
  Alle Mechaniken gehen mit jeder Klasse („Giftwolke vertreiben“, „Laterne entzünden“, „Licht weiterreichen“).
  Automatisch getestet: Wipes, abgewehrtes Verschlingen, Phase 2 und Siege kommen alle vor.

- **Schritt 3 – Kreuzweg-Demo (Gerüst):** Neues Startmenü. Stadt schräg von oben mit Platzhalter-Grafik
  (Marktplatz, Statue der Fünf, Gilde, Bingos Laden, Schmiede, sechs Straßen, die sechste zugewachsen),
  Laufen per Antippen mit Wegsuche um Häuser und Bäume, Ausbilder Ye mit kurzem Gespräch
  (beim zweiten Mal ein anderer Satz), Laterne an der Gildenwand als kleiner Hinweis.
  Spiellogik und Anzeige sind getrennt; ein „Testgefährte“ läuft als zweiter Spieler über dieselben Befehle.

- **Schritt 4 – Web-Export:** Nach jedem Push automatisch neu gebaut und veröffentlicht (alle Läufe erfolgreich).

## Was du testen kannst

Link: **https://cazex-studio.github.io/MiniKampf/** (Handy quer halten). Das Spiel startet jetzt mit einem Menü.

**Neu in Runde 2 – bitte testen** (Kampf-Sandbox)
1. Bogenschütze ins Team nehmen und „Schnellfeuer“ antippen: Drei Pfeile fliegen auf zufällige Gegner.
2. Sternensängerin (heißt jetzt Vega) nehmen, „Polarstern“ auf einen Helden: Er steht danach weiter vorne in der Zugleiste und hat „Abw+“.
3. Monster-Zähmer nehmen, einen Gegner unter die Hälfte seines Lebens bringen, dann „Zähmen“. Klappt es, steht das
   Monster bei „Wechsel“ in der Liste und kämpft für dich.
4. „Pilzhöhle: nur Bosse“ schaffen: Am Ende kommt die Frage, was mit dem Urbaum geschieht. Beide Knöpfe ausprobieren.
5. Kunoichi: Ein einzelnes Siegel lösen lädt die Ult nicht mehr, zwei Siegel auf demselben Gegner lösen (Kombination) schon.


**1. Kampf-Sandbox** (Menü → „Kampf-Sandbox“)
- Wie bisher: bis zu 4 Klassen wählen, Gegner wählen, kämpfen, am Ende die Auswertung ansehen.
- Neu beim Duett **Sternentanz** (Sternensängerin + Klingentänzerin): Zaras Klingen treffen danach
  eine Runde lang mit Sternenkraft (Anzeige „Sternenkraft“ auf ihrem Namensschild).

**2. Pilzhöhle** (in der Sandbox unter „Gegner“)
- „Pilzhöhle“ = ganzer Dungeon mit 4 Wellen. „Pilzhöhle: nur Bosse“ = schneller Test der Bosse.
- Im Kampf-Log links unten steht bei jedem Boss, welche Mechanik gerade gilt.
- **Sporenkönigin:** Achte auf „Mechanik heute“. Bei *Sporenblüte* stehen die Giftwolken auf ihrem
  Namensschild – nicht mit Feuer übertreiben, „Giftwolke vertreiben“ nutzen. Bei *Sporen-Zwillinge*
  beide Sporenknospen schnell hintereinander besiegen.
- **Wurzelmutter:** Nicht auf sie selbst schlagen (heilt sie), sondern auf „Knoten vorne“ und
  „Knoten hinten“, beide vor ihrem nächsten Zug. Auf ihrem Schild läuft „Verschlingen in X Zügen“.
- **Vorbote:** Das Bild wird dunkler, die Zugleiste ist weg. „Laterne entzünden“ (hellblaue Knöpfe)
  hellt auf. Wer „SPLITTERLICHT“ auf dem Namensschild hat, wird nicht angegriffen, verliert aber
  immer mehr Leben: rechtzeitig „Licht weiterreichen“.
- Gute Fragen beim Testen: Ist es zu schwer oder zu leicht? Versteht man die Mechaniken aus dem Log?

**3. Kreuzweg-Demo** (Menü → „Kreuzweg-Demo“)
- Boden antippen = laufen. Ausbilder Ye antippen = hinlaufen und reden („Weiter“ blättert).
  Beim zweiten Mal sagt er etwas anderes.
- Der „Testgefährte“ ist ein zweiter Spieler, der zur Probe herumläuft.
- Nur ein Gerüst mit Platzhalter-Grafik: Die Häuser sind einfache Blöcke, noch keine Kämpfe oder Aufträge.


## Vorläufige Werte (Feinschliff am Ende)

Diese Dinge stehen nicht in design.md, ich habe sie selbst gewählt. Sie sind **vorläufig, Feinschliff am Ende**:
Erst wenn alles spielbar ist, werden sie zusammen abgestimmt.

- **Selbst gewählte Passiven:**
  - Mechaniker / Roboter „Wartung“: Solange Fritz lebt, repariert sich der Roboter jeden Zug um 5.
  - Rüstungsschmied: Passende Rüstung fängt 40 % ab, jede Härte (bis 5) noch einmal 6 %.
  - Zwielicht-Wandler: Am Rand der Leiste „überladen“ = 1,6-facher Schaden, aber jeden Zug 8 % Rückstoß.
  - Bank-Boni der Zähmer-Monster: Moosling −15 % Schaden, Glutwelpe +15 % Schaden, Bachotter +5 LP je Zug.
- **Pilzhöhle (alle Zahlen):** Leben und Angriffe der Monster und Bosse, 5 Giftwolken mit je 2 Schaden,
  Sporenknospen heilen 8 %, Verschlingen nach 3 Zügen, Knotenpaar kostet 25 % Leben,
  Dunkelheit in 6 Stufen, Splitterlicht brennt 8, 12, 16 …
- **Neu in Runde 2:** Schnellfeuer (3 × 7), Polarstern (Abwehr+ und 30 % früher dran),
  Zähmen (unter 50 % Leben, Chance = fehlendes Leben, halbes Leben auf der Bank, höchstens 5 Monster).
## Als Nächstes (Vorschläge)

- Kreuzweg-Demo ausbauen: Marv, Bingo, erste Aufträge, Probestunden, Sternenfall-Boss, Klassenwahl.
- Rückmeldungen zur Pilzhöhle einarbeiten (Schwierigkeit, Zahlen).

## Offene Fragen an Marco

- **Pilzhöhle – was ich selbst ergänzt habe** (bitte prüfen; alle Zahlen **vorläufig, Feinschliff am Ende**):
  - Gegen Giftwolken gibt es für jede Klasse „Giftwolke vertreiben“ (kostet den Zug), Wind-Treffer vertreiben auch eine.
    Jede Wolke macht bei jedem Zug der Königin 2 Schaden an allen.
  - „Dieselbe Runde“ heißt im Prototyp: bevor der überlebende Sporenknospe bzw. die Wurzelmutter wieder dran ist.
  - Ein zerstörtes Knotenpaar kostet die Wurzelmutter 25 % Leben, danach wachsen neue Knoten.
  - Splitterlicht: Der Halter wird vom Vorboten nicht angegriffen, verliert aber jeden Vorboten-Zug mehr Leben (8, 12, 16 …).
    Weiterreichen kostet den Zug.
  - Monsterkarten der Dungeon-Monster gibt es in der Sandbox noch nicht (Zähmen schon).
  - Entscheidung „Baum retten“: Bekommt die Gruppe den herausgeschnittenen Splitter trotzdem (kleiner?) oder wird er zerstört?
    Im Moment sagt der Text nur, dass er heraus ist.

- **Kreuzweg-Demo:** Passen die Positionen (Gilde im Nordosten, Bingos Laden im Westen, die sechste,
  zugewachsene Straße nach Südosten)? Soll Ye vor der Gilde stehen oder drinnen?
