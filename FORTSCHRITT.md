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
| 10 | Kreuzweg-Demo Schritt 3: Grundausbildung (Lektionen, erster Gruppenkampf) | erledigt |
| 11 | Kreuzweg-Demo Schritt 4: Marv und Bingos Laden | erledigt |
| 12 | Kreuzweg-Demo Schritt 5: Gesandte der fünf Regionen mit Probestunden | erledigt |
| 13 | Kreuzweg-Demo Schritt 6: Der zugewachsene Weg (Wache Holm, Mira) | erledigt |
| 14 | Kreuzweg-Demo Schritt 7: Nacht des Sternenfalls (Fest, Sternenfresser, Ren) | erledigt |

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
  - Namen nach deiner Antwort: Die Gildenschreiberin heißt **Lene**, die Schmiedin **Marta**.

- **Schritt 10 – Kreuzweg-Demo, Grundausbildung** (Schritt 3 aus `KREUZWEG_PLAN.md`, Stufe 2–5):
  - Nach Ye's erstem Auftrag steht er **am Stadttor** (in der Gilde ist er dann nicht mehr).
  - **Vier Lektionen**, jede ein eigener Kampf auf dem Kampfbildschirm, danach geht es zurück in die Stadt:
    1. **Tempo-Leiste** gegen einen Feldschleim (nur „Schlag“),
    2. **Fähigkeiten** (neu: Kraftschlag und Erste Hilfe, Mana und Abklingzeit),
    3. **Parieren** gegen Ye selbst mit Übungsschwert – bestanden nach **zwei perfekten Paraden** („Schild hoch, Schild runter“),
    4. **Zwei Reihen** gegen einen Rüpelkobold (neu: „Nach hinten“).
  - **Erklär-Fenster** („Ye erklärt“) halten den Kampf an, bis du „Verstanden“ antippst. Die Erklärung zum Parieren
    kommt, bevor der erste Schlag losgeht, damit der Ring zum Schlag passt.
  - **Erster Gruppenkampf:** du mit den Novizen **Ida, Bo und Tom** (der Computer steuert sie) gegen vier Kobolde.
  - Du kämpfst als **Novize** (noch keine Klasse, keine Ult): mit jeder Stufe etwas mehr Leben und Mana.
  - Erfahrung gibt es beim **ersten** Sieg jeder Lektion. Verlieren ist nicht schlimm: „Nochmal versuchen“ oder später
    wieder mit Ye reden. „Aufgeben“ oben rechts bringt dich zurück in die Stadt.
  - Am Ende: **Stufe 5**, 75 Gold, 3 Heiltränke. Ye kündigt an, dass in der Stadt bald einiges los ist (Schritt 4: Marv und Bingo).
  - Neue Gegner: Feldschleim, Wiesenkobold, Rüpelkobold (zähmbar wie alle normalen Monster).
  - **Platzhalter:** alle Texte (Ye, Erklärungen, Ida, Bo, Tom); als Hintergrund dient noch das Gewölbe der Sandbox,
    nicht die Wiese vor dem Stadttor.
  - **Tests:** Der Computer hat jede Lektion und den Gruppenkampf je 30-mal gespielt: alles läuft, alles ist für
    Anfänger schaffbar (Zahlen vorläufig). Welt-Test mit der ganzen Grundausbildung und ein Test für den echten Wechsel
    Stadt → Kampf → Stadt: alles richtig. Die 75 Sandbox-Kämpfe laufen unverändert.
  - **Nachbesserung nach deinem Test:**
    - In **Lektion 1 und 2** kann der Novize noch **nicht parieren** (kein Ring). Parieren kommt erst in Lektion 3.
      Ye erklärt dort zusätzlich: Als Novize lernt jeder das Parieren, später hängt es von der Klasse ab
      (manche parieren, manche weichen aus, manche haben keine Reaktion). Auf dem Klassenwahl-Bildschirm (Schritt 8)
      steht das dann bei jeder Klasse.
    - **Zahlentasten am PC:** Vor jedem Knopf im Kampf steht seine Nummer, 1–9 wählen ihn aus (Fähigkeiten, Auswahl,
      „Zurück“). Gilt auch in der Kampf-Sandbox. Am Handy bleiben die Knöpfe ohne Nummer.
    - **Mitstreiter parieren seltener:** Ida, Bo und Tom schaffen eine perfekte Reaktion nur noch in 10 % der Fälle.
    - **Lektion 4:** Die erste Aktion ist „Nach hinten“. Alle anderen Knöpfe sind gesperrt („Erst ‚Nach hinten‘“),
      bis du die Reihe gewechselt hast. Danach ist alles frei. (In `data/kaempfe.json` als `"zuerst": "row"` festgelegt.)

- **Schritt 11 – Kreuzweg-Demo, Marv und Bingos Laden** (Schritt 4 aus `KREUZWEG_PLAN.md`):
  - **Marv** ist erst nach der Grundausbildung in der Stadt (an der Straße zwischen Tor und Marktplatz) und
    **spricht dich von sich aus an**, sobald du vorbeikommst – einmal. Er erzählt begeistert von Kreuzweg-Karten
    und schickt dich zu Bingo. Auftrag „Marvs großer Traum“: bei Bingo nach der Sternentafel fragen, zurück zu Marv.
    Seine Antwort auf 5000 Gold: „Dann spar halt! Ich hab Zeit.“ (der Running Gag beginnt).
  - **Handelsherr Bingo** steht vor seinem Laden. **Laden-Fenster:** Heiltrank kaufen (15 Gold), Dinge aus der Tasche
    verkaufen (zur Hälfte des Preises), die **Sternentafel für 5000 Gold** (viel zu teuer: „Zu wenig Gold“).
    Bingo erklärt auf Nachfrage, was die Sternentafel ist.
  - **Heiltränke im Kampf:** Damit sich der Laden lohnt, kann der Novize ab Lektion 4 und im Gruppenkampf Heiltränke
    aus seiner Tasche trinken oder reichen (heilt 35). Getrunkene Tränke fehlen danach in der Tasche, auch bei
    „Nochmal versuchen“.
  - Neue Datendatei `data/laeden.json`. **Platzhalter:** alle Texte von Marv und Bingo, ihr Aussehen.
  - Das Mini-Spiel Kreuzweg-Karten selbst kommt später (laut Plan spielt Marv genau einmal mit).
  - Tests: Welt-Test mit Marv und Bingo (Ansprechen, Kaufen, Verkaufen, zu teuer), Übergangs-Test mit Heiltränken: alles richtig.

- **Schritt 12 – Kreuzweg-Demo, Gesandte der fünf Regionen** (Schritt 5 aus `KREUZWEG_PLAN.md`, Stufe 5–7):
  - **Ye am Tor** steht jetzt links neben der Straße (10,19) und nicht mehr hinter den Bäumen.
  - Nach der Grundausbildung stehen **fünf Gesandte** rund um die Statue der Fünf: Arkanum, Messinghafen, Glutoase,
    Grünwacht und Nebelinseln. Jeder erzählt kurz von seiner Region und bietet **Probestunden** für ihre Klassen an
    (zusammen alle 11 Klassen aus der Sandbox).
  - **Lene** (Schreiberin) vergibt den Auftrag „Die Gesandten der fünf Regionen“: **eine Probestunde ist Pflicht**,
    die anderen sind freiwillig (jede gibt beim ersten Sieg 40 Erfahrung). Abgeben bei Lene: 300 Erfahrung, 50 Gold
    – damit **Stufe 6**, mit allen Probestunden Stufe 7.
  - **Probestunde:** Du spielst die Klasse kurz auf der Übungswiese, **mit Ida und Bo** als Gruppe (sonst sind Tank und
    Support allein kaum spielbar). Die **Ult ist schon zu 60 % voll** – du lädst sie mit der typischen Aktion der Klasse
    auf. Ye erklärt vorher die Klasse (Rolle, Mechanik, Reaktion, Ult) aus den Klassendaten.
  - Gespräche mit vielen Antworten wachsen nach oben, damit sie ins Bild passen. In der Stadt wählen 1–9 Antworten.
  - **Namen der Gesandten** (nach deiner Antwort): Magistra Ilwen (Arkanum), Tüftler Pim (Messinghafen), Feuertänzerin
    Nalia (Glutoase), Fährtenleser Aske (Grünwacht), Schreindienerin Mei (Nebelinseln).
  - **Platzhalter:** alle Texte der Gesandten. Hintergrund im Kampf
    ist noch das Gewölbe.
  - **Tests:** Der Computer hat alle 11 Probestunden je 30-mal gespielt: alle schaffbar (24–43 Züge, alle Figuren
    zusammen). Welt-Test mit Lene, Gesandten und Probestunden: alles richtig.

- **Schritt 13 – Kreuzweg-Demo, Der zugewachsene Weg** (Schritt 6 aus `KREUZWEG_PLAN.md`, Stufe 7–8):
  - Nach den Gesandten bittet **Lene** dich, der Wache am alten Südost-Weg einen **Essenskorb** zu bringen.
  - **Wache Holm** steht am Anfang der zugewachsenen sechsten Straße (hinter der Schmiede). Er freut sich über das
    Essen, aber zum Weg sagt er nur „Befehl der Fünf: Niemand geht da lang“ – und schickt dich weg.
  - Danach hörst du ein leises Singen: **Mira** steht plötzlich da und spricht dich an: **„Hörst du sie auch?“**
    Sie war vor zehn Jahren auch Novize, hustet („Die Lieder werden lauter“) und verabschiedet sich mit einem Hinweis
    auf das **Fest der fünf Wege**. Danach ist sie wieder fort.
  - Belohnung: 200 + 250 Erfahrung = **Stufe 7** (mit allen freiwilligen Probestunden Stufe 8).
  - **Platzhalter:** alle Texte von Lene, Holm und Mira (Mira ist eine Hauptfigur: Marco schreibt ihre Dialoge noch).
  - Der Marktplatz ist inzwischen recht voll (viele Namensschilder dicht beieinander). Das nehme ich mir beim
    Feinschliff (Schritt 9) vor.
  - Test: Welt-Test mit Korb, Wache und Mira: alles richtig.

- **Schritt 14 – Kreuzweg-Demo, Nacht des Sternenfalls** (Schritt 7 aus `KREUZWEG_PLAN.md`, Stufe 8–10):
  - **Aufgeräumt:** Die Gesandten stehen jetzt am Anfang „ihrer“ Straße (Arkanum Norden, Nebelinseln Nordwesten,
    Grünwacht Westen, Messinghafen Osten, Glutoase Süden) statt alle um die Statue. NPCs wippen deutlich ruhiger
    und nicht mehr alle im Gleichtakt.
  - **Fest der fünf Wege:** Lene lädt dich ein („Warum fünf Wege? Es gibt doch sechs Straßen.“ – „Die sechste zählt
    nicht.“). Es wird **Nacht**, auf dem Marktplatz leuchten **fünf Festlaternen** in den Farben der Regionen.
    Die Gesandten sind abgereist.
  - **Marv** spricht dich auf dem Fest an und fragt, ob du die Sternentafel schon hast. Mitten im Satz beginnt der
    **Sternenfall**: greller Lichtblitz, das Bild wackelt, ein Splitter schlägt ein, ein Feldschleim frisst ihn.
  - **Boss „Der Sternenfresser“** (mit Ida, Bo und Tom): Ein **Sternenpanzer** lässt Treffer fast abprallen. Nur eine
    **perfekte Parade** erschüttert ihn für kurze Zeit, dann könnt ihr zuschlagen. Nach **10 Zügen** explodiert
    der Splitter in seinem Bauch. So ist er nur mit mehreren guten Paraden zu schaffen.
    (Computer-Test mit jeder zweiten Parade gelungen: 11 von 30 Siegen – wer gut pariert, schafft es öfter.)
  - **Sieg:** Erfolg **„Schild hoch, Schild runter“** (steht jetzt im Auftragsbuch unter „Erfolge“) – und eine
    Fremde taucht auf, lobt dich und **klaut den Splitter**. **Niederlage:** Alles wird schwarz … dieselbe Fremde
    **rettet die Gruppe**. Beides Mal stellt sie sich als **Ren** vor („Du hast mich nie gesehen“).
  - Kein „Nochmal versuchen“ beim Boss: Die Geschichte geht so oder so weiter. Danach: Stufe 8 (Niederlage) bzw. 9 (Sieg).
  - Auf dem Marktplatz bleibt ein **leuchtender Krater**.
  - **Platzhalter:** alle Texte (Lene, Marv, Erzähler, Ye, Ren – Ren ist eine Hauptfigur). Der Kampf spielt noch im Gewölbe.
  - Tests: Welt-Test mit Fest, Sternenfall, Niederlage und Sieg: alles richtig. Sandbox-Kämpfe unverändert.
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

**Neu: Grundausbildung** (Kreuzweg-Demo, nach Ye's erstem Auftrag)
1. Prüfe, ob Ye nach seinem ersten Auftrag am Stadttor (unten, wo du angekommen bist) mit „!“ steht. Sprich ihn an.
2. Lektion 1 und 2 spielen: Erscheinen die Erklär-Fenster, kommt noch KEIN Ring, und geht es danach zurück in die Stadt?
   Am PC: Fähigkeiten mit den Zahlentasten 1, 2, 3 … wählen.
3. Lektion 3: Ye greift an, tippe, wenn der Ring grün wird. Prüfe, ob die Lektion nach zwei Paraden bestanden ist.
4. Lektion 4: Zuerst geht nur „Nach hinten“, die anderen Knöpfe sind gesperrt. Bekommst du hinten weniger Schaden?
5. Gruppenkampf mit Ida, Bo und Tom gewinnen und bei Ye abgeben: Danach solltest du Stufe 5 haben.

**Neu: Marv und Bingo** (Kreuzweg-Demo, nach der Grundausbildung)
1. Vom Stadttor Richtung Marktplatz laufen: Marv sollte dich von selbst ansprechen. Nimm seinen Auftrag an.
2. Zu Handelsherr Bingo (links vor seinem Laden): „Zeig mir deine Waren“. Kauf einen Heiltrank und verkauf etwas.
3. Versuch, die Sternentafel zu kaufen: Es sollte „Zu wenig Gold“ kommen.
4. Bingo nach dem leuchtenden Brett fragen, dann zurück zu Marv und den Auftrag abgeben.
5. Im Gruppenkampf (oder Lektion 4) einen Heiltrank trinken: Danach sollte er in der Tasche fehlen.

**Neu: Gesandte und Probestunden** (Kreuzweg-Demo, nach der Grundausbildung)
1. Am Stadttor nachsehen: Ye steht jetzt links neben der Straße und nicht mehr hinter den Bäumen.
2. Lene hat ein „!“: Sprich mit ihr und nimm den Auftrag an.
3. Geh zu einem der fünf Gesandten rund um die Statue und frag nach der Region. Starte dann eine Probestunde.
4. Prüfe in der Probestunde, ob die Erklärung zur Klasse passt und ob du die Ult (60 % voll) aufladen und benutzen kannst.
5. Danach bei Lene abgeben: Prüfe, ob du jetzt Stufe 6 hast. Probier gern noch weitere Klassen aus.

**Neu: Der zugewachsene Weg** (Kreuzweg-Demo, nach den Gesandten)
1. Prüfe bei einem Gesandten, ob er jetzt einen eigenen Namen hat (z. B. Feuertänzerin Nalia).
2. Lene bittet dich nach den Gesandten um den Essenskorb. Nimm an: Der Korb liegt jetzt in deiner Tasche.
3. Geh zu Wache Holm am Anfang der zugewachsenen Straße hinter der Schmiede, gib ihm den Korb und frag nach dem Weg.
4. Nachdem er dich wegschickt, sollte Mira dich ansprechen: „Hörst du sie auch?“
5. Danach sollte Mira wieder fort sein und du Stufe 7 haben.

**Neu: Nacht des Sternenfalls** (Kreuzweg-Demo, nach Mira)
1. Prüfe, ob die Gesandten jetzt an den fünf Straßen stehen und die NPCs ruhiger stehen.
2. Lene lädt zum Fest ein: Wird es Nacht, und leuchten auf dem Marktplatz fünf Laternen?
3. Geh zum Marktplatz: Marv spricht dich an, dann beginnt der Sternenfall (Lichtblitz) und der Boss-Kampf.
4. Im Kampf: Pariere die Angriffe des Sternenfressers. Erst nach einer perfekten Parade ist er „ERSCHÜTTERT“ und nimmt
   richtig Schaden. Achte auf den Countdown „EXPLOSION in X Zügen“.
5. Danach taucht Ren auf (bei Sieg klaut sie den Splitter, bei Niederlage rettet sie euch). Bei Sieg: Auftragsbuch → Erfolge.


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

- Kreuzweg-Demo nach `KREUZWEG_PLAN.md`: als Nächstes Schritt 8 (Klassenwahl-Bildschirm und Abreise).
- Hintergrund für Kämpfe vor der Stadt (Wiese statt Gewölbe).
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
