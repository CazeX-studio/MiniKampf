# Bauaufträge

Kleine Bauaufträge für Claude Code, übertragen aus dem Abschnitt „Bauaufträge-Entwurf (Stand 21.10.2026)“
im Brainstorm-Doc „CazeX MMO – Brainstorming“. Die Beschlüsse in design.md (Repo Spieldesign) gelten.
Sagt Marco „Mach den nächsten Bauauftrag“: kurz FORTSCHRITT.md prüfen, den nächsten offenen Schritt von oben nehmen, bauen, committen, Status auf „fertig“ setzen und in FORTSCHRITT.md eintragen.

Status: offen / in Arbeit / fertig

## Projekt 0: Playtest 25.10. (Rest) – kommt vor allen anderen

Teil 1 ist gebaut (siehe FORTSCHRITT.md). Schritte 1–4 fertig (26.10.). Die Details stehen im Brainstorm-Doc unter „Testtag-Notizen“ → „Playtest 25.10.2026“.

### Schritt 1: Tasche wie in klassischen Spielen
- **Ziel:** Die Tasche zeigt Kästchen, in jedem liegt ein Gegenstand mit Bild und Anzahl. Gegenstände lassen sich per Ziehen und Ablegen verschieben (die Reihenfolge wird gemerkt). Passt zu Projekt 4 (Tasche und Bank).
- **So testest du es:** Mit I die Tasche öffnen, einen Gegenstand in ein anderes Kästchen ziehen, Tasche schließen und wieder öffnen: Er liegt noch dort.
- **Status:** fertig (26.10.)

### Schritt 2: Klasse erst beim Lehrmeister lernen
- **Ziel:** Am Ende von Kreuzweg wählt man nur die Klasse und bekommt einen Auftrag, der zum Lehrmeister in der Region führt. Erst dort lernt man die Klasse (bis dahin kämpft man als Novize). Gilt für alle Klassen, Grünwacht zuerst (Fenn, Tilda).
- **So testest du es:** Neu beginnen, bis zur Klassenwahl spielen, eine Grünwacht-Klasse wählen: Der Wegweiser führt zum Lehrmeister, erst nach dem Gespräch dort kämpft man mit der Klasse.
- **Status:** fertig (26.10.; Bogenschütze bei Fenn, Zähmer bei Esche; die anderen Klassen kämpfen wie bisher gleich mit ihrer Klasse, bis es ihre Region gibt)

### Schritt 3: Kael kommt auf einer anderen Plattform dazu
- **Ziel:** Kael steht nicht mehr direkt neben Ysolde. Ein kleiner Auftrag schickt einen auf eine andere Plattform in Wipfelheim, dort kommt Kael angelaufen und spricht einen an.
- **So testest du es:** Nach den veränderten Tieren dem Wegweiser folgen: Kael läuft auf der anderen Plattform zu dir.
- **Status:** fertig (26.10.; Westplattform beim Seilaufzug, Auftrag „Ein Fremder in Wipfelheim“ von Ysolde)

### Schritt 4: Grünwacht größer
- **Ziel:** Weg nach Grünwacht, Waldboden und Wipfelheim werden größer und weniger eng (mehr Platz zwischen Bäumen, Figuren und Orten). Monster, Orte und Wegweiser passen sich an, die automatischen Durchläufe laufen weiter.
- **So testest du es:** Durch den Wald und Wipfelheim laufen: Es fühlt sich weiter an, nichts klemmt, keine Figur steht zu dicht an einer anderen.
- **Status:** fertig (26.10.; alle drei Karten um die Hälfte größer, Pilzhöhle unverändert)

## Projekt 1: Aussehen

### Schritt 1: Licht wie bei Octopath Traveler
- **Ziel:** Lichtquellen wie Fackeln, Laternen, leuchtende Sternensplitter und Glut, dazu ein leichtes Abdunkeln der Umgebung, damit das Licht wirkt.
- **So testest du es:** Kreuzweg und die Pilzhöhle ansehen, die Lichter werfen einen Schein und die Splitter glühen.
- **Status:** fertig (22.10.)

### Schritt 2: Einheitliches Pixel-Paket
- **Ziel:** Ein einheitliches kostenloses Pixel-Paket (freie Lizenz) im Stil von Ragnarok und Octopath. Claude Code schlägt vorher zwei bis drei Pakete zur Auswahl vor und stellt nach Marcos Wahl alle Platzhalter darauf um.
- **So testest du es:** Durch Kreuzweg laufen und einen Kampf spielen, alles wirkt wie aus einem Guss.
- **Vorschläge (22.10.):** A) Flare (schräge Sicht wie jetzt, Ausrüstung sichtbar, CC-BY-SA), B) LPC-Figurenbaukasten (Sicht von oben, riesige Auswahl, CC-BY-SA/GPL/OGA-BY, Welt müsste umgebaut werden), C) Ninja Adventure (Sicht von oben, niedlich, CC0). Empfehlung Claude: A. Marco (22.10.): Flare gefällt nicht, gewünscht ist Pixel-Grafik wie Octopath, er schaut sich selbst um (selbst zeichnen, KI als Vorlage oder Pixel-Künstler).
- **Status:** zurückgestellt (wartet auf die Look-Bibel, Abendthema 12 im Brainstorm-Doc)

### Schritt 3: Licht im Kampf
- **Ziel:** Der Kampf übernimmt das Grundlicht des Ortes (Höhle dunkel, Fest-Nacht bläulich, tagsüber hell). Im Gewölbe stehen Fackeln am Rand. Feuer-, Blitz-, Licht- und Splitter-Angriffe leuchten kurz auf (wie die Zauber bei Octopath Traveler).
- **So testest du es:** Einen Kampf in Kreuzweg, einen in der Pilzhöhle und einen in der Fest-Nacht spielen: Jeder Kampf sieht aus wie sein Ort, ein Feuerangriff taucht das Feld kurz in oranges Licht.
- **Status:** fertig (22.10.)

### Schritt 4: Licht als Mechanik in der Pilzhöhle
- **Ziel:** Beim Vorboten wird das Licht Teil der Anzeige: Bei „Lichtfraß“ schrumpfen die Lichtkreise sichtbar, „Laterne entzünden“ stellt eine echte Laterne mit Lichtkreis aufs Feld, wer das Splitterlicht hält („Das letzte Licht“), leuchtet lila, und beim Weiterreichen wandert das Licht sichtbar. Die Regeln bleiben gleich, nur die Anzeige ändert sich.
- **So testest du es:** Gegen den Vorboten kämpfen, eine Laterne entzünden und das Splitterlicht weiterreichen: Man sieht immer, wo Licht ist und wer sicher ist.
- **Status:** fertig (22.10.)

## Projekt 2: Kampfgefühl

### Schritt 1: Parieren mit Klang und Funken
- **Ziel:** Parieren mit knackigem Klang und kurzem Funkenblitz. Beim perfekten Parieren zusätzlich ein heller Ton und ein kleiner Zeitlupen-Moment. Klänge vorerst aus kostenlosen Paketen mit freier Lizenz.
- **So testest du es:** Im Kampf normal und perfekt parieren, beides klingt und sieht unterschiedlich aus und fühlt sich gut an.
- **Schon da:** Parade-Klirren und bei der perfekten Parade ein heller Dreiklang (selbst erzeugte Platzhalter, Schritt 19 in FORTSCHRITT.md). Offen sind Funkenblitz, Zeitlupe und Klänge aus einem freien Paket.
- **Hinweis (22.10.):** Klänge neu selbst erzeugt (knackiger), weil die Seiten der freien Klang-Pakete aus der Cloud gesperrt sind. Ein freies Paket (z. B. Kenney „Impact Sounds“, CC0) kann später am PC eingesetzt werden.
- **Status:** fertig (22.10.)

### Schritt 2: Harte Treffer spürbar machen
- **Ziel:** Harte Treffer lassen das Bild für einen Augenblick anhalten, dazu wackelt der Bildschirm leicht.
- **So testest du es:** Einen starken Angriff ausführen und einen harten Treffer einstecken, beides spürt man deutlich.
- **Status:** fertig (22.10.)

### Schritt 3: Schadenszahlen
- **Ziel:** Kritische Treffer erscheinen groß und farbig. Bei Mehrfach-Treffern ploppt jede Zahl einzeln schnell nacheinander auf. Welche Fähigkeiten mehrfach treffen, kommt später aus Abendthema 13.
- **So testest du es:** Einen kritischen Treffer und einen Mehrfach-Angriff (z. B. Schnellfeuer) ansehen.
- **Status:** fertig (22.10.)

## Projekt 3: Geld (Bronze, Silber, Gold)

### Schritt 1: Geld speichern und anzeigen
- **Ziel:** Geld wird als eine Zahl gespeichert und als Bronze, Silber und Gold angezeigt (z. B. 100 Bronze = 1 Silber, 100 Silber = 1 Gold). Die Münznamen stehen an einer einzigen Stelle.
- **So testest du es:** Geld-Anzeige ansehen, per Testknopf Geld dazugeben und prüfen, ob die Münzen richtig umspringen.
- **Status:** fertig (27.10.; bisherige Beträge zählen jetzt als Bronze, die Feinabstimmung kommt mit Schritt 2)

### Schritt 2: Monster lassen wenig Geld fallen
- **Ziel:** Besiegte Monster geben einen kleinen Geldbetrag, damit Geld knapp bleibt.
- **So testest du es:** Monster besiegen, das Geld steigt um einen kleinen Betrag.
- **Schon da:** Monster in der Wildnis geben bereits „etwas Gold“. Offen ist, die Beträge auf Bronze/Silber/Gold umzustellen und knapp zu halten.
- **Status:** fertig (27.10.; Monster 3–5 Bronze, Aufträge ein paar Silber, Heiltrank 25 Bronze)

## Projekt 4: Tasche und Bank

### Schritt 1: Tasche mit 30 Plätzen
- **Ziel:** Die Tasche hat 30 Plätze.
- **So testest du es:** Gegenstände aufheben, bis die Tasche voll ist, danach erscheint ein Hinweis.
- **Status:** fertig (27.10.; Sammeln und Kaufen klappen bei voller Tasche nicht, Geschenke aus Aufträgen kommen trotzdem hinein)

### Schritt 1b: Wegwerfen und Beute-Fenster
- **Ziel:** Gegenstände lassen sich aus der Tasche wegwerfen (mit Nachfrage; nicht bei Gegenständen der Geschichte oder für laufende Aufträge). Passt Beute nach einem Sieg nicht mehr in die Tasche, wartet sie im Beute-Fenster: erst etwas wegwerfen, dann nehmen, oder liegen lassen. (Marcos Wunsch vom 27.10.)
- **So testest du es:** Tasche füllen, Beute bekommen, das Beute-Fenster erscheint. Etwas wegwerfen, dann die Beute nehmen.
- **Status:** fertig (27.10.; Monster lassen noch keine Gegenstände fallen, darum vorerst Testknopf „Test: Beute“)

### Schritt 2: Bank, die überall dasselbe enthält
- **Ziel:** Jede Bankstelle zeigt dieselben eingelagerten Sachen.
- **So testest du es:** Etwas einlagern und wieder herausholen, an zwei Bankstellen prüfen, dass beide dasselbe zeigen.
- **Status:** offen

### Schritt 3: Bankplätze gegen Gold erweitern
- **Ziel:** Man kann mehr Bankplätze kaufen.
- **So testest du es:** Erweiterung kaufen, das Geld sinkt, die Bank hat mehr Plätze.
- **Status:** offen

## Projekt 5: Gürtel und Tränke

### Schritt 1: Vier Gürtelplätze
- **Ziel:** Vier Gürtelplätze, jeder fasst einen kleinen Stapel (z. B. 5). Befüllen nur außerhalb des Kampfes.
- **So testest du es:** Heiltränke auf den Gürtel legen, im Kampf lässt sich der Gürtel nicht umräumen.
- **Status:** offen

### Schritt 2: Ein Gürtel-Gegenstand pro Runde gratis
- **Ziel:** Im Kampf ist ein Gürtel-Gegenstand pro Runde gratis, jeder weitere kostet den Zug.
- **So testest du es:** Trank nehmen und in derselben Runde noch angreifen, ein zweiter Gegenstand beendet den Zug.
- **Status:** offen

### Schritt 3: Gemeinsame Trank-Wartezeit
- **Ziel:** Gemeinsame Wartezeit von 3 Runden für alle Tränke, sichtbar am Gürtel.
- **So testest du es:** Nach einem Trank sind alle Tränke 3 Runden gesperrt und zählen sichtbar herunter.
- **Status:** offen

## Projekt 6: Händler

### Schritt 1: Händler verkauft Tränke und Grundmaterialien
- **Ziel:** Ein Händler verkauft Heiltränke und Grundmaterialien (Garn, Öl, Leder) gegen Geld.
- **So testest du es:** Etwas kaufen, das Geld sinkt, der Gegenstand liegt in der Tasche. Ohne genug Geld klappt der Kauf nicht.
- **Schon da:** Bingos Laden in Kreuzweg verkauft Heiltränke (mit „Zu wenig Gold“). Offen sind die Grundmaterialien und die neuen Münzen.
- **Status:** offen

## Projekt 7: Tag und Nacht
_Aus Marcos Entscheidung vom 22.10.2026: Tageszeit nach der echten Uhrzeit, nachts andere Monster und eigene Stimmung._

### Schritt 1: Tageszeit nach der echten Uhrzeit
- **Ziel:** Das Licht wechselt fließend zwischen Morgen, Tag, Abend und Nacht (Nacht von 21 bis 6 Uhr, dazwischen Dämmerung; die Fest-Nacht der Geschichte bleibt immer Nacht). Das Licht richtet sich nach der lokalen Uhrzeit des Spielers. Nachts ist die Welt dunkler, Laternen, Fenster und Fackeln leuchten stärker. Ein Testknopf stellt die Uhrzeit vor.
- **So testest du es:** Mit dem Testknopf die Uhrzeit auf Abend und Nacht stellen: Die Welt wird langsam dunkler und die Lichter wirken stärker.
- **Status:** offen

### Schritt 2: Nachts andere Monster
- **Ziel:** In der Wildnis stehen nachts andere Monster als tagsüber. Ob Nacht ist, bestimmt hier die Uhrzeit des Servers, damit alle am selben Ort dieselben Monster sehen.
- **So testest du es:** Testknopf auf Nacht: Auf dem Weg nach Grünwacht stehen andere Monster, auf Tag wieder die gewohnten.
- **Status:** offen

## Später (wartet auf andere Teile des Spiels)
- Taschen vom Schneider und Lagerfeuer-Essen (brauchen Berufe)
- Marktstand-Gebühr (braucht den Markt)
- Schriftrollen, Wiederbelebungs-Rolle und besondere Munition
- Testversion bis Stufe 20 mit Kauf (braucht Online-Konten)
- Sternen-Glanz und Siegel-Zähler (braucht den Server)
- Erste eigene Grafiken (wartet auf die Look-Bibel aus Thema 12)
- Nachts geschlossene Läden und andere NPCs (Erweiterung von Tag und Nacht, Projekt 7)
