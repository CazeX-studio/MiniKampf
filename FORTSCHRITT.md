# Fortschritt

Hier steht, was fertig ist, was als Nächstes kommt und welche Fragen offen sind.
Wird nach jedem Arbeitsschritt aktualisiert.

## Aufgaben dieser Runde (Runde 2)

| Nr. | Aufgabe | Stand |
|-----|---------|-------|
| 1 | Sternensängerin heißt jetzt „Vega“ | erledigt |
| 2 | Schnellfeuer, Polarstern, Zähmen, Entscheidung nach der Pilzhöhle | offen |
| 3 | Kunoichi-Ult lädt nur durch Siegel-Kombinationen | offen |
| 4 | Elemente absichern (unbekanntes Element = normaler Schaden) | offen |
| 5 | Selbst gewählte Werte als „vorläufig“ markieren | offen |
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

## Als Nächstes (Vorschläge)

- Kreuzweg-Demo ausbauen: Marv, Bingo, erste Aufträge, Probestunden, Sternenfall-Boss, Klassenwahl.
- Rückmeldungen zur Pilzhöhle einarbeiten (Schwierigkeit, Zahlen).

## Offene Fragen an Marco

- **Pilzhöhle – was ich selbst ergänzt habe** (bitte prüfen):
  - Gegen Giftwolken gibt es für jede Klasse „Giftwolke vertreiben“ (kostet den Zug), Wind-Treffer vertreiben auch eine.
    Jede Wolke macht bei jedem Zug der Königin 2 Schaden an allen.
  - „Dieselbe Runde“ heißt im Prototyp: bevor der überlebende Sporenknospe bzw. die Wurzelmutter wieder dran ist.
  - Ein zerstörtes Knotenpaar kostet die Wurzelmutter 25 % Leben, danach wachsen neue Knoten.
  - Splitterlicht: Der Halter wird vom Vorboten nicht angegriffen, verliert aber jeden Vorboten-Zug mehr Leben (8, 12, 16 …).
    Weiterreichen kostet den Zug.
  - Zähmen und Monsterkarten der Dungeon-Monster gibt es in der Sandbox noch nicht.

- **Kreuzweg-Demo:** Passen die Positionen (Gilde im Nordosten, Bingos Laden im Westen, die sechste,
  zugewachsene Straße nach Südosten)? Soll Ye vor der Gilde stehen oder drinnen?
