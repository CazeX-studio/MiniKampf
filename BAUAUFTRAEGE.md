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
- **Status:** fertig (28.10.; Bankstellen: Bankhüterin Ilse in Kreuzweg neben der Gilde, Bankhüter Tamm in Wipfelheim; 20 Plätze, ganze Stapel einlagern und abholen)

### Schritt 3: Bankplätze gegen Gold erweitern
- **Ziel:** Man kann mehr Bankplätze kaufen.
- **So testest du es:** Erweiterung kaufen, das Geld sinkt, die Bank hat mehr Plätze.
- **Status:** fertig (28.10.; an jeder Bankstelle: +10 Plätze für 50 Silber, 1 Gold, 2 Gold, 4 Gold, dann voll ausgebaut mit 60 Plätzen; Preise in data/laeden.json)

## Projekt 5: Gürtel und Tränke

### Schritt 1: Vier Gürtelplätze
- **Ziel:** Vier Gürtelplätze, jeder fasst einen kleinen Stapel (z. B. 5). Befüllen nur außerhalb des Kampfes.
- **So testest du es:** Heiltränke auf den Gürtel legen, im Kampf lässt sich der Gürtel nicht umräumen.
- **Status:** fertig (28.10.; Gürtel unter der Tasche, nur Heiltränke, Stapel bis 5; im Kampf zählen Gürtel und Tasche zusammen, verbraucht wird zuerst vom Gürtel – dass nur der Gürtel zählt, kommt mit Schritt 2)

### Schritt 2: Ein Gürtel-Gegenstand pro Runde gratis
- **Ziel:** Im Kampf ist ein Gürtel-Gegenstand pro Runde gratis, jeder weitere kostet den Zug.
- **So testest du es:** Trank nehmen und in derselben Runde noch angreifen, ein zweiter Gegenstand beendet den Zug.
- **Status:** fertig (28.10.; „Runde“ = eigener Zug; im Kampf zählen nur noch Tränke am Gürtel, neue Tränke hängen sich von selbst an den Gürtel)

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

## Projekt 8: Monsterkarten und Kartenalbum (Beschluss 27.10.)

### Schritt 1: Kartenalbum
- **Ziel:** Eigenes Menü (Taste K und Knopf oben) mit einer Seite pro Region. Feste Plätze für jedes Monster der Region, fehlende Karten nur als dunkler Umriss, Zähler „Grünwacht: 5 / 12“, doppelte Karten mit Anzahl. Die Textzeile unten in der Tasche entfällt.
- **So testest du es:** Mit K das Album öffnen, zwischen den Seiten blättern; gesammelte Karten sind zu sehen, fehlende als Umriss, der Zähler stimmt.
- **Status:** offen

### Schritt 2: Karten aktivieren
- **Ziel:** Eine gefundene Karte fällt als „unbekannte Monsterkarte“ in die Tasche (bei voller Tasche ins Beute-Fenster). „Aktivieren“ dreht sie mit einem kleinen Aufdeck-Moment um, danach liegt sie im Album und die Tasche ist wieder frei.
- **So testest du es:** Monster besiegen, bis eine Karte kommt, in der Tasche „Aktivieren“ wählen: Die Karte dreht sich um und steht im Album.
- **Status:** offen

### Schritt 3: Monster-Infos im Album
- **Ziel:** Schon die erste Karte eines Monsters zeigt im Album sein Element und seine Schwäche.
- **So testest du es:** Im Album eine Karte anklicken: Element und Schwäche stehen dabei, bei fehlenden Karten nicht.
- **Status:** offen

### Schritt 4: Besitzeffekte
- **Ziel:** Jede Karte im Album gibt einen kleinen dauerhaften Bonus, der zum Monster passt (z. B. Rindenbär +1 Leben, Windfalke +1 Tempo) und im Kampf wirkt. Doppelte zählen nicht mehrfach. Im Album und unter „Werte (C)“ steht, was die Karten zusammen bringen. Vorerst nur Werte, die es im Kampf schon gibt (Leben, Mana, Angriff, Tempo); Verteidigung kommt mit der Ausrüstung dazu.
- **So testest du es:** Werte (C) ansehen, eine neue Karte aktivieren: Der Wert steigt um den Bonus der Karte.
- **Status:** offen

### Schritt 5: Deck für Kreuzweg-Karten wählen
- **Ziel:** Im Album wählt man die 5 Karten, mit denen man bei Kreuzweg-Karten antritt.
- **So testest du es:** Im Album 5 Karten markieren, gegen Marv spielen: Genau diese Karten sind auf der Hand.
- **Status:** offen

### Schritt 6: Doppelte Karten bei Bingo verkaufen
- **Ziel:** Bingo kauft doppelte Karten für ein paar Bronze. Die letzte Karte einer Sorte bleibt immer im Album.
- **So testest du es:** Mit einer doppelten Karte zu Bingo gehen, sie verkaufen: Das Geld steigt, im Album steht eine weniger.
- **Status:** offen

### Schritt 7: Belohnung für eine volle Seite
- **Ziel:** Wer alle Karten einer Region hat, bekommt eine Belohnung (Titel, besonderer Kartenrücken oder Extra-Platz in der Tasche; welche genau, entscheidet Marco).
- **So testest du es:** Per Testknopf alle Karten einer Region geben: Die Belohnung erscheint mit einer Meldung.
- **Status:** offen

### Schritt 8: Marv kommentiert neue Karten
- **Ziel:** Hat man eine Karte, die Marv noch nicht gesehen hat, spricht er einen darauf an („Ooooh, die hab ich noch nicht!“).
- **So testest du es:** Eine neue Karte aktivieren und in Kreuzweg zu Marv gehen.
- **Status:** offen

### Schritt 9: Karten verbessern bis +10
- **Ziel:** Karten lassen sich bis +10 verbessern, mit einer doppelten Karte derselben Sorte plus etwas Gold. Bis +4 klappt es immer, ab +5 kann es misslingen. Jede Stufe stärkt den Besitzeffekt (und später den Sockel). Bei einem Fehlschlag bleibt die Karte auf ihrer Stufe, nur die doppelte Karte und das Gold sind weg. (Beschluss 27.10.)
- **So testest du es:** Eine Karte verbessern: Sie zeigt „+1“, der Bonus unter „Werte (C)“ steigt, eine doppelte Karte und etwas Gold sind weg. Ab +5 klappt es manchmal nicht.
- **Status:** offen

## Projekt 9: Kreuzweg im Baukasten
_Aus Marcos Entscheidung vom 27.10.2026: Die Welt bleibt in Rautenansicht und wird aus Einzelbildern zusammengesetzt (Vorbild: Marcos Bild vom Kreuzweg-Marktplatz bei Nacht). Bild-Regeln in `data/BAUKASTEN.md`._

### Schritt 1: Baukasten-Testfeld
- **Ziel:** Ein kleiner Marktplatz aus Platzhalter-Bildern (Boden, Häuser, Stände, Statue, Torbogen, Brücke, Laternen, Bäume, Kleinkram). Man kann laufen, Häuser werden durchsichtig, wenn man dahinter steht, Laternen und Fackeln leuchten nachts. Welche Teile es gibt und wo sie stehen, steht in Datendateien, nicht im Code.
- **So testest du es:** Im Startmenü „Baukasten-Testfeld“: herumlaufen, über die Brücke gehen, hinter ein Haus laufen, mit N Tag und Nacht umschalten, mit G das Raster ansehen.
- **Status:** fertig (27.10.)

### Schritt 2: Echte Bilder einsetzen
- **Ziel:** Marcos Bildblätter (KI-Vorlagen nach `data/BAUKASTEN.md`) zuschneiden, verkleinern und die Platzhalter ersetzen.
- **So testest du es:** Im Testfeld sieht alles aus wie auf Marcos Bild, jedes Teil steht sauber auf seinem Feld (Raster mit G).
- **Status:** fertig (27.10.; 44 Teile aus 7 Bildblättern, Testfeld nach Kreuzweg aus design.md neu aufgebaut; dazu Splitterkreis, zwei Krater und Sternsplitter mit Umschalten der Geschichte per K)

### Schritt 3: Übergänge und Ufer
- **Ziel:** Weiche Übergänge zwischen Gras, Pflaster und Erde, Ufer am Wasser, damit der Boden nicht kariert wirkt.
- **So testest du es:** Im Testfeld an Straßenrand und Fluss entlanglaufen: keine harten Kanten mehr.
- **Status:** fertig (27.10.; ausgefranste Ränder nach Vorrang Gras > Erde > Pflaster > Platz > Wasser, Uferschatten im Wasser, dunkle Kachelränder entfernt)

### Schritt 4: Figuren in vier Richtungen
- **Ziel:** Vega (dann alle Figuren) läuft schräg nach oben und unten mit eigenen Bildern statt nur seitlich.
- **So testest du es:** Im Testfeld in alle Richtungen laufen: Vega schaut immer in Laufrichtung.
- **Status:** fertig für Vega im Testfeld (27.10.; 24 Bilder: Stehen und Laufen nach vorne und hinten, nach links gespiegelt; in der Kreuzweg-Demo und für andere Figuren noch nicht)

### Schritt 5: Kreuzweg aus dem Baukasten
- **Ziel:** Die echte Stadt Kreuzweg wird aus den Baukasten-Teilen aufgebaut (Plan nach design.md: Marktplatz, Gilde, Wegrast, Gesandten-Hof, Bingos Stand, sechstes Tor). Figuren, Aufträge und Geschichte bleiben, wie sie sind.
- **So testest du es:** Die Kreuzweg-Demo spielen: Alles ist wie vorher, sieht aber aus wie im Testfeld.
- **Entschieden (28.10.):** rund mit Ringstraße und sechs Toren. Norden: sechstes Tor hinter der Statue; Süden: Glutoase und Haupteingang; Westen: Grünwacht; Nordwesten Arkanum, Nordosten Nebelinseln, Osten Messinghafen (siehe design.md „Kreuzweg im Detail“).
- **Status:** offen

### Schritt 6: Grünwacht aus dem Baukasten
- **Ziel:** Weg nach Grünwacht, Waldboden, Wipfelheim und Pilzhöhle ebenso umstellen (braucht eigene Wald-Teile).
- **So testest du es:** Grünwacht durchspielen: alles wie vorher, im neuen Aussehen.
- **Status:** offen

## Projekt 10: Oberfläche nach Marcos UI-Entwurf (27.10.)

Grundlage: Marcos Asterfall-UI-Set (zwei Bildblätter in `tools/vorlagen/ui/`) und der Entwurf mit Auftragsbuch, Tasche,
Werten, Zugleiste, Kampfmenü, Sieg-Fenster und Meldungen. Look überall eingebaut und Meldungen mit Rahmen: fertig (27.10.).

### Schritt 1: Kampf nach Entwurf
- **Ziel:** Zugleiste mit Bildern in Goldfeldern, Namensschilder mit Goldrahmen und Leisten aus dem Set, Kampfmenü links
  (Angriff, Fähigkeiten, Gegenstände, Verteidigen, Fliehen) neben den Fähigkeiten.
- **So testest du es:** Einen Kampf beginnen: „Angriff“ lässt gleich ein Ziel wählen, „Verteidigen“ wartet ab, „Gegenstände“ zeigt nur Tränke.
- **Status:** fertig (27.10.)

### Schritt 2: Sieg-Fenster und Gegenstands-Infofenster
- **Ziel:** Sieg-Fenster mit Banner, Belohnung mit Symbolen und goldenem Knopf; Infofenster beim Darüberfahren über einem Gegenstand.
- **So testest du es:** Einen Kampf gewinnen; in der Tasche mit der Maus über einen Gegenstand fahren.
- **Status:** fertig (27.10.)

### Schritt 3: Auftragsbuch, Werte und Tasche nach Entwurf
- **Ziel:** Auftragsbuch mit Liste links und Einzelheiten rechts (Häkchen, Belohnung), Werte mit Bild der Figur und Leisten,
  Tasche mit Gold und belegten Plätzen unten, Schnellleiste mit Symbolen, goldene und rote Knöpfe.
- **So testest du es:** J, C und I drücken und die drei Fenster ansehen.
- **Status:** fertig (27.10.; Reiter mit Gegenstandsarten in der Tasche fehlen noch, weil Gegenstände noch keine Art haben)

### Schritt 4: Teile vom Art Designer einsetzen
- **Ziel:** Element- und Fähigkeits-Symbole, Fliehen-Symbol, Bildlaufleiste, Trennlinie, Ruf-Leiste mit 10 Feldern,
  Weiter-Dreieck, Pergament-Sprechblase, Bilderrahmen und Auftrags-Bändchen einbauen (Prompt am 27.10. an Marco gegeben).
- **So testest du es:** Kampf, Werte (Ruf) und Auftragsbuch ansehen: überall die neuen Symbole.
- **Status:** fertig (27.10.; Gegenstandsarten-Symbole liegen bereit, Reiter in der Tasche erst, wenn Gegenstände eine Art haben)

## Projekt 11: Figuren wie bei Ragnarok (Kopf und Körper getrennt)
_Aus Marcos Entscheidung vom 28.10.2026: Spielfiguren werden aus Kopf und Körper zusammengesetzt. Jede Klasse hat einen männlichen und einen weiblichen Körper (Kleidung, Waffe, alle Bewegungen), der Kopf (Gesicht, Haut, Haare) liegt darüber und bleibt beim Klassenwechsel gleich. Erste Figur: Kofi._

### Schritt 1: Probe mit Kofi
- **Ziel:** Kofis fertige Bilder in Kopf und Körper zerlegen (Kopf pro Bild ausschneiden, Ankerpunkt am Hals merken) und im Spiel wieder zusammensetzen. Zeigt, ob das mit KI-Bildern sauber klappt, bevor neue Blätter bestellt werden.
- **So testest du es:** Im Editor bei „Figuren-Animationen“ Kofi ansehen: Er sieht aus wie vorher, Kopf und Körper sind aber getrennte Teile (Knopf „Bilder: ganz / aus Teilen / Standardkopf“).
- **Status:** fertig (28.10.2026: 46 von 49 Bildern getrennt, liegend und Parade-Anfang bleiben ganz)

### Schritt 2: Kopf-Blätter der sechs Novizen
_Am 28.10. geteilt: Kofis Kopf-Blatt kam zuerst._
- **Ziel:** Pro Novize ein Kopf-Blatt (Kopf schräg vorne, seitlich, schräg hinten; Gesichter normal, Schmerz, Freude, Augen zu). Prompt steht in Spieldesign/GRAFIK_AUFTRAG.md (B7).

#### Schritt 2a: Kofis Kopf-Blatt
- **Ziel:** Kofis Kopf-Blatt einbauen: Köpfe ausschneiden, in jedem Bild den Kopf finden und tauschen, Gesicht passend zur Bewegung (Schmerz beim Treffer, entschlossen beim Angriff, Freude beim Sieg, Augen zu bei Fähigkeit und Fallen).
- **So testest du es:** Editor → „Figur: Kofi“ → „Figuren-Animationen“ → Knopf auf „Bilder: neuer Kopf“: Kofi trägt die Köpfe aus dem Blatt.
- **Status:** fertig (28.10.2026)

#### Schritt 2b: Kopf-Blätter der anderen fünf Novizen
- **Ziel:** Die fünf übrigen Kopf-Blätter einbauen und im Editor zwischen den Köpfen wechseln (auf Kofis Körper).
- **So testest du es:** Im Editor zwischen den sechs Köpfen wechseln, der Körper bleibt gleich.
- **Status:** in Arbeit (28.10.2026: Kopfwechsel gebaut, 1 von 5 Köpfen da: Novizin w1 (roter Zopf). Köpfe sind namenlos: m1 = Kofis Kopf, weitere heißen m2, m3, w2, w3. Ein neues Blatt einbauen: Datei nach `tools/vorlagen/<kennung>_kopf.png`, Kennung in `WEITERE_KOEPFE` in `tools/kopf_koerper.py`, Werkzeug laufen lassen, danach `tools/koerper_blatt.py`.)

### Schritt 3: Novizen-Körper männlich und weiblich
- **Ziel:** Ein gemeinsamer Novizen-Körper je Geschlecht für alle sechs; Schal- und Schildfarbe färbt das Spiel pro Figur. Prompt: Spieldesign/GRAFIK_AUFTRAG.md (B8), Kopf als grünes Oval, keine Haut sichtbar.
- **So testest du es:** Alle sechs Novizen laufen und kämpfen mit demselben Körper, aber eigenem Kopf und eigener Farbe.
- **Status:** fertig (28.10.2026: beide Körper komplett, je drei Blätter; Kopf neigt sich mit. Einfärben entfällt: Marco hat entschieden, dass alle Novizen gleich aussehen.)

### Schritt 4: Körper der Grünwacht-Klassen
- **Ziel:** Bogenschütze und Monster-Zähmer, je männlich und weiblich. Beim Lernen der Klasse wechselt der Körper, der Kopf bleibt.
- **So testest du es:** In Grünwacht die Klasse lernen: Die Figur trägt danach die Klassenkleidung.
- **Status:** offen

### Schritt 5: Figur erstellen
- **Ziel:** Zu Spielbeginn Geschlecht wählen (daraus folgt der Körper), einen passenden Kopf (namenlos: m1, w1 …) wählen, Namen eingeben (design.md: „Charakter erstellen“). Später kommen Frisuren dazu (Ideen-Parkplatz).
- **So testest du es:** Neues Spiel: Figur zusammenstellen, sie läuft so durch Kreuzweg.
- **Status:** fertig (28.10.2026: Körper männlich/weiblich, Kopf blättern, Name; gespeichert im Spielstand. Wählbar sind die Köpfe, die es schon gibt: Novize m1 und Novizin w1, je nach Geschlecht. Frisuren kommen später.)

### Schritt 6: Körper der übrigen Klassen
- **Ziel:** Die übrigen neun Klassen je männlich und weiblich, Region für Region.
- **So testest du es:** Jede Klasse in der Kampf-Sandbox mit eigenem Körper ansehen.
- **Status:** offen

## Später (wartet auf andere Teile des Spiels)
- Taschen vom Schneider und Lagerfeuer-Essen (brauchen Berufe)
- Marktstand-Gebühr (braucht den Markt)
- Schriftrollen (auch „Licht im Dunkeln“, beschlossen 28.10.), Wiederbelebungs-Rolle und besondere Munition
- Testversion bis Stufe 20 mit Kauf (braucht Online-Konten)
- Sternen-Glanz und Siegel-Zähler (braucht den Server)
- Erste eigene Grafiken (wartet auf die Look-Bibel aus Thema 12)
- Nachts geschlossene Läden und andere NPCs (Erweiterung von Tag und Nacht, Projekt 7)
- Monsterkarten sockeln (braucht die Ausrüstung) und Karten mit Freunden tauschen (braucht den Server)
