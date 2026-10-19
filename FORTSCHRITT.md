# Fortschritt

Hier steht, was fertig ist, was als Nächstes kommt und welche Fragen offen sind.
Wird nach jedem Arbeitsschritt aktualisiert.

## Kurz zusammengefasst (Runde 2, Stand 2026-10-19)

**Was sich geändert hat:**
- Die Sternensängerin heißt jetzt **Vega**.
- Neue Fähigkeiten: **Schnellfeuer** (Bogenschütze), **Polarstern** (Sternensängerin), **Zähmen** (Monster-Zähmer,
  auch Monster aus der Pilzhöhle). Nach der Pilzhöhle entscheidest du, was mit dem **Urbaum** passiert.
- Die Ult der Kunoichi lädt nur noch durch Siegel-**Kombinationen**.
- Unter der Haube: Der Kampf ist jetzt in **Regeln** (ohne Grafik) und **Anzeige** getrennt – die Grundlage für
  gemeinsame Kämpfe. 75 Computer-Kämpfe laufen vorher und nachher genau gleich ab.
- **Kreuzweg-Demo:** Laufen mit **WASD/Pfeiltasten** oder **Steuerknopf** am Handy, reden mit **E/Leertaste** oder
  dem Knopf „Reden“. Neu: **Gespräche mit Antworten**, **Auftragsbuch**, **Gold und Tasche**, **Stufen 1–10**,
  **automatisches Speichern** und ein kleiner **Probe-Auftrag** bei Ye. Alle Texte stehen in Datendateien (`data/`).
- Selbst gewählte Zahlen und Passiven sind als **„vorläufig, Feinschliff am Ende“** gesammelt (Abschnitt weiter unten).
- Neuer Fahrplan für die Kreuzweg-Demo: `KREUZWEG_PLAN.md` (Schritt 0 und 1 sind fertig).

**Was du testen kannst:** siehe „Was du testen kannst“ weiter unten (Abschnitte „Neu in Runde 2“).

**Bitte beachten:** Alle Dialoge von Ye sind **Platzhalter-Texte**. Die Dialoge der Hauptfiguren schreibst du noch;
sie stehen in `data/dialoge.json` und lassen sich dort ohne Programmieren ändern (Anleitung in `data/LIESMICH.md`).

## Aufgaben dieser Runde (Runde 2)

| Nr. | Aufgabe | Stand |
|-----|---------|-------|
| 1 | Sternensängerin heißt jetzt „Vega“ | erledigt |
| 2 | Schnellfeuer, Polarstern, Zähmen, Entscheidung nach der Pilzhöhle | erledigt |
| 3 | Kunoichi-Ult lädt nur durch Siegel-Kombinationen | erledigt |
| 4 | Elemente absichern (unbekanntes Element = normaler Schaden) | erledigt |
| 5 | Selbst gewählte Werte als „vorläufig“ markieren | erledigt |
| 6 | Kampf in Regeln und Anzeige trennen | erledigt |
| 7 | Steuerung in der Welt: Tasten (PC), Steuerknopf und Aktions-Knopf (Handy) | erledigt |
| 8 | Kreuzweg-Demo Schritt 1: Bausteine (siehe KREUZWEG_PLAN.md) | erledigt |
| 9 | Kreuzweg-Demo Schritt 2: Ankunft (Gilde, Ye, erster Auftrag) | erledigt |

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

- **Schritt 6 – Kampf in Regeln und Anzeige getrennt:**
  - **Regeln** (`battle_state.gd`): ein Kampf-Zustand ganz ohne Grafik. Er nimmt Befehle an („Vega benutzt
    Polarstern auf Wren“, „Reaktion getroffen: ja“) und meldet Ereignisse („Treffer 12 auf Sporenwolf“,
    „Geschoss von Wren zum Dornling“, Log-Zeilen). Er wartet nie auf Animationen und hat seinen eigenen Zufall.
  - **Anzeige** (`combat.gd`): spielt diese Ereignisse der Reihe nach ab (Figuren, Treffer, Leisten, Log, Ring)
    und gibt deine Eingaben als Befehle zurück. Die Lebensleiste sinkt erst, wenn der Treffer zu sehen ist.
  - **Warum:** Für gemeinsame Kämpfe kann der Kampf-Zustand später auf einem Server laufen; jeder Spieler hat nur
    die Anzeige. Ein Computer-Spieler kann denselben Kampf ohne Grafik in Sekunden durchspielen.
  - **Geprüft:** 75 automatische Kämpfe (5 Teams, alle 11 Klassen, alle 5 Gegner, je 3 feste Zufallswerte)
    vor und nach dem Umbau. Ergebnis: **Zug für Zug identisch** (Leben, Mana, Ult, Zugleiste, jede Log-Zeile und
    jede Schadenszahl, rund 90.000 Zeilen). Für den Vergleich habe ich im alten Stand nur die Zufallsquelle
    ausgetauscht, sonst nichts. Dazu ein Probelauf mit echter Anzeige, in dem der Computer spielt
    (`tests/anzeige_auto.tscn`), und alle Szenen starten ohne Fehlermeldung.

- **Schritt 7 – Steuerung in der Welt** (Kreuzweg-Demo, auch in design.md unter „Steuerung“ eingetragen):
  - **PC:** WASD oder Pfeiltasten = laufen, E oder Leertaste = reden bzw. Gespräch weiterblättern. Klicken zum Hinlaufen bleibt.
  - **Handy:** Steuerknopf unten links – er erscheint dort, wo der Daumen aufsetzt (kurz antippen ohne Ziehen = hinlaufen).
    Aktions-Knopf „Reden“ unten rechts. Antippen zum Hinlaufen bleibt. Beides erscheint nur auf Geräten mit Touchscreen.
  - Häuser, Bäume und NPCs halten dich auf, du rutschst an ihnen entlang.
  - Wie bisher alles über Befehle an die Welt („steuern“, „benutzen“), damit später Mitspieler dazukommen können.
  - Der Kampf bleibt rundenbasiert mit Antippen. Automatischer Test `tests/welt_test.gd`: alles richtig.

- **Schritt 8 – Kreuzweg-Demo, Bausteine** (Schritt 1 aus `KREUZWEG_PLAN.md`):
  - **Gespräche mit Antworten:** Ye stellt Fragen, du wählst eine Antwort (antippen oder Taste 1–4).
    Je nach Antwort und Fortschritt sagt er etwas anderes.
  - **Auftragsbuch** (Knopf „Aufträge“ oder J): zeigt laufende, erfüllte und abgeschlossene Aufträge mit Fortschritt.
  - **Gold und Tasche** (Knopf „Tasche“ oder I), **Erfahrung und Stufen 1–10** oben links.
  - **Speichern:** automatisch bei jedem Fortschritt und beim Verlassen. „Neu beginnen“ löscht den Spielstand.
  - **Probe-Auftrag „Kräuter für Ye“:** nur zum Ausprobieren der Bausteine (der echte erste Auftrag kommt in Schritt 2).
    Drei leuchtende Silberkräuter einsammeln (antippen oder E daneben), bei Ye abgeben:
    30 Gold, 120 Erfahrung (= Stufe 2) und ein Heiltrank.
  - **Alles in Datendateien** (`data/`): Dialoge, Aufträge, Gegenstände, Stufen, Meldungen und die NPCs der Stadt.
    Anleitung zum Ändern: `data/LIESMICH.md`.
  - **Mehrspieler-tauglich:** Jeder Spieler hat seinen eigenen Fortschritt, alles läuft über Befehle an die Welt
    („rede mit Ye“, „wähle Antwort 2“, „sammle Punkt 1“). Jeder sieht nur die Kräuter, die er selbst noch nicht hat.
  - **Platzhalter:** Ye's Texte sind Platzhalter – **Marco schreibt die Dialoge der Hauptfiguren noch.**
  - Automatischer Test `tests/welt_test.gd` (Gespräch, Auftrag, Belohnung, Stufen, Speichern): alles richtig.

- **Nachbesserung nach deinem Test:**
  - Das dritte Silberkraut lag hinter der Schmiede versteckt. Es liegt jetzt frei sichtbar auf dem Marktplatz.
  - **Splitter sind Dungeon-Belohnungen** (auch in design.md eingetragen): Nach der Pilzhöhle behält die Gruppe den
    Splitter in beiden Fällen. In der Auswertung steht „Belohnung: Sternensplitter“. Der Sternensplitter steht schon
    als Gegenstand in `data/gegenstaende.json`, damit er später in die Tasche kommen kann.
  - Die Knöpfe der Urbaum-Entscheidung verraten nicht mehr, was danach passiert (z. B. besserer Ruf bei den Zähmern).
    Die Folgen stehen erst nach der Wahl im Log. Das gilt ab jetzt für alle Entscheidungen.
  - Die Urbaum-Frage kommt **nur beim ersten Abschluss**. Die Wahl wird im Spielstand gespeichert; bei jedem weiteren
    Sieg in der Pilzhöhle gilt sie automatisch („Wie beim ersten Mal …“). „Neu beginnen“ in der Kreuzweg-Demo löscht

- **Schritt 9 – Kreuzweg-Demo, Ankunft** (Schritt 2 aus `KREUZWEG_PLAN.md`, Stufe 1–2):
  - **Einleitung am Stadttor:** Beim ersten Betreten erzählt ein Erzähler kurz, wo du bist, und schickt dich zur Gilde.
  - **Abenteurergilde:** Die Gildenschreiberin **Lene** vor dem Eingang trägt dich als Novize ein und schickt dich zu Ye.
  - **Ausbilder Ye:** begrüßt dich, beantwortet Fragen (Kämpfen, Laterne) und gibt den **ersten Auftrag
    „Die Stadt kennenlernen“**: drei Silberkräuter sammeln und der **Schmiedin Marta** Bescheid sagen. Abgeben bei Ye
    = 25 Gold, ein Heiltrank und genau **Stufe 2**. Danach kündigt Ye die Grundausbildung am Stadttor an (Schritt 3).
  - **Hilfen zum Zurechtfinden:** „!“ über einem NPC = neuer Auftrag, „?“ = dort etwas erledigen oder abgeben.
    Oben links steht immer das nächste **Ziel** (z. B. „Silberkraut 1 / 3“ oder „Zurück zu Ausbilder Ye“).
  - Wer Ye vor der Anmeldung anspricht, wird freundlich zur Gilde geschickt. Marv kommt wie geplant erst nach dem Tutorial.
  - Der Probe-Auftrag aus Schritt 1 ist durch den echten ersten Auftrag ersetzt. **Alte Spielstände beginnen neu**
    (sie passten nicht mehr zum neuen Ablauf).
  - **Platzhalter:** Alle Texte von Erzähler, Gildenschreiberin, Ye und Schmiedin sind Platzhalter –
    **Marco schreibt die Dialoge der Hauptfiguren noch** (`data/dialoge.json`).
  - Automatischer Test `tests/welt_test.gd` spielt den ganzen Ablauf durch (41 Prüfungen): alles richtig.
    sie mit. (Im fertigen Spiel ist der erste Abschluss der über den Auftrag.) Auch in design.md eingetragen.

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
4. „Pilzhöhle: nur Bosse“ schaffen: Am Ende kommt die Frage, was mit dem Urbaum geschieht (nur beim ersten Mal; zum
   erneuten Testen in der Kreuzweg-Demo „Neu beginnen“ antippen).
5. Kunoichi: Ein einzelnes Siegel lösen lädt die Ult nicht mehr, zwei Siegel auf demselben Gegner lösen (Kombination) schon.
6. Umbau des Kampfes: Spiel einen ganzen Kampf wie gewohnt. Es sollte sich nichts anders anfühlen: Treffer, Zahlen,
   Ring zum Parieren, Wellen und Auswertung wie vorher. Achte darauf, dass die Lebensleiste erst beim Treffer sinkt.

**Neu: Steuerung in der Kreuzweg-Demo** (Menü → „Kreuzweg-Demo“)
1. PC: Mit WASD oder den Pfeiltasten herumlaufen. Läuft die Figur in die richtige Richtung und bleibt an Häusern hängen?
2. PC: Neben Ausbilder Ye stellen und E (oder Leertaste) drücken: Das Gespräch startet, E blättert weiter.
3. Handy (quer): Daumen unten links aufsetzen und ziehen. Der Steuerknopf erscheint unter dem Daumen, die Figur läuft.
4. Handy: Neben Ye „Reden“ unten rechts antippen. Das Gespräch startet.
5. Antippen bzw. Klicken auf den Boden läuft weiterhin dorthin.

**Bausteine der Kreuzweg-Demo:** Gespräche mit Antworten, Auftragsbuch (J), Tasche (I), Stufe oben links, Speichern
(Seite neu laden = Stand bleibt) und „Neu beginnen“ testest du jetzt direkt im Ablauf „Ankunft in Kreuzweg“.

**Neu: Ankunft in Kreuzweg** (Menü → „Kreuzweg-Demo“, vorher einmal „Neu beginnen“)
1. Prüfe, ob der Erzähler die Stadt kurz vorstellt und oben „Ziel: Bei der Gildenschreiberin anmelden“ steht.
2. Zur Gildenschreiberin gehen (das „?“ über ihrem Kopf). Probier beide Antworten aus und lass dich eintragen.
3. Zu Ausbilder Ye gehen (jetzt hat er das „?“). Stell ihm Fragen und nimm danach seinen Auftrag an.
4. Der Schmiedin (südlich der Statue, vor der Schmiede) Bescheid sagen und die drei Kräuter sammeln.
   Prüfe, ob das Ziel oben mitzählt.
5. Bei Ye abgeben: Danach solltest du Stufe 2, 25 Gold und einen Heiltrank haben, und Ye erwähnt die Grundausbildung.


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
- Boden antippen = laufen (oder WASD/Pfeiltasten bzw. Steuerknopf). Ausbilder Ye antippen = hinlaufen und reden („Weiter“ oder E blättert).
  Beim zweiten Mal sagt er etwas anderes.
- Der „Testgefährte“ ist ein zweiter Spieler, der zur Probe herumläuft.
- Platzhalter-Grafik: Die Häuser sind einfache Blöcke. Noch keine Kämpfe in der Stadt, nur ein Probe-Auftrag.


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

- Kreuzweg-Demo nach `KREUZWEG_PLAN.md`: als Nächstes Schritt 3 (Grundausbildung: Kämpfe vor der Stadt, Tutorial, erster Gruppenkampf).
- Dialoge der Hauptfiguren: Marco schreibt sie; Platzhalter stehen in `data/dialoge.json`.
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


- **Kreuzweg-Demo:** Passen die Positionen (Gilde im Nordosten, Bingos Laden im Westen, die sechste,
  zugewachsene Straße nach Südosten)? Soll Ye vor der Gilde stehen oder drinnen?
